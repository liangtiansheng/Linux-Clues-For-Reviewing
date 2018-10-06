1、按照官网给的步骤一步步手动安装，一会sudo一会不sudo，其中有两个步骤
    [root@mon1 ~]# sudo -u ceph mkdir /var/lib/ceph/mon/ceph-mon1
    [root@mon1 ~]# sudo -u ceph ceph-mon --mkfs -i mon1 --monmap /tmp/monmap --keyring /tmp/ceph.mon.keyring
    2018-09-25 22:17:13.081119 7f7948887ec0 -1 mon.mon1@-1(probing) e0 unable to find a keyring file on /tmp/ceph.mon.keyring: (13) Permission denied
    2018-09-25 22:17:13.081170 7f7948887ec0 -1 ceph-mon: error creating monfs: (2) No such file or directory
    问题：严格按照操作还是有这个错，这是因为ceph-authtool生成的/tmp/ceph.mon.keyring权限是600，这里切换成ceph执行命令当然没权限了
    方法：chmod 644 /tmp/ceph.mon.keyring

2、cephfs用kernel driver挂载时出现错误 
    [root@mon1 ~]# mount -t ceph 192.168.2.81:6789:/ /cephfs_test
    mount error 22 = Invalid argument
    错误日志：
        Oct  6 16:40:54 mon1 kernel: libceph: no secret set (for auth_x protocol)
        Oct  6 16:40:54 mon1 kernel: libceph: error -22 on auth protocol 2 init
    分析原因：
        原因如日志所说很明显，必须指定用户和其密钥
    解决办法：
        [root@mon1 ~]# cat /etc/ceph/ceph.client.admin.keyring 
        [client.admin]
            key = AQATiLdba1USDhAA62+phX8TXrQCiSUEcnmUHw==
            caps mds = "allow *"
            caps mon = "allow *"
            caps osd = "allow *"
        [root@mon1 ~]# vim admin.secret
        ###粘贴key###

        ***这里要注意一下，挂载用的是mon的ip和port
        [root@mon1 ~]# mount -t ceph 192.168.2.81:6789:/ /cephfs_test/ -o name=admin,secretfile=/root/admin.secret
        [root@mon1 ~]# df -hP
        Filesystem           Size  Used Avail Use% Mounted on
        /dev/sda2            116G  1.4G  115G   2% /
        devtmpfs             981M     0  981M   0% /dev
        tmpfs                992M     0  992M   0% /dev/shm
        tmpfs                992M  9.4M  982M   1% /run
        tmpfs                992M     0  992M   0% /sys/fs/cgroup
        /dev/sda1            297M  107M  191M  36% /boot
        tmpfs                199M     0  199M   0% /run/user/0
        192.168.2.81:6789:/  360G  328M  360G   1% /cephfs_test
        [root@mon1 ~]#

3、创建好rbd块后，进行映射时出现错误
    root@ceph-1:~# rbd map test_image
    rbd: sysfs write failed
    RBD image feature set mismatch. You can disable features unsupported by the kernel with "rbd feature disable".
    In some cases useful info is found in syslog - try "dmesg | tail" or so.
    rbd: map failed: (6) No such device or address
    错误日志：
        Oct  6 19:18:51 mon1 kernel: libceph: mon0 192.168.2.81:6789 session established
        Oct  6 19:18:51 mon1 kernel: libceph: client24188 fsid 532d1fb6-f5bf-4127-a6e8-7d5f27746557
        Oct  6 19:18:51 mon1 kernel: rbd: image test_image: image uses unsupported features: 0x38
    分析原因：
        [root@mon1 ~]# rbd info test_image
        rbd image 'test_image':
            size 10240 MB in 2560 objects
            order 22 (4096 kB objects)
            block_name_prefix: rbd_data.5e786b8b4567
            format: 2
            features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
            flags:
            
            ### features 的意义 ###
            layering: 支持分层
            striping: 支持条带化 v2
            exclusive-lock: 支持独占锁
            object-map: 支持对象映射（依赖 exclusive-lock ）
            fast-diff: 快速计算差异（依赖 object-map ）
            deep-flatten: 支持快照扁平化操作
            journaling: 支持记录 IO 操作（依赖独占锁）
            ### 遗憾的是CentOS的3.10内核仅支持其中的layering feature，其他feature概不支持。我们需要手动disable这些features ###
    解决办法：
        [root@mon1 ~]# rbd feature disable test_image exclusive-lock, object-map, fast-diff, deep-flatten
        [root@mon1 ~]# rbd map test_image
        /dev/rbd0