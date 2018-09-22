systemd新特性
	系统引导时实现服务并行启动：
	按需激活进程：开始并没有都启动
	系统状态快照：自带
	基于依赖关系定义服务控制逻辑
核心概念：unit
	配置文件进行标识和配置：文件中主要包含了系统服务、监听socket、保存的系统快照以及其它与init相关的特性
	保存至：
		/usr/lib/systemd/system
		/run/systemd/system
		/etc/systemd/system
	Unit的类型：(systemctl --type service)
		service unit: 文件扩展名为.service，用于定义系统服务
		Target unit：文件扩展名为.target，用于模拟实现“运行级别”
		Device unit: 文件扩展名为.device, 用于定义内核识别的设备
		mount unit: 文件扩展名为.mount，定义文件系统挂载点
		Socket unit：文件扩展名为.socket，用于标识进程间通信的socket文件
		snapshot unit: 文件扩展名为.snapshot，管理系统快照
		automount unit: 文件扩展名.automount，文件系统的自动挂载点
		path unit: 文件扩展名.path, 用于定义文件系统中的一个文件或目录
	关键特性：systemd监控这些接口，随时干活，向后兼容sysv init脚本
		基于socket的激活机制：socket与服务程序分离
		基于bus的激活机制：
		基于device的激活机制：
		基于path的激活机制：
		系统快照：保存各unit的当前状态信息于持久存储设备中
	不兼容特性：
		runlevel
		systemctl命令固定不变
		不是由systemd启动的服务,systemctl无法与之通信
	管理系统服务：
		Centos7：service unit
		注意：能兼容早期的服务脚本
		命令：systemctl COMMAND NAME.service

		条件式重启：
				service NAME condrestat（启动再重启，没启动不动它）
				systemctl try-restart NAME.service
		
		查看开机是否启动
				checkconfig --list NAME
				systemctl is-enabled NAME.service
					systemctl enable/disable NAME.service
		查看所有服务：
				systemctl list-units --type service --all
				systemctl list-unit-files --type service
		target units:
			配置文件：.target
			运行级别
				0 --> runlevel0.target, poweroff.target
				1 --> runlevel1.target, rescue.target
				2 --> runlevel2.target, multi-user.target
				3 --> runlevel3.target, multi-user.target
				4 --> runlevel4.target, multi-user.target
					确实没区别
				5 --> runlevel5.target, graphical.target
				6 --> runlevel6.target, reboot.target
			级别切换：
				init N(RHEL5) --> systemctl isolate NAME.target
			获取默认运行级别：
				runlevel --> systemctl list-units --type target
			获取默认运行级别
				/etc/inittab --> systemctl get-default
			修改默认级别：
				/etc/inittab --> systemctl set-default graphical.target
				这个是软链接，手动改也行
			切换至紧急救援模式：
				systemctl rescue
			切换至emergency模式
				systemctl emergency
			其他：
				关机：systemctl halt、systemctl poweroff
				重起：systemctl reboot
				挂起：systemctl suspend
				快照：systemctl hibernate
					下次就会自动载入快照
				快照并挂起：systemctl hybrid-sleep
				禁止开机自起：systemctl mask NAME.service
				取消开机自起：systemctl unmask NAME.service
		# systemd-analyze 显示本次启动系统过程中用户、initrd及kernel所花费的时间
		# systemd-analyze blame 显示每个启动项所花费的时间明细
		# systemd-analyze critical-chain 按时间顺序打印UNIT树
		# systemd-analyze plot > bootplot.svg
		# systemd-analyze dot | dot -Tsvg > systemd.svg 为开机启动过程生成向量图
			需要graphviz软件包
			颜色标识：
				黑色(black)：需要启动相关关联
				深蓝(dark blue)：必须
				深灰(black grey)：需求
				红色(red)：冲突
				绿色(green)：after（之后）