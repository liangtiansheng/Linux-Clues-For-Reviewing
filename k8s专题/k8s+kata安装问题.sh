FAQ
1???????????
---->???????????
	---->libdevmapper-dev ? automake???????
		---->apt install automake ? https://launchpad.net/ubuntu/xenial/arm64/libdevmapper-dev/2:1.02.110-1ubuntu10 ???deb?????

---->root@node3:~# ceph -s
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
	---->ceph?osd???????vespace???? vespace?????sdb?unmount
		---->??ceph-osd??????node???systemctl restart ceph.target

---->??map ceph???,??rbd map hyper/test ?????
	---->systemd-udevd?????
		---->systemctl start systemd-udevd
			---->$ rbd map hyper/test
				 /dev/rbd0
				 $ rbd showmapped
				 id pool  image snap device
				 0  hyper test  -    /dev/rbd0
		
2???????????,??ceph??pgs??????
---->root@node1:~# ceph -s
	cluster 31fd5a3d-00ba-443e-95ad-5392d1a593a7
		health HEALTH_ERR
			1 pgs inconsistent
			3 scrub errors
		monmap e1: 1 mons at {node1=172.16.4.101:6789/0}
			election epoch 8, quorum 0 node1
		osdmap e66: 3 osds: 3 up, 3 in
			flags sortbitwise,require_jewel_osds
		pgmap v3579: 64 pgs, 1 pools, 308 MB data, 167 objects
			60989 MB used, 4965 GB / 5024 GB avail
			63 active+clean
			1 active+clean+inconsistent
	---->????ceph???????1.14pg???
		root@node1:~# ceph health detail
		HEALTH_ERR 1 pgs inconsistent; 3 scrub errors
		pg 1.14 is active+clean+inconsistent, acting [2,3,1]
		3 scrub errors
		---->????
			root@node1:~# ceph pg repair 1.14
			instructing pg 1.14 on osd.2 to repair
			??????
	---->????ceph pg repair?????
	    root@node1:~# ceph health detail 
		HEALTH_ERR 1 pgs inconsistent; 4 scrub errors
		pg 1.26 is active+clean+inconsistent, acting [1,2,3]
		4 scrub errors
		root@node1:~# 
		---->????????pg repair???????https://ceph.com/geen-categorie/ceph-manually-repair-object/
		bash
		$ sudo ceph health detail
		HEALTH_ERR 1 pgs inconsistent; 2 scrub errors
		pg 17.1c1 is active+clean+inconsistent, acting [21,25,30]
		2 scrub errors
		
		Ok, so the problematic PG is 17.1c1 and is acting on OSD 21, 25 and 30.

		You can always try to run ceph pg repair 17.1c1 and check if this will fix your issue.
		Sometime it does, something it does not and you need to dig further.
		
		Find the problem
		In order to get the root cause, we need to dive into the OSD log files.
		A simple grep -Hn 'ERR' /var/log/ceph/ceph-osd.21.log, note that if logs rotated you might have to use zgrep instead.

		This gives us the following root cause:
		log [ERR] : 17.1c1 shard 21: soid 58bcc1c1/rb.0.90213.238e1f29.00000001232d/head//17 digest 0 != known digest 3062795895
		log [ERR] : 17.1c1 shard 25: soid 58bcc1c1/rb.0.90213.238e1f29.00000001232d/head//17 digest 0 != known digest 3062795895
		What is telling this log?
		Well it says that the object digest should be 3062795895 and is actually 0.
		
		Find the object
		Now we have to dive into OSD 21 directory, thanks to the information we have it is pretty straightforward.

		What do we know?

		Problematic PG: 17.1c1
		OSD number
		Object name: rb.0.90213.238e1f29.00000001232d
		
		At this stage we search the object:
		bash
		$ sudo find /var/lib/ceph/osd/ceph-21/current/17.1c1_head/ -name 'rb.0.90213.238e1f29.00000001232d*' -ls
		671193536 4096 -rw-r--r-- 1 root root 4194304 Feb 14 01:05 /var/lib/ceph/osd/ceph-21/current/17.1c1_head/DIR_1/DIR_C/DIR_1/DIR_C/rb.0.90213.238e1f29.00000001232d__head_5.....
		
		Now there are a couple of other things you can check:

		Look at the size of each objects on every systems
		Look at the MD5 of each objects on every systems
		Then compare all of them to find the bad object.	
		
		Fix the problem
		Just move the object away ?? with the following:

		stop the OSD that has the wrong object responsible for that PG
		flush the journal (ceph-osd -i <id> --flush-journal)
		move the bad object to another location
		start the OSD again
		call ceph pg repair 17.1c1
		
		It might look a bit rough to delete an object but in the end it?s job Ceph?s job to do that.
		Of course the above works well when you have 3 replicas when it is easier for Ceph to compare two versions against another one.
		A situation with 2 replicas can be a bit different, Ceph might not be able to solve this conflict and the problem could persist.
		So a simple trick could be to chose the latest version of the object, set the noout flag on the cluster, stop the OSD that has a wrong version.
		Wait a bit, start the OSD again and unset the noout flag.
		The cluster should sync up the good version of the object to OSD that had a wrong version.
	---->?????????????????
		ceph osd pool set hyper size 1
		ceph osd pool set hyper min_size 1
		ceph pg repaire 1.26
		ceph osd pool set hyper size 3
		ceph osd pool set hyper min_size 2
		ceph pg repaire 1.26
		
---->????pod???
	 kubelet?
	 Orphaned pod "4db449f0-4eaf-11e8-94ab-90b8d042b91a" found, but volume paths are still present on disk : There were a total of 3 errors similar to this. Turn up verbosity to see them.
	---->rm -rf /var/lib/kubelet/pods/4db449f0-4eaf-11e8-94ab-90b8d042b91a/volumes/rook.io~rook/pvc-4d3b9c2c-4eaf-11e8-b497-90b8d0abcd2b/
		 ?etcd???pod
		 export ETCDCTL_API=3
		 alias etcdctl="etcdctl --endpoints=https://109.105.30.155:2379 --cacert=/etc/etcd/ssl/etcd-ca.pem --cert=/etc/etcd/ssl/etcd.pem --key=/etc/etcd/ssl/etcd-key.pem"
		 etcdctl del /registry/pods/default/wordpress-consul-5b88f4868-4ss8x
		 
---->kubelet???????ImageFsInfo from image service failed
	---->??????ImageFS API is not supported in frakti,?????? https://github.com/kubernetes/frakti/issues/304
	
---->mysql????????????mariadb???????????arm64
	---->root@node3:~# docker run --rm mplatform/mquery mariadb
		Unable to find image 'mplatform/mquery:latest' locally
		latest: Pulling from mplatform/mquery
		db6020507de3: Pull complete 
		713cdc222639: Pull complete 
		Digest: sha256:e15189e3d6fbcee8a6ad2ef04c1ec80420ab0fdcf0d70408c0e914af80dfb107
		Status: Downloaded newer image for mplatform/mquery:latest
		Image: mariadb
		 * Manifest List: Yes
		 * Supported platforms:
		   - linux/amd64
		   - linux/arm64/v8
		   - linux/ppc64le

		root@node3:~# docker run --rm mplatform/mquery mariadb:10.1.14
		Image: mariadb:10.1.14
		 * Manifest List: No
		 * Supports: amd64/linux
	---->root@node3:~# docker run --rm mplatform/mquery mysql
		Image: mysql
		 * Manifest List: Yes
		 * Supported platforms:
		   - linux/amd64

---->mysql????????pod???????pod???container???????pod??/var/log/mysql/error.log?????innodb??????????memory??
	---->??pod??????????
		---->frakti????64M?hyperd??128M?????????pod ?128M?????????????????/lib/systemd/system/xxx.service????
			root@node3:~# ps aux | grep qemu
			root      4388  0.0  0.0   9368   576 pts/0    S+   19:42   0:00 grep qemu
			root     24451  5.5  0.5 3121012 340504 ?      Sl   18:05   5:26 /usr/bin/qemu-system-aarch64 -machine virt,accel=kvm,gic-version=host,usb=off -global kvm-pit.lost_tick_policy=discard -cpu host -kernel /var/lib/hyper/kernel -initrd /var/lib/hyper/hyper-initrd.img -append console=ttyAMA0 panic=1 iommu=no -realtime mlock=off -no-user-config -nodefaults -rtc base=utc,clock=host,driftfix=slew -no-reboot -display none -boot strict=on -m size=1024,slots=1,maxmem=32768M -smp cpus=1,maxcpus=8 -device pci-bridge,chassis_nr=1,id=pci.0 -qmp unix:/var/run/hyper/vm-lwVFDlibDh/qmp.sock,server,nowait -serial unix:/var/run/hyper/vm-lwVFDlibDh/console.sock,server,nowait -device virtio-serial-pci,id=virtio-serial0,bus=pci.0,addr=0x2 -device virtio-scsi-pci,id=scsi0,bus=pci.0,addr=0x3 -chardev socket,id=charch0,path=/var/run/hyper/vm-lwVFDlibDh/hyper.sock,server,nowait -device virtserialport,bus=virtio-serial0.0,nr=1,chardev=charch0,id=channel0,name=sh.hyper.channel.0 -chardev socket,id=charch1,path=/var/run/hyper/vm-lwVFDlibDh/tty.sock,server,nowait -device virtserialport,bus=virtio-serial0.0,nr=2,chardev=charch1,id=channel1,name=sh.hyper.channel.1 -fsdev local,id=virtio9p,path=/var/run/hyper/vm-lwVFDlibDh/share_dir,security_model=none -device virtio-9p-pci,fsdev=virtio9p,mount_tag=share_dir -daemonize -pidfile /var/run/hyper/vm-lwVFDlibDh/pidfile -D /var/log/hyper/qemu/vm-lwVFDlibD.log
			
			root@node3:~# ps aux | grep frakti
			root      1643  2.0  0.1 1260016 103920 ?      Ssl  10:01  11:43 /usr/bin/frakti --v=3 --log-dir=/var/log/frakti --logtostderr=false --cgroup-driver=cgroupfs --listen=/var/run/frakti.sock --streaming-server-addr=172.16.4.103 --hyper-endpoint=127.0.0.1:22318
			root      2287  3.2  0.3 2197300 200756 ?      Ssl  10:01  18:50 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --cgroup-driver=cgroupfs --cni-bin-dir=/opt/cni/bin --cni-conf-dir=/etc/cni/net.d --network-plugin=cni --container-runtime=remote --container-runtime-endpoint=/var/run/frakti.sock --feature-gates=AllAlpha=true --enable-controller-attach-detach=false --node-ip=172.16.4.103 --logtostderr=false --log-dir=/var/log/kubernetes/ --v=3 --max-pods=2000 --system-reserved=memory=1G

			root@node3:~# ps aux | grep hyperd
			root      1662  0.9  0.1 1764860 113268 ?      Ssl  10:01   5:31 /usr/bin/hyperd --log_dir=/var/log/hyper
			---->????mariadb????????????????
				????????
				1. ????????/var/run/mysqld/ld/mysqld.sock???????????????????my.cnf, ?f, ?/var/run/mysqld??/var/lib/mysql? /var/lib/mysql??rdb?volume
				2. ??????????Cannott init tc log?????????my.cnf???f???log_bin=ON
				???????????????my.cnf,?????build?mariadb?Dockerfile
				????build mariadb???Dockerfile????????

				https://github.com/Jimmy-Xu/mariadb/tree/patch-for-phytium/10.3/1
				https://github.com/Jimmy-Xu/mariadb/tree/patch-for-phytium/10.3/2
				?????dockerhub,? hyperhq/mariadb-arm64v8:10.3
			
---->??k8s+kata+ceph+mysql??????
---->root@node1:~# mysqlslap -a -c 50,100,150 --auto-generate-sql-load-type=mixed --create-schema=hellodb --iterations=3 --engine=innodb -
	h 172.16.4.101 -P 30006 -u root -pEnter password: 
	mysqlslap: Error when connecting to server: 1049 Unknown database 'hellodb'
	mysqlslap: Error when connecting to server: 1049 Unknown database 'hellodb'
	mysqlslap: Error when connecting to server: 1049 Unknown database 'hellodb'
	Benchmark
		Running for engine innodb
		Average number of seconds to run all queries: 1.468 seconds
		Minimum number of seconds to run all queries: 1.223 seconds
		Maximum number of seconds to run all queries: 1.679 seconds
		Number of clients running queries: 50
		Average number of queries per client: 0

	mysqlslap: Error when connecting to server: 1049 Unknown database 'hellodb'
	mysqlslap: Error when connecting to server: 1049 Unknown database 'hellodb'
	mysqlslap: Error when connecting to server: 1049 Unknown database 'hellodb'
	mysqlslap: Error when connecting to server: 1049 Unknown database 'hellodb'
	Benchmark
		Running for engine innodb
		Average number of seconds to run all queries: 1.970 seconds
		Minimum number of seconds to run all queries: 1.656 seconds
		Maximum number of seconds to run all queries: 2.433 seconds
		Number of clients running queries: 100
		Average number of queries per client: 0

	mysqlslap: Error when connecting to server: 1049 Unknown database 'hellodb'
	mysqlslap: Error when connecting to server: 1049 Unknown database 'hellodb'
	mysqlslap: Error when connecting to server: 1049 Unknown database 'hellodb'
	mysqlslap: Error when connecting to server: 1040 Too many connections
	mysqlslap: Error when connecting to server: 1040 Too many connections
	mysqlslap: Error when connecting to server: 1049 Unknown database 'hellodb'
	mysqlslap: Error when connecting to server: 1049 Unknown database 'hellodb'
	mysqlslap: Error when connecting to server: 1049 Unknown database 'hellodb'
	mysqlslap: Error when connecting to server: 1049 Unknown database 'hellodb'	

	Benchmark
		Running for engine innodb
		Average number of seconds to run all queries: 1.865 seconds
		Minimum number of seconds to run all queries: 1.707 seconds
		Maximum number of seconds to run all queries: 2.127 seconds
		Number of clients running queries: 150
		Average number of queries per client: 0
	?????mysql pod?????????????????????????

---->?kubelet????????????/etc/default/kubelet??????????????????/etc/systemd/system/kubelet.service.d/05-frakti.conf?????
    ---->??????????kubelet????????????,??kubelet???ps aux | grep kubelet??????????????????????????,systemd????????????????
        root@compute1:~# cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf 
        # Note: This dropin only works with kubeadm and kubelet v1.11+
        [Service]
        Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
        Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
        # This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
        EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
        # This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
        # the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
        EnvironmentFile=-/etc/default/kubelet
        ExecStart=
        ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS
        root@compute1:~# 
        ---->????kata????????????????api-->kubelet(????????frakti)-->frakti(?????????)-->hyperd-->qemu-kvm(/etc/hyper/config???)-->hyperctl pull images               
			
			