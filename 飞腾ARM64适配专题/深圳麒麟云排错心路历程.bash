问题：客户反馈无法连接麒麟云平台上的一个实例！

分析：
	1. 刚接管云平台，并不熟悉架构情况，肓查了一下，对比所有计算节点的top参数，compute4死过一次机，而且重启过。
	2. 登陆到云平台，发现这个实例是shutdown的状态，第一反应是start实例，一闪而过，始终是shutdown状态，那必须找日志获得有用的信息；
	3. 由于是kolla-ansible部署的openstack，所有的配置文件和日志文件都是自定义在宿主机的相关目录下，并且挂载至相关容器组件，经过大量时间查找，结果如下：
	
	组件相关的配置文件还是在/etc/kolla目录下
	root@controller1:~# ls /etc/kolla/
	admin-openrc.sh   glance-registry  kafka          monasca-notification       neutron-metadata-agent  passwords.yml         toolbox
	cinder-api        globals.yml      keystone       monasca-persister          neutron-server          rabbitmq              TRANS.TBL
	cinder-scheduler  heat-api         kibana         monasca-thresh             nova-api                searchlight-api       zookeeper
	cron              heat-api-cfn     mariadb        neutron-dhcp-agent         nova-conductor          searchlight-listener
	elasticsearch     heat-engine      memcached      neutron-l3-agent           nova-consoleauth        storm-nimbus
	fluentd           horizon          monasca-agent  neutron-lbaas-agent        nova-scheduler          storm-supervisor
	glance-api        influxdb         monasca-api    neutron-linuxbridge-agent  nova-spicehtml5proxy    storm-ui
	root@controller1:~# 
	
	日志目录在/var/lib/docker/volumes/kolla_logs/_data/下
	root@controller1:~# ls /var/lib/docker/volumes/kolla_logs/_data/
	cinder         glance   heat     influxdb  keystone  mariadb  neutron  rabbitmq     storm  zookeeper
	elasticsearch  haproxy  horizon  kafka     kibana    monasca  nova     searchlight  swift
	root@controller1:~# 
	root@compute4:~# ls /var/lib/docker/volumes/kolla_logs/_data/
	cinder  haproxy  libvirt  monasca  neutron  nova  swift
	root@compute4:~# 
	
	4. 查看nova/nova-compute.log
	2019-01-02 19:10:52.553 3169 ERROR oslo_messaging.rpc.dispatcher   File "/usr/lib/python2.7/dist-packages/nova/compute/manager.py", line 2655, in start_instance
	2019-01-02 19:10:52.553 3169 ERROR oslo_messaging.rpc.dispatcher     self._power_on(context, instance)
	2019-01-02 19:10:52.553 3169 ERROR oslo_messaging.rpc.dispatcher   File "/usr/lib/python2.7/dist-packages/nova/compute/manager.py", line 2628, in _power_on
	2019-01-02 19:10:52.553 3169 ERROR oslo_messaging.rpc.dispatcher     block_device_info)
	2019-01-02 19:10:52.553 3169 ERROR oslo_messaging.rpc.dispatcher   File "nova/virt/libvirt/driver.pyx", line 2877, in nova.virt.libvirt.driver.LibvirtDriver.power_on (nova/virt/libvirt/driver.c:56438)
	2019-01-02 19:10:52.553 3169 ERROR oslo_messaging.rpc.dispatcher   File "nova/virt/libvirt/driver.pyx", line 2737, in nova.virt.libvirt.driver.LibvirtDriver._hard_reboot (nova/virt/libvirt/driver.c:54000)
	2019-01-02 19:10:52.553 3169 ERROR oslo_messaging.rpc.dispatcher   File "/usr/lib/python2.7/dist-packages/oslo_utils/fileutils.py", line 42, in ensure_tree
	2019-01-02 19:10:52.553 3169 ERROR oslo_messaging.rpc.dispatcher     os.makedirs(path, mode)
	2019-01-02 19:10:52.553 3169 ERROR oslo_messaging.rpc.dispatcher   File "/usr/lib/python2.7/os.py", line 157, in makedirs
	2019-01-02 19:10:52.553 3169 ERROR oslo_messaging.rpc.dispatcher     mkdir(name, mode)
	2019-01-02 19:10:52.553 3169 ERROR oslo_messaging.rpc.dispatcher OSError: [Errno 13] Permission denied: '/nova/instances/dece3b41-45d3-4bed-aaee-ae219a8e7490'
	
	5. 错误很明显是权限问题，所以找/nova/instances/dece3b41-45d3-4bed-aaee-ae219a8e7490目录，宿主机上根本找不到这个目录，宿主机上的instance目录如下所示：
	root@compute4:/var/lib/docker/volumes/nova_compute/_data# pwd
	/var/lib/docker/volumes/nova_compute/_data
	root@compute4:/var/lib/docker/volumes/nova_compute/_data# ll
	总用量 368
	drwxr-xr-x 10 42436 42436   4096 1月   2 21:27 ./
	drwxr-xr-x  3 root  root    4096 11月  6 20:27 ../
	-rw-------  1 42436 42436     99 1月   2 22:09 .bash_history
	drwxr-xr-x  2 42436 42436   4096 11月  1 12:08 buckets/
	drwxr-xr-x  6 42436 42436   4096 11月  6 20:28 CA/
	drwxr-xr-x  2 42436 42436   4096 11月  1 12:08 images/
	drwxrwxrwx  2 42436 42436   4096 11月  1 12:08 instances/
	drwxr-xr-x  2 42436 42436   4096 11月  1 12:08 keys/
	drwxr-xr-x  2 42436 42436   4096 11月  1 12:08 networks/
	-rw-r-----  1 42436 42436 328704 11月  1 13:44 nova.sqlite
	drwxr-xr-x  2 42436 42436   4096 1月   2 15:18 .ssh/
	drwxr-xr-x  2 42436 42436   4096 11月  7 16:24 tmp/
	root@compute4:/var/lib/docker/volumes/nova_compute/_data# 
	
	6. 可以看到这个instance目录属主属组是42436，查看了一下宿主机并没有42436这个属主属组，权限我已改成777，但是还是报第4步中的错误，最后想到所有组件都是以容器运行的，所以进入相关容器：
	(nova-libvirt)[root@compute4 /]# id 42436
	uid=42436(nova) gid=42436(nova) groups=42436(nova),42400(kolla),42427(qemu)
	(nova-libvirt)[root@compute4 /]#
	(nova-libvirt)[root@compute4 /]# ll -d /nova/instances/
	drwxr-xr-x 8 root root 4096 Jan  2 22:13 /nova/instances//
	(nova-libvirt)[root@compute4 /]# 
		
	7. 发现容器中才有nova这个用户，而且uid和gid正是42436，宿主机instance目录与容器中的instance目录是映射关系，实质上是同一个地址，但是此处的instance目录的属主属组是root，所以会报第4步中的Permission denied；
	8. chown -R nova.nova /nova/instances/改掉这个目录属主属组，再执行第2步中的start，还是一闪而过，错误如下：
	2019-01-02 21:20:46.992 3169 ERROR oslo_messaging.rpc.dispatcher   File "/usr/lib/python2.7/dist-packages/nova/compute/manager.py", line 375, in decorated_function
	2019-01-02 21:20:46.992 3169 ERROR oslo_messaging.rpc.dispatcher     return function(self, context, *args, **kwargs)
	2019-01-02 21:20:46.992 3169 ERROR oslo_messaging.rpc.dispatcher   File "/usr/lib/python2.7/dist-packages/nova/compute/manager.py", line 2655, in start_instance
	2019-01-02 21:20:46.992 3169 ERROR oslo_messaging.rpc.dispatcher     self._power_on(context, instance)
	2019-01-02 21:20:46.992 3169 ERROR oslo_messaging.rpc.dispatcher   File "/usr/lib/python2.7/dist-packages/nova/compute/manager.py", line 2628, in _power_on
	2019-01-02 21:20:46.992 3169 ERROR oslo_messaging.rpc.dispatcher     block_device_info)
	2019-01-02 21:20:46.992 3169 ERROR oslo_messaging.rpc.dispatcher   File "nova/virt/libvirt/driver.pyx", line 2877, in nova.virt.libvirt.driver.LibvirtDriver.power_on (nova/virt/libvirt/driver.c:56438)
	2019-01-02 21:20:46.992 3169 ERROR oslo_messaging.rpc.dispatcher   File "nova/virt/libvirt/driver.pyx", line 2756, in nova.virt.libvirt.driver.LibvirtDriver._hard_reboot (nova/virt/libvirt/driver.c:54229)
	2019-01-02 21:20:46.992 3169 ERROR oslo_messaging.rpc.dispatcher   File "nova/virt/libvirt/driver.pyx", line 7251, in nova.virt.libvirt.driver.LibvirtDriver._get_instance_disk_info (nova/virt/libvirt/driver.c:143381)
	2019-01-02 21:20:46.992 3169 ERROR oslo_messaging.rpc.dispatcher   File "/usr/lib/python2.7/genericpath.py", line 57, in getsize
	2019-01-02 21:20:46.992 3169 ERROR oslo_messaging.rpc.dispatcher     return os.stat(filename).st_size
	2019-01-02 21:20:46.992 3169 ERROR oslo_messaging.rpc.dispatcher OSError: [Errno 2] No such file or directory: '/nova/instances/dece3b41-45d3-4bed-aaee-ae219a8e7490/disk'
	9. 这种错误也很明显，就是没有disk，当然不可能启动实例，非常奇怪，最大的问题不过是compute4重启过，不可能丢掉disk，想到是不是用到了外挂存储，像nfs,lvm,ceph之类的，对比了一下compute3上面的实例，确实用了lvm;
	10. 对比compute3最后发现compute4上的lvm在重启后没有挂载，导致disk不见了，对比compute3是把/dev/vms/vms挂载到了/cloud/vms，所以依葫芦画瓢，记住要重启nova_compute和nova_libvirt，不然目录映射不生效，还是找不到disk;
	11. 挂载lvm后，重启服务后，发现容器中的/nova/instances/的属主属组本身就是nova:nova，第7，8步中的root属主属组是因为没有挂载真正的后端存储，那个instance是假的instance，不是lvm中真正的instance。
	12. 再启动instance都可以成功。
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	