虚拟用户：仅用于访问某服务的数字标识；
用户：字符串，凭证
MTA：邮件传输代理，SMTP服务器
	SMTP：(25/tcp)
	sendmail, UUCP
		单体结构，SUID，配置文件语法(m4编写)
	qmail：由一位数学家写的，后来不玩了
	postfix：模块化设计，安全，跟sendmail兼容，效率高
	exim: MTA
	Exchange (Windows, 异步消息协作平台)

SASL: Simple Authintication Secure Layer, 简单认证安全层，v2认证框架
	默认情况下sasl服务器是基于pam认证的，也就是/etc/passwd文件
	当时这种局限性很明显，所以有了下面这种
	cyrus-sasl
	courier-authlib
	
MDA：mail delivery agent
	procmail
	maildrop
	
MRA: mail retrieval agent（pop3, imap4）
	cyrus-imap
	dovecot
	
MUA: mail user agent
	Outlook Express, Outlook
	Foxmail
	Thunderbird
	Evolution
	mutt(文本界面)
	
Webmail:
	Openwebmail
	squirrelmail
	Extmail(Extman)
		EMOS, CentOS
		

发邮件：Postfix + SASL (courier-authlib) + MySQL（可以实现虚拟用户认证）
收邮件：Dovecot + MySQL
webmail：Extmail + Extman + httpd

postfix的配置文件：
	postfix模块化:
		master: /etc/postfix/master.cf（服务器所有进程的配置文件，包括主进程、子进程）
		main: /etc/postfix/main.cf（实现各种功能的主配置文件）
		主配置文件格式：{参数 = 值}参数必须写在行的绝对行首，以空白开头的行被认为是上一行的延续
			
postconf: 配置postfix的管理工具
	-d: 显示默认没有改动的配置
	-n: 修改了的配置
	-m: 显示支持的查找表类型
	-A: 显示支持的SASL客户端插件类型
	-a: 服务器端支持的SASL插件类型
	-e PARMATER=VALUE: 更改某参数配置信息，并保存至main.cf文件中
	
smtp状态码：
1xx: 纯信息
2xx: 正确
3xx: 上一步操作尚未完成，需要继续补充
4xx: 暂时性错误
5xx: 永久性错误

smtp协议命令：
	helo (smtp协议)
	ehlo (esmtp协议)
	mail from:
	rcpt to:
	
alias: 邮件别名

abc@magedu.com: postmaster@magedu.com


/etc/aliases --> hash --> /etc/aliases.db（类似于二进制的东西，查询速度会快一些）

# newaliases命令可以将/etc/aliases散列成/etc/aliases.db

postfix默认把本机的IP地址所在的网段识别为本地网络，并且为之中继邮件；

SMTP: 会话过程
	helo
	mail from
	rcpt to
	data
	.
	quit

***安装postfix全过程
*先卸载系统自带的post用户和组
[root@PXE1 postfix-3.1.0]# groupdel postfix
groupdel: cannot remove the primary group of user 'postfix'
[root@PXE1 postfix-3.1.0]# id postfix
uid=89(postfix) gid=89(postfix) groups=89(postfix),12(mail)
[root@PXE1 postfix-3.1.0]# groupdel postfix
groupdel: cannot remove the primary group of user 'postfix'
[root@PXE1 postfix-3.1.0]# userdel -r postfix
userdel: /var/spool/postfix not owned by postfix, not removing
[root@PXE1 postfix-3.1.0]# groupdel postfix
groupdel: group 'postfix' does not exist
[root@PXE1 postfix-3.1.0]# userdel -r postfix
userdel: user 'postfix' does not exist
 
*安装必要的post用户和组
[root@PXE1 postfix-3.1.0]# groupadd -g 2525 postfix
[root@PXE1 postfix-3.1.0]# useradd -g 2525 -u 2525 -M -s /sbin/nologin postfix
[root@PXE1 postfix-3.1.0]# groupadd -g 2526 postdrop
[root@PXE1 postfix-3.1.0]# useradd -g 2526 -u 2526 -M -s /sbin/nologin postdrop
[root@PXE1 postfix-3.1.0]# id postfix
uid=2525(postfix) gid=2525(postfix) groups=2525(postfix)
[root@PXE1 postfix-3.1.0]# id postdrop
uid=2526(postdrop) gid=2526(postdrop) groups=2526(postdrop)
[root@PXE1 postfix-3.1.0]# make makefiles 'CCARGS=-DHAS_MYSQL -I/usr/local/mysql/include -DUSE_SASL_AUTH -DUSE_CYRUS_SASL -I/usr/include/sasl  -DUSE_TLS ' 'AUXLIBS=-L/usr/local/mysql/lib -lmysqlclient -lz -lm -L/usr/lib/sasl2 -lsasl2  -lssl -lcrypto'
(echo "# Do not edit -- this file documents how Postfix was built for your machine."; /bin/sh makedefs) > makedefs.tmpNo <db.h> include file found.
Install the appropriate db*-devel package first.
make: *** [Makefiles] Error 1
make: *** [makefiles] Error 2
[root@PXE1 postfix-3.1.0]# yum install db*-devel
Installing     : glib2-devel-2.22.5-5.el6.i686                                                  1/5 
Installing     : db4-cxx-4.7.25-16.el6.i686                                                     2/5 
Installing     : 1:dbus-devel-1.2.24-3.el6.i686                                                 3/5 
Installing     : db4-devel-4.7.25-16.el6.i686                                                   4/5 
Installing     : dbus-glib-devel-0.86-5.el6.i686                                                
[root@PXE1 postfix-3.1.0]# make makefiles 'CCARGS=-DHAS_MYSQL -I/usr/local/mysql/include -DUSE_SASL_AUTH -DUSE_CYRUS_SASL -I/usr/include/sasl  -DUSE_TLS ' 'AUXLIBS=-L/usr/local/mysql/lib -lmysqlclient -lz -lm -L/usr/lib/sasl2 -lsasl2  -lssl -lcrypto'
[root@PXE1 postfix-3.1.0]# yum install cyrus-sasl-devel
[root@PXE1 postfix-3.1.0]# make & make install
[root@PXE1 ~]# postfix start
postfix: warning: smtputf8_enable is true, but EAI support is not compiled in
postsuper: warning: smtputf8_enable is true, but EAI support is not compiled in
postfix/postlog: warning: smtputf8_enable is true, but EAI support is not compiled in
postfix/postfix-script: warning: not owned by postfix: /var/lib/postfix/.
postfix/postlog: warning: smtputf8_enable is true, but EAI support is not compiled in
postfix/postfix-script: warning: not owned by postfix: /var/lib/postfix/./master.lock
postfix/postlog: warning: smtputf8_enable is true, but EAI support is not compiled in
postfix/postfix-script: warning: not owned by postfix: /var/spool/postfix/private
postfix/postlog: warning: smtputf8_enable is true, but EAI support is not compiled in
postfix/postfix-script: warning: not owned by postfix: /var/spool/postfix/public
postfix/postlog: warning: smtputf8_enable is true, but EAI support is not compiled in
postfix/postfix-script: warning: not owned by group postdrop: /var/spool/postfix/public
postfix/postlog: warning: smtputf8_enable is true, but EAI support is not compiled in
postfix/postfix-script: starting the Postfix mail system
postfix/postlog: warning: smtputf8_enable is true, but EAI support is not compiled in
postfix/postfix-script: fatal: mail system startup failed
[root@PXE1 ~]# 
[root@PXE1 ~]# postconf "smtputf8_enable = no"
[root@PXE1 ~]# postfix start
postfix/postfix-script: warning: not owned by postfix: /var/lib/postfix/.
postfix/postfix-script: warning: not owned by postfix: /var/lib/postfix/./master.lock
postfix/postfix-script: warning: not owned by postfix: /var/spool/postfix/private
postfix/postfix-script: warning: not owned by postfix: /var/spool/postfix/public
postfix/postfix-script: warning: not owned by group postdrop: /var/spool/postfix/public
postfix/postfix-script: starting the Postfix mail system
postfix/postfix-script: fatal: mail system startup failed
[root@PXE1 ~]# chown -R postfix /var/lib/postfix/
[root@PXE1 ~]# chown -R postfix /var/spool/postfix/
[root@PXE1 ~]# chgrp postdrop /var/spool/postfix/public/
[root@PXE1 ~]# postfix start
postfix/postfix-script: warning: not owned by root: /var/spool/postfix/.
postfix/postfix-script: warning: not owned by root: /var/spool/postfix/pid
postfix/postfix-script: starting the Postfix mail system
[root@PXE1 ~]# chown root /var/spool/postfix/.
[root@PXE1 ~]# chown root /var/spool/postfix/pid/
[root@PXE1 ~]# postfix start
postfix/postfix-script: fatal: the Postfix mail system is already running
[root@PXE1 ~]# netstat -tnlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State       PID/Program name   
tcp        0      0 127.0.0.1:9000              0.0.0.0:*                   LISTEN      1336/php-fpm.conf)  
tcp        0      0 0.0.0.0:3306                0.0.0.0:*                   LISTEN      1701/mysqld         
tcp        0      0 0.0.0.0:22                  0.0.0.0:*                   LISTEN      1347/sshd           
tcp        0      0 0.0.0.0:25                  0.0.0.0:*                   LISTEN      8444/master         
tcp        0      0 :::22                       :::*                        LISTEN      1347/sshd           
[root@PXE1 ~]# 


***安装完成之后，下面演示怎么发邮件
*确保/etc/aliases这个别名文件转换成了/etc/aliases.db，快速检索，可以用newaliase命令生成
[root@PXE1 ~]# cat /etc/aliases
#
#  Aliases in this file will NOT be expanded in the header from
#  Mail, but WILL be visible over networks or from /bin/mail.
#
#	>>>>>>>>>>	The program "newaliases" must be run after
#	>> NOTE >>	this file is updated for any changes to
#	>>>>>>>>>>	show through to sendmail.
#

# Basic system aliases -- these MUST be present.
mailer-daemon:	postmaster
postmaster:	root

# General redirections for pseudo accounts.
bin:		root
daemon:		root
adm:		root
lp:		root
sync:		root
shutdown:	root
halt:		root
mail:		root
news:		root
uucp:		root
operator:	root
games:		root
[root@PXE1 ~]# newaliases 
[root@PXE1 ~]# ls /etc/ | grep "alias"
aliases
aliases.db
[root@PXE1 ~]# telnet localhost 25
Trying ::1...
telnet: connect to address ::1: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 PXE1.localdomain ESMTP Postfix
helo
501 Syntax: HELO hostname
mail from:hadoop
250 2.1.0 Ok
rcpt to:openstack
250 2.1.5 Ok
data
354 End data with <CR><LF>.<CR><LF>
how are you?  
you know what!
i have done yet     
.
250 2.0.0 Ok: queued as D786582E95
quit
221 2.0.0 Bye
Connection closed by foreign host.
[root@PXE1 ~]# 
[root@PXE1 ~]# tail /var/log/maillog 
May  5 12:49:18 PXE1 postfix/smtpd[8476]: disconnect from localhost[127.0.0.1] helo=1 ehlo=1 mail=1 commands=3
May  5 12:57:55 PXE1 postfix/smtpd[8499]: warning: dict_nis_init: NIS domain name not set - NIS lookups disabled
May  5 12:57:55 PXE1 postfix/smtpd[8499]: connect from localhost[127.0.0.1]
May  5 12:58:25 PXE1 postfix/smtpd[8499]: D786582E95: client=localhost[127.0.0.1]
May  5 12:59:05 PXE1 postfix/cleanup[8503]: D786582E95: message-id=<20160505125825.D786582E95@PXE1.localdomain>
May  5 12:59:05 PXE1 postfix/qmgr[8446]: D786582E95: from=<hadoop@PXE1.localdomain>, size=346, nrcpt=1 (queue active)
May  5 12:59:05 PXE1 postfix/local[8504]: warning: dict_nis_init: NIS domain name not set - NIS lookups disabled
May  5 12:59:05 PXE1 postfix/local[8504]: D786582E95: to=<openstack@PXE1.localdomain>, orig_to=<openstack>, relay=local, delay=50, delays=50/0.02/0/0.01, dsn=2.0.0, status=sent (delivered to mailbox)
May  5 12:59:05 PXE1 postfix/qmgr[8446]: D786582E95: removed
May  5 13:00:03 PXE1 postfix/smtpd[8499]: disconnect from localhost[127.0.0.1] helo=0/1 mail=1 rcpt=1 data=1 quit=1 commands=4/5
[root@PXE1 ~]# su - openstack
[openstack@PXE1 ~]$ mail
Heirloom Mail version 12.4 7/29/08.  Type ? for help.
"/var/spool/mail/openstack": 1 message 1 new
>N  1 hadoop@PXE1.localdom  Thu May  5 12:59  15/497   
& 1
Message  1:
From hadoop@PXE1.localdomain  Thu May  5 12:59:05 2016
Return-Path: <hadoop@PXE1.localdomain>
X-Original-To: openstack
Delivered-To: openstack@PXE1.localdomain
Date: Thu,  5 May 2016 12:58:15 +0000 (GMT)
From: hadoop@PXE1.localdomain
Status: R

how are you?
you know what!
i have done yet

& 

*测试一下是否中继，默认情况下只要是本机所在网段都可以中继
[root@PXE1 ~]# telnet localhost 25
Trying ::1...
telnet: connect to address ::1: Connection refused
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
220 PXE1.localdomain ESMTP Postfix
hleo
502 5.5.2 Error: command not recognized
helo          
501 Syntax: HELO hostname
mail from:jerry@qq.com
250 2.1.0 Ok
rcpt to:a@yahoo.com
250 2.1.5 Ok
data
354 End data with <CR><LF>.<CR><LF>
hello   
I miss you!
.
250 2.0.0 Ok: queued as 26FD582E95
quit
221 2.0.0 Bye
Connection closed by foreign host.
[root@PXE1 ~]# tail /var/log/maillog 
May  5 12:59:05 PXE1 postfix/local[8504]: warning: dict_nis_init: NIS domain name not set - NIS lookups disabled
May  5 12:59:05 PXE1 postfix/local[8504]: D786582E95: to=<openstack@PXE1.localdomain>, orig_to=<openstack>, relay=local, delay=50, delays=50/0.02/0/0.01, dsn=2.0.0, status=sent (delivered to mailbox)
May  5 12:59:05 PXE1 postfix/qmgr[8446]: D786582E95: removed
May  5 13:00:03 PXE1 postfix/smtpd[8499]: disconnect from localhost[127.0.0.1] helo=0/1 mail=1 rcpt=1 data=1 quit=1 commands=4/5
May  5 13:10:04 PXE1 postfix/smtpd[8551]: warning: dict_nis_init: NIS domain name not set - NIS lookups disabled
May  5 13:10:04 PXE1 postfix/smtpd[8551]: connect from localhost[127.0.0.1]
May  5 13:11:39 PXE1 postfix/smtpd[8551]: 26FD582E95: client=localhost[127.0.0.1]
May  5 13:12:01 PXE1 postfix/cleanup[8555]: 26FD582E95: message-id=<20160505131139.26FD582E95@PXE1.localdomain>
May  5 13:12:01 PXE1 postfix/qmgr[8446]: 26FD582E95: from=<jerry@qq.com>, size=310, nrcpt=1 (queue active)
May  5 13:12:04 PXE1 postfix/smtpd[8551]: disconnect from localhost[127.0.0.1] helo=0/1 mail=1 rcpt=1 data=1 quit=1 unknown=0/1 commands=4/6
[root@PXE1 ~]# 

****一个完整意义上的邮件服务器
*提供SysV脚本
[root@PXE1 ~]# vim /etc/rc.d/init.d/postfix
写脚本
[root@PXE1 ~]# chmod +x /etc/rc.d/init.d/postfix 
[root@PXE1 ~]# chkconfig --add postfix
[root@PXE1 ~]# service postfix restart
Shutting down postfix:                                     [  OK  ]
Starting postfix:                                          [  OK  ]
[root@PXE1 ~]# vim /etc/postfix/main.cf
修改以下几项为您需要的配置
myhostname = mail.magedu.com
myorigin = magedu.com
mydomain = magedu.com
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
mynetworks = 192.168.1.0/24, 127.0.0.0/8

说明:
myorigin参数用来指明发件人所在的域名，即做发件地址伪装；
mydestination参数指定postfix接收邮件时收件人的域名，即您的postfix系统要接收到哪个域名的邮件；
myhostname 参数指定运行postfix邮件系统的主机的主机名，默认情况下，其值被设定为本地机器名；
mydomain 参数指定您的域名，默认情况下，postfix将myhostname的第一部分删除而作为mydomain的值；
mynetworks 参数指定你所在的网络的网络地址，postfix系统根据其值来区别用户是远程的还是本地的，如果是本地网络用户则允许其访问；
inet_interfaces 参数指定postfix系统监听的网络接口；

注意：
1、在postfix的配置文件中，参数行和注释行是不能处在同一行中的；
2、任何一个参数的值都不需要加引号，否则，引号将会被当作参数值的一部分来使用；
3、每修改参数及其值后执行 postfix reload 即可令其生效；但若修改了inet_interfaces，则需重新启动postfix；
4、如果一个参数的值有多个，可以将它们放在不同的行中，只需要在其后的每个行前多置一个空格即可；postfix会把第一个字符为空格或tab的文本行视为上一行的延续；
[root@PXE1 ~]# hostname mail.yuliang.com
[root@PXE1 ~]# vim /etc/sysconfig/network
NETWORKING=yes
HOSTNAME=mail.yuliang.com

*配置好DNS服务器
[root@mail named]# vim /etc/named.conf 
options {
        directory       "/var/named";
};

zone "." IN {
        type hint;
        file "named.ca";
};

zone "localhost" IN {
        type master;
        file "named.localhost";
};

zone "0.0.127.in-addr.arpa" IN {
        type master;
        file "named.loopback";
};

zone "yuliang.com" IN {
        type master;
        file "yuliang.com.zone";
};
zone "3.168.192.in-addr.arpa" IN {
        type master;
        file "3.168.192.zone";
};
[root@mail named]# vim /var/named/yuliang.com.zone
$TTL 600
yuliang.com.  IN        SOA     ns1.yuliang.com.        admin.yuliang.com (
                                2016050401
                                1H
                                5M
                                2D
                                6H )

yuliang.com.    IN      NS      ns1.yuliang.com.
                IN      MX 10   mail
mail            IN      A       192.168.3.111
www             IN      A       192.168.3.111
ns1             IN      A       192.168.3.111
[root@mail named]# vim /var/named/3.168.192.zone 
$TTL 600
@               IN      SOA     ns1.yuliang.com.        admin.yuliang.com. (
                                2016050401
                                1H
                                5M
                                2D
                                6H )

                IN      NS      ns1.yuliang.com.
111             IN      PTR     mail.yuliang.com.
111             IN      PTR     www.yuliang.com.
111             IN      PTR     ns1.yuliang.com.
[root@mail named]# cd /etc/postfix/
[root@mail postfix]# vim main.cf
mynetworks = 192.168.3.0/25, 127.0.0.0/8
myhostname = mail.yuliang.com
myorigin = $myhostname
mydomain = yuliang.com
mydestination=$myhostname, $mydomain, localhost, ns.$mydomain
[root@mail postfix]# service postfix restart
Shutting down postfix:                                     [  OK  ]
Starting postfix:                                          [  OK  ]
[root@mail postfix]# 

*测试一下是否给指定的网段中继
[root@mail postfix]# telnet mail.yuliang.com 25
Trying 192.168.3.111...
Connected to mail.yuliang.com.
Escape character is '^]'.
220 mail.yuliang.com ESMTP Postfix
helo mail.yuliang.com
250 mail.yuliang.com
mail from:abc@abc.com
250 2.1.0 Ok
rcpt to:obama@whitehouse.com
250 2.1.5 Ok
data
354 End data with <CR><LF>.<CR><LF>
hello
for testing
.
250 2.0.0 Ok: queued as 358C782E95
quit
221 2.0.0 Bye
Connection closed by foreign host.
[root@mail postfix]# 

*显然，本地中继完全没问题
[root@mail postfix]# tail /var/log/maillog 
May  5 14:39:56 PXE1 postfix/postfix-script[8853]: starting the Postfix mail system
May  5 14:39:56 PXE1 postfix/master[8855]: daemon started -- version 3.1.0, configuration /etc/postfix
May  5 14:41:38 PXE1 postfix/smtpd[8863]: warning: dict_nis_init: NIS domain name not set - NIS lookups disabled
May  5 14:41:38 PXE1 postfix/smtpd[8863]: connect from ns1.yuliang.com[192.168.3.111]
May  5 14:42:37 PXE1 postfix/smtpd[8863]: 358C782E95: client=ns1.yuliang.com[192.168.3.111]
May  5 14:42:55 PXE1 postfix/cleanup[8867]: 358C782E95: message-id=<20160505144237.358C782E95@mail.yuliang.com>
May  5 14:42:55 PXE1 postfix/qmgr[8858]: 358C782E95: from=<abc@abc.com>, size=335, nrcpt=1 (queue active)
May  5 14:42:57 PXE1 postfix/smtpd[8863]: disconnect from ns1.yuliang.com[192.168.3.111] helo=1 mail=1 rcpt=1 data=1 quit=1 commands=5
May  5 14:43:29 PXE1 postfix/smtp[8868]: connect to whitehouse.com[192.64.147.150]:25: Connection timed out
May  5 14:43:29 PXE1 postfix/smtp[8868]: 358C782E95: to=<obama@whitehouse.com>, relay=none, delay=74, delays=40/0.02/35/0, dsn=4.4.1, status=deferred (connect to whitehouse.com[192.64.147.150]:25: Connection timed out)

*修改一下mynetwork不给除127.0.0.1外的主机中继
[root@mail postfix]# vim main.cf
mynetworks = 127.0.0.0/8
*注意用telnet再连上来不认为是127.0.0.1，而是本机192.168.3.111，两个不同的概念
[root@mail ~]# service postfix restart
Shutting down postfix:                                     [  OK  ]
Starting postfix:                                          [  OK  ]
[root@mail ~]# 
[root@mail ~]# telnet mail.yuliang.com 25
Trying 192.168.3.111...
Connected to mail.yuliang.com.
Escape character is '^]'.
220 mail.yuliang.com ESMTP Postfix
helo   
501 Syntax: HELO hostname
mail from:abc@qq.com
250 2.1.0 Ok
rcpt to:obama@whitehouse.com
454 4.7.1 <obama@whitehouse.com>: Relay access denied
quit
221 2.0.0 Bye
Connection closed by foreign host.
[root@mail ~]# 

*用windows的OutlookExpress充当MUA来发送邮件
-->windows OutlookExprss已经发了一份邮件给openstack
*看日志，已收到
[root@mail ~]# tail /var/log/maillog 
May  5 15:20:51 PXE1 postfix/smtp[8983]: 358C782E95: to=<obama@whitehouse.com>, relay=none, delay=2315, delays=2278/0.02/38/0, dsn=4.4.1, status=deferred (connect to whitehouse.com[192.64.147.150]:25: Connection timed out)
May  5 15:48:56 PXE1 postfix/smtpd[8990]: warning: dict_nis_init: NIS domain name not set - NIS lookups disabled
May  5 15:48:56 PXE1 postfix/smtpd[8990]: connect from unknown[192.168.3.87]
May  5 15:48:56 PXE1 postfix/smtpd[8990]: F112782E9D: client=unknown[192.168.3.87]
May  5 15:48:57 PXE1 postfix/cleanup[8995]: F112782E9D: message-id=<ED1947CC5C1C475B9BE73380415B829A@372dbe460707424>
May  5 15:48:57 PXE1 postfix/qmgr[8970]: F112782E9D: from=<hadoop@yuliang.com>, size=696, nrcpt=1 (queue active)
May  5 15:48:57 PXE1 postfix/local[8996]: warning: dict_nis_init: NIS domain name not set - NIS lookups disabled
May  5 15:48:57 PXE1 postfix/smtpd[8990]: disconnect from unknown[192.168.3.87] helo=1 mail=1 rcpt=1 data=1 quit=1 commands=5
May  5 15:48:57 PXE1 postfix/local[8996]: F112782E9D: to=<openstack@yuliang.com>, relay=local, delay=0.11, delays=0.06/0.01/0/0.04, dsn=2.0.0, status=sent (delivered to mailbox)
May  5 15:48:57 PXE1 postfix/qmgr[8970]: F112782E9D: removed
[root@mail ~]# 
[root@mail ~]# su - openstack
[openstack@mail ~]$ mail
Heirloom Mail version 12.4 7/29/08.  Type ? for help.
"/var/spool/mail/openstack": 2 messages 1 new
    1 hadoop@PXE1.localdom  Thu May  5 12:59  16/508   
>N  2 Hadoop                Thu May  5 15:48  24/835   "Hello"

-->在windows上面写了一封邮件给obama@whitehouse.com测试给不给中继
-->立即显示错误信息如下：
由于服务器拒绝收件人之一，无法发送邮件。被拒绝的电子邮件地址是“obama|@whitehouse.com”。 
主题 'it's a secret', 帐户: '192.168.3.111', 服务器: '192.168.3.111', 协议: SMTP, 服务器响应: '454 4.7.1 <obama|@whitehouse.com>: Relay access denied', 端口: 25, 安全(SSL): 否, 服务器错误: 454, 错误号: 0x800CCC79


***安装一个收邮件的服务器
MRA: cyrus-imap, dovecot
*这里用dovecot的rpm包
dovecot依赖mysql
dovecot支持四种协议
pop3: 110/tcp
imap4: 143/tcp
pops, imaps
配置文件：/etc/dovecot.conf
自带SASL认证能力,不依赖sasl
邮箱格式：
	mbox：一个文件存储所有邮件
	maildir：一个文件存储一封邮件，所有邮件存储一个目录中
RHEL5和RHEL6上有配置有所不同，需要注意
[root@mail ~]# yum install dovecot
[root@mail ~]# vim /etc/dovecot/dovecot.conf
protocols = imap pop3 
[root@mail ~]# service dovecot start
Starting Dovecot Imap:                                     [  OK  ]
[root@mail ~]# netstat -tnlp
tcp        0      0 0.0.0.0:110                 0.0.0.0:*                   LISTEN      9134/dovecot        
tcp        0      0 0.0.0.0:143                 0.0.0.0:*                   LISTEN      9134/dovecot        

-->windows再发一份邮件给openstack, 通过dovecot来收邮件
*接收出错
[root@mail ~]# telnet mail.yuliang.com 110
Trying 192.168.3.111...
Connected to mail.yuliang.com.
Escape character is '^]'.
+OK Dovecot ready. <26ef.1.572b9f96.fBJMg19rUQYDhCnJYkd2EQ==@mail.yuliang.com>
USER openstack
+OK
PASS redhat
Connection closed by foreign host.
[root@mail ~]# 
[root@mail ~]# tail /var/log/maillog 
May  5 19:18:02 PXE1 postfix/qmgr[9728]: 36AE482F98: removed
May  5 19:18:02 PXE1 postfix/local[9958]: warning: dict_nis_init: NIS domain name not set - NIS lookups disabled
May  5 19:18:02 PXE1 postfix/local[9958]: 13C0E82F9A: to=<hadoop@yuliang.com>, relay=local, delay=0.06, delays=0.04/0.01/0/0.01, dsn=2.0.0, status=sent (delivered to mailbox)
May  5 19:18:02 PXE1 postfix/qmgr[9728]: 13C0E82F9A: removed
May  5 19:30:07 PXE1 postfix/qmgr[9728]: 358C782E95: from=<abc@abc.com>, size=335, nrcpt=1 (queue active)
May  5 19:30:41 PXE1 postfix/smtp[9961]: connect to whitehouse.com[192.64.147.150]:25: Connection timed out
May  5 19:30:41 PXE1 postfix/smtp[9961]: 358C782E95: to=<obama@whitehouse.com>, relay=none, delay=17306, delays=17272/0.03/35/0, dsn=4.4.1, status=deferred (connect to whitehouse.com[192.64.147.150]:25: Connection timed out)
May  5 19:32:06 PXE1 dovecot: pop3-login: Login: user=<openstack>, method=PLAIN, rip=192.168.3.111, lip=192.168.3.111, mpid=9969, secured
May  5 19:32:06 PXE1 dovecot: pop3(openstack): Error: user openstack: Initialization failed: mail_location not set and autodetection failed: Mail storage autodetection failed with home=/home/openstack
May  5 19:32:06 PXE1 dovecot: pop3(openstack): Error: Invalid user settings. Refer to server log for more information.
[root@mail ~]# 

*设置/etc/dovecot/conf.d/10-mail.conf配置文件如下：
[root@rhel6 ~]# grep -v '^#' /etc/dovecot/conf.d/10-mail.conf  |grep -v '^$' |grep -v '#'
mail_location = mbox:~/mail:INBOX=/var/mail/%u
mbox_write_locks = fcntl
[root@mail ~]# telnet mail.yuliang.com 110
Trying 192.168.3.111...
Connected to mail.yuliang.com.
Escape character is '^]'.
+OK Dovecot ready. <2714.1.572ba3a8.pc5+UGSDbMEbzhRkggo11g==@mail.yuliang.com>
user openstack
+OK
pass redhat
-ERR [IN-USE] Couldn't open INBOX: Internal error occurred. Refer to server log for more information. [2016-05-05 19:49:08]
Connection closed by foreign host.
[root@mail ~]# mkdir -p /home/openstack/mail/.imap/INBOX
[root@mail ~]# chown -R openstack:openstack /home/openstack/mail/.imap/INBOX
[root@mail ~]# 
[root@mail ~]# telnet mail.yuliang.com 110
Trying 192.168.3.111...
Connected to mail.yuliang.com.
Escape character is '^]'.
+OK Dovecot ready. <2755.2.572ba6ba.h7TRyUPfpRwBtJeNYhpRmA==@mail.yuliang.com>
user openstack
+OK
pass redhat
+OK Logged in.
LIST
+OK 4 messages:
1 454
2 806
3 800
4 757
.
quit 
+OK Logging out.
Connection closed by foreign host.
[root@mail ~]# 

*为了能让服务器网段内的所有主机都能收邮件
[root@mail ~]# vim /etc/dovecot/dovecot.conf
login_trusted_networks =192.168.3.0/24





例1：实现postfix基于客户端的访问控制
smtp: 
connection: smtpd_client_restrictions = check_client_access hash:/etc/postfix/access 
helo: smtpd_helo_restrictions = check_helo_access mysql:/etc/postfix/mysql_user
mail from: smtpd_sender_restrictions = 
rcpt to: smtpd_recipient_restrictions = 
data: smtpd_data_restrictions = 


*postconf -m：可查看限定模式支持哪些查找表，常用的有hash，mysql
[root@mail ~]# postconf -m
btree
cidr
environ
fail
hash
inline
internal
memcache
mysql
nis
pcre
pipemap
proxy
randmap
regexp
socketmap
static
tcp
texthash
unionmap
unix

查找表：
	访问控制文件
	/etc/postfix/access --> hash格式 --> /etc/postfix/access.db
	类似/etc/aliases --> /etc/aliases.db转换成二进制快
	obama@aol.com reject
	microsoft.com OK

[root@mail ~]# vim /etc/postfix/access 
-->windows OutlookExpree的IP地址
192.168.3.87    REJECT
[root@mail ~]# postmap /etc/postfix/access 
[root@mail ~]# ls /etc/postfix/
access             canonical      main.cf          master.cf        relocated
access.db          generic        main.cf.default  master.cf.proto  TLS_LICENSE
aliases            header_checks  main.cf.proto    postfix-files    transport
bounce.cf.default  LICENSE        makedefs.out     postfix-files.d  virtual
[root@mail ~]# 
[root@mail ~]# vim /etc/postfix/main.cf
添加一行：
smtpd_client_restrictions=check_client_access hash:/etc/postfix/access
[root@mail ~]# postconf -n | grep "smtpd_client"
smtpd_client_restrictions = check_client_access hash:/etc/postfix/access
[root@mail ~]# service postfix restart
Shutting down postfix:                                     [  OK  ]
Starting postfix:                                          [  OK  ]

-->windows OutlookExpree发一封邮件试试，直接显示如下：
由于服务器拒绝收件人之一，无法发送邮件。被拒绝的电子邮件地址是“openstack@yuliang.com”。 
主题 'sdf', 帐户: '192.168.3.111', 服务器: '192.168.3.111', 协议: SMTP, 
服务器响应: '554 5.7.1 <unknown[192.168.3.87]>: Client host rejected: Access denied', 
端口: 25, 安全(SSL): 否, 服务器错误: 554, 错误号: 0x800CCC79

*再测试一个限定域
[root@mail ~]# vim /etc/postfix/access
查看文件中注释的格式：
whitehouse.com  REJECT
[root@mail ~]# postmap /etc/postfix/access
[root@mail ~]# vim /etc/postfix/main.cf
smtpd_sender_restrictions=check_sender_access hash:/etc/postfix/access
[root@mail ~]# service postfix restart
Shutting down postfix:                                     [  OK  ]
Starting postfix:                                          [  OK  ]
[root@mail ~]# 
[root@mail ~]# telnet mail.yuliang.com 25
Trying 192.168.3.111...
Connected to mail.yuliang.com.
Escape character is '^]'.
220 mail.yuliang.com ESMTP Postfix
helo
501 Syntax: HELO hostname
mail from:obama@whitehouse.com
250 2.1.0 Ok
rcpt to:openstack@yuliang.com
554 5.7.1 <obama@whitehouse.com>: Sender address rejected: Access denied
quit
221 2.0.0 Bye
Connection closed by foreign host.
[root@mail ~]# 

*再测试一个不让发给某用户，自定义一个文件
[root@mail ~]# vim /etc/postfix/recipient
openstack@      REJECT
[root@mail ~]# postmap /etc/postfix/recipient 
[root@mail ~]# 
[root@mail ~]# vim /etc/postfix/main.cf
注意顺序：
smtpd_recipient_restrictions=check_recipient_access hash:/etc/postfix/recipient, permit_mynetworks, reject_unauth_destination
[root@mail ~]# service postfix restart
Shutting down postfix:                                     [  OK  ]
Starting postfix:                                          [  OK  ]
[root@mail ~]# telnet mail.yuliang.com 25
Trying 192.168.3.111...
Connected to mail.yuliang.com.
Escape character is '^]'.
220 mail.yuliang.com ESMTP Postfix
helo
501 Syntax: HELO hostname
mail from:1062817308@qq.com
250 2.1.0 Ok
rcpt to:openstack@yuliang.com 
554 5.7.1 <openstack@yuliang.com>: Recipient address rejected: Access denied
quit 
221 2.0.0 Bye
Connection closed by foreign host.
[root@mail ~]# 



例2：实现postfix基于服务端cyrus-sasl的认证功能
*什么是别名？
*很显然这个例子说明了就是将域内的用户重定向，发的邮件给了别名用户，本尊收不到
[root@mail ~]# vim /etc/aliases
a:              hadoop
tomcat:         hadoop
[root@mail ~]# newaliases 
[root@mail ~]# !telnet 
telnet mail.yuliang.com 25 
Trying 192.168.3.111...
Connected to mail.yuliang.com.
Escape character is '^]'.
220 mail.yuliang.com ESMTP Postfix
helo
501 Syntax: HELO hostname
mail from:root@yuliang.com  
250 2.1.0 Ok
rcpt to:tomcat@yuliang.com
250 2.1.5 Ok
data
354 End data with <CR><LF>.<CR><LF>
check it
.
250 2.0.0 Ok: queued as 22E5382F99
quit
221 2.0.0 Bye
Connection closed by foreign host.
[root@mail ~]# su - tomcat
[tomcat@mail ~]$ mail
No mail for tomcat
[tomcat@mail ~]$ exit
logout
[root@mail ~]# su - hadoop
[hadoop@mail ~]$ mail
Heirloom Mail version 12.4 7/29/08.  Type ? for help.
"/var/spool/mail/hadoop": 2 messages 2 new
>N  1 Mail Delivery System  Thu May  5 19:18  83/2718  "Undelivered Mail Returned to Sender"
 N  2 root@yuliang.com      Fri May  6 10:50  13/467   
& 

postfix + SASL 用户认证

1、启动sasl，启动sasl服务

/etc/rc.d/init.d/saslauthd
	/etc/sysconfig/saslauthd

	saslauthd -v: 显示当前主机saslauthd服务所支持的认证机制，默认为pam

[root@mail ~]# saslauthd -v
saslauthd 2.1.23
authentication mechanisms: getpwent kerberos5 pam rimap shadow ldap
*由此可见认证机制可以基于shadow文件，所以把sasl配置文件默认认证改为shadow
[root@mail ~]# vim /etc/sysconfig/saslauthd 
MECH=shadow
[root@mail ~]# service saslauthd status
saslauthd is stopped
[root@mail ~]# service saslauthd start
Starting saslauthd:                                        [  OK  ]
[root@mail ~]# chkconfig saslauthd on

*用一个testsaslauthd命令来测试sasl是否可以认证
[root@mail ~]# testsaslauthd -u openstack -p redhat
0: OK "Success."
[root@mail ~]# 

*用postconf -a 查看服务器端可以支持哪些认证机制，cyrus表明是sasl的接口
[root@mail ~]# postconf -a
cyrus
dovecot
[root@mail ~]# 



*主配置文件将上面实验的条目还原以免影响这次实验
[root@mail ~]# vim /etc/postfix/main.cf
只留：mynetworks =127.0.0.0/8
注释掉：smtpd_recipient_restrictions

加上这几行：
############################CYRUS-SASL############################
broken_sasl_auth_clients = yes
smtpd_recipient_restrictions=permit_mynetworks,permit_sasl_authenticated,reject_invalid_hostname,reject_non_fqdn_hostname,reject_unknown_sender_domain,reject_non_fqdn_sender,reject_non_fqdn_recipient,reject_unknown_recipient_domain,reject_unauth_pipelining,reject_unauth_destination
smtpd_sasl_auth_enable = yes
smtpd_sasl_local_domain = $myhostname
smtpd_sasl_security_options = noanonymous
smtpd_sasl_path = smtpd
smtpd_banner = Welcome to our $myhostname ESMTP,Warning: Version not Available!

*新建文件，认证模式
[root@mail ~]# vim /usr/lib/sasl2/smtpd.conf
pwcheck_method: saslauthd
mech_list: PLAIN LOGIN
[root@mail ~]# service postfix reload
Reloading postfix:                                         [  OK  ]
[root@mail ~]# 
[root@mail ~]# echo -n 'hadoop' | openssl base64
aGFkb29w
[root@mail ~]# echo -n 'PASSWORD' | openssl base64
PHRzd2NieXk4ODg+
[root@mail ~]# 

****这个地方强调一下，由于pwcheck_method是saslauthd那么/etc/sysconfig/saslauthd下MECH=pam一定要对应，这里用到的就不对
这个实验用的是/etc/shadow文件，所以要改成MECH=shadow，可以用saslauthd -v查看所有认证方式
[root@mail ~]# telnet mail.yuliang.com 25
Trying 192.168.3.111...
Connected to mail.yuliang.com.
Escape character is '^]'.
220 Welcome to our mail.yuliang.com ESMTP,Warning: Version not Available!
ehlo mail.yuliang.com
250-mail.yuliang.com
250-PIPELINING
250-SIZE 10240000
250-VRFY
250-ETRN
250-AUTH PLAIN LOGIN
250-AUTH=PLAIN LOGIN
250-ENHANCEDSTATUSCODES
250-8BITMIME
250 DSN
auth login
334 VXNlcm5hbWU6
aGFkb29w
334 UGFzc3dvcmQ6
PHRzd2NieXk4ODg+
235 2.7.0 Authentication successful
mail from:hadoop@yuliang.com
250 2.1.0 Ok
rcpt to:1062817308@qq.com
250 2.1.5 Ok
data
354 End data with <CR><LF>.<CR><LF>
A trial  
This is a test for authentication based on cyrus of sasl.
.
250 2.0.0 Ok: queued as ECD3D82F99
quit
221 2.0.0 Bye
Connection closed by foreign host.
[root@mail ~]# 

*使用另外一个MUA mutt
[root@mail ~]# yum install mutt
[root@mail ~]# mutt -f pop://openstack@mail.yuliang.com
生成格式如下：
q:Quit  d:Del  u:Undel  s:Save  m:Mail  r:Reply  g:Group  ?:Help
   1 N   May 07 Hadoop          (0.1K) hello




---Mutt: pop://openstack@mail.yuliang.com/ [Msgs:1 New:1 0.8K]---(date/date)-----------------(all)---



*****基于虚拟有户的虚拟域邮件系统架构
MUA(OutlookExpress)==>postfix==>Cyrus-SASL==>Courier-authlib==>mysql
1、courier简介

courier-authlib是Courier组件中的认证库，它是courier组件中一个独立的子项目，用于为Courier的其它组件提供认证服务。
其认证功能通常包括验正登录时的帐号和密码、获取一个帐号相关的家目录或邮件目录等信息、改变帐号的密码等。
而其认证的实现方式也包括基于PAM通过/etc/passwd和/etc/shadow进行认证，基于GDBM或DB进行认证，基于LDAP/MySQL/PostgreSQL进行认证等。
因此，courier-authlib也常用来与courier之外的其它邮件组件(如postfix)整合为其提供认证服务。

备注：在RHEL5上要使用0.64.0及之前的版本，否则，可能会由于sqlite版本过低问题导致configure检查无法通过或编译无法进行。

2、安装

接下来开始编译安装
# tar jxvf courier-authlib-0.64.0.tar.bz2
# cd courier-authlib-0.64.0
#./configure \
    --prefix=/usr/local/courier-authlib \
    --sysconfdir=/etc \
    --without-authpam \
    --without-authshadow \
    --without-authvchkpw \
    --without-authpgsql \
    --with-authmysql \
    --with-mysql-libs=/usr/lib/mysql \
    --with-mysql-includes=/usr/include/mysql \
    --with-redhat \
    --with-authmysqlrc=/etc/authmysqlrc \
    --with-authdaemonrc=/etc/authdaemonrc \
    --with-mailuser=postfix \
    --with-mailgroup=postfix \
    --with-ltdl-lib=/usr/lib \
    --with-ltdl-include=/usr/include
# make
# make install

备注：可以使用--with-authdaemonvar=/var/spool/authdaemon选项来指定进程套接字目录路径，/usr/local/courier-authlib/var


# chmod 755 /usr/local/courier-authlib/var/spool/authdaemon
# cp /etc/authdaemonrc.dist  /etc/authdaemonrc
# cp /etc/authmysqlrc.dist  /etc/authmysqlrc

修改/etc/authdaemonrc 文件
authmodulelist="authmysql"
authmodulelistorig="authmysql"
daemons=10

3、配置其通过mysql进行邮件帐号认证

编辑/etc/authmysqlrc 为以下内容，其中2525，2525 为postfix 用户的UID和GID。
MYSQL_SERVER localhost
MYSQL_PORT 3306                   (指定你的mysql监听的端口，这里使用默认的3306)
MYSQL_USERNAME  extmail      (这时为后文要用的数据库的所有者的用户名)
MYSQL_PASSWORD extmail        (密码)
MYSQL_SOCKET  /var/lib/mysql/mysql.sock
MYSQL_DATABASE  extmail
MYSQL_USER_TABLE  mailbox
MYSQL_CRYPT_PWFIELD  password
MYSQL_UID_FIELD  '2525'
MYSQL_GID_FIELD  '2525'
MYSQL_LOGIN_FIELD  username
MYSQL_HOME_FIELD  concat('/var/mailbox/',homedir)
MYSQL_NAME_FIELD  name
MYSQL_MAILDIR_FIELD  concat('/var/mailbox/',maildir)

4、提供SysV服务脚本
在编绎目录下：
# cp courier-authlib.sysvinit /etc/rc.d/init.d/courier-authlib
# chmod 755 /etc/init.d/courier-authlib
# chkconfig --add courier-authlib
# chkconfig --level 2345 courier-authlib on

# echo "/usr/local/courier-authlib/lib/courier-authlib" >> /etc/ld.so.conf.d/courier-authlib.conf
# ldconfig -v
# service courier-authlib start   (启动服务)

5、配置postfix和courier-authlib

新建虚拟用户邮箱所在的目录，并将其权限赋予postfix用户：
#mkdir –pv /var/mailbox
#chown –R postfix /var/mailbox

接下来重新配置SMTP 认证，编辑 /usr/lib/sasl2/smtpd.conf ，确保其为以下内容：
pwcheck_method: authdaemond
log_level: 3
mech_list:PLAIN LOGIN
authdaemond_path:/usr/local/courier-authlib/var/spool/authdaemon/socket


九、让postfix支持虚拟域和虚拟用户

1、编辑/etc/postfix/main.cf，添加如下内容：注意这个courier-authlib依赖sasl,所以之前在postfix里面加入的sasl认证配置不能删掉
########################Virtual Mailbox Settings########################
virtual_mailbox_base = /var/mailbox
virtual_mailbox_maps = mysql:/etc/postfix/mysql_virtual_mailbox_maps.cf
virtual_mailbox_domains = mysql:/etc/postfix/mysql_virtual_domains_maps.cf
virtual_alias_domains =
virtual_alias_maps = mysql:/etc/postfix/mysql_virtual_alias_maps.cf
virtual_uid_maps = static:2525
virtual_gid_maps = static:2525
virtual_transport = virtual
maildrop_destination_recipient_limit = 1
maildrop_destination_concurrency_limit = 1
##########################QUOTA Settings########################
message_size_limit = 14336000
virtual_mailbox_limit = 20971520
virtual_create_maildirsize = yes
virtual_mailbox_extended = yes
virtual_mailbox_limit_maps = mysql:/etc/postfix/mysql_virtual_mailbox_limit_maps.cf
virtual_mailbox_limit_override = yes
virtual_maildir_limit_message = Sorry, the user's maildir has overdrawn his diskspace quota, please Tidy your mailbox and try again later.
virtual_overquota_bounce = yes

2、使用extman源码目录下docs目录中的extmail.sql和init.sql建立数据库：

# tar zxvf  extman-1.1.tar.gz
# cd extman-1.1/docs
# mysql -u root -p < extmail.sql
# mysql -u root -p <init.sql
# cp mysql*  /etc/postfix/

3、授予用户extmail访问extmail数据库的权限
mysql> GRANT all privileges on extmail.* TO extmail@localhost IDENTIFIED BY 'extmail';
mysql> GRANT all privileges on extmail.* TO extmail@127.0.0.1 IDENTIFIED BY 'extmail';

说明：
1、启用虚拟域以后，需要取消中心域，即注释掉myhostname, mydestination, mydomain, myorigin几个指令；当然，你也可以把mydestionation的值改为你自己需要的。
2、对于MySQL-5.1以后版本，其中的服务脚本extmail.sql执行会有语法错误；可先使用如下命令修改extmail.sql配置文件，而后再执行。修改方法如下：
	# sed -i 's@TYPE=MyISAM@ENGINE=InnoDB@g' extmail.sql
3、此时mysql中已经由extmail提供了几个域，如果要支持别的域可以手动加上去，其实后面的extman就能通过图形界面往上加




十、配置dovecot

# vi /etc/dovecot.conf
mail_location = maildir:/var/mailbox/%d/%n/Maildir
……
auth default {
    mechanisms = plain
    passdb sql {
        args = /etc/dovecot-mysql.conf
    }
    userdb sql {
        args = /etc/dovecot-mysql.conf
    }
    ……
RHEL7的语法变了，查官网dovecot.org

# vim /etc/dovecot-mysql.conf                 
driver = mysql
connect = host=localhost dbname=extmail user=extmail password=extmail
default_pass_scheme = CRYPT
password_query = SELECT username AS user,password AS password FROM mailbox WHERE username = '%u' 
user_query = SELECT maildir, uidnumber AS uid, gidnumber AS gid FROM mailbox WHERE username = '%u'

说明：如果mysql服务器是本地主机，即host=localhost时，如果mysql.sock文件不是默认的/var/lib/mysql/mysql.sock，可以使用host=“sock文件的路径”来指定新位置；例如，使用通用二进制格式安装的MySQL，其soc文件位置为/tmp/mysql.sock，相应地，connect应按如下方式定义。
connect = host=/tmp/mysql.sock dbname=extmail user=extmail password=extmail



接下来启动dovecot服务：

# service dovecot start
# chkconfig dovecot on



十一、安装Extmail-1.2

说明：如果extmail的放置路径做了修改，那么配置文件webmail.cf中的/var/www路径必须修改为你所需要的位置。本文使用了默认的/var/www，所以，以下示例中并没有包含路径修改的相关内容。

1、安装
# tar zxvf extmail-1.2.tar.gz
# mkdir -pv /var/www/extsuite
# mv extmail-1.2 /var/www/extsuite/extmail
# cp /var/www/extsuite/extmail/webmail.cf.default  /var/www/extsuite/extmail/webmail.cf

2、修改主配置文件
#vi /var/www/extsuite/extmail/webmail.cf

部分修改选项的说明：

SYS_MESSAGE_SIZE_LIMIT = 5242880
用户可以发送的最大邮件

SYS_USER_LANG = en_US
语言选项，可改作：
SYS_USER_LANG = zh_CN

SYS_MAILDIR_BASE = /home/domains
此处即为您在前文所设置的用户邮件的存放目录，可改作：
SYS_MAILDIR_BASE = /var/mailbox

SYS_MYSQL_USER = db_user
SYS_MYSQL_PASS = db_pass
以上两句句用来设置连接数据库服务器所使用用户名、密码和邮件服务器用到的数据库，这里修改为：
SYS_MYSQL_USER = extmail
SYS_MYSQL_PASS = extmail

SYS_MYSQL_HOST = localhost
指明数据库服务器主机名，这里默认即可

SYS_MYSQL_TABLE = mailbox
SYS_MYSQL_ATTR_USERNAME = username
SYS_MYSQL_ATTR_DOMAIN = domain
SYS_MYSQL_ATTR_PASSWD = password

以上用来指定验正用户登录里所用到的表，以及用户名、域名和用户密码分别对应的表中列的名称；这里默认即可

SYS_AUTHLIB_SOCKET = /var/spool/authdaemon/socket
此句用来指明authdaemo socket文件的位置，这里修改为：
SYS_AUTHLIB_SOCKET = /usr/local/courier-authlib/var/spool/authdaemon/socket


3、apache相关配置
由于extmail要进行本地邮件的投递操作，故必须将运行apache服务器用户的身份修改为您的邮件投递代理的用户；本例中打开了apache服务器的suexec功能，故使用以下方法来实现虚拟主机身份切换。此例中的MDA为postfix自带，因此将指定为postfix用户：
<VirtualHost *:80>
ServerName mail.magedu.com
DocumentRoot /var/www/extsuite/extmail/html/
ScriptAlias /extmail/cgi /var/www/extsuite/extmail/cgi
Alias /extmail /var/www/extsuite/extmail/html
SuexecUserGroup postfix postfix
</VirtualHost>

修改 cgi执行文件属主为apache运行身份用户：
# chown -R postfix.postfix /var/www/extsuite/extmail/cgi/

如果您没有打开apache服务器的suexec功能,也可以使用以下方法解决：
# vim /etc/httpd/httpd.conf
User postfix
Group postfix

<VirtualHost *:80>
ServerName mail.magedu.com
DocumentRoot /var/www/extsuite/extmail/html/
ScriptAlias /extmail/cgi /var/www/extsuite/extmail/cgi
Alias /extmail /var/www/extsuite/extmail/html
</VirtualHost>

4、依赖关系的解决

extmail将会用到perl的Unix::syslogd功能，您可以去http://search.cpan.org搜索下载原码包进行安装。
# tar zxvf Unix-Syslog-0.100.tar.gz
# cd Unix-Syslog-0.100
# perl Makefile.PL
# make
# make install

5、启动apache服务
# service httpd start
# chkconfig httpd on



十二、安装Extman-1.1

1、安装及基本配置

# tar zxvf  extman-1.1.tar.gz
# mv extman-1.1 /var/www/extsuite/extman

修改配置文件以符合本例的需要：
# cp /var/www/extsuite/extman/webman.cf.default  /var/www/extsuite/extman/webman.cf
# vi /var/www/extsuite/extman/webman.cf

SYS_MAILDIR_BASE = /home/domains
此处即为您在前文所设置的用户邮件的存放目录，可改作：
SYS_MAILDIR_BASE = /var/mailbox

SYS_DEFAULT_UID = 1000
SYS_DEFAULT_GID = 1000
此两处后面设定的ID号需更改为前而创建的postfix用户和postfix组的id号，本文使用的是2525，因此，上述两项需要修改为：
SYS_DEFAULT_UID = 2525
SYS_DEFAULT_GID = 2525

SYS_MYSQL_USER = webman
SYS_MYSQL_PASS = webman
修改为：
SYS_MYSQL_USER = extmail
SYS_MYSQL_PASS = extmail

而后修改cgi目录的属主：
# chown -R postfix.postfix /var/www/extsuite/extman/cgi/

在apache的主配置文件中Extmail的虚拟主机部分，添加如下两行：
ScriptAlias /extman/cgi /var/www/extsuite/extman/cgi
Alias /extman /var/www/extsuite/extman/html

创建其运行时所需的临时目录，并修改其相应的权限：
#mkdir  -pv  /tmp/extman
#chown postfix.postfix  /tmp/extman

修改
SYS_CAPTCHA_ON = 1
为
SYS_CAPTCHA_ON = 0

好了，到此为止，重新启动apache服务器后，您的Webmail和Extman已经可以使用了，可以在浏览器中输入指定的虚拟主机的名称进行访问，如下：
http://mail.magedu.com

选择管理即可登入extman进行后台管理了。默认管理帐号为：root@extmail.org  密码为：extmail*123*

说明：
(1) 如果您安装后无法正常显示校验码，安装perl-GD模块会解决这个问题。如果想简单，您可以到以下地址下载适合您的平台的rpm包，安装即可：  http://dries.ulyssis.org/rpm/packages/perl-GD/info.html
(2) extman-1.1自带了图形化显示日志的功能；此功能需要rrdtool的支持，您需要安装此些模块才可能正常显示图形日志。


2、配置Mailgraph_ext，使用Extman的图形日志：（下面所需的软件包面要自己下载）

接下来安装图形日志的运行所需要的软件包Time::HiRes、File::Tail和rrdtool，其中前两个包您可以去http://search.cpan.org搜索并下载获得，后一个包您可以到 http://oss.oetiker.ch/rrdtool/pub/?M=D下载获得； 注意安装顺序不能改换。

安装Time::HiRes
#tar zxvf Time-HiRes-1.9707.tar.gz
#cd Time-HiRes-1.9707
#perl Makefile.PL
#make
#make test
#make install

安装File::Tail
#tar zxvf File-Tail-0.99.3.tar.gz
#cd File-Tail-0.99.3
#perl Makefile
#make
#make test
#make install

安装rrdtool-1.2.23
#tar zxvf rrdtool-1.2.23.tar.gz
#cd rrdtool-1.2.23
#./configure --prefix=/usr/local/rrdtool
#make
#make install

创建必要的符号链接(Extman会到这些路径下找相关的库文件)
#ln -sv /usr/local/rrdtool/lib/perl/5.8.5/i386-linux-thread-multi/auto/RRDs/RRDs.so   /usr/lib/perl5/5.8.5/i386-linux-thread-multi/
#ln -sv /usr/local/rrdtool/lib/perl/5.8.5/RRDp.pm   /usr/lib/perl5/5.8.5
#ln -sv /usr/local/rrdtool/lib/perl/5.8.5/i386-linux-thread-multi/RRDs.pm   /usr/lib/perl5/5.8.5

复制mailgraph_ext到/usr/local，并启动之
# cp -r /var/www/extsuite/extman/addon/mailgraph_ext  /usr/local  
# /usr/local/mailgraph_ext/mailgraph-init start 

启动cmdserver(在后台显示系统信息) 
# /var/www/extsuite/extman/daemon/cmdserver --daemon

添加到自动启动队列
# echo “/usr/local/mailgraph_ext/mailgraph-init start” >> /etc/rc.d/rc.local
# echo “/var/www/extsuite/extman/daemon/cmdserver -v -d” >> /etc/rc.d/rc.local 

使用方法： 等待大约15分钟左右，如果邮件系统有一定的流量，即可登陆到extman里，点“图形日志”即可看到图形化的日志。具体每天，周，月，年的则点击相应的图片进入即可。 






十三、配置postfix使用maildrop投递邮件


 maildrop是一个使用C++编写的用来代替本地MDA的带有过滤功能邮件投递代理，是courier邮件系统组件之一。它从标准输入接受信息并投递到用户邮箱；maildrop既可以将邮件投递到mailboxes格式邮箱，亦可以将其投递到maildirs格式邮箱。同时，maildrop可以从文件中读取入站邮件过滤指示，并由此决定是将邮件送入用户邮箱或者转发到其它地址等。和procmail不同的是，maildrop使用结构化的过滤语言，因此，邮件系统管理员可以开发自己的过滤规则并应用其中。

 我们在此将使用maildrop来代替postfix自带的MDA，并以此为基础扩展后文的邮件杀毒和反垃圾邮件功能的调用；在此可能会修改前文中的许多设置，请确保您的设置也做了相应的修改。

 1、安装

 将courier-authlib的头文件及库文件(参考第八部分的第四小节)链接至/usr目录(编译maildrop时会到此目录下找此些相关的文件):
 # ln -sv /usr/local/courier-authlib/bin/courierauthconfig   /usr/bin
 # ln -sv /usr/local/courier-authlib/include/*   /usr/include

 maildrop需要pcre的支持，因此，需要事先提供pcre的头文件及库文件等开发组件。如果选择以yum源来提供pcre，请确保安装pcre-devel包。
 # yum -y install pcre-devel

 # groupadd -g 1001 vmail
 # useradd -g vmail -u 1001 -M -s /sbin/nologin vmail
 # tar xf maildrop-2.6.0.tar.bz2
 # cd maildrop-2.6.0
 # ./configure \
     --enable-sendmail=/usr/sbin/sendmail \
     --enable-trusted-users='root vmail' \
     --enable-syslog=1 --enable-maildirquota \
     --enable-maildrop-uid=1001 \
     --enable-maildrop-gid=1001 \
     --with-trashquota --with-dirsync
 # make
 # make install

 检查安装结果，请确保有"Courier Authentication Library extension enabled."一句出现：
 # maildrop -v
maildrop 2.6.0 Copyright 1998-2005 Double Precision, Inc.
GDBM/DB extensions enabled.
Courier Authentication Library extension enabled.
Maildir quota extension are now always enabled.
This program is distributed under the terms of the GNU General Public
License. See COPYING for additional information.


 2、新建其配置文件/etc/maildroprc文件，首先指定maildrop的日志记录位置：
 # vi /etc/maildroprc
 添加：
 logfile "/var/log/maildrop.log" 

 # touch /var/log/maildrop.log
 # chown vmail.vmail /var/log/maildrop.log

 3、配置Postfix

 编辑master.cf
 # vi /etc/postfix/master.cf
 启用如下两行
 maildrop  unix  -       n       n       -       -       pipe
    flags=DRhu user=vmail argv=/usr/local/bin/maildrop -d ${recipient}

 注意：定义transport的时候，即如上两行中的第二行，其参数行必须以空格开头，否则会出错。

 编辑main.cf
 # vi /etc/postfix/main.cf
 virtual_transport = virtual
 修改为：
 virtual_transport = maildrop

 将下面两项指定的UID和GID作相应的修改:
 virtual_uid_maps = static:2525
 virtual_gid_maps = static:2525
 修改为:
 virtual_uid_maps = static:1001
 virtual_gid_maps = static:1001


 4、编辑/etc/authmysqlrc

 # vi /etc/authmysqrc
 MYSQL_UID_FIELD  '2525'
 MYSQL_GID_FIELD  '2525'
 更改为：
 MYSQL_UID_FIELD  '1001'
 MYSQL_GID_FIELD  '1001'

注意：没有此处的修改，maildrop可能会报告 “signal 0x06”的错误报告。

5、编辑/etc/httpd/httpd.conf，修改运行用户:

如果启用了suexec的功能，则将虚拟主机中指定的
SuexecUserGroup postfix postfix
修改为：
SuexecUserGroup vmail vmail

如果没有使用上面的功能，则修改User和Group指令后的用户为vmail
将前文中的如下项
User postfix
Group postfix 
修改为：
User vmail
Group vmail

6、将用户邮件所在的目录/var/mailbox和extman的临时目录/tmp/extman的属主和属组指定为vmail
#chown -R vmail.vmail /var/mailbox
#chown -R vmail.vmail /tmp/extman

7、修改extman的主配置文件中的默认用户ID和组ID，确保其为类似如下内容
SYS_DEFAULT_UID = 1001
SYS_DEFAULT_GID = 1001

8、验正
接下来重新启动postfix和apache，进行发信测试后，如果日志中的记录类同以下项，则安装成功
Apr 15 15:33:54 localhost postfix/pipe[11964]: 04B92147CE9: to=<jerry@magedu.com>, relay=maildrop, delay=0.16, delays=0.07/0.03/0/0.07, dsn=2.0.0, status=sent (delivered via maildrop service)


十四、安装clamav-0.97.7

 最新的clamav-0.97.7需要zlib-1.2.2以上的版本的支持，因此需要事先安装相应版本的zlib-devel；在RHEL5.8上，使用系统yum源安装即可。

1、安装clamav-0.97.7

 添加ClamAV运行所需的组和用户：
 #groupadd clamav
 #useradd -g clamav -s /sbin/nologin -M clamav

 添加配合amavisd-new使用的用户amavis
 #groupadd amavis
 #useradd -g amavis -s /sbin/nologin -M amavis

 #tar zxvf clamav-0.97.7.tar.gz
 #cd clamav-0.97.7
 #./configure --prefix=/usr/local/clamav --with-dbdir=/usr/local/clamav/share --sysconfdir=/etc/clamav
 #make
 #make check
 #make install

 3、配置Clam AntiVirus：

 编辑主配置文件：
 #vim /etc/clamav/clamd.conf

 注释掉第八行的Example,如下：
 # Example

 找到如下行
 #LogFile /tmp/clamd.log
 #PidFile /var/run/clamd.pid
 LocalSocket /tmp/clamd.socket
 #DatabaseDirectory /var/lib/clamav
 #User clamav
 修改为：
 LogFile /var/log/clamav/clamd.log
 PidFile /var/run/clamav/clamd.pid
 LocalSocket /var/run/clamav/clamd.socket
 DatabaseDirectory /usr/local/clamav/share
 User amavis

 启用以下选项
 LogSyslog yes
 LogFacility LOG_MAIL
 LogVerbose yes
 StreamMaxLength 20M   

 说明：上面最后一个参数后面的数值应该与邮件服务器允许的最大附件值相一致


 编辑更新进程的配置文件
 #vim /etc/clamav/freshclam.conf

 注释掉Example，如下:
 # Example

 找到如下行
 #DatabaseDirectory /var/lib/clamav
 #UpdateLogFile /var/log/freshclam.log
 PidFile /var/run/freshclam.pid
 分别修改为：
 DatabaseDirectory /usr/local/clamav/share
 UpdateLogFile /var/log/clamav/freshclam.log
 PidFile /var/run/clamav/freshclam.pid

 启用以下选项：
 DatabaseMirror db.XY.clamav.net  (这里也可以把XY改成您的国家代码来实现，比如，我们用cn来代替)
 LogSyslog yes
 LogFacility LOG_MAIL
 LogVerbose yes

 4、建立日志所在的目录、进程与socket所在的目录，并让它属于clamav用户：

 # mkdir -v /var/log/clamav
 # chown -R amavis.amavis /var/log/clamav
 # mkdir -v /var/run/clamav
 # chmod 700 /var/run/clamav
 # chown -R amavis.amavis /var/run/clamav

 建立freshlog的日志文件
 #touch  /var/log/clamav/freshclam.log
 #chown  clamav.clamav  /var/log/clamav/freshclam.log

 5、配置crontab，让Clam AntiVirus每小时检测一次新的病毒库：

 # crontab -e
 添加：
 37 * * * * /usr/local/clamav/bin/freshclam

 6、配置库文件搜索路径：

 # echo “/usr/local/clamav/lib” >> /etc/ls.so.conf
 # ldconfig -v

 7、配置clamav开机自动启动

 # cp contrib/init/RedHat/clamd  /etc/rc.d/init.d/clamd
 # cp contrib/init/RedHat/clamav-milter  /etc/rc.d/init.d/clamav-milter
 # chkconfig --add clamd
 # chkconfig --add clamav-milter
 # chkconfig --level 2345 clamd on
 # chkconfig --level 2345 clamav-milter on

 编辑/etc/rc.d/init.d/clamd，将服务进程的路径指向刚才的安装目录
 #vi /etc/rc.d/init.d/clamd
 找到如下行
 progdir="/usr/local/sbin"
 修改为：
 progdir="/usr/local/clamav/sbin"

 启动clamd
 #service clamd start

 ####################################完全演练######################################
一、安装前的准备工作：

安装前说明：邮件服务依赖于DNS服务，请事先确信您的DNS服务已经为邮件应用配置完成。

1、安装所需的rpm包，这包括以下这些：
httpd, mysql, mysql-server, mysql-devel, openssl-devel, dovecot, perl-DBD-MySQL, tcl, tcl-devel, libart_lgpl, libart_lgpl-devel, libtool-ltdl, libtool-ltdl-devel, expect

2、关闭sendmail，并将它的随系统自动启动功能关闭：
# service sendmail stop
# chkconfig sendmail off

3、安装以下开发所用到的rpm包组：
Development Libraries
Development Tools

方法：
# yum groupinstall "packge_group_name"

二、启动依赖的服务：

1、启动mysql数据库，并给mysql的root用户设置密码：
# service mysqld start
# chkconfig mysqld on
# mysqladmin -uroot password 'your_password'

2、启动saslauthd服务，并将其加入到自动启动队列：
# service saslauthd start
# chkconfig saslauthd on

三、安装配置postfix

# groupadd -g 2525 postfix
# useradd -g postfix -u 2525 -s /sbin/nologin -M postfix
# groupadd -g 2526 postdrop
# useradd -g postdrop -u 2526 -s /sbin/nologin -M postdrop

# tar zxvf postfix-2.9.3.tar.gz
# cd postfix-2.9.3
# make makefiles 'CCARGS=-DHAS_MYSQL -I/usr/include/mysql -DUSE_SASL_AUTH -DUSE_CYRUS_SASL -I/usr/include/sasl  -DUSE_TLS ' 'AUXLIBS=-L/usr/lib/mysql -lmysqlclient -lz -lm -L/usr/lib/sasl2 -lsasl2  -lssl -lcrypto'
# make
# make install

# make makefiles 'CCARGS=-DHAS_MYSQL -I/usr/local/mysql/include -DUSE_SASL_AUTH -DUSE_CYRUS_SASL -I/usr/include/sasl  -DUSE_TLS ' 'AUXLIBS=-L/usr/local/mysql/lib -lmysqlclient -lz -lm -L/usr/lib/sasl2 -lsasl2  -lssl -lcrypto'


按照以下的提示输入相关的路径([]号中的是缺省值，”]”后的是输入值，省略的表示采用默认值)

　　install_root: [/] /
　　tempdir: [/root/postfix-2.9.3] /tmp/postfix
　　config_directory: [/etc/postfix] /etc/postfix
　　daemon_directory: [/usr/libexec/postfix] 
　　command_directory: [/usr/sbin] 
　　queue_directory: [/var/spool/postfix]
　　sendmail_path: [/usr/sbin/sendmail]
　　newaliases_path: [/usr/bin/newaliases]
　　mailq_path: [/usr/bin/mailq]
　　mail_owner: [postfix]
　　setgid_group: [postdrop]   
    html_directory: [no]/var/www/html/postfix 
    manpages: [/usr/local/man]
    readme_directory: [no]

生成别名二进制文件：
#  newaliases

2．进行一些基本配置，测试启动postfix并进行发信
# vim /etc/postfix/main.cf
修改以下几项为您需要的配置
myhostname = mail.magedu.com
myorigin = magedu.com
mydomain = magedu.com
mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
mynetworks = 192.168.1.0/24, 127.0.0.0/8

说明:
myorigin参数用来指明发件人所在的域名，即做发件地址伪装；
mydestination参数指定postfix接收邮件时收件人的域名，即您的postfix系统要接收到哪个域名的邮件；
myhostname 参数指定运行postfix邮件系统的主机的主机名，默认情况下，其值被设定为本地机器名；
mydomain 参数指定您的域名，默认情况下，postfix将myhostname的第一部分删除而作为mydomain的值；
mynetworks 参数指定你所在的网络的网络地址，postfix系统根据其值来区别用户是远程的还是本地的，如果是本地网络用户则允许其访问；
inet_interfaces 参数指定postfix系统监听的网络接口；

注意：
1、在postfix的配置文件中，参数行和注释行是不能处在同一行中的；
2、任何一个参数的值都不需要加引号，否则，引号将会被当作参数值的一部分来使用；
3、每修改参数及其值后执行 postfix reload 即可令其生效；但若修改了inet_interfaces，则需重新启动postfix；
4、如果一个参数的值有多个，可以将它们放在不同的行中，只需要在其后的每个行前多置一个空格即可；postfix会把第一个字符为空格或tab的文本行视为上一行的延续；


四、为postfix提供SysV服务脚本/etc/rc.d/init.d/postfix，内容如下(#END 之前)：
#!/bin/bash
#
# postfix      Postfix Mail Transfer Agent
#
# chkconfig: 2345 80 30
# description: Postfix is a Mail Transport Agent, which is the program \
#              that moves mail from one machine to another.
# processname: master
# pidfile: /var/spool/postfix/pid/master.pid
# config: /etc/postfix/main.cf
# config: /etc/postfix/master.cf

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ $NETWORKING = "no" ] && exit 3

[ -x /usr/sbin/postfix ] || exit 4
[ -d /etc/postfix ] || exit 5
[ -d /var/spool/postfix ] || exit 6

RETVAL=0
prog="postfix"

start() {
	# Start daemons.
	echo -n $"Starting postfix: "
        /usr/bin/newaliases >/dev/null 2>&1
	/usr/sbin/postfix start 2>/dev/null 1>&2 && success || failure $"$prog start"
	RETVAL=$?
	[ $RETVAL -eq 0 ] && touch /var/lock/subsys/postfix
        echo
	return $RETVAL
}

stop() {
  # Stop daemons.
	echo -n $"Shutting down postfix: "
	/usr/sbin/postfix stop 2>/dev/null 1>&2 && success || failure $"$prog stop"
	RETVAL=$?
	[ $RETVAL -eq 0 ] && rm -f /var/lock/subsys/postfix
	echo
	return $RETVAL
}

reload() {
	echo -n $"Reloading postfix: "
	/usr/sbin/postfix reload 2>/dev/null 1>&2 && success || failure $"$prog reload"
	RETVAL=$?
	echo
	return $RETVAL
}

abort() {
	/usr/sbin/postfix abort 2>/dev/null 1>&2 && success || failure $"$prog abort"
	return $?
}

flush() {
	/usr/sbin/postfix flush 2>/dev/null 1>&2 && success || failure $"$prog flush"
	return $?
}

check() {
	/usr/sbin/postfix check 2>/dev/null 1>&2 && success || failure $"$prog check"
	return $?
}

restart() {
	stop
	start
}

# See how we were called.
case "$1" in
  start)
	start
	;;
  stop)
	stop
	;;
  restart)
	stop
	start
	;;
  reload)
	reload
	;;
  abort)
	abort
	;;
  flush)
	flush
	;;
  check)
	check
	;;
  status)
  	status master
	;;
  condrestart)
	[ -f /var/lock/subsys/postfix ] && restart || :
	;;
  *)
	echo $"Usage: $0 {start|stop|restart|reload|abort|flush|check|status|condrestart}"
	exit 1
esac

exit $?

# END

为此脚本赋予执行权限：
# chmod +x /etc/rc.d/init.d/postfix

将postfix服务添加至服务列表：
# chkconfig --add postfix

设置其开机自动启动：
# chkconfig postfix on

使用此脚本重新启动服务，以测试其能否正常执行：
# service postfix restart

此时可使用本地用户测试邮件收发了。

五、为postfix服务开启用户别名支持：

1、在配置文件开启基于hash的别名文件支持

在main.cf中，找到如下指令，而后启用它(即移除前面的#号)：
#alias_maps = hash:/etc/aliases

2、在/etc/aliases文件中定义新的别名项，其格式通常为以冒号隔开的两个字段，前一个字段为初始目标邮件地址，后一个字段为实际发往的地址，如：
redhat：	magedu
gentoo@126.com:  admin@magedu.com

3、将/etc/aliases转换为hash格式：
# postalias  /etc/aliases

4、让postfix重新载入配置文件，即可进行测试；

六、实现postfix基于客户端的访问控制

1、基于客户端的访问控制概览

postfix内置了多种反垃圾邮件的机制，其中就包括“客户端”发送邮件限制。客户端判别机制可以设定一系列客户信息的判别条件：
smtpd_client_restrictions
smtpd_data_restrictions
smtpd_helo_restrictions
smtpd_recipient_restrictions
smtpd_sender_restrictions

上面的每一项参数分别用于检查SMTP会话过程中的特定阶段，即客户端提供相应信息的阶段，如当客户端发起连接请求时，postfix就可以根据配置文件中定义的smtpd_client_restrictions参数来判别此客户端IP的访问权限。相应地，smtpd_helo_restrictions则用于根据用户的helo信息判别客户端的访问能力等等。

如果DATA命令之前的所有内容都被接受，客户端接着就可以开始传送邮件内容了。邮件内容通常由两部分组成，前半部分是标题(header)，其可以由header_check过滤，后半部分是邮件正文(body)，其可以由check_body过滤。这两项实现的是邮件“内容检查”。

postfix的默认配置如下：
smtpd_client_restrictions =
smtpd_data_restrictions =
smtpd_end_of_data_restrictions =
smtpd_etrn_restrictions =
smtpd_helo_restrictions =
smtpd_recipient_restrictions = permit_mynetworks, reject_unauth_destination
smtpd_sender_restrictions =

这限制了只有mynetworks参数中定义的本地网络中的客户端才能通过postfix转发邮件，其它客户端则不被允许，从而关闭了开放式中继(open relay)的功能。

Postfix有多个内置的限制条件，如上面的permit_mynetworks和reject_unauth_destination，但管理员也可以使用访问表(access map)来自定义限制条件。自定义访问表的条件通常使用check_client_access, check_helo_access, check_sender_access, check_recipient_access进行，它们后面通常跟上type:mapname格式的访问表类型和名称。其中，check_sender_access和check_recipient_access用来检查客户端提供的邮件地址，因此，其访问表中可以使用完整的邮件地址，如admin@magedu.com；也可以只使用域名，如magedu.com；还可以只有用户名的部分，如marion@。

2、实现示例1

这里以禁止172.16.100.66这台主机通过工作在172.16.100.1上的postfix服务发送邮件为例演示说明其实现过程。访问表使用hash的格式。

(1)首先，编辑/etc/postfix/access文件，以之做为客户端检查的控制文件，在里面定义如下一行：
172.16.100.66		REJECT

(2)将此文件转换为hash格式
# postmap /etc/postfix/access

(3)配置postfix使用此文件对客户端进行检查
编辑/etc/postfix/main.cf文件，添加如下参数：
smtpd_client_restrictions = check_client_access hash:/etc/postfix/access

(4)让postfix重新载入配置文件即可进行发信控制的效果测试了。

3、实现示例2

这里以禁止通过本服务器向microsoft.com域发送邮件为例演示其实现过程。访问表使用hash的格式。
(1)首先，建立/etc/postfix/denydstdomains文件(文件名任取)，在里面定义如下一行：
microsoft.com		REJECT

(2)将此文件转换为hash格式
# postmap /etc/postfix/denydstdomains

(3)配置postfix使用此文件对客户端进行检查
编辑/etc/postfix/main.cf文件，添加如下参数：
smtpd_recipient_restrictions = check_recipient_access hash:/etc/postfix/denydstdomains, permit_mynetworks, reject_unauth_destination

(4)让postfix重新载入配置文件即可进行发信控制的效果测试了。

4、检查表格式的说明

hash类的检查表都使用类似如下的格式：
pattern   action

检查表文件中，空白行、仅包含空白字符的行和以#开头的行都会被忽略。以空白字符开头后跟其它非空白字符的行会被认为是前一行的延续，是一行的组成部分。

(1)关于pattern
其pattern通常有两类地址：邮件地址和主机名称/地址。

邮件地址的pattern格式如下：
user@domain  用于匹配指定邮件地址；
domain.tld   用于匹配以此域名作为邮件地址中的域名部分的所有邮件地址；
user@ 			 用于匹配以此作为邮件地址中的用户名部分的所有邮件地址；

主机名称/地址的pattern格式如下：
domain.tld   用于匹配指定域及其子域内的所有主机；
.domain.tld   用于匹配指定域的子域内的所有主机；
net.work.addr.ess
net.work.addr
net.work
net        用于匹配特定的IP地址或网络内的所有主机；
network/mask  CIDR格式，匹配指定网络内的所有主机；

(2)关于action

接受类的动作：
OK   接受其pattern匹配的邮件地址或主机名称/地址；
全部由数字组成的action   隐式表示OK；

拒绝类的动作(部分)：
4NN text 
5NN text 
    其中4NN类表示过一会儿重试；5NN类表示严重错误，将停止重试邮件发送；421和521对于postfix来说有特殊意义，尽量不要自定义这两个代码；
REJECT optional text...   拒绝；text为可选信息；
DEFER optional text...    拒绝；text为可选信息； 



七、为postfix开启基于cyrus-sasl的认证功能

使用以下命令验正postfix是否支持cyrus风格的sasl认证，如果您的输出为以下结果，则是支持的：
# /usr/local/postfix/sbin/postconf  -a
cyrus
dovecot

#vim /etc/postfix/main.cf
添加以下内容：
############################CYRUS-SASL############################
broken_sasl_auth_clients = yes
smtpd_recipient_restrictions=permit_mynetworks,permit_sasl_authenticated,reject_invalid_hostname,reject_non_fqdn_hostname,reject_unknown_sender_domain,reject_non_fqdn_sender,reject_non_fqdn_recipient,reject_unknown_recipient_domain,reject_unauth_pipelining,reject_unauth_destination
smtpd_sasl_auth_enable = yes
smtpd_sasl_local_domain = $myhostname
smtpd_sasl_security_options = noanonymous
smtpd_sasl_path = smtpd
smtpd_banner = Welcome to our $myhostname ESMTP,Warning: Version not Available!



# vim /usr/lib/sasl2/smtpd.conf
添加如下内容：
pwcheck_method: saslauthd
mech_list: PLAIN LOGIN

让postfix重新加载配置文件
#/usr/sbin/postfix reload


*****这个地方强调一下，由于pwcheck_method是saslauthd那么/etc/sysconfig/saslauthd下MECH=pam一定要对应，这里用到的就不对
这个实验用的是/etc/shadow文件，所以要改成MECH=shadow，可以用saslauthd -v查看所有认证方式
# telnet localhost 25
Trying 127.0.0.1...
Connected to localhost.localdomain (127.0.0.1).
Escape character is '^]'.
220 Welcome to our mail.magedu.com ESMTP,Warning: Version not Available!
ehlo mail.magedu.com
250-mail.magedu.com
250-PIPELINING
250-SIZE 10240000
250-VRFY
250-ETRN
250-AUTH PLAIN LOGIN
250-AUTH=PLAIN LOGIN               （请确保您的输出以类似两行）
250-ENHANCEDSTATUSCODES
250-8BITMIME
250 DSN



八、安装Courier authentication library

1、courier简介

courier-authlib是Courier组件中的认证库，它是courier组件中一个独立的子项目，用于为Courier的其它组件提供认证服务。其认证功能通常包括验正登录时的帐号和密码、获取一个帐号相关的家目录或邮件目录等信息、改变帐号的密码等。而其认证的实现方式也包括基于PAM通过/etc/passwd和/etc/shadow进行认证，基于GDBM或DB进行认证，基于LDAP/MySQL/PostgreSQL进行认证等。因此，courier-authlib也常用来与courier之外的其它邮件组件(如postfix)整合为其提供认证服务。

备注：在RHEL5上要使用0.64.0及之前的版本，否则，可能会由于sqlite版本过低问题导致configure检查无法通过或编译无法进行。

2、安装

接下来开始编译安装
# tar jxvf courier-authlib-0.64.0.tar.bz2
# cd courier-authlib-0.64.0
#./configure \
    --prefix=/usr/local/courier-authlib \
    --sysconfdir=/etc \
    --without-authpam \
    --without-authshadow \
    --without-authvchkpw \
    --without-authpgsql \
    --with-authmysql \
    --with-mysql-libs=/usr/lib/mysql \
    --with-mysql-includes=/usr/include/mysql \
    --with-redhat \
    --with-authmysqlrc=/etc/authmysqlrc \
    --with-authdaemonrc=/etc/authdaemonrc \
    --with-mailuser=postfix \
    --with-mailgroup=postfix \
    --with-ltdl-lib=/usr/lib \
    --with-ltdl-include=/usr/include
# make
# make install

备注：可以使用--with-authdaemonvar=/var/spool/authdaemon选项来指定进程套接字目录路径,默认是在/usr/local/courier-authlib/var下，不太常规


# chmod 755 /usr/local/courier-authlib/var/spool/authdaemon
# cp /etc/authdaemonrc.dist  /etc/authdaemonrc
# cp /etc/authmysqlrc.dist  /etc/authmysqlrc

修改/etc/authdaemonrc 文件
authmodulelist="authmysql"
authmodulelistorig="authmysql"
daemons=10

3、配置其通过mysql进行邮件帐号认证

编辑/etc/authmysqlrc 为以下内容，其中2525，2525 为postfix 用户的UID和GID。
MYSQL_SERVER localhost
MYSQL_PORT 3306                   (指定你的mysql监听的端口，这里使用默认的3306)
MYSQL_USERNAME  extmail      (这时为后文要用的数据库的所有者的用户名)
MYSQL_PASSWORD extmail        (密码)
MYSQL_SOCKET  /var/lib/mysql/mysql.sock
MYSQL_DATABASE  extmail
MYSQL_USER_TABLE  mailbox
MYSQL_CRYPT_PWFIELD  password
MYSQL_UID_FIELD  '2525'
MYSQL_GID_FIELD  '2525'
MYSQL_LOGIN_FIELD  username
MYSQL_HOME_FIELD  concat('/var/mailbox/',homedir)
MYSQL_NAME_FIELD  name
MYSQL_MAILDIR_FIELD  concat('/var/mailbox/',maildir)

4、提供SysV服务脚本
在编绎目录下：
# cp courier-authlib.sysvinit /etc/rc.d/init.d/courier-authlib
# chmod 755 /etc/init.d/courier-authlib
# chkconfig --add courier-authlib
# chkconfig --level 2345 courier-authlib on

# echo "/usr/local/courier-authlib/lib/courier-authlib" >> /etc/ld.so.conf.d/courier-authlib.conf
# ldconfig -v
# service courier-authlib start   (启动服务)

5、配置postfix和courier-authlib

新建虚拟用户邮箱所在的目录，并将其权限赋予postfix用户：
#mkdir –pv /var/mailbox
#chown –R postfix /var/mailbox

接下来重新配置SMTP 认证，编辑 /usr/lib/sasl2/smtpd.conf ，确保其为以下内容：
pwcheck_method: authdaemond
log_level: 3
mech_list:PLAIN LOGIN
authdaemond_path:/usr/local/courier-authlib/var/spool/authdaemon/socket


九、让postfix支持虚拟域和虚拟用户

1、编辑/etc/postfix/main.cf，添加如下内容：注意这个courier-authlib依赖sasl,所以之前在postfix里面加入的sasl认证配置不能删掉
########################Virtual Mailbox Settings########################
virtual_mailbox_base = /var/mailbox
virtual_mailbox_maps = mysql:/etc/postfix/mysql_virtual_mailbox_maps.cf
virtual_mailbox_domains = mysql:/etc/postfix/mysql_virtual_domains_maps.cf
virtual_alias_domains =
virtual_alias_maps = mysql:/etc/postfix/mysql_virtual_alias_maps.cf
virtual_uid_maps = static:2525
virtual_gid_maps = static:2525
virtual_transport = virtual
maildrop_destination_recipient_limit = 1
maildrop_destination_concurrency_limit = 1
##########################QUOTA Settings########################
message_size_limit = 14336000
virtual_mailbox_limit = 20971520
virtual_create_maildirsize = yes
virtual_mailbox_extended = yes
virtual_mailbox_limit_maps = mysql:/etc/postfix/mysql_virtual_mailbox_limit_maps.cf
virtual_mailbox_limit_override = yes
virtual_maildir_limit_message = Sorry, the user's maildir has overdrawn his diskspace quota, please Tidy your mailbox and try again later.
virtual_overquota_bounce = yes

2、使用extman源码目录下docs目录中的extmail.sql和init.sql建立数据库：

# tar zxvf  extman-1.1.tar.gz
# cd extman-1.1/docs
# mysql -u root -p < extmail.sql
# mysql -u root -p <init.sql
# cp mysql*  /etc/postfix/

3、授予用户extmail访问extmail数据库的权限
mysql> GRANT all privileges on extmail.* TO extmail@localhost IDENTIFIED BY 'extmail';
mysql> GRANT all privileges on extmail.* TO extmail@127.0.0.1 IDENTIFIED BY 'extmail';

说明：
1、启用虚拟域以后，需要取消中心域，即注释掉myhostname, mydestination, mydomain, myorigin几个指令；当然，你也可以把mydestionation的值改为你自己需要的。
2、对于MySQL-5.1以后版本，其中的服务脚本extmail.sql执行会有语法错误；可先使用如下命令修改extmail.sql配置文件，而后再执行。修改方法如下：
3、此时mysql中已经由extmail提供了几个域，如果要支持别的域可以手动加上去，其实后面的extman就能通过图形界面往上加
# sed -i 's@TYPE=MyISAM@ENGINE=InnoDB@g' extmail.sql



十、配置dovecot

# vi /etc/dovecot.conf
mail_location = maildir:/var/mailbox/%d/%n/Maildir
……
auth default {
    mechanisms = plain
    passdb sql {
        args = /etc/dovecot-mysql.conf
    }
    userdb sql {
        args = /etc/dovecot-mysql.conf
    }
    ……

# vim /etc/dovecot-mysql.conf                 
driver = mysql
connect = host=localhost dbname=extmail user=extmail password=extmail
default_pass_scheme = CRYPT
password_query = SELECT username AS user,password AS password FROM mailbox WHERE username = '%u' 
user_query = SELECT maildir, uidnumber AS uid, gidnumber AS gid FROM mailbox WHERE username = '%u'

说明：如果mysql服务器是本地主机，即host=localhost时，如果mysql.sock文件不是默认的/var/lib/mysql/mysql.sock，可以使用host=“sock文件的路径”来指定新位置；例如，使用通用二进制格式安装的MySQL，其soc文件位置为/tmp/mysql.sock，相应地，connect应按如下方式定义。
connect = host=/tmp/mysql.sock dbname=extmail user=extmail password=extmail



接下来启动dovecot服务：

# service dovecot start
# chkconfig dovecot on



十一、安装Extmail-1.2

说明：如果extmail的放置路径做了修改，那么配置文件webmail.cf中的/var/www路径必须修改为你所需要的位置。本文使用了默认的/var/www，所以，以下示例中并没有包含路径修改的相关内容。

1、安装
# tar zxvf extmail-1.2.tar.gz
# mkdir -pv /var/www/extsuite
# mv extmail-1.2 /var/www/extsuite/extmail
# cp /var/www/extsuite/extmail/webmail.cf.default  /var/www/extsuite/extmail/webmail.cf

2、修改主配置文件
#vi /var/www/extsuite/extmail/webmail.cf

部分修改选项的说明：

SYS_MESSAGE_SIZE_LIMIT = 5242880
用户可以发送的最大邮件

SYS_USER_LANG = en_US
语言选项，可改作：
SYS_USER_LANG = zh_CN

SYS_MAILDIR_BASE = /home/domains
此处即为您在前文所设置的用户邮件的存放目录，可改作：
SYS_MAILDIR_BASE = /var/mailbox

SYS_MYSQL_USER = db_user
SYS_MYSQL_PASS = db_pass
以上两句句用来设置连接数据库服务器所使用用户名、密码和邮件服务器用到的数据库，这里修改为：
SYS_MYSQL_USER = extmail
SYS_MYSQL_PASS = extmail

SYS_MYSQL_HOST = localhost
指明数据库服务器主机名，这里默认即可

SYS_MYSQL_TABLE = mailbox
SYS_MYSQL_ATTR_USERNAME = username
SYS_MYSQL_ATTR_DOMAIN = domain
SYS_MYSQL_ATTR_PASSWD = password

以上用来指定验正用户登录里所用到的表，以及用户名、域名和用户密码分别对应的表中列的名称；这里默认即可

SYS_AUTHLIB_SOCKET = /var/spool/authdaemon/socket
此句用来指明authdaemo socket文件的位置，这里修改为：
SYS_AUTHLIB_SOCKET = /usr/local/courier-authlib/var/spool/authdaemon/socket


3、apache相关配置

由于extmail要进行本地邮件的投递操作，故必须将运行apache服务器用户的身份修改为您的邮件投递代理的用户；本例中打开了apache服务器的suexec功能，故使用以下方法来实现虚拟主机运行身份的指定。此例中的MDA为postfix自带，因此将指定为postfix用户：
<VirtualHost *:80>
ServerName mail.magedu.com
DocumentRoot /var/www/extsuite/extmail/html/
ScriptAlias /extmail/cgi /var/www/extsuite/extmail/cgi
Alias /extmail /var/www/extsuite/extmail/html
SuexecUserGroup postfix postfix
</VirtualHost>

修改 cgi执行文件属主为apache运行身份用户：
# chown -R postfix.postfix /var/www/extsuite/extmail/cgi/

如果您没有打开apache服务器的suexec功能,也可以使用以下方法解决：
# vim /etc/httpd/httpd.conf
User postfix
Group postfix

<VirtualHost *:80>
ServerName mail.magedu.com
DocumentRoot /var/www/extsuite/extmail/html/
ScriptAlias /extmail/cgi /var/www/extsuite/extmail/cgi
Alias /extmail /var/www/extsuite/extmail/html
</VirtualHost>

4、依赖关系的解决

extmail将会用到perl的Unix::syslogd功能，您可以去http://search.cpan.org搜索下载原码包进行安装。
# tar zxvf Unix-Syslog-0.100.tar.gz
# cd Unix-Syslog-0.100
# perl Makefile.PL
# make
# make install

5、启动apache服务
# service httpd start
# chkconfig httpd on



十二、安装Extman-1.1

1、安装及基本配置

# tar zxvf  extman-1.1.tar.gz
# mv extman-1.1 /var/www/extsuite/extman

修改配置文件以符合本例的需要：
# cp /var/www/extsuite/extman/webman.cf.default  /var/www/extsuite/extman/webman.cf
# vi /var/www/extsuite/extman/webman.cf

SYS_MAILDIR_BASE = /home/domains
此处即为您在前文所设置的用户邮件的存放目录，可改作：
SYS_MAILDIR_BASE = /var/mailbox

SYS_DEFAULT_UID = 1000
SYS_DEFAULT_GID = 1000
此两处后面设定的ID号需更改为前而创建的postfix用户和postfix组的id号，本文使用的是2525，因此，上述两项需要修改为：
SYS_DEFAULT_UID = 2525
SYS_DEFAULT_GID = 2525

SYS_MYSQL_USER = webman
SYS_MYSQL_PASS = webman
修改为：
SYS_MYSQL_USER = extmail
SYS_MYSQL_PASS = extmail

而后修改cgi目录的属主：
# chown -R postfix.postfix /var/www/extsuite/extman/cgi/

在apache的主配置文件中Extmail的虚拟主机部分，添加如下两行：
ScriptAlias /extman/cgi /var/www/extsuite/extman/cgi
Alias /extman /var/www/extsuite/extman/html

创建其运行时所需的临时目录，并修改其相应的权限：
#mkdir  -pv  /tmp/extman
#chown postfix.postfix  /tmp/extman

修改
SYS_CAPTCHA_ON = 1
为
SYS_CAPTCHA_ON = 0

好了，到此为止，重新启动apache服务器后，您的Webmail和Extman已经可以使用了，可以在浏览器中输入指定的虚拟主机的名称进行访问，如下：
http://mail.magedu.com

选择管理即可登入extman进行后台管理了。默认管理帐号为：root@extmail.org  密码为：extmail*123*

说明：
(1) 如果您安装后无法正常显示校验码，安装perl-GD模块会解决这个问题。如果想简单，您可以到以下地址下载适合您的平台的rpm包，安装即可：  http://dries.ulyssis.org/rpm/packages/perl-GD/info.html
(2) extman-1.1自带了图形化显示日志的功能；此功能需要rrdtool的支持，您需要安装此些模块才可能正常显示图形日志。


2、配置Mailgraph_ext，使用Extman的图形日志：（下面所需的软件包面要自己下载）

接下来安装图形日志的运行所需要的软件包Time::HiRes、File::Tail和rrdtool，其中前两个包您可以去http://search.cpan.org搜索并下载获得，后一个包您可以到 http://oss.oetiker.ch/rrdtool/pub/?M=D下载获得； 注意安装顺序不能改换。

安装Time::HiRes
#tar zxvf Time-HiRes-1.9707.tar.gz
#cd Time-HiRes-1.9707
#perl Makefile.PL
#make
#make test
#make install

安装File::Tail
#tar zxvf File-Tail-0.99.3.tar.gz
#cd File-Tail-0.99.3
#perl Makefile
#make
#make test
#make install

安装rrdtool-1.2.23
#tar zxvf rrdtool-1.2.23.tar.gz
#cd rrdtool-1.2.23
#./configure --prefix=/usr/local/rrdtool
#make
#make install

创建必要的符号链接(Extman会到这些路径下找相关的库文件)
#ln -sv /usr/local/rrdtool/lib/perl/5.8.5/i386-linux-thread-multi/auto/RRDs/RRDs.so   /usr/lib/perl5/5.8.5/i386-linux-thread-multi/
#ln -sv /usr/local/rrdtool/lib/perl/5.8.5/RRDp.pm   /usr/lib/perl5/5.8.5
#ln -sv /usr/local/rrdtool/lib/perl/5.8.5/i386-linux-thread-multi/RRDs.pm   /usr/lib/perl5/5.8.5

复制mailgraph_ext到/usr/local，并启动之
# cp -r /var/www/extsuite/extman/addon/mailgraph_ext  /usr/local  
# /usr/local/mailgraph_ext/mailgraph-init start 

启动cmdserver(在后台显示系统信息) 
# /var/www/extsuite/extman/daemon/cmdserver --daemon

添加到自动启动队列
# echo “/usr/local/mailgraph_ext/mailgraph-init start” >> /etc/rc.d/rc.local
# echo “/var/www/extsuite/extman/daemon/cmdserver -v -d” >> /etc/rc.d/rc.local 

使用方法： 等待大约15分钟左右，如果邮件系统有一定的流量，即可登陆到extman里，点“图形日志”即可看到图形化的日志。具体每天，周，月，年的则点击相应的图片进入即可。 






十三、配置postfix使用maildrop投递邮件


 maildrop是一个使用C++编写的用来代替本地MDA的带有过滤功能邮件投递代理，是courier邮件系统组件之一。它从标准输入接受信息并投递到用户邮箱；maildrop既可以将邮件投递到mailboxes格式邮箱，亦可以将其投递到maildirs格式邮箱。同时，maildrop可以从文件中读取入站邮件过滤指示，并由此决定是将邮件送入用户邮箱或者转发到其它地址等。和procmail不同的是，maildrop使用结构化的过滤语言，因此，邮件系统管理员可以开发自己的过滤规则并应用其中。

 我们在此将使用maildrop来代替postfix自带的MDA，并以此为基础扩展后文的邮件杀毒和反垃圾邮件功能的调用；在此可能会修改前文中的许多设置，请确保您的设置也做了相应的修改。

 1、安装

 将courier-authlib的头文件及库文件(参考第八部分的第四小节)链接至/usr目录(编译maildrop时会到此目录下找此些相关的文件):
 # ln -sv /usr/local/courier-authlib/bin/courierauthconfig   /usr/bin
 # ln -sv /usr/local/courier-authlib/include/*   /usr/include

 maildrop需要pcre的支持，因此，需要事先提供pcre的头文件及库文件等开发组件。如果选择以yum源来提供pcre，请确保安装pcre-devel包。
 # yum -y install pcre-devel

 # groupadd -g 1001 vmail
 # useradd -g vmail -u 1001 -M -s /sbin/nologin vmail
 # tar xf maildrop-2.6.0.tar.bz2
 # cd maildrop-2.6.0
 # ./configure \
     --enable-sendmail=/usr/sbin/sendmail \
     --enable-trusted-users='root vmail' \
     --enable-syslog=1 --enable-maildirquota \
     --enable-maildrop-uid=1001 \
     --enable-maildrop-gid=1001 \
     --with-trashquota --with-dirsync
 # make
 # make install

 检查安装结果，请确保有"Courier Authentication Library extension enabled."一句出现：
 # maildrop -v
maildrop 2.6.0 Copyright 1998-2005 Double Precision, Inc.
GDBM/DB extensions enabled.
Courier Authentication Library extension enabled.
Maildir quota extension are now always enabled.
This program is distributed under the terms of the GNU General Public
License. See COPYING for additional information.


 2、新建其配置文件/etc/maildroprc文件，首先指定maildrop的日志记录位置：
 # vi /etc/maildroprc
 添加：
 logfile "/var/log/maildrop.log" 

 # touch /var/log/maildrop.log
 # chown vmail.vmail /var/log/maildrop.log

 3、配置Postfix

 编辑master.cf
 # vi /etc/postfix/master.cf
 启用如下两行
 maildrop  unix  -       n       n       -       -       pipe
    flags=DRhu user=vmail argv=/usr/local/bin/maildrop -d ${recipient}

 注意：定义transport的时候，即如上两行中的第二行，其参数行必须以空格开头，否则会出错。

 编辑main.cf
 # vi /etc/postfix/main.cf
 virtual_transport = virtual
 修改为：
 virtual_transport = maildrop

 将下面两项指定的UID和GID作相应的修改:
 virtual_uid_maps = static:2525
 virtual_gid_maps = static:2525
 修改为:
 virtual_uid_maps = static:1001
 virtual_gid_maps = static:1001


 4、编辑/etc/authmysqlrc

 # vi /etc/authmysqrc
 MYSQL_UID_FIELD  '2525'
 MYSQL_GID_FIELD  '2525'
 更改为：
 MYSQL_UID_FIELD  '1001'
 MYSQL_GID_FIELD  '1001'

注意：没有此处的修改，maildrop可能会报告 “signal 0x06”的错误报告。

5、编辑/etc/httpd/httpd.conf，修改运行用户:

如果启用了suexec的功能，则将虚拟主机中指定的
SuexecUserGroup postfix postfix
修改为：
SuexecUserGroup vmail vmail

如果没有使用上面的功能，则修改User和Group指令后的用户为vmail
将前文中的如下项
User postfix
Group postfix 
修改为：
User vmail
Group vmail

6、将用户邮件所在的目录/var/mailbox和extman的临时目录/tmp/extman的属主和属组指定为vmail
#chown -R vmail.vmail /var/mailbox
#chown -R vmail.vmail /tmp/extman

7、修改extman的主配置文件中的默认用户ID和组ID，确保其为类似如下内容
SYS_DEFAULT_UID = 1001
SYS_DEFAULT_GID = 1001

8、验正
接下来重新启动postfix和apache，进行发信测试后，如果日志中的记录类同以下项，则安装成功
Apr 15 15:33:54 localhost postfix/pipe[11964]: 04B92147CE9: to=<jerry@magedu.com>, relay=maildrop, delay=0.16, delays=0.07/0.03/0/0.07, dsn=2.0.0, status=sent (delivered via maildrop service)


十四、安装clamav-0.97.7

 最新的clamav-0.97.7需要zlib-1.2.2以上的版本的支持，因此需要事先安装相应版本的zlib-devel；在RHEL5.8上，使用系统yum源安装即可。

1、安装clamav-0.97.7

 添加ClamAV运行所需的组和用户：
 #groupadd clamav
 #useradd -g clamav -s /sbin/nologin -M clamav

 添加配合amavisd-new使用的用户amavis
 #groupadd amavis
 #useradd -g amavis -s /sbin/nologin -M amavis

 #tar zxvf clamav-0.97.7.tar.gz
 #cd clamav-0.97.7
 #./configure --prefix=/usr/local/clamav --with-dbdir=/usr/local/clamav/share --sysconfdir=/etc/clamav
 #make
 #make check
 #make install

 3、配置Clam AntiVirus：

 编辑主配置文件：
 #vim /etc/clamav/clamd.conf

 注释掉第八行的Example,如下：
 # Example

 找到如下行
 #LogFile /tmp/clamd.log
 #PidFile /var/run/clamd.pid
 LocalSocket /tmp/clamd.socket
 #DatabaseDirectory /var/lib/clamav
 #User clamav
 修改为：
 LogFile /var/log/clamav/clamd.log
 PidFile /var/run/clamav/clamd.pid
 LocalSocket /var/run/clamav/clamd.socket
 DatabaseDirectory /usr/local/clamav/share
 User amavis

 启用以下选项
 LogSyslog yes
 LogFacility LOG_MAIL
 LogVerbose yes
 StreamMaxLength 20M   

 说明：上面最后一个参数后面的数值应该与邮件服务器允许的最大附件值相一致


 编辑更新进程的配置文件
 #vim /etc/clamav/freshclam.conf

 注释掉Example，如下:
 # Example

 找到如下行
 #DatabaseDirectory /var/lib/clamav
 #UpdateLogFile /var/log/freshclam.log
 PidFile /var/run/freshclam.pid
 分别修改为：
 DatabaseDirectory /usr/local/clamav/share
 UpdateLogFile /var/log/clamav/freshclam.log
 PidFile /var/run/clamav/freshclam.pid

 启用以下选项：
 DatabaseMirror db.XY.clamav.net  (这里也可以把XY改成您的国家代码来实现，比如，我们用cn来代替)
 LogSyslog yes
 LogFacility LOG_MAIL
 LogVerbose yes

 4、建立日志所在的目录、进程与socket所在的目录，并让它属于clamav用户：

 # mkdir -v /var/log/clamav
 # chown -R amavis.amavis /var/log/clamav
 # mkdir -v /var/run/clamav
 # chmod 700 /var/run/clamav
 # chown -R amavis.amavis /var/run/clamav

 建立freshlog的日志文件
 #touch  /var/log/clamav/freshclam.log
 #chown  clamav.clamav  /var/log/clamav/freshclam.log

 5、配置crontab，让Clam AntiVirus每小时检测一次新的病毒库：

 # crontab -e
 添加：
 37 * * * * /usr/local/clamav/bin/freshclam

 6、配置库文件搜索路径：

 # echo “/usr/local/clamav/lib” >> /etc/ls.so.conf
 # ldconfig -v

 7、配置clamav开机自动启动

 # cp contrib/init/RedHat/clamd  /etc/rc.d/init.d/clamd
 # cp contrib/init/RedHat/clamav-milter  /etc/rc.d/init.d/clamav-milter
 # chkconfig --add clamd
 # chkconfig --add clamav-milter
 # chkconfig --level 2345 clamd on
 # chkconfig --level 2345 clamav-milter on

 编辑/etc/rc.d/init.d/clamd，将服务进程的路径指向刚才的安装目录
 #vi /etc/rc.d/init.d/clamd
 找到如下行
 progdir="/usr/local/sbin"
 修改为：
 progdir="/usr/local/clamav/sbin"

 启动clamd
 #service clamd start

















