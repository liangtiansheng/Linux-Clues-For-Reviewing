官方权威指南：http://www.ansible.com.cn/docs/

Ansible:运维工具
	运维工作：系统安装(物理机、虚拟机)-->程序包安装、配置、服务启动-->批量操作-->程序发布-->监控
	OS Provisioning：
		物理机：PXE、Cobbler
		虚拟机：Image Templates
	Configuration:
		puppet (ruby)
		saltstack (python)
		chef
		cfengine
	Command and Control:
		fabric
	预发布验证：
		新版本的代码先发布到服务器（跟线上环境配置完全相同，只是未接入到调度器）

	程序发布：
		不能影响用户体验：
		系统不能停机
		不能导致系统故障或造成系统完全不可用
	灰度发布：
		发布路径：
			/webapp/tuangou-1.1
			/webapp/tuangou-1.2
		在调度器上下线一批主机(maintanance)-->关闭服务-->部署新版本的应用程序-->批量启动服务
		
		自动灰度发布：脚本、发布平台

	运维工具的分类：要不要在被管理的主机上安装代理
		agent：puppet, func
		agentless: ansible(依赖ssh), fabric
			都要安装ssh
	ansible:特性
		模块化，调用特定的模块，完成特殊任务
		基于python语言实现，由paramiko(ssh的API)、PyYAML和Jinjia2三个关建模块：
		部署简单，agentless
		默认使用SSH协议
			(1)基于密钥认证
			(2)在inventory文件中指定账号和密码
		主从模式
			master:ansible, ssh client
			slave: ssh server
		基于模块完成各种任务,支持自定义模块(支持各种编程语言)
		支持Playbook(根据这个定义的剧本ansible同时唱n出戏)

	ansible的核心组件：
		ansible core
		host inventory
		core modules
		custom modules
		playbook(yaml,jinjia2)
		connect plugin
	安装：依赖于epel源(http://dl.fedoraproject.org/pub/epel/)
		配置文件：/etc/ansible/ansible.cfg
		Inventory: /etc/ansible/hosts
	如何查看模块文件：
		ansible-doc -l
		ansible-doc -s MODULE_NAME
	ansible命令应用基础：
		语法：ansible <host-pattern> [-f forks] [-m module_name] [-a args]
			-f forks: 启动的并发线程数
			-m module_name：要使用的模块
			-a args：模块特有参数
		command：命令模块、默认模块、用于在远程执行命令
			ansible all -a	'date'
		cron:
			state:
				present：安装
				abscent：移除
			# ansible websrvs -m cron -a 'minute="*/10" job="/bin/echo hello" name="test cron job"'
		user:
			name=: 指明创建的用户的名字
			# ansible websrvrs -m user -a 'name=mysql uid=306 system=yes group=mysql'
				
		copy:
			src=：定义本地源文件路径
			dest=：定义远程目标文件路径
			content=：取代src=, 表示直接用此处指定的信息生成为目标文件内容：

			# ansible all -m copy -a 'content="hello\nansible\n" dest=/tmp/test.ansible'
		file：设定文件属性
			path=：指定文件路径，可以使用name或dest替换：
	
		ping：测试指定主机是否能连接

		service：指定运行状态
			enable=：是否开机自启，取值为true或者false
			name=: 服务名称
			state=：状态，取值有started, stopped, restarted;
		shell模块：在远程主机上运行命令
			龙其是用到管道等功能的复杂命令时用shell
		script：将本地脚本复杂到远程主机并运行之
			注意：使用相对路径
		yum：安装程序包
			name：指明要安装的程序包，可以带上版本号
			state：present安装，abscent卸载
		setup：收集远程主机的facts
			每个被管理节点在接收并运行管理命令之前，会将自己主机相关信息，如操作系统版本、IP地址等报告给远程的ansible主机

		ansible中使用的YAML基础元素：
			变量
			Inventory
			条件测试
			迭代
		playbook的组成结构
			Inventory
			Modules
			Ad Hoc Commands
			Playbooks
				Tasks
				variables
				Templates
				Handlers
				Roles
		注意几个事：
		1、这个"-"表示某一个级别下的list，也就是多个并列项，一定注意如此对齐，不然报错
		2、tags在运行ansible-playbook playbook.yml --tags "marks"时表明只有tags为marks的那个任务执行，别的不动，但有个特殊tags：always，无论调用哪个tags，它总是生效
		3、handlers就是tasks，只是被调用时才生效
		4、templates只是在向某个配置文件传递变量时很有作用
		5、变量可以在playbook中直接自定义，也可以用内置变量，在inventory里定义的变量可以直接用在playbook里面

		---
		- hosts: first
		  remote_user: root
		  vars:
		  - servername: httpd
		  - servicename: httpd

		  tasks:
		  - name: install httpd packages
		    yum: name={{ servername }} state=present
		  - name: if httpd's configuraton changed, notify httpd to restart
		    tags:
		    - marks
		    template: src=/root/httpd.conf dest=/etc/httpd/conf/httpd.conf
		    notify:
		    - restart httpd
		  - name: start httpd
		    service: name={{ servicename }} state=started enabled=true
		  handlers:
		  - name: restart httpd
		    service: name=httpd state=restarted
		  [root@Directory ~]# ansible-playbook playbook.yml --tags "marks"

		 ***定义roles
		[root@Directory ~]# mkdir ansible_playbook/roles/{first,second}/{files,templates,tasks,handlers,vars,defaults,meta} -pv
		[root@Directory ~]# tree ansible_playbook/
		ansible_playbook/
		└── roles
		    ├── first
		    │   ├── defaults
		    │   ├── files
		    │   ├── handlers
		    │   ├── meta
		    │   ├── tasks
		    │   ├── templates
		    │   └── vars
		    └── second
			├── defaults
			├── files
			├── handlers
			├── meta
			├── tasks
			├── templates
			└── vars
		[root@Directory tasks]# vim main.yml		
		---
		- name: install mariadb
		  yum: name=mariadb-server state=present
		- name: start service
		  service: name=mariadb state=started
		- name: if mariadb changed, revoke handlers
		  template: src=my.cnf dest=/etc/my.cnf
		  notify:
		  - restart mariadb
		[root@Directory handlers]# vim main.yml
		---
		- name: restart mariadb
		  service: name=mariadb state=restarted
		[root@Directory webserver]# ls templates/
		my.cnf
		[root@Directory webserver]#
		详解可参考http://www.ansible.com.cn/docs/
		




