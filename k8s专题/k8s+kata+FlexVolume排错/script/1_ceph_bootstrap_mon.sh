#!/bin/bash
#
# 参数： eth1Ip clusterNetworkIp
#
#

set -o errexit
set -o nounset
set -o pipefail
set -x


publicNetworkIp="$1"
publicNetworkPrefix="$2"

clusterNetworkIp="$3"
clusterNetworkPrefix="$4"


theHostname=$(hostname)
theFsid=$(uuidgen)
publicNetwork="${publicNetworkIp}/${publicNetworkPrefix}"
clusterNetwork="${clusterNetworkIp}/${clusterNetworkPrefix}"

# "osd pool default size": 用于设置一存储池的对象副本数,默认值为3,等同于 ceph osd pool set {pool-name} size {size} 
cat > /etc/ceph/ceph.conf << EOF
[global]

fsid = ${theFsid}
mon initial members = ${theHostname}
mon_host = ${clusterNetworkIp}

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
monmaptool --create --add ${theHostname} ${clusterNetworkIp} --fsid ${theFsid} /tmp/monmap
mkdir /var/lib/ceph/mon/ceph-${theHostname}
ceph-mon --mkfs -i ${theHostname} --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
sudo touch /var/lib/ceph/mon/ceph-${theHostname}/done
chown ceph:ceph /var/lib/ceph/mon/ -R
systemctl start ceph-mon@${theHostname}
systemctl enable ceph-mon@${theHostname}
systemctl enable ceph.target

