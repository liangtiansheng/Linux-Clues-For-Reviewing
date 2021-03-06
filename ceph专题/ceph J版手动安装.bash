########################## 实验的版本为ceph version 10.2.11 ##########################
一、配置阿里源
    1、配置阿里的base源和epel源
        [root@mon1 ~]# wget -qO /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
        [root@mon1 ~]# wget -qO /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
    2、配置阿里的ceph源
        [root@mon1 ~]# cat /etc/yum.repos.d/Aliyun-ceph.repo
        [ceph]
        name=ceph
        baseurl=https://mirrors.aliyun.com/ceph/rpm-jewel/el7/x86_64/
        gpgcheck=0
        [ceph-noarch]
        name=cephnoarch
        baseurl=https://mirrors.aliyun.com/ceph/rpm-jewel/el7/noarch/
        gpgcheck=0
二、部署monitor节点
    1、所有节点都安装ceph ceph-radosgw
        [root@mon1 ~]# yum -y install ceph ceph-radosgw
        [root@osd1 ~]# yum -y install ceph ceph-radosgw
        [root@osd2 ~]# yum -y install ceph ceph-radosgw
    2、创建第一个mon节点
        2.1、登录到mon1，查看ceph目录是否已经生成
            [root@mon1 ~]# ls /etc/ceph/
            rbdmap
        2.2、生成ceph配置文件
            [root@mon1 ~]# touch /etc/ceph/ceph.conf
        2.3、执行uuidgen命令，得到一个唯一的标识，作为ceph集群的ID
            [root@mon1 ~]# uuidgen
            bdfb36e0-23ed-4e2f-8bc6-b98d9fa9136c
        2.4、配置ceph.conf
            [root@mon1 ~]# vim /etc/ceph/ceph.conf
            [global]
            fsid = bdfb36e0-23ed-4e2f-8bc6-b98d9fa9136c
            #设置mon1为mon节点
            mon initial members = mon1
            #设置mon节点地址
            mon host = 192.168.1.10
            public network = 192.168.1.0/24
            auth cluster required = cephx
            auth service required = cephx
            auth client required = cephx
            osd journal size = 1024
            #设置副本数
            osd pool default size = 3
            #设置最小副本数
            osd pool default min size = 1
            osd pool default pg num = 256
            osd pool default pgp num = 256
            osd crush chooseleaf type = 1
            osd_mkfs_type = xfs
            max mds = 5
            mds max file size = 100000000000000
            mds cache size = 1000000
            #设置osd节点down后900s，把此osd节点逐出ceph集群，把之前映射到此节点的数据映射到其他节点。
            mon osd down out interval = 900
            [mon]
            #把时钟偏移设置成0.5s，默认是0.05s,由于ceph集群中存在异构PC，导致时钟偏移总是大于0.05s，为了方便同步直接把时钟偏移设置成0.5s
            mon clock drift allowed = .50
        2.5、为监控节点创建管理密钥
            [root@mon1 ~]# ceph-authtool --create-keyring /tmp/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
            creating /tmp/ceph.mon.keyring
        2.6、为ceph amin用户创建管理集群的密钥并赋予访问权限
            [root@mon1 ~]# sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --set-uid=0 --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
            creating /etc/ceph/ceph.client.admin.keyring
        2.7、生成一个引导-osd密钥环，生成一个client.bootstrap-osd用户并将用户添加到密钥环中
            [root@mon1 ~]# sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd'
            creating /var/lib/ceph/bootstrap-osd/ceph.keyring
        2.8、将生成的密钥添加到ceph.mon.keyring
            [root@mon1 ~]# sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
            importing contents of /etc/ceph/ceph.client.admin.keyring into /tmp/ceph.mon.keyring
            [root@mon1 ~]# sudo ceph-authtool /tmp/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
            importing contents of /var/lib/ceph/bootstrap-osd/ceph.keyring into /tmp/ceph.mon.keyring
        2.9、使用主机名、主机IP地址(ES)和FSID生成monmap。把它保存成/tmp/monmap
            [root@mon1 ~]# monmaptool --create --add mon1 192.168.1.10 --fsid bdfb36e0-23ed-4e2f-8bc6-b98d9fa9136c /tmp/monmap
            monmaptool: monmap file /tmp/monmap
            monmaptool: set fsid to bdfb36e0-23ed-4e2f-8bc6-b98d9fa9136c
            monmaptool: writing epoch 0 to /tmp/monmap (1 monitors)
        2.10、创建一个默认的数据目录
            [root@mon1 ~]# sudo -u ceph mkdir /var/lib/ceph/mon/ceph-mon1
        2.11、修改ceph.mon.keyring属主和属组为ceph
            [root@mon1 ~]# chown ceph.ceph /tmp/ceph.mon.keyring
        2.12、初始化mon
            [root@mon1 ~]# sudo -u ceph ceph-mon --mkfs -i mon1 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
            ceph-mon: set fsid to bdfb36e0-23ed-4e2f-8bc6-b98d9fa9136c
            ceph-mon: created monfs at /var/lib/ceph/mon/ceph-mon1 for mon.mon1
        2.13、为了防止重新被安装创建一个空的done文件
            [root@mon1 ~]# sudo touch /var/lib/ceph/mon/ceph-mon1/done
        2.14、启动mon
            [root@mon1 ~]# systemctl start ceph-mon@mon1
        2.15、查看运行状态
            [root@mon1 ~]# systemctl status ceph-mon@mon1
            ● ceph-mon@mon1.service - Ceph cluster monitor daemon
                Loaded: loaded (/usr/lib/systemd/system/ceph-mon@.service; disabled; vendor preset: disabled)
                Active: active (running) since Fri 2018-06-29 13:36:27 CST; 5min ago
                Main PID: 1936 (ceph-mon)
        2.16、设置mon开机自动启动
            [root@mon1 ~]# systemctl enable ceph-mon@mon1
            Created symlink from /etc/systemd/system/ceph-mon.target.wants/ceph-mon@mon1.service to /usr/lib/systemd/system/ceph-mon@.service.
    3、新增mon节点osd1
        3.1、把mon1上生成的配置文件和密钥文件拷贝到osd1
            [root@mon1 ~]# scp /etc/ceph/* root@osd1:/etc/ceph/
            [root@mon1 ~]# scp /var/lib/ceph/bootstrap-osd/ceph.keyring root@osd1:/var/lib/ceph/bootstrap-osd/
            [root@mon1 ~]# scp /tmp/ceph.mon.keyring root@osd1:/tmp/ceph.mon.keyring //这个可以不用复制，因为3.3这步手动获取到了ceph.mon.keyring，但是要改成ceph属主属组
        3.2、在osd1上创建一个默认的数据目录
            [root@osd1 ~]# sudo -u ceph mkdir /var/lib/ceph/mon/ceph-osd1 //这个目录可以不用手动创建，ceph-mon --mkfs -i命令会自动创建，目录命名为ceph-`hostname`
        3.3、获取密钥和monmap信息
            [root@osd1 ~]# ceph auth get mon. -o /tmp/ceph.mon.keyring //可以通过这个命令获取第一次创建的ceph.mon.keyring，然后改成ceph属主属组，不然会报没有权限，官方没有改权限这一步，是个坑
            exported keyring for mon.
            [root@osd1 ~]# ceph mon getmap -o /tmp/ceph.mon.map //这个是root属主属组，其它有读的权限即可，所以不用改成ceph属主属组
            got monmap epoch 1
        3.4、在osd1上修改ceph.mon.keyring属主和属组为ceph
            [root@osd1 ~]# chown ceph.ceph /tmp/ceph.mon.keyring
        3.5、初始化mon
            [root@osd1 ~]# sudo -u ceph ceph-mon --mkfs -i osd1 --monmap /tmp/ceph.mon.map --keyring /tmp/ceph.mon.keyring
            ceph-mon: set fsid to 8ca723b0-c350-4807-9c2a-ad6c442616aa
            ceph-mon: created monfs at /var/lib/ceph/mon/ceph-osd1 for mon.osd1
        3.6、为了防止重新被安装创建一个空的done文件
            [root@osd1 ~]# sudo touch /var/lib/ceph/mon/ceph-osd1/done
        3.7、将新的mon节点添加至ceph集群的mon列表
            [root@osd1 ~]# ceph mon add osd1 192.168.1.11:6789
            adding mon.osd1 at 192.168.1.11:6789/0
        3.8、启动新添加的mon
            [root@osd1 ~]# systemctl start ceph-mon@osd1 
            [root@osd1 ~]# systemctl status ceph-mon@osd1
            ● ceph-mon@osd1.service - Ceph cluster monitor daemon
            Loaded: loaded (/usr/lib/systemd/system/ceph-mon@.service; disabled; vendor preset: disabled)
            Active: active (running) since Sat 2018-06-30 10:58:52 CST; 6s ago
            Main PID: 1555 (ceph-mon)
        3.9、设置mon开机自动启动
            [root@osd1 ~]# systemctl enable ceph-mon@osd1
            Created symlink from /etc/systemd/system/ceph-mon.target.wants/ceph-mon@osd1.service to /usr/lib/systemd/system/ceph-mon@.service.
           
            补充1：cephX用一张图来表明秘钥的生成关系：
                                        +-----> client.cinder
                                        |
                    +--> client.admin ----+-----> client.nova
                    |					  |					  
                    |					  +-----> client.glance
                    |
                    +--> client.bootstrap-mds --------> mds.NodeA					  
                    |
                    |
            mon. ------> client.bootstrap-osd --------> osd.0
                    |							  |
                    |							  +---> osd.1
                    |                             |
                    |							  +---> osd.2
                    |
                    |--> client.bootstrap-rgw --------> client.rgw.NodeA
                    |--> client.bootstrap-mgr --------> client.rgw.NodeA
            通过这张图，我们可以很容易理解 bootstrap 的几个用户的用处了，就是用于引导生成对应类用户的用户，比如bootstrap-osd 用于引导生成所有 osd.N 用户。
           
            补充2：启动mon服务会自动生成bootstarp-mds及bootstrap-rgw的密钥,cephX中mon.是认证鼻祖,mon初始化时会生成相关对象的自举密钥，以下是ceph-deploy mon create-initial产生的日志
            [2017-07-28 16:49:53,468][centos7][INFO  ] Running command: /usr/bin/ceph --connect-timeout=25 --cluster=ceph --admin-daemon=/var/run/ceph/ceph-mon.centos7.asok mon_status
            [2017-07-28 16:49:53,557][centos7][INFO  ] Running command: /usr/bin/ceph --connect-timeout=25 --cluster=ceph --name mon. --keyring=/var/lib/ceph/mon/ceph-centos7/keyring auth get client.admin
            [2017-07-28 16:49:53,761][centos7][INFO  ] Running command: /usr/bin/ceph --connect-timeout=25 --cluster=ceph --name mon. --keyring=/var/lib/ceph/mon/ceph-centos7/keyring auth get client.bootstrap-mds
            [2017-07-28 16:49:54,046][centos7][INFO  ] Running command: /usr/bin/ceph --connect-timeout=25 --cluster=ceph --name mon. --keyring=/var/lib/ceph/mon/ceph-centos7/keyring auth get client.bootstrap-mgr
            [2017-07-28 16:49:54,255][centos7][INFO  ] Running command: /usr/bin/ceph --connect-timeout=25 --cluster=ceph --name mon. --keyring=/var/lib/ceph/mon/ceph-centos7/keyring auth get-or-create client.bootstrap-mgr mon allow profile bootstrap-mgr
            [2017-07-28 16:49:54,452][centos7][INFO  ] Running command: /usr/bin/ceph --connect-timeout=25 --cluster=ceph --name mon. --keyring=/var/lib/ceph/mon/ceph-centos7/keyring auth get client.bootstrap-osd
            [2017-07-28 16:49:54,658][centos7][INFO  ] Running command: /usr/bin/ceph --connect-timeout=25 --cluster=ceph --name mon. --keyring=/var/lib/ceph/mon/ceph-centos7/keyring auth get client.bootstrap-rgw
    4、新增mon节点osd2
        4.1、把mon1上生成的配置文件和密钥文件拷贝到osd2
            [root@mon1 ~]# scp /etc/ceph/* root@osd2:/etc/ceph/ 
            [root@mon1 ~]# scp /var/lib/ceph/bootstrap-osd/ceph.keyring root@osd2:/var/lib/ceph/bootstrap-osd/
            [root@mon1 ~]# scp /tmp/ceph.mon.keyring root@osd2:/tmp/ceph.mon.keyring //这个可以不用复制，因为4.3这步手动获取到了ceph.mon.keyring，但是要改成ceph属主属组
        4.2、在osd2上创建一个默认的数据目录
            [root@osd2 ~]# sudo -u ceph mkdir /var/lib/ceph/mon/ceph-osd2
        4.3、获取密钥和monmap信息
            [root@osd2 ~]# ceph auth get mon. -o /tmp/ceph.mon.keyring //可以通过这个命令获取第一次创建的ceph.mon.keyring，然后改成ceph属主属组，不然会报没有权限，官方没有改权限这一步，是个坑
            exported keyring for mon.
            [root@osd2 ~]# ceph mon getmap -o /tmp/ceph.mon.map //这个是root属主属组，其它有读的权限即可，所以不用改成ceph属主属组
            got monmap epoch 1
        4.4、在osd2上修改ceph.mon.keyring属主和属组为ceph
            [root@osd2 ~]# chown ceph.ceph /tmp/ceph.mon.keyring
        4.5、初始化mon
            [root@osd2 ~]# sudo -u ceph ceph-mon --mkfs -i osd2 --monmap /tmp/ceph.mon.map --keyring /tmp/ceph.mon.keyring
            ceph-mon: set fsid to 8ca723b0-c350-4807-9c2a-ad6c442616aa
            ceph-mon: created monfs at /var/lib/ceph/mon/ceph-osd2 for mon.osd2
        4.6、为了防止重新被安装创建一个空的done文件
            [root@osd2 ~]# sudo touch /var/lib/ceph/mon/ceph-osd2/done
        4.7、将新的mon节点添加至ceph集群的mon列表
            [root@osd2 ~]# ceph mon add osd2 192.168.1.12:6789
            adding mon.osd2 at 192.168.1.12:6789/0
        4.8、启动新添加的mon
            [root@osd2 ~]# systemctl start ceph-mon@osd2 //启动mon服务会自动生成bootstarp-mds及bootstrap-rgw的密钥
            [root@osd2 ~]# systemctl status ceph-mon@osd2
            ● ceph-mon@osd2.service - Ceph cluster monitor daemon
            Loaded: loaded (/usr/lib/systemd/system/ceph-mon@.service; disabled; vendor preset: disabled)
            Active: active (running) since Sat 2018-06-30 11:16:00 CST; 4s ago
            Main PID: 1594 (ceph-mon)、
        4.9、设置mon开机自动启动
            [root@osd2 ~]# systemctl enable ceph-mon@osd2
            Created symlink from /etc/systemd/system/ceph-mon.target.wants/ceph-mon@osd2.service to /usr/lib/systemd/system/ceph-mon@.service.
        4.10、三个mon创建完成后可以通过ceph -s查看集群状态
            [root@mon1 ~]# ceph -s
                cluster 8ca723b0-c350-4807-9c2a-ad6c442616aa
                health HEALTH_ERR
                        64 pgs are stuck inactive for more than 300 seconds
                        64 pgs stuck inactive
                        64 pgs stuck unclean
                        no osds
                monmap e3: 3 mons at {mon1=192.168.1.10:6789/0,osd1=192.168.1.11:6789/0,osd2=192.168.1.12:6789/0}
                        election epoch 12, quorum 0,1,2 mon1,osd1,osd2
                osdmap e1: 0 osds: 0 up, 0 in
                        flags sortbitwise,require_jewel_osds
                pgmap v2: 64 pgs, 1 pools, 0 bytes data, 0 objects
                        0 kB used, 0 kB / 0 kB avail
                            64 creating
            注：当前状态中的error是由于还没有添加osd

三、部署osd节点
    1、添加osd之前先在crush图中创建3个名称分别为mon1，osd1，osd2的桶
        [root@mon1 ~]# ceph osd crush add-bucket mon1 host //桶的类型type 0 osd、type 1 host、type 2 chassis、type 3 rack、type 4 row、type 5 pdu、type 6 pod、type 7 room、type 8 datacenter、type 9 region、type 10 root
        added bucket mon1 type host to crush map
        [root@mon1 ~]# ceph osd crush add-bucket osd1 host
        added bucket osd1 type host to crush map
        [root@mon1 ~]# ceph osd crush add-bucket osd2 host
        added bucket osd2 type host to crush map
    2、把3个新添加的桶移动到默认的root下
        [root@mon1 ~]# ceph osd crush move mon1 root=default
        moved item id -2 name 'mon1' to location {root=default} in crush map
        [root@mon1 ~]# ceph osd crush move osd1 root=default
        moved item id -3 name 'osd1' to location {root=default} in crush map
        [root@mon1 ~]# ceph osd crush move osd2 root=default
        moved item id -4 name 'osd2' to location {root=default} in crush map
    3、创建第一个osd
        3.1、创建osd
            [root@mon1 ~]# ceph osd create
            0
            注：0位osd的ID号，默认情况下会自动递增
        3.2、准备磁盘
            注：通过ceph-disk命令可以自动根据ceph.conf文件中的配置信息对磁盘进行分区
            [root@mon1 ~]# ceph-disk prepare /dev/sdb
            Creating new GPT entries.
            The operation has completed successfully.
            The operation has completed successfully.
            meta-data=/dev/sdb1              isize=2048   agcount=4, agsize=1245119 blks
                    =                       sectsz=512   attr=2, projid32bit=1
                    =                       crc=1        finobt=0, sparse=0
            data     =                       bsize=4096   blocks=4980475, imaxpct=25
                    =                       sunit=0      swidth=0 blks
            naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
            log      =internal log           bsize=4096   blocks=2560, version=2
                    =                       sectsz=512   sunit=0 blks, lazy-count=1
            realtime =none                   extsz=4096   blocks=0, rtextents=0
            The operation has completed successfully.
        3.3、对第一个分区进行格式化
            [root@mon1 ~]# mkfs.xfs -f /dev/sdb1
            meta-data=/dev/sdb1              isize=512    agcount=4, agsize=1245119 blks
                    =                       sectsz=512   attr=2, projid32bit=1
                    =                       crc=1        finobt=0, sparse=0
            data     =                       bsize=4096   blocks=4980475, imaxpct=25
                    =                       sunit=0      swidth=0 blks
            naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
            log      =internal log           bsize=4096   blocks=2560, version=2
                    =                       sectsz=512   sunit=0 blks, lazy-count=1
            realtime =none                   extsz=4096   blocks=0, rtextents=0
        3.4、创建osd默认的数据目录
            [root@mon1 ~]# mkdir -p /var/lib/ceph/osd/ceph-0
            注：目录格式为ceph-$ID，第一步创建出的osd的ID为0，所以目录为ceph-0
        3.5、对分区进行挂载
            [root@mon1 ~]# mount /dev/sdb1 /var/lib/ceph/osd/ceph-0/
        3.6、添加自动挂载信息
            [root@mon1 ~]# echo "/dev/sdb1 /var/lib/ceph/osd/ceph-0/ xfs defaults 0 0" >> /etc/fstab
        3.7、初始化 OSD 数据目录
            [root@mon1 ~]# ceph-osd -i 0 --mkfs --mkkey
            2018-06-30 11:31:19.791042 7f7cbd911880 -1 journal FileJournal::_open: disabling aio for non-block journal.  Use journal_force_aio to force use of aio anyway
            2018-06-30 11:31:19.808367 7f7cbd911880 -1 journal FileJournal::_open: disabling aio for non-block journal.  Use journal_force_aio to force use of aio anyway
            2018-06-30 11:31:19.814628 7f7cbd911880 -1 filestore(/var/lib/ceph/osd/ceph-0) could not find #-1:7b3f43c4:::osd_superblock:0# in index: (2) No such file or directory
            2018-06-30 11:31:19.875860 7f7cbd911880 -1 created object store /var/lib/ceph/osd/ceph-0 for osd.0 fsid 8ca723b0-c350-4807-9c2a-ad6c442616aa
            2018-06-30 11:31:19.875985 7f7cbd911880 -1 auth: error reading file: /var/lib/ceph/osd/ceph-0/keyring: cannot open /var/lib/ceph/osd/ceph-0/keyring: (2) No such file or directory
            2018-06-30 11:31:19.876241 7f7cbd911880 -1 created new key in keyring /var/lib/ceph/osd/ceph-0/keyring
        3.8、添加key
            [root@mon1 ~]# ceph auth add osd.0 osd 'allow *' mon 'allow profile osd' -i /var/lib/ceph/osd/ceph-0/keyring
            added key for osd.0
        3.9、把新建的osd添加到crush中
            [root@mon1 ~]# ceph osd crush add osd.0 1.0 host=mon1
            add item id 0 name 'osd.0' weight 1 at location {host=mon1} to crush map
        3.10、修改osd数据目录的属主和属组为ceph
            [root@mon1 ~]# chown -R ceph:ceph /var/lib/ceph/osd/ceph-0/
        3.11、启动新添加的osd
            [root@mon1 ~]# systemctl start ceph-osd@0
            [root@mon1 ~]# systemctl status ceph-osd@0
            ● ceph-osd@0.service - Ceph object storage daemon
            Loaded: loaded (/usr/lib/systemd/system/ceph-osd@.service; disabled; vendor preset: disabled)
                Active: active (running) since Sat 2018-06-30 11:32:58 CST; 4s ago
                Process: 3408 ExecStartPre=/usr/lib/ceph/ceph-osd-prestart.sh --cluster ${CLUSTER} --id %i (code=exited, status=0/SUCCESS)
            Main PID: 3459 (ceph-osd)
        3.12、设置osd开机自动启动
            [root@mon1 ~]# systemctl enable ceph-osd@0
            Created symlink from /etc/systemd/system/ceph-osd.target.wants/ceph-osd@0.service to /usr/lib/systemd/system/ceph-osd@.service.
        3.13、查看ceph osd tree状态
            [root@mon1 ~]# ceph osd tree
            ID WEIGHT  TYPE NAME      UP/DOWN REWEIGHT PRIMARY-AFFINITY
            -1 1.00000 root default                                    
            -2 1.00000     host mon1                                  
            0 1.00000         osd.0       up  1.00000          1.00000
            -3       0     host osd1                                  
            -4       0     host osd2 
    4、添加新的osd
        注：和添加第一个osd的方法一样，这里写了个简单的添加脚本，可以通过脚本快速进行一下添加
        [root@mon1 ~]# sh osd.sh
        Select the disk: sdc
        Select the host: mon1
        Cleanup OSD ID is done.
        Directory is done.
        Prepare OSD Disk is done.
        Add OSD is done

        脚本内容
        #!/bin/bash
        read -p "Select the disk: " DISK
        until [[ $DISK =~ ^sd[a-z] ]];do
            echo "please input like sd[a-z]!!!"
            read -p "Select the disk: " DISK
        done
        read -p "Select the host: " HOST
        until grep $HOST /etc/hosts;do
            echo "please input ceph_cluster host!!!"
            read -p "Select the host: " HOST
        done
        ##### Cleanup DOWN OSD ID #####
        function precheckOsd {
            if [ `ceph osd dump | egrep ^osd.[[:digit:]]+[[:space:]]{1}down|awk '{print $1,$2}' | wc -l` -gt 0 ];then
                ceph osd dump | egrep ^osd.[[:digit:]]+[[:space:]]{1}down|awk '{print $1,$2}'
                echo -e "\033[41;32myou have these down osds above, do you want to remove them?\033[0m"
                read -p "your choice[y/n]:" CHOICE
                until [ $CHOICE == "y" -o $CHOICE == "n" ];do
                read -p "your choice[y/n]:" CHOICE
                done
                if [[ $CHOICE == 'y' ]];then
                    for i in `ceph osd dump | egrep ^osd.[[:digit:]]+[[:space:]]{1}down|awk '{print $1}'`;do
                        ceph osd crush remove $i
                        ceph auth del $i
                        ceph osd rm $i
                    done
                    echo -e "\033[40;32myou have finished clearing down osds.\033[0m"
                else 
                    echo -e "\033[40;32myou are going to ignore these down osds.\033[0m"
                fi
            else
                echo "you have no down osds"
            fi
        }
        ##### Create OSD Directory #####
        function createOsdDirectory {
            ssh $HOST "if [ -d $DIRECTORY ] ;then rm -rf $DIRECTORY;fi"
            ssh $HOST "mkdir -p $DIRECTORY"
            if [ $? = 0 ] ; then
                echo -e "\033[40;32mDirectory is done.\033[0m"
            else
                echo -e "\033[41;32mDirectory is not ready, please check it.\033[0m"
                exit 7
            fi
        }
        ##### Prepare OSD Disk #####
        function prepareOsdDisk {
            PARTITION=/dev/${DISK}1
            ssh $HOST "blkid | grep $DISK | grep \"ceph data\" &> /dev/zero"
            if [ $? != 0 ] ; then
                ssh $HOST "ceph-disk zap /dev/$DISK &> /dev/zero" 
                ssh $HOST "ceph-disk prepare /dev/$DISK &> /dev/zero"
            else
                echo -e "\033[40;32m$DISK has already configured into osd.\033[0m"
                read -p "but you can zap this disk[y/n]:" DETERMIN
                until [ $DETERMIN == 'y' -o $DETERMIN == 'n' ];do
                    read -p "but you can zap this disk[y/n]:" DETERMIN
                done
                if [ $DETERMIN == 'y' ];then
                    if ssh $HOST "mount | grep $PARTITION";then ssh $HOST "umount $PARTITION";fi
                    ssh $HOST "ceph-disk zap /dev/$DISK &> /dev/null"
                    ssh $HOST "partprobe /dev/$DISK" //注意这一步一定要做，不然内核还记录着分区的状态，后面会失败
                    ssh $HOST "ceph-disk prepare /dev/$DISK &> /dev/null"
                else
                    echo "you are going to ignore this disk and quit"
                    exit 0
                fi
            fi
            ssh $HOST "mkfs.xfs -f $PARTITION &> /dev/zero"
            ssh $HOST "echo \"$PARTITION $DIRECTORY xfs rw,noatime,attr2,inode64,noquota 0 0\" >> /etc/fstab"
            ssh $HOST "mount -o rw,noatime,attr2,inode64,noquota $PARTITION $DIRECTORY"
            if [ $? = 0 ] ; then
                echo -e "\033[40;32mPrepare OSD Disk is done.\033[0m"
            else
                echo -e "\033[40;32mSomething is wrong with preparing osd.\033[0m"
                exit 7
            fi
        }
        ##### Add OSD #####
        function addOsd {
            ssh $HOST "ceph-osd -i $ID --mkfs --mkkey &> /dev/zero"
            ssh $HOST "ceph auth add osd.$ID osd 'allow *' mon 'allow profile osd' -i $DIRECTORY/keyring &> /dev/zero"
            ssh $HOST "ceph osd crush add osd.$ID 1.0 host=$HOST &> /dev/zero"
            ssh $HOST "chown -R ceph:ceph /var/lib/ceph/osd"
            ssh $HOST "systemctl start ceph-osd@$ID &> /dev/zero"
            ssh $HOST "systemctl enable ceph-osd@$ID &> /dev/zero"
            ssh $HOST "systemctl status ceph-osd@$ID &> /dev/zero"
            if [ $? = 0 ] ; then
                echo -e "\033[40;32mAdd OSD is done\033[0m"
            else
                echo -e "\033[40;32mSomthing is wrong with adding osd.\033[0m"
            fi
        }
        precheckOsd
        ID=$(ceph osd create)
        DIRECTORY=/var/lib/ceph/osd/ceph-$ID
        createOsdDirectory
        prepareOsdDisk
        addOsd
        
        注：osd添加完成后查看ceph osd tree 状态

        [root@mon1 ~]# ceph osd tree
        ID WEIGHT  TYPE NAME      UP/DOWN REWEIGHT PRIMARY-AFFINITY
        -1 9.00000 root default                                    
        -2 3.00000     host mon1                                  
        6 1.00000         osd.6       up  1.00000          1.00000
        1 1.00000         osd.1       up  1.00000          1.00000
        4 1.00000         osd.4       up  1.00000          1.00000
        -3 3.00000     host osd1                                  
        7 1.00000         osd.7       up  1.00000          1.00000
        2 1.00000         osd.2       up  1.00000          1.00000
        5 1.00000         osd.5       up  1.00000          1.00000
        -4 3.00000     host osd2                                  
        0 1.00000         osd.0       up  1.00000          1.00000
        3 1.00000         osd.3       up  1.00000          1.00000
        8 1.00000         osd.8       up  1.00000          1.00000
    5、状态修复
        5.1、通过ceph -s查看状态
            [root@mon1 ~]# ceph -s
                cluster ffcb01ea-e7e3-4097-8551-dde0256f610a
                health HEALTH_WARN
                        too few PGs per OSD (21 < min 30)
                monmap e3: 3 mons at {mon1=192.168.1.10:6789/0,osd1=192.168.1.11:6789/0,osd2=192.168.1.12:6789/0
                        election epoch 8, quorum 0,1,2 mon1,osd1,osd2
                osdmap e52: 9 osds: 9 up, 9 in
                        flags sortbitwise,require_jewel_osds
                pgmap v142: 64 pgs, 1 pools, 0 bytes data, 0 objects
                        9519 MB used, 161 GB / 170 GB avail
                            64 active+clean
            注：HEALTH_WARN 提示PG太小
            
            补充：PG计算方式
            total PGs = ((Total_number_of_OSD * 100) / max_replication_count) / pool_count
            当前ceph集群是9个osd，3副本，1个默认的rbd pool
            所以PG计算结果为300，一般把这个值设置为与计算结果最接近的2的幂数，跟300比较接近的是256

        5.2、查看当前的PG值
            [root@mon1 ~]# ceph osd pool get rbd pg_num
            pg_num: 64
            [root@mon1 ~]# ceph osd pool get rbd pgp_num
            pgp_num: 64
        5.3、手动设置
            [root@mon1 ~]# ceph osd pool set rbd pg_num 256
            set pool 0 pg_num to 256
            [root@mon1 ~]# ceph osd pool set rbd pgp_num 256
            set pool 0 pgp_num to 256
        5.4、再次查看状态
            [root@mon1 ~]# ceph -s
                cluster ffcb01ea-e7e3-4097-8551-dde0256f610a
                health HEALTH_WARN
                        clock skew detected on mon.osd1, mon.osd2
                        Monitor clock skew detected
                monmap e3: 3 mons at {mon1=192.168.1.10:6789/0,osd1=192.168.1.11:6789/0,osd2=192.168.1.12:6789/0}
                        election epoch 16, quorum 0,1,2 mon1,osd1,osd2
                osdmap e56: 9 osds: 9 up, 9 in
                        flags sortbitwise,require_jewel_osds
                pgmap v160: 256 pgs, 1 pools, 0 bytes data, 0 objects
                        9527 MB used, 161 GB / 170 GB avail
                            256 active+clean
    6、Monitor clock skew detected
        在上个查看结果中出现了一个新的warn，这个一般是由于mon节点的时间偏差比较大，可以修改ceph.conf中的时间偏差值参数来进行修复
        修改结果：
        [mon]
        mon clock drift allowed = 2
        mon clock drift warn backoff = 30
        再次查看状态
        [root@mon1 ~]# ceph -s
            cluster ffcb01ea-e7e3-4097-8551-dde0256f610a
            health HEALTH_OK
            monmap e3: 3 mons at {mon1=192.168.1.10:6789/0,osd1=192.168.1.11:6789/0,osd2=192.168.1.12:6789/0}
                    election epoch 22, quorum 0,1,2 mon1,osd1,osd2
            osdmap e56: 9 osds: 9 up, 9 in
                    flags sortbitwise,require_jewel_osds
            pgmap v160: 256 pgs, 1 pools, 0 bytes data, 0 objects
                    9527 MB used, 161 GB / 170 GB avail
                        256 active+clean
        注：生产环境中可以通过配置时间同步解决此状况

四、部署mds节点
    1、创建第一个mds
        1.1、为mds元数据服务器创建一个目录
            [root@mon1 ~]# mkdir -p /var/lib/ceph/mds/ceph-mon1
        1.2、为bootstrap-mds客户端创建一个密钥 注：(如果下面的密钥在目录里已生成可以省略此步骤）
            [root@mon1 ~]# ceph-authtool --create-keyring /var/lib/ceph/bootstrap-mds/ceph.keyring --gen-key -n client.bootstrap-mds
            creating /var/lib/ceph/bootstrap-mds/ceph.keyring
        1.3、在ceph auth库中创建bootstrap-mds客户端，赋予权限添加之前创建的密钥 注（查看ceph auth list 用户权限认证列表 如果已有client.bootstrap-mds此用户，此步骤可以省略）
            [root@mon1 ~]# ceph auth add client.bootstrap-mds mon 'allow profile bootstrap-mds' -i /var/lib/ceph/bootstrap-mds/ceph.keyring
        1.4、在root家目录里创建ceph.bootstrap-mds.keyring文件
            [root@mon1 ~]# touch /root/ceph.bootstrap-mds.keyring
        1.5、把keyring /var/lib/ceph/bootstrap-mds/ceph.keyring里的密钥导入家目录下的ceph.bootstrap-mds.keyring文件里
            [root@mon1 ~]# ceph-authtool --import-keyring /var/lib/ceph/bootstrap-mds/ceph.keyring ceph.bootstrap-mds.keyring
            importing contents of /var/lib/ceph/bootstrap-mds/ceph.keyring into ceph.bootstrap-mds.keyring
        1.6、在ceph auth库中创建mds.mon1用户，并赋予权限和创建密钥，密钥保存在/var/lib/ceph/mds/ceph-mon1/keyring文件里
            [root@mon1 ~]# ceph --cluster ceph --name client.bootstrap-mds --keyring /var/lib/ceph/bootstrap-mds/ceph.keyring auth get-or-create mds.mon1 osd 'allow rwx' mds 'allow' mon 'allow profile mds' -o /var/lib/ceph/mds/ceph-mon1/keyring
        1.7、启动mds
            [root@mon1 ~]# systemctl start ceph-mds@mon1
            [root@mon1 ~]# systemctl status ceph-mds@mon1
            ● ceph-mds@mon1.service - Ceph metadata server daemon
                Loaded: loaded (/usr/lib/systemd/system/ceph-mds@.service; disabled; vendor preset: disabled)
                Active: active (running) since Mon 2018-07-02 10:54:17 CST; 5s ago
            Main PID: 18319 (ceph-mds)
        1.8、设置mds开机自动启动
            [root@mon1 ~]# systemctl enable ceph-mds@mon1
            Created symlink from /etc/systemd/system/ceph-mds.target.wants/ceph-mds@mon1.service to /usr/lib/systemd/system/ceph-mds@.service.
    2、添加第二个mds
        2.1、拷贝密钥文件到osd1
            [root@mon1 ~]# scp ceph.bootstrap-mds.keyring osd1:/root/ceph.bootstrap-mds.keyring       
            [root@mon1 ~]# scp /var/lib/ceph/bootstrap-mds/ceph.keyring osd1:/var/lib/ceph/bootstrap-mds/ceph.keyring
        2.2、在osd1上创建mds元数据目录
            [root@osd1 ~]# mkdir -p /var/lib/ceph/mds/ceph-osd1
        2.3、在ceph auth库中创建mds.mon1用户，并赋予权限和创建密钥，密钥保存在/var/lib/ceph/mds/ceph-osd1/keyring文件里
            [root@osd1 ~]# ceph --cluster ceph --name client.bootstrap-mds --keyring /var/lib/ceph/bootstrap-mds/ceph.keyring auth get-or-create mds.osd1 osd 'allow rwx' mds 'allow' mon 'allow profile mds' -o /var/lib/ceph/mds/ceph-osd1/keyring
        2.4、启动mds
            [root@osd1 ~]# systemctl start ceph-mds@osd1
            [root@osd1 ~]# systemctl status ceph-mds@osd1
            ● ceph-mds@osd1.service - Ceph metadata server daemon
                Loaded: loaded (/usr/lib/systemd/system/ceph-mds@.service; disabled; vendor preset: disabled)
                Active: active (running) since Mon 2018-07-02 11:21:09 CST; 3s ago
            Main PID: 14164 (ceph-mds)
        2.5、设置mds开机自动启动
            [root@osd1 ~]# systemctl enable ceph-mds@osd1
            Created symlink from /etc/systemd/system/ceph-mds.target.wants/ceph-mds@osd1.service to /usr/lib/systemd/system/ceph-mds@.service.
    3、添加第三个mds
        3.1、拷贝密钥文件到osd2
            [root@mon1 ~]# scp ceph.bootstrap-mds.keyring osd2:/root/ceph.bootstrap-mds.keyring       
            [root@mon1 ~]# scp /var/lib/ceph/bootstrap-mds/ceph.keyring osd2:/var/lib/ceph/bootstrap-mds/ceph.keyring
        3.2、在osd2上创建mds元数据目录
            [root@osd2 ~]# mkdir -p /var/lib/ceph/mds/ceph-osd2
        3.3、在ceph auth库中创建mds.mon1用户，并赋予权限和创建密钥，密钥保存在/var/lib/ceph/mds/ceph-osd1/keyring文件里
            [root@osd2 ~]# ceph --cluster ceph --name client.bootstrap-mds --keyring /var/lib/ceph/bootstrap-mds/ceph.keyring auth get-or-create mds.osd2 osd 'allow rwx' mds 'allow' mon 'allow profile mds' -o /var/lib/ceph/mds/ceph-osd2/keyring
        3.4、启动mds
            [root@osd2 ~]# systemctl restart ceph-mds@osd2
            [root@osd2 ~]# systemctl status ceph-mds@osd2
            ● ceph-mds@osd2.service - Ceph metadata server daemon
                Loaded: loaded (/usr/lib/systemd/system/ceph-mds@.service; disabled; vendor preset: disabled)
                Active: active (running) since Mon 2018-07-02 11:11:41 CST; 15min ago
            Main PID: 31940 (ceph-mds)
        3.5、设置mds开机自动启动
            [root@osd2 ~]# systemctl enable ceph-mds@osd2
            Created symlink from /etc/systemd/system/ceph-mds.target.wants/ceph-mds@osd2.service to /usr/lib/systemd/system/ceph-mds@.service.

五、部署radosgw节点
    1、设备列表
        注：以上的环境现在是这个样子的
        mon,osd,mds,rgw mon1 192.168.1.10
        mon,osd,mds,rgw osd1 192.168.1.11
        mon,osd,mds,rgw osd2 192.168.1.12

    2、Ceph RGW 部署
        Ceph RGW的FastCGI支持多种Web服务器作为前端，例如Nginx、Apache2等。 从Ceph Hammer版本开始，使用ceph-deploy部署时将会默认使用内置的civetweb作为前端。本文分别采用civeweb和nginx进行一下部署。

    3、使用civetweb配置
        3.1、安装radosgw
            注：如果之前已经进行过安装，可以跳过此步骤
            [root@mon1 ~]# yum -y install radosgw
            [root@osd1 ~]# yum -y install radosgw
            [root@osd2 ~]# yum -y install radosgw
        3.2、创建资源池
            注：需要创建的资源池列表如下
            [root@mon1 ~]# cat pool
            .rgw
            .rgw.root
            .rgw.control
            .rgw.gc
            .rgw.buckets
            .rgw.buckets.index
            .rgw.buckets.extra
            .log
            .intent-log
            .usage
            .users
            .users.email
            .users.swift
            .users.uid
            注：这里通过脚本快速创建这些资源池，脚本内容如下

            #!/bin/bash
            PG_NUM=64
            PGP_NUM=64
            SIZE=3
            for i in `cat /root/pool`
                    do
                    ceph osd pool create $i $PG_NUM
                    ceph osd pool set $i size $SIZE
                    done
            for i in `cat /root/pool`
                    do
                    ceph osd pool set $i pgp_num $PGP_NUM
                    done
        3.3、创建keyring
            [root@mon1 ~]# sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.radosgw.keyring
            creating /etc/ceph/ceph.client.radosgw.keyring
        3.4、修改文件权限
            [root@mon1 ~]# sudo chown ceph:ceph /etc/ceph/ceph.client.radosgw.keyring
        3.5、生成ceph-radosgw服务对应的用户和key
            [root@mon1 ~]# sudo ceph-authtool /etc/ceph/ceph.client.radosgw.keyring -n client.rgw.mon1 --gen-key
        3.6、为用户添加访问权限
            [root@mon1 ~]# sudo ceph-authtool -n client.rgw.mon1 --cap osd 'allow rwx' --cap mon 'allow rwx' /etc/ceph/ceph.client.radosgw.keyring
        3.7、导入keyring到集群中
            [root@mon1 ~]# sudo ceph -k /etc/ceph/ceph.client.admin.keyring auth add client.rgw.mon1 -i /etc/ceph/ceph.client.radosgw.keyring
            added key for client.rgw.mon1
        3.8、配置ceph.conf
            [client.rgw.mon1]
            host=mon1
            keyring=/etc/ceph/ceph.client.radosgw.keyring
            log file=/var/log/radosgw/client.radosgw.gateway.log
            rgw_s3_auth_use_keystone = False
            rgw_frontends = civetweb port=8080
        3.9、创建日志目录并修改权限
            [root@mon1 ~]# mkdir /var/log/radosgw
            [root@mon1 ~]# chown ceph:ceph /var/log/radosgw
        3.10、启动rgw
            [root@mon1 ~]# systemctl start ceph-radosgw@rgw.mon1
            [root@mon1 ~]# systemctl status ceph-radosgw@rgw.mon1
            ● ceph-radosgw@rgw.mon1.service - Ceph rados gateway
                Loaded: loaded (/usr/lib/systemd/system/ceph-radosgw@.service; disabled; vendor preset: disabled)
                Active: active (running) since Tue 2018-07-03 12:53:42 CST; 5s ago
            Main PID: 13660 (radosgw)
            CGroup: /system.slice/system-ceph\x2dradosgw.slice/ceph-radosgw@rgw.mon1.service
                    └─13660 /usr/bin/radosgw -f --cluster ceph --name client.rgw.mon1 --setuser ceph --setgr...
            Jul 03 12:53:42 mon1 systemd[1]: Started Ceph rados gateway.
            Jul 03 12:53:42 mon1 systemd[1]: Starting Ceph rados gateway...
        3.11、查看端口监听状态
            [root@mon1 ~]# netstat -antpu | grep 8080
            tcp        0      0 0.0.0.0:8080            0.0.0.0:*               LISTEN      13660/radosgw
        3.12、设置rgw开机自动启动
            [root@mon1 ~]# systemctl enable ceph-radosgw@rgw.mon1
            Created symlink from /etc/systemd/system/ceph-radosgw.target.wants/ceph-radosgw@rgw.mon1.service to /usr/lib/systemd/system/ceph-radosgw@.service.
        3.13、在osd1、osd2上部署rgw
            注：以下命令在mon1上执行即可
            a、创建对应的client.rgw.osd1、client.rgw.osd2用户并进行授权
                [root@mon1 ~]# sudo ceph-authtool /etc/ceph/ceph.client.radosgw.keyring -n client.rgw.osd1 --gen-key
                [root@mon1 ~]# sudo ceph-authtool -n client.rgw.osd1 --cap osd 'allow rwx' --cap mon 'allow rwx' /etc/ceph/ceph.client.radosgw.keyring
                [root@mon1 ~]# sudo ceph -k /etc/ceph/ceph.client.admin.keyring auth add client.rgw.osd1 -i /etc/ceph/ceph.client.radosgw.keyring
                added key for client.rgw.osd1
                [root@mon1 ~]# sudo ceph-authtool /etc/ceph/ceph.client.radosgw.keyring -n client.rgw.osd2 --gen-key
                [root@mon1 ~]# sudo ceph-authtool -n client.rgw.osd2 --cap osd 'allow rwx' --cap mon 'allow rwx' /etc/ceph/ceph.client.radosgw.keyring
                [root@mon1 ~]# sudo ceph -k /etc/ceph/ceph.client.admin.keyring auth add client.rgw.osd2 -i /etc/ceph/ceph.client.radosgw.keyring
                added key for client.rgw.osd2

            b、在ceph.conf文件中添加如下内容
                [client.rgw.osd1]
                host=osd1
                keyring=/etc/ceph/ceph.client.radosgw.keyring
                log file=/var/log/radosgw/client.radosgw.gateway.log
                rgw_s3_auth_use_keystone = False
                rgw_frontends = civetweb port=8080
                [client.rgw.osd2]
                host=osd2
                keyring=/etc/ceph/ceph.client.radosgw.keyring
                log file=/var/log/radosgw/client.radosgw.gateway.log
                rgw_s3_auth_use_keystone = False
                rgw_frontends = civetweb port=8080
            c、 把创建好的ceph.client.radosgw.keyring和ceph.conf传到osd1和osd2上
                [root@mon1 ~]# scp /etc/ceph/ceph.client.radosgw.keyring osd1:/etc/ceph/ceph.client.radosgw.keyring
                [root@mon1 ~]# scp /etc/ceph/ceph.client.radosgw.keyring osd2:/etc/ceph/ceph.client.radosgw.keyring
                [root@mon1 ~]# scp /etc/ceph/ceph.conf osd1:/etc/ceph/ceph.conf
                [root@mon1 ~]# scp /etc/ceph/ceph.conf osd2:/etc/ceph/ceph.conf
            d、 在osd1和osd2上分别创建日志目录并修改权限
                [root@osd1 ~]# mkdir /var/log/radosgw
                [root@osd1 ~]# chown ceph:ceph /var/log/radosgw
                [root@osd2 ~]# mkdir /var/log/radosgw
                [root@osd2 ~]# chown ceph:ceph /var/log/radosgw
            e、 启动osd1和osd2上的rgw服务
                [root@osd1 ~]# systemctl start ceph-radosgw@rgw.osd1
                [root@osd1 ~]# systemctl status ceph-radosgw@rgw.osd1
                ● ceph-radosgw@rgw.osd1.service - Ceph rados gateway
                    Loaded: loaded (/usr/lib/systemd/system/ceph-radosgw@.service; disabled; vendor preset: disabled)
                    Active: active (running) since Tue 2018-07-03 13:19:51 CST; 5s ago
                Main PID: 12016 (radosgw)
               
                [root@osd2 ~]# systemctl start ceph-radosgw@rgw.osd2
                [root@osd2 ~]# systemctl status ceph-radosgw@rgw.osd2
                ● ceph-radosgw@rgw.osd2.service - Ceph rados gateway
                    Loaded: loaded (/usr/lib/systemd/system/ceph-radosgw@.service; disabled; vendor preset: disabled)
                    Active: active (running) since Tue 2018-07-03 13:21:51 CST; 6s ago
                Main PID: 2435 (radosgw)
            f、 设置rgw开机自动启动
                [root@osd1 ~]# systemctl enable ceph-radosgw@rgw.osd1
                Created symlink from /etc/systemd/system/ceph-radosgw.target.wants/ceph-radosgw@rgw.osd1.service to /usr/lib/systemd/system/ceph-radosgw@.service.
                [root@osd2 ~]# systemctl enable ceph-radosgw@rgw.osd2
                Created symlink from /etc/systemd/system/ceph-radosgw.target.wants/ceph-radosgw@rgw.osd2.service to /usr/lib/systemd/system/ceph-radosgw@.service.


    4、使用nginx配置
        4.1、在mon1上安装nginx
            [root@mon1 ~]# yum -y install nginx
        4.2、在/etc/nginx/conf.d/目录下生成rgw.conf并添加如下配置
            server {
                listen   80;
                server_name mon1;
                location / {
                    fastcgi_pass_header Authorization;
                    fastcgi_pass_request_headers on;
                    fastcgi_param QUERY_STRING  $query_string;
                    fastcgi_param REQUEST_METHOD $request_method;
                    fastcgi_param CONTENT_LENGTH $content_length;
                    fastcgi_param CONTENT_LENGTH $content_length;
                    if ($request_method = PUT) {
                            rewrite ^ /PUT$request_uri;
                    }
                    include fastcgi_params;
                    fastcgi_pass 192.168.1.10:9000;
                }
                location /PUT/ {
                    internal;
                    fastcgi_pass_header Authorization;
                    fastcgi_pass_request_headers on;
                    include fastcgi_params;
                    fastcgi_param QUERY_STRING  $query_string;
                    fastcgi_param REQUEST_METHOD $request_method;
                    fastcgi_param CONTENT_LENGTH $content_length;
                    fastcgi_param  CONTENT_TYPE $content_type;
                    fastcgi_pass 192.168.1.10:9000;
                }
            }
            server {
                listen   80;
                server_name osd1;
                location / {
                    fastcgi_pass_header Authorization;
                    fastcgi_pass_request_headers on;
                    fastcgi_param QUERY_STRING  $query_string;
                    fastcgi_param REQUEST_METHOD $request_method;
                    fastcgi_param CONTENT_LENGTH $content_length;
                    fastcgi_param CONTENT_LENGTH $content_length;
                    if ($request_method = PUT) {
                            rewrite ^ /PUT$request_uri;
                    }
                    include fastcgi_params;
                    fastcgi_pass 192.168.1.11:9000;
                }
                location /PUT/ {
                    internal;
                    fastcgi_pass_header Authorization;
                    fastcgi_pass_request_headers on;
                    include fastcgi_params;
                    fastcgi_param QUERY_STRING  $query_string;
                    fastcgi_param REQUEST_METHOD $request_method;
                    fastcgi_param CONTENT_LENGTH $content_length;
                    fastcgi_param  CONTENT_TYPE $content_type;
                    fastcgi_pass 192.168.1.11:9000;
                }
            }
            server {
                listen   80;
                server_name osd2;
                location / {
                    fastcgi_pass_header Authorization;
                    fastcgi_pass_request_headers on;
                    fastcgi_param QUERY_STRING  $query_string;
                    fastcgi_param REQUEST_METHOD $request_method;
                    fastcgi_param CONTENT_LENGTH $content_length;
                    fastcgi_param CONTENT_LENGTH $content_length;
                    if ($request_method = PUT) {
                            rewrite ^ /PUT$request_uri;
                    }
                    include fastcgi_params;
                    fastcgi_pass 192.168.1.12:9000;
                }
                location /PUT/ {
                    internal;
                    fastcgi_pass_header Authorization;
                    fastcgi_pass_request_headers on;
                    include fastcgi_params;
                    fastcgi_param QUERY_STRING  $query_string;
                    fastcgi_param REQUEST_METHOD $request_method;
                    fastcgi_param CONTENT_LENGTH $content_length;
                    fastcgi_param  CONTENT_TYPE $content_type;
                    fastcgi_pass 192.168.1.12:9000;
                }
            }
            注：由于是使用nginx端口使用是80端口，需要删掉或注释nginx.conf中的默认端口80的站点配置，否则nginx无法启动

        4.3、启动nginx并设置为开机自动启动
            [root@mon1 ~]# systemctl start nginx
            [root@mon1 ~]# systemctl enable nginx
        4.4、修改ceph.conf内容如下
            [client.rgw.mon1]
            rgw frontends=fastcgi socket_port=9000 socket_host=0.0.0.0
            host=mon1
            keyring=/etc/ceph/ceph.client.radosgw.keyring
            log file=/var/log/radosgw/client.radosgw.gateway.log
            rgw print continue=false
            rgw content length compat = true
            [client.rgw.osd1]
            rgw frontends=fastcgi socket_port=9000 socket_host=0.0.0.0
            host=osd1
            keyring=/etc/ceph/ceph.client.radosgw.keyring
            log file=/var/log/radosgw/client.radosgw.gateway.log
            rgw print continue=false
            rgw content length compat = true
            [client.rgw.osd2]
            rgw frontends=fastcgi socket_port=9000 socket_host=0.0.0.0
            host=osd2
            keyring=/etc/ceph/ceph.client.radosgw.keyring
            log file=/var/log/radosgw/client.radosgw.gateway.log
            rgw print continue=false
            rgw content length compat = true
        4.5、把修改好的/etc/ceph.conf 文件传到osd1和osd2上
            [root@mon1 ~]# scp  /etc/ceph/ceph.conf osd1:/etc/ceph/ceph.conf
            [root@mon1 ~]# scp  /etc/ceph/ceph.conf osd2:/etc/ceph/ceph.conf
        4.6、在3个节点上分别重启rgw并观察端口是否修改为了9000
            [root@mon1 ~]# systemctl restart ceph-radosgw@rgw.mon1
            [root@mon1 ~]# systemctl status ceph-radosgw@rgw.mon1                                                                                                       
            ● ceph-radosgw@rgw.mon1.service - Ceph rados gateway
                Loaded: loaded (/usr/lib/systemd/system/ceph-radosgw@.service; enabled; vendor preset: disabled)
                Active: active (running) since Tue 2018-07-03 15:00:44 CST; 5s ago
            Main PID: 16087 (radosgw)
            
            [root@mon1 ~]# netstat -antpu | grep 9000
            tcp        0      0 0.0.0.0:9000            0.0.0.0:*               LISTEN      16087/radosgw 
            [root@osd1 ~]# systemctl restart ceph-radosgw@rgw.osd1
            [root@osd1 ~]# systemctl status ceph-radosgw@rgw.osd1                                                                                                        
            ● ceph-radosgw@rgw.osd1.service - Ceph rados gateway
                Loaded: loaded (/usr/lib/systemd/system/ceph-radosgw@.service; enabled; vendor preset: disabled)
                Active: active (running) since Tue 2018-07-03 15:01:46 CST; 5s ago

            [root@osd1 ~]# netstat -anptu | grep 9000
            tcp        0      0 0.0.0.0:9000            0.0.0.0:*               LISTEN      13983/radosgw
            [root@osd2 ~]# systemctl restart ceph-radosgw@rgw.osd2
            [root@osd2 ~]# systemctl status ceph-radosgw@rgw.osd2
            ● ceph-radosgw@rgw.osd2.service - Ceph rados gateway
                Loaded: loaded (/usr/lib/systemd/system/ceph-radosgw@.service; enabled; vendor preset: disabled)
                Active: active (running) since Tue 2018-07-03 15:02:43 CST; 14s ago
            [root@osd2 ~]# netstat -antpu | grep 9000
            tcp        0      0 0.0.0.0:9000            0.0.0.0:*               LISTEN      3737/radosgw
            
            注：这一步做的过程中出了点小问题，osd1上的rgw一直无法重启成功，后来查看是ceph.client.radosgw.keyring 中osd1的用户信息没有了，需要重新添加一下，添加之前先通过ceph auth list看一下是否还有osd1的信息，如果有的话，需要手动清除一下，然后再执行之前的创建用户和添加授权的命令即可。正确的文件内容如下
            [root@mon1 ~]# cat /etc/ceph/ceph.client.radosgw.keyring
            [client.rgw.mon1]
                    key = AQCPADtbk6AoJxAAXSUaO5FmHAJl9BJBCeVZVA==
                    caps mon = "allow rwx"
                    caps osd = "allow rwx"
            [client.rgw.osd1]
                    key = AQBRFjtb5zz0LRAAwr7RdxLprs344gA8v60Qhw==
                    caps mon = "allow rwx"
                    caps osd = "allow rwx"
            [client.rgw.osd2]
                    key = AQCeBztbQPdFChAAgoDcmDWsQwRCo5SDPaHAIw==
                    caps mon = "allow rwx"
                    caps osd = "allow rwx"
















