FTP：File Transfer Protocol
	21/tcp:

文件共享服务：应用层，ftp
		NFS: Network File System (RPC: Remote Procedure Call, 远程过程调用)
		Samba: CIFS/SMB

FTP: tcp, 两个连接
	命令连接/控制连接：21/tcp
			client --> server
	数据连接: 对服务器来说
		主动模式：20/tcp
			server --> client
		
		被动模式：端口随机
			client --> server

	数据传输模式(自动模式)：
		二进制：
		文本：
		ftp server --> ftp client
C/S:
	Server:
		wu-ftpd
		proftpd
		pureftp
		vsftpd
		ServU
	Client:
		ftp
		lftp,lftpget
		wget,curl
		filezilla
		gftp(Linux GUI)
		
		flashfxp
		cuteftp
			商业
响应码：
	1XX：信息
	2XX: 成功类状态码
	3XX：提示需进一步提供补充类信息的状态码
	4XX: 客户端错误
	5XX：服务端错误
vsftpd:
	/etc/vsftpd: 配置文件目录
	/etc/init.d/vsftpd: 服务脚本
	/usr/sbin/vsftpd: 主程序
基于nsswitch：network server switch，名称解析框架
	配置文件：/etc/nsswitch.conf
		db: store1, store2,........
			第一个找不到，找第二个......
		每种存储中查找的结果状态：STATUS --> success | notfound | unavail | tryagain
		对应于每种状态参数的行为：ACTION --> return |　continue

		host: files nis [NOTFOUND=return] dns
			nis找完就返回，不找dns，除非nis不存在
	模块：/lib64/libnss*, /usr/lib64/libnss*
		/usr/lib64/libnss3.so             /usr/lib64/libnss_dns-2.17.so      /usr/lib64/libnss_nisplus-2.17.so
		/usr/lib64/libnssckbi.so          /usr/lib64/libnss_dns.so.2         /usr/lib64/libnss_nisplus.so.2
		/usr/lib64/libnss_compat-2.17.so  /usr/lib64/libnss_files-2.17.so    /usr/lib64/libnss_nis.so.2
		/usr/lib64/libnss_compat.so.2     /usr/lib64/libnss_files.so.2       /usr/lib64/libnsspem.so
		/usr/lib64/libnss_db-2.17.so      /usr/lib64/libnss_hesiod-2.17.so   /usr/lib64/libnss_sss.so.2
		/usr/lib64/libnssdbm3.chk         /usr/lib64/libnss_hesiod.so.2      /usr/lib64/libnsssysinit.so
		/usr/lib64/libnssdbm3.so          /usr/lib64/libnss_myhostname.so.2  /usr/lib64/libnssutil3.so
		/usr/lib64/libnss_db.so.2         /usr/lib64/libnss_nis-2.17.so
	
	getent database [entry]
	[root@CentOS7 ~]# getent passwd root
	root:x:0:0:root:/root:/bin/bash
	[root@CentOS7 ~]# getent services http
	http                  80/tcp www www-http
	[root@CentOS7 ~]# getent services ssh
	ssh                   22/tcp
	[root@CentOS7 ~]#

基于PAM(pluggable authentication module)实现用户认证：
	认证库：
		文件、MySQL、LDAP、NIS
	以下通用框架就是告诉程序员怎么跟MySQL、LDAP......交互
	/etc/pam.d/*
		某一个程序来认证，告诉他找哪个模块来认证
		每个应用单独定义自己的认证机制
			[root@CentOS7 pam.d]# cat su
			#%PAM-1.0
			auth		sufficient	pam_rootok.so
			# Uncomment the following line to implicitly trust users in the "wheel" group.
			#auth		sufficient	pam_wheel.so trust use_uid
			# Uncomment the following line to require a user to be in the "wheel" group.
			#auth		required	pam_wheel.so use_uid
			auth		substack	system-auth
			auth		include		postlogin
			account		sufficient	pam_succeed_if.so uid = 0 use_uid quiet
			account		include		system-auth
			password	include		system-auth
			session		include		system-auth
			session		include		postlogin
			session		optional	pam_xauth.so
			[root@CentOS7 pam.d]#
				pam_rootok.so这个模块就是说是root,OK没问题，过，
		配置文件中每行定义一种检查规则
			格式：
				type	control		module-path	module-arguments
				type：检查功能类别
					auth：账号的认证和授权
					account：与账号管理相关的非认证功能
					password：用户修改密码时密码检查规则
				control：同一种功能的多个检查之间如何进行组合
					两种实现机制：
						1、使用一个关键词来定义：例如：sufficient,required,requisite
						2、使用一个或多个“status=action”形式的组合表示
						简单机制
							required
								必须要通过，通过要检，没通过也要检
							requisite
								必须要通过，通过要检，没通过不用说了
							sufficient
								通过就定了，过，没通过不管，别人决定
							optional
								作为参考
							include
								包含后面指定文件中相同类别的规则
						复杂机制
							status: 返回状态
							action: ok, done, die, ignore, bad, reset
								ok: 一票通过权
								done：通过就通过
								die：一票否决权
								bad：不过就不过

				module-path：模块路径
					/lib64/security：此目录下的模块引用时可使用相对路径
				module-arguments: 模块参数

				模块：
					(1)pam_shells.so
					(2)pam_limits.so
						模块通过读取配置文件完成用户对系统资源的使用控制
							/etc/security/limits.conf
							/etc/security/limits.s/*
								格式：<domain>      <type>  <item>         <value>
								domain：
									username
									@group
									*：所有用户
								type：
									soft：软限制，超过这个限制也不能长久
									hard：硬限制，一定不能超过这个
								item：
									nproc：用户所能够同时进行的最大进程数量
									msqqueue：使用的POSIXi消息队列能够占用的最大内存空间
									nofile：能够同时打开的最大文件数量
								ulimit：改软限制
									ulimit -n #：文件数量
									ulimit -u #：进程数量
	/lib/security/*
	/lib64/security/*
	支持虚拟用户
	虚拟用户：
		所有的虚拟用户会被统一映射为一个指定的系统账号，访问的共享位置即为此系统账号的家目录
			
		各虚拟用户可被赋予不同的访问权限
			通过匿名用户的权限控制参数进行指定：
		虚拟用户账号的存储方式：
			文件：编辑文件
				奇数行为用户名
				偶数行为密码

				此文件需要被编码为hash格式:
					但是每次加用户就要重新编绎
			关系型数据库中的表中：
				mysql库
					pam要依赖于pam-mysql模块
						但是pam没有自带的pam-mysql模块，这是第三方模块
			


vsftpd: (ftp, ftp) 
	/var/ftp：ftp服务根目录
ftp: 系统用户，下面的三种用户都会映射为系统用户
	匿名用户 --> 系统用户: anonymous_enable
	系统用户: local_enable
	虚拟用户 --> 系统用户

/var/ftp: ftp用户的家目录
	匿名用户访问目录
/etc/vsftpd/vsftpd.conf：主配置文件

/usr/sbin/vsftpd：Vsftpd的主程序

/etc/rc.d/init.d/vsftpd：启动脚本

/etc/pam.d/vsftpd：PAM认证文件（此文件中file=/etc/vsftpd/ftpusers字段，指明阻止访问的用户来自/etc/vsftpd/ftpusers文件中的用户）

/etc/vsftpd/ftpusers：禁止使用vsftpd的用户列表文件。记录不允许访问FTP服务器的用户名单，管理员可以把一些对系统安全有威胁的用户账号记录在此文件中，以免用户从FTP登录后获得大于上传下载操作的权利，而对系统造成损坏。（注意：linux-4中此文件在/etc/目录下）

/etc/vsftpd/user_list：禁止或允许使用vsftpd的用户列表文件。这个文件中指定的用户缺省情况（即在/etc/vsftpd/vsftpd.conf中设置userlist_deny=YES）下也不能访问FTP服务器，在设置了userlist_deny=NO时,仅允许user_list中指定的用户访问FTP服务器。（注意：linux-4中此文件在/etc/目录下）

/var/ftp：匿名用户主目录；本地用户主目录为：/home/用户主目录，即登录后进入自己家目录

/var/ftp/pub：匿名用户的下载目录，此目录需赋权根chmod 1777 pub（1为特殊权限，使上载后无法删除）

/etc/logrotate.d/vsftpd.log：Vsftpd的日志文件

chroot: 禁锢用户于其家目录中

系统用户：
	write_enable=YES: 上传文件
文件服务权限：文件系统权限*文件共享权限

守护进程：
	独立守护：适用于访问量大，用户在线时间长的用户
	瞬时守护
		由xinetd代为管理

vsftpd: 
	max_clients=#
	max_per_ip=#

安全通信方式：
	ftps: ftp+ssl/tls
	sftp: OpenSSH, SubSystem, sftp(SSH)


vsftpd: PAM(手动定义配置文件)
	匿名
	本地
	虚拟用户
		MySQL: VSFTPD, users ： Name,Password
		/etc/vsftpd/vusers: --> db_load 
			USERNAME
			PASSWORD

db4-utils 这个软件包提供的db_load命令将配置文件改成二进制格式
目前为止学了三个将配置文件改成二进制格式的工具：newalias postmap db_load
postconf -m
[root@mail ~]# yum install vsftpd -y
[root@mail ~]# rpm -ql vsftpd
/etc/logrotate.d/vsftpd.log
/etc/pam.d/vsftpd
/etc/rc.d/init.d/vsftpd
/etc/vsftpd
/etc/vsftpd/ftpusers
/etc/vsftpd/user_list
/etc/vsftpd/vsftpd.conf
/etc/vsftpd/vsftpd_conf_migrate.sh
/var/ftp
/var/ftp/pub
[root@mail ~]# service vsftpd start
Starting vsftpd for vsftpd:                                [  OK  ]
[root@mail ~]# chkconfig vsftpd on

*匿名用户上传下载的公共目录
[root@mail ~]# cd /var/ftp/
[root@mail ftp]# ls
pub

*用windows终端测试
C:\Users\yu>ftp 192.168.3.55
连接到 192.168.3.55。
220 (vsFTPd 2.0.5)
用户(192.168.3.55:(none)): anonymous
331 Please specify the password.
密码:
230 Login successful.
ftp> ls
200 PORT command successful. Consider using PASV.
150 Here comes the directory listing.
pub
226 Directory send OK.
ftp: 收到 5 字节，用时 0.00秒 5000.00千字节/秒。
ftp> ?
命令可能是缩写的。  命令为:

!               delete          literal         prompt          send
?               debug           ls              put             status
append          dir             mdelete         pwd             trace
ascii           disconnect      mdir            quit            type
bell            get             mget            quote           user
binary          glob            mkdir           recv            verbose
bye             hash            mls             remotehelp
cd              help            mput            rename
close           lcd             open            rmdir
ftp>

*配置文件详解
[root@mail ~]# vim /etc/vsftpd/vsftpd.conf
# 是否允许匿名登录FTP服务器，默认设置为YES允许
# 用户可使用用户名ftp或anonymous进行ftp登录，口令为用户的E-mail地址。
# 如不允许匿名访问则设置为NO
anonymous_enable=YES

# 是否允许本地用户(即linux系统中的用户帐号)登录FTP服务器，默认设置为YES允许
# 本地用户登录后会进入用户主目录，而匿名用户登录后进入匿名用户的下载目录/var/ftp/pub
# 若只允许匿名用户访问，前面加上#注释掉即可阻止本地用户访问FTP服务器
local_enable=YES

# 是否允许本地用户对FTP服务器文件具有写权限，默认设置为YES允许
write_enable=YES 

# 掩码，本地用户默认掩码为077
# 你可以设置本地用户的文件掩码为缺省022，也可根据个人喜好将其设置为其他值
#local_umask=022

# 是否允许匿名用户上传文件，须将全局的write_enable=YES。默认为YES
#anon_upload_enable=YES

# 是否允许匿名用户创建新文件夹
#anon_mkdir_write_enable=YES 

# 是否激活目录欢迎信息功能
# 当用户用CMD模式首次访问服务器上某个目录时，FTP服务器将显示欢迎信息
# 默认情况下，欢迎信息是通过该目录下的.message文件获得的
# 此文件保存自定义的欢迎信息，由用户自己建立
#dirmessage_enable=YES

# 是否让系统自动维护上传和下载的日志文件
# 默认情况该日志文件为/var/log/vsftpd.log,也可以通过下面的xferlog_file选项对其进行设定
# 默认值为NO
xferlog_enable=YES

# Make sure PORT transfer connections originate from port 20 (ftp-data).
# 是否设定FTP服务器将启用FTP数据端口的连接请求
# ftp-data数据传输，21为连接控制端口
connect_from_port_20=YES

# 设定是否允许改变上传文件的属主，与下面一个设定项配合使用
# 注意，不推荐使用root用户上传文件
#chown_uploads=YES

# 设置想要改变的上传文件的属主，如果需要，则输入一个系统用户名
# 可以把上传的文件都改成root属主。whoever：任何人
#chown_username=whoever

# 设定系统维护记录FTP服务器上传和下载情况的日志文件
# /var/log/vsftpd.log是默认的，也可以另设其它
#xferlog_file=/var/log/vsftpd.log

# 是否以标准xferlog的格式书写传输日志文件
# 默认为/var/log/xferlog，也可以通过xferlog_file选项对其进行设定
# 默认值为NO
#xferlog_std_format=YES

# 以下是附加配置，添加相应的选项将启用相应的设置
# 是否生成两个相似的日志文件
# 默认在/var/log/xferlog和/var/log/vsftpd.log目录下
# 前者是wu_ftpd类型的传输日志，可以利用标准日志工具对其进行分析；后者是vsftpd类型的日志
#dual_log_enable

# 是否将原本输出到/var/log/vsftpd.log中的日志，输出到系统日志
#syslog_enable

# 设置数据传输中断间隔时间，此语句表示空闲的用户会话中断时间为600秒
# 即当数据传输结束后，用户连接FTP服务器的时间不应超过600秒。可以根据实际情况对该值进行修改
#idle_session_timeout=600

# 设置数据连接超时时间，该语句表示数据连接超时时间为120秒，可根据实际情况对其个修改
#data_connection_timeout=120

# 运行vsftpd需要的非特权系统用户，缺省是nobody
#nopriv_user=ftpsecure

# 是否识别异步ABOR请求。
# 如果FTP client会下达“async ABOR”这个指令时，这个设定才需要启用
# 而一般此设定并不安全，所以通常将其取消
#async_abor_enable=YES

# 是否以ASCII方式传输数据。默认情况下，服务器会忽略ASCII方式的请求。
# 启用此选项将允许服务器以ASCII方式传输数据
# 不过，这样可能会导致由"SIZE /big/file"方式引起的DoS攻击
#ascii_upload_enable=YES
#ascii_download_enable=YES

# 登录FTP服务器时显示的欢迎信息
# 如有需要，可在更改目录欢迎信息的目录下创建名为.message的文件，并写入欢迎信息保存后
#ftpd_banner=Welcome to blah FTP service.

# 黑名单设置。如果很讨厌某些email address，就可以使用此设定来取消他的登录权限
# 可以将某些特殊的email address抵挡住。
#deny_email_enable=YES

# 当上面的deny_email_enable=YES时，可以利用这个设定项来规定哪些邮件地址不可登录vsftpd服务器
# 此文件需用户自己创建，一行一个email address即可
#banned_email_file=/etc/vsftpd/banned_emails

# 用户登录FTP服务器后是否具有访问自己目录以外的其他文件的权限
# 设置为YES时，用户被锁定在自己的home目录中，vsftpd将在下面chroot_list_file选项值的位置寻找chroot_list文件
# 必须与下面的设置项配合
#chroot_list_enable=YES

# 被列入此文件的用户，在登录后将不能切换到自己目录以外的其他目录
# 从而有利于FTP服务器的安全管理和隐私保护。此文件需自己建立
#chroot_list_file=/etc/vsftpd/chroot_list

# 是否允许递归查询。默认为关闭，以防止远程用户造成过量的I/O
#ls_recurse_enable=YES

# 是否允许监听。
# 如果设置为YES，则vsftpd将以独立模式运行，由vsftpd自己监听和处理IPv4端口的连接请求
listen=YES

# 设定是否支持IPV6。如要同时监听IPv4和IPv6端口，
# 则必须运行两套vsftpd，采用两套配置文件
# 同时确保其中有一个监听选项是被注释掉的
#listen_ipv6=YES

# 设置PAM外挂模块提供的认证服务所使用的配置文件名，即/etc/pam.d/vsftpd文件
# 此文件中file=/etc/vsftpd/ftpusers字段，说明了PAM模块能抵挡的帐号内容来自文件/etc/vsftpd/ftpusers中
#pam_service_name=vsftpd

# 是否允许ftpusers文件中的用户登录FTP服务器，默认为NO
# 若此项设为YES，则user_list文件中的用户允许登录FTP服务器
# 而如果同时设置了userlist_deny=YES，则user_list文件中的用户将不允许登录FTP服务器，甚至连输入密码提示信息都没有
#userlist_enable=YES/NO

# 设置是否阻扯user_list文件中的用户登录FTP服务器，默认为YES
#userlist_deny=YES/NO

# 是否使用tcp_wrappers作为主机访问控制方式。
# tcp_wrappers可以实现linux系统中网络服务的基于主机地址的访问控制
# 在/etc目录中的hosts.allow和hosts.deny两个文件用于设置tcp_wrappers的访问控制
# 前者设置允许访问记录，后者设置拒绝访问记录。
# 如想限制某些主机对FTP服务器192.168.57.2的匿名访问，编缉/etc/hosts.allow文件，如在下面增加两行命令：
# vsftpd:192.168.57.1:DENY 和vsftpd:192.168.57.9:DENY
# 表明限制IP为192.168.57.1/192.168.57.9主机访问IP为192.168.57.2的FTP服务器
# 此时FTP服务器虽可以PING通，但无法连接
tcp_wrappers=YES

[root@mail ~]# ftp 192.168.3.55
*lcd客户端目录切换，方便上传下载文件指定目录
Connected to 192.168.3.55.
220 (vsFTPd 2.0.5)
530 Please login with USER and PASS.
530 Please login with USER and PASS.
KERBEROS_V4 rejected as an authentication type
Name (192.168.3.55:root): hadoop
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> lcd /etc
Local directory now /etc
ftp> put inittab
local: inittab remote: inittab
227 Entering Passive Mode (192,168,3,55,189,245)
150 Ok to send data.
226 File receive OK.
1666 bytes sent in 9.9e-05 seconds (1.6e+04 Kbytes/s)
ftp> ls
227 Entering Passive Mode (192,168,3,55,130,228)
150 Here comes the directory listing.
-rw-r--r--    1 500      500           532 May 07 20:11 fstab
-rw-r--r--    1 500      500          1666 May 07 20:18 inittab
226 Directory send OK.
ftp> pwd
257 "/home/hadoop"
[root@mail ~]# cd /home/hadoop/
[root@mail hadoop]# ls
fstab  inittab

*将用户禁固在其家目录下，避免到处逛不安全
[root@mail hadoop]# vim /etc/vsftpd/vsftpd.conf
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd/chroot_list
[root@mail hadoop]# vim /etc/vsftpd/chroot_list
hadoop
[root@mail hadoop]# service vsftpd restart
Shutting down vsftpd:                                      [  OK  ]
Starting vsftpd for vsftpd:                                [  OK  ]
[root@mail hadoop]# ftp 192.168.3.55
Connected to 192.168.3.55.
220 (vsFTPd 2.0.5)
530 Please login with USER and PASS.
530 Please login with USER and PASS.
KERBEROS_V4 rejected as an authentication type
Name (192.168.3.55:root): hadoop
331 Please specify the password.
Password:
230 Login successful.
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> pwd
257 "/"
ftp> cd /etc
550 Failed to change directory.
*禁固本地所有用户在其家目录
[root@mail ~]# vim /etc/vsftpd/vsftpd.conf
chroot_local_user=YES

*用下面两项来控制谁能登陆谁不能
[root@mail vsftpd]# vim /etc/vsftpd/vsftpd.conf
*如果没有userlist_deny这一项，默认在userlist里面的用户都不允许
userlist_enable=YES
userlist_deny=YES
[root@mail vsftpd]# vim user_list
hadoop
[root@mail vsftpd]# ftp 192.168.3.55
Connected to 192.168.3.55.
220 (vsFTPd 2.0.5)
530 Please login with USER and PASS.
530 Please login with USER and PASS.
KERBEROS_V4 rejected as an authentication type
Name (192.168.3.55:root): hadoop
530 Permission denied.
Login failed.

***vsftpd基于ssl的认证
[root@mail ~]# cd /etc/pki/CA
[root@mail CA]# mkdir certs newcerts crl
[root@mail CA]# touch index.txt
[root@mail CA]# echo 01 > serial
[root@mail CA]# (umask 077;openssl genrsa -out private/cakey.pem 2048)
Generating RSA private key, 2048 bit long modulus
........+++
..................+++
e is 65537 (0x10001)
[root@mail CA]# openssl req -new -x509 -key private/cakey.pem -out cacert.pem -days 3650
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [GB]:CN
State or Province Name (full name) [Berkshire]:HB
Locality Name (eg, city) [Newbury]:ZZ
Organization Name (eg, company) [My Company Ltd]:YuLiang
Organizational Unit Name (eg, section) []:Tech
Common Name (eg, your name or your server's hostname) []:ca.yuliang.com
Email Address []:
[root@mail CA]# 
[root@mail CA]# mkdir /etc/vsftpd/ssl
[root@mail CA]# cd /etc/vsftpd/ssl/
[root@mail ssl]# (umask 077;openssl genrsa -out vsftpd.key 2048)
Generating RSA private key, 2048 bit long modulus
.....................................................................................................+++
.........................+++
e is 65537 (0x10001)
[root@mail ssl]# openssl req -new -key vsftpd.key -out vsftpd.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [GB]:CN
State or Province Name (full name) [Berkshire]:HB
Locality Name (eg, city) [Newbury]:ZZ
Organization Name (eg, company) [My Company Ltd]:YuLiang
Organizational Unit Name (eg, section) []:ftp.yuliang.com
Common Name (eg, your name or your server's hostname) []:
[root@mail ssl]# openssl req -new -key vsftpd.key -out vsftpd.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [GB]:CN
State or Province Name (full name) [Berkshire]:HB
Locality Name (eg, city) [Newbury]:ZZ
Organization Name (eg, company) [My Company Ltd]:YuLiang      
Organizational Unit Name (eg, section) []:Tech
Common Name (eg, your name or your server's hostname) []:ftp.yuliang.com
Email Address []:

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
[root@mail ssl]# 
[root@mail ssl]# openssl ca -in vsftpd.csr -out vsftpd.crt
Using configuration from /etc/pki/tls/openssl.cnf
Error opening CA private key ../../CA/private/cakey.pem
8101:error:02001002:system library:fopen:No such file or directory:bss_file.c:352:fopen('../../CA/private/cakey.pem','r
')8101:error:20074002:BIO routines:FILE_CTRL:system lib:bss_file.c:354:
unable to load CA private key
[root@mail ssl]# 
[root@mail ssl]# vim /etc/pki/tls/openssl.cnf 
[ CA_default ]

dir             = /etc/pki/CA           # Where everything is kept
[root@mail ssl]# openssl ca -in vsftpd.csr -out vsftpd.crt
[root@mail ssl]# vim /etc/vsftpd/vsftpd.conf
#ssl or tls
ssl_enable=YES
ssl_sslv3=YES
ssl_tlsv1=YES
allow_anon_ssl=NO
force_local_data_ssl=YES
force_local_logins_ssl=YES
rsa_cert_file=/etc/vsftpd/ssl/vsftpd.crt
rsa_private_key_file=/etc/vsftpd/ssl/vsftpd.key
[root@mail ssl]# service vsftpd restart
Shutting down vsftpd:                                      [  OK  ]
Starting vsftpd for vsftpd:                                [  OK  ]




官方文档：vsftp基于mysql用户认证

安装vsftpd、mysql和phpmyadmin
Vsftp没有内置的MySQL支持，所以我们必须使用PAM来认证：
sudo apt-get install vsftpd libpam-mysql mysql-server mysql-client phpmyadmin
随后会询问下列问题：
New password for the MySQL "root" user: <-- yourrootsqlpassword
Repeat password for the MySQL "root" user: <-- yourrootsqlpassword
Web server to reconfigure automatically: <-- apache2
创建MySQL数据库
现在我们创建名为vsftpd的数据库和名为vsftpd的MySQL账户（用于vsftpd进程连接vsftpd数据库）：
mysql -u root -p
CREATE DATABASE vsftpd;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP ON vsftpd.* TO 'vsftpd'@'localhost' IDENTIFIED BY 'ftpdpass';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP ON vsftpd.* TO 'vsftpd'@'localhost.localdomain' IDENTIFIED BY 'ftpdpass';
FLUSH PRIVILEGES;
ftpdpass换成你想要的密码，然后创建表：
USE vsftpd;
CREATE TABLE `accounts` (
`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`username` VARCHAR( 30 ) NOT NULL ,
`pass` VARCHAR( 50 ) NOT NULL ,
UNIQUE (
`username`
)
) ENGINE = MYISAM ;
quit;

配置vsftpd
首先创建一个vsftpd的用户（/home/vsftpd），属于nogroup。vsftpd进程运行在该用户下，虚拟用户的FTP目录会放置在/home/vsftpd下（如/home/vsftpd/user1, /home/vsftpd/user2）
useradd --home /home/vsftpd --gid nogroup -m --shell /bin/false vsftpd
备份初始的/etc/vsftpd.conf文件，创建新的：
cp /etc/vsftpd.conf /etc/vsftpd.conf_orig
cat /dev/null > /etc/vsftpd.conf

vi /etc/vsftpd.conf
内容如下：
listen=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
nopriv_user=vsftpd
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/vsftpd.pem
guest_enable=YES
guest_username=vsftpd
local_root=/home/vsftpd/$USER
user_sub_token=$USER
virtual_use_local_privs=YES
user_config_dir=/etc/vsftpd_user_conf
allow_writeable_chroot=YES
	RHLE7以后权限加强了，必须有这一句 

mkdir /etc/vsftpd_user_conf
cp /etc/pam.d/vsftpd /etc/pam.d/vsftpd_orig
cat /dev/null > /etc/pam.d/vsftpd
vi /etc/pam.d/vsftpd
auth required pam_mysql.so user=vsftpd passwd=ftpdpass host=localhost db=vsftpd table=accounts usercolumn=username passwdcolumn=pass crypt=2
account required pam_mysql.so user=vsftpd passwd=ftpdpass host=localhost db=vsftpd table=accounts usercolumn=username passwdcolumn=pass crypt=2

最后，我们重启vsftpd：
sudo service vsftpd restart

创建虚拟用户
mysql -u root -p
USE vsftpd;
创建名为testuser，密码为secret（会用MySQL的password函数加密）：
INSERT INTO accounts (username, pass) VALUES('testuser', PASSWORD('secret'));
quit;

testuser的根目录应该是 /home/vsftpd/testuser，但麻烦的是vsftpd不会自动创建该目录的，所以我们得自个手动创建，同时确保它的属于vsftpd用户和nogroup用户组。
mkdir /home/vsftpd/testuser
chown vsftpd:nogroup /home/vsftpd/testuser

最后试下能否正常登录
ftp localhost
数据库管理
用phpmyadmin管理mysql数据库最方便了。只要注意在设定密码时选择PASSWORD函数j就行。还有就是新增虚拟用户时别忘了手动新建虚拟用户的根目录。






***NFS文件系统：强调一下，除了服务端要装nfs-utils外，客户端也要装，不然不能识别nfs
服务器端：nfs-utils
	nfs: nfsd(nfs主服务), mountd(接受客户端挂载请求), quotad(限定客户端配额)
	nfsd: 主服务2049/tcp, 2049/udp端口不变
	mountd: 端口由rpc随机分配
	quotad: 端口由rpc随机分配
		半随机的
配置文件：
/etc/exports
格式：/path/to/somedir CLIENT_LIST（多个客户之间使用空白字符分隔）
	每个客户端后面必须跟一个小括号，里面定义了此客户访问特性，如访问权限等
	172.16.0.0/16(ro,async) 192.16.0.0/24(rw,sync)
showmount命令：
	showmount -e NFS_SERVER: 查看NFS服务器“导出”的各文件系统
	showmount -a NFS_SERVER: 查看NFS服务器所有被挂载的文件系统及其挂载的客户端对应关系列表
	showmount -d NFS_SERVER: 显示NFS服务器所有导出的文件系统中被客户端挂载了文件系统列表

客户端使用mount命令挂载：
	mount -t nfs NFS_SERVER:/PATH/TO/SOME_EXPORT  /PATH/TO/SOMEWHRERE

文件系统导出属性：
	ro:
	rw:
	sync:
	async:
	root_squash: 将root用户映射为来宾账号；
	no_root_squash: 保留root的权限
	all_squash: 
	anonuid, anongid: 指定映射的来宾账号的UID和GID；
让mountd和quotad等进程监听在固定端口，编辑配置文件/etc/sysconfig/nfs

exportfs命令：可以立即生效以免正在存的人因为重启服务而崩溃
	-a：跟-r或-u选项同时使用，表示重新挂载所有文件系统或取消导出所有文件系统；
	-r: 重新导出
	-u: 取消导出
	-v: 显示详细信息

[root@mail ~]# service nfs start
Starting NFS services:                                     [  OK  ]
Starting NFS quotas:                                       [  OK  ]
Starting NFS daemon:                                       [  OK  ]
Starting NFS mountd:                                       [  OK  ]
[root@mail ~]# 
[root@mail ~]# netstat -tnlp | grep "rpc"
tcp        0      0 0.0.0.0:874                 0.0.0.0:*                   LISTEN      2812/rpc.statd      
tcp        0      0 0.0.0.0:752                 0.0.0.0:*                   LISTEN      30253/rpc.mountd    
tcp        0      0 0.0.0.0:720                 0.0.0.0:*                   LISTEN      30220/rpc.rquotad   
[root@mail ~]# 

*nfs会向rpc注册申请随机端口
[root@mail ~]# rpcinfo -p localhost
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp    871  status
    100024    1   tcp    874  status
    100011    1   udp    717  rquotad
    100011    2   udp    717  rquotad
    100011    1   tcp    720  rquotad
    100011    2   tcp    720  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    4   udp   2049  nfs
    100021    1   udp  60754  nlockmgr
    100021    3   udp  60754  nlockmgr
    100021    4   udp  60754  nlockmgr
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100003    4   tcp   2049  nfs
    100021    1   tcp  56923  nlockmgr
    100021    3   tcp  56923  nlockmgr
    100021    4   tcp  56923  nlockmgr
    100005    1   udp    749  mountd
    100005    1   tcp    752  mountd
    100005    2   udp    749  mountd
    100005    2   tcp    752  mountd
    100005    3   udp    749  mountd
    100005    3   tcp    752  mountd
*而rpc自身的服务器端应用端口就只有下面几个
[root@mail ~]# service nfs stop
Shutting down NFS mountd:                                  [  OK  ]
Shutting down NFS daemon:                                  [  OK  ]
Shutting down NFS quotas:                                  [  OK  ]
[root@mail ~]# rpcinfo -p localhost
   program vers proto   port
    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp    871  status
    100024    1   tcp    874  status
[root@mail ~]# 
*nfs软件提供好几个服务
[root@mail ~]# rpm -ql nfs-utils | grep "init.d"
主服务：
/etc/rc.d/init.d/nfs
锁服务：为了避免多个用户同时操作一个文件导致崩溃，第一个人会向rpc申请锁，其他人不能应用
/etc/rc.d/init.d/nfslock
/etc/rc.d/init.d/rpcgssd
/etc/rc.d/init.d/rpcidmapd
/etc/rc.d/init.d/rpcsvcgssd
[root@mail ~]# mkdir /var/share
[root@mail ~]# vim /etc/exports 
/var/share      192.168.3.0/24(ro,async)
[root@mail ~]# service nfs restart
*在客户端也可以查看
[root@RHEL6 ~]# showmount -e 192.168.3.55
Export list for 192.168.3.55:
/var/share 192.168.3.0/24
[root@RHEL6 ~]# 
[root@RHEL6 ~]# mount -t nfs 192.168.3.55:/var/share /media
[root@RHEL6 ~]# ls /media/
[root@RHEL6 ~]# 
[root@RHEL5 ~]# cp /etc/fstab /var/share/
[root@RHEL6 ~]# ls /media/
fstab
[root@RHEL5 ~]# vim /etc/exports 
/var/share      192.168.3.0/24(ro,async)
/var/log        192.168.3.0/24(ro)
[root@RHEL5 ~]# exportfs -arv
exporting 192.168.3.0/24:/var/share
exporting 192.168.3.0/24:/var/log
*显示被客户端挂载了的
[root@RHEL5 ~]# showmount -d 192.168.3.55
Directories on 192.168.3.55:
/var/share
[root@RHEL5 ~]# 

*服务器端通过UID来标示用户，毕竟是两个主机，UID一样名字不一样被视为同一权限用户
[root@RHEL5 ~]# id hadoop
uid=500(hadoop) gid=500(hadoop) groups=500(hadoop)
[root@RHEL5 ~]# setfacl -m u:hadoop:rwx /var/share
[root@RHEL5 ~]# su - hadoop
[hadoop@RHEL5 ~]$ cd /var/share/
[hadoop@RHEL5 share]$ touch a.hadoop
[hadoop@RHEL5 share]$ ll
total 4
-rw-rw-r-- 1 hadoop hadoop   0 May 10 01:53 a.hadoop
-rw-r--r-- 1 root   root   532 May 10 01:15 fstab
[root@RHEL6 ~]# groupadd -g 500 openstack
[root@RHEL6 ~]# useradd -g 500 -u 500 openstack
[root@RHEL6 ~]# ll /media/
total 4
-rw-rw-r--. 1 openstack openstack   0 May 10 01:53 a.hadoop
-rw-r--r--. 1 root      root      532 May 10 01:15 fstab
[root@RHEL6 ~]# 
*默认情况下root用户是不能删除UID挂载nfs里面的文件，但是可以通过no_root_squash设置保留root权限
[root@RHEL6 media]# rm -rf a.hadoop 
rm: cannot remove `a.hadoop': Permission denied
[root@RHEL6 media]# rm -rf fstab
rm: cannot remove `fstab': Permission denied

*开机自动挂载nfs时，千万注意如果nfs服务器没开机，那么这边也开不了机，要用到_rnetdev忽略才能正常启动
[root@RHEL6 media]# vim /etc/fstab 
192.168.3.55:/var/share /media      nfs     defaults,_rnetdev	0 0

*让mountd和quotad等进程监听在固定端口，编辑配置文件/etc/sysconfig/nfs
[root@RHEL6 media]# vim /etc/sysconfig/nfs
RQUOTAD_PORT=875
LOCKD_TCPPORT=32803
LOCKD_UDPPORT=32769
MOUNTD_PORT=892

samba: 主要目的就是夸平台
	linux<==>windowns<==>unix
	夸平台实现文件交换很实用，ftp不太实用
	137/udp, 138/udp, 139/tcp, 445/tcp
	NetBIOS：Windows基于主机实现互相通信的机制，15个字符
	
	三种服务
	nmbd: netbios
	smbd: cifs
	winbindd: 可以让Linux加入windows AD中去

	UNC路径：\\SERVER\share_file
	
	windows服务，Linux客户
		交互式：
			# smbclient -L HOST -U USERNAME
			获取共享信息之后
			# smbclient //SERVER -U USERNAME

		基于挂载的方式：
			mount -t CIFS //SERVER /PATH -o username=USERNAME,password=PASSWORD

	linux服务，windows客户
		服务脚本
		/usr/lib/systemd/system/nmb.service
		/usr/lib/systemd/system/smb.service
		主配置文件
		/etc/samba/smb.conf
			全局设定：所有的共享设定
			特定设定：家目录、打印机、自定义共享
		samba用户：
			账号：都是系统用户，/etc/passwd
			密码：samba服务自有密码文件
				将系统用户添加为samba的命令：smbpasswd

				smbpasswd:
				-a sys_user: 添加系统用户为samba用户
				-d: 禁用
				-e: 启用
				-x: 删除
		samba-swat图形界面供samba专家使用




Network Time Protocol(NTP，网络时间协议)用于同步它所有客户端时钟的服务。NTP服务器将本地系统的时钟与一个公共的NTP服务器同步然后作为时间主机提供服务，使本地网络的所有客户端能同步时钟。

　　同步时钟最大的好处就是相关系统上日志文件中的数据，如果网络中使用中央日志主机集中管理日志，得到的日志结果就更能反映真实情况。在同步了时钟的网络中，集中式的性能监控、服务监控系统能实时的反应系统信息，系统管理员可以快速的检测和解决系统错误。

　　ntp时间服务器是一个简单的常用的服务器，工作中我们只要做到会用就行，能搭建起来就可以了，不用太去深入研究ntp时间服务器的原理。

 

服务端的配置：

　　第一步，安装NTP服务：

　　1）rpm -ivh ntp-4.2.2p1-8.el5.centos.1.rpm

　　2）yum install -y ntp ntpdate

 

　　第二步，配置NTP服务：

　　编辑配置文件/etc/ntp.conf ，配置之前记得先备份文件。          

　　restrict default kod nomodify notrap nopeer noquery　　　　　　　　　　　　　　　restrict、default定义默认访问规则，nomodify禁止远程主机修改本地服务器

　　restrict -6 default kod nomodify notrap nopeer noquery   ===== 》》》》》》》　配置，notrap拒绝特殊的ntpdq捕获消息，noquery拒绝btodq/ntpdc查询　　

　　restrict 127.0.0.1　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　（这里的查询是服务器本身状态的查询）。

　　restrict -6 ::1

　　

　　restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap　===== 》》》》》》 这句是手动增加的，意思是指定的192.168.1.0--192.168.1.254的服务器都

　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　　 可以使用ntp服务器来同步时间。

　　server 192.168.1.117　　　　　　　　　　　　　　　　　　　 ===== 》》》》》》   这句也是手动添加的，可以将局域网中的指定ip作为局域网内的ntp服务器。

　　server 0.centos.pool.ntp.org

　　server 1.centos.pool.ntp.org　　　　　　　　　　　　　　　　===== 》》》》》》 这3个域名都是互联网上的ntp服务器，也还有许多其他可用的ntp服务器，能连上

　　server 2.centos.pool.ntp.org 　　　　　　　　　　　　　　　　　　　　　　　　　　外网时，本地会跟这几个ntp服务器上的时间保持同步。

 

　　server  127.127.1.0     # local clock 　　　　　　　　　　　   ===== 》》》》》》  当服务器与公用的时间服务器失去联系时，就是连不上互联网时，以局域网内的时

　　fudge   127.127.1.0 stratum 10　　　　　　　　　　　　　　　　　　　　　　　　　间服务器为客户端提供时间同步服务。

 

　　第三步，启动NTP服务：

　　/etc/init.d/ntpd start　　　　　　　　　　　　　　　　当前启动ntpd服务

　　chkconfig  ntpd on　　　　　　　　　　　　　　　　　下次开机自启ntpd服务

　　

　　第四步，检查时间服务器是否正确同步

　　在服务端执行  ntpq -p　　下面是我在自己的服务器上面的测试的结果，仅供参考：

　　

　　当所有远程服务器（不是本地服务器）的jitter值都为4000，并且reach和dalay的值是0时，就表示时间同步有问题。可能原因有2个：

　　1）服务器端的防火墙设置，阻断了123端口（可以用 iptables -t filter -A INPUT -p udp --destination-port 123 -j ACCEPT 解决）

　　2）每次重启ntp服务器之后，大约3-5分钟客户端才能与服务端建立连接，建立连接之后才能进行时间同步，否则客户端同步时间时会显示

　　　no server suitable for synchronization found的报错信息，不用担心，等会就可以了。

 

客户端的配置：

　　第一步，客户端安装NTP服务：

　　yum install -y ntp

　　

　　第二步，同步时间：

　　ntpdate   服务器IP或者域名


			