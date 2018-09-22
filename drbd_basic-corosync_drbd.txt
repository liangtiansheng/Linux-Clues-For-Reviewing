#################################### DRBD BASIC ########################################

前提：
1）本配置共有两个测试节点，分别node1.magedu.com和node2.magedu.com，相的IP地址分别为172.16.100.11和172.16.100.12；
2）node1和node2两个节点上各提供了一个大小相同的分区作为drbd设备；我们这里为在两个节点上均为/dev/sda5，大小为512M；
3）系统为rhel5.8，x86平台；

1、准备工作

两个节点的主机名称和对应的IP地址解析服务可以正常工作，且每个节点的主机名称需要跟"uname -n“命令的结果保持一致；因此，需要保证两个节点上的/etc/hosts文件均为下面的内容：
172.16.100.11 node1.magedu.com node1
172.16.100.12 node2.magedu.com node2

为了使得重新启动系统后仍能保持如上的主机名称，还分别需要在各节点执行类似如下的命令：

Node1:
# sed -i 's@\(HOSTNAME=\).*@\1node1.magedu.com@g'
# hostname node1.magedu.com

Node2：
# sed -i 's@\(HOSTNAME=\).*@\1node2.magedu.com@g'
# hostname node2.magedu.com

2、安装软件包

drbd共有两部分组成：内核模块和用户空间的管理工具。其中drbd内核模块代码已经整合进Linux内核2.6.33以后的版本中，因此，如果您的内核版本高于此版本的话，你只需要安装管理工具即可；否则，您需要同时安装内核模块和管理工具两个软件包，并且此两者的版本号一定要保持对应。

目前在用的drbd版本主要有8.0、8.2和8.3三个版本，其对应的rpm包的名字分别为drbd, drbd82和drbd83，对应的内核模块的名字分别为kmod-drbd, kmod-drbd82和kmod-drbd83。各版本的功能和配置等略有差异；我们实验所用的平台为x86且系统为rhel5.8，因此需要同时安装内核模块和管理工具。我们这里选用最新的8.3的版本(drbd83-8.3.8-1.el5.centos.i386.rpm和kmod-drbd83-8.3.8-1.el5.centos.i686.rpm)，下载地址为：http://mirrors.sohu.com/centos/5.8/extras/i386/RPMS/。

实际使用中，您需要根据自己的系统平台等下载符合您需要的软件包版本，这里不提供各版本的下载地址。

下载完成后直接安装即可：
# yum -y --nogpgcheck localinstall drbd83-8.3.8-1.el5.centos.i386.rpm kmod-drbd83-8.3.8-1.el5.centos.i686.rpm

3、配置drbd

drbd的主配置文件为/etc/drbd.conf；为了管理的便捷性，目前通常会将些配置文件分成多个部分，且都保存至/etc/drbd.d目录中，主配置文件中仅使用"include"指令将这些配置文件片断整合起来。通常，/etc/drbd.d目录中的配置文件为global_common.conf和所有以.res结尾的文件。其中global_common.conf中主要定义global段和common段，而每一个.res的文件用于定义一个资源。

在配置文件中，global段仅能出现一次，且如果所有的配置信息都保存至同一个配置文件中而不分开为多个文件的话，global段必须位于配置文件的最开始处。目前global段中可以定义的参数仅有minor-count, dialog-refresh, disable-ip-verification和usage-count。

common段则用于定义被每一个资源默认继承的参数，可以在资源定义中使用的参数都可以在common段中定义。实际应用中，common段并非必须，但建议将多个资源共享的参数定义为common段中的参数以降低配置文件的复杂度。

resource段则用于定义drbd资源，每个资源通常定义在一个单独的位于/etc/drbd.d目录中的以.res结尾的文件中。资源在定义时必须为其命名，名字可以由非空白的ASCII字符组成。每一个资源段的定义中至少要包含两个host子段，以定义此资源关联至的节点，其它参数均可以从common段或drbd的默认中进行继承而无须定义。

下面的操作在node1.magedu.com上完成。

1）复制样例配置文件为即将使用的配置文件：
# cp /usr/share/doc/drbd83-8.3.8/drbd.conf  /etc

2）配置/etc/drbd.d/global-common.conf
global {
        usage-count no;
        # minor-count dialog-refresh disable-ip-verification
}

common {
        protocol C;

        handlers {
                pri-on-incon-degr "/usr/lib/drbd/notify-pri-on-incon-degr.sh; /usr/lib/drbd/notify-emergency-reboot.sh; echo b > /proc/sysrq-trigger ; reboot -f";
                pri-lost-after-sb "/usr/lib/drbd/notify-pri-lost-after-sb.sh; /usr/lib/drbd/notify-emergency-reboot.sh; echo b > /proc/sysrq-trigger ; reboot -f";
                local-io-error "/usr/lib/drbd/notify-io-error.sh; /usr/lib/drbd/notify-emergency-shutdown.sh; echo o > /proc/sysrq-trigger ; halt -f";
                # fence-peer "/usr/lib/drbd/crm-fence-peer.sh";
                # split-brain "/usr/lib/drbd/notify-split-brain.sh root";
                # out-of-sync "/usr/lib/drbd/notify-out-of-sync.sh root";
                # before-resync-target "/usr/lib/drbd/snapshot-resync-target-lvm.sh -p 15 -- -c 16k";
                # after-resync-target /usr/lib/drbd/unsnapshot-resync-target-lvm.sh;
        }

        startup {
                #wfc-timeout 120;
                #degr-wfc-timeout 120;
        }

        disk {
                on-io-error detach;
                #fencing resource-only;
        }

        net {
                cram-hmac-alg "sha1";
                shared-secret "mydrbdlab";
        }

        syncer {
                rate 1000M;
        }
}

3、定义一个资源/etc/drbd.d/web.res，内容如下：
resource web {
  on node1.magedu.com {
    device    /dev/drbd0;
    disk      /dev/sda5;
    address   172.16.100.11:7789;
    meta-disk internal;
  }
  on node2.magedu.com {
    device    /dev/drbd0;
    disk      /dev/sda5;
    address   172.16.100.12:7789;
    meta-disk internal;
  }
}

以上文件在两个节点上必须相同，因此，可以基于ssh将刚才配置的文件全部同步至另外一个节点。
# scp  /etc/drbd.*  node2:/etc

4、在两个节点上初始化已定义的资源并启动服务：

1）初始化资源，在Node1和Node2上分别执行：
# drbdadm create-md web

2）启动服务，在Node1和Node2上分别执行：
/etc/init.d/drbd start

3）查看启动状态：
# cat /proc/drbd
version: 8.3.8 (api:88/proto:86-94)
GIT-hash: d78846e52224fd00562f7c225bcc25b2d422321d build by mockbuild@builder10.centos.org, 2010-06-04 08:04:16
 0: cs:Connected ro:Secondary/Secondary ds:Inconsistent/Inconsistent C r----
    ns:0 nr:0 dw:0 dr:0 al:0 bm:0 lo:0 pe:0 ua:0 ap:0 ep:1 wo:b oos:505964

也可以使用drbd-overview命令来查看：
# drbd-overview 
  0:web  Connected Secondary/Secondary Inconsistent/Inconsistent C r---- 

从上面的信息中可以看出此时两个节点均处于Secondary状态。于是，我们接下来需要将其中一个节点设置为Primary。在要设置为Primary的节点上执行如下命令：
# drbdsetup /dev/drbd0 primary –o

  注： 也可以在要设置为Primary的节点上使用如下命令来设置主节点：
     # drbdadm -- --overwrite-data-of-peer primary web

而后再次查看状态，可以发现数据同步过程已经开始：
# drbd-overview 
  0:web  SyncSource Primary/Secondary UpToDate/Inconsistent C r---- 
    [============>.......] sync'ed: 66.2% (172140/505964)K delay_probe: 35
    
等数据同步完成以后再次查看状态，可以发现节点已经牌实时状态，且节点已经有了主次：
# drbd-overview 
  0:web  Connected Primary/Secondary UpToDate/UpToDate C r---- 

5、创建文件系统

文件系统的挂载只能在Primary节点进行，因此，也只有在设置了主节点后才能对drbd设备进行格式化：
# mke2fs -j -L DRBD /dev/drbd0
# mkdir /mnt/drbd 
# mount /dev/drbd0 /mnt/drbd

6、切换Primary和Secondary节点

对主Primary/Secondary模型的drbd服务来讲，在某个时刻只能有一个节点为Primary，因此，要切换两个节点的角色，只能在先将原有的Primary节点设置为Secondary后，才能原来的Secondary节点设置为Primary:

Node1:
# cp -r /etc/drbd.* /mnt/drbd  
# umount /mnt/drbd
# drbdadm secondary web

查看状态：
# drbd-overview 
  0:web  Connected Secondary/Secondary UpToDate/UpToDate C r---- 

Node2:
# drbdadm primary web
# drbd-overview 
  0:web  Connected Primary/Secondary UpToDate/UpToDate C r---- 
# mkdir /mnt/drbd
# mount /dev/drbd0 /mnt/drbd

使用下面的命令查看在此前在主节点上复制至此设备的文件是否存在：
# ls /mnt/drbd




drbd 8.4中第一次设置某节点成为主节点的命令
# drbdadm primary --force resource

配置资源双主模型的示例：
resource mydrbd {

        net {
                protocol C;
                allow-two-primaries yes;
        }

        startup {
                become-primary-on both;
        }

        disk {
                fencing resource-and-stonith;
        }

        handlers {
                # Make sure the other node is confirmed
                # dead after this!
                outdate-peer "/sbin/kill-other-node.sh";
        }

        on node1.magedu.com {
                device  /dev/drbd0;
                disk    /dev/vg0/mydrbd;
                address 172.16.200.11:7789;
                meta-disk       internal;
        }

        on node2.magedu.com {
                device  /dev/drbd0;
                disk    /dev/vg0/mydrbd;
                address 172.16.200.12:7789;
                meta-disk       internal;
        }
}


############################# DRBD & COROSYNC ##################################
前提：
1）本配置共有两个测试节点，分别node1.a.org和node2.a.org，相的IP地址分别为192.168.0.5和192.168.0.6；
2）node1和node2两个节点已经配置好了基于openais/corosync的集群；且node1和node2也已经配置好了Primary/Secondary模型的drbd设备/dev/drbd0，且对应的资源名称为web；如果您此处的配置有所不同，请确保后面的命令中使用到时与您的配置修改此些信息与您所需要的配置保持一致；
3）系统为rhel5.4，x86平台；

1、查看当前集群的配置信息，确保已经配置全局属性参数为两节点集群所适用：

# crm configure show
node node1.a.org
node node2.a.org
property $id="cib-bootstrap-options" \
 dc-version="1.0.11-1554a83db0d3c3e546cfd3aaff6af1184f79ee87" \
 cluster-infrastructure="openais" \
 expected-quorum-votes="2" \
 stonith-enabled="false" \
 last-lrm-refresh="1308059765" \
 no-quorum-policy="ignore"

在如上输出的信息中，请确保有stonith-enabled和no-quorum-policy出现且其值与如上输出信息中相同。否则，可以分别使用如下命令进行配置：
# crm configure property stonith-enabled=false
# crm configure property no-quorum-policy=ignore

2、将已经配置好的drbd设备/dev/drbd0定义为集群服务；

1）按照集群服务的要求，首先确保两个节点上的drbd服务已经停止，且不会随系统启动而自动启动：

# drbd-overview
 0:web Unconfigured . . . . 

# chkconfig drbd off 

2）配置drbd为集群资源：

提供drbd的RA目前由OCF归类为linbit，其路径为/usr/lib/ocf/resource.d/linbit/drbd。我们可以使用如下命令来查看此RA及RA的meta信息：

# crm ra classes
heartbeat
lsb
ocf / heartbeat linbit pacemaker
stonith

# crm ra list ocf linbit
drbd 

# crm ra info ocf:linbit:drbd
This resource agent manages a DRBD resource
as a master/slave resource. DRBD is a shared-nothing replicated storage
device. (ocf:linbit:drbd)

Master/Slave OCF Resource Agent for DRBD

Parameters (* denotes required, [] the default):

drbd_resource* (string): drbd resource name
 The name of the drbd resource from the drbd.conf file.

drbdconf (string, [/etc/drbd.conf]): Path to drbd.conf
 Full path to the drbd.conf file.

Operations' defaults (advisory minimum):

 start timeout=240
 promote timeout=90
 demote timeout=90
 notify timeout=90
 stop timeout=100
 monitor_Slave interval=20 timeout=20 start-delay=1m
 monitor_Master interval=10 timeout=20 start-delay=1m


drbd需要同时运行在两个节点上，但只能有一个节点（primary/secondary模型）是Master，而另一个节点为Slave；因此，它是一种比较特殊的集群资源，其资源类型为多态（Multi-state）clone类型，即主机节点有Master和Slave之分，且要求服务刚启动时两个节点都处于slave状态。

[root@node1 ~]# crm
crm(live)# configure
crm(live)configure# primitive webdrbd ocf:linbit:drbd params drbd_resource=web op monitor role=Master interval=50s timeout=30s op monitor role=Slave interval=60s timeout=30s
crm(live)configure# master MS_Webdrbd webdrbd meta master-max="1" master-node-max="1" clone-max="2" clone-node-max="1" notify="true"

crm(live)configure# show webdrbd
primitive webdrbd ocf:linbit:drbd \
 params drbd_resource="web" \
 op monitor interval="15s"
crm(live)configure# show MS_Webdrbd
ms MS_Webdrbd webdrbd \
 meta master-max="1" master-node-max="1" clone-max="2" clone-node-max="1" notify="true"
crm(live)configure# verify
crm(live)configure# commit


查看当前集群运行状态：
# crm status
============
Last updated: Fri Jun 17 06:24:03 2011
Stack: openais
Current DC: node2.a.org - partition with quorum
Version: 1.0.11-1554a83db0d3c3e546cfd3aaff6af1184f79ee87
2 Nodes configured, 2 expected votes
1 Resources configured.
============

Online: [ node2.a.org node1.a.org ]

 Master/Slave Set: MS_Webdrbd
 Masters: [ node2.a.org ]
 Slaves: [ node1.a.org ]

由上面的信息可以看出此时的drbd服务的Primary节点为node2.a.org，Secondary节点为node1.a.org。当然，也可以在node2上使用如下命令验正当前主机是否已经成为web资源的Primary节点：
# drbdadm role web
Primary/Secondary

3）为Primary节点上的web资源创建自动挂载的集群服务

MS_Webdrbd的Master节点即为drbd服务web资源的Primary节点，此节点的设备/dev/drbd0可以挂载使用，且在某集群服务的应用当中也需要能够实现自动挂载。假设我们这里的web资源是为Web服务器集群提供网页文件的共享文件系统，其需要挂载至/www（此目录需要在两个节点都已经建立完成）目录。

此外，此自动挂载的集群资源需要运行于drbd服务的Master节点上，并且只能在drbd服务将某节点设置为Primary以后方可启动。因此，还需要为这两个资源建立排列约束和顺序约束。

# crm
crm(live)# configure
crm(live)configure# primitive WebFS ocf:heartbeat:Filesystem params device="/dev/drbd0" directory="/www" fstype="ext3"
crm(live)configure# colocation WebFS_on_MS_webdrbd inf: WebFS MS_Webdrbd:Master
crm(live)configure# order WebFS_after_MS_Webdrbd inf: MS_Webdrbd:promote WebFS:start
crm(live)configure# verify
crm(live)configure# commit

查看集群中资源的运行状态：
 crm status
============
Last updated: Fri Jun 17 06:26:03 2011
Stack: openais
Current DC: node2.a.org - partition with quorum
Version: 1.0.11-1554a83db0d3c3e546cfd3aaff6af1184f79ee87
2 Nodes configured, 2 expected votes
2 Resources configured.
============

Online: [ node2.a.org node1.a.org ]

 Master/Slave Set: MS_Webdrbd
 Masters: [ node2.a.org ]
 Slaves: [ node1.a.org ]
 WebFS (ocf::heartbeat:Filesystem): Started node2.a.org

由上面的信息可以发现，此时WebFS运行的节点和drbd服务的Primary节点均为node2.a.org；我们在node2上复制一些文件至/www目录（挂载点），而后在故障故障转移后查看node1的/www目录下是否存在这些文件。
# cp /etc/rc./rc.sysinit /www

下面我们模拟node2节点故障，看此些资源可否正确转移至node1。

以下命令在Node2上执行：
# crm node standby
# crm status
============
Last updated: Fri Jun 17 06:27:03 2011
Stack: openais
Current DC: node2.a.org - partition with quorum
Version: 1.0.11-1554a83db0d3c3e546cfd3aaff6af1184f79ee87
2 Nodes configured, 2 expected votes
2 Resources configured.
============

Node node2.a.org: standby
Online: [ node1.a.org ]

 Master/Slave Set: MS_Webdrbd
 Masters: [ node1.a.org ]
 Stopped: [ webdrbd:0 ]
 WebFS (ocf::heartbeat:Filesystem): Started node1.a.org

由上面的信息可以推断出，node2已经转入standby模式，其drbd服务已经停止，但故障转移已经完成，所有资源已经正常转移至node1。

在node1可以看到在node2作为primary节点时产生的保存至/www目录中的数据，在node1上均存在一份拷贝。

让node2重新上线：
# crm node online
[root@node2 ~]# crm status
============
Last updated: Fri Jun 17 06:30:05 2011
Stack: openais
Current DC: node2.a.org - partition with quorum
Version: 1.0.11-1554a83db0d3c3e546cfd3aaff6af1184f79ee87
2 Nodes configured, 2 expected votes
2 Resources configured.
============

Online: [ node2.a.org node1.a.org ]

 Master/Slave Set: MS_Webdrbd
 Masters: [ node1.a.org ]
 Slaves: [ node2.a.org ]
 WebFS (ocf::heartbeat:Filesystem): Started node1.a.org
 
 
 
mysql+drbd+corosync
 
 
node node1.magedu.com
node node2.magedu.com
primitive mysqldrbd ocf:linbit:drbd \
	params drbd_resource="mysqlres" \
	op monitor interval="30s" role="Master" timeout="30s" \
	op monitor interval="40s" role="Slave" timeout="30s" \
	op start interval="0" timeout="240" \
	op stop interval="0" timeout="100"
primitive mysqlfs ocf:heartbeat:Filesystem \
	params device="/dev/drbd0" directory="/data/mydata" fstype="ext3" \
	op start interval="0" timeout="60s" \
	op stop interval="0" timeout="60s"
primitive mysqlserver lsb:mysqld
primitive mysqlvip ocf:heartbeat:IPaddr \
	params ip="172.16.100.1"
ms ms_mysqldrbd mysqldrbd \
	meta master-max="1" master-node-max="1" clone-max="2" clone-node-max="1" notify="true"
colocation mysqlfs_with_ms_mysqldrbd inf: mysqlfs ms_mysqldrbd:Master
colocation mysqlserver_with_mysqlfs inf: mysqlfs mysqlserver
colocation mysqlvip_with_mysqlserver inf: mysqlvip mysqlserver
order mysqlfs_after_ms_mysqldrbd inf: ms_mysqldrbd:promote mysqlfs:start
order mysqlserver_after_mysqlfs inf: mysqlfs mysqlserver
property $id="cib-bootstrap-options" \
	dc-version="1.1.5-1.1.el5-01e86afaaa6d4a8c4836f68df80ababd6ca3902f" \
	cluster-infrastructure="openais" \
	expected-quorum-votes="2" \
	stonith-enabled="false" \
	no-quorum-policy="ignore"


版本2：
crm(live)# configure 
crm(live)configure# SHOW
node node1.magedu.com \
	attributes standby="off"
node node2.magedu.com \
	attributes standby="off"
primitive myip ocf:heartbeat:IPaddr \
	params ip="172.16.100.1" nic="eth0" cidr_netmask="255.255.0.0"
primitive mysqld lsb:mysqld
primitive mysqldrbd ocf:heartbeat:drbd \
	params drbd_resource="mydrbd" \
	op start interval="0" timeout="240" \
	op stop interval="0" timeout="100" \
	op monitor interval="20" role="Master" timeout="30" \
	op monitor interval="30" role="Slave" timeout="30"
primitive mystore ocf:heartbeat:Filesystem \
	params device="/dev/drbd0" directory="/mydata" fstype="ext3" \
	op start interval="0" timeout="60" \
	op stop interval="0" timeout="60"
ms ms_mysqldrbd mysqldrbd \
	meta master-max="1" master-node-max="1" clone-max="2" clone-node-max="1" notify="true"
colocation myip_with_ms_mysqldrbd inf: ms_mysqldrbd:Master myip
colocation mysqld_with_mystore inf: mysqld mystore
colocation mystore_with_ms_mysqldrbd inf: mystore ms_mysqldrbd:Master
order mysqld_after_mystore inf: mystore mysqld
order mystore_after_ms_mysqldrbd inf: ms_mysqldrbd:promote mystore:start
property $id="cib-bootstrap-options" \
	dc-version="1.1.5-1.1.el5-01e86afaaa6d4a8c4836f68df80ababd6ca3902f" \
	cluster-infrastructure="openais" \
	expected-quorum-votes="2" \
	stonith-enabled="false" \
	no-quorum-policy="ignore" \
	last-lrm-refresh="1368438416"
rsc_defaults $id="rsc-options" \
	resource-stickiness="100"

	
	
	
使用双主模型：

一、设定资源启用双主模型
resource <resource> {
  startup {
    become-primary-on both;
    ...
  }
  net {
    allow-two-primaries yes;
    after-sb-0pri discard-zero-changes;
    after-sb-1pri discard-secondary;
    after-sb-2pri disconnect;
    ...
  }
  ...
}

同时，包括双主drbd模型中的任何集群文件系统都需要fencing功能，且要求其不仅要在资源级别实现，也要在节点级别实现STONITH功能。

disk {
        fencing resource-and-stonith;
}
handlers {
        outdate-peer "/sbin/make-sure-the-other-node-is-confirmed-dead.sh"
}



二、使用GFS2文件系统




三、结合RHCS时的资源定义示例
<rm>
  <resources />
  <service autostart="1" name="mysql">
    <drbd name="drbd-mysql" resource="mydrbd">
      <fs device="/dev/drbd0"
          mountpoint="/var/lib/mysql"
          fstype="ext3"
          name="mydrbd"
          options="noatime"/>
    </drbd>
    <ip address="172.16.100.8" monitor_link="1"/>
    <mysql config_file="/etc/my.cnf"
           listen_address="172.16.100.8"
           name="mysqld"/>
  </service>
</rm>






多节点同时启动一个IP
node node1.magedu.com \
	attributes standby="off"
node node2.magedu.com
node node3.magedu.com \
	attributes standby="off"
primitive DLM ocf:pacemaker:controld \
	params daemon="/usr/sbin/dlm_controld" \
	op start interval="0" timeout="90" \
	op stop interval="0" timeout="100"
primitive clusterip ocf:heartbeat:IPaddr2 \
	params ip="172.16.200.7" cidr_netmask="32" clusterip_hash="sourceip"
clone WebIP clusterip \
	meta globally-unique="true" clone-max="3" clone-node-max="3" target-role="Stopped"
clone dlm_clone DLM \
	meta clone-max="3" clone-node-max="1" target-role="Started"
property $id="cib-bootstrap-options" \
	dc-version="1.1.7-6.el6-148fccfd5985c5590cc601123c6c16e966b85d14" \
	cluster-infrastructure="openais" \
	expected-quorum-votes="3" \
	stonith-enabled="false" \
	last-lrm-refresh="1354024090"

