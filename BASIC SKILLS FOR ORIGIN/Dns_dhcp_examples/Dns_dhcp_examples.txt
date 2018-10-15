DNS: 域名解析，BIND: Berkeley Internet Name Domain
DNS: Domain Name Service
域名：www.magedu.com(主机名，FQDN：Full Qualified Domain Name, 完全限定域名)
DNS：名称解析，Name Resolving 名称转换（背后有查询过程，数据库）
	FQDN<-->IP
	172.16.0.1		www.magedu.com.
	172.16.0.2		mail.magedu.com.


stub resolver: 名称解析器	
TLD:(top level domain)
	组织域：.com, .org, .net, .cc
	国家域: .cn, .tw, .hk, .iq, .ir, .jp
	反向域: IP-->FQDN
		反向：IP-->FQDN
		正向：FQDN-->IP
查询：两段式：递归（一般用户是递归），迭代（一般nameserver是迭代）

	递归：只发出一次请求
	迭代：发出多次请求
	
解析：
	正向：FQDN-->IP
	反向：IP-->FQDN
	

DNS：分布式数据库
	上级仅知道其直接下级；
	下级只知道根的位置；

DNS服务器：
	接受本地客户查询请求（递归）
	外部客户端请求：请求权威答案
		肯定答案：TTL（缓存时间）
		否定答案：TTL
	外部客户端请求：非权威答案
		
	
DNS服务器类型
	主DNS服务器: 数据修改
	辅助DNS服务器：请求数据同步
		serial number（版本号，辅DNS的版本号与主DNS版本号对比，不同则更新）
		refresh（辅DNS来检查周期）
		retry（重查时间）
		expire（认定丢失时间）
		nagative answer TTL（否定缓存时间）
	缓存DNS服务器（不提供权威答案，权威答案只能由本尊给）
	转发器（不缓存只转发）

数据库中的，每一个条目称作一个资源记录(Resource Record, RR)
资源记录的格式：

$TTL 600;（全局TTL，下面记录可以继承）

NAME	[TTL]   	IN			RRT		VALUE
www.magedu.com.		IN			A		1.1.1.1


1.1.1.1			IN			PTR		www.magedu.com.


资源记录类型（RRT）：
SOA(Start Of Authority): 标明一个区域内部主从DNS服务器如何同步数据，以及起始授权对象是谁（FQDN, 一般是主DNS服务器）
	ZONE NAME		TTL		IN		SOA		FQDN		ADMINISTRATOR_MAILBOX (
						serial number
						refresh
						retry
						expire
						na ttl )
	时间单位：M（分钟）、H（小时）、D（天）、W（周），默认单位是秒
	邮箱格式：admin@magedu.com -写为-> admin.magedu.com（@有特殊意义，表示ZONE NAME）
	***在区域里面一定要注意最后的一个根点.不能少
	magedu.com.		600		IN		SOA		ns1.magedu.com.		admin.magedu.com. (
						2013040101
						1H
						5M
						1W
						1D )
NS(Name Server): ZONE NAME --> FQDN（自报家门）（其A记录一般在上级就指定了，但是为了反回IP，也要指定）
	magedu.com.		600		IN		NS		ns1.magedu.com.
	magedu.com.		600		IN		NS		ns2.magedu.com.
	ns1.magedu.com.		600		IN		A		1.1.1.2
	ns2.magedu.com.		600		IN		A		1.1.1.5

MX(Mail eXchanger): ZONE NAME --> FQDN
优先级：0-99，数字越小级别越高
	ZONE NAME		TTL		IN		MX  pri		VALUE
	
	magedu.com.		600		IN		MX  10		mail.magedu.com.
	mail.magedu.com.	600		IN		A		1.1.1.3

A（address）：	FQDN-->IPv4	
AAAA：FQDN-->IPv6

PTR(pointer)：IP-->FQDN

CNAME(Canonical NAME): FQDN-->FQDN
	www2.magedu.com.		IN		CNAME		www.magedu.com.

*还可能有以下几种：
TXT
CHAOS
SRV



***两者没有必然联系，本域在上级区域中记录，下级区域在本域中记录，在生产应用中都是区域在工作，正反区域分开联系
域：Domain（逻辑概念）
区域：Zone（物理概念）

***上级授权记录
.com
magedu.com.		IN		NS		ns.magedu.com.
ns.magedu.com.		IN		A		192.168.0.10

例1、
magedu.com.	192.168.0.0/24
www		192.168.0.1
mail		192.168.0.2, MX

建立两个区域文件：
正向区域文件
magedu.com.		IN		SOA	
简写为：
@（配制文件定义过）	IN		SOA

www.maged.com.		IN		A	192.168.0.1
简写为：
www			IN		A	192.168.0.1

	
反向区域文件：
0.168.192.in-addr.arpa.		IN	SOA	

1.0.168.192.in-addr.arpa.	IN	PTR	www.magedu.com.
简写为：
1				IN	PTR	www.magedu.com.


区域传送的类型：主辅更新类型
	完全区域传送: axfr 
	增量区域传送：ixfr
	
区域类型：
	主区域：master
	从区域：slave
	提示区域：hint
	转发区域：forward
zone "ZONE NAME" IN {
	type {master|slave|hint|forward};
	
};

主区域：
	file "区域数据文件";
	
从区域：
	file "区域数据文件";
	masters { master1_ip; };


DNS：BIND
	Berkeley Internet Name Domain
	ISC：后来由此组织管理
	
bind97：配置文件
	/etc/named.conf
		BIND进程的工作属性
		区域的定义
	/etc/rndc.key
		rndc: Remote Name Domain Controller
		密钥文件 
		配置信息：/etc/rndc.conf
		
	/var/named/
		区域数据文件

	/etc/rc.d/init.d/named
		{start|stop|restart|status|reload}
		
	二进制程序：named

bind-chroot: 将DNS所需的配制文件全部归于自建的一个新根下，更安全
	默认：named
		用户：named
		组：named
		
	/var/named/chroot/
		etc/named.conf
		etc/rdnc.key
		sbin/named
		var/named/

***配置中常用的几个命令	
named-checkconfig：检查named.conf文件有没有语法错误，但不能查出逻辑错误
name-checkzone：检查区域文件中是否有语法错误
dig: Domain Information Gropher
dig -t RT NAME @IP
dig -t NS mageedu.com
dig -x IP: 
	根据IP查找FQDN
dig:
	aa: Authority Answer
	
host -t RT NAME: 查询名称的解析结果

nslookup: 交互式
nslookup>
		server IP（设定DNS服务器）
		set q=RT（设定资源查询类型）
		NAME 


***DNS: 监听的协议及端口：
		53/udp
		53/tcp
		953/tcp, rndc
		
		



临时性地关闭SELinux:
# getenforce
Enforcing

# setenforce 0
# setenforce 1

永久关闭：
# vim /etc/selinux/config


DNS RT
	$TTL 宏
	$ORIGIN mageedu.com.
	$GENERATE
	NAME	[TTL]	IN	RT		VALUE	
SOA：
	@	IN	SOA		MASTER_NS_SERVER_FQDN	ADMIN_MAILBOX （
	
	）
NS：
	@	IN	NS	NS_SERVER_FQDN
MX:
	@	IN	MX  pri	MX_SERVER_FQDN
A
AAAA
PTR
CNAME
	Alias	IN	CNAME	FQDN

泛域解析：
	*.mageedu.com.		IN	A	

rndc: 控制DNS服务器，远程控制

正向区域授权：
SUB_ZONE_NAME	IN	NS	NSSERVER_SUB_ZONE_NAME
NSSERVER_SUB_ZONE_NAME	IN	A	IP

forward {only|first}
forwarders {};
only：如果转发服务器不接受转发就放弃
first：如果转发服务器不接受转发就找别的

zone "ZONE_NAME" IN {
	type forward;
	forwarders {};	
};


allow-recursion {};	#允许给谁递归
allow-query {};		#允许谁来查询
	allow-query { 172.16.0.0/16; 127.0.0.0/8; 10.0.0.0/8; }
allow-transfer {};	#允许谁进行传送
	axfr：完全传送
	ixfr：增量传送

***定义访问控制，类似涵数一样被方便调用
acl ACL_NAME { 
	172.16.0.0/16;
	127.0.0.0/8;
};

acl innet { 
	172.16.0.0/16;
	127.0.0.0/8;
};

allow-query { innet; };
	      none;
	      any;

***智能DNS基础，用视图判断DNS来源，将DNS解析到最佳DNS服务器上，避免服务器超载而加快速度
view VIEW_NAME {

};
视图一旦定义，所有的区域都必须定义在视图中


***定义弹性日志系统，更加细致且根据需要记录必要日志，避免日志过大影响系统性能
logging {

};
category  defines what should be logged
	1、All log messages are divided into one of fifteen categories.
	2、A category directive will be used to determine to which channels log messages should be directed.
	3、Messages in one category may be directed to multiple channels
catagory: bind的子系统 日志源
	查询
	区域传送
	
	可以通过catagory自定义日志来源
Fifteen categories to choose from
	default  Defines default channel for categories
	general  Catch-all category for unclassified messages
	client  Client request problems
	config  Configuration file problems
	dispatch  Dispatch of inbound packets to internal server modules
	dnssec  DNSSEC and TSIG
	lame-servers  Problems due to remote server misconfiguration
	network  Related to network operations
	notify  NOTIFY announcements
	queries  Query processing
	resolver  Recursive query processing
	security  Accepted or denied requests
	update  Dynamic updates
	xfer-in  Zone transfers received by the server
	xfer-out  Zone transfers sent by the server


channel  defines where log information should go
channel: 日志保存位置
		syslog
		file: 自定义保存日志信息的文件

queryperf : 压力测试



例：以上所有知识点汇聚成完整的实验
***自已配置bind的关键配置文件
[root@RHEL6 ~]# mv /etc/named.conf /root/named.conf.backup 
[root@RHEL6 ~]# vim /etc/named.conf
***注意语法格式
*options是全局配置
options {
        directory       "/var/named";
};

*zone表示区域配置
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
[root@RHEL6 ~]# chown root:named /etc/named.conf 
[root@RHEL6 ~]# chmod 640 /etc/named.conf 

*检查配置文件的语法错误
[root@RHEL6 ~]# named-checkconf 
[root@RHEL6 ~]# named-checkzone "localhost" /var/named/named.localhost 
zone localhost/IN: loaded serial 0
OK
[root@RHEL6 ~]#
[root@RHEL6 ~]# service named start
Starting named:                                            [  OK  ]
[root@RHEL6 ~]# 
[root@RHEL6 ~]# tail /var/log/messages
Apr 17 08:59:12 RHEL6 named[2332]: automatic empty zone: 8.E.F.IP6.ARPA
Apr 17 08:59:12 RHEL6 named[2332]: automatic empty zone: 9.E.F.IP6.ARPA
Apr 17 08:59:12 RHEL6 named[2332]: automatic empty zone: A.E.F.IP6.ARPA
Apr 17 08:59:12 RHEL6 named[2332]: automatic empty zone: B.E.F.IP6.ARPA
Apr 17 08:59:12 RHEL6 named[2332]: command channel listening on 127.0.0.1#
953Apr 17 08:59:12 RHEL6 named[2332]: command channel listening on ::1#953
Apr 17 08:59:12 RHEL6 named[2332]: the working directory is not writable
Apr 17 08:59:12 RHEL6 named[2332]: zone 0.0.127.in-addr.arpa/IN: loaded se
rial 0Apr 17 08:59:12 RHEL6 named[2332]: zone localhost/IN: loaded serial 0
Apr 17 08:59:12 RHEL6 named[2332]: running
[root@RHEL6 ~]# getenforce 
Disabled
[root@RHEL6 ~]# setenforce 0
setenforce: SELinux is disabled

*在配置文件里面永久关闭
[root@RHEL6 ~]# vim /etc/selinux/config 
SELINUX=disabled

*测试能不能解析
[root@RHEL6 ~]# vim /etc/resolv.conf 
nameserver 192.168.3.66
[root@RHEL6 ~]# ping baidu.com
PING baidu.com (111.13.101.208) 56(84) bytes of data.
64 bytes from 111.13.101.208: icmp_seq=1 ttl=50 time=74.0 ms
64 bytes from 111.13.101.208: icmp_seq=2 ttl=50 time=78.3 ms
[root@RHEL6 ~]# chkconfig --list named
named          	0:off	1:off	2:off	3:off	4:off	5:off	6:off
[root@RHEL6 ~]# chkconfig named on
[root@RHEL6 ~]# chkconfig --list named
named          	0:off	1:off	2:on	3:on	4:on	5:on	6:off

***以上只是缓存服务器，接下来实验申请过一个域名mageedu.com后的配置
[root@RHEL6 ~]# vim /etc/named.conf 
zone "mageedu.com" IN {
        type master;
        file "mageedu.com.zone";
};
[root@RHEL6 ~]# named-checkconf 
[root@RHEL6 ~]# service named restart
Stopping named:                                            [  OK  ]
Starting named: 
Error in named configuration:
zone localhost/IN: loaded serial 0
zone 0.0.127.in-addr.arpa/IN: loaded serial 0
zone mageedu.com/IN: loading from master file mageedu.com.zone failed: f
ile not foundzone mageedu.com/IN: not loaded due to errors.
_default/mageedu.com/IN: file not found
                                                           [FAILED]
[root@RHEL6 ~]# vim /var/named/mageedu.com.zone
$TTL 600
#SOA 记录
mageedu.com.    IN      SOA     ns1.mageedu.com.        admin.mageedu.com (
                                2016041701
                                1H
                                5M
                                2D
                                6H )
#NS 记录
mageedu.com.    IN      NS      ns1.mageedu.com.
                
#MX 记录（当域名相同时可以省略，默认从上面继承）
                IN      MX 10   mail
ns1             IN      A       192.168.3.66
mail            IN      A       192.168.3.67
www             IN      A       192.168.3.66
www             IN      A       192.168.3.68
ftp             IN      CNAME   www
[root@RHEL6 ~]# cd /var/named/
[root@RHEL6 named]# ll
total 32
drwxrwx---. 2 named named 4096 May 26  2010 data
drwxrwx---. 2 named named 4096 May 26  2010 dynamic
-rw-r--r--  1 root  root   370 Apr 17 09:31 mageedu.com.zone
-rw-r-----. 1 root  named 1892 Feb 18  2008 named.ca
-rw-r-----. 1 root  named  152 Dec 15  2009 named.empty
-rw-r-----. 1 root  named  152 Jun 21  2007 named.localhost
-rw-r-----. 1 root  named  168 Dec 15  2009 named.loopback
drwxrwx---. 2 named named 4096 May 26  2010 slaves
[root@RHEL6 named]# chmod 640 mageedu.com.zone 
[root@RHEL6 named]# chown root:named mageedu.com.zone 
[root@RHEL6 named]# named-checkzone "mageedu.com" /var/named/mageedu.com.zone 
zone mageedu.com/IN: loaded serial 2016041701
OK
[root@RHEL6 named]# 
[root@RHEL6 named]# service named restart
Stopping named:                                            [  OK  ]
Starting named:                                            [  OK  ]
[root@RHEL6 named]# dig -t A www.mageedu.com

; <<>> DiG 9.7.0-P2-RedHat-9.7.0-5.P2.el6 <<>> -t A www.mageedu.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 10
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 2, AUTHORITY: 1, ADDITIONAL: 1

;; QUESTION SECTION:
;www.mageedu.com.		IN	A

;; ANSWER SECTION:
www.mageedu.com.	600	IN	A	192.168.3.68
www.mageedu.com.	600	IN	A	192.168.3.66

;; AUTHORITY SECTION:
mageedu.com.		600	IN	NS	ns1.mageedu.com.

;; ADDITIONAL SECTION:
ns1.mageedu.com.	600	IN	A	192.168.3.66

;; Query time: 0 msec
;; SERVER: 192.168.3.66#53(192.168.3.66)
;; WHEN: Sun Apr 17 09:43:04 2016
;; MSG SIZE  rcvd: 99
[root@RHEL6 named]# dig -t CANME ftp.mageedu.com
;; Warning, ignoring invalid type CANME

; <<>> DiG 9.7.0-P2-RedHat-9.7.0-5.P2.el6 <<>> -t CANME ftp.mageedu.com
;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 31697
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 1, ADDITIONAL: 1

;; QUESTION SECTION:
;ftp.mageedu.com.		IN	A

;; ANSWER SECTION:
ftp.mageedu.com.	600	IN	CNAME	www.mageedu.com.
www.mageedu.com.	600	IN	A	192.168.3.66
www.mageedu.com.	600	IN	A	192.168.3.68

;; AUTHORITY SECTION:
mageedu.com.		600	IN	NS	ns1.mageedu.com.

;; ADDITIONAL SECTION:
ns1.mageedu.com.	600	IN	A	192.168.3.66

;; Query time: 2 msec
;; SERVER: 192.168.3.66#53(192.168.3.66)
;; WHEN: Sun Apr 17 09:45:03 2016
;; MSG SIZE  rcvd: 117
[root@RHEL6 named]# host -t A www.mageedu.com
www.mageedu.com has address 192.168.3.68
www.mageedu.com has address 192.168.3.66
[root@RHEL6 named]# host -t MX mageedu.com
mageedu.com mail is handled by 10 mail.mageedu.com.
[root@RHEL6 named]# host -t SOA mageedu.com
mageedu.com has SOA record ns1.mageedu.com. admin.mageedu.com.mageedu.com. 20160
41701 3600 300 172800 21600
[root@RHEL6 named]# vim /etc/named.conf 
zone "3.168.192.in-addr.arpa" IN {
        type master;
        file "3.168.192.in-addr.arpa";
};
[root@RHEL6 named]# vim /var/named/3.168.192.in-addr.arpa 
$TTL 600
@               IN      SOA     ns1.mageedu.com.        admin.mageedu.com (
                                2016041701
                                1H
                                5M
                                2D
                                6H )
                IN      NS      ns1.mageedu.com.
66              IN      PTR     ns1.mageedu.com.
66              IN      PTR     www.mageedu.com.
68              IN      PTR     mail.mageedu.com.
67              IN      PTR     www.mageedu.com.
[root@RHEL6 named]# chown root:named 3.168.192.in-addr.arpa 
[root@RHEL6 named]# chmod 640 3.168.192.in-addr.arpa 
[root@RHEL6 named]# named-checkconf 
[root@RHEL6 named]# named-checkzone "3.168.192.in-addr.arpa" "3.168.192.in-addr.arpa" 
zone 3.168.192.in-addr.arpa/IN: loaded serial 2016041701
OK
[root@RHEL6 named]# 
[root@RHEL6 named]# service named restart
Stopping named:                                            [  OK  ]
Starting named:                                            [  OK  ]
[root@RHEL6 named]# nslookup
> 192.168.3.66
Server:		192.168.3.66
Address:	192.168.3.66#53

66.3.168.192.in-addr.arpa	name = ns1.mageedu.com.
66.3.168.192.in-addr.arpa	name = www.mageedu.com.
> 


***关于递归，默认状态下是给所有人递归如下：
*这就是默认状态下的递归，相当于dig +recurse -t A www.sohu.com @192.168.3.66
[root@RHEL6 ~]# dig -t A www.sohu.com @192.168.3.66

; <<>> DiG 9.7.0-P2-RedHat-9.7.0-5.P2.el6 <<>> -t A www.sohu.com @192.16
8.3.66;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 38993
;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 5, ADDITIONAL: 0

;; QUESTION SECTION:
;www.sohu.com.			IN	A

;; ANSWER SECTION:
www.sohu.com.		1800	IN	CNAME	gs.a.sohu.com.
gs.a.sohu.com.		300	IN	CNAME	fgz.a.sohu.com.
fgz.a.sohu.com.		300	IN	A	14.18.240.6

;; AUTHORITY SECTION:
a.sohu.com.		3600	IN	NS	s.a.sohu.com.
a.sohu.com.		3600	IN	NS	k.a.sohu.com.
a.sohu.com.		3600	IN	NS	y.a.sohu.com.
a.sohu.com.		3600	IN	NS	x.a.sohu.com.
a.sohu.com.		3600	IN	NS	w.a.sohu.com.

;; Query time: 1054 msec
;; SERVER: 192.168.3.66#53(192.168.3.66)
;; WHEN: Mon Apr 18 09:53:00 2016
;; MSG SIZE  rcvd: 163

*如果明确指出norecurse就是不帮忙递归，那么它会显示说让你们去找根吧，我无能为力
[root@RHEL6 ~]# dig +norecurse -t A www.sina.com @192.168.3.66

; <<>> DiG 9.7.0-P2-RedHat-9.7.0-5.P2.el6 <<>> +norecurse -t A www.sina.
com @192.168.3.66;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 5348
;; flags: qr ra; QUERY: 1, ANSWER: 0, AUTHORITY: 13, ADDITIONAL: 0

;; QUESTION SECTION:
;www.sina.com.			IN	A

;; AUTHORITY SECTION:
com.			172509	IN	NS	b.gtld-servers.net.
com.			172509	IN	NS	j.gtld-servers.net.
com.			172509	IN	NS	f.gtld-servers.net.
com.			172509	IN	NS	e.gtld-servers.net.
com.			172509	IN	NS	i.gtld-servers.net.
com.			172509	IN	NS	c.gtld-servers.net.
com.			172509	IN	NS	a.gtld-servers.net.
com.			172509	IN	NS	k.gtld-servers.net.
com.			172509	IN	NS	h.gtld-servers.net.
com.			172509	IN	NS	g.gtld-servers.net.
com.			172509	IN	NS	d.gtld-servers.net.
com.			172509	IN	NS	l.gtld-servers.net.
com.			172509	IN	NS	m.gtld-servers.net.

;; Query time: 1 msec
;; SERVER: 192.168.3.66#53(192.168.3.66)
;; WHEN: Mon Apr 18 09:57:45 2016
;; MSG SIZE  rcvd: 254

*当然可以用dig +trace 追踪整个过程
[root@RHEL6 ~]# dig +trace -t A www.sina.com @192.168.3.66

; <<>> DiG 9.7.0-P2-RedHat-9.7.0-5.P2.el6 <<>> +trace -t A www.sina.com 
@192.168.3.66;; global options: +cmd
.			517349	IN	NS	b.root-servers.net.
.			517349	IN	NS	i.root-servers.net.
.			517349	IN	NS	e.root-servers.net.
.			517349	IN	NS	k.root-servers.net.
.			517349	IN	NS	c.root-servers.net.
.			517349	IN	NS	j.root-servers.net.
.			517349	IN	NS	f.root-servers.net.
.			517349	IN	NS	a.root-servers.net.
.			517349	IN	NS	h.root-servers.net.
.			517349	IN	NS	m.root-servers.net.
.			517349	IN	NS	d.root-servers.net.
.			517349	IN	NS	l.root-servers.net.
.			517349	IN	NS	g.root-servers.net.
;; Received 492 bytes from 192.168.3.66#53(192.168.3.66) in 1 ms

com.			172800	IN	NS	a.gtld-servers.net.
com.			172800	IN	NS	b.gtld-servers.net.
com.			172800	IN	NS	c.gtld-servers.net.
com.			172800	IN	NS	d.gtld-servers.net.
com.			172800	IN	NS	e.gtld-servers.net.
com.			172800	IN	NS	f.gtld-servers.net.
com.			172800	IN	NS	g.gtld-servers.net.
com.			172800	IN	NS	h.gtld-servers.net.
com.			172800	IN	NS	i.gtld-servers.net.
com.			172800	IN	NS	j.gtld-servers.net.
com.			172800	IN	NS	k.gtld-servers.net.
com.			172800	IN	NS	l.gtld-servers.net.
com.			172800	IN	NS	m.gtld-servers.net.
;; Received 490 bytes from 192.203.230.10#53(e.root-servers.net) in 851 
ms
sina.com.		172800	IN	NS	ns1.sina.com.cn.
sina.com.		172800	IN	NS	ns2.sina.com.cn.
sina.com.		172800	IN	NS	ns3.sina.com.cn.
sina.com.		172800	IN	NS	ns1.sina.com.
sina.com.		172800	IN	NS	ns2.sina.com.
sina.com.		172800	IN	NS	ns4.sina.com.
sina.com.		172800	IN	NS	ns3.sina.com.
;; Received 231 bytes from 192.5.6.30#53(a.gtld-servers.net) in 225 ms

www.sina.com.		60	IN	CNAME	us.sina.com.cn.
us.sina.com.cn.		60	IN	CNAME	news.sina.com.cn.
news.sina.com.cn.	60	IN	CNAME	jupiter.sina.com.cn.
jupiter.sina.com.cn.	3600	IN	CNAME	ara.sina.com.cn.
ara.sina.com.cn.	60	IN	A	58.63.236.248
ara.sina.com.cn.	60	IN	A	121.14.1.189
ara.sina.com.cn.	60	IN	A	121.14.1.190
sina.com.cn.		86400	IN	NS	ns3.sina.com.cn.
sina.com.cn.		86400	IN	NS	ns1.sina.com.cn.
sina.com.cn.		86400	IN	NS	ns4.sina.com.cn.
sina.com.cn.		86400	IN	NS	ns2.sina.com.cn.
;; Received 301 bytes from 61.172.201.254#53(ns2.sina.com.cn) in 15196 ms

*下面我们在配置文件里明确指明递归情况
[root@RHEL6 ~]# vim /etc/named.conf 
options {

        directory "/var/named";
        recursion yes;

};
可以改成只为某类用户递归：
options {

        directory "/var/named";
        allow-recursion { 192.168.3.0/24;};

};
[root@RHEL6 ~]# named-checkconf 
[root@RHEL6 ~]# service named reload
Reloading named:                                           [  OK  ]
[root@RHEL6 ~]# dig +recurse -t A www.baidu.com @192.168.3.66

; <<>> DiG 9.7.0-P2-RedHat-9.7.0-5.P2.el6 <<>> +recurse -t A www.baidu.com @192
.168.3.66;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 29167
;; flags: qr rd ra; QUERY: 1, ANSWER: 3, AUTHORITY: 5, ADDITIONAL: 0

;; QUESTION SECTION:
;www.baidu.com.			IN	A

;; ANSWER SECTION:
www.baidu.com.		1093	IN	CNAME	www.a.shifen.com.
www.a.shifen.com.	300	IN	A	14.215.177.38
www.a.shifen.com.	300	IN	A	14.215.177.37

;; AUTHORITY SECTION:
a.shifen.com.		1200	IN	NS	ns4.a.shifen.com.
a.shifen.com.		1200	IN	NS	ns5.a.shifen.com.
a.shifen.com.		1200	IN	NS	ns1.a.shifen.com.
a.shifen.com.		1200	IN	NS	ns2.a.shifen.com.
a.shifen.com.		1200	IN	NS	ns3.a.shifen.com.

;; Query time: 780 msec
;; SERVER: 192.168.3.66#53(192.168.3.66)
;; WHEN: Mon Apr 18 10:14:29 2016
;; MSG SIZE  rcvd: 180

*这种情况下本机也不能递归，因为不是这段地址
[root@RHEL6 ~]# dig +recurse -t A www.baidu.com @127.0.0.1

; <<>> DiG 9.7.0-P2-RedHat-9.7.0-5.P2.el6 <<>> +recurse -t A www.baidu.com @127
.0.0.1;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: REFUSED, id: 61239
;; flags: qr rd; QUERY: 1, ANSWER: 0, AUTHORITY: 0, ADDITIONAL: 0
;; WARNING: recursion requested but not available

;; QUESTION SECTION:
;www.baidu.com.			IN	A

;; Query time: 0 msec
;; SERVER: 127.0.0.1#53(127.0.0.1)
;; WHEN: Mon Apr 18 10:15:26 2016
;; MSG SIZE  rcvd: 31


***下面介绍完全区域传送和增量区域传送
*axfr 完全区域传送，可以用dig测试得到区域内的所有数据
[root@RHEL6 ~]# dig -t axfr yuliang.com

; <<>> DiG 9.7.0-P2-RedHat-9.7.0-5.P2.el6 <<>> -t axfr yuliang.com
;; global options: +cmd
yuliang.com.		600	IN	SOA	ns1.yuliang.com. admin.yuliang.
com.yuliang.com. 2016041701 86400 300 604800 86400yuliang.com.		600	IN	NS	ns1.yuliang.com.
yuliang.com.		600	IN	MX	10 mail.yuliang.com.
ftp.yuliang.com.	600	IN	CNAME	www.yuliang.com.
mail.yuliang.com.	600	IN	A	192.168.3.67
ns1.yuliang.com.	600	IN	A	192.168.3.66
www.yuliang.com.	600	IN	A	192.168.3.68
yuliang.com.		600	IN	SOA	ns1.yuliang.com. admin.yuliang.
com.yuliang.com. 2016041701 86400 300 604800 86400;; Query time: 1 msec
;; SERVER: 192.168.3.66#53(192.168.3.66)
;; WHEN: Mon Apr 18 10:19:24 2016
;; XFR size: 8 records (messages 1, bytes 228)

*正常情况下除了从DNS之外，不允许其他任何DNS服务器获得传送
[root@RHEL6 ~]# vim /etc/named.conf 
options {
        directory "/var/named";
        allow-recursion { 192.168.3.0/24;};
};

zone "." IN {
        type hint;
        file "named.ca";
};

zone "localhost" IN {
        type master;
        file "named.localhost";
        allow-transfer { none; };
};

zone "0.0.127.in-addr.arpa" IN {
        type master;
        file "named.loopback";
        allow-transfer { none; };
};

zone "yuliang.com" IN {
        type master;
        file "yu.com";
        allow-transfer { 192.168.3.99; };
};

zone "3.168.192.in-addr.arpa" IN {
        type master;
        file "yu.arpa.com";
        allow-transfer { 192.168.3.99; };
};
[root@RHEL6 ~]# service named reload
Reloading named:                                           [  OK  ]
[root@RHEL6 ~]# dig -t axfr 192.168.3.66

; <<>> DiG 9.7.0-P2-RedHat-9.7.0-5.P2.el6 <<>> -t axfr 192.168.3.66
;; global options: +cmd
; Transfer failed.
[root@RHEL6 ~]# 

****按照上面的思路新建一台主机，ip为192.168.3.99，模拟辅DNS服务器
*根据结果显示，在主DNS配置文件中定义过允许192.168.3.99主机传送，所以只有此主机可以传送
[root@localhost ~]# dig -t axfr yuliang.com @192.168.3.66

; <<>> DiG 9.7.0-P2-RedHat-9.7.0-5.P2.el6 <<>> -t axfr yuliang.com @192.168.3.
66;; global options: +cmd
yuliang.com.		600	IN	SOA	ns1.yuliang.com. admin.yuliang
.com.yuliang.com. 2016041701 86400 300 604800 86400yuliang.com.		600	IN	NS	ns1.yuliang.com.
yuliang.com.		600	IN	MX	10 mail.yuliang.com.
ftp.yuliang.com.	600	IN	CNAME	www.yuliang.com.
mail.yuliang.com.	600	IN	A	192.168.3.67
ns1.yuliang.com.	600	IN	A	192.168.3.66
www.yuliang.com.	600	IN	A	192.168.3.68
yuliang.com.		600	IN	SOA	ns1.yuliang.com. admin.yuliang
.com.yuliang.com. 2016041701 86400 300 604800 86400;; Query time: 3 msec
;; SERVER: 192.168.3.66#53(192.168.3.66)
;; WHEN: Tue Apr 19 14:48:52 2016
;; XFR size: 8 records (messages 1, bytes 228)
[root@localhost ~]# scp 192.168.3.66:/etc/named.conf /etc/
root@192.168.3.66's password: 
named.conf                                  100%  519     0.5KB/s   00:00    
[root@localhost ~]# vim /etc/named.conf 
zone "yuliang.com" IN {
        type slave; #从服务器的类型
        file "slaves/yu.com"; #slave目录named组定义了写的权限，正好可以从主服务器同步
        masters { 192.168.3.66; }; #指定谁是主服务器
        allow-transfer { none; }; 
};

zone "3.168.192.in-addr.arpa" IN {
        type slave;
        file "slaves/yu.arpa.com";
        masters { 192.168.3.66; };
        allow-transfer { none; };
};
[root@localhost ~]# named-checkconf 
[root@localhost ~]# service named start
Starting named:                                            [FAILED]
*出现故障注意看日志，搜集信息
[root@localhost ~]# tail -5 /var/log/messages 
Apr 19 16:21:38 localhost named[22366]: using up to 4096 sockets
Apr 19 16:21:38 localhost named[22366]: loading configuration from '/etc/named.conf'
Apr 19 16:21:38 localhost named[22366]: none:0: open: /etc/named.conf: permission denied
Apr 19 16:21:38 localhost named[22366]: loading configuration: permission denied
Apr 19 16:21:38 localhost named[22366]: exiting (due to fatal error)
[root@localhost ~]# ll /etc/named.conf 
-rw-r----- 1 root root 571 Apr 19 16:21 /etc/named.conf
[root@localhost ~]# chgrp named /etc/named.conf 
[root@localhost ~]# ll /etc/named.conf 
-rw-r----- 1 root named 571 Apr 19 16:21 /etc/named.conf
[root@localhost ~]# service named start
Starting named:                                            [  OK  ]
[root@localhost slaves]# cd /var/named/slaves/
[root@localhost slaves]# tail /var/log/messages 
Apr 19 16:23:40 localhost named[22417]: zone localhost/IN: loaded serial 0
Apr 19 16:23:40 localhost named[22417]: running
Apr 19 16:23:40 localhost named[22417]: zone yuliang.com/IN: Transfer started.
Apr 19 16:23:40 localhost named[22417]: transfer of 'yuliang.com/IN' from 192.168.3.66#53: connected using 192.168.3.
99#59201Apr 19 16:23:40 localhost named[22417]: zone yuliang.com/IN: transferred serial 2016041701
Apr 19 16:23:40 localhost named[22417]: transfer of 'yuliang.com/IN' from 192.168.3.66#53: Transfer completed: 1 mess
ages, 8 records, 228 bytes, 0.104 secs (2192 bytes/sec)Apr 19 16:23:41 localhost named[22417]: zone 3.168.192.in-addr.arpa/IN: Transfer started.
Apr 19 16:23:41 localhost named[22417]: transfer of '3.168.192.in-addr.arpa/IN' from 192.168.3.66#53: connected using
 192.168.3.99#60126Apr 19 16:23:41 localhost named[22417]: zone 3.168.192.in-addr.arpa/IN: transferred serial 2016041701
Apr 19 16:23:41 localhost named[22417]: transfer of '3.168.192.in-addr.arpa/IN' from 192.168.3.66#53: Transfer comple
ted: 1 messages, 6 records, 219 bytes, 0.009 secs (24333 bytes/sec)
[root@localhost slaves]# ll
total 8
-rw-r--r-- 1 named named 424 Apr 19 16:23 yu.arpa.com
-rw-r--r-- 1 named named 417 Apr 19 16:23 yu.com

如果主从不同步偿试：
1、关闭selinux,firewall
2、主DNS服务器中一定要给辅DNS授权，也就是主DNS里面要有辅DNS的NS记录
3、同步的前提条件一定是主DNS的serial比辅DNS的serial版本高(手动加1)
4、以前的内核在主DNS服务器中要加上notify yes;
[root@RHEL6 ~]# vim /var/named/yu.com 
yuliang.com.    IN      SOA     ns1.yuliang.com.        admin.yuliang.com (
                                2016041702
yuliang.com.    IN      NS      ns2.yuliang.com.
ns2             IN      A       192.168.3.99

hello           IN      A       192.168.3.88
[root@RHEL6 ~]# vim /var/named/yu.arpa.com 
3.168.192.in-addr.arpa. IN      SOA     ns1.yuliang.com.        admin.yuliang.com (
                                2016041702

3.168.192.in-addr.arpa.         IN      NS      ns2.yuliang.com.
99				IN      PTR     ns2.yuliang.com.
88				IN      PTR     hello.yuliang.com.


[root@RHEL6 ~]# service named reload
Reloading named:                                           [  OK  ]
[root@RHEL6 ~]# 
[root@RHEL6 ~]# tail /var/log/messages
Apr 20 06:41:57 RHEL6 named[2152]: loading configuration from '/etc/named.conf'
Apr 20 06:41:57 RHEL6 named[2152]: using default UDP/IPv4 port range: [1024, 65535]
Apr 20 06:41:57 RHEL6 named[2152]: using default UDP/IPv6 port range: [1024, 65535]
Apr 20 06:41:57 RHEL6 named[2152]: the working directory is not writable
Apr 20 06:41:57 RHEL6 named[2152]: reloading configuration succeeded
Apr 20 06:41:57 RHEL6 named[2152]: zone yuliang.com/IN: loaded serial 2016041702
Apr 20 06:41:57 RHEL6 named[2152]: zone yuliang.com/IN: sending notifies (serial 2016041702)
Apr 20 06:41:57 RHEL6 named[2152]: reloading zones succeeded
Apr 20 06:41:57 RHEL6 named[2152]: client 192.168.3.99#33738: transfer of 'yuliang.com/IN': AXFR-style IXFR starte
dApr 20 06:41:57 RHEL6 named[2152]: client 192.168.3.99#33738: transfer of 'yuliang.com/IN': AXFR-style IXFR ended
Apr 20 06:53:48 RHEL6 named[2152]: zone 3.168.192.in-addr.arpa/IN: loaded serial 2016041702
Apr 20 06:53:48 RHEL6 named[2152]: zone 3.168.192.in-addr.arpa/IN: sending notifies (serial 2016041702)
Apr 20 06:53:48 RHEL6 named[2152]: client 192.168.3.99#33834: transfer of '3.168.192.in-addr.arpa/IN': AXFR-style IXFR started
Apr 20 06:53:48 RHEL6 named[2152]: client 192.168.3.99#33834: transfer of '3.168.192.in-addr.arpa/IN': AXFR-style IXFR ended
[root@localhost slaves]# cat yu.com 
$ORIGIN .
$TTL 600	; 10 minutes
yuliang.com		IN SOA	ns1.yuliang.com. admin.yuliang.com.yuliang.com. (
				2016041702 ; serial
				86400      ; refresh (1 day)
				300        ; retry (5 minutes)
				604800     ; expire (1 week)
				86400      ; minimum (1 day)
				)
			NS	ns1.yuliang.com.
			NS	ns2.yuliang.com.
			MX	10 mail.yuliang.com.
$ORIGIN yuliang.com.
ftp			CNAME	www
hello			A	192.168.3.88
mail			A	192.168.3.67
ns1			A	192.168.3.66
ns2			A	192.168.3.99
www			A	192.168.3.68


***rndc控制DNS服务器，远程控制很方便
*有可能熵池用完了，要手动指
*rndc.key删除，用rndc.conf配置文件验证
*S/C两端都要启动DNS服务
*named.conf最后的include文件不能省略
[root@RHEL6 ~]# rndc-confgen -r /dev/urandom > /etc/rndc.conf
[root@RHEL6 ~]# vim /etc/rndc.conf 
使用末行模式
:.,$w >> /etc/named.conf

*修改inet 0.0.0.0 allow { NEEDED; }
[root@RHEL6 ~]# vim /etc/named.conf 
使用末行模式
:.,$s/^# //g
[root@RHEL6 ~]# rndc -c /etc/rndc.conf status
rndc: connection to remote host closed
This may indicate that
* the remote server is using an older version of the command protocol,
* this host is not authorized to connect,
* the clocks are not synchronized, or
* the key is invalid.
[root@RHEL6 ~]# service named reload
Reloading named:                                           [  OK  ]
*rndc -c 指定文件加子命令指定状态
[root@RHEL6 ~]# rndc -c /etc/rndc.conf status
version: 9.7.0-P2-RedHat-9.7.0-5.P2.el6
CPUs found: 2
worker threads: 2
number of zones: 16
debug level: 0
xfers running: 0
xfers deferred: 0
soa queries in progress: 0
query logging is OFF
recursive clients: 0/0/1000
tcp clients: 0/100
server is up and running
*子命令notify通知DNS服务器
[root@RHEL6 ~]# rndc -c /etc/rndc.conf notify "yuliang.com"
zone notify queued
[root@RHEL6 ~]# tail /var/log/messages
Apr 20 08:48:08 RHEL6 named[2152]: received SIGHUP signal to reload zones
Apr 20 08:48:08 RHEL6 named[2152]: loading configuration from '/etc/named.
conf'Apr 20 08:48:08 RHEL6 named[2152]: using default UDP/IPv4 port range: [1024, 65535]Apr 20 08:48:08 RHEL6 named[2152]: using default UDP/IPv6 port range: [1024, 65535]Apr 20 08:48:08 RHEL6 named[2152]: stopping command channel on ::1#953
Apr 20 08:48:08 RHEL6 named[2152]: the working directory is not writable
Apr 20 08:48:08 RHEL6 named[2152]: reloading configuration succeeded
Apr 20 08:48:08 RHEL6 named[2152]: reloading zones succeeded
Apr 20 08:48:48 RHEL6 named[2152]: received control channel command 'notify yuliang.com'Apr 20 08:48:48 RHEL6 named[2152]: zone yuliang.com/IN: sending notifies (serial 2016041702)
*清除缓存
[root@RHEL6 ~]# rndc -c /etc/rndc.conf flush
*停止DNS服务
[root@RHEL6 ~]# rndc -c /etc/rndc.conf stop
[root@RHEL6 ~]# netstat -tuln | grep ":53"
udp        0      0 0.0.0.0:53637               0.0.0.0:*                 
[root@RHEL6 ~]# service named start
Starting named:                                            [  OK  ]
[root@RHEL6 ~]# service named start
Starting named: named: already running                     [  OK  ]
*可以直接停止
[root@RHEL6 ~]# rndc stop
[root@RHEL6 ~]# service named start
Starting named:                                            [  OK  ]
*远程192.168.3.99，但是要改一下本机配制文件，监听的port
[root@RHEL6 ~]# vim /etc/named.conf 
key "rndc-key" {
        algorithm hmac-md5;
        secret "vnyY27JCyNSuOvMGLpQHqw==";
};

controls {
        inet 192.168.3.66 port 953
                allow { 192.168.3.99; } keys { "rndc-key"; };
};
[root@RHEL6 ~]# service named restart
Stopping named:                                            [  OK  ]
Starting named:                                            [  OK  ]
[root@RHEL6 ~]# netstat -tnlu | grep ":53"
tcp        0      0 192.168.3.66:53             0.0.0.0:*                   LISTEN      
tcp        0      0 127.0.0.1:53                0.0.0.0:*                   LISTEN      
udp        0      0 0.0.0.0:53637               0.0.0.0:*                               
udp        0      0 192.168.3.66:53             0.0.0.0:*                               
udp        0      0 127.0.0.1:53                0.0.0.0:*                               
*远程主机上没有rndc的key文件，复制一份过去到其家目录也可以
[root@RHEL6 ~]# scp /etc/rndc.conf 192.168.3.99:/root
default-server 127.0.0.1;
改成
default-server 192.168.3.66;
[root@localhost ~]# rndc -c rndc.conf status
rndc: connection to remote host closed
This may indicate that
* the remote server is using an older version of the command protocol,
* this host is not authorized to connect,
* the clocks are not synchronized, or
* the key is invalid.
[root@localhost ~]# date 04201318
[root@RHEL6 ~]# date 04201318
[root@localhost ~]# rndc -c rndc.conf status
version: 9.7.0-P2-RedHat-9.7.0-5.P2.el6
CPUs found: 2
worker threads: 2
number of zones: 16
debug level: 0
xfers running: 0
xfers deferred: 0
soa queries in progress: 0
query logging is OFF
recursive clients: 0/0/1000
tcp clients: 0/100
server is up and running
*rndc 远程控制不安全，一般就在本地服务器上用


***子域授权
[root@RHEL6 ~]# vim /var/named/yu.com 
*强调一下：1、改序列号让辅DNS同步；2、本域内同样要声明本域管理者NS是谁；3、子域地址一般与授权父域地址是不一样的（这里为实验一样）；
4、父域授权多个子域时，子域独立，可以在不同的网段内
$TTL 600
yuliang.com.    IN      SOA     ns1.yuliang.com.        admin.yuliang.com (
                                2016041703
                                1D
                                5M
                                1W
                                1D )
yuliang.com.    IN      NS      ns1.yuliang.com.
yuliang.com.    IN      NS      ns2.yuliang.com.
ns2             IN      A       192.168.3.99
yuliang.com.    IN      MX 10   mail.yuliang.com.
ns1             IN      A       192.168.3.66
mail            IN      A       192.168.3.67
www             IN      A       192.168.3.68
ftp             IN      CNAME   www
hello           IN      A       192.168.3.88


fin             IN      NS      ns1.fin
ns1.fin         IN      A       192.168.3.101

market          IN      NS      ns1.market
ns1.market      IN      A       192.168.3.202
[root@RHEL6 ~]# service named restart
Stopping named:                                            [  OK  ]
Starting named:                                            [  OK  ]
[root@RHEL6 ~]# tail /var/log/messages
Apr 20 14:06:59 RHEL6 named[3249]: the working directory is not writable
Apr 20 14:06:59 RHEL6 named[3249]: zone 0.0.127.in-addr.arpa/IN: loaded serial 0
Apr 20 14:06:59 RHEL6 named[3249]: zone 3.168.192.in-addr.arpa/IN: loaded serial 2016041702
Apr 20 14:06:59 RHEL6 named[3249]: zone yuliang.com/IN: loaded serial 2016041703
Apr 20 14:06:59 RHEL6 named[3249]: zone localhost/IN: loaded serial 0
Apr 20 14:06:59 RHEL6 named[3249]: zone yuliang.com/IN: sending notifies (serial 2016041703)
Apr 20 14:06:59 RHEL6 named[3249]: zone 3.168.192.in-addr.arpa/IN: sending notifies (serial 2016041702)
Apr 20 14:06:59 RHEL6 named[3249]: running
Apr 20 14:06:59 RHEL6 named[3249]: client 192.168.3.99#37450: transfer of 'yuliang.com/IN': AXFR-style IXFR started
Apr 20 14:06:59 RHEL6 named[3249]: client 192.168.3.99#37450: transfer of 'yuliang.com/IN': AXFR-style IXFR ended
[root@localhost ~]# cat /var/named/slaves/yu.com 
$ORIGIN .
$TTL 600	; 10 minutes
yuliang.com		IN SOA	ns1.yuliang.com. admin.yuliang.com.yuliang.com. (
				2016041703 ; serial
				86400      ; refresh (1 day)
				300        ; retry (5 minutes)
				604800     ; expire (1 week)
				86400      ; minimum (1 day)
				)
			NS	ns1.yuliang.com.
			NS	ns2.yuliang.com.
			MX	10 mail.yuliang.com.
$ORIGIN yuliang.com.
fin			NS	ns1.fin
$ORIGIN fin.yuliang.com.
ns1			A	192.168.3.101
$ORIGIN yuliang.com.
ftp			CNAME	www
hello			A	192.168.3.88
mail			A	192.168.3.67
market			NS	ns1.market
$ORIGIN market.yuliang.com.
ns1			A	192.168.3.202
$ORIGIN yuliang.com.
ns1			A	192.168.3.66
ns2			A	192.168.3.99
www			A	192.168.3.68

*新建一台主机192.168.3.101配置子域服务器
[root@localhost ~]# vim /etc/named.conf
options {
        directory "/var/named";
};

zone "." IN {
        type hint;
        file "named.ca";
};

zone "localhost" IN {
        type master;
        file "named.localhost";
        allow-transfer { none; };
};

zone "0.0.127.in-addr.arpa" IN {
        type master;
        file "named.loopback";
        allow-transfer { none; };
};

zone "fin.yuliang.com" IN {
        type master;
        file "fin.yu.com";
};
[root@localhost named]# scp 192.168.3.66:/var/named/yu.com /var/named/fin.yu.com
root@192.168.3.66's password: 
yu.com                                          100%  466     0.5KB/s   00:00    
[root@localhost named]# vim fin.yu.com 
$TTL 600
fin.yuliang.com.        IN      SOA     ns1.fin.yuliang.com.    admin.fin.yuliang.com (
                                2016041703
                                1D
                                5M
                                1W
                                1D )
fin.yuliang.com.        IN      NS      ns1.fin.yuliang.com.
ns1             IN      A       192.168.3.101
mail            IN      A       192.168.3.67
www             IN      A       192.168.3.68
ftp             IN      CNAME   www
hello           IN      A       192.168.3.88
[root@localhost named]# service named restart
Stopping named:                                            [  OK  ]
Starting named:                                            [FAILED]
[root@localhost named]# tail /var/log/messages 
Apr 20 11:19:32 localhost named[2206]: exiting (due to fatal error)
Apr 20 11:21:50 localhost named[2287]: starting BIND 9.7.0-P2-RedHat-9.7.0-5.P2.el6 -u named
Apr 20 11:21:50 localhost named[2287]: built with '--build=i386-redhat-linux-gnu' '--host=i386-redhat-linux-gnu' '--target=i686-redh
at-linux-gnu' '--program-prefix=' '--prefix=/usr' '--exec-prefix=/usr' '--bindir=/usr/bin' '--sbindir=/usr/sbin' '--sysconfdir=/etc' '--datadir=/usr/share' '--includedir=/usr/include' '--libdir=/usr/lib' '--libexecdir=/usr/libexec' '--sharedstatedir=/var/lib' '--mandir=/usr/share/man' '--infodir=/usr/share/info' '--with-libtool' '--localstatedir=/var' '--enable-threads' '--enable-ipv6' '--with-pic' '--disable-static' '--disable-openssl-version-check' '--with-dlz-ldap=yes' '--with-dlz-postgres=yes' '--with-dlz-mysql=yes' '--with-dlz-filesystem=yes' '--with-gssapi=yes' '--disable-isc-spnego' 'build_alias=i386-redhat-linux-gnu' 'host_alias=i386-redhat-linux-gnu' 'target_alias=i686-redhat-linux-gnu' 'CFLAGS= -O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -m32 -march=i686 -mtune=atom -fasynchronous-unwind-tables' 'CPPFLAGS= -DDIG_SIGCHASE'Apr 20 11:21:50 localhost named[2287]: adjusted limit on open files from 1024 to 1048576
Apr 20 11:21:50 localhost named[2287]: found 1 CPU, using 1 worker thread
Apr 20 11:21:50 localhost named[2287]: using up to 4096 sockets
Apr 20 11:21:50 localhost named[2287]: loading configuration from '/etc/named.conf'
Apr 20 11:21:50 localhost named[2287]: none:0: open: /etc/named.conf: permission denied
Apr 20 11:21:50 localhost named[2287]: loading configuration: permission denied
Apr 20 11:21:50 localhost named[2287]: exiting (due to fatal error)
[root@localhost named]# chgrp named fin.yu.com 
[root@localhost named]# chgrp named /etc/named.conf
[root@localhost named]# service named restart
Stopping named:                                            [  OK  ]
Starting named:                                            [  OK  ]
[root@localhost named]# dig -t A www.fin.yuliang.com @192.168.3.101

; <<>> DiG 9.7.0-P2-RedHat-9.7.0-5.P2.el6 <<>> -t A www.fin.yuliang.com @192.
168.3.101;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 11997
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 1, ADDITIONAL: 1

;; QUESTION SECTION:
;www.fin.yuliang.com.		IN	A

;; ANSWER SECTION:
www.fin.yuliang.com.	600	IN	A	192.168.3.68

;; AUTHORITY SECTION:
fin.yuliang.com.	600	IN	NS	ns1.fin.yuliang.com.

;; ADDITIONAL SECTION:
ns1.fin.yuliang.com.	600	IN	A	192.168.3.101

;; Query time: 0 msec
;; SERVER: 192.168.3.101#53(192.168.3.101)
;; WHEN: Wed Apr 20 11:28:56 2016
;; MSG SIZE  rcvd: 87
[root@localhost named]# dig -t NS fin.yuliang.com @192.168.3.101

; <<>> DiG 9.7.0-P2-RedHat-9.7.0-5.P2.el6 <<>> -t NS fin.yuliang.com @192.168
.3.101;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 14809
;; flags: qr aa rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; QUESTION SECTION:
;fin.yuliang.com.		IN	NS

;; ANSWER SECTION:
fin.yuliang.com.	600	IN	NS	ns1.fin.yuliang.com.

;; ADDITIONAL SECTION:
ns1.fin.yuliang.com.	600	IN	A	192.168.3.101

;; Query time: 1 msec
;; SERVER: 192.168.3.101#53(192.168.3.101)
;; WHEN: Wed Apr 20 11:29:49 2016
;; MSG SIZE  rcvd: 67
*这是在子域服务器上做的测试，没问题，再到父域上做一次测试
*注意，授权是在父服务器上的区域中授的权
[root@RHEL6 ~]# dig -t NS fin.yuliang.com @192.168.3.66

; <<>> DiG 9.7.0-P2-RedHat-9.7.0-5.P2.el6 <<>> -t NS fin.yuliang.com @192.168
.3.66;; global options: +cmd
;; Got answer:
;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 6424
;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1

;; QUESTION SECTION:
;fin.yuliang.com.		IN	NS

;; ANSWER SECTION:
fin.yuliang.com.	577	IN	NS	ns1.fin.yuliang.com.

;; ADDITIONAL SECTION:
ns1.fin.yuliang.com.	577	IN	A	192.168.3.101

;; Query time: 0 msec
;; SERVER: 192.168.3.66#53(192.168.3.66)
;; WHEN: Wed Apr 20 11:45:30 2016
;; MSG SIZE  rcvd: 67


***一般情况下子域是不知道父域所在地的，如果明确指出要父域帮忙转发，配置如下：
[root@localhost named]# vim /etc/named.conf
*这是在全局配置里面要求除解析本地定义过的域之外，全部都让此处定义的父域去查，但是父域要帮忙递归才行
*父域中也不见得定义过像baidu.com这样的域，所以它还是会去找根. ，故此并没有什么太大意义
options {
        directory "/var/named";
        forward first;
        forwarders { 192.168.3.66; };
};
*当然如果我们就是找父域或父域定义的域那最好如下创建：
*这是专门的转发域，也就是请求yuliang.com的时候，不用找区域文件，直接去找父域
zone "yuliang.com" IN {
        type forward;
        forward first;
        forwarders { 192.168.3.66; };
};
[root@localhost named]# named-checkconf 
[root@localhost named]# service named restart
Stopping named:                                            [  OK  ]
Starting named:                                            [  OK  ]
[root@localhost named]# 

***acl的用法，跟涵数相似，在/etc/named.conf 里面定义
[root@RHEL6 ~]# vim /etc/named.conf 
acl innet {
        192.168.3.0/24;
        127.0.0.0/8;
};
options {
        directory "/var/named";
        allow-recursion { innet; };
        notify yes ;
};
[root@RHEL6 ~]# service named restart
Stopping named:                                            [  OK  ]
Starting named:                                            [  OK  ]


***当使用智能DNS解析（也就是根据IP智能选择最佳服务器）时，要用CDN机制，比较复杂，其中就有一个关键且基础的应
   用，也就是view视图，需要注意的是一但应用了视图，区域都得定义在视图区域内
[root@RHEL6 ~]# vim /etc/named.conf 
acl innet {
        192.168.3.0/24;
        127.0.0.0/8;
};
options {
        directory "/var/named";
        allow-recursion { innet; };
        notify yes ;
};

view telecom {
        match-clients { innet; };
        zone "yuliang.com" IN {
                type master;
                file "telecom.yuliang.com.zone";
        };
};

view unicom {
        match-clients { any; };
        zone "yuliang.com" IN {
                type master;
                file "unicom.yuliang.com.zone";
        };
};
[root@RHEL6 named]# vim telecom.yuliang.com.zone
$TTL 43200
@       IN      SOA     ns1.yuliang.com.        admin.yuliang.com. (
                        2016042101
                        1H
                        10M
                        7D
                        1D )
        IN      NS      ns1
        IN      MX 10   mail
ns1     IN      A       192.168.3.66
mail    IN      A       192.168.3.67
www     IN      A       192.168.3.68
[root@RHEL6 named]# chgrp named telecom.yuliang.com.zone 
[root@RHEL6 named]# chmod 640 telecom.yuliang.com.zone 
[root@RHEL6 named]# cp -p telecom.yuliang.com.zone unicom.yuliang.com.zone
[root@RHEL6 named]# vim unicom.yuliang.com.zone 
$TTL 43200
@       IN      SOA     ns1.yuliang.com.        admin.yuliang.com. (
                        2016042101
                        1H
                        10M
                        7D
                        1D )
        IN      NS      ns1
        IN      MX 10   mail
ns1     IN      A       192.168.3.66
mail    IN      A       172.16.0.11
www     IN      A       172.16.0.22
[root@RHEL6 named]# service named restart
Stopping named:                                            [  OK  ]
Starting named:                                            [  OK  ]
[root@RHEL6 named]# 


***记录日志的功能，但在互联网上面不便打开日志功能，因为DNS请求数量很多，日志过多影响速度
   但是可以开放一部分日志功能，为安全和效率设计
[root@RHEL6 named]# vim /etc/named.conf 
logging {
        channel query_log {
                file "/var/log/bind_query.log" versions 3 size 10M; 
                severiy dynamic;
                print-category yes;	#log the category of messages
                print-time yes;		#log the date and timeof messages
                print-severity  yes;	#log the severity level of messages
        };

        category queries { query_log; };
};
[root@RHEL6 log]# mkdir /var/log/named
[root@RHEL6 log]# chown named:named /var/log/named/
[root@RHEL6 log]# chmod 770 /var/log/named/
[root@RHEL6 log]# service named restart
Stopping named:                                            [  OK  ]
Starting named:                                            [  OK  ]
[root@RHEL6 log]# 
[root@RHEL6 log]# cd /var/log/named/
[root@RHEL6 named]# ls
bind_query.log
[root@RHEL6 named]# cat bind_query.log 
21-Apr-2016 09:30:22.410 queries: info: client 192.168.3.99#54741: view telecom: query: www.yuliang.com IN A + (192.168.3.66)
[root@RHEL6 named]# vim /etc/named.conf 
logging {
        channel query_log {
                file "/var/log/named/bind_query.log" versions 3 size 10M;
                severity dynamic;
                print-category yes;
                print-time yes;
                print-severity  yes;
        };
        channel xfer_log {
                file "/var/log/named/transfer.log" versions 3 size 10k;
                severity debug 3;
                print-time yes;
        };
        
        category queries { query_log; };
        category xfer-out { xfer_log; };
};
[root@RHEL6 named]# named-checkconf 
[root@RHEL6 named]# service named restart
Stopping named:                                            [  OK  ]
Starting named:                                            [  OK  ]
[root@RHEL6 named]# tail /var/log/named/transfer.log 
[root@RHEL6 named]# 
[root@localhost ~]# dig -t axfr yuliang.com @192.168.3.66

; <<>> DiG 9.7.0-P2-RedHat-9.7.0-5.P2.el6 <<>> -t axfr yuliang.com @192.168.3.66
;; global options: +cmd
yuliang.com.		43200	IN	SOA	ns1.yuliang.com. admin.yuliang.com
. 2016042101 3600 600 604800 86400yuliang.com.		43200	IN	NS	ns1.yuliang.com.
yuliang.com.		43200	IN	MX	10 mail.yuliang.com.
mail.yuliang.com.	43200	IN	A	192.168.3.67
ns1.yuliang.com.	43200	IN	A	192.168.3.66
www.yuliang.com.	43200	IN	A	192.168.3.68
yuliang.com.		43200	IN	SOA	ns1.yuliang.com. admin.yuliang.com
. 2016042101 3600 600 604800 86400;; Query time: 3 msec
;; SERVER: 192.168.3.66#53(192.168.3.66)
;; WHEN: Thu Apr 21 09:47:07 2016
;; XFR size: 7 records (messages 1, bytes 198)
[root@RHEL6 named]# tail /var/log/named/transfer.log 
21-Apr-2016 09:39:39.502 client 192.168.3.99#47471: view telecom: transfer of 'yuliang.com/IN': AXFR started
21-Apr-2016 09:39:39.511 client 192.168.3.99#47471: view telecom: transfer of 'yuliang.com/IN': AXFR ended
[root@RHEL6 named]# 


***下面用到一个工具queryperf，可以测试DNS的解析速度，即压力测试
*在bind-9.7.4软件包里有一个contrib/目录里面有queryperf，在编绎bind的时候没有将queryperf编进去，这里手动编绎
[root@RHEL6 ~]# vim test
www.yuliang.com A
yuliang.com NS
yuliang.com MX
*在test建的记录很少，所以测试速度不见得真实
[root@RHEL6 ~]# queryperf -d test -s 192.168.3.66

DNS Query Performance Testing Tool
Version: $Id: queryperf.c,v 1.12 2007-09-05 07:36:04 marka Exp $

[Status] Processing input data
[Status] Sending queries (beginning with 192.168.3.66)
[Status] Testing complete

Statistics:

  Parse input file:     once
  Ended due to:         reaching end of file

  Queries sent:         3 queries
  Queries completed:    3 queries
  Queries lost:         0 queries
  Queries delayed(?):   0 queries

  RTT max:         	0.000358 sec
  RTT min:              0.000032 sec
  RTT average:          0.000192 sec
  RTT std deviation:    0.000125 sec
  RTT out of range:     0 queries

  Percentage completed: 100.00%
  Percentage lost:        0.00%

  Started at:           Tue Mar 29 12:00:09 2016
  Finished at:          Tue Mar 29 12:00:09 2016
  Ran for:              0.000461 seconds

  Queries per second:   6507.592191 qps
  *下面在test文件里建20万条记录测试
[root@RHEL6 ~]# queryperf -d test -s 192.168.3.66

DNS Query Performance Testing Tool
Version: $Id: queryperf.c,v 1.12 2007-09-05 07:36:04 marka Exp $

[Status] Processing input data
[Status] Sending queries (beginning with 192.168.3.66)
[Status] Testing complete

Statistics:

  Parse input file:     once
  Ended due to:         reaching end of file

  Queries sent:         881790 queries
  Queries completed:    881790 queries
  Queries lost:         0 queries
  Queries delayed(?):   0 queries

  RTT max:         	0.078719 sec
  RTT min:              0.000043 sec
  RTT average:          0.001142 sec
  RTT std deviation:    0.000608 sec
  RTT out of range:     0 queries

  Percentage completed: 100.00%
  Percentage lost:        0.00%

  Started at:           Tue Mar 29 12:22:40 2016
  Finished at:          Tue Mar 29 12:23:33 2016
  Ran for:              52.267444 seconds

  Queries per second:   16870.731234 qps
*此时有80万条记录，在测试时不仅自身要处理大量数据，同时有大量数据进行I/O存储，所以非常慢


DHCP: Dynamic Host Configuration Protocol <-- bootp

DHCP的四个报文都是广播格式
Client--> DHCPDISCOVER 
		DHCPOFFER <-- Server
Client--> DCHPREQUEST 
		  DCHPACK <-- Server
		  
Client--> DHCPREQUEST
		  DHCPACK <-- Server
DHCP_RELAY：DHCP中继，可由路由器桥接，单播给指定服务器和用户		  
UDP:
	67/udp
	68/udp
***DHCP服务器，安装后，其配置文件/etc/dhcpd.conf里没有内容，模板在/usr/share/doc/dhcpd*/dhcpd.conf.example
[root@RHEL5 ~]# cp /usr/share/doc/dhcp-3.0.5/dhcpd.conf.sample /etc/dhcpd.conf
cp: overwrite `/etc/dhcpd.conf'? y
[root@RHEL5 ~]# vim /etc/dhcpd.conf 
# 1. 整體的環境設定
ddns-update-style            none;			<==不要更新 DDNS 的設定
ignore client-updates;					<==忽略用戶端的 DNS 更新功能

subnet 192.168.100.0 netmask 255.255.255.0 {
	default-lease-time           259200;		<==預設租約為 3 天
	max-lease-time               518400;		<==最大租約為 6 天
	option routers               192.168.3.1;	<==這就是預設路由
	option domain-name           "yuliang.com";	<==給予一個領域名稱
	option domain-name-servers   192.168.3.66;
# 上面是 DNS 的 IP 設定，這個設定值會修改用戶端的 /etc/resolv.conf 檔案內容

# 2. 關於動態分配的 IP

    range 192.168.100.101 192.168.100.200;  <==分配的 IP 範圍

# 3. 關於固定的 IP 啊！
    host IP66 {
        hardware ethernet    00:0C:29:0E:7D:A1; <==用戶端網卡 MAC
        fixed-address        192.168.3.254;     <==給予固定的 IP，此IP一定要在地址池外，不冲突
    }
}
[root@RHEL5 ~]# service dhcpd start
Starting dhcpd:                                            [  OK  ]
*当给了指定的主机固定IP地址时，每次就会将此IP地址发给指定主机，而且多个dhcp服务器都存在时，固定地址优先
[root@RHEL6 dhcp]# service network restart
Shutting down interface eth0:                              [  OK  ]
Shutting down loopback interface:                          [  OK  ]
Bringing up loopback interface:                            [  OK  ]
Bringing up interface eth0:                                [  OK  ]
[root@RHEL6 ~]# ifconfig
eth0      Link encap:Ethernet  HWaddr 00:0C:29:0E:7D:A1  
          inet addr:192.168.3.254  Bcast:192.168.3.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fe0e:7da1/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:29806 errors:0 dropped:0 overruns:0 frame:0
          TX packets:22379 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:18841244 (17.9 MiB)  TX bytes:13258313 (12.6 MiB)
          Interrupt:18 Base address:0x2000 
*如果谁动态从这个dhcp服务器上得到过ip地址就会有地址租期
[root@RHEL5 ~]# cat /var/lib/dhcpd/dhcpd.leases
# All times in this file are in UTC (GMT), not your local timezone.   This is
# not a bug, so please don't ask about it.   There is no portable way to
# store leases in the local timezone, so please don't request this as a
# feature.   If this is inconvenient or confusing to you, we sincerely
# apologize.   Seriously, though - don't ask.
# The format of this file is documented in the dhcpd.leases(5) manual page.
# This lease file was written by isc-dhcp-V3.0.5-RedHat











