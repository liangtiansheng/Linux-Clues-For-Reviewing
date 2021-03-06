 参考：http://blog.51cto.com/bigboss/2174899
 1、环境 ：
    系统版本：Linux master1 4.4.58-20180525.kylin.server.YUN+-generic #kylin SMP Mon May 28 10:52:24 CST 2018 aarch64 aarch64 aarch64 GNU/Linux
    Kubernetes: v1.11.3
    Docker-ce: 17.03.2-ce

    Keepalived保证apiserever服务器的IP高可用
    Haproxy实现apiserver的负载均衡
    master x3 && etcd x3 保证k8s集群可用性

    172.16.4.61        master1 + Keepalived + Haproxy + etcd
    172.16.4.62        master2 + Keepalived + Haproxy + etcd
    172.16.4.63        master3 + Keepalived + Haproxy + etcd
    172.16.4.64        compute1
    172.16.4.65        compute2
    172.16.4.250       VIP、apiserver的地址
2、所有节点防火墙：
    sed -ri 's#(SELINUX=).*#\1disabled#' /etc/selinux/config
    setenforce 0
    systemctl disable firewalld
    systemctl stop firewalld
3、所有节点关闭swap:
    swapoff -a //将fstab中的swap也注释掉
4、所有节点加载内核模块
    $ sudo modprobe br_netfilter
    $ sudo modprobe ip_vs
5、所有节点配置转发相关参数，否则可能会出错
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vm.swappiness=0
EOF

    sysctl --system
6、所有节点加载ipvs相关模块：
    root@master1:~# vim /etc/modules-load.d/ipvs.conf
    ip_vs_dh
    ip_vs_fo
    ip_vs_ftp
    ip_vs
    ip_vs_lblc
    ip_vs_lblcr
    ip_vs_lc
    ip_vs_nq
    ip_vs_ovf
    ip_vs_pe_sip
    ip_vs_rr
    ip_vs_sed
    ip_vs_sh
    ip_vs_wlc
    ip_vs_wrr
7、所有节点手动二进制安装kubeadm kubectl kubelet 1.11.3版本和docker 17.03.2-ce
8、所有节点配置hosts
    172.16.4.61        master1
    172.16.4.62        master2
    172.16.4.63        master3
    172.16.4.64        compute1
    172.16.4.65        compute2
    172.16.4.250       VIP
9、三个master节点安装etcd，用二进制安装即可，这里不打算用证书配置etcd
10、master1节点安装keepalived+haproxy,配置如下
cat  > keepalived-master.conf <<EOF
global_defs {
    router_id lb-master-105
}

vrrp_script check-haproxy {
    script "killall -0 haproxy"
    interval 5
    weight -30
}

vrrp_instance VI-kube-master {
    state MASTER
    priority 120
    dont_track_primary
    interface ${VIP_IF}
    virtual_router_id 68
    advert_int 3
    track_script {
        check-haproxy
    }
    virtual_ipaddress {
        ${MASTER_VIP}
    }
}
EOF

cat > haproxy.cfg <<EOF
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
11、master2,master3同样配置keepalived+haproxy，注意配置不同，主备优先级之类的
12、master1上执行
    cd $HOME
cat << EOF > /root/kubeadm-init.yaml
apiVersion: kubeadm.k8s.io/v1alpha2
kind: MasterConfiguration
kubernetesVersion: v1.11.3      # kubernetes的版本
api:
advertiseAddress: 172.16.4.61   
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
    - "http://172.16.4.61:2379"
    - "http://172.16.4.62:2379"
    - "http://172.16.4.63:2379"
#        caFile: /etc/kubernetes/pki/etcd/etcd-ca.pem
#        certFile: /etc/kubernetes/pki/etcd/etcd.pem
#        keyFile: /etc/kubernetes/pki/etcd/etcd-key.pem
networking:
podSubnet: 10.244.0.0/16      # pod网络的网段
kubeProxy:
config:
    mode: ipvs   #启用IPVS模式
featureGates:
CoreDNS: true
#    imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers  # image的仓库源
EOF
    
    systemctl enable kubelet

    在执行以下命令的时候一定要保证8443 6443端口开启，Kubelet actived
    kubeadm init --config /root/kubeadm-init.yaml

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

cat << EOF > /etc/profile.d/kubernetes.sh 
source <(kubectl completion bash)
EOF
    source /etc/profile.d/kubernetes.sh 

    scp -r /etc/kubernetes/pki 172.16.4.62:/etc/kubernetes/
    scp -r /etc/kubernetes/pki 172.16.4.63:/etc/kubernetes/

13、master2上执行，注意advertiseAddress不同
    cd /etc/kubernetes/pki/
    rm -fr apiserver.crt apiserver.key
    cd $HOME
cat << EOF > /root/kubeadm-init.yaml
apiVersion: kubeadm.k8s.io/v1alpha2
kind: MasterConfiguration
kubernetesVersion: v1.11.3      # kubernetes的版本
api:
advertiseAddress: 172.16.4.62  
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
    - "http://172.16.4.61:2379"
    - "http://172.16.4.62:2379"
    - "http://172.16.4.63:2379"
#        caFile: /etc/kubernetes/pki/etcd/etcd-ca.pem
#        certFile: /etc/kubernetes/pki/etcd/etcd.pem
#        keyFile: /etc/kubernetes/pki/etcd/etcd-key.pem
networking:
podSubnet: 10.244.0.0/16      # pod网络的网段
kubeProxy:
config:
    mode: ipvs   #启用IPVS模式
featureGates:
CoreDNS: true
#    imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers  # image的仓库源
EOF
    
    systemctl enable kubelet

    在执行以下命令的时候一定要保证8443 6443端口开启，Kubelet actived
    kubeadm init --config /root/kubeadm-init.yaml

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

cat << EOF > /etc/profile.d/kubernetes.sh 
source <(kubectl completion bash)
EOF
    source /etc/profile.d/kubernetes.sh 

14、master3上执行
    cd /etc/kubernetes/pki/
    rm -fr apiserver.crt apiserver.key
    cd $HOME
cat << EOF > /root/kubeadm-init.yaml
apiVersion: kubeadm.k8s.io/v1alpha2
kind: MasterConfiguration
kubernetesVersion: v1.11.3      # kubernetes的版本
api:
advertiseAddress: 172.16.4.63  
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
    - "http://172.16.4.61:2379"
    - "http://172.16.4.62:2379"
    - "http://172.16.4.63:2379"
#        caFile: /etc/kubernetes/pki/etcd/etcd-ca.pem
#        certFile: /etc/kubernetes/pki/etcd/etcd.pem
#        keyFile: /etc/kubernetes/pki/etcd/etcd-key.pem
networking:
podSubnet: 10.244.0.0/16      # pod网络的网段
kubeProxy:
config:
    mode: ipvs   #启用IPVS模式
featureGates:
CoreDNS: true
#    imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers  # image的仓库源
EOF
    
    systemctl enable kubelet

    在执行以下命令的时候一定要保证8443 6443端口开启，Kubelet actived
    kubeadm init --config /root/kubeadm-init.yaml

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

cat << EOF > /etc/profile.d/kubernetes.sh 
source <(kubectl completion bash)
EOF
    source /etc/profile.d/kubernetes.sh 

15、将所有node节点加入集群
    获取加入集群的token
    #在master主机执行获取join命令
    kubeadm token create --print-join-command

    [root@master ~]# kubeadm token create --print-join-command
    kubeadm join 192.168.1.100:6443 --token zpru0r.jkvrdyy2caexr8kk --discovery-token-ca-cert-hash sha256:a45c091dbd8a801152aacd877bcaaaaf152697bfa4536272c905a83612b3bf22
    每个compute上执行这个命令
16、安装flannal网络
    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
17、查看Node状态
    root@master1:~# kubectl get pods --all-namespaces 
    NAMESPACE     NAME                              READY     STATUS    RESTARTS   AGE
    kube-system   coredns-78fcdf6894-7m8bv          1/1       Running   0          2h
    kube-system   coredns-78fcdf6894-dzdz2          1/1       Running   0          2h
    kube-system   kube-apiserver-master1            1/1       Running   0          2h
    kube-system   kube-apiserver-master2            1/1       Running   0          2h
    kube-system   kube-apiserver-master3            1/1       Running   0          2h
    kube-system   kube-controller-manager-master1   1/1       Running   0          2h
    kube-system   kube-controller-manager-master2   1/1       Running   0          2h
    kube-system   kube-controller-manager-master3   1/1       Running   0          2h
    kube-system   kube-flannel-ds-arm64-5sbf8       1/1       Running   0          1h
    kube-system   kube-flannel-ds-arm64-6z7cw       1/1       Running   0          1h
    kube-system   kube-flannel-ds-arm64-dvm5w       1/1       Running   0          1h
    kube-system   kube-flannel-ds-arm64-p8jd6       1/1       Running   0          1h
    kube-system   kube-flannel-ds-arm64-vgv2t       1/1       Running   0          1h
    kube-system   kube-proxy-28cjb                  1/1       Running   0          2h
    kube-system   kube-proxy-58k4h                  1/1       Running   0          2h
    kube-system   kube-proxy-btsf4                  1/1       Running   0          2h
    kube-system   kube-proxy-fqjcp                  1/1       Running   0          1h
    kube-system   kube-proxy-xgqbw                  1/1       Running   0          1h
    kube-system   kube-scheduler-master1            1/1       Running   1          2h
    kube-system   kube-scheduler-master2            1/1       Running   0          2h
    kube-system   kube-scheduler-master3            1/1       Running   0          2h
    root@master1:~# 
18、创建一个nginx，测试应用和dns是否正常
    cd /root && mkdir nginx && cd nginx
cat << EOF > nginx.yaml
---
apiVersion: v1
kind: Service
metadata:
name: nginx
spec:
selector:
    app: nginx
type: NodePort
ports:
- port: 80
    nodePort: 31000
    name: nginx-port
    targetPort: 80
    protocol: TCP

---
apiVersion: apps/v1
kind: Deployment
metadata:
name: nginx
spec:
replicas: 2
selector:
    matchLabels:
    app: nginx
template:
    metadata:
    name: nginx
    labels:
        app: nginx
    spec:
    containers:
    - name: nginx
        image: nginx
        ports:
        - containerPort: 80
EOF
    kubectl apply -f nginx.yaml
19、创建一个POD来测试DNS解析
cat > centos.yaml <<EOF
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: centos-deploy
spec:
  replicas: 1
  selector:
    matchLabels:
      app: centos
  template:
    metadata:
      name: centos-template
      labels:
        app: centos
    spec:
      containers:
      - name: centos-container
        image: arm64v8/centos
        ports:
        - containerPort: 80
        command: ["/bin/sh","-c","sleep 3600"]
EOF
    root@master1:~# kubectl apply -f centos/centos.yaml
    root@master1:~/centos# kubectl exec -it centos-deploy-69755846fd-rmmlp bash
    [root@centos-deploy-69755846fd-rmmlp /]# yum install bind-utils -y
    root@master1:~# kubectl get svc --all-namespaces 
    NAMESPACE     NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)         AGE
    default       kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP         1d
    default       nginx        NodePort    10.108.46.161   <none>        80:31000/TCP    5h
    kube-system   kube-dns     ClusterIP   10.96.0.10      <none>        53/UDP,53/TCP   23h
    root@master1:~#
    root@master1:~/centos# kubectl exec -it centos-deploy-69755846fd-rmmlp bash
    [root@centos-deploy-69755846fd-rmmlp /]# dig @10.96.0.10 nginx.default.cluster.local. A

    '<<>> DiG 9.9.4-RedHat-9.9.4-61.el7_5.1 <<>> @10.96.0.10 nginx.default.cluster.local. A
    ; (1 server found)
    ;; global options: +cmd
    ;; Got answer:
    ;; ->>HEADER<<- opcode: QUERY, status: NXDOMAIN, id: 2361
    ;; flags: qr rd ra; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 1

    ;; OPT PSEUDOSECTION:
    ; EDNS: version: 0, flags:; udp: 4096
    ;; QUESTION SECTION:
    ;nginx.default.cluster.local.	IN	A

    ;; AUTHORITY SECTION:
    cluster.local.		23	IN	SOA	ns.dns.cluster.local. hostmaster.cluster.local. 1542784249 7200 1800 86400 30

    ;; Query time: 1 msec
    ;; SERVER: 10.96.0.10#53(10.96.0.10)
    ;; WHEN: Wed Nov 21 07:11:39 UTC 2018
    ;; MSG SIZE  rcvd: 149

    [root@centos-deploy-69755846fd-rmmlp /]#
    root@master2:~# kubectl exec -it centos-deploy-69755846fd-9nxl4 bash
    [root@centos-deploy-69755846fd-9nxl4 /]# curl nginx.default.svc.cluster.local.
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
        body {
            width: 35em;
            margin: 0 auto;
            font-family: Tahoma, Verdana, Arial, sans-serif;
        }
    </style>
    </head>
    <body>
    <h1>Welcome to nginx!</h1>
    <p>If you see this page, the nginx web server is successfully installed and
    working. Further configuration is required.</p>

    <p>For online documentation and support please refer to
    <a href="http://nginx.org/">nginx.org</a>.<br/>
    Commercial support is available at
    <a href="http://nginx.com/">nginx.com</a>.</p>

    <p><em>Thank you for using nginx.</em></p>
    </body>
    </html>'
    [root@centos-deploy-69755846fd-9nxl4 /]#
20、关闭vip所在的节点，发现vip飘到了master2

































