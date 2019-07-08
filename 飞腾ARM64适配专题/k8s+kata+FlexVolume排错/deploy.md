长城飞腾(ARM)服务器k8s解决方案测试环境部署文档
------------------------------------------

<!-- TOC -->

- [测试环境](#测试环境)
    - [硬件](#硬件)
        - [CPU](#cpu)
        - [内存](#内存)
        - [硬盘设备](#硬盘设备)
        - [网卡设备](#网卡设备)
    - [软件](#软件)
- [部署方案](#部署方案)
- [部署ceph](#部署ceph)
    - [安装ceph](#安装ceph)
    - [部署第一个mon节点](#部署第一个mon节点)
    - [复制ceph配置文件](#复制ceph配置文件)
    - [添加osd节点](#添加osd节点)
    - [重建默认pool](#重建默认pool)
    - [启动systemd-udevd服务](#启动systemd-udevd服务)
    - [测试ceph rbd](#测试ceph-rbd)
- [从源码编译并部署frakti和hyperd](#从源码编译并部署frakti和hyperd)
    - [编译 frakti & cephrbd](#编译-frakti--cephrbd)
    - [编译hyperd](#编译hyperd)
    - [部署计算节点](#部署计算节点)
- [FAQ](#faq)
    - [ceph集群的osd都掉线](#ceph集群的osd都掉线)
    - [无法map ceph块设备](#无法map-ceph块设备)
    - [无法访问k8s](#无法访问k8s)

<!-- /TOC -->

# 测试环境

## 硬件

飞腾ARM服务器

三节点：node1, node2, node3

### CPU

```
$ cat /proc/cpuinfo  | grep processor | wc -l
16

$ cat /proc/cpuinfo | head -n9
processor	: 0
model name	: phytium FT1500a
bogomips	: 3594.24
flags		: fp asimd evtstrm aes pmull sha1 sha2 crc32
CPU implementer	: 0x70
CPU architecture: 8
CPU variant	: 0x1
CPU part	: 0x660
CPU revision	: 1
```

### 内存
```
$ cat /proc/meminfo  | grep MemTotal
MemTotal:       65952304 kB
```

### 硬盘设备

> sdb已用于有容云，ceph的osd节点将共用sdb设备
```
root@node1:~# lsblk | grep sdb
sdb      8:16   0   1.7T  0 disk /vespace/chain/data-9908b8a2-08c0-44b5-8da1-876f8a8c7d36

root@node2:~# lsblk | grep sdb
sdb      8:16   0   1.7T  0 disk /vespace/chain/data-7bf5121e-79a9-47e7-a8af-03e7bd00ac40

root@node3:~# lsblk | grep sdb
sdb      8:16   0   1.7T  0 disk /vespace/chain/data-a6272c33-d1cd-489c-a38b-f525d8052ae9
```

### 网卡设备
```
node1: eth0 172.16.4.101
node2: eth0 172.16.4.102
node3: eth0 172.16.4.103
```


## 软件

- OS: Kylin 4.0.2
- Kubernetes v1.11
- Frakti v1.11.0 + [cephrbd驱动](https://github.com/kubernetes/frakti/pull/340)
- Hyperd v1.0.0
- Ceph 10.2.10 (Jewel)
- Qemu 2.8

```
//OS
$ lsb_release -a
No LSB modules are available.
Distributor ID:	Kylin
Description:	Kylin 4.0.2
Release:	4.0.2
Codename:	juniper
```


# 部署方案

1个mon节点，3个osd节点，3副本

- node1: k8s master节点，将作为ceph的mon和osd节点
- node2: k8s master节点，将作为ceph的osd节点
- node3: k8s 计算节点，将作为ceph的osd节点

> osd: object storage daemon(对象存储守护进程), 提供块设备, 可以提供给pod作为flexVolume，直接挂载到hyperd虚拟机上

# 部署ceph 

## 安装ceph

```
// 需要翻墙安装ceph
$ export http_proxy=http://x.x.x.x:8118
$ export https_proxy=http://x.x.x.x:8118

// 导入key
$ wget -q -O- 'https://download.ceph.com/keys/release.asc' | sudo apt-key add -

// 添加安装源
$ sudo apt-add-repository 'deb https://download.ceph.com/debian-jewel/ xenial main'
或者
$ echo 'deb http://archive.canonical.com/ubuntu xenial partner' >> /etc/apt/sources.list

// 安装ceph
$ apt update && apt install ceph

// 检查安装后版本，确认是10.2.10
$ dpkg -l | egrep -i 'ceph|rbd|rados'
```

## 部署第一个mon节点

> 在node1上执行

```
//生产网推荐使用双网卡:
- 千兆网卡提供Ceph的Public Network通信
- 万兆网卡提供Ceph的Cluster Network通信

//本测试环境为单网卡(用法:1_ceph_bootstrap_mon.sh <publicNetworkIp> <publicNetworkPrefix> <clusterNetworkIp> <clusterNetworkPrefix>)
$ bash 1_ceph_bootstrap_mon.sh 172.16.4.101 24 172.16.4.101 24
```

## 复制ceph配置文件

将node1上生成的ceph配置文件，复制到其他ceph节点

```
//在node2和node3上分别创建/etc/ceph目录
$ mkdir -p /etc/ceph

//从node1上复制ceph配置文件到node2和node3
$ scp /etc/ceph/{ceph.conf,ceph.client.admin.keyring} root@172.16.4.102:/etc/ceph
$ scp /etc/ceph/{ceph.conf,ceph.client.admin.keyring} root@172.16.4.103:/etc/ceph
```

## 添加osd节点

在需要做osd的节点上做如下操作：

```
//node1, node2和node3的/dev/sdb设备已挂载，且用于vespace。没有其他空闲磁盘，但可以复用/dev/sdb。
因此可以跳过脚本2_ceph_prepare_osd_disks.sh

//node1, node2, node3上分别执行，将创建osd相关的目录（格式：bash 3_ceph_add_osd.sh <osd数据目录>）
$ bash 3_ceph_add_osd.sh /vespace/chain/data-9908b8a2-08c0-44b5-8da1-876f8a8c7d36
$ bash 3_ceph_add_osd.sh /vespace/chain/data-7bf5121e-79a9-47e7-a8af-03e7bd00ac40
$ bash 3_ceph_add_osd.sh /vespace/chain/data-a6272c33-d1cd-489c-a38b-f525d8052ae9
```

## 重建默认pool 

默认pool为rbd，删除后新建pool，name为hyper(cephrbd驱动的默认pool为hyper)

```
//删除默认的rbd pool
$ ceph osd pool rm rbd rbd --yes-i-really-really-mean-it

//新建hyper pool
$ ceph osd pool create hyper 64 64
//检查hyper pool
$ ceph osd pool get hyper size && ceph osd pool get hyper min_size
```

## 启动systemd-udevd服务

```
//所有osd节点需要运行systemd-udevd服务，否则ceph rbd设备无法map和unmap
$ systemctl start systemd-udevd

//确保systemd-udevd服务已启动
$ systemctl status systemd-udevd | grep Active -B1
   Loaded: loaded (/lib/systemd/system/systemd-udevd.service; static; vendor preset: enabled)
   Active: active (running) since 二 2018-08-07 10:42:28 CST; 6min ago
```

## 测试ceph rbd

```
//检查ceph集群状态
$ ceph status
$ ceph osd tree

$ rbd create -p hyper --size 1G test
$ rbd ls -p hyper
$ rbd map hyper/test
$ rbd showmapped
$ rbd unmap hyper/test
```
> 以上操作均正常，表示ceph集群可用


# 从源码编译并部署frakti和hyperd

调用关系: kubelet -> frakti -> hyperd

为了支持ceph rbd设备，需要增加flexVolume驱动，以便解析pod中的flexVolume相关参数，
因此需要重新编译frakti源码（含ceph rbd的flexVolume驱动）。

hyperd链接了库libvirt/librbd，因此安装ceph之后，也需要重新编译，以支持挂载ceph rbd块设备到虚拟机.


## 编译 frakti & cephrbd

frakti依赖kubernetes，且frakti的版本号与kubernete一致。

如，kubernetes使用1.11，那么frakti也需要1.11版本

> 下面步骤将在node3上clone frakti代码并编译
```
$ mkdir -p $GOPATH/src/k8s.io
$ git clone https://github.com/kubernetes/frakti.git $GOPATH/src/k8s.io/frakti
$ cd $GOPATH/src/k8s.io/frakti

$ make
go build -a --tags "" -o ./out/frakti ./cmd/frakti
go build -a --tags "" -o ./out/rbd ./cmd/flexvolume-cinder-rbd/cinder_rbd.go
go build -a --tags "" -o ./out/pd ./cmd/flexvolume-gce-pd/gce_pd.go
go build -a --tags "" -o ./out/cephrbd ./cmd/flexvolume-hyper-cephrbd/cephrbd.go

编译结果:
- out/frakti
- out/cephrbd ceph  #ceph rbd的flexVolume驱动
```

> 注: https://github.com/kubernetes/frakti/pull/340 此PR已给flexVolume driver加入ceph rbd支持，且目前已merge到master分支


## 编译hyperd

```
//安装依赖
$ apt install automake

//libdevmapper-dev在官方源没有，可以从源码编译，或者第三方源下载deb包。此处使用了从 https://launchpad.net/ubuntu/xenial/arm64/libdevmapper-dev/2:1.02.110-1ubuntu10 下载的deb包及其依赖
$ dpkg -i libdevmapper-dev/*.deb

//编译hyperd
$ mkdir -p ${GOPATH}/src/github.com/hyperhq
$ cd ${GOPATH}/src/github.com/hyperhq
$ git clone https://github.com/hyperhq/hyperd.git hyperd
$ ./autogen.sh
$ ./configure
$ make

编译结果：
- cmd/hyperd/hyperd      #服务
- cmd/hyperctl/hyperctl  #命令行
```

## 部署计算节点

将frakit, cephrbd和hyperd部署到所有计算节点,本测试环境是node3

```
//停止服务
$ systemctl stop kubelet frakti hyperd

//部署frakti和cephrbd
$ cd $GOPATH/src/k8s.io/frakti
$ cp -f ./out/frakti /usr/bin
$ mkdir -p /usr/libexec/kubernetes/kubelet-plugins/volume/exec/hyper~cephrbd
$ cp out/cephrbd /usr/libexec/kubernetes/kubelet-plugins/volume/exec/hyper~cephrbd/cephrbd

注：kubelet将自动定位flexVolume的驱动位置，因此只需要将cephrbd放到
/usr/libexec/kubernetes/kubelet-plugins/volume/exec/hyper~cephrbd目录下即可


//部署hyperd
$ cd ${GOPATH}/src/github.com/hyperhq/hyperd
$ cp cmd/hyperd/hyperd -rf /usr/bin/hyperd


//启动服务
$ service hyperd start
$ service frakti start
$ service kubelet start

//确保kubelet,frakti,hyperd服务已启动
$ status kubelet frakti hyperd | grep Active -B1
           └─05-frakti.conf, 10-kubeadm.conf
   Active: active (running) since 二 2018-08-07 10:20:29 CST; 27min ago
--
   Loaded: loaded (/lib/systemd/system/frakti.service; enabled; vendor preset: enabled)
   Active: active (running) since 二 2018-08-07 10:20:25 CST; 27min ago
--
   Loaded: loaded (/lib/systemd/system/hyperd.service; enabled; vendor preset: enabled)
   Active: active (running) since 二 2018-08-07 10:20:22 CST; 27min ago
```

# FAQ

## ceph集群的osd都掉线


```
【现象】
root@node3:~# ceph -s
    cluster 4a4c83b0-5722-4cd8-815a-f7785deafaa2
     health HEALTH_ERR <<<<<<
            64 pgs are stuck inactive for more than 300 seconds
            64 pgs stale
            64 pgs stuck stale
            3/3 in osds are down
     monmap e1: 1 mons at {node1=172.16.4.101:6789/0}
            election epoch 4, quorum 0 node1
     osdmap e29: 3 osds: 0 up, 3 in
            flags sortbitwise,require_jewel_osds
      pgmap v472: 64 pgs, 1 pools, 75148 kB data, 41 objects
            60839 MB used, 4965 GB / 5024 GB avail

【原因】
ceph的osd数据目录共用了vespace的目录， vespace停掉之后，sdb被unmount

【解决】
重启ceph-osd服务，在每个node上执行下:
$ systemctl restart ceph.target

再次检查ceph集群状态，恢复
$ ceph -s
    cluster 4a4c83b0-5722-4cd8-815a-f7785deafaa2
     health HEALTH_OK   <<<<<<
     monmap e1: 1 mons at {node1=172.16.4.101:6789/0}
            election epoch 5, quorum 0 node1
     osdmap e31: 3 osds: 3 up, 3 in
            flags sortbitwise,require_jewel_osds
      pgmap v478: 64 pgs, 1 pools, 75148 kB data, 41 objects
            60838 MB used, 4965 GB / 5024 GB avail
                  64 active+clean                  
```

## 无法map ceph块设备

```
【现象】
$ rbd create -p hyper --size 1G test
$ rbd map hyper/test
<此处挂起>

【原因】
systemd-udevd服务未启动

【解决】
$ systemctl start systemd-udevd

//再次检查，可以正常map设备
$ rbd map hyper/test
/dev/rbd0

$ rbd showmapped
id pool  image snap device
0  hyper test  -    /dev/rbd0

//可以正常unmap
$ rbd unmap hyper/test
$ rbd showmapped
```

## 无法访问k8s

```
【现象】
$ kubectl get nodes
<此处挂起>
【原因】node1的eth0未指定浮动ip

【解决】node1上执行
$ ip add add 172.16.4.250/24 dev eth0

//再次测试
$ kubectl get nodes
NAME      STATUS    ROLES     AGE       VERSION
node1     Ready     master    6d        v1.11.1
node2     Ready     master    6d        v1.11.1
node3     Ready     <none>    6d        v1.11.1
```

至此, ceph集群， frakti，hyperd和flexVolume的ceph rbd驱动已部署完成，后面就可以在k8s pod中，通过flexVolume来使用ceph rbd块设备，使其作为volume挂载到容器中。详见[使用示例](usage.md)