#!/bin/bash
set -o errexit
set -x

# resolve packages needed
function packages_resolving {
echo -e "\033[1;32m------------------------------packages_resolving---------------------------\033[0m"
	#install some dependency packages
	apt purge docker* -y
	apt purge ceph* -y
	[ ! -d /tmp/k8s_packages ] && mkdir /tmp/k8s_packages
	tar xf /root/k8s_kata/k8s_packages.tar.bz2 -C /tmp/k8s_packages
	dpkg -i /tmp/k8s_packages/*.deb
	apt-mark hold kubelet kubeadm kubectl
	systemctl daemon-reload && systemctl restart kubelet
}

#resolve kernel parameters needed
function resolve_kernel_parameters {
echo -e "\033[1;32m------------------------------resolve_kernel_parameters--------------------\033[0m"
	echo 'net.bridge.bridge-nf-call-iptables = 1
	fs.inotify.max_user_watches=1048576

	net.ipv6.conf.all.disable_ipv6 = 1
	net.ipv6.conf.default.disable_ipv6 = 1

	net.ipv4.conf.all.rp_filter=0
	net.ipv4.conf.default.rp_filter=0

	net.ipv4.ip_forward=1

	' >> /etc/sysctl.conf && \
	sysctl -p
}

function stop_swap {
echo -e "\033[1;32m------------------------------stop_swap------------------------------------\033[0m"
	swapoff -a
	sed -i -r s@\(.*\)swap\(.*\)@#\\1swap\\2@g /etc/fstab
}

function deploy_etcd {
echo -e "\033[1;32m------------------------------deploy_etcd----------------------------------\033[0m"
#install etcd
tar xf /root/k8s_kata/etcd-v3.2.24-linux-arm64.tar.gz -C /usr/local/
ln -svf /usr/local/etcd-v3.2.24-linux-arm64/etcd /usr/bin/etcd
ln -svf /usr/local/etcd-v3.2.24-linux-arm64/etcdctl /usr/bin/etcdctl

#make dir needed
[ ! -d /var/lib/etcd ] && mkdir /var/lib/etcd
[ ! -d /etc/etcd ] && mkdir /etc/etcd
[ ! -e /etc/etcd/etcd.conf ] && touch /etc/etcd/etcd.conf
if ! id etcd &> /dev/null;then
	useradd etcd
fi

#make service for etcd
IP1=`ssh master1 ifconfig eth0 | grep "\<inet\>" | awk '{print $2}' | awk -F":" '{print $2}'`
IP2=`ssh master2 ifconfig eth0 | grep "\<inet\>" | awk '{print $2}' | awk -F":" '{print $2}'`
IP3=`ssh master3 ifconfig eth0 | grep "\<inet\>" | awk '{print $2}' | awk -F":" '{print $2}'`
ETCD_IP=`ifconfig eth0 | grep "\<inet\>" | awk '{print $2}' | awk -F":" '{print $2}'`
HOSTNAME=`hostname`
cat > /lib/systemd/system/etcd.service << EOF
[Unit]
Description=Etcd Server
After=network.target
After=network-online.target
Wants=network-online.target

[Service]
#Type=notify
WorkingDirectory=/var/lib/etcd/
EnvironmentFile=-/etc/etcd/etcd.conf
Environment="ETCD_UNSUPPORTED_ARCH=arm64"
User=etcd
# set GOMAXPROCS to number of processors
ExecStart=/bin/bash -c "GOMAXPROCS=$(nproc) /usr/bin/etcd --name ${HOSTNAME} --initial-advertise-peer-urls http://${ETCD_IP}:2380 \
  --listen-peer-urls http://${ETCD_IP}:2380 \
  --listen-client-urls http://${ETCD_IP}:2379,http://127.0.0.1:2379 \
  --advertise-client-urls http://${ETCD_IP}:2379 \
  --initial-cluster-token etcd-cluster-1 \
  --initial-cluster master1=http://${IP1}:2380,master2=http://${IP2}:2380,master3=http://${IP3}:2380 \
  --initial-cluster-state new \
  --data-dir=\"/var/lib/etcd/${HOSTNAME}.etcd\" "
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF
chown etcd:etcd /var/lib/etcd/ -R
systemctl daemon-reload
systemctl enable   etcd
systemctl restart  etcd 
}

#检查etcd的健康状态
function etcd_health_check {
echo -e "\033[1;32m------------------------------etcd_health_check----------------------------\033[0m"
/usr/bin/etcdctl cluster-health
}

#安装keepalived+haproxy
function ha_deploy {
[ ! -d /tmp/ha ] && mkdir /tmp/ha
tar xf /root/k8s_kata/ha.tar.bz2 -C /tmp/ha
dpkg -i /tmp/ha/*.deb
cat > /etc/haproxy/haproxy.cfg <<EOF
global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    stats socket /var/run/haproxy-admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon
    nbproc 1

defaults
    log     global
    timeout connect 5000
    timeout client  10m
    timeout server  10m

listen  admin_stats
    bind 0.0.0.0:10080
    mode http
    log 127.0.0.1 local0 err
    stats refresh 30s
    stats uri /status
    stats realm welcome login\ Haproxy
    stats auth admin:123456
    stats hide-version
    stats admin if TRUE

listen kube-master
    bind 0.0.0.0:8443
    mode tcp
    option tcplog
    balance source
    server master1 172.16.4.61:6443 check inter 2000 fall 2 rise 2 weight 1
    server master2 172.16.4.62:6443 check inter 2000 fall 2 rise 2 weight 1
    server master3 172.16.4.63:6443 check inter 2000 fall 2 rise 2 weight 1
EOF
service haproxy restart

if [ `hostname` = "master1" ];then
cat > /etc/keepalived/keepalived.conf <<EOF
! Configuration File for keepalived
global_defs {
   router_id haproxy
}
vrrp_script check_run {
   script "killall -0 haproxy"
   interval 5
}
vrrp_sync_group VG1 {
    group {
		VI_1
    }
}
vrrp_instance VI_1 {
    state MASTER
    interface eth0
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass haproxy
    }
    track_script {
        check_run 
    }
    virtual_ipaddress {
        172.16.4.250
    }
}

EOF
else
cat > /etc/keepalived/keepalived.conf <<EOF
! Configuration File for keepalived
global_defs {
   router_haproxy
}
vrrp_script check_run {
   script "killall -0 haproxy"
   interval 5
}
vrrp_sync_group VG1 {
    group {
          VI_1
    }
}
vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 51
    priority 50
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass haproxy
    }
    track_script {
        check_run 
    }
    virtual_ipaddress {
        172.16.4.250
    }
}
EOF
fi
systemctl restart keepalived.service
}

#分发镜像
function distribute_k8s_images {
echo -e "\033[1;32m------------------------------distribute_k8s_images------------------------\033[0m"
docker load -i k8s_arm64_images.tar
}
#部署k8s的master节点
function deploy_k8s_master {
echo -e "\033[1;32m------------------------------deploy_k8s_master----------------------------\033[0m"
IP1=`ssh master1 ifconfig eth0 | grep "\<inet\>" | awk '{print $2}' | awk -F":" '{print $2}'`
IP2=`ssh master2 ifconfig eth0 | grep "\<inet\>" | awk '{print $2}' | awk -F":" '{print $2}'`
IP3=`ssh master3 ifconfig eth0 | grep "\<inet\>" | awk '{print $2}' | awk -F":" '{print $2}'`
IP=`ifconfig eth0 | grep "\<inet\>" | awk '{print $2}' | awk -F":" '{print $2}'`
## apiServerCertSANs 里要写上所有 master 节点的 ip
## For flannel to work correctly, --pod-network-cidr=10.244.0.0/16 has to be passed to kubeadm init. 
cat > /root/config.yaml << EOL
apiVersion: kubeadm.k8s.io/v1alpha2
kind: MasterConfiguration
kubernetesVersion: v1.11.3      # kubernetes的版本
api:
  advertiseAddress: ${IP}   
  bindPort: 6443
  controlPlaneEndpoint: 172.16.4.250:8443   #VIP地址
apiServerCertSANs:              #此处填所有的masterip和lbip和其它你可能需要通过它访问apiserver的地址和域名或者主机名等
- master1
- master2
- master3
- 172.16.4.61
- 172.16.4.62
- 172.16.4.63
- 172.16.4.250
- 127.0.0.1
etcd:    #ETCD的地址
  external:
    endpoints:
    - "http://${IP1}:2379"
    - "http://${IP2}:2379"
    - "http://${IP3}:2379"
#    caFile: /etc/kubernetes/pki/etcd/etcd-ca.pem
#    certFile: /etc/kubernetes/pki/etcd/etcd.pem
#    keyFile: /etc/kubernetes/pki/etcd/etcd-key.pem
networking:
  podSubnet: 10.244.0.0/16      # pod网络的网段
kubeProxy:
  config:
    mode: ipvs   #启用IPVS模式
featureGates:
  CoreDNS: true
#imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers  # image的仓库源
EOL

## init
kubeadm init --config=/root/config.yaml

}

#部署flannel网络
function deploy_flannel {
echo -e "\033[1;32m------------------------------deploy_flannel-------------------------------\033[0m"
wget https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml  && \
sed -i "s/amd64/arm64/g" kube-flannel.yml  && \
export KUBECONFIG=/etc/kubernetes/admin.conf  && \
kubectl apply -f kube-flannel.yml  
}

#部署ceph集群mon
function deploy_ceph_mon {
echo -e "\033[1;32m------------------------------deploy_ceph_mon------------------------------\033[0m"

CEPH_NET="172.16.4.0/24"
CEPH_IP="172.16.4.61"

theHostname=$(hostname)
theFsid=$(uuidgen)
publicNetwork=$CEPH_NET
clusterNetwork=$CEPH_NET

# "osd pool default size": 用于设置一存储池的对象副本数,默认值为3,等同于 ceph osd pool set {pool-name} size {size} 
cat > /etc/ceph/ceph.conf << EOF
[global]
fsid = ${theFsid}
mon initial members = ${theHostname}
mon_host = $CEPH_IP
public network = ${publicNetwork}
cluster network = ${clusterNetwork}
auth cluster required = cephx
auth service required = cephx
auth client required = cephx

[osd]
osd journal size = 20000
osd pool default size = 3
osd pool default min size = 2
osd pool default pg num = 256
osd pool default pgp num = 256
osd crush chooseleaf type = 1
filestore xattr use omap = true
filestore min sync interval = 3
filestore max sync interval = 10
filestore queue max ops = 25000
filestore queue max bytes = 10485760
filestore queue committing max ops = 5000
filestore queue committing max bytes = 3072000000
journal max write bytes = 1073714824
journal max write entries = 10000
journal queue max ops = 50000
journal queue max bytes = 3072000000
osd max write size = 512
osd client message size cap = 2147483648
osd deep scrub stride = 131072
osd op threads = 4
osd disk threads = 2
osd map cache size = 1024
osd map cache bl size = 128
osd mount options xfs = "rw,noexec,nodev,noatime,nodiratime"
osd recovery op priority = 4
osd recovery max active = 10
osd max backfills = 4

[client]
rbd cache = false
rbd cache size = 0
rbd cache max dirty =0
rbd cache target dirty = 0
rbd cache writethrough until flush = false
# 内核 rbd.ko 不支持某些特性，需要加此配置
rbd default features = 3
EOF

ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow'
ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring

rm -f /tmp/monmap
monmaptool --create --add ${theHostname} $CEPH_IP --fsid ${theFsid} /tmp/monmap
[ ! -d /var/lib/ceph/mon/ceph-${theHostname} ] && mkdir /var/lib/ceph/mon/ceph-${theHostname}
ceph-mon --mkfs -i ${theHostname} --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
sudo touch /var/lib/ceph/mon/ceph-${theHostname}/done
chown ceph:ceph /var/lib/ceph/mon/ -R
systemctl start ceph-mon@${theHostname}
systemctl enable ceph-mon@${theHostname}
systemctl enable ceph.target
}

#部置ceph集群准备osd
function deploy_ceph_prepare_osd {
echo -e "\033[1;32m------------------------------deploy_ceph_prepare_osd----------------------\033[0m"
[ ! -d /data ] && mkdir /data
DISK_LABEL="data"
DATA_DIR="/data"
for i in sdb ; do
    echo -e "\n------ ${i} ------"
    mkfs.xfs -f -K -L ${DISK_LABEL}_${i} /dev/${i}
    mkdir -p ${DATA_DIR}/${i}
    echo "/dev/disk/by-label/${DISK_LABEL}_${i}  ${DATA_DIR}/${i}   xfs   rw,noexec,nodev,noatime,nodiratime,nofail    0 0" >> /etc/fstab
    sleep 1
    mount -a
done
}

#部署ceph集群加载osd
function deploy_ceph_add_osd {
echo -e "\033[1;32m------------------------------deploy_ceph_add_osd--------------------------\033[0m"
theHostname=$(hostname)
ceph osd crush add-bucket ${theHostname} host
ceph osd crush move ${theHostname} root=default
DATA_DIR="/data/sdb"

for dataDir in "$DATA_DIR"  ; do
    echo -e "\n------ ${dataDir} ------"
    num=`ceph osd create`
    mkdir -p ${dataDir}/osd/ceph-${num}
    ln -sf ${dataDir}/osd/ceph-${num} /var/lib/ceph/osd/ceph-${num}
    ceph-osd -i ${num} --mkfs --mkkey
    ceph auth add osd.${num} osd 'allow *' mon 'allow profile osd' -i /var/lib/ceph/osd/ceph-${num}/keyring
    ceph osd crush add osd.${num} 1.0 host=$(hostname)
    chown ceph:ceph /var/lib/ceph/osd ${dataDir}/osd -R
    systemctl start ceph-osd@${num} 
    systemctl enable ceph-osd@${num}
    systemctl enable ceph.target
    sleep 2
done
}

#部署计算节点
function deploy_compute_node {
echo -e "\033[1;32m------------------------------deploy_compute_node--------------------------\033[0m"
#stop all service
#systemctl stop kubelet frakti hyperd

#install golang
tar xf /root/k8s_kata/go1.10.4.linux-arm64.tar.gz -C /usr/local/
ln -svf /usr/local/go/bin/go /usr/bin/go

#make frakti
#[ ! -d /opt/go ] && mkdir /opt/go -pv
#echo "export GOPATH=/opt/go" >> /etc/profile.d/go.sh
#source /etc/profile.d/go.sh
#mkdir -p $GOPATH/src/k8s.io
#tar xf /root/k8s_kata/frakti-master.tar.bz2 -C $GOPATH/src/k8s.io/
#cd $GOPATH/src/k8s.io/frakti
#make

#make hyperd
#mkdir -p ${GOPATH}/src/github.com/hyperhq
#cd ${GOPATH}/src/github.com/hyperhq
#tar xf /root/k8s_kata/hyperd-1.0.0.tar.bz2
#cd hyperd/
#./autogen.sh
#./configure
#make

#configure kubelet
NODE_IP=`ifconfig eth0 | grep "\<inet\>" | awk '{print $2}' | awk -F":" '{print $2}'`
logDir='/var/log/kubernetes/'
mkdir -p ${logDir}
reservedMemory='1G'
echo "[Service]
Environment=\"KUBELET_EXTRA_ARGS=--container-runtime=remote \
--container-runtime-endpoint=/var/run/frakti.sock \
--feature-gates=AllAlpha=true \
--enable-controller-attach-detach=false \
--node-ip=${NODE_IP} \
--logtostderr=false --log-dir=${logDir} --v=3 \
--max-pods=2000 \
--system-reserved=memory=${reservedMemory}\"
"  > /etc/systemd/system/kubelet.service.d/05-frakti.conf
systemctl daemon-reload
systemctl enable kubelet

#configure hyperd
#cd ${GOPATH}/src/github.com/hyperhq/hyperd
cp /root/k8s_kata/hyperd -rf /usr/bin/hyperd
cp /root/k8s_kata/hyperctl -rf /usr/bin/hyperctl
chmod +x /usr/bin/{hyperctl,hyperd}
cp /root/k8s_kata/hyperd.service /lib/systemd/system/
[ ! -d /etc/hyper ] && mkdir /etc/hyper
cp /root/k8s_kata/config /etc/hyper/
[ ! -d /var/lib/hyper/ ] && mkdir -p /var/lib/hyper/
cp /root/k8s_kata/{kernel,hyper-initrd.img} /var/lib/hyper/ 
#configure frakti
#cd $GOPATH/src/k8s.io/frakti
cp -f /root/k8s_kata/frakti /usr/bin
chmod +x /usr/bin/frakti
ceph_drive_dir=/usr/libexec/kubernetes/kubelet-plugins/volume/exec/hyper~cephrbd
[ ! -d $ceph_drive_dir ] && mkdir -p $ceph_drive_dir
cp /root/k8s_kata/cephrbd /usr/libexec/kubernetes/kubelet-plugins/volume/exec/hyper~cephrbd/cephrbd
chmod +x /usr/libexec/kubernetes/kubelet-plugins/volume/exec/hyper~cephrbd/cephrbd
cp /root/k8s_kata/frakti.service /lib/systemd/system/
ssa=`ifconfig eth0 | grep "\<inet\>" | awk '{print $2}' | awk -F":" '{print $2}'`
sed -i s@--streaming-server-addr=192.168.2.117@--streaming-server-addr=$ssa@g /lib/systemd/system/frakti.service

#start all services
[ ! -d /var/log/hyper ] && mkdir /var/log/hyper
[ ! -d /var/log/frakti ] && mkdir /var/log/frakti
systemctl daemon-reload
service hyperd start
systemctl enable hyperd
service frakti start
systemctl enable frakti
service kubelet start
}

function authentication {
echo -e "\033[1;32m------------------------------authentication-------------------------------\033[0m"
programDir=`dirname $0`
programDir=$(readlink -f $programDir)
parentDir="$(dirname $programDir)"
programDirBaseName=$(basename $programDir)
set -x
export KUBECONFIG=/etc/kubernetes/admin.conf
for i in `seq 1 30`; do
    aaa=`kubectl get csr --all-namespaces | grep Pending | awk '{print $1}'`
    if [ "$aaa" ]; then
        for i in $aaa; do
            kubectl certificate approve $i || exit 1
        done
        sleep 5
    else
        break
    fi
done
exit 0
}
		
