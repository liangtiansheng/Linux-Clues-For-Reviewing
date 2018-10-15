launch instance:
	1. nova.conf-->compute_driver=Libvirt.LibvirtDriver 
	2. 定义flavor(cpu,disk,ramdisk)
	3. nova-api处理请求-->MQ-->过滤器filter,权重值-->决定instance着陆在哪个计算节点--MQ-->nova-compute--hypervisor-->生成instance
	nova-compute创建instance大致分为四步：
		1.为instance准备资源
		2.创建instance镜像文件(instance的目录由nova.conf中指定路径，从glance下载image作为backing_file，再创建镜像)
		3.创建instance XML文件(XML也是保存在instance下，叫libvirt.xml)
		4.创建虚拟网络并启动虚拟机

日志格式：时间戳-->日志等级-->代码模块-->RequestID-->日志内容-->源码位置(RequestID是可以跨主机的，同一种操作下的各组件日志RequestID可能相同，定位错误有用)

instance操作：
	1.stop和start：分别是关闭和启动instance
	2.terminate：会关闭instance并删除镜像文件，同时释放网络资源
	3.pause和suspend：都是通过resume恢复，pause对应的操作叫unpause，suspend对应操作就是resume
	4.snapshot：将image全量备份到snapshot-->保存至glance中
		暂停instance-->对Instance镜像文件做快照--恢复instance-->上传snapshot至glance中
	5.rebuild：关闭instance-->下载新image并准备instance镜像文件-->启动instance
	6.shelve：
		是suspend的升级（会将系统预留资源去掉）
		通过snapshot来做
		还会删除instance目录
	7.unshelve:
		当时shelve把instance的image保存在glance中，操作跟launch instance非常类似
	8.migrate:
		实际上是特殊的resize
		在调度过程中同样会出现调到本节点这种情况，但是会抛出UnabledToMigrateToSelf异常，再调度就会有RetryFilter过滤掉源节点
		nova-api-->nova-scheduler-->源节点ssh到目标节点在instance目录下touch临时文件-->失败说明没有共享存储-->创建instance目录-->关闭instance-->将instance scp 到目标节点
								
								   Confirm-->源节点删除instance同时hypervisor删除instance
								  /
		-->目标节点launch instance
								  \ 
								   Revirt-->目标节点删除instance同时hypervisor删除instance-->源节点重启instance
		注意：这个过程要用到ssh,scp到对方主机，所以两主机间要可以让nova基于密钥通信
	9.resize:
		分两种情况：
			1.目标节点与源节点不同，那就跟前面的migrate一样，只是用了新的flavor
			2.调度到同一节点：
				准备新flavor-->关闭instance-->创建instance镜像文件-->将Instance目录备份命名为_resize(用作revirt)-->创建instance XML-->准备虚拟网络
								Confirm-->删除计算节点上的instance目录_resize
							   /
				-->启动instance
							   \
							    Revirt-->关闭instance-->从_resize目录恢复重启instance
	10.Live Migrate:
		前提条件：
			1.源目标cpu一致，Libvirt版本一致
			2.基于主机名通信
			3.nova.conf指明在线迁移TCP协议
			4.instance用config.drive保存其matadata，也要迁移到目标节点，目前libvirt只支持迁移vfat类型的config.drive，所以要在nova.conf中指明launch instance时创建vfat类型的config.driver
				"config_drive_format=vfat"
			5.源和目标节点libvirt tcp远程监听服务得打开，配置两个文件
				/etc/default/libvirt-bin
					start_libvirtd="yes"
					libvirtd_opts="-d -l"
				/etc/libvirt/libvirtd.conf
					listen_tls=0
					listen_tcp=1
					unix_sock_group="libvirtd"
					unix_sock_ro_perms="0777"
					unix_sock_rw_perms="0777"
					auth_unix_ro="none"
					auth_unix_rw="none"
					auth_tcp="none"
				service libvirt-bin restart
				热迁移要指明目标节点(没有scheduler)
					Block Migration(不共享)
						1.目标节点执行迁移前的准备工作，首先将Instance数据迁移过来主要包括镜像文件，虚拟网络等资源
						2.源节点启动迁移操作，暂停instance
						3.在目标节点上resume instance
						4.源节点执行迁移后的处理，删除instance
						5.目标节点上执行迁移后处理工作，创建XML，在hypervisor中定义Instance，使下次能正常启动
					Migration(共享)
						模拟共享：
							controller /var/lib/nova/instance作为NFS共享
							compute1 将/var/lib/nova/instance挂载到相同的/var/lib/nova/instance下
						1.Dashboard上不能再勾选Block Migration
						2.因为共享instance目录，所以不用迁移镜像文件，也不用删除
						3.只是instance内存状态从源节点传输到目标节点，整个迁移比Block Migration快得多
	11.Evacuate：
		前提instance的镜像文件必须放在共享存储上，比如instance c2在compute1上挂掉
		在controller上执行 nova evacuate c2 --on-share-storage
		evacuate通过rebuild操作实现，因为evacuate是用共享存储上instance的镜像文件重新创建虚机
		rebuild instance-->nova-scheduler-->nova-compute-->为instance准备资源-->使用共享镜像文件-->启动instance
		
	12.Rescue/unrescue:
		Rescue用指定的image作为启动盘引导instance将instance本身的系统盘作为第二个磁盘挂载到操作系统上
		nova rescue c2-->关闭instance-->通过image创建新的引导盘，命名为disk.rescue-->启动instance-->virsh edit查看c2，disk.rescue变成vda，真正启动盘disk变成vdb
		-->登陆instance，修复vdb-->nova unrescue c2-->从原启动盘重新启动instance
		
cinder:两种存储方式
	1.Block storage(协议有SAS,SCSI,SAN,iSCSI)
	2.文件系统(NAS,NFS,CEPH)
	一般情况，volume-api在控制节点上，cinder-volume在存储节点上，volume-provider可以独立存在于某个节点
	
	LVM:
		cinder.conf中volume_driver=lvm.LVMVolumeDriver
		cinder-volume会用lvs,vgs实时报告存储资源给cinder
		scheduler会根据这些信息，在接收api请求后定位要创建存储的节
			filter-->weighting(同nova)
				AvailabilityZoneFilter：为了提高容灾和隔离服务，将存储节点和计算节点划分到不同的AvailabilityZone中，默认有一个Nova的Zone，所有节点初始在nova中
				CapacityFilter：过滤掉大小不满足要求的存储节点，volume-type指定Capabilities的类型(cinder.conf中设置volume_backend_name，其作用是为存储节点的volume provider命名，这样capabilities通过volume type筛选指定的volume provider)
                CapabilitysFilter: 不同类型provider有自己的特性(Capabilities)，比如有的支技thin provisioning
                    cinder用"Volume Type"指定需要的Capabilities, "Volume Type"可以根据需要定义若干Capabilities
                        Admin-->System-->Volume通过"Volume Type"的"Extra Specs"定义Capabilities，"Extra Specs"是用Key-Value的开式来定义，不同volume provider支持的extra specs不同，可参考官方文档
                            默认"Extra Specs"只有一个"volume_backend_name"，这是最重要也是必须要有的"Extra Specs"
                                cinder.conf中的volume_backend_name是为存储节点的"Volume Provider"命名，这样CapabilitiesFilter就可以通过"Volume Type"的"volume_backend_name"筛选出指定的"Volume Provider"
        cinder-api:
			启动flow(工作流)，有若干tasks,ExtractVolumeRequestTask,QuotaReserveTask,EntryCreateTask,QuotaCommitTask,VolumeCastTask
			这些tasks都有"PENDING","RUNNING","SUCCESS"三个阶段
		cinder-scheduler:
			通过Flow Volume_Create_Scheduler执行调度
			FLOW依次执行ExtractSchedulerSpecTask和SchedulerCreateVolumeTask
			SchedulerCreateVolumeTask主要做filter和weighting
			经过AvailabilityZoneFilter,CapacityFilter,CapabilitiesFilter和CapacityWeigher的层层筛选
		Cinder-volume：
			通过flow volume-create-manager执行Tasks依次ExtractVolumeRefTask,OnfailureReschedulerTask,ExtractVolumeSpecTask,NotifyVolumeActionTask为Volume创建做准备
			接下来CreateVolumeFromSpecTask执行volume创建，命令是lvcreate
			最后CreateVolumeOnFinishTask完成扫尾，volume_create_manager结束
		Attach：
			api接受请求预处理-->MQ-->cinder-volume-->tgtadm --lld iscsi --op show --mode target 初始化并export出来-->nova-compute执行iscsiadm new,update,login,rescan,访问target上的volume
			-->计算节点更新instance XML文件，将volume映射给Instance
			
多网卡bounding
	mode=0：平衡负载模式，有自动备援，但需要”Switch”支援及设定。
		仅仅设置这里optionsbond0 miimon=100 mode=0还不够
		mode 0下bond所绑定的网卡的IP都被修改成相同的mac地址，同一交换机下arp表里这个mac地址对应多个端口，所以交换机两个端口要做聚合（cisco称为 ethernetchannel，foundry称为portgroup）
		另外一个解决办法是，两个网卡接入不同的交换机

	mode=1：自动备援模式，其中一条线若断线，其他线路将会自动备援。

	mode=6：平衡负载模式，有自动备援，不必”Switch”支援及设定。
		mode6模式下无需配置交换机，因为做bonding的这两块网卡是使用不同的MAC地址。				
				
				
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
								
								
								
								
								