puppet(1):
	
	OS Provisioning(PXE, Cobbler)
	OS Configuration(ansible, puppet, saltstack, chef, cfengine)
	Command and Control(func, ansible, fabric)

	puppet：IT基础设施自动化管理工具；
		整个生命周期；
			provisioning
			configuration
			orchestration
			reporting

	www.puppetlabs.com

		作者：Luke Kanies, PuppetLabs

			2005, 0.2 --> 0.24.x --> 0.25.x --> 0.26.x(2.6.x) --> 2.7.x --> 3.0

	puppet: agent
		master/agent
			master：puppet server
			agent: 
				真正执行相应管理操作的核心部件；周期性地去master请求与自己相关的配置；

	puppet的工作模式：
		声明性、基于模型；
			定义：使用puppet配置语言定义基础配置信息；
			模拟：模拟测试运行；
			强制：强制当前与定义的目标状态保持一致；
			报告：通过puppet api将执行结果发送给接收者；

	puppet有三个层次：
		配置语言
		事务层
		资源抽象层
			资源类型：例如用户、组、文件、服务、cron任务等等；
			属性及状态 与 其实现方式分离；
			期望状态

	puppet的核心组件：资源
		资源清单：manifests
		资源清单及清单中的资源定义的所依赖文件、模板等数据按特定结构组织起即为“模块”

	安装：
		agent: puppet, facter
		master: puppet-server

	puppet：
		命令的用法格式：
			Usage: puppet <subcommand> [options] <action> [options]

		获取所支持的所有的资源类型：
			# puppet describe -l

			# puppet describe RESOURCE_TYPE

	定义资源：
		type {'title':
			attribute1	=> value1,
			attribute2	=> value2,
		}

			type必须小写；title在同一类型下必须惟一；

		常用资源类型：
			user, group, file, package, service, exec, cron, notify

		group:
			管理组资源
			常用属性：
				name: 组名，NameVar
				gid：GID
				system: true, false
				ensure: present, absent
				members：组内成员

		user：
			管理用户
			常用属性：
				commet：注释信息
				ensure：present, absent
				expiry：过期期限；
				gid：基本组id
				groups：附加组
				home：家目录
				shell：默认shell
				name: NameVar
				system：是否为系统用户，true|false
				uid: UID
				password：

		file：
			管理文件及其内容、从属关系以及权限；内容可通过content属性直接给出，也可通过source属性根据远程服务器路径下载生成；
			指明文件内容来源：
				content：直接给出文件内容，支持\n, \t；
				source：从指定位置下载文件；
				ensure：file, directory, link, present, absent
			常用属性：
				force:强制运行，可用值yes, no, true, false
				group：属组
				owner：属主
				mode：权限，支持八进制格式权限，以及u,g,o的赋权方式
				path：目标路径；
				source：源文件路径；可以是本地文件路径（单机模型），也可以使用puppet:///modules/module_name/file_name；
				target：当ensure为“link”时，target表示path指向的文件是一个符号链接文件，其目标为此target属性所指向的路径；此时content及source属性自动失效；

					file{'/tmp/mydir':
					        ensure  => directory,
					}

					file{'/tmp/puppet.file':
					        content => 'puppet testing\nsecond line.',
					        ensure  => file,
					        owner   => 'centos',
					        group   => 'distro',
					        mode    => '0400',
					}

					file{'/tmp/fstab.puppet':
					        source  => '/etc/fstab',
					        ensure  => file,
					}

					file{'/tmp/puppet.link':
					        ensure  => link,
					        target  => '/tmp/puppet.file',
					}	
					
		exec：
			运行一外部命令；命令应该具有“幂等性”；
				幂等性：
					1、命令本身具有	幂等性；
					2、资源有onlyif, unless,creates等属性以实现命令的条件式运行；
					3、资源有refreshonly属性，以实现只有订阅的资源发生变化时才执行；

			command：运行的命令；NameVar；
			creates：此属性指定的文件不存在时才执行此命令；	
			cwd：在此属性指定的路径下运行命令；
			user: 以指定的用户身份运行命令；
			group: 指定组；
			onlyif：给定一个测试命令；仅在此命令执行成功（返回状态码为0）时才运行command指定的命令；
			unless：给定一个测试命令；仅在此命令执行失败（返回状态码不为0）时才运行command指定的命令；
			refresh：接受到其它资源发来的refresh通知时，默认是重新执行exec定义的command，refresh属性可改变这种行为，即可指定仅在refresh时运行的命令；
			refreshonly：仅在收到refresh通知，才运行此资源；
			returns：期望的状态返回值，返回非此值时表示命令执行失败；
			tries：尝试执行的次数；
			timeout：超时时长；
			path：指明命令搜索路径，其功能类型PATH环境变量；其值通常为列表['path1', 'path2', ...]；如果不定义此属性，则必须给定命令的绝对路径；

				exec{'/usr/sbin/modprobe ext4':
					user	=> root,
					group	=> root,
					refresh	=> '/usr/sbin/modprobe -r ext4 && /usr/sbin/modprobe ext4',
					timeout	=> 5,
					tries	=> 2,
				}

				exec{'/bin/echo mageedu > /tmp/hello.txt':
					user	=> root,
					group	=> root,
					creates	=> '/tmp/hello.txt',
				}

				exec{'/bin/echo mageedu > /tmp/hello2.txt':
					user	=> root,
					group	=> root,
					unless	=> '/usr/bin/test -e /tmp/hello2.txt',
				}

		notify：
			核心属性：
				message：要发送的消息的内容；NameVar

				
				notify{"hello there.": }

		cron：
			管理cron任务；
			常用属性：
				ensure：present, absent
				command：要运行的job；
				hour:
				minute:
				month:
				monthday：
				weekday:
				name:
				user：运行的用户
				environment：运行时的环境变量；

				cron{"sync time":
					command	=> '/usr/sbin/ntpdate 172.16.0.1 &> /dev/null',
					minute	=> '*/10',
					ensure	=> present,
				}	


puppet(2)
	
		package：
			管理程序包；
			常用属性：
				ensure: installed, latest, VERSION(2.3.1-2.el7)，present, absent
				name：程序包名称；
				source：包来源；可以本地文件路径或URL；
				provider：rpm

			package{'zsh':
				ensure	=> latest,
			}

			package{'jdk':
				ensure	=> installed,
				source	=> '/usr/local/src/jdk-8u25-linux-x64.rpm',
				provider => rpm,
			}		

		service：
			管理服务；
			常用属性：
				enable：是否开机自动启动，true|false；
				ensure：启动(running), 停止(stopped)；
				hasrestart：是否支持restart参数；
				hasstatus：是否支持status参数；
				name：服务名称，NameVar
				path：脚本查找路径；
				pattern：用于搜索此服务相关的进程的模式；当脚本不支持restart/status时，用于确定服务是否处于运行状态；
				restart：用于执行“重启”的命令；
				start：
				stop:
				status：

				package{'nginx':
					ensure	=> latest,
				}

				service{'nginx':
					ensure	=> running,
					enable	=> true,
					hasrestart => true,
					hasstatus => true,
					restart	=> 'systemctl reload nginx.service',
				}			

	特殊属性：Metaparameters

		资源引用：
			Type['title']

		依赖关系
			被依赖的资源中使用：before
			依赖其它资源的资源：require
			->：链式依赖

		通知关系
			被依赖的资源中使用：notify
			监听其它资源的资源：subscribe
			~>：链式通知

	puppet的变量及其作用域
		变量名均以$开头，赋值符号=; 任何非正则表达式类型的数据均可赋值给变量；

		作用域：定义代码的生效范围，以实现代码间隔离；
			仅能隔离：变量，资源的默认属性；
			不能隔离：资源的名称，及引用；

			每个变量两种引用路径：
				相对路径
				绝对路径：$::scope::scope::variable

			变量的赋值符号：
				=
				+=：追加赋值

			数据类型：
				布尔型：ture, false
				undef：未声明
				字符型：可以不用引号，支持单引号(强引用)，双引号(弱引用)
				数值型：整数和浮点数；
				数组：[item1, item2, ...]，元素可为任意可用数据类型，包括数组和hash; 索引从0开始，还可以使用负数；
				hash：{key => value, key => value,...}, 键为字符串，而值可以是任意数据类型；

				正则表达式：
					非标准数据类型，不能赋值给变量；

						语法结构：
							(?<ENABLED OPTION>:<SUBPATTERN>)
							(?-<DISABLED OPTION>:<SUBPATTERN>)

							OPTION:
								i: 忽略字符大小写；
								m：把.当换行符；
								x：忽略模式中的空白和注释；

				表达式：
					比较操作符：==, !=, <, <=, >, >=, =~, !~, in
					逻辑操作符：and, or, !
					算术操作符：+, -, *, /, %, >>, <<
					
		puppet中变量的种类：
			自定义变量
			facter变量：可直接引用；
				查看puppet支持的各facts：
					facter -p
			内置变量：
				客户端内置：
					$clientcert
					$clientversion
				服务器端内置
					$servername
					$serverip
					$serverversion
					$module_name

	条件判断：
		if, case, selector, unless

		if语句：
			if CONDITION {
				...
			}

			if CONDITION {
				...
			} 
			else {
				...
			}

			if $processorcount>1 {
				notice("SMP Host.")
			} else {
				notice("Poor Guy.")
			}		

			CONDITION的用法：
				1、比较表达式
				2、变量引用
				3、有返回值函数调用

			if $operatingsystem =~ /^(?i-mx:(centos|redhat|fedora|ubuntu))/ {
				notice("Welcome to $1 distribution linux.")
			}

		case语句：

			case CONTROL_EXPRESSION {
				case1, case2: { statement }
				case3, case4, case5: { statement }
				...
				default: { statment }
			}

			CONTROL_EXPRESSION：表达式、变量、函数（有返回值）；
			case：
				字符串，变量，有返回值函数，模式，default

		selector语句：

			类似于case，但分支的作用不在于执行代码片断，而是返回一个直接值；

			CONTROL_VARIABLE ? {
				case1 => value1,
				case2 => value2,
				...
				default => valueN
			}

			CONTROL_VARIABLE: 变量、有返回值的函数；但不能是表达式；
			case：直接值(需要带引号)、变量、有返回值的函数、正则表达式模式或default

	类：class
		用于公共目的的一组资源，是命名的代码块；创建后可在puppet全局进行调用；类可以被继承；

		语法格式：
			class class_name {
				...puppet code...
			}

			注意：类名只能包含小写字母、数字和下载线，且必须以小写字母开头；

			class nginx {
			    $webserver=nginx

			    package{$webserver:
					ensure	=> latest,
			    }

			    file{'/etc/nginx/nginx.conf':
					ensure	=> file,
					source	=> '/root/modules/nginx/files/nginx.conf',
					require	=> Package['nginx'],
					notify	=> Service['nginx'],
			    }

			    service{'nginx':
					ensure	=> running,
					enable	=> true,
					hasrestart => true,
					hasstatus => true,
					#restart	=> 'systemctl reload nginx.service',
					require	=> [ Package['nginx'], File['/etc/nginx/nginx.conf'] ],
			    }
			}	

		注意：类在声明后方才执行；

		类声明的方式1：
			include class_name, class_name, ...

		定义能接受参数的类：
			class class_name($arg1='value1', $arg2='value2') {
				... puppet code ...
			}

		类声明方式2：
			class{'class_name':
				arg1 => value,
				arg2 => value,
			}

			示例：
				class nginx($webserver='nginx') {

				    package{$webserver:
				        ensure  => latest,
				    }

				    file{'/etc/nginx/nginx.conf':
				        ensure  => file,
				        source  => '/root/modules/nginx/files/nginx.conf',
				        require => Package['nginx'],
				        notify  => Service['nginx'],
				    }

				    service{'nginx':
				        ensure  => running,
				        enable  => true,
				        hasrestart => true,
				        hasstatus => true,
				        #restart        => 'systemctl reload nginx.service',
				        require => [ Package['nginx'], File['/etc/nginx/nginx.conf'] ],
				    }
				}

				class{'nginx':
				        webserver => 'tengine',
				}

		类继承：

			定义方式：
				class base_class {
					... puppet code ...
				}

				class base_class::class_name inherits base_class {
					... puppet code ...
				}

			作用：继承一个已有的类，并实现覆盖资源属性，或向资源属性追加额外值；
				=>, +>

			类继承时：
				(1) 声名子类时，其基类会被自动首先声明；
				(2) 基类成为了子类的父作用域，基类中的变量和属性默认值会被子类复制一份；
				(3) 子类可以覆盖父类中同一资源的相同属性的值；

				class nginx {
					package{'nginx':
						ensure	=> latest,
						name => nginx,
					} ->
					
					service{'nginx':
						enable	=> true,
						ensure	=> running,
						hasrestart => true,
						hasstatus => true,
						restart => 'service nginx reload',
					}
				}

				class nginx::webserver inherits nginx {
					file{'/etc/nginx/nginx.conf':
						source => '/root/modules/nginx/files/nginx_web.conf',
						ensure	=> file,
						notify 	=> Service['nginx'],
					}
				}

				class nginx::proxy inherits nginx {
					file{'/etc/nginx/nginx.conf':
						source => '/root/modules/nginx/files/nginx_proxy.conf',
						ensure	=> file,
						notify 	=> Service['nginx'],
					}
				}			


			在子类中覆盖父类中已经定的资源的属性值：
				class nginx::webserver inherits nginx {
				        Package['nginx'] {
				                name => tengine,
				        }

				        file{'/etc/nginx/nginx.conf':
				                source => '/root/modules/nginx/files/nginx_web.conf',
				                ensure  => file,
				                notify  => Service['nginx'],
				        }
				}

	模板：基于ERB模板语言，在静态文件中使用变量等编程元素生成适用于多种不同的环境的文本文件（配置文件）；Embedded RuBy, 用于实现在文本文件中嵌入ruby代码，原来的文本信息不会被改变，但ruby代码会被执行，执行结果将直接替换原来代码；

		<%= Ruby Expression %>：替换为表达式的值；
		<% Ruby Expression %>：仅执行代码，而不替换；
		<%# comment %>：文本注释；
		<%%：输出为<%
		%%>：输出为%>
		<%- Ruby code %>：忽略空白字符；
		<% Ruby code -%>：忽略空白行；

		在模板中可以使用变量，包括puppet的任意可用变量，但变量名以@字符开头；

		条件判断：
			<% if CONDITION -%>
				some text
			<% end %>

			<% if CONDITION -%>
				some text
			<% else %>
				some other text
			<% end %>

		迭代：
			<% @ArrayName.echo do | Variable_Name | -%>
				some text with <%= Variable_Name %>
			<% end %>


		file{'/etc/nginx/nginx.conf':
			content => template('/root/modules/nginx/files/nginx_proxy.conf'),
			ensure	=> file,
			notify 	=> Service['nginx'],
		}

	模块：
		module_name/
			manifests/
				init.pp：至少应该包含一个与当前模块名称同名类；
			files：静态文件；puppet:///modules/module_name/file_name;
			templates：模板文件目录；template('module_name/template_file_name')；
			lib：插件目录；
			tests：当前模块的使用帮助文件及示例文件；
			spec：类似于tests目录，存储lib目录下定义的插件的使用帮助及示例文件；

		模块管理命令：
			puppet module <action> [--environment production ] [--modulepath $basemodulepath ]

				ACTIONS:
				  build        Build a module release package.
				  changes      Show modified files of an installed module.
				  generate     Generate boilerplate for a new module.
				  install      Install a module from the Puppet Forge or a release archive.
				  list         List installed modules
				  search       Search the Puppet Forge for a module.
				  uninstall    Uninstall a puppet module.
				  upgrade      Upgrade a puppet module.
				
puppet(3)
	
	agent/master：
		agent：默认每隔30分钟向master发送node name和facts，并请求catalog；
		master：验正客户端身份，查找与其相关的site manifest，编译生成catalog，并发送给客户端；

		ssl xmlrpc, https
			8140/tcp

		master：puppet, puppet-server, facter
		agent：puppet, facter

	配置及配置文件：
		主配置文件：/etc/puppet/puppet.conf

		显示或设置配置参数：
			puppet config 
				print
				set

		手动生成完成配置文件：
			master:
				puppet master --genconfig > /etc/puppet/puppet_default.conf

			agent：
				puppet agent --genconfig >> /etc/puppet/puppet_default.conf


			注意：
				(1) 生成新的配置之前不能删除或移动原有的puppet.conf；
				(2) 生成的配置中，有的参数已经被废弃，与现有Puppet版本可能兼容；
				(3) 有的参数的默认值与现在版本所支持值可能不相兼容；

		获取puppet文档：
			puppet doc
				分段，称为reference
				列出所有的reference：
					puppet doc --list

				查看某一reference：
					puppet doc -r REFERENCE_NAME

		配置文件的组成部分：
			[main]
			[master]
			[agent]


		签署证书：
			puppet cert <action> [-h|--help] [-V|--version] [-d|--debug] [-v|--verbose] [--digest <digest>] [<host>]

			Action：
				list：查看所等签署请求；

	配置agent/master：
		1、配置master; 
			# puppet master --no-daemonize -v
			# systemctl start puppetmaster.service
			# systemctl enable puppetmaster.service

			8140/tcp

		2、配置agent：
			# puppet agent --server=MASTER_HOST_NAME --no-daemonize --noop --test -v
			# puppet agent --server=MASTER_HOST_NAME --no-daemonize -v -d
				发送证书签署请求给master；

		3、在master端为客户签署证书
			# puppet cert list
			# puppet cert sign NODE_NAME
			# puppet cert sign --all

		4、在master端：
			(1) 安装所有要用到的模块；
				puppet module install
				自研

			(2) 定义site manifest; 
				/etc/puppet/manifests/site.pp
					node 'NODE_NAME' {
						... puppet code ...
					}

				例如：
					node "node3.magedu.com" {
						include nginx::proxy
					}

	节点管理：
		site.pp定义节点的方式：
			(1) 以主机名直接给出其相关定义；
				node 'NODE_NAME' {
					... puppet code ...
				}

			(2) 把功能相近的主机事先按统一格式命名，按统一格式调用；
				node /^web\d+\.magedu\.com/ {
					... puppet code ...
				}

		主机命名规范：
			角色-运营商-机房名-IP.DOMAIN.TLD

				web-unicom-jxq-1.1.1.1.magedu.com

		对节点配置分段管理：
			/etc/puppet/mainfests/
				site.pp
					import "webservers/*.pp"

				webservers/
					unicom.pp
					telecom.pp
				cacheservers/

				appservers/

	面临的两个问题：
		1、主机名解析；
		2、如何为系统准备好puppet agent；

	puppet的多环境支持：
		master环境配置段：
			[master]
			environment = production, testing, development

			[production]
			manifest = /etc/puppet/environments/production/manifests/site.pp
			modulepath = /etc/puppet/environments/production/modules/
			fileserverconfig = /etc/puppet/fileserver.conf

			[testing]
			manifest = /etc/puppet/environments/testing/manifests/site.pp
			modulepath = /etc/puppet/environments/testing/modules/
			fileserverconfig = /etc/puppet/fileserver.conf

			[development]
			manifest = /etc/puppet/environments/development/manifests/site.pp
			modulepath = /etc/puppet/environments/development/modules/
			fileserverconfig = /etc/puppet/fileserver.conf

		agent配置文件：
			[agent]
			environment = testing

	puppet的文件服务器：
		fileserver.conf
			生效的结果是结合puppet.conf与auth.conf；用于实现安全配置，例如agent能够或不能访问master端的哪些文件；

			[mount_point]
			path /PATH/TO/SOMEWHERE
			allow HOSTNAME
			allow_ip IP
			deny all

	auth.conf配置文件：
		认证配置文件，为puppet提供acl功能，主要应用于puppet的Restful API的调用；

			xmlrpc:
				https://master:8140/{environment}/{resource}/{key}

			path /path_to_somewhere
			auth yes
			method find, save
			allow
			allow_ip

	namespaceauth.conf
		用于控制名称空间的访问法则；
		[puppetrun]
		allow node3.magedu.com

		名称空间：
			fileserver, puppetmaster, puppetrunners, puppetreports, resource

	autosign.conf：
		让master在接收到agent的证书签署后直接自动为其签署；
			*.magedu.com

	puppet kick模式：
		3.8版本之后已经废弃；

	puppet的dashboard：

	puppet master的扩展方式：
		单机扩展：
			Nginx + Mongrel
			Nginx + Passenger
			httpd + Passenger


Cobbler：
	
	PXE：
		Preboot Execution Environment

		硬件支持：

	核心术语：
		distro：发行版；CentOS 6.7, CentOS 7.1
		profile：distro+kickstart
			subprofile
		system：

	安装使用cobbler：
		# yum install cobbler cobbler-web httpd
		# systemctl start httpd.service
		# systemctl start cobblerd .service


监控：
	传感器：

	数据采集 --> 数据存储 --> 数据展示
	报警：采集到的数据超出阈值

		时间序列数据



	开源监控工具：

	SNMP：Simple Network Management Protocol

	SNMP的工作模式：
		NMS向agent采集数据
		agent向NMS报告数据
		NMS请求agent修改配置

	SNMP的组件：
		MIB：management information base
			agent端协议太简单，不能把要获取的指标信息详细化格式化，需要一个仓库规范
			MIBVIEW视图
		SMI：MIB表示符号
		SNMP协议

	SNMP协议的版本：
		v1, v2, v3
		v2c: NMS --> agent 
			发送一个标识过去，与agent端一样就通过
		v3: 认证、加密、解密

	Linux: net-snmp程序包

	NMS可发起操作：
		Get, GetNext, Set, Trap

		agent: Response

		UDP
			NMS: 161
			agent: 162

	分布式监控

	著名的开源监控工具：zabbix, zennos, opennms, cacti, nagios(icinga), ganglia

	监控功能的实现：
		agent
		ssh
		SNMP 虽然古老，但是像路由器你不能装一个配套的agent
		IPMI

	zabbix: 有专用agent的监控工具
		监控主机：
			Linux、Windows、FreeBSD
		网络设备：
			SNMP, SSH(并非所有)


	可监控对象：
		设备/软件
			设备：服务器、路由器、交换机、IO系统
			软件：OS、网络、应用程序
		偶发性小故障：
			主机down机、服务不可用、主机不可达
		严重故障：
		主机性能指标
		趋势：时间序列数据

	数据存储：
		cacti: rrd (round robin database)
		zabbix: mysql, pgsql

	zabbix架构中的组件：
		zabbix-server: C语言
		OS: zabbix-agent: C语言
		zabbix-web：GUI，用于实现zabbix设定和展示
		zabbix-proxy: 分布式监控环境中的专用组件
		

		zabbix-database: MySQL, PGSQL(postgreSQL)、Oracle、DB2、SQLite


	zabbix产生的数据主要由四部分组成：
		配置数据
		历史数据：50Bytes
		历史趋势数据: 128Bytes
		事件数据: 130Bytes





回顾：
	zabbix组件：
		zabbix-server
		zabbix-database
		zabbix-web
		zabbix-agent
		zabbix-proxy
	zabbix逻辑组件：
		主机组、主机
		item（监控项）、appliction（应用）
		graph（图形）展示item采集到的数据
		trigger（触发器）
			event（事件）
		action
			notice
			command
		media
		users(meida)
	监控系统：
		数据采集、数据存储、报警、数据可视化
	zabbix:
		database --> zabbix-server （zabbix_server.conf） --> zabbix-web(LAMP) --> http://zabbix-web-server/zabbix
		zabbix-agent （zabbix-agent）

	添加主机

	agent: 161
	nms: 162 (trap)
	
	历史数据：采样生成的数据
	历史趋势数据：每小时的最大值、最小值、平均值、统计

	As is: 不做任何处理
	Delta(speed per second):   (value - prev_value)/(time - prev_time)
		第10秒: 12000, 第20秒: 13000--> (13000-12000)/(20-10)
	Delta(simple change)：(value - prev_value)

	Trigger:
		名称中可以使用宏：变量
			{HOST.HOST}, {HOST.NAME}, {HOST.IP}, {HOST.CONN}, {HOST.DNS}

	Action有两类：
		send message
		command

	由zabbix监控某关注的指标：
		定义的思路：
		host group(针对同需求的host归组) --> host --> item (存储于MySQL)--> graph (zabbix-web) --> trigger(触发器只是定义一个阈值) --> action(conditon+operation)
		application：针对items把功能相近的一组item归类在一起统一进行管理组件；

	Zabbix完整的监控配置流程大体上由如下步骤组成：
		Host group --> Hosts --> Applications --> Items(在appication内) --> Triggers --> Events --> Actions --> User groups(警告都是向某类对像发送) --> Users --> Medias(发送告警的方式email,qq,message...)
		graph 虽不是必需但更直观
		screen 集中显示

		依赖关系：
			Host --> Item --> Trigger --> Action --> Notice, Command

		添加主机到zabbix server：
			discovery：服务端定义好规则将网段内的可以接受监控的都加进来 
			auto_registrion：客户端主动上来
			low level discovery

		模板：discovery可以将发现的主机用模板链接上去
			template：
				item, application, trigger, graph, action

	主机组标准：
		机器用途、系统版本、应用程序、地理位置、业务单元

	Item：
		默认的Items有多种类型：定义是snmp还是agent获取
			Zabbix-agent：
				工作模式：passive, active

			网卡流量相关：
				net.if.in[if,<mode>]
					if: 接口，如eht0
					mode: bytes, packets, errors, dropped
				net.if.out[if,<mode>]
				net.if.total[if.<mode>]

			端口相关：
				net.tcp.listen[port]
				net.tcp.port[<ip>,port]
				net.tcp.service[service,<ip>,<port>]
				net.udp.listen[port]

			进程相关：
				kernel.maxfiles允许最大文件数
				kernel.maxproc允许最大进程数

			CPU相关：
				system.cpu.intr中断
				system.cpu.load[<cpu>,<mode>]负载
				system.cpu.num[<type>]颗数
				system.cpu.switches上下文切换
				system.cpu.util[<cpu>,<type>,<mode>]哪个cpu哪个指标的利用率

			磁盘IO或文件系统相关：
				vfs.dev.read[<device>,<type>,<mode>]
				vfs.dev.write[<device>,<type>,<mode>]
				vfs.fs.inode[fs,<mode>]

		用户可自定义item：
			关键：选取一个惟一的key；
			命令：收集数据的命令或脚本；

		Trigger:
			状态：
				OK：在阈值内
				PROBLEM：有事件发生；
					zabbix server每次接收到items的新数据时，就会对Item的当前采样值进行判断，即与trigger的表达式进行比较；

			一个trigger只能属于一个Item, 但一个Item可以有多个trigger；

			Severity：严重级别
				Not classified: 未知级别，灰色；
				Information: 一般信息，亮绿；
				Warning：警告信息，黄色；
				Average: 一般故障，橙色；
				High：高级别故障，红色；
				Disater：致命故障，亮红；

		Action：
			触发条件一般为事件：
				Trigger events: OK --> PROBLEM
				Discovery events: zabbix的network discovery工作时发现主机；
				Auto registration events：主动模式的agent注册时产生的事件；
				Internal events：Item变成不再被支持，或Trigger变成未知状态；

		Operations的功能：
			动作：
				send message
				Remote command

			配置send message：
				(1) 先定义好Media；
				(2) 再定义好用户；
				(3) 配置要发送的信息；










zabbix on CentOS 7

	zabbix: 2.0, 2.2, 2.4 

	epel附带版本安装
		zabbix20
		zabbix22

	Linux开源监控系统：
		nagios报警功能强大
		cacti绘图功能强大
		zabbix结合二者，还有更多优势
		ganglia分布集群监控，有强大的聚合功能

	zabbix-2.4

		mariadb











回顾和总结：zabbix的基本应用

	Host group --> Host --> Application --> Item --> Trigger (OK-->PROBLEM, trigger event) --> Action (Conditon+Operation(Send Message, Remote Command)) 

	Send Message：
		Media:
			Email、SMS、Jabber、Script、EZ Texting

			给出具体实现：
		User groups --> User (Media) 

		示例中：node2.magedu.com --> Traffic --> Inbound traffic, Outbound traffic --> trigger (inboud)

	Zabbix常用术语：
		Item Key
		Escalation报警升级
		Template
		Web Scennario web应用场境

	Zabbix服务器进程：
		housekeeper, alter, discoverer, httppoller, Poller, pinger, db_config_syncer, timer, escaltor

zabbix(3)

	Item key:
		命名要求：只能使用字母、数字、下划线、点号、连接符
		接受参数；system.cpu.load[<cpu>,<mode>], net.if.inbound[if,<mode>]

			注意：每个key背后都应该有一个命令或脚本来负责实现数据收集；此命令或脚本可调用传递给key的参数，调用方式为$1, $2,...

			官方文档：https://www.zabbix.com/documentation/2.4/manual/config/items/itemtypes/zabbix_agent

		在zabbix中定义item时调用某key，还需额外定义数据采集频率、历史数据的保存时长等；

	Trigger：
		触发器表达式：{<Server>:<key>.<function>(<parameter>)}<operator><constant>

			{node2.magedu.com:net.if.in[eth0,bytes].last(#1)}>1200

		<function>：评估采集到的数据是否在合理范围内时所使用的函数；其评估过程可以根据采集到的数据、当前时间或其它因素；
			avg, count, change, date, dayofweek, dayofmonth, delta, diff, iregexp, regexp, last, max, min, nodata, now, prev, str, strlen, sum
				diff: 通常用于文件有没变化
				dayofweek：本同第几天
				change：这次与上次差值
				delta：返回指定时间内最大值与最小值之差或者指定次数内
				avg: 可以是时段内也可以是多少次求平均
				regexp：检查最后一次采样的数据是否能够被指定的模式所匹配；1表示匹配，0表示不匹配；
				now：返回自Unix元年至此刻经历的秒数；
				prev: 倒数第二个采样值；
				str: 从最后一次的采样中查找此处指定的子串；找到为1，找不到为0；
				strlen：最后一次的采样中字符串的长度与此处指定的长度进行比较

		<operator>:操作符
			>, <, =, #(不等于)
			/, *, -, +	
			&, |

		触发器间有依赖关系；

	Action：
		message
		condition
			event：
				trigger
				disovery: 事件发现状态
					Service Up, Service Down, Host up, Host Down, Service Discovered, Service Lost, Host Discovered, Host Lost
				auto_registration
				lld
		operation
			send message
				Media Type
					Email, SMS, Jabber, Script, EZ Texting
						Script：Alert Script
							放置于特定目录中：AlertScriptsPath=/usr/lib/zabbix/alertscripts
								zabbix_server.conf配置文件中的参数；

							脚本中可使用$1, $2, $3来调用 action 页面中显示的"邮件的收件人", "Default Subject", "Default Message"；
							
							注意：新放入此目录中的脚本，只有重启zabbix-server方能被使用；
							#!/bin/bash
							to="$1"
							subject="$2"
							body="$3"
							echo "$body" | mail -s "$subject" "$to"
							
				
				User
			remote command权限可能不足
				(1) 给zabbix定义sudo规则；
					zabbix ALL=(ALL) ALL
				(2) 不支持active模式的agent；
				(3) 不支持代理模式；
				(4) 命令长度不得超过255个字符；
				(5) 可以使用宏；
				(6) zabbix-server仅执行命令，而不关心命令是否执行成功；

				前提：zabbix-agent要配置为支持执行远程命令：
					EnableRemoteCommands=1

				注意
					(1) 如果用到以其它用户身份执行命令的话，那么命令本身要以sudo方式运行：
						sudo /etc/rc.d/init.d/httpd restart
					(2) 在各agent上的sudoers文件，要注释如下行:
						Defaults    requiretty(zabbix执行此命令不是用tty执行的)
	graphic：默认情况下定义了item就会有graphic，在latest data里可以找到，但是要show filter过滤一下，但是默认只为某一个item单独定义
		只有在要将多个图用在一个application中时才需要自定义
			
	screen：相当于excel一个表一样，将多项多列一起展示
		configeration-->screen-->create screen
		monitor-->screen

	宏：就变量，按着预定的规则进行替换
		两类：引用方式略有区别
			内建：{MACRO_NAME}
			自定义：{$MACRO_NAME}

		可以三个级别使用：
			Global, Template, Host

			优先级：Host --> Template --> Global
				在某级别找到后将直接使用；

	模板：一系列配置的集合，此些配置可通过“链接”的方式应用于指定的主机；
		application, item, trigger, graph, screen, discovery, web

	维护时间：
		Configuration --> Maintance

	User Parameters：实现用户自定义item key, 实现特有数据指标监控(zabbix 内置了许多item key)；
		语法:
			UserParameter=<key>,<command>

		示例：在agent端/etc/zabbix/zabbix.agent.conf.d/**.conf
			UserParameter=os.memory.used, free -m | awk '/^Mem/{print $3}'
			UserParameter=os.memory.total, free -m | awk '/^Mem/{print $2}'


			UserParameter=Mysql.dml[*], /usr/local/mysql/bin/mysql -h$1 -u$2 -p$3 -e 'SHOW GLOBAL STATUS' | awk '/Com_$4\>/{print $$2}'


zabbix(4)

	zabbix提供网络发现功能：network discovery
		HTTP、ICMP、SSH、LDAP、TCP、SNMP、Telnet、Zabbix_agent扫描指定网络内的主机；

		一旦主机被发现，如果对其进行操作，将由action来决定；

		LLD: Low Level Discovery

		此二者的功能：
			自动添加或移除主机、将主机链接至模板或删除链接、添加监控项、将主机添加至分组、定义触发器、执行远程脚本；

		网络发现有两个步骤：
			discovery(周期扫描某网段) --> action中选择基于discovery触发

			发现中的事件：
				Service Discovered, Service Lost, Service Up, Service Down
				Host Discovered, Host List, Host Up, Host Down

			actions:
				Sending notifications
				Adding/removing hosts
				Enabling/disabling hosts
				Adding hosts to a group
				Removing hosts from a group
				Linking hosts to/unlinking from a template
				Executing remote scripts	
				
	auto_registation：客户端也可以主动来请求注册
		
		支持使用agent(active)类型的item key；
			这是agent端主动周期向server发送信息，不是server用poller进程索取数据
		配置过程：
			(1) 定义agent端：
				ServerActive= 至关重要
				Server=
				Hostname=
				ListenIP= 设置为本机某特定IP；
				ListenPort= 一般默认
				HostMetadata= 可以使用但不强求
					可以在action中的condition中定义HostMetadata=****
				HostMetadataItem=item key, 一般使用system.uname

			(2) 配置action, 同样要求其事件action来源为auto-registation
				HostMetadata只用于自动注册，当前目机唯一标识
				
	LLD: Low Level Discovery
		1、自动发现特定变量的名称；
			#IFNAME, #FSNAME,
		2、添加针对对变量的Items；
			返回值为JSON
		好比ansible中的facts信息，被执行端主机发来facts，执行端根据facts随机应便替换变量以求针对正确资源发送正确指令

	zabbix的监控方式：
		zabbix-web所能够显示的且可指定为监控接口类型的监控方式：
			Agent
				passive
				active
			SNMP: Simple Network Management Protocol
				MIB, SMI, SNMP (v1, v2c, v3)
			IPMI:
				智慧平台管理接口（Intelligent Platform Management Interface）原本是一种Intel架构的企业系统的周边设备所采用的一种工业标准。IPMI亦是一个开放的免费标准，使用者无需支付额外的费用即可使用此标准。
			JMX：Java Management Extensions，用于通过Java自己的接口对java程序进行监控；
				如JVM运行程序时的各项数据
				zabbix-java-gateway用于获取监控数据；


		SNMP监控方式：
			操作：Get, GetNext, Set, Response, Trap
			MIB: 是被管理对象的集合，而且还额外定义了被管理对象的名称、访问权限、数据类型等属性；
			MIB视图：MIB的子集
			授权：将某MIB视图与某Community绑定来实现；
			OID：Object ID, 1.3.6.1.2.1
				1: system
				2: interface
				4: ip
				6: tcp
				7: udp


		JMX监控方式：
			(1) 安装zabbix-java-gateway；
				配置文件：/etc/zabbix/zabbix_java_gateway.conf
					Listen_IP=
					Listen_PORT=10052

				zabbix server的配置文件/etc/zabbix/zabbix_server.conf
					JavaGateWay=
					JavaGateWayPort=10052
			(2) Java应用程序开户JMX接口：
				java -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=10053 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false 

			监控Tomcat，在启动脚本中传递如下参数
				export CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=10053 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
		
		分布式监控之proxy监控
				如果有两个机房，每一个有500个主机
				可以定义每一个机房一个proxy server(也要有自己的数据库) 收取所有主机信息，再汇总传到总zabbix-server上去
				配置好proxy，以后再添加proxy所在网段内主机时，在zabbix-server添加选上monitor by proxy ***，以后主是proxy监视这个主机，每秒向zabbix-server报告
								
				预测一下zabbix database需要用到的空间：
					60000/60 = 1000条

					历史数据=天数X每秒钟处理的数据量X24X3600X50Bytes
						默认保存90天
						90X1000X86400X50Bytes

					趋势数据：
						每一个趋势128Bytes, 
							大小=天数X监控项X24X128Bytes

					事件数据：
						每个占据130Bytes
							大小：天数X86400X130
				
	





