动态网页：服务器端存储的文档非HTML格式，而是编程语言开发的脚本，脚本接受参数之后在服务器运行一次，运行完成之后会生成HTML格式的文档，把生成的文档发给客户端；

web: index.php

web --> procotol --> php (运行index.php)

请求报文语法：
<method> <request-URL> <version>
<headers>

<entity-body> 
	
响应报文语法：
<version> <status> <reason-phrase>
<headers>

<entity-body>

状态码:
1xx: 纯信息
2xx: “成功”类的信息 (200, 201, 202)
3xx：重定向类的信息 (301, 302, 304)
4xx: 客户端错误类的信息 (404)
5xx：服务器端错误类的信息

HEADER:
	通用首部
	请求首部
		IF-Modified-Since If-None_Match
	响应首部
	实体首部
	扩展首部


请求报文：
GET / HTTP/1.1
Host: www.magedu.com
Connection: keep-alive

响应报文：
HTTP/1.1 200 OK
X-Powered-By: PHP/5.2.17
Vary: Accept-Encoding,Cookie,User-Agent
Cache-Control: max-age=3, must-revalidate
Content-Encoding: gzip
Content-Length: 6931
上面两个报文的第一行通常称作报文“起始行(start line)”；后面的标签格式的内容称作首部域(Header field)，每个首部域都由名称(name)和值(value)组成，
中间用逗号分隔。另外，响应报文通常还有一个称作Body的信息主体，即响应给客户端的内容。

I/O类型：
	从被调用者角度来理解
	同步和异步：synchronous,asynchronous
		同步：调用(系统调用或库调用或函数调用等)发出之后不会立即返回，但一旦返回，则返回即是最终结果
		异步：调用(系统调用或库调用或函数调用等)发出之后，被调用方立即返回消息，但返回的并非最终结果，被调用者通过状态、通知机制等来通知调用者、或通过回调函数来处理
	从调用者角度来理解
	阻塞和非阻塞：block, nonblock
		关注的是调用者等待被调用者返回调用结果时的状态（中间态）

		阻塞：调用结果返回之前，调用者会被挂起(似不可中断睡眠状态)，调用者只有在得到返回结果之后才能继续工作
		非阻塞：调用者在结果返回之前，不会被挂起，即调用不会阻塞调用者
I/O模型：
	blocking IO：阻塞IO
	nonblocking IO：非阻塞IO
	IO multiplexing：复用IO--------->prefork、worker
		select(), poll()
			内核中的IO助理，只能承载1024个并发
			调用者阻塞在select上面，但还可以生成多个请求
			性能并没有多大提升
	signal driven IO：事情驱动IO---------->event
		通知机制：
			水平触发：多次通知至到收取
			边缘触发：只通知一次，
	asynchronous IO：异步IO

	前四个在数据从内核复制到用户空间依然是阻塞的，最后一个从磁盘到内核，从内核到用户空间都是非阻塞，性能最强大
	nginx性能强大就是因为开发时就用到signal driven的机制编程，而且支持asynchronous
	apache由于年代久远，IO模型多是IO multiplexing，event有改进，功能非常完善
	所以nginx一般做反向代理，而apache做后端集群
		



Web服务器的主要操作
1、	建立连接——接受或拒绝客户端连接请求；
2、	接收请求——通过网络读取HTTP请求报文；
3、	处理请求——解析请求报文并做出相应的动作；
4、	访问资源——访问请求报文中相关的资源；
5、	构建响应——使用正确的首部生成HTTP响应报文；
6、	发送响应——向客户端发送生成的响应报文；
7、	记录日志——当已经完成的HTTP事务记录进日志文件；

Web服务器处理并发连接请求的架构方式

1、单线程web服务器(Single-threaded web servers)

此种架构方式中，web服务器一次处理一个请求，结束后读取并处理下一个请求。在某请求处理过程中，其它所有的请求将被忽略，因此，在并发请求较多的场景中将会出现严重的必能问题。

2、多进程/多线程web服务器

此种架构方式中，web服务器生成多个进程或线程并行处理多个用户请求，进程或线程可以按需或事先生成。有的web服务器应用程序为每个用户请求生成一个单独的进程或线程来进行响应，不过，一旦并发请求数量达到成千上万时，多个同时运行的进程或线程将会消耗大量的系统资源。

3、I/O多路复用web服务器

为了能够支持更多的并发用户请求，越来越多的web服务器正在采用多种复用的架构——同步监控所有的连接请求的活动状态，当一个连接的状态发生改变时(如数据准备完毕或发生某错误)，将为其执行一系列特定操作；在操作完成后，此连接将重新变回暂时的稳定态并返回至打开的连接列表中，直到下一次的状态改变。由于其多路复用的特性，进程或线程不会被空闲的连接所占用，因而可以提供高效的工作模式。

4、多路复用多线程web服务器

将多进程和多路复用的功能结合起来形成的web服务器架构，其避免了让一个进程服务于过多的用户请求，并能充分利用多CPU主机所提供的计算能力。

代理

Web代理服务器工作于web客户端和web服务器之间，它负责接收来自于客户端的http请求，并将其转发至对应的服务；而后接收来自于服务端的响应，并将响应报文回送至客户端。

httpd:
	事先创建进程
	按需维持适当的进程
	模块块设计，核心比较小，各种功能都模块添加（包括php）
		支持运行配置，支持单独编译模块
	支持多种方式的虚拟主机配置
		Socket  IP:Port
		虚拟主机：
			基于IP的虚拟主机；
			基于端口的虚拟主机；
			基于域名的虚拟主机；
		
protocol://HOST:PORT/path/to/source
		
			Method URL version
			header
			
			body


			GET /download/linux.tar.bz2 HTTP/1.0
			Host: www.magedu.com
	支持https协议 (mod_ssl)
	支持用户认证
	支持基于IP或主机名的ACL
	支持每目录的访问控制
	支持URL重写，/image/a.jpeg, /bbs/images/abc.jpeg
httpd:
	/usr/sbin/httpd(MPM: prefork)
		httpd: root, root (master process)
		httpd: apche, apache (worker process)
	/etc/rc.d/init.d/httpd
	Port: (80/tcp), (ssl: 443/tcp)
	/etc/httpd: 工作根目录，相当于程序安装目录
	/etc/httpd/conf: 配置文件目录
		主配置文件：httpd.conf
		/etc/httpd/conf.d/*.conf
	/etc/httpd/modules: 模块目录
	/etc/httpd/logs --> /var/log/httpd: 日志目录
		日志文件有两类：访问日志access_log，错误日志：err_log
	/var/www/
		html
		cgi-bin
		
		cgi: Common Gateway Interface
			Client --> httpd (index.cgi) --> Spawn Process (index.cgi) --> httpd --> Client
			perl, python, java, (Servlet, JSP), php
			
		fastcgi: 
		
		程序：指令和数据
			数据，数据库服务
			
httpd:
	directive value
	指令不区分字符大小写
	value则根据需要有可能要区分

MPM: Multi Path Modules
	mpm_winnt
	prefork (一个请求用一个进程响应)
	worker  (一个请求用一个线程响应, (启动多个进程，每个进程生成多个线程))
	event   (一个进程处理多个请求)
URL路径跟本地文件系统路径不是一码事儿， URL是相对于DocumentRoot的路径而言的。

Options
	None: 不支持任何选项
	Indexes: 允许索引目录（生产应用中关闭）
	FollowSynLinks: 允许访问符号链接指向的原文件(生产应用中关闭)
	Includes: 允许执行服务端包含（SSI）
	ExecCGI: 允许运行CGI脚本
	All: 支持所有选项
	multiview：跟客户端协量传递给客户更合适的网面，比如中国人传递中文
***生产中这个就为none
	
Order：用于定义基于主机的访问功能的，IP，网络地址或主机定义访问控制机制
	Order allow,deny
	allow from
	deny from
***默人的就是deny
192.168.0.0/24

地址的表示方式：
	IP
	network/netmask
	HOSTNAME: www.a.com
	DOMAINNAME: magedu.com
	Partial IP: 172.16, 172.16.0.0/16

Order deny,allow
Deny from 192.168.0.0/24

	192.168.0.1, 172.16.100.177

elinks http://172.16.100.1
	-dump
	-source

认证：htpasswd -c -m /usr/local/apache/passwd/passwords marion(注意创建第二个账户时把-c去掉，不然复盖全文件)
<Directory>
	AllowOverride 

	AuthType Basic
	AuthName "Restricted Files"
	AuthUserFile /usr/local/apache/passwd/passwords
	Require user marion
注意用组定义的语法：
GroupName: rbowen dpitts sungo rshersey

	AuthType Basic
	AuthName "By Invitation Only"
	# Optional line:
	AuthBasicProvider file
	AuthUserFile /usr/local/apache/passwd/passwords
	AuthGroupFile /usr/local/apache/passwd/groups
	Require group GroupName


	<Directory /www/docs/private>
	AuthName "Private"
	AuthType Basic
	AuthBasicProvider dbm
	AuthDBMUserFile /www/passwords/passwd.dbm
	Require valid-user
	</Directory>


如果要在某个用户的家目录提供访问页面，格式如下：
tom
http://172.16.100.1/~tom/


PV: Page View，每天的页面访问量
UV: User View, 每天的独立IP访问量,(日UV、月UV)


/web/html

/www/forum bbs

http://172.16.100.1/bbs/images/logo.jpeg

定义网站文档目录
访问选项:options
基于主机的访问控制
基于用户或组的访问控制
用户个人站点
错误日志
日志格式
访问日志 PV UV
路径别名
CGI
虚拟主机


Apache的指令：
Listen [IP:]PORT
MPM: MultiPath Modules
	prefork: 一个请求用一个进程处理，稳定性好、大并发场景下消耗资源较多；
	worker：每个请求用一个线程处理(启动一定数量的进程，每个进程生成一定数量的线程)
	event：每个进程处理多个请求，基于事件来实现 （apache 2.2测试）
	mpm_winnt
	
ErrorLog
LogLevel

LogFormat
	combined
	common
CustomLog

路径别名：
Alias /URL "local_path"

User
Group


CGI: Common Gateway Interface, 通用网关接口，协议

网页内容：动态内容，静态内容
静态内容：
	.jpeg
	.gif
	.png
	.html
	.css
动态内容：
	编程语言写好程序-->执行一次，生成处理结果，经过html格式化后的文本
	
echo "<h1>Hellow world</h1>"

练习：
建立httpd服务器(基于编译的方式进行)，要求：
	1)提供两个基于名称的虚拟主机:
		(a)www1.magedu.com，页面文件目录为/web/vhosts/www1；错误日志为/var/log/httpd/www1.err，访问日志为/var/log/httpd/www1.access；
		(b)www2.magedu.com，页面文件目录为/web/vhosts/www2；错误日志为/var/log/httpd/www2.err，访问日志为/var/log/httpd/www2.access；
		(c)为两个虚拟主机建立各自的主页文件index.html，内容分别为其对应的主机名；
		(d)通过www1.magedu.com/status输出httpd工作状态相关信息，且只允许提供帐号密码才能访问(status:status)；
	2)www1主机仅允许172.16.0.0/16网络中的客户机访问；www2主机可以被所有主机访问；


为上题中的第2个虚拟主机提供https服务，使得用户可以通过https安全的访问此web站点；
	(1)要求使用证书认证，证书中要求使用的国家(CN)、州(Henan)、城市(Zhengzhou)和组织(MageEdu)；
	(2)设置部门为TECH，主机名为www2.magedu.com，邮件为admin@magedu.com；
	(3)此服务禁止来自于192.168.1.0/24网络中的主机访问；


PHP is Hypertext Preprocessor
超文本预处理器

关于PHP

一、PHP简介
	
PHP是通用服务器端脚本编程语言，其主要用于web开发以实现动态web页面，它也是最早实现将脚本嵌入HTML源码文档中的服务器端脚本语言之一。同时，php还提供了一个命令行接口，因此，其也可以在大多数系统上作为一个独立的shell来使用。

Rasmus Lerdorf于1994年开始开发PHP，它是初是一组被Rasmus Lerdorf称作“Personal Home Page Tool” 的Perl脚本， 这些脚本可以用于显示作者的简历并记录用户对其网站的访问。后来，Rasmus Lerdorf使用C语言将这些Perl脚本重写为CGI程序，还为其增加了运行Web forms的能力以及与数据库交互的特性，并将其重命名为“Personal Home Page/Forms Interpreter”或“PHP/FI”。此时，PHP/FI已经可以用于开发简单的动态web程序了，这即是PHP 1.0。1995年6月，Rasmus Lerdorf把它的PHP发布于comp.infosystems.www.authoring.cgi Usenet讨论组，从此PHP开始走进人们的视野。1997年，其2.0版本发布。

1997年，两名以色列程序员Zeev Suraski和Andi Gutmans重写的PHP的分析器(parser)成为PHP发展到3.0的基础，而且从此将PHP重命名为PHP: Hypertext Preprocessor。此后，这两名程序员开始重写整个PHP核心，并于1999年发布了Zend Engine 1.0，这也意味着PHP 4.0的诞生。2004年7月，Zend Engine 2.0发布，由此也将PHP带入了PHP5时代。PHP5包含了许多重要的新特性，如增强的面向对象编程的支持、支持PDO(PHP Data Objects)扩展机制以及一系列对PHP性能的改进。

二、PHP Zend Engine

Zend Engine是开源的、PHP脚本语言的解释器，它最早是由以色列理工学院(Technion)的学生Andi Gutmans和Zeev Suraski所开发，Zend也正是此二人名字的合称。后来两人联合创立了Zend Technologies公司。

Zend Engine 1.0于1999年随PHP 4发布，由C语言开发且经过高度优化，并能够做为PHP的后端模块使用。Zend Engine为PHP提供了内存和资源管理的功能以及其它的一些标准服务，其高性能、可靠性和可扩展性在促进PHP成为一种流行的语言方面发挥了重要作用。

Zend Engine的出现将PHP代码的处理过程分成了两个阶段：首先是分析PHP代码并将其转换为称作Zend opcode的二进制格式(类似Java的字节码)，并将其存储于内存中；第二阶段是使用Zend Engine去执行这些转换后的Opcode。

三、PHP的Opcode

Opcode是一种PHP脚本编译后的中间语言，就像Java的ByteCode,或者.NET的MSL。PHP执行PHP脚本代码一般会经过如下4个步骤(确切的来说，应该是PHP的语言引擎Zend)：
1、Scanning(Lexing) —— 将PHP代码转换为语言片段(Tokens)
2、Parsing —— 将Tokens转换成简单而有意义的表达式
3、Compilation —— 将表达式编译成Opocdes
4、Execution —— 顺次执行Opcodes，每次一条，从而实现PHP脚本的功能

四、php的加速器

基于PHP的特殊扩展机制如opcode缓存扩展也可以将opcode缓存于php的共享内存中，从而可以让同一段代码的后续重复执行时跳过编译阶段以提高性能。由此也可以看出，这些加速器并非真正提高了opcode的运行速度，而仅是通过分析opcode后并将它们重新排列以达到快速执行的目的。

常见的php加速器有：

1、APC (Alternative PHP Cache)
遵循PHP License的开源框架，PHP opcode缓存加速器，目前的版本不适用于PHP 5.4。项目地址，http://pecl.php.net/package/APC。

2、eAccelerator
源于Turck MMCache，早期的版本包含了一个PHP encoder和PHP loader，目前encoder已经不在支持。项目地址， http://eaccelerator.net/。

3、XCache
快速而且稳定的PHP opcode缓存，经过严格测试且被大量用于生产环境。项目地址，http://xcache.lighttpd.net/

4、Zend Optimizer和Zend Guard Loader
Zend Optimizer并非一个opcode加速器，它是由Zend Technologies为PHP5.2及以前的版本提供的一个免费、闭源的PHP扩展，其能够运行由Zend Guard生成的加密的PHP代码或模糊代码。 而Zend Guard Loader则是专为PHP5.3提供的类似于Zend Optimizer功能的扩展。项目地址，http://www.zend.com/en/products/guard/runtime-decoders

5、NuSphere PhpExpress
NuSphere的一款开源PHP加速器，它支持装载通过NuSphere PHP Encoder编码的PHP程序文件，并能够实现对常规PHP文件的执行加速。项目地址，http://www.nusphere.com/products/phpexpress.htm

五、PHP源码目录结构

PHP的源码在结构上非常清晰。其代码根目录中主要包含了一些说明文件以及设计方案，并提供了如下子目录：

1、build —— 顾名思义，这里主要放置一些跟源码编译相关的文件，比如开始构建之前的buildconf脚本及一些检查环境的脚本等。
2、ext —— 官方的扩展目录，包括了绝大多数PHP的函数的定义和实现，如array系列，pdo系列，spl系列等函数的实现。 个人开发的扩展在测试时也可以放到这个目录，以方便测试等。
3、main —— 这里存放的就是PHP最为核心的文件了，是实现PHP的基础设施，这里和Zend引擎不一样，Zend引擎主要实现语言最核心的语言运行环境。
4、Zend —— Zend引擎的实现目录，比如脚本的词法语法解析，opcode的执行以及扩展机制的实现等等。
5、pear —— PHP 扩展与应用仓库，包含PEAR的核心文件。
6、sapi —— 包含了各种服务器抽象层的代码，例如apache的mod_php，cgi，fastcgi以及fpm等等接口。
7、TSRM —— PHP的线程安全是构建在TSRM库之上的，PHP实现中常见的*G宏通常是对TSRM的封装，TSRM(Thread Safe Resource Manager)线程安全资源管理器。
8、tests —— PHP的测试脚本集合，包含PHP各项功能的测试文件。
9、win32 —— 这个目录主要包括Windows平台相关的一些实现，比如sokcet的实现在Windows下和*Nix平台就不太一样，同时也包括了Windows下编译PHP相关的脚本。

apache与php连动接口（语法）
<html>
	<head></head>

<?php
 phpinfo();
?>

</html>


MVC技术：module处理数据、view接受和输出数据、controller控制整个业务流程
嵌入式web开发语言
index.php：生存周期也是apache控制

CGI模型：多请求时会出现进程不停生成与销毁，资源消耗
Module模型：dynamic shared object(DSO)，将apache与php组成一个进程，性能有所提升
fastcgi模型：apache server <---> php server相当于apache是客户端、php是服务器，这种性能最好

	
/etc/my.cnf --> /etc/mysql/my.cnf --> $BASEDIR/my.cnf --> ~/.my.cnf	


MySQL服务器维护了两类变量：
	服务器变量：
		定义MySQL服务器运行特性
		SHOW GLOBAL VARIABLES [LIKE 'STRING'];
	状态变量：
		保存了MySQL服务器运行统计数据
		SHOW GLOBAL STATUS [LIKE 'STRING'] 

MySQL通配符：
	_:任意单个字符
	%：任意长度的任意字符

php53-mbstring
	
	
MPM: prefork, worker, event
模块化方式使用MPM

# yum -y install pcre-devel

# tar xf apr-1.4.6.tar.bz2
# cd apr-1.4.6
# ./configure --prefix=/usr/local/apr
# make
# make install

# tar xf apr-util-1.4.1.tar.bz2
# cd apr-util-1.4.1
# ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
# make
# make install


# tar xf httpd-2.4.4.tar.bz2
# cd httpd-2.4.4
# ./configure --prefix=/usr/local/apache --sysconfdir=/etc/httpd --enable-so --enable-rewirte --enable-ssl --enable-cgi --enable-cgid --enable-modules=most --enable-mods-shared=most --enable-mpms-shared=all --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util
# make
# make install


	

php连接mysql并获取数据测试：
<?php
$conn=mysql_connect('localhost','root','123456');

if (!$conn)
  {
  die('Could not connect: ' . mysql_error());
  }

mysql_select_db("mydb", $conn);

$result = mysql_query("SELECT * FROM tb1");

while($row = mysql_fetch_array($result))
  {
  echo $row['Name'] . " " . $row['Age'];
  echo "<br />";
  }

mysql_close();
?>	




<?php
  $conn=mysql_connect('localhost','root','redhat');
  if ($conn)
    echo "Success...";
  else
    echo "Failure...";
?>


Apache的主配置文件：/etc/httpd/conf/httpd.conf
默认站点主目录：/var/www/html/
Apache服务器的配置信息全部存储在主配置文件/etc/httpd/conf/httpd.conf中，这个文件中的内容非常多，用wc命令统计一共有1009行，其中大部分是以#开头的注释行。
[root@justin ~]# wc -l /etc/httpd/conf/httpd.conf 
1009 /etc/httpd/conf/httpd.conf 
[root@justin ~]#

配置文件包括三部分：
[root@justin ~]# grep '\<Section\>' /etc/httpd/conf/httpd.conf -n 
### Section 1: Global Environment 
### Section 2: 'Main' server configuration 
### Section 3: Virtual Hosts 
[root@justin ~]#

***Global Environment---全局环境配置，决定Apache服务器的全局参数
***Main server configuration---主服务配置，相当于是Apache中的默认Web站点，如果我们的服务器中只有一个站点，那么就只需在这里配置就可以了。
***8Virtual Hosts---虚拟主机，虚拟主机不能与Main Server主服务器共存，当启用了虚拟主机之后，Main Server就不能使用了




***Global Environment
ServerTokens OS
*在出现错误页的时候是否显示服务器操作系统的名称，ServerTokens Prod为不显示

ServerRoot "/etc/httpd"
*用于指定Apache的运行目录，服务启动之后自动将目录改变为当前目录，在后面使用到的所有相对路径都是想对这个目录下


PidFile run/httpd.pid
*记录httpd守护进程的pid号码，这是系统识别一个进程的方法，系统中httpd进程可以有多个，但这个PID对应的进程是其他的父进程


Timeout 60
*服务器与客户端断开的时间


KeepAlive Off
*是否持续连接（因为每次连接都得三次握手，如果是访问量不大，建议打开此项，如果网站访问量比较大关闭此项比较好），修改为：KeepAlive On 表示允许程序性联机


MaxKeepAliveRequests 100
*表示一个连接的最大请求数


KeepAliveTimeout 15
*一个请求断开连接前的时间


<IfModule prefork.c> 
	StartServers      8 
	MinSpareServers    5 
	MaxSpareServers  20 
	ServerLimit      256 
	MaxClients      256 
	MaxRequestsPerChild  4000 
</IfModule>
*系统默认的模块，表示为每个访问启动一个进程（即当有多个连接公用一个进程的时候，在同一时刻只能有一个获得服务，其它的排队）。
	StartServer开始服务时启动8个进程用作等待，最小空闲5个进程，最多空闲20个进程。
	MaxClient限制同一时刻客户端的最大连接请求数量，超过的要进入等候队列。
	MaxRequestsPerChild每个进程生存期内允许服务的最大请求数量，数量达到，立即销毁，0表示永不结束


<IfModule worker.c> 
	StartServers        4 
	MaxClients        300 
	MinSpareThreads    25 
	MaxSpareThreads    75 
	ThreadsPerChild    25 
	MaxRequestsPerChild  0 
</IfModule>
*为Apache配置线程访问，即每对WEB服务访问启动一个线程，这样对内存占用率比较小。
	ServerLimit服务器允许配置进程数的上限。
	ThreadLimit每个子进程可能配置的线程上限
	StartServers启动httpd进程数，
	MaxClients某一时间点最多能发起多少个访问，超过的要进入队列等待，其大小有ServerLimit和ThreadsPerChild的乘积决定
	ThreadsPerChild每个子进程生存期间常驻执行线程数，子线程建立之后将不再增加
	MaxRequestsPerChild每个进程启动的最大线程数(跟上面的表述有点区别，是因为这种模型是线程处理请求，进程只负责生成和管理线程)，如达到限制数时进程将结束，如置为0则子线程永不结束


Listen 80
*监听的端口，如有多块网卡，默认监听所有网卡

LoadModule auth_basic_module modules/mod_auth_basic.so 
...... 
LoadModule version_module modules/mod_version.so
*启动时加载的模块

Include conf.d/*.conf
*加载的配置文件

User apache 
Group apache
*启动服务后转换的身份，在启动服务时通常以root身份，然后转换身份，这样增加系统安全

***Main server configuration
ServerAdmin root@localhost
*管理员的邮箱，有什么问题发邮件给管理员

#ServerName www.example.com:80
*默认是不需要指定的，服务器通过名字解析过程来获得自己的名字，但如果解析有问题（如反向解析不正确），或者没有DNS名字，也可以在这里指定IP地址，当这项不正确的时候服务器不能正常启动。前面启动Apache时候提示正在启动 
httpd：httpd: apr_sockaddr_info_get() failed forjustin httpd: Could not reliably determine the server's fully qualified domain name, using 127.0.0.1forServerName，
解决方法就是启动该项把www.example.com:80修改为自己的域名或者直接修改为localhost或者注释掉


UseCanonicalName Off
*如果客户端提供了主机名和端口，Apache将会使用客户端提供的这些信息来构建自引用URL。这些值与用于实现基于域名的虚拟主机的值相同，并且对于同样的客户端可用。
CGI变量SERVER_NAME和SERVER_PORT也会由客户端提供的值来构建


DocumentRoot "/var/www/html"
*网页文件存放的目录

Directory的封装就是对某一个路径下的文件定义什么规则
<Directory /> 
    Options FollowSymLinks 
    AllowOverride None 
</Directory>
*对根目录的一个权限的设置



<Directory "/var/www/html"> 
    Options Indexes FollowSymLinks 
    AllowOverride None 
    Order allow,deny 
    Allow from all 
</Directory>

*对/var/www/html目录的一个权限的设置，options中Indexes表示当网页不存在的时候允许索引显示目录中的文件，FollowSymLinks是否允许访问符号链接文件（本尊）。
有的选项有ExecCGI表是否使用CGI，如Options Includes ExecCGI FollowSymLinks表示允许服务器执行CGI及SSI，禁止列出目录。
SymLinksOwnerMatch表示当符号链接的文件和目标文件为同一用户拥有时才允许访问。AllowOverrideNone表示不允许这个目录下的访问控制文件来改变这里的配置，
这也意味着不用查看这个目录下的访问控制文件，修改为：AllowOverride All 表示允许.htaccess。Order对页面的访问控制顺序后面的一项是默认选项，
如allow，deny则默认是deny，Allow from all表示允许所有的用户，通过和上一项结合可以控制对网站的访问控制
[root@localhost ~]# vim /etc/httpd/conf/httpd.conf
<Directory "/var/www/html">

	Options Indexes FollowSymLinks

	AllowOverride AuthConfig
		AuthType Basic
		AuthName "Restricted Site..."
		AuthUserFile "/etc/httpd/conf/htpasswd"
		Require valid-user

	Order allow,deny
	Allow from all
</Directory>
[root@localhost ~]# man htpasswd
*第一次加-c，以后不加-c以免覆盖，-m是MD5加密
[root@localhost ~]# htpasswd -c -m /etc/httpd/conf/htpasswd hadoop
New password: 
Re-type new password: 
Adding password for user hadoop
[root@localhost ~]# htpasswd -m /etc/httpd/conf/htpasswd tom
New password: 
Re-type new password: 
Adding password for user tom
[root@localhost ~]# cat /etc/httpd/conf/htpasswd 
hadoop:$apr1$tBqmOWXT$ptvFOaDHDandUe0PgkdG9/
tom:$apr1$fIg0pIGD$EQyT0Jyy5iNZyVhpmd3wb0
[root@localhost ~]# 
[root@localhost ~]# httpd -t
httpd: Could not reliably determine the server's fully qualified domain name, 
using localhost.localdomain for ServerNameSyntax OK
[root@localhost ~]# vim /etc/httpd/conf/httpd.conf 
ServerName www.yuliang.com
[root@localhost ~]# httpd -t
Syntax OK
[root@localhost ~]# 
[root@localhost ~]# service httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@localhost ~]# 
*再登陆http://192.168.3.66会要账户和密码
*基于组认证
[root@localhost ~]# vim /etc/httpd/conf/httpd.conf
AuthType Basic
        AuthName "Restricted Site..."
        AuthUserFile "/etc/httpd/conf/htpasswd"
        AuthGroupFile "/etc/httpd/conf/htgroup"
        Require group myusers
[root@localhost ~]# vim /etc/httpd/conf/htgroup
myusers: hadoop tom
[root@localhost ~]# httpd -t 
Syntax OK
[root@localhost ~]# service httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]




<IfModule mod_userdir.c> 
    UserDir disabled 
</IfModule>
*是否允许用户访问其家目录，默认是不允许

#<Directory /home/*/public_html> 
#    AllowOverride FileInfo AuthConfig Limit 
#    Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec 
#    <Limit GET POST OPTIONS> 
#        Order allow,deny 
#        Allow from all 
#    </Limit> 
#    <LimitExcept GET POST OPTIONS> 
#        Order deny,allow 
#        Deny from all 
#    </LimitExcept> 
#</Directory>
*如果允许访问用户的家目录中的网页文件，则取消以上注释，并对其中进行修改
[root@localhost ~]# vim /etc/httpd/conf/httpd.conf 
<IfModule mod_userdir.c>
    #UserDir disabled
    UserDir public_html
</IfModule>
[root@localhost ~]# su - hadoop
[hadoop@localhost ~]$ mkdir public_html
[hadoop@localhost ~]$ cd public_html
[hadoop@localhost public_html]$ vim index.html
<title>Normal user site from its home dir</title>
<h1>This is a special test for normal users</h1>
[hadoop@localhost public_html]$ exit
logout
[root@localhost ~]# 
[root@localhost ~]# chmod o+x /home/hadoop/
[root@localhost ~]# service httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@localhost ~]# elinks http://192.168.3.66/~hadoop
*访问的格式就是在地址后面加一个~hadoop即可
elinks http://172.16.100.1	<==以纯文本方式打开一个交互式网站
	-dump：显示完网页直接退出，不停留在交互模式下
	-source：显示网页源代码




DirectoryIndex index.html index.html.var
*指定所要访问的主页的默认主页名字，默认首页文件名为index.html


AccessFileName .htaccess
*定义每个目录下的访问控制文件名，缺省为.htaccess


<Files ~ "^\.ht"> 
    Order allow,deny 
    Deny from all 
    Satisfy All 
</Files>
*控制不让web上的用户来查看.htpasswd和.htaccess这两个文件



TypesConfig /etc/mime.types

# This file controls what Internet media types are sent to the client for given file extension(s).  Sending the correct media type to the client
  is important so they know how to handle the content of the file. Extra types can either be added here or by using an AddType directive in your config files
# MIME：多功能网络邮件扩充协议，是由RFC组织定义互联网文件传输类型


DefaultType text/plain
*默认的网页的类型


<IfModule mod_mime_magic.c> 
#  MIMEMagicFile /usr/share/magic.mime 
   MIMEMagicFile conf/magic
</IfModule>
*指定判断文件真实MIME类型功能的模块



HostnameLookups Off
*当打开此项功能时，在记录日志的时候同时记录主机名，这需要服务器来反向解析域名，增加了服务器的负载，通常不建议开启



#EnableMMAP off
*是否允许内存映射：如果httpd在传送过程中需要读取一个文件的内容，它是否可以使用内存映射。如果为on表示如果操作系统支持的话，将使用内存映射。
 在一些多核处理器的系统上，这可能会降低性能，如果在挂载了NFS的DocumentRoot上如果开启此项功能，可能造成因为分段而造成httpd崩溃



#EnableSendfile off
*这个指令控制httpd是否可以使用操作系统内核的sendfile支持来将文件发送到客户端。默认情况下，当处理一个请求并不需要访问文件内部的数据时(比如请求一个静态的文件内容)，
 如果操作系统支持，Apache将使用sendfile将文件内容直接发送到客户端而并不读取文件


ErrorLog logs/error_log
*错误日志存放的位置



LogLevel warn
*Apache日志的级别


LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined 
LogFormat "%h %l %u %t \"%r\" %>s %b" common 
LogFormat "%{Referer}i -> %U" referer 
LogFormat "%{User-agent}i" agent
*定义了日志的格式，并用不同的代号表示
# %h: remote host
# %l: remote log-in name (unless Identity ON, you get "-")
# %u: remote username
# %t: time (standard english time)
# %r: first line requested
# %>s: last status requested
# %b: display with common log format total package bytes except http header, display "-" when there is no byte, instead of 0
# %{referrer}i：请求报文中referrer首部的值，即当前页面从哪一个超链接跳转而来
# %I: Bytes received, including request and headers, cannot be zero.
# %O: Bytes sent, including headers, cannot be zero.
# %S: Bytes transferred (received and sent), including request and headers, cannot be zero. This is the combination of %I and %O.
# %^FB: Delay in microseconds between when the request arrived and the first byte of the response headers are written. Only available if LogIOTrackTTFB is set to ON.

#CustomLog logs/access_log common 
CustomLog logs/access_log combined
*说明日志记录的位置，这里面使用了相对路径，所以ServerRoot需要指出，日志位置就存放在/etc/httpd/logs



ServerSignature On
*定义当客户请求的网页不存在，或者错误的时候是否提示apache的版本的一些信息



Alias /icons/ "/var/www/icons/"
*定义一些不在DocumentRoot下的文件，而可以将其映射到网页根目录中，这也是访问其他目录的一种方法，但在声明的时候切记目录后面加”/”



<Directory "/var/www/icons"> 
    Options Indexes MultiViews FollowSymLinks 
    AllowOverride None 
    Order allow,deny 
    Allow from all 
</Directory>
*定义对/var/www/icons/的权限，修改为 Options MultiViews FollowSymLinks表示不在浏览器上显示树状目录结构



<IfModule mod_dav_fs.c> 
    # Location of the WebDAV lock database. 
    DAVLockDB /var/lib/dav/lockdb
</IfModule>
*对mod_dav_fs.c模块儿的管理



ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
*对CGI模块儿的的别名，与Alias相似。



<Directory "/var/www/cgi-bin"> 
    AllowOverride None 
    Options None 
    Order allow,deny 
    Allow from all 
</Directory>
*对/var/www/cgi-bin文件夹的管理，方法同上



# Redirect old-URI new-URL
*Redirect参数是用来重写URL的，当浏览器访问服务器上的一个已经不存在的资源的时候，服务器返回给浏览器新的URL，告诉浏览器从该URL中获取资源。
 这主要用于原来存在于服务器上的文档改变位置之后，又需要能够使用老URL能访问到原网页

IndexOptions FancyIndexing VersionSort NameWidth=* HTMLTable Charset=UTF-8 
AddIconByEncoding (CMP,/icons/compressed.gif) x-compress x-gzip
... 
IndexIgnore .??* *~ *# HEADER* README* RCS CVS *,v *,t
*当一个HTTP请求的URL为一个目录的时候，服务器返回这个目录中的索引文件，如果目录中不存在索引文件，并且服务器有许可显示目录文件列表的时候，
 就会显示这个目录中的文件列表，为了使得这个文件列表能具有可理解性，而不仅仅是一个简单的列表，就需要前这些参数。如果使用了IndexOptionsFancyIndexing选项，
 可以让服务器针对不同的文件引用不同的图标。如果没有就使用DefaultIcon定义缺省图标。同样，使用AddDescription可以为不同类型的文档介入描述



AddLanguage ca .ca 
...... 
AddLanguage zh-TW .zh-tw
*添加语言



LanguagePriority en ca cs da de el eo es et fr he hr it ja ko ltz nl nn no pl pt pt-BR ru sv zh-CN zh-TW
*Apache支持的语言



AddDefaultCharset UTF-8
*默认支持的语言




#AddType application/x-tar .tgz
*支持的应用如果想支持对php的解析添加这样一行



#AddEncoding x-compress .Z 
#AddEncoding x-gzip .gz .tgz
*支持对以.Z和.gz.tgz结尾的文件



AddType application/x-compress .Z 
AddType application/x-gzip .gz .tgz
*添加对上述两种文件的应用



#AddHandler cgi-script .cgi
*修改为：AddHandler cgi-script .cgi .pl 表示允许扩展名为.pl的CGI脚本运行



AddType text/html .shtml 
AddOutputFilter INCLUDES .shtml
*添加动态处理类型为server-parsed由服务器预先分析网页内的标记，将标记改为正确的HTML标识



#ErrorDocument 404 /missing.html
*当服务器出现404错误的时候，返回missing.html页面



Alias /error/ "/var/www/error/"
*赋值别名

<IfModule mod_negotiation.c> 
<IfModule mod_include.c> 
    <Directory "/var/www/error"> 
        AllowOverride None 
        Options IncludesNoExec 
        AddOutputFilter Includes html 
        AddHandler type-map var 
        Order allow,deny 
        Allow from all 
        LanguagePriority en es de fr 
        ForceLanguagePriority Prefer Fallback 
    </Directory>
*对/var/www/error网页的权限及操作




BrowserMatch "Mozilla/2" nokeepalive 
BrowserMatch "MSIE 4\.0b2;" nokeepalive downgrade-1.0 force-response-1.0 
BrowserMatch "RealPlayer 4\.0" force-response-1.0 
BrowserMatch "Java/1\.0" force-response-1.0 
BrowserMatch "JDK/1\.0" force-response-1.0 
.....
*设置特殊的参数，以保证对老版本浏览器的兼容，并支持新浏览器的特性




***Virtual Hosts
#NameVirtualHost *:80
*如果启用虚拟主机的话，必须将前面的注释去掉，而且，第二部分的内容都可以出现在每个虚拟主机部分。
*Certeros7配置虚拟主机一定要有<Directory>容器，还要有标准的授权
# VirtualHost example: 
#<VirtualHost *:80> 
#    ServerAdmin webmaster@www.linuxidc.com 
#    DocumentRoot /www/docs/www.linuxidc.com 
#    ServerName www.linuxidc.com 
#    ErrorLog logs/www.linuxidc.com-error_log 
#    CustomLog logs/www.linuxidc.com-access_log common 
#</VirtualHost>

*配制虚拟主机得先取消中心主机，注释中心主机的DocumentRoot即可
虚拟主机的定义：
<VirtualHost HOST>
	定义属性
</VirtualHost>
<Directory "PATH">
   Options xxx
   AllowOverride xxx
   order allow,deny
   allow from all
   Requier all granted
</Directory>

*基于IP的虚拟主机
[root@localhost ~]# vim /etc/httpd/conf.d/virtual.conf
<VirtualHost 192.168.3.66:80>
        ServerName hello.yuliang.com
        DocumentRoot "/www/yuliang.com"
</VirtualHost>
<VirtualHost 192.168.3.67:80>
        ServerName www.a.org
        DocumentRoot "/www/a.org"
</VirtualHost>
[root@localhost ~]# httpd -t
Warning: DocumentRoot [/www/yuliang.com] does not exist
Warning: DocumentRoot [/www/a.org] does not exist
Syntax OK
[root@localhost ~]# mkdir -pv /www{yuliang.com,a.org}
mkdir: created directory `/wwwyuliang.com'
mkdir: created directory `/wwwa.org'
[root@localhost ~]# 
[root@localhost conf]# mkdir -pv /www/{yuliang.com,a.org}
mkdir: created directory `/www'
mkdir: created directory `/www/yuliang.com'
mkdir: created directory `/www/a.org'
[root@localhost conf]# cd /www/yuliang.com/
[root@localhost yuliang.com]# vim index.html
<h1>Yuliang.com</h1>
[root@localhost yuliang.com]# cd ../a.org/
[root@localhost a.org]# vim index.html
<h1>a.org</h1>
[root@localhost a.org]# httpd -t
Syntax OK
[root@localhost a.org]# ip addr add 192.168.3.67/24 dev eth0
[root@localhost a.org]# ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN 
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNK
NOWN qlen 1000    link/ether 00:0c:29:0e:7d:a1 brd ff:ff:ff:ff:ff:ff
    inet 192.168.3.66/24 brd 192.168.3.255 scope global eth0
    inet 192.168.3.67/24 scope global secondary eth0
    inet6 fe80::20c:29ff:fe0e:7da1/64 scope link 
       valid_lft forever preferred_lft forever
[root@localhost a.org]#

*基于端口虚拟主机
[root@localhost a.org]# vim /etc/httpd/conf.d/virtual.conf 
<VirtualHost 192.168.3.66:80>
        ServerName hello.yuliang.com
        DocumentRoot "/www/yuliang.com"
</VirtualHost>

<VirtualHost 192.168.3.66:8080>
        ServerName www.b.net
        DocumentRoot "/www/b.net"
</VirtualHost>
[root@localhost a.org]# mkdir /www/b.net
[root@localhost a.org]# cd /www/b.net/
[root@localhost b.net]# vim index.html
<h1>b.net</h1>
[root@localhost b.net]# vim /etc/httpd/conf/httpd.conf 
Listen 8080
[root@localhost b.net]# service httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@localhost b.net]# 

*基于域名的虚拟主机
[root@localhost b.net]# vim /etc/httpd/conf.d/virtual.conf
NameVirtualHost 192.168.3.67:80

<VirtualHost 192.168.3.67:80>
        ServerName www.a.org
        DocumentRoot "/www/a.org"
</VirtualHost>
<VirtualHost 192.168.3.67:80>
        ServerName www.d.gov
        DocumentRoot "/www/d.gov"
</VirtualHost>

[root@localhost b.net]# mkdir /www/d.gov
[root@localhost b.net]# cd /www/d.gov/
[root@localhost d.gov]# vim index.html
<h1>This is third lab based on net_hostname</h1>
[root@localhost d.gov]#

*单独为某个虚拟主机封装规则
[root@localhost ~]# vim /etc/httpd/conf.d/virtual.conf
NameVirtualHost 192.168.3.67:80

<VirtualHost 192.168.3.67:80>
        ServerName www.a.org
        DocumentRoot "/www/a.org"
        <Directory "/www/a.org">
                Options none
                AllowOverride authconfig
                AuthType basic
                AuthName "Restrict area"
                AuthUserFile "/etc/httpd/.htpasswd"
                Require valid-user
        </Directory>
</VirtualHost>
<VirtualHost 192.168.3.67:80>
        ServerName www.d.gov
        DocumentRoot "/www/d.gov"
        <Directory "/www/d.gov">
                Options none
                AllowOverride none
                Order deny,allow
                Deny from 192.168.3.42
        </Directory>
</VirtualHost>

[root@localhost named]# httpd -t
Syntax OK
[root@localhost named]# service httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@localhost named]# 
[root@localhost conf.d]# htpasswd -c -m /etc/httpd/.htpasswd tom
New password: 
Re-type new password: 
Adding password for user tom
[root@localhost conf.d]# htpasswd  -m /etc/httpd/.htpasswd jerry
New password: 
Re-type new password: 
Adding password for user jerry
[root@localhost conf.d]# 
[root@localhost conf.d]# service httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@localhost conf.d]# 



***SSl认证加密机制，需要证书
*httpd认证所需要依赖的模块
[root@localhost ~]# mount /dev/cdrom /mnt/
mount: block device /dev/sr0 is write-protected, mounting read-only
[root@localhost ~]# yum install mod_ssl
[root@localhost ~]# rpm -ql mod_ssl
/etc/httpd/conf.d/ssl.conf
/usr/lib/httpd/modules/mod_ssl.so
/var/cache/mod_ssl
/var/cache/mod_ssl/scache.dir
/var/cache/mod_ssl/scache.pag
/var/cache/mod_ssl/scache.sem

*把192.168.3.99当作CA中心
[root@localhost ~]# cd /etc/pki/
[root@localhost pki]# cd CA/
[root@localhost CA]# (umask 077; openssl genrsa -out private/cakey.pem 2048)
Generating RSA private key, 2048 bit long modulus
..................+++
....+++
e is 65537 (0x10001)
[root@localhost CA]# ls -l private/
total 4
-rw------- 1 root root 1679 Apr 24 11:50 cakey.pem
[root@localhost CA]# 
*改一下默认值，方便自动生成
[root@localhost CA]# vim ../tls/openssl.cnf
dir				= /etc/pki/CA
countryName_default             = CN
stateOrProvinceName_default     = Hubei
0.organizationName_default      = yuliang.com
organizationalUnitName_default  =Tech
[root@localhost CA]# openssl req -new -x509 -key private/cakey.pem -out cacert.pem -days 3655
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [CN]:
State or Province Name (full name) [Hubei]:
Locality Name (eg, city) [Wuhan]:
Organization Name (eg, company) [yuliang.com]:
Organizational Unit Name (eg, section) [Tech]:
Common Name (eg, your name or your server's hostname) []:ca.yuliang.com
Email Address []:admin@yuliang.com
[root@localhost CA]#
[root@localhost CA]# mkdir certs crl newcerts
[root@localhost CA]# touch index.txt
[root@localhost CA]# echo 01 > serial
[root@localhost CA]# ls
cacert.pem  certs  crl  index.txt  newcerts  private  serial
[root@localhost CA]# 

*192.168.3.66当作证书申请端
[root@localhost ~]# cd /etc/httpd/
[root@localhost httpd]# ls
conf  conf.d  logs  modules  run
[root@localhost httpd]# mkdir ssl
[root@localhost httpd]# cd ssl/
[root@localhost ssl]# (umask 077; openssl genrsa 1024 > httpd.key)
Generating RSA private key, 1024 bit long modulus
.......++++++
............++++++
e is 65537 (0x10001)
[root@localhost ssl]# ll
total 4
-rw------- 1 root root 887 Apr 24 11:53 httpd.key
[root@localhost ssl]# openssl req -new -key httpd.key -out httpd.csr
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [XX]:CN
State or Province Name (full name) []:Hubei    
Locality Name (eg, city) [Default City]:Wuhan
Organization Name (eg, company) [Default Company Ltd]:yuliang.com
Organizational Unit Name (eg, section) []:Tech
Common Name (eg, your name or your server's hostname) []:hello.yuliang.com
Email Address []:hello@yuliang.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
[root@localhost ssl]# 
[root@localhost ssl]# scp httpd.csr 192.168.3.99:/tmp
root@192.168.3.99's password: 
httpd.csr                                                                                       100%  708     0.7KB/s   00:00    
[root@localhost ssl]# 

*回到192.168.3.99给传送过来申请书签证
[root@localhost CA]# openssl ca -in /tmp/httpd.csr -out /tmp/httpd.crt -days 3650
Using configuration from /etc/pki/tls/openssl.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (0x1)
        Validity
            Not Before: Apr 24 16:14:14 2016 GMT
            Not After : Apr 22 16:14:14 2026 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = Hubei
            organizationName          = yuliang.com
            organizationalUnitName    = Tech
            commonName                = hello.yuliang.com
            emailAddress              = hello@yuliang.com
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Comment: 
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier: 
                00:90:55:9B:D6:1C:75:C0:CA:5D:83:1E:E4:D0:EA:8E:4C:B6:DB:F5
            X509v3 Authority Key Identifier: 
                keyid:54:82:71:BE:FC:B5:8F:EA:46:F7:F4:15:34:45:4F:C2:FC:E1:AE:91

Certificate is to be certified until Apr 22 16:14:14 2026 GMT (3650 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
[root@localhost CA]# 
[root@localhost CA]# cat index.txt
V	260422161414Z		01	unknown	/C=CN/ST=Hubei/O=yuliang.com/OU=Tech/CN=hello.yuliang.com/emailAddress=hello@yulia
ng.com[root@localhost CA]# cat serial
02
[root@localhost CA]# 

*回到192.168.3.66将192.168.3.99上签好的证书复制过来
[root@localhost ssl]# scp 192.168.3.99:/tmp/httpd.crt ./
root@192.168.3.99's password: 
httpd.crt                                                                                       100% 3873     3.8KB/s   00:00    
[root@localhost ssl]# 
[root@localhost ssl]# cd /etc/httpd/conf.d/
[root@localhost conf.d]# cp ssl.conf /root/ssl.conf.backup
RHEL7上有点不一样，做以下调整
[root@localhost conf.d]# vim ssl.conf 
准确指出来
DocumentRoot "/var/www/html/a.com"
ServerName www.a.com:443
SSLCertificateFile /etc/pki/tls/certs/server.crt
SSLCertificateKeyFile /etc/pki/tls/private/server.key
[root@localhost conf.d] vim /etc/httpd/conf.d/httpd-vhosts.conf
调整虚拟主机
<VirtualHost *:80>
 ServerName www.a.com
 Redirect permanent / https://www.a.com/
 DocumentRoot "/var/www/html/a.com"

 <Directory "/var/www/html/a.com">
 Options None
 AllowOverride None
 Require all granted
 </Directory>
</VirtualHost>

5. 强制Apache Web服务器始终使用https

如果由于某种原因，你需要站点的Web服务器都只使用HTTPS，此时就需要将所有HTTP请求(端口80)重定向到HTTPS(端口443)。 Apache Web服务器可以容易地做到这一点。

1，强制主站所有Web使用（全局站点）

如果要强制主站使用HTTPS，我们可以这样修改httpd配置文件：

# vim /etc/httpd/conf/httpd.conf

ServerName www.example.com:80
Redirect permanent / https://www.example.com

重启Apache服务器，使配置生效：

# systemctl restart httpd

 

2，强制虚拟主机（单个站点）

如果要强制单个站点在虚拟主机上使用HTTPS，对于HTTP可以按照下面进行配置：

# vim /etc/httpd/conf.d/httpd-vhosts.conf

<VirtualHost *:80>
    ServerName www.a.com
    Redirect permanent / https://www.a.com/
</VirtualHost>

重启Apache服务器，使配置生效：

# systemctl restart httpd


***MySQL：的基本应用
*mysql数据库其实是一个目录，如下：
[root@localhost ~]# cd /var/lib/mysql/
[root@localhost mysql]# ls
ibdata1  ib_logfile0  ib_logfile1  mysql  mysql.sock  test
[root@localhost mysql]# ll
total 20488
-rw-rw---- 1 mysql mysql 10485760 Apr 29 09:19 ibdata1
-rw-rw---- 1 mysql mysql  5242880 Apr 29 09:19 ib_logfile0
-rw-rw---- 1 mysql mysql  5242880 Apr 29 09:19 ib_logfile1
drwx------ 2 mysql mysql     4096 Apr 29 09:19 mysql
srwxrwxrwx 1 mysql mysql        0 Apr 29 09:19 mysql.sock
drwx------ 2 mysql mysql     4096 Apr 29 09:19 test
[root@localhost mysql]# mysql
mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| test               |
+--------------------+
3 rows in set (0.00 sec)
[root@localhost mysql]# mkdir mydb
[root@localhost mysql]# ll
total 20492
-rw-rw---- 1 mysql mysql 10485760 Apr 29 09:19 ibdata1
-rw-rw---- 1 mysql mysql  5242880 Apr 29 09:19 ib_logfile0
-rw-rw---- 1 mysql mysql  5242880 Apr 29 09:19 ib_logfile1
drwxr-xr-x 2 root  root      4096 Apr 29 09:34 mydb
drwx------ 2 mysql mysql     4096 Apr 29 09:19 mysql
srwxrwxrwx 1 mysql mysql        0 Apr 29 09:19 mysql.sock
drwx------ 2 mysql mysql     4096 Apr 29 09:19 test
[root@localhost mysql]# chown mysql:mysql mydb/
[root@localhost mysql]# mysql
mysql> show database;
ERROR 1064 (42000): You have an error in your SQL syntax; check the manual
 that corresponds to your MySQL server version for the right syntax to use near 'database' at line 1mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mydb               |
| mysql              |
| test               |
+--------------------+
4 rows in set (0.00 sec)
mysql> 
mysql>
mysql> create database testdb;
Query OK, 1 row affected (0.00 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mydb               |
| mysql              |
| test               |
| testdb             |
+--------------------+
5 rows in set (0.00 sec)
mysql> 
mysql> 
mysql> use mydb;
Database changed
mysql> 
mysql> CREATE TABLE students(Name CHAR(20) NOT NULL,Age TINYINT UNSIGNED,Gender CHAR(1) NOT NULL);
Query OK, 0 rows affected (0.07 sec)

mysql> 
mysql> 
mysql> show tables;
+----------------+
| Tables_in_mydb |
+----------------+
| students       |
+----------------+
1 row in set (0.00 sec)
mysql> 
mysql> 
mysql> desc students;
+--------+---------------------+------+-----+---------+-------+
| Field  | Type                | Null | Key | Default | Extra |
+--------+---------------------+------+-----+---------+-------+
| Name   | char(20)            | NO   |     | NULL    |       |
| Age    | tinyint(3) unsigned | YES  |     | NULL    |       |
| Gender | char(1)             | NO   |     | NULL    |       |
+--------+---------------------+------+-----+---------+-------+
3 rows in set (0.00 sec)
mysql> 
mysql> 
mysql> alter table students add course varchar(100);
Query OK, 0 rows affected (0.10 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc students;
+--------+---------------------+------+-----+---------+-------+
| Field  | Type                | Null | Key | Default | Extra |
+--------+---------------------+------+-----+---------+-------+
| Name   | char(20)            | NO   |     | NULL    |       |
| Age    | tinyint(3) unsigned | YES  |     | NULL    |       |
| Gender | char(1)             | NO   |     | NULL    |       |
| course | varchar(100)        | YES  |     | NULL    |       |
+--------+---------------------+------+-----+---------+-------+
4 rows in set (0.00 sec)
mysql> 
mysql> 
mysql> alter table students CHANGE course Course varchar(100) after Name;
Query OK, 0 rows affected (0.10 sec)
Records: 0  Duplicates: 0  Warnings: 0

mysql> desc students;
+--------+---------------------+------+-----+---------+-------+
| Field  | Type                | Null | Key | Default | Extra |
+--------+---------------------+------+-----+---------+-------+
| Name   | char(20)            | NO   |     | NULL    |       |
| Course | varchar(100)        | YES  |     | NULL    |       |
| Age    | tinyint(3) unsigned | YES  |     | NULL    |       |
| Gender | char(1)             | NO   |     | NULL    |       |
+--------+---------------------+------+-----+---------+-------+
4 rows in set (0.00 sec)
mysql> 
mysql> insert into students (Name,Gender) value('LingHuchong','M'),('Xiaolongnv','F');
Query OK, 2 rows affected (0.00 sec)
Records: 2  Duplicates: 0  Warnings: 0

mysql> SELECT * FROM students;
+-------------+--------+------+--------+
| Name        | Course | Age  | Gender |
+-------------+--------+------+--------+
| LingHuchong | NULL   | NULL | M      |
| Xiaolongnv  | NULL   | NULL | F      |
+-------------+--------+------+--------+
2 rows in set (0.00 sec)
mysql>
mysql> INSERT INTO students values('XiaoXiangzi','Hamagong',57,'M');
Query OK, 1 row affected (0.00 sec)

mysql> SELECT * FROM students;
+-------------+----------+------+--------+
| Name        | Course   | Age  | Gender |
+-------------+----------+------+--------+
| LingHuchong | NULL     | NULL | M      |
| Xiaolongnv  | NULL     | NULL | F      |
| XiaoXiangzi | Hamagong |   57 | M      |
+-------------+----------+------+--------+
3 rows in set (0.00 sec)

mysql> 
mysql> UPDATE students SET Course='Pixiejianfa';
Query OK, 3 rows affected (0.00 sec)
Rows matched: 3  Changed: 3  Warnings: 0

mysql> SELECT * FROM students;
+-------------+-------------+------+--------+
| Name        | Course      | Age  | Gender |
+-------------+-------------+------+--------+
| LingHuchong | Pixiejianfa | NULL | M      |
| Xiaolongnv  | Pixiejianfa | NULL | F      |
| XiaoXiangzi | Pixiejianfa |   57 | M      |
+-------------+-------------+------+--------+
3 rows in set (0.00 sec)

mysql> 
mysql> UPDATE students SET Course='Hamogong' WHERE Name='XiaoXiangzi';
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0

mysql> SELECT * FROM students;
+-------------+-------------+------+--------+
| Name        | Course      | Age  | Gender |
+-------------+-------------+------+--------+
| LingHuchong | Pixiejianfa | NULL | M      |
| Xiaolongnv  | Pixiejianfa | NULL | F      |
| XiaoXiangzi | Hamogong    |   57 | M      |
+-------------+-------------+------+--------+
3 rows in set (0.00 sec)
mysql> 
mysql> 
mysql> SELECT Name,Course FROM students WHERE Gender='M';
+-------------+-------------+
| Name        | Course      |
+-------------+-------------+
| LingHuchong | Pixiejianfa |
| XiaoXiangzi | Hamogong    |
+-------------+-------------+
2 rows in set (0.00 sec)
mysql> 
mysql> 
mysql> 
mysql> SELECT * FROM students;
+-------------+-------------+------+--------+
| Name        | Course      | Age  | Gender |
+-------------+-------------+------+--------+
| LingHuchong | Pixiejianfa | NULL | M      |
| Xiaolongnv  | Pixiejianfa | NULL | F      |
| XiaoXiangzi | Hamogong    |   57 | M      |
+-------------+-------------+------+--------+
3 rows in set (0.00 sec)

mysql> DELETE FROM students WHERE Course='Pixiejianfa';
Query OK, 2 rows affected (0.00 sec)

mysql> SELECT * FROM students;
+-------------+----------+------+--------+
| Name        | Course   | Age  | Gender |
+-------------+----------+------+--------+
| XiaoXiangzi | Hamogong |   57 | M      |
+-------------+----------+------+--------+
1 row in set (0.00 sec)

mysql> 
mysql> CREATE USER 'jerry'@'%' IDENTIFIED BY 'jerry';
Query OK, 0 rows affected (0.00 sec)

mysql> SHOW GRANTS FOR 'jerry'@'%';
+-------------------------------------------------------------------------
-----------------------------+| Grants for jerry@%                                                      
                             |+-------------------------------------------------------------------------
-----------------------------+| GRANT USAGE ON *.* TO 'jerry'@'%' IDENTIFIED BY PASSWORD '*09FB9E6E2AA07
50E9D8A8D22B6AA8D86C85BF3D0' |+-------------------------------------------------------------------------
-----------------------------+1 row in set (0.00 sec)

mysql> 
mysql> grant all privileges on mydb.* to 'jerry'@'%';
Query OK, 0 rows affected (0.00 sec)

mysql> SHOW GRANTS FOR 'jerry'@'%';
+-------------------------------------------------------------------------
-----------------------------+| Grants for jerry@%                                                      
                             |+-------------------------------------------------------------------------
-----------------------------+| GRANT USAGE ON *.* TO 'jerry'@'%' IDENTIFIED BY PASSWORD '*09FB9E6E2AA07
50E9D8A8D22B6AA8D86C85BF3D0' || GRANT ALL PRIVILEGES ON `mydb`.* TO 'jerry'@'%'                         
                             |+-------------------------------------------------------------------------
-----------------------------+2 rows in set (0.00 sec)

mysql> 



一、MySQL基础操作练习（所属的库叫做testdb）
新建如下表（包括结构和内容）：
ID	Name		Age	Gender	Course
1	LingHuchong	24	Male	Hamagong
2	HuangRong	19	Female	Chilian Shenzhang
3	Lu Wushuang	18	Female	Jiuyang Shengong
4	Zhu Ziliu	52	Male	Pixie Jianfa
5	Chen Jialuo	22	Male	Xianglong Shiba Zhang

二、完成如下操作
	找出性别为女性的所有人
	找出年龄大于20的所有人
	修改Zhu Ziliu的Course为Kuihua Baodian
	删除年龄小于等于19岁的所有人
	创建此表及所属的库
	授权给testuser对testdb库有所有访问权限
mysql> CREATE DATABASE testdb;
Query OK, 1 row affected (0.00 sec)

mysql> 
mysql> 
mysql> USE testdb;
Database changed
mysql> CREATE TABLE students(ID TINYINT UNSIGNED NOT NULL, Name varchar(20) NOT NULL, Age TINYINT UNSIGNED, Gender char(1), Course varchar(20) NOT NULL);
Query OK, 0 rows affected (0.07 sec)

mysql> 
mysql> show tables;
+------------------+
| Tables_in_testdb |
+------------------+
| students         |
+------------------+
1 row in set (0.00 sec)

mysql> desc students;
+--------+---------------------+------+-----+---------+-------+
| Field  | Type                | Null | Key | Default | Extra |
+--------+---------------------+------+-----+---------+-------+
| ID     | tinyint(3) unsigned | NO   |     | NULL    |       |
| Name   | varchar(20)         | NO   |     | NULL    |       |
| Age    | tinyint(3) unsigned | YES  |     | NULL    |       |
| Gender | char(1)             | YES  |     | NULL    |       |
| Course | varchar(20)         | NO   |     | NULL    |       |
+--------+---------------------+------+-----+---------+-------+
5 rows in set (0.00 sec)
mysql>
mysql> INSERT INTO students values(1, 'LingHuchong', 24, 'M', 'Hamagong');
Query OK, 1 row affected (0.00 sec)

mysql> 
mysql> INSERT INTO students values(2, 'HuangRong', 19, 'F', 'Chilian Shenzhang'),(3, 'LuWushuang', 18, 'F', 'Jiuyang Shengong'),(4, 'Zhu Ziliu', 52, 'M', 'Pixiejianfa'),(5, 'Chen jialuo', 22, 'M', 'Xianglong Shiba Zhang');
Query OK, 4 rows affected, 1 warning (0.00 sec)
Records: 4  Duplicates: 0  Warnings: 1

mysql> 
mysql> SELECT * FROM students;
+----+-------------+------+--------+----------------------+
| ID | Name        | Age  | Gender | Course               |
+----+-------------+------+--------+----------------------+
|  1 | LingHuchong |   24 | M      | Hamagong             |
|  2 | HuangRong   |   19 | F      | Chilian Shenzhang    |
|  3 | LuWushuang  |   18 | F      | Jiuyang Shengong     |
|  4 | Zhu Ziliu   |   52 | M      | Pixiejianfa          |
|  5 | Chen jialuo |   22 | M      | Xianglong Shiba Zhan |
+----+-------------+------+--------+----------------------+
5 rows in set (0.00 sec)

mysql> 
mysql> SELECT * FROM students WHERE Gender='F';
+----+------------+------+--------+-------------------+
| ID | Name       | Age  | Gender | Course            |
+----+------------+------+--------+-------------------+
|  2 | HuangRong  |   19 | F      | Chilian Shenzhang |
|  3 | LuWushuang |   18 | F      | Jiuyang Shengong  |
+----+------------+------+--------+-------------------+
2 rows in set (0.00 sec)

mysql> 
mysql> SELECT * FROM students WHERE Age >20 ;
+----+-------------+------+--------+----------------------+
| ID | Name        | Age  | Gender | Course               |
+----+-------------+------+--------+----------------------+
|  1 | LingHuchong |   24 | M      | Hamagong             |
|  4 | Zhu Ziliu   |   52 | M      | Pixiejianfa          |
|  5 | Chen jialuo |   22 | M      | Xianglong Shiba Zhan |
+----+-------------+------+--------+----------------------+
3 rows in set (0.00 sec)

mysql> 
mysql> UPDATE students SET Course='Kuihua Baodian' WHERE Name='Zhu Ziliu';
Query OK, 1 row affected (0.00 sec)
Rows matched: 1  Changed: 1  Warnings: 0
mysql> select * from students;
+----+-------------+------+--------+----------------------+
| ID | Name        | Age  | Gender | Course               |
+----+-------------+------+--------+----------------------+
|  1 | LingHuchong |   24 | M      | Hamagong             |
|  2 | HuangRong   |   19 | F      | Chilian Shenzhang    |
|  3 | LuWushuang  |   18 | F      | Jiuyang Shengong     |
|  4 | Zhu Ziliu   |   52 | M      | Kuihua Baodian       |
|  5 | Chen jialuo |   22 | M      | Xianglong Shiba Zhan |
+----+-------------+------+--------+----------------------+
5 rows in set (0.00 sec)

mysql> 
mysql> DELETE FROM students WHERE Age<= 19;
Query OK, 2 rows affected (0.00 sec)

mysql> select * from students;
+----+-------------+------+--------+----------------------+
| ID | Name        | Age  | Gender | Course               |
+----+-------------+------+--------+----------------------+
|  1 | LingHuchong |   24 | M      | Hamagong             |
|  4 | Zhu Ziliu   |   52 | M      | Kuihua Baodian       |
|  5 | Chen jialuo |   22 | M      | Xianglong Shiba Zhan |
+----+-------------+------+--------+----------------------+
3 rows in set (0.00 sec)

mysql> 
mysql> CREATE USER 'testuser'@'%' IDENTIFIED BY 'ok';
Query OK, 0 rows affected (0.00 sec)

mysql> GRANT ALL privileges ON testdb.* TO 'testuser'@'%';
Query OK, 0 rows affected (0.00 sec)

mysql> 

***为用户设定密码：
1、mysql> SET PASSWORD FOR 'USERNAME'@'HOST'=PASSWORD('password');
2、[root@PXE1 ~]# mysqladmin -u USERNAME -h HOSTNAME password 'NEW_PASS' -p
3、mysql> UPDATE user SET Password=PASSWORD('password') WHERE USER='root' AND HOST='127.0.0.1';

*使用户密码生效
mysql> FLUSH PRIVILEGES;

mysql> 
mysql> 
mysql> SET PASSWORD FOR 'root'@'localhost'=PASSWORD('redhat');
Query OK, 0 rows affected (0.00 sec)

mysql> 
mysql> SELECT User,Host,Password FROM user;
+----------+-----------------------+-------------------------------------------+
| User     | Host                  | Password                                  |
+----------+-----------------------+-------------------------------------------+
| root     | localhost             | *84BB5DF4823DA319BBF86C99624479A198E6EEE9 |
| root     | localhost.localdomain |                                           |
| root     | 127.0.0.1             |                                           |
|          | localhost             |                                           |
|          | localhost.localdomain |                                           |
| jerry    | %                     | *09FB9E6E2AA0750E9D8A8D22B6AA8D86C85BF3D0 |
| tom      | %                     | *71FF744436C7EA1B954F6276121DB5D2BF68FC07 |
| siri     | 192.168.3.83          | *CCC149155FC8DB8A8E18B1A94EFE97D8BD46674E |
| testuser | %                     | *31330A9B24799CC9566A39CBD78CEF60E26C906F |
+----------+-----------------------+-------------------------------------------+
9 rows in set (0.00 sec)

mysql> 
mysql> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.00 sec)

mysql> 
*正确格式是：-p跟旧密码之间没有空格
[root@mysql ~]# mysqladmin -uroot -hlocalhost -p"old_pass" password "new_pass"

mysql> UPDATE user SET Password='redhat' WHERE user='root' and host='127.0.0.1';
Query OK, 0 rows affected (0.00 sec)
Rows matched: 1  Changed: 0  Warnings: 0

mysql> 


*图形客户端工具
1、phpMyAdmin
2、workbench
3、MySQL Front
4、Navicat for MySQL
5、Toad

LANP的结构化
	单层结构：apache, php, mysql位于一个服务器
	两层结构：apache, php位于一个服务器，mysql位于一个服务器（或者后两者在一起）
	三层结构：apache, php, mysql各位于一个服务器
		三层结构便于扩展

LAMP连体基本要求：httpd-->php解释器-->php-mysql连接器-->mysqld

<title>A</title>
<h1>Test for connection between httpd, php and mysql</h1>
<?php
        $conn=mysql_connect('localhost','root','redhat');
        if ($conn)
                echo "Success...";
        else
                echo "failure...";
?>

PHP：脚本编程语言，php解释器
	WebApp：面向对象的特征
		Zend:
			第一段：词法分析、语法分析、编绎为Opcode;
				opcode放置于内存中
			第二段：zend引擎执行opcode(opcode像java bytecode，zend像java jvm)
	PHP 缓存器
		APC
		eAccelerator
		XCache 这个用的多
PHP解释器-->MySQL，如何交互？
	PHP解释器就像Bash一样，本身只是一个翻译者
	真正与MySQL交互的是程序代码（index.php里面的代码）
httpd+php：
	CGI模式：请求php-->httpd-->cgi协议-->启动php进程解释脚本
	Module：请求php-->httpd 加载自身模块解释php脚本
	FastCGI：请求php-->httpd-->cgi协议-->专门有一个服务器生成管理多个cgi进程（像守护进程一样，Socks:9000侦听）

LAMP编绎配置：
	Linux, Apache, MySQL, PHP(Python, Perl)
rpm包：
	/bin, /sbin, /usr/bin, /usr/sbin
	/lib, /usr/lib
	/etc
	/usr/share/{doc,man}

编译安装：
	/usr/local/
		bin, sbin
		lib
		etc
		share/{doc,man}
	为了能够准确卸载删除，要放在/usr/local/软件同名目录下
	/usr/local/httpd/{bin, sbin, lib, includes, etc, share/man,....}
		但是要解决路径的问题，以前学编绎安装软件时有详细步骤

Apache: ASF(apache软件基金会), httpd, tomcat, cloudware
	httpd: 2.4.4
	php: 5.4.13
	MySQL:5.6.10 (rpm, 通用二进制, 源码)
先后关系：httpd-->MySQL-->php-->XCache（依赖的头文件和库文件有顺序）
1、httpd安装
*httpd背后的虚拟机
	apr: Apache Portable Runtime
	[root@PXE1 ~]# rpm -q apr
	apr-1.3.9-3.el6.i686
	[root@PXE1 ~]# rpm -q apr-util
	apr-util-1.3.9-3.el6.i686
	[root@PXE1 ~]# rpm -qi apr-util
	Name        : apr-util                     Relocations: (not relocatable)
	Version     : 1.3.9                             Vendor: Red Hat, Inc.
	Release     : 3.el6                         Build Date: Fri 18 Dec 2009 04:09:59 PM 
	GMTInstall Date: Tue 26 Apr 2016 11:14:37 PM GMT      Build Host: x86-003.build.bos.red
	hat.comGroup       : System Environment/Libraries   Source RPM: apr-util-1.3.9-3.el6.src.rp
	mSize        : 199112                           License: ASL 2.0
	Signature   : RSA/8, Mon 16 Aug 2010 03:24:20 PM GMT, Key ID 199e2f91fd431d51
	Packager    : Red Hat, Inc. <http://bugzilla.redhat.com/bugzilla>
	URL         : http://apr.apache.org/
	Summary     : Apache Portable Runtime Utility library
	Description :
	The mission of the Apache Portable Runtime (APR) is to provide a
	free library of C data structures and routines.  This library
	contains additional utility interfaces for APR; including support
	for XML, LDAP, database interfaces, URI parsing and more.
	[root@PXE1 ~]# 
*所以要安装两个最新的插件apr, apr-util
apr-->apr-util-->httpd

#yum -y install pcre-devel

#tar -xf apr-1.4.6.tar.bz2
#cd apr-1.4.6
#./configure --prefix=/usr/local/apr
#make
#make install

#tar xf apr-util-1.4.1.tar.bz2
#cd apr-util-1.4.1
#./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
#make
#make install

#tar xf httpd-2.4.4.tar.bz2
#cd httpd-2.4.4
#./configure --prefix=/usr/local/apache --sysconfdir=/etc/httpd --enable-so --enable-rewrite --enable-ssl --enable-cgi --enable-cgid --enable-modules=most --enable-mods-shared=most --enable-mpms-shared=all --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util
#make
#make install


httpd 2.4新特性：
1、MPM可于运行时装载：
	--enable-mpms-shared=all --with-mpm=event
2、Event MPM
3、异步读写
4、在每模块及每目录上指定日志级别
5、每请求配置：<IF>, <ElseIF>, <Else>
6、增强的表达式分析器
7、毫秒级的KeepAlive Timeout
8、基于域名的虚拟主机不再需要NameVirtualHost指令
9、降低了内存占用
10、支持在配置文件中使用自定义变量

新增加的模块：
mod_proxy_fcgi
mod_proxy_scgi
mod_proxy_express
mod_remoteip
mod_session
mod_ratelimit
mod_request
等等：

对于基于IP的访问控制
Order allow, deny
all from all

2.4中不再支持此方法
2.4使用Require user
Require user USERNAME
Require group GROUPNAME

Require ip IPADDR
Require not ip IPADDR
	ip
	NETWORK/NETMASK
	NETWORK/LENGTH
	NET
	172.16.0.0/255.255.0.0=172.16.0.0/16=172.16
Require host HOSTNAME
	HOSTNAME
	DOMAIN
	www.magedu.com
	.magedu.com
允许所有主机访问
Require all granted

拒绝所有主访问
Require all deny


MySQL：配置文件格式，集中式配置文件，可以为多个程序提供配置
[mysql]
....

[mysqld]
....

MySQL找配置文件路径：/etc/my.cnf-->/etc/mysql/my.cnf-->$BASEDIR/my.cnf-->~/.my.cnf

MySQL服务器维护了两类变量：
	服务器变量：
		定义MySQL服务器运行特性
		SHOW GLOBAL VARIABLES [LIKE 'STRING'];
	状态变量：
		保存了MySQL服务器运行统计数据
		SHOW GLOBAL STATUS [LIKE 'STRING'];
MySQL通配符：
	_: 任意单个字符
	%: 任意长度的任意字符

PHP源代码目录结构简介
基于PHP-5.3.8源代码给大家分享一下PHP的内核结构，以便更好的理解PHP脚本的执行过程和写出高效率的脚本。
目录结构如下：
1. build 和编译有关的目录，里面包括wk，awk和sh脚本用于编译处理，其中m4文件是linux下编译程序自动生成的文件，可以使用buildconf命令操作具体的配置文件。
2. ext 扩展库代码，例如 Mysql，gd，zlib，xml，iconv 等我们熟悉的扩展库，ext_skel是linux下扩展生成脚本，windows下使用ext_skel_win32.php脚本生成，每个扩展目录下包括php_扩展名.c文件和phpt批处理测试脚本。
3. main 主目录，包括php.h,main.c,logos.h数组等等，是php程序的主要部分，定义了程序的SAPI接口全局变量等等。
4. netware 网络目录，以前的版本没有此目录，里面就两个文件sendmail_nw.h和start.c，分别定义SOCK通信说需要的头文件和具体实现。
5. pear 扩展包目录，PHP Extension and Application Repository的简写，install-pear.txt文件中详细说明了怎么样安装具体的扩展包，自己去看吧。
6. sapi 和各种服务器的接口调用，例如apache、IIS等，也包含一般的fastcgi、cgi等，如果你看过apache的源代码的话，这个目录一目了然的清楚了，比如apache_hooks和apache2handler等等。
7. scripts Linux 下的脚本目录。
8. tests 测试脚本目录，主要是phpt脚本，由--TEST--，--POST--，--FILE--和--EXPECT--三个部分组成。有些需要初始化的可以加--INI--部分。
9. TSRM 线程安全资源管理器，Thread Safe Resource Manager的缩写，研究过PHP的源码，你就会看到这个东西到处都在，保证在单线程和多线程模型下的线程安全和代码一致性。
10. win32目录，Windows 下编译 PHP 有关的脚本，用了 WSH。
11. Zend 文件夹核心的引擎，包括PHP的生命周期，内存管理，变量定义和赋值以及函数宏定义等等。


php支持扩展功能：
	Xcache
	
压力测试工具：
	ab
	httpd_load
	webbench
	siege
使用ab命令测试apache服务器性能：

-c concurrency：一次性发起的请求个数，默认为1；
-i：测试时使用HEAD方法，默认为GET；
-k：启用HTTP长连接请求方式；
-n requests：发起的模拟请求个数；默认为1个；请求数要大于等于并发连接数；
-q：静默模式，在请求数大于150个时不输出请求完成百分比；

输出结果：
Time taken for tests：从第一个请求连接建立到收到最后一个请求的响应报文结束所经历的时长；
Complete requests：成功的请求数；


[root@PXE1 ~]# ls
apr-1.4.6.tar.bz2  apr-util-1.4.1.tar.bz2  httpd-2.4.4.tar.gz  mysql-5.5.28.tar.gz
[root@PXE1 ~]# tar -xf apr-1.4.6.tar.bz2 
[root@PXE1 ~]# cd apr-1.4.6
[root@PXE1 apr-1.4.6]# ls
apr-config.in  build             docs        libapr.mak    mmap           shmem
apr.dep        buildconf         dso         libapr.rc     network_io     strings
apr.dsp        build.conf        emacs-mode  LICENSE       NOTICE         support
apr.dsw        build-outputs.mk  file_io     locks         NWGNUmakefile  tables
apr.mak        CHANGES           helpers     Makefile.in   passwd         test
apr.pc.in      config.layout     include     Makefile.win  poll           threadproc
apr.spec       configure         libapr.dep  memory        random         time
atomic         configure.in      libapr.dsp  misc          README         user
[root@PXE1 apr-1.4.6]# 
*编绎可以指定很多功能，用./configure --help 查看这些功能，有需要就指定上，但默认的在这里足够
[root@PXE1 apr-1.4.6]# ./configure --prefix=/usr/local/apr
[root@PXE1 apr-1.4.6]#  make
[root@PXE1 apr-1.4.6]#  make install
[root@PXE1 ~]# tar xf apr-util-1.4.1.tar.bz2 
[root@PXE1 ~]# cd apr-util-1.4.1
[root@PXE1 apr-util-1.4.1]# ./configure --help
--with-apr=PATH         prefix for installed APR or the full path to
[root@PXE1 apr-util-1.4.1]# ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
[root@PXE1 apr-util-1.4.1]# make
[root@PXE1 apr-util-1.4.1]# make install
[root@PXE1 ~]# tar xf httpd-2.4.4.tar.gz 
[root@PXE1 ~]# cd httpd-2.4.4
[root@PXE1 httpd-2.4.4]# 
--enable-ssl            SSL/TLS support (mod_ssl)
 --enable-so             DSO capability. This module will be automatically
--enable-deflate        Deflate transfer encoding support
[root@PXE1 httpd-2.4.4]# yum install pcre-devel -y
[root@PXE1 httpd-2.4.4]# ./configure --prefix=/usr/local/apache --sysconfdir=/etc/httpd --enable-so --enable-rewrite --enable-ssl --enable-cgi --enable-cgid --enable-modules=most --enable-mods-shared=most --enable-mpms-shared=all --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util
checking whether to enable mod_ssl... configure: error: mod_ssl has been requested but can not be built due to prerequisite failures
[root@PXE1 httpd-2.4.4]# yum install openssl-devel -y
[root@PXE1 httpd-2.4.4]# ./configure --prefix=/usr/local/apache --sysconfdir=/etc/httpd --enable-so --enable-rewrite --enable-ssl --enable-cgi --enable-cgid --enable-modules=most --enable-mods-shared=most --enable-mpms-shared=all --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util
[root@PXE1 httpd-2.4.4]# make
[root@PXE1 httpd-2.4.4]# make install
Installing configuration files
mkdir /etc/httpd/extra
mkdir /etc/httpd/original
mkdir /etc/httpd/original/extra
Installing HTML documents
mkdir /usr/local/apache/htdocs
Installing error documents
mkdir /usr/local/apache/error
Installing icons
mkdir /usr/local/apache/icons
mkdir /usr/local/apache/logs
Installing CGIs
mkdir /usr/local/apache/cgi-bin
Installing header files
mkdir /usr/local/apache/include
Installing build system files
mkdir /usr/local/apache/build
Installing man pages and online manual
mkdir /usr/local/apache/man
mkdir /usr/local/apache/man/man1
mkdir /usr/local/apache/man/man8
mkdir /usr/local/apache/manual
make[1]: Leaving directory `/root/httpd-2.4.4'

*自己编绎的在/etc/init.d下没有对应的httpd服务，所以要找到服务，当然可以自己创建到/etc/init.d
[root@PXE1 apache]# ls /etc/init.d/
abrtd     cpuspeed   halt        lvm2-monitor   network      sandbox    xinetd
acpid     dhcpd      ip6tables   mdmonitor      psacct       saslauthd
atd       dhcpd6     iptables    messagebus     rdisc        single
auditd    dhcrelay   irqbalance  microcode_ctl  restorecond  smartd
cgconfig  functions  kdump       netconsole     rhnsd        sshd
cgred     haldaemon  killall     netfs          rsyslog      udev-post
[root@PXE1 ~]# cd /usr/local/apache/
[root@PXE1 apache]# file bin/apachectl 
bin/apachectl: POSIX shell script text executable
[root@PXE1 apache]# 
[root@PXE1 apache]# bin/apachectl start
httpd (pid 5881) already running
[root@PXE1 apache]# 
[root@PXE1 apache]# netstat -tunl
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State      
tcp        0      0 0.0.0.0:22                  0.0.0.0:*                   LISTEN      
tcp        0      0 :::80                       :::*                        LISTEN      
tcp        0      0 :::22                       :::*                        LISTEN      
udp        0      0 0.0.0.0:69                  0.0.0.0:*                               
[root@PXE1 apache]# 
[root@PXE1 apache]# ls
bin  build  cgi-bin  error  htdocs  icons  include  logs  man  manual  modules
[root@PXE1 apache]# ls htdocs/
index.html
[root@PXE1 apache]# ls logs/
access_log  error_log  httpd.pid
[root@PXE1 apache]# ls /var/run/
abrt          auditd.pid   hald            netreport  setrans      xinetd.pid
abrtd.pid     console      haldaemon.pid   plymouth   sshd.pid
acpid.pid     ConsoleKit   lvm             pm-utils   sudo
acpid.socket  cron.reboot  mdadm           saslauthd  syslogd.pid
atd.pid       dbus         messagebus.pid  sepermit   utmp
[root@PXE1 apache]# vim /etc/httpd/httpd.conf 
PidFile "/var/run/httpd.pid"

*为了启动方便，我们在/etc/init.d下写脚本
*要实现这些功能，就要让进程显示在/var/run下面
[root@PXE1 logs]# cat httpd.pid 
5881
[root@PXE1 logs]# kill 5881
[root@PXE1 apache]# bin/apachectl start
[root@PXE1 apache]# ls logs/
access_log  error_log
[root@PXE1 apache]# ls /var/run/ | grep "^httpd"
httpd.pid
[root@PXE1 apache]# 
[root@PXE1 apache]# vim /etc/init.d/httpd
#!/bin/bash
#
# httpd        Startup script for the Apache HTTP Server
#
# chkconfig: - 85 15
# description: Apache is a World Wide Web server.  It is used to serve \
#	       HTML files and CGI.
# processname: httpd
# config: /etc/httpd/conf/httpd.conf
# config: /etc/sysconfig/httpd
# pidfile: /var/run/httpd.pid

# Source function library.
. /etc/rc.d/init.d/functions

if [ -f /etc/sysconfig/httpd ]; then
        . /etc/sysconfig/httpd
fi

# Start httpd in the C locale by default.
HTTPD_LANG=${HTTPD_LANG-"C"}

# This will prevent initlog from swallowing up a pass-phrase prompt if
# mod_ssl needs a pass-phrase from the user.
INITLOG_ARGS=""

# Set HTTPD=/usr/sbin/httpd.worker in /etc/sysconfig/httpd to use a server
# with the thread-based "worker" MPM; BE WARNED that some modules may not
# work correctly with a thread-based MPM; notably PHP will refuse to start.

# Path to the apachectl script, server binary, and short-form for messages.
apachectl=/usr/local/apache/bin/apachectl
httpd=${HTTPD-/usr/local/apache/bin/httpd}
prog=httpd
pidfile=${PIDFILE-/var/run/httpd.pid}
lockfile=${LOCKFILE-/var/lock/subsys/httpd}
RETVAL=0

start() {
        echo -n $"Starting $prog: "
        LANG=$HTTPD_LANG daemon --pidfile=${pidfile} $httpd $OPTIONS
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && touch ${lockfile}
        return $RETVAL
}

stop() {
	echo -n $"Stopping $prog: "
	killproc -p ${pidfile} -d 10 $httpd
	RETVAL=$?
	echo
	[ $RETVAL = 0 ] && rm -f ${lockfile} ${pidfile}
}
reload() {
    echo -n $"Reloading $prog: "
    if ! LANG=$HTTPD_LANG $httpd $OPTIONS -t >&/dev/null; then
        RETVAL=$?
        echo $"not reloading due to configuration syntax error"
        failure $"not reloading $httpd due to configuration syntax error"
    else
        killproc -p ${pidfile} $httpd -HUP
        RETVAL=$?
    fi
    echo
}

# See how we were called.
case "$1" in
  start)
	start
	;;
  stop)
	stop
	;;
  status)
        status -p ${pidfile} $httpd
	RETVAL=$?
	;;
  restart)
	stop
	start
	;;
  condrestart)
	if [ -f ${pidfile} ] ; then
		stop
		start
	fi
	;;
  reload)
        reload
	;;
  graceful|help|configtest|fullstatus)
	$apachectl $@
	RETVAL=$?
	;;
  *)
	echo $"Usage: $prog {start|stop|restart|condrestart|reload|status|fullstatus|graceful|help|configtest}"
	exit 1
esac

exit $RETVAL
[root@PXE1 apache]# chmod +x /etc/init.d/httpd
[root@PXE1 apache]# service httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@PXE1 apache]# chkconfig --add httpd
[root@PXE1 apache]# chkconfig --list httpd
httpd          	0:off	1:off	2:off	3:off	4:off	5:off	6:off
[root@PXE1 apache]# 
[root@PXE1 apache]# chkconfig --level 35 httpd on
[root@PXE1 apache]# chkconfig --list httpd
httpd          	0:off	1:off	2:off	3:on	4:off	5:on	6:off
[root@PXE1 apache]#vim /etc/profile.d/httpd.sh
export PATH=$PATH:/usr/local/apache/bin
[root@PXE1 ~]# echo $PATH
/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/apache/bin:/root/bin
[root@PXE1 ~]# httpd -t
Syntax OK
[root@PXE1 ~]# httpd -l
Compiled in modules:
  core.c
  mod_so.c
  http_core.c
[root@PXE1 ~]# httpd -M
Loaded Modules:
mpm_event_module (shared)
[root@PXE1 ~]# vim /etc/httpd/httpd.conf
#LoadModule mpm_event_module modules/mod_mpm_event.so
LoadModule mpm_prefork_module modules/mod_mpm_prefork.so
[root@PXE1 ~]# service httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@PXE1 ~]# httpd -M
Loaded Modules:
 mpm_prefork_module (shared)

***安装MySQL
[root@PXE1 ~]# tar -xf mysql-5.5.28-linux2.6-i686.tar.gz -C /usr/local
[root@PXE1 ~]# cd /usr/local/
[root@PXE1 local]# ls
apache  apr-util  etc    include  libexec                     sbin   src
apr     bin       games  lib      mysql-5.5.28-linux2.6-i686  share
*创链接好识别mysql的版本
[root@PXE1 local]# ln -sv mysql-5.5.28-linux2.6-i686/ mysql
`mysql' -> `mysql-5.5.28-linux2.6-i686/'
[root@PXE1 local]# 
[root@PXE1 local]# cd mysql
[root@PXE1 mysql]# ls
bin      data  include         lib  mysql-test  scripts  sql-bench
COPYING  docs  INSTALL-BINARY  man  README      share    support-files

*MySQL要为其创建专门的用户和组，-r指定为系统用户
[root@PXE1 mysql]# groupadd -r -g 306 mysql
[root@PXE1 mysql]# useradd -g 306 -r -u 306 mysql
[root@PXE1 mysql]# id mysql
uid=306(mysql) gid=306(mysql) groups=306(mysql)
[root@PXE1 home]# grep mysql /etc/passwd
mysql:x:306:306::/home/mysql:/bin/bash
[root@PXE1 mysql]# chown -R mysql.mysql /usr/local/mysql/*
[root@PXE1 mysql]# ll
total 76
drwxr-xr-x  2 mysql mysql  4096 May  1 12:37 bin
-rw-r--r--  1 mysql mysql 17987 Aug 29  2012 COPYING
drwxr-xr-x  4 mysql mysql  4096 May  1 12:37 data
drwxr-xr-x  2 mysql mysql  4096 May  1 12:37 docs
drwxr-xr-x  3 mysql mysql  4096 May  1 12:37 include
-rw-r--r--  1 mysql mysql  7604 Aug 29  2012 INSTALL-BINARY
drwxr-xr-x  3 mysql mysql  4096 May  1 12:37 lib
drwxr-xr-x  4 mysql mysql  4096 May  1 12:37 man
drwxr-xr-x 10 mysql mysql  4096 May  1 12:37 mysql-test
-rw-r--r--  1 mysql mysql  2552 Aug 29  2012 README
drwxr-xr-x  2 mysql mysql  4096 May  1 12:37 scripts
drwxr-xr-x 27 mysql mysql  4096 May  1 12:37 share
drwxr-xr-x  4 mysql mysql  4096 May  1 12:37 sql-bench
drwxr-xr-x  2 mysql mysql  4096 May  1 12:37 support-files
[root@PXE1 mysql]# 

*这是mysql的初始化脚本，编绎的MySQL，在应用前要手动执行，rpm包自动执行
[root@PXE1 mysql]# ls scripts/
mysql_install_db
[root@PXE1 mysql]# 

*编绎的通用二进制mysql默认状态下数据放在了安装目录下的data/下面，这个不合适
*为数据库单独创一个逻辑卷
Command (m for help): p

Disk /dev/sda: 119.2 GB, 119185342464 bytes
255 heads, 63 sectors/track, 14490 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x00068e8b

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1          26      204800   83  Linux
Partition 1 does not end on cylinder boundary.
/dev/sda2              26        1301    10240000   83  Linux
/dev/sda3            1301        1431     1048576   82  Linux swap / Solaris
/dev/sda4            1431       14490   104896525    5  Extended
/dev/sda5            1431        4042    20972933+  8e  Linux LVM
[root@PXE1 ~]# partx -a /dev/sda
[root@PXE1 ~]# partx -l /dev/sda
# 1:      2048-   411647 (   409600 sectors,    209 MB)
# 2:    411648- 20891647 ( 20480000 sectors,  10485 MB)
# 3:  20891648- 22988799 (  2097152 sectors,   1073 MB)
# 4:  22988800-232781849 (209793050 sectors, 107414 MB)
# 5:  22988863- 64934729 ( 41945867 sectors,  21476 MB)
[root@PXE1 ~]# pvcreate /dev/sda5
  Physical volume "/dev/sda5" successfully created
[root@PXE1 ~]# vgcreate myvg /dev/sda5
  Volume group "myvg" successfully created
[root@PXE1 ~]# lvcreate -n mydata -L 5G myvg
  Logical volume "mydata" created
[root@PXE1 ~]# 
[root@PXE1 ~]# mke2fs -j /dev/myvg/mydata 
[root@PXE1 ~]# mkdir /mydata
[root@PXE1 ~]# vim /etc/fstab
/dev/myvg/mydata        /mydata                 ext3    defaults        0 0
[root@PXE1 ~]# mount -a
[root@PXE1 ~]# mount
/dev/sda2 on / type ext4 (rw)
proc on /proc type proc (rw)
sysfs on /sys type sysfs (rw)
devpts on /dev/pts type devpts (rw,gid=5,mode=620)
tmpfs on /dev/shm type tmpfs (rw)
/dev/sda1 on /boot type ext4 (rw)
none on /proc/sys/fs/binfmt_misc type binfmt_misc (rw)
/dev/sr0 on /mnt type iso9660 (ro)
/dev/mapper/myvg-mydata on /mydata type ext3 (rw)
[root@PXE1 ~]# mkdir /mydata/data
[root@PXE1 ~]# ll /mydata/
total 20
drwxr-xr-x 2 root root  4096 May  1 14:46 data
drwx------ 2 root root 16384 May  1 14:42 lost+found
[root@PXE1 ~]# chown -R mysql.mysql /mydata/data/
[root@PXE1 ~]# ll /mydata
total 20
drwxr-xr-x 2 mysql mysql  4096 May  1 14:46 data
drwx------ 2 root  root  16384 May  1 14:42 lost+found
[root@PXE1 ~]# chmod o-rx /mydata/data/
[root@PXE1 ~]# ll /mydata
total 20
drwxr-x--- 2 mysql mysql  4096 May  1 14:46 data
drwx------ 2 root  root  16384 May  1 14:42 lost+found
[root@PXE1 ~]# cd /usr/local/mysql
[root@PXE1 mysql]# scripts/mysql_install_db --user=mysql --datadir=/mydata/data/

*刚才为了数据初始化，属主改成了mysql，为了安全重新改回root
*注意，mysql要写数据一定要有写的权限，我们专门改变了数据保存的路径并给了权限
[root@PXE1 mysql]# chown -R root /usr/local/mysql/*
[root@PXE1 mysql]# ll
total 76
drwxr-xr-x  2 root mysql  4096 May  1 12:37 bin
-rw-r--r--  1 root mysql 17987 Aug 29  2012 COPYING
drwxr-xr-x  4 root mysql  4096 May  1 12:37 data
drwxr-xr-x  2 root mysql  4096 May  1 12:37 docs
drwxr-xr-x  3 root mysql  4096 May  1 12:37 include
-rw-r--r--  1 root mysql  7604 Aug 29  2012 INSTALL-BINARY
drwxr-xr-x  3 root mysql  4096 May  1 12:37 lib
drwxr-xr-x  4 root mysql  4096 May  1 12:37 man
drwxr-xr-x 10 root mysql  4096 May  1 12:37 mysql-test
-rw-r--r--  1 root mysql  2552 Aug 29  2012 README
drwxr-xr-x  2 root mysql  4096 May  1 12:37 scripts
drwxr-xr-x 27 root mysql  4096 May  1 12:37 share
drwxr-xr-x  4 root mysql  4096 May  1 12:37 sql-bench
drwxr-xr-x  2 root mysql  4096 May  1 12:37 support-files
[root@PXE1 mysql]# cp support-files/mysql.server /etc/init.d/mysqld
[root@PXE1 mysql]# ls -l /etc/init.d/mysqld 
-rwxr-xr-x 1 root root 10650 May  1 14:58 /etc/init.d/mysqld
[root@PXE1 mysql]# chkconfig --add mysqld
[root@PXE1 mysql]# chkconfig --list mysqld
mysqld         	0:off	1:off	2:on	3:on	4:on	5:on	6:off
[root@PXE1 mysql]# 

*配置mysql的配置文件，其配置文件非常特殊，有多个片文件，查找路径是/etc/my.cnf-->/etc/mysql/my.cnf-->$BASEDIR/my.cnf-->~/.my.cnf
[root@PXE1 mysql]# ls support-files/
binary-configure   magic                   my-medium.cnf        mysql.server
config.huge.ini    my-huge.cnf             my-small.cnf         ndb-config-2-node.ini
config.medium.ini  my-innodb-heavy-4G.cnf  mysqld_multi.server
config.small.ini   my-large.cnf            mysql-log-rotate
[root@PXE1 mysql]# cp support-files/my-large.cnf /etc/my.cnf

*添加一项
[root@PXE1 mysql]# vim /etc/my.cnf 
datadir=/mydata/data
[root@PXE1 mysql]# service mysqld start
Starting MySQL.... SUCCESS! 
[root@PXE1 mysql]# netstat -tuln 
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State      
tcp        0      0 0.0.0.0:3306                0.0.0.0:*                   LISTEN      
tcp        0      0 0.0.0.0:22                  0.0.0.0:*                   LISTEN      
tcp        0      0 :::80                       :::*                        LISTEN      
tcp        0      0 :::22                       :::*                        LISTEN      
udp        0      0 0.0.0.0:69                  0.0.0.0:*                        
[root@PXE1 mysql]# vim /etc/profile.d/mysql.sh
export PATH=$PATH:/usr/local/mysql/bin
[root@PXE1 ~]# mysql
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 1
Server version: 5.5.28-log MySQL Community Server (GPL)

Copyright (c) 2000, 2012, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
mysql> SHOW VARIABLES LIKE 'datadir';
+---------------+---------------+
| Variable_name | Value         |
+---------------+---------------+
| datadir       | /mydata/data/ |
+---------------+---------------+
1 row in set (0.00 sec)

mysql> 
[root@PXE1 mysql]# vim /etc/man.config
MANPATH /usr/local/mysql/man
[root@PXE1 mysql]# vim /etc/ld.so.conf.d/mysql.conf
/usr/local/mysql/lib
*重读库文件，为了缓存在/etc/ld.so.cache
[root@PXE1 mysql]# ldconfig -v
[root@PXE1 mysql]# ls -l /etc/ld.so.cache 
-rw-r--r-- 1 root root 28810 May  1 15:31 /etc/ld.so.cache
[root@PXE1 mysql]# ln -sv /usr/local//mysql/include/ /usr/include/mysql
`/usr/include/mysql' -> `/usr/local//mysql/include/'
[root@PXE1 mysql]# ls /usr/include/mysql/
decimal.h   my_alloc.h      my_dir.h     my_pthread.h     mysql_embed.h    my_xml.h           sql_state.h
errmsg.h    my_attribute.h  my_getopt.h  mysql            mysql.h          plugin_audit.h     sslopt-case.h
keycache.h  my_compiler.h   my_global.h  mysql_com.h      mysql_time.h     plugin_ftparser.h  sslopt-longopts.h
m_ctype.h   my_config.h     my_list.h    mysqld_ername.h  mysql_version.h  plugin.h           sslopt-vars.h
m_string.h  my_dbug.h       my_net.h     mysqld_error.h   my_sys.h         sql_common.h       typelib.h
[root@PXE1 mysql]# 

***编绎安装PHP
[root@PXE1 php-5.5.35]# tar xf php-5.5.35.tar.bz2
[root@PXE1 php-5.5.35]# cd php-5.5.35
[root@PXE1 php-5.5.35]# yum install libxml2-devel
[root@PXE1 php-5.5.35]# yum install bzip2-devel -y
[root@PXE1 php-5.5.35]# ./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --with-openssl --with-mysqli=/usr/local/mysql/bin/mysql_config --enable-mbstring --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml  --enable-sockets --with-apxs2=/usr/local/apache/bin/apxs --with-mcrypt  --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-bz2  --enable-maintainer-zts
configure: error: mcrypt.h not found. Please reinstall libmcrypt.
[root@PXE1 ~]# rpm -ivh mhash-0.9.9.9-1.rhel6.i686.rpm mhash-devel-0.9.9.9-1.rhel6.i686.rpm libmcrypt-2.5.8-9.el6.i686.rpm libmcrypt-devel-2.5.8-9.el6.i686.rpm 
[root@PXE1 php-5.5.35]# ./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --with-openssl --with-mysqli=/usr/local/mysql/bin/mysql_config --enable-mbstring --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml  --enable-sockets --with-apxs2=/usr/local/apache/bin/apxs --with-mcrypt  --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-bz2  --enable-maintainer-zts
[root@PXE1 php-5.5.35]# make

*根据下面的安装信息可知，模块化安装会集成于apache当中
[root@PXE1 php-5.5.35]# make install
/bin/sh /root/php-5.5.35/libtool --silent --preserve-dup-deps --mode=install cp ext/opcache/opcache.la /root/php-5.5.35/modules
Installing PHP SAPI module:       apache2handler
/usr/local/apache/build/instdso.sh SH_LIBTOOL='/usr/local/apr/build-1/libtool' libphp5.la /usr/local/apache/modules
/usr/local/apr/build-1/libtool --mode=install install libphp5.la /usr/local/apache/modules/
libtool: install: install .libs/libphp5.so /usr/local/apache/modules/libphp5.so
libtool: install: install .libs/libphp5.lai /usr/local/apache/modules/libphp5.la
libtool: install: warning: remember to run `libtool --finish /root/php-5.5.35/libs'
chmod 755 /usr/local/apache/modules/libphp5.so
[activating module `php5' in /etc/httpd/httpd.conf]
Installing shared extensions:     /usr/local/php/lib/php/extensions/no-debug-zts-20121212/
Installing PHP CLI binary:        /usr/local/php/bin/
Installing PHP CLI man page:      /usr/local/php/php/man/man1/
Installing PHP CGI binary:        /usr/local/php/bin/
Installing PHP CGI man page:      /usr/local/php/php/man/man1/
Installing build environment:     /usr/local/php/lib/php/build/
Installing header files:          /usr/local/php/include/php/
Installing helper programs:       /usr/local/php/bin/
  program: phpize
  program: php-config
Installing man pages:             /usr/local/php/php/man/man1/
  page: phpize.1
  page: php-config.1
Installing PEAR environment:      /usr/local/php/lib/php/
[PEAR] Archive_Tar    - already installed: 1.4.0
[PEAR] Console_Getopt - already installed: 1.4.1
[PEAR] Structures_Graph- already installed: 1.1.1
[PEAR] XML_Util       - already installed: 1.3.0
[PEAR] PEAR           - already installed: 1.10.1
Wrote PEAR system config file at: /usr/local/php/etc/pear.conf
You may want to add: /usr/local/php/lib/php to your php.ini include_path
/root/php-5.5.35/build/shtool install -c ext/phar/phar.phar /usr/local/php/bin
ln -s -f phar.phar /usr/local/php/bin/phar
Installing PDO headers:          /usr/local/php/include/php/ext/pdo/
[root@PXE1 php-5.5.35]# 

*php编绎的配置文件特殊，在编绎目录下有两个php.ini-development、php.ini-production分别对应开发和生产应用
*这里将php.ini-production复制至/etc目录下，因为编绎的时候指定的是/etc目录下，系统会去/etc/下面找配置文件
[root@PXE1 php-5.5.35]# cp php.ini-production /etc/php.ini

*要让apache能够理解php结尾的页面文件，并测试php与apache连通
[root@PXE1 php-5.5.35]# vim /etc/httpd/httpd.conf
加两行
AddType application/x-httpd-php .php
AddType application/x-httpd-php-source .phps
[root@PXE1 php-5.5.35]# httpd -t
Syntax OK
[root@PXE1 php-5.5.35]# service httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@PXE1 php-5.5.35]# cd /usr/local/apache/htdocs/
[root@PXE1 htdocs]# ls
index.html
[root@PXE1 htdocs]# mv index.html index.php
[root@PXE1 htdocs]# vim index.php 
<html><body><h1>It really works!</h1></body></html>
<?php
phpinfo();
?>

*测试php跟mysql连通
[root@PXE1 htdocs]# vim index.php
<html><body><h1>It really works!</h1></body></html>
<?php
        $conn=mysql_connect('localhost','root','');
                if ($conn)
                        echo "connection succeed!!!";
                else
                        echo "connection failed!!!";
?>


***安装php加速器，xcache，在编绎前要执行php扩展命令，一定按顺序才能安装
[root@PXE1 xcache-3.0.0]# man -M /usr/local/php/php/man/ phpize
[root@PXE1 ~]# tar xf xcache-3.2.0.tar.bz2 
[root@PXE1 ~]# cd xcache-3.2.0
*没有configure脚本
[root@PXE1 xcache-3.2.0]# ls
admin                          encoder.c          prepare.devel.inc
align.h                        foreachcoresig.h   prepare.devel.inc.example
assembler.c                    graph              processor
AUTHORS                        includes.c         processor.c
ChangeLog                      INSTALL            README
config.m4                      lock.c             run-xcachetest
config.w32                     lock.h             stack.c
const_string.c                 Makefile.frag      stack.h
const_string.h                 mem.c              test.mak
const_string_opcodes_php4.x.h  mem.h              tests
const_string_opcodes_php5.0.h  mkopcode.awk       THANKS
const_string_opcodes_php5.1.h  mkopcode_spec.awk  utils.c
const_string_opcodes_php5.4.h  mkstructinfo.awk   utils.h
const_string_opcodes_php6.x.h  mmap.c             xcache.c
COPYING                        NEWS               xcache_globals.h
coverager                      opcode_spec.c      xcache.h
coverager.c                    opcode_spec_def.h  xcache.ini
coverager.h                    opcode_spec.h      xcache-test.ini
decoder.c                      optimizer.c        xcache-zh-gb2312.ini
Decompiler.class.php           optimizer.h        xc_malloc.c
decompilesample.php            phpdc.phpr         xc_shm.c
disassembler.c                 phpdop.phpr        xc_shm.h
disassembler.h                 prepare.devel

*在编绎目录下执行php的phpize扩展命令才会有configure脚本 
[root@PXE1 xcache-3.2.0]# /usr/local/php/bin/phpize 
Configuring for:
PHP Api Version:         20121113
Zend Module Api No:      20121212
Zend Extension Api No:   220121212
[root@PXE1 xcache-3.2.0]# 
[root@PXE1 xcache-3.2.0]# ./configure --enable-xcache --with-php-config=/usr/local/php/bin/php-config
[root@PXE1 xcache-3.2.0]# make
[root@PXE1 xcache-3.2.0]# make install
Installing shared extensions:     /usr/local/php/lib/php/extensions/no-debug-zts-20121212/

*要将编绎目录下xcache.ini配置文件追加至php.ini配置文件中，或者是新建一个目录/etc/php.d/然后复制进去
[root@PXE1 xcache-3.2.0]# mkdir /etc/php.d
[root@PXE1 xcache-3.2.0]# cp xcache.ini /etc/php.d/

*xcache以前的版本2.x是需要在下面片文件中指出上面的Install shared extensions路径的，但是这里的3.x可以自动查找
[root@PXE1 xcache-3.2.0]# vim /etc/php.d/xcache.ini 
[xcache-common]
;; non-Windows example:
extension = xcache.so
;; Windows example:
; extension = php_xcache.dll

***配置虚拟主机（前面介绍过2.4以上的版本有很多新特性，虚拟主机有不小变化）
*注释中心主机启用虚拟主机
[root@PXE1 ~]# vim /etc/httpd/httpd.conf
#DocumentRoot "/usr/local/apache/htdocs"
Include /etc/httpd/extra/httpd-vhosts.conf
[root@PXE1 httpd]# cd /etc/httpd/extra/
[root@PXE1 extra]# ls
httpd-autoindex.conf  httpd-languages.conf           httpd-ssl.conf
httpd-dav.conf        httpd-manual.conf              httpd-userdir.conf
httpd-default.conf    httpd-mpm.conf                 httpd-vhosts.conf
httpd-info.conf       httpd-multilang-errordoc.conf  proxy-html.conf
[root@PXE1 extra]# vim httpd-vhosts.conf 
到主配置文件中启用这个模块
Required modules: mod_log_config
<VirtualHost *:80>
    ServerName www.a.org
    DocumentRoot "/www/a.org"
    ErrorLog "/var/log/httpd/a.org-error_log"
    CustomLog "/var/log/httpd/a.org-access_log" combined
</VirtualHost>

<VirtualHost *:80>
    ServerName www.b.net
    DocumentRoot "/www/b.net"
    ErrorLog "/var/log/httpd/b.net-error_log"
    CustomLog "/var/log/httpd/b.net-access_log" common
</VirtualHost>
[root@PXE1 extra]# mkdir /www/{a.org,b.net} -pv
mkdir: created directory `/www'
mkdir: created directory `/www/a.org'
mkdir: created directory `/www/b.net'
[root@PXE1 extra]# httpd -t
Syntax OK
[root@PXE1 extra]# service httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]
[root@PXE1 extra]# tail /var/log/httpd/a.org-
a.org-access_log  a.org-error_log   
[root@PXE1 extra]# tail /var/log/httpd/a.org-error_log 
[root@PXE1 extra]# 
[root@PXE1 extra]# echo "<h1>www.a.org</h1>" > /www/a.org/index.html
[root@PXE1 extra]# echo "<h1>www.b.net</h1>" > /www/b.net/index.html

*httpd2.4以上的版本安全性比较高，默认情况下不让访问，要加控制列表
[root@PXE1 extra]# vim /etc/httpd/extra/httpd-vhosts.conf
<VirtualHost *:80>
    ServerName www.a.org
    DocumentRoot "/www/a.org"
    ErrorLog "/var/log/httpd/a.org-error_log"
    CustomLog "/var/log/httpd/a.org-access_log" combined
        <Directory "/www/a.org">
            Options none
            AllowOverride none
            Require all granted
        </Directory>
</VirtualHost>
<VirtualHost *:80>
    ServerName www.b.net
    DocumentRoot "/www/b.net"
    ErrorLog "/var/log/httpd/b.net-error_log"
    CustomLog "/var/log/httpd/b.net-access_log" common
        <Directory "/www/b.net">
            Options none
            AllowOverride none
            Require all granted
        </Directory>
</VirtualHost>
[root@PXE1 extra]# httpd -t
Syntax OK
[root@PXE1 extra]# service httpd restart
Stopping httpd:                                            [  OK  ]
Starting httpd:                                            [  OK  ]

***压力测试，ab命令
*注意格式，指定到哪个页面
[root@PXE1 extra]# ab -c 100 -n 1000 http://www.a.org/index.html
其中-n代表请求数，-c代表并发数，数据大一些在这里精确一点
返回结果:
##首先是apache的版本信息 
This is ApacheBench, Version 2.3 <$Revision: 655654 $> 
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/ 
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking vm1.jianfeng.com (be patient)


Server Software:        Apache/2.4.4						##apache版本 
Server Hostname:        www.a.org						##请求的机子 
Server Port:            80 ##请求端口

Document Path:          /index.html 
Document Length:        25 bytes						##页面长度

Concurrency Level:      100							##并发数 
Time taken for tests:   0.273 seconds						##共使用了多少时间 
Complete requests:      1000							##请求数 
Failed requests:        0							##失败请求 
Write errors:           0   
Total transferred:      275000 bytes						##总共传输字节数，包含http的头信息等 
HTML transferred:       25000 bytes						##html字节数，实际的页面传递字节数 
Requests per second:    3661.60 [#/sec] (mean)					##每秒多少请求，这个是非常重要的参数数值，服务器的吞吐量 
Time per request:       27.310 [ms] (mean)					##所有请求完成，平均每批请求用到的时间 
Time per request:       0.273 [ms] (mean, across all concurrent requests)	##所有请求完成，平均每个请求用到的时间 
Transfer rate:          983.34 [Kbytes/sec] received				##每秒接受到的字节

Connection Times (ms) 
              min  mean[+/-sd] median   max 
Connect:        0    1   2.3      0      16 
Processing:     6   25   3.2     25      32 
Waiting:        5   24   3.2     25      32 
Total:          6   25   4.0     25      48

Percentage of the requests served within a certain time (ms) 
  50%     25									## 50%的请求在25ms内返回 
  66%     26									## 60%的请求在26ms内返回 
  75%     26 
  80%     26 
  90%     27 
  95%     31 
  98%     38 
  99%     43 
100%     48 (longest request)

*linux默认只允许并发小于1000个，用ulimit改成10000，-r忽略错误
[root@PXE1 extra]# ulimit -n 10000
[root@PXE1 extra]# ab -r -c 2000 -n 50000 http://www.a.org/index.html
This is ApacheBench, Version 2.3 <$Revision: 655654 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking www.a.org (be patient)
Completed 5000 requests
Completed 10000 requests
Completed 15000 requests
Completed 20000 requests
Completed 25000 requests
Completed 30000 requests
Completed 35000 requests
Completed 40000 requests
Completed 45000 requests
Completed 50000 requests
Finished 50000 requests


Server Software:        Apache/2.4.4
Server Hostname:        www.a.org
Server Port:            80

Document Path:          /index.html
Document Length:        19 bytes

Concurrency Level:      2000
Time taken for tests:   17.451 seconds
Complete requests:      50000
Failed requests:        7
   (Connect: 0, Receive: 0, Length: 7, Exceptions: 0)
Write errors:           0
Non-2xx responses:      7
Total transferred:      13676278 bytes
HTML transferred:       953118 bytes
Requests per second:    2865.16 [#/sec] (mean)
Time per request:       698.042 [ms] (mean)
Time per request:       0.349 [ms] (mean, across all concurrent requests)
Transfer rate:          765.33 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0  356 1152.9     91   10300
Processing:    25  225 306.9     86    2706
Waiting:        1  189 294.6     63    2658
Total:         68  580 1254.7    238   10615

Percentage of the requests served within a certain time (ms)
  50%    238
  66%    523
  75%    551
  80%    613
  90%    924
  95%   1665
  98%   3336
  99%  10521
 100%  10615 (longest request)
[root@PXE1 extra]# 

*实际上页面的大小也影响求请效果，这个测试的页面很小，换一个试试
[root@PXE1 extra]# cd /www/a.org/
[root@PXE1 a.org]# ll
total 4
-rw-r--r-- 1 root root 19 May  2 17:36 index.html
[root@PXE1 a.org]# cp /var/log/lastlog /www/a.org/test.html
[root@PXE1 a.org]# ll -l /www/a.org/test.html 
-rw-r--r-- 1 root root 146292 May  2 19:31 /www/a.org/test.html

*效果很明显
[root@PXE1 a.org]# ab -r -c 2000 -n 50000 http://www.a.org/test.html
This is ApacheBench, Version 2.3 <$Revision: 655654 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking www.a.org (be patient)
Completed 5000 requests
Completed 10000 requests
Completed 15000 requests
Completed 20000 requests
Completed 25000 requests
Completed 30000 requests
Completed 35000 requests
Completed 40000 requests
Completed 45000 requests
Completed 50000 requests
Finished 50000 requests


Server Software:        Apache/2.4.4
Server Hostname:        www.a.org
Server Port:            80

Document Path:          /test.html
Document Length:        146292 bytes

Concurrency Level:      2000
Time taken for tests:   38.547 seconds
Complete requests:      50000
Failed requests:        0
Write errors:           0
Total transferred:      7347874314 bytes
HTML transferred:       7334788296 bytes
Requests per second:    1297.13 [#/sec] (mean)
Time per request:       1541.863 [ms] (mean)
Time per request:       0.771 [ms] (mean, across all concurrent requests)
Transfer rate:          186155.49 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        6  289 958.2     93    9097
Processing:   219 1247 1010.3   1020   12661
Waiting:        3  186 502.4     76    8748
Total:        282 1536 1708.1   1136   16238

Percentage of the requests served within a certain time (ms)
  50%   1136
  66%   1316
  75%   1457
  80%   1554
  90%   2056
  95%   4141
  98%   7390
  99%   8764
 100%  16238 (longest request)
[root@PXE1 a.org]# 

***为编绎安装的httpd实现加密ssl，首先在主配置文件中启用两项
[root@PXE1 ~]# vim /etc/httpd/httpd.conf
Include /etc/httpd/extra/httpd-ssl.conf
LoadModule ssl_module modules/mod_ssl.so
[root@PXE1 ~]# vim /etc/httpd/extra/httpd-ssl.conf
*和前面配置的https过程是一样的，回顾



httpd 2.4.4 + mysql-5.5.28 + php-5.4.13编译安装过程：

一、编译安装apache

1、解决依赖关系

httpd-2.4.4需要较新版本的apr和apr-util，因此需要事先对其进行升级。升级方式有两种，一种是通过源代码编译安装，一种是直接升级rpm包。这里选择使用编译源代码的方式进行，它们的下载路径为ftp://172.16.0.1/pub/Sources/new_lamp。

(1) 编译安装apr

# tar xf apr-1.4.6.tar.bz2
# cd apr-1.4.6
# ./configure --prefix=/usr/local/apr
# make && make install

(2) 编译安装apr-util

# tar xf apr-util-1.5.2.tar.bz2
# cd apr-util-1.5.2
# ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr
# make && make install

附：apache官方对APR的介绍：

The mission of the Apache Portable Runtime (APR) project is to create and maintain software libraries that provide a predictable and consistent interface to underlying platform-specific implementations. The primary goal is to provide an API to which software developers may code and be assured of predictable if not identical behaviour regardless of the platform on which their software is built, relieving them of the need to code special-case conditions to work around or take advantage of platform-specific deficiencies or features.

(3) httpd-2.4.4编译过程也要依赖于pcre-devel软件包，需要事先安装。此软件包系统光盘自带，因此，找到并安装即可。

2、编译安装httpd-2.4.4

首先下载httpd-2.4.4到本地，下载路径为ftp://172.16.0.1/pub/Sources/new_lamp。而后执行如下命令进行编译安装过程：

# tar xf httpd-2.4.4.tar.bz2
# cd httpd-2.4.4
# ./configure --prefix=/usr/local/apache --sysconfdir=/etc/httpd --enable-so --enable-ssl --enable-cgi --enable-rewrite 
--with-zlib --with-pcre --with-apr=/usr/local/apr --with-apr-util=/usr/local/apr-util --enable-modules=most 
--enable-mpms-shared=all --with-mpm=event
# make && make install


补充：

（1）构建MPM为静态模块
在全部平台中，MPM都可以构建为静态模块。在构建时选择一种MPM，链接到服务器中。如果要改变MPM，必须重新构建。为了使用指定的MPM，请在执行configure脚本 时，使用参数 --with-mpm=NAME。NAME是指定的MPM名称。编译完成后，可以使用 ./httpd -l 来确定选择的MPM。 此命令会列出编译到服务器程序中的所有模块，包括 MPM。

（2）构建 MPM 为动态模块

在Unix或类似平台中，MPM可以构建为动态模块，与其它动态模块一样在运行时加载。 构建 MPM 为动态模块允许通过修改LoadModule指令内容来改变MPM，而不用重新构建服务器程序。在执行configure脚本时，使用--enable-mpms-shared选项即可启用此特性。当给出的参数为all时，所有此平台支持的MPM模块都会被安装。还可以在参数中给出模块列表。默认MPM，可以自动选择或者在执行configure脚本时通过--with-mpm选项来指定，然后出现在生成的服务器配置文件中。编辑LoadModule指令内容可以选择不同的MPM。


3、修改httpd的主配置文件，设置其Pid文件的路径

编辑/etc/httpd/httpd.conf，添加如下行即可：
PidFile  "/var/run/httpd.pid"

4、提供SysV服务脚本/etc/rc.d/init.d/httpd，内容如下：

#!/bin/bash
#
# httpd        Startup script for the Apache HTTP Server
#
# chkconfig: - 85 15
# description: Apache is a World Wide Web server.  It is used to serve \
#	       HTML files and CGI.
# processname: httpd
# config: /etc/httpd/conf/httpd.conf
# config: /etc/sysconfig/httpd
# pidfile: /var/run/httpd.pid

# Source function library.
. /etc/rc.d/init.d/functions

if [ -f /etc/sysconfig/httpd ]; then
        . /etc/sysconfig/httpd
fi

# Start httpd in the C locale by default.
HTTPD_LANG=${HTTPD_LANG-"C"}

# This will prevent initlog from swallowing up a pass-phrase prompt if
# mod_ssl needs a pass-phrase from the user.
INITLOG_ARGS=""

# Set HTTPD=/usr/sbin/httpd.worker in /etc/sysconfig/httpd to use a server
# with the thread-based "worker" MPM; BE WARNED that some modules may not
# work correctly with a thread-based MPM; notably PHP will refuse to start.

# Path to the apachectl script, server binary, and short-form for messages.
apachectl=/usr/local/apache/bin/apachectl
httpd=${HTTPD-/usr/local/apache/bin/httpd}
prog=httpd
pidfile=${PIDFILE-/var/run/httpd.pid}
lockfile=${LOCKFILE-/var/lock/subsys/httpd}
RETVAL=0

start() {
        echo -n $"Starting $prog: "
        LANG=$HTTPD_LANG daemon --pidfile=${pidfile} $httpd $OPTIONS
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && touch ${lockfile}
        return $RETVAL
}

stop() {
	echo -n $"Stopping $prog: "
	killproc -p ${pidfile} -d 10 $httpd
	RETVAL=$?
	echo
	[ $RETVAL = 0 ] && rm -f ${lockfile} ${pidfile}
}
reload() {
    echo -n $"Reloading $prog: "
    if ! LANG=$HTTPD_LANG $httpd $OPTIONS -t >&/dev/null; then
        RETVAL=$?
        echo $"not reloading due to configuration syntax error"
        failure $"not reloading $httpd due to configuration syntax error"
    else
        killproc -p ${pidfile} $httpd -HUP
        RETVAL=$?
    fi
    echo
}

# See how we were called.
case "$1" in
  start)
	start
	;;
  stop)
	stop
	;;
  status)
        status -p ${pidfile} $httpd
	RETVAL=$?
	;;
  restart)
	stop
	start
	;;
  condrestart)
	if [ -f ${pidfile} ] ; then
		stop
		start
	fi
	;;
  reload)
        reload
	;;
  graceful|help|configtest|fullstatus)
	$apachectl $@
	RETVAL=$?
	;;
  *)
	echo $"Usage: $prog {start|stop|restart|condrestart|reload|status|fullstatus|graceful|help|configtest}"
	exit 1
esac

exit $RETVAL

而后为此脚本赋予执行权限：
# chmod +x /etc/rc.d/init.d/httpd

加入服务列表：
# chkconfig --add httpd


接下来就可以启动服务进行测试了。


二、安装mysql-5.5.28

1、准备数据存放的文件系统

新建一个逻辑卷，并将其挂载至特定目录即可。这里不再给出过程。

这里假设其逻辑卷的挂载目录为/mydata，而后需要创建/mydata/data目录做为mysql数据的存放目录。

2、新建用户以安全方式运行进程：

# groupadd -r mysql
# useradd -g mysql -r -s /sbin/nologin -M -d /mydata/data mysql
# chown -R mysql:mysql /mydata/data

3、安装并初始化mysql-5.5.28

首先下载平台对应的mysql版本至本地，这里是32位平台，因此，选择的为mysql-5.5.28-linux2.6-i686.tar.gz，其下载位置为ftp://172.16.0.1/pub/Sources/mysql-5.5。

# tar xf mysql-5.5.28-linux2.6-i686.tar.gz -C /usr/local
# cd /usr/local/
# ln -sv mysql-5.5.28-linux2.6-i686  mysql
# cd mysql 

# chown -R mysql:mysql  .
# scripts/mysql_install_db --user=mysql --datadir=/mydata/data
# chown -R root  .

4、为mysql提供主配置文件：

# cd /usr/local/mysql
# cp support-files/my-large.cnf  /etc/my.cnf

并修改此文件中thread_concurrency的值为你的CPU个数乘以2，比如这里使用如下行：
thread_concurrency = 2

另外还需要添加如下行指定mysql数据文件的存放位置：
datadir = /mydata/data


5、为mysql提供sysv服务脚本：

# cd /usr/local/mysql
# cp support-files/mysql.server  /etc/rc.d/init.d/mysqld
# chmod +x /etc/rc.d/init.d/mysqld

添加至服务列表：
# chkconfig --add mysqld
# chkconfig mysqld on

而后就可以启动服务测试使用了。


为了使用mysql的安装符合系统使用规范，并将其开发组件导出给系统使用，这里还需要进行如下步骤：
6、输出mysql的man手册至man命令的查找路径：

编辑/etc/man.config，添加如下行即可：
MANPATH  /usr/local/mysql/man

7、输出mysql的头文件至系统头文件路径/usr/include：

这可以通过简单的创建链接实现：
# ln -sv /usr/local/mysql/include  /usr/include/mysql

8、输出mysql的库文件给系统库查找路径：

# echo '/usr/local/mysql/lib' > /etc/ld.so.conf.d/mysql.conf

而后让系统重新载入系统库：
# ldconfig

9、修改PATH环境变量，让系统可以直接使用mysql的相关命令。具体实现过程这里不再给出。

10、pid默认路径在/tmp下，如果要修改，注意mysqld跟my.cnf一致，并且要给自定义的pid路径赋予mysql属主权限

三、编译安装php-5.4.13

1、解决依赖关系：

请配置好yum源（可以是本地系统光盘）后执行如下命令：
# yum -y groupinstall "X Software Development" 

如果想让编译的php支持mcrypt扩展，此处还需要下载ftp://172.16.0.1/pub/Sources/ngnix目录中的如下两个rpm包并安装之：
libmcrypt-2.5.7-5.el5.i386.rpm
libmcrypt-devel-2.5.7-5.el5.i386.rpm

2、编译安装php-5.4.13

首先下载源码包至本地目录，下载位置ftp://172.16.0.1/pub/Sources/new_lamp。

# tar xf php-5.4.13.tar.bz2
# cd php-5.4.13
# ./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --with-openssl --with-mysqli=/usr/local/mysql/bin/mysql_config 
--enable-mbstring --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml  --enable-sockets 
--with-apxs2=/usr/local/apache/bin/apxs --with-mcrypt  --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-bz2  
--enable-maintainer-zts


说明：
1、这里为了支持apache的worker或event这两个MPM，编译时使用了--enable-maintainer-zts选项。
2、如果使用PHP5.3以上版本，为了链接MySQL数据库，可以指定mysqlnd，这样在本机就不需要先安装MySQL或MySQL开发包了。mysqlnd从php 5.3开始可用，可以编译时绑定到它（而不用和具体的MySQL客户端库绑定形成依赖），但从PHP 5.4开始它就是默认设置了。
# ./configure --with-mysql=mysqlnd --with-pdo-mysql=mysqlnd --with-mysqli=mysqlnd

# make
# make test
# make intall

为php提供配置文件：
# cp php.ini-production /etc/php.ini

3、 编辑apache配置文件httpd.conf，以apache支持php
 
 # vim /etc/httpd/httpd.conf
 1、添加如下二行
   AddType application/x-httpd-php  .php
   AddType application/x-httpd-php-source  .phps

 2、定位至DirectoryIndex index.html 
   修改为：
    DirectoryIndex  index.php  index.html

而后重新启动httpd，或让其重新载入配置文件即可测试php是否已经可以正常使用。

四、安装xcache，为php加速：

1、安装
# tar xf xcache-3.0.1.tar.gz
# cd xcache-3.0.1
# /usr/local/php/bin/phpize
# ./configure --enable-xcache --with-php-config=/usr/local/php/bin/php-config
# make && make install

安装结束时，会出现类似如下行：
Installing shared extensions:     /usr/local/php/lib/php/extensions/no-debug-zts-20100525/

2、编辑php.ini，整合php和xcache：

首先将xcache提供的样例配置导入php.ini
# mkdir /etc/php.d
# cp xcache.ini /etc/php.d

说明：xcache.ini文件在xcache的源码目录中。

接下来编辑/etc/php.d/xcache.ini，找到zend_extension开头的行，修改为如下行：
zend_extension = /usr/local/php/lib/php/extensions/no-debug-zts-20100525/xcache.so

注意：如果php.ini文件中有多条zend_extension指令行，要确保此新增的行排在第一位。

五、启用服务器状态

mod_status模块可以让管理员查看服务器的执行状态，它通过一个HTML页面展示了当前服务器的统计数据。这些数据通常包括但不限于：
(1) 处于工作状态的worker进程数；
(2) 空闲状态的worker进程数；
(3) 每个worker的状态，包括此worker已经响应的请求数，及由此worker发送的内容的字节数；
(4) 当前服务器总共发送的字节数；
(5) 服务器自上次启动或重启以来至当前的时长；
(6) 平均每秒钟响应的请求数、平均每秒钟发送的字节数、平均每个请求所请求内容的字节数；

启用状态页面的方法很简单，只需要在主配置文件中添加如下内容即可：
<Location /server-status>
    SetHandler server-status
    Require all granted
</Location>

需要提醒的是，这里的状态信息不应该被所有人随意访问，因此，应该限制仅允许某些特定地址的客户端查看。比如使用Require ip 172.16.0.0/16来限制仅允许指定网段的主机查看此页面。






第二部分、配置apache-2.4.4与fpm方式的php-5.4.13

一、apache、MySQL的安装与前一部分相同；请根据其进行安装；

二、编译安装php-5.4.13

1、解决依赖关系：

请配置好yum源（可以是本地系统光盘）后执行如下命令：
# yum -y groupinstall "X Software Development" 

如果想让编译的php支持mcrypt扩展，此处还需要下载ftp://172.16.0.1/pub/Sources/ngnix目录中的如下两个rpm包并安装之：
libmcrypt-2.5.7-5.el5.i386.rpm
libmcrypt-devel-2.5.7-5.el5.i386.rpm
mhash-0.9.9-1.el5.centos.i386.rpm
mhash-devel-0.9.9-1.el5.centos.i386.rpm

2、编译安装php-5.4.13

首先下载源码包至本地目录，下载位置ftp://172.16.0.1/pub/Sources/new_lamp。

# tar xf php-5.4.13.tar.bz2
# cd php-5.4.13
# ./configure --prefix=/usr/local/php --with-mysql=/usr/local/mysql --with-openssl --with-mysqli=/usr/local/mysql/bin/mysql_config --enable-mbstring
--with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml  --enable-sockets --enable-fpm --with-mcrypt 
--with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --with-bz2


说明：如果使用PHP5.3以上版本，为了链接MySQL数据库，可以指定mysqlnd，这样在本机就不需要先安装MySQL或MySQL开发包了。mysqlnd从php 5.3开始可用，可以编译时绑定到它（而不用和具体的MySQL客户端库绑定形成依赖），但从PHP 5.4开始它就是默认设置了。
# ./configure --with-mysql=mysqlnd --with-pdo-mysql=mysqlnd --with-mysqli=mysqlnd

# make
# make intall

为php提供配置文件：
# cp php.ini-production /etc/php.ini

3、配置php-fpm
 
为php-fpm提供Sysv init脚本，并将其添加至服务列表：
# cp sapi/fpm/init.d.php-fpm  /etc/rc.d/init.d/php-fpm
# chmod +x /etc/rc.d/init.d/php-fpm
# chkconfig --add php-fpm
# chkconfig php-fpm on

为php-fpm提供配置文件：
# cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf 

编辑php-fpm的配置文件：
# vim /usr/local/php/etc/php-fpm.conf
配置fpm的相关选项为你所需要的值，并启用pid文件（如下最后一行）：
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 2
pm.max_spare_servers = 8
pid = /usr/local/php/var/run/php-fpm.pid （注意，要跟提供的服务脚本中的Pid路径保持一致）

接下来就可以启动php-fpm了：
# service php-fpm start

使用如下命令来验正（如果此命令输出有中几个php-fpm进程就说明启动成功了）：
# ps aux | grep php-fpm

默认情况下，fpm监听在127.0.0.1的9000端口，也可以使用如下命令验正其是否已经监听在相应的套接字。
# netstat -tnlp | grep php-fpm
tcp        0      0 127.0.0.1:9000              0.0.0.0:*                   LISTEN      689/php-fpm 

三、配置httpd-2.4.4

1、启用httpd的相关模块

在Apache httpd 2.4以后已经专门有一个模块针对FastCGI的实现，此模块为mod_proxy_fcgi.so，它其实是作为mod_proxy.so模块的扩充，因此，这两个模块都要加载
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so


2、配置虚拟主机支持使用fcgi

在相应的虚拟主机中添加类似如下两行。
	ProxyRequests Off
	ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/PATH/TO/DOCUMENT_ROOT/$1

	
例如：
<VirtualHost *:80>
    DocumentRoot "/www/magedu.com"
    ServerName magedu.com
    ServerAlias www.magedu.com

	ProxyRequests Off
	ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/www/magedu.com/$1
*2.4.10以后可以用<FilesMatch>块代替，而且上面的很麻烦，直接
<FilesMatch \.php$>
   setHandler “proxy:fcgi://127.0.0.1:9000”
</FilesMatch>

    <Directory "/www/magedu.com">
        Options none
        AllowOverride none
        Require all granted
    </Directory>
</VirtualHost>

ProxyRequests Off：关闭正向代理
ProxyPassMatch：把以.php结尾的文件请求发送到php-fpm进程，php-fpm至少需要知道运行的目录和URI，所以这里直接在fcgi://127.0.0.1:9000后指明了这两个参数，其它的参数的传递已经被mod_proxy_fcgi.so进行了封装，不需要手动指定。

3、编辑apache配置文件httpd.conf，让apache能识别php格式的页面，并支持php格式的主页
 
 # vim /etc/httpd/httpd.conf
 1、添加如下二行
   AddType application/x-httpd-php  .php
   AddType application/x-httpd-php-source  .phps

 2、定位至DirectoryIndex index.html 
   修改为：
    DirectoryIndex  index.php  index.html

补充：Apache httpd 2.4以前的版本中，要么把PHP作为Apache的模块运行，要么添加一个第三方模块支持PHP-FPM实现。



