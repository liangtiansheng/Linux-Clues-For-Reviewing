LB集群的实现：
	硬件：
		F5 BIG-IP
		Citrix NetScaler
		A10 A10
		Array
		Redware
	软件:
		lvs
		haproxy
		nginx
		ats (apache traffic server)
		perlbal
	基于工作的协议层次划分：
		传输层：
			lvs,haproxy(mode tcp)
		应用层：
			haproxy,nginx,ats,perlbal
章文嵩研发的LVS：Linux Virtual Server(layer4四层路由)
LVS:工作在INPUT链上，进来的IPVS请求报文被修改(不动原报文，在原报文头部加一个D mac和R mac转给RS)后直接过POSTROUTING链出去到RS
根据请求报文的目标IP和PORT将其转发至后端主机集群中的某一个主机(根据Loadbalance算法)
类型：
	NAT：地址转换
	DR: 直接路由
	TUN：隧道

	NAT模型:
		1、集群节点跟director必须在同一个IP网络中；
		2、RIP通常是私有地址，仅用于各集群节点间的通信；
		3、director位于client和real server之间，并负责处理进出的所有通信；
		4、realserver必须将网关指向DIP；
		5、支持端口映射；
		6、realserver可以使用任意OS；
		7、较大规模应该场景中，director易成为系统瓶颈；
		8、请求和响应报文都要经由director转发

	DR模型: Director(VIP,DIP),RealServer(VIP,RIP)
		1、保证前端路由器将目标IP为VIP的请求报文发送给director;
			解决方案：
				静态绑定
				arp_tables
				修改RS主机内核的参数
		2、RS的RIP可以使用私有地址，但也可以使用公网地址
		3、RS跟Director必须在同一物理网络中，不一定同一网段，但距离也不可能远
		4、请求报文经由Director调度，但响应报文一定不能经由Director
		5、不支持端口映射
		6、RS可以是大多数OS
		7、RS的网关不能指向DIP
		8、Director和RS都有VIP地址，所以通过mac地址寻址
		9、RS一般数据从哪来就从哪出，所以要借用lo回环口配VIP

	TUN模型：跟DR相似，但这种模型不修改请求报文的IP首部(CIP<-->VIP)，而是重新封装报文(DIP<-->RIP),realserver跨互联网
		1、集群节点可以跨越Internet；
		2、RIP、DIP、VIP必须是公网地址；
		3、director仅负责处理入站请求，响应报文则由realserver直接发往客户端；
		4、realserver网关不能指向director；
		5、只有支持隧道功能的OS才能用于realserver；
		6、不支持端口映射；
		7、这种模型MTU大小需要手动控制，不然有的路由器是不支持切片
		8、Director和RS同样都有VIP，不然拆了第一个头部，第二个头部不能识别就转发了
	FULLNAT：director通过同时修改请求报文的目标地址和源地址进行转发
		1、VIP是公网地址：RIP和DIP是私网地址，二者无须在同一网络中
		2、RS接收到的请求报文的源地址为DIP，因此要响应给DIP
		3、请求报文和响应报文都必须经由Director
		4、支持端口映射机制
		5、RS可以使用任意OS
http: stateless无状态，淘宝购物车里面的商品如何保持
	session保持：
		session绑定：1、source ip hash 2、cookie
			对某一特定服务
			对多个共享同一组RS的服务，session实现不了
		session复制集群：通过多播的方式让每个session集群节点都有session，消耗大
		session服务器：mamcached,redis(key-value, kv store)，流服务器
scheduler method:
固定调度，静态：纯粹根据算法轮询分配不考虑Server在线的连接数
	rr: 轮叫，轮询
	wrr: Weight, 计算加权公平调度
	sh: source hash, 源地址hash，session邦定（http stateless无状态，每次登陆都有可能认证）
		sh将来自同一个IP的请求始终调度至同一RS
	dh: destination hash, 无论哪个主机对同一目标的请求发送给同一Server，提高缓存命中率

动态调度方法：算法都有一定
	lc: 最少连接
		Overhead = active*256+inactive
		谁的小，挑谁
	wlc: 加权最少连接，考虑服务器性能不一样
		(active*256+inactive)/weight
	sed: 最短期望延迟
		（active+1)*256/weight
	nq: never queue（先分发再计算，改进的sed）
	LBLC: 基于本地的最少连接
		动态的DH算法
		正向代理情形下的cache server调度
	LBLCR: 基于本地的带复制功能的最少连接
默认方法：wlc

一、关于ipvsadm:
ipvsadm是运行于用户空间、用来与ipvs交互的命令行工具，它的作用表现在：
1、定义在Director上进行dispatching的服务(service)，以及哪此服务器(server)用来提供此服务；
2、为每台同时提供某一种服务的服务器定义其权重（即概据服务器性能确定的其承担负载的能力）；

注：权重用整数来表示，有时候也可以将其设置为atomic_t；其有效表示值范围为24bit整数空间，即（2^24-1）；

因此，ipvsadm命令的主要作用表现在以下方面：
1、添加服务（通过设定其权重>0）；
2、关闭服务（通过设定其权重>0）；此应用场景中，已经连接的用户将可以继续使用此服务，直到其退出或超时；新的连接请求将被拒绝；
3、保存ipvs设置，通过使用“ipvsadm-sav > ipvsadm.sav”命令实现；
4、恢复ipvs设置，通过使用“ipvsadm-sav < ipvsadm.sav”命令实现；
5、显示ip_vs的版本号，下面的命令显示ipvs的hash表的大小为4k；
  # ipvsadm
    IP Virtual Server version 1.2.1 (size=4096)
6、显示ipvsadm的版本号
  # ipvsadm --version
   ipvsadm v1.24 2003/06/07 (compiled with popt and IPVS v1.2.0)

二、ipvsadm使用中应注意的问题
默认情况下，ipvsadm在输出主机信息时使用其主机名而非IP地址，因此，Director需要使用名称解析服务。如果没有设置名称解析服务、服务不可用或设置错误，ipvsadm将会一直等到名称解析超时后才返回。当然，ipvsadm需要解析的名称仅限于RealServer，考虑到DNS提供名称解析服务效率不高的情况，建议将所有RealServer的名称解析通过/etc/hosts文件来实现；

三、调度算法
Director在接收到来自于Client的请求时，会基于"schedule"从RealServer中选择一个响应给Client。ipvs支持以下调度算法：

1、轮询（round robin, rr),加权轮询(Weighted round robin, wrr)——新的连接请求被轮流分配至各RealServer；算法的优点是其简洁性，它无需记录当前所有连接的状态，所以它是一种无状态调度。轮叫调度算法假设所有服务器处理性能均相同，不管服务器的当前连接数和响应速度。该算法相对简单，不适用于服务器组中处理性能不一的情况，而且当请求服务时间变化比较大时，轮叫调度算法容易导致服务器间的负载不平衡。
2、最少连接(least connected, lc)， 加权最少连接(weighted least connection, wlc)——新的连接请求将被分配至当前连接数最少的RealServer；最小连接调度是一种动态调度算法，它通过服务器当前所活跃的连接数来估计服务器的负载情况。调度器需要记录各个服务器已建立连接的数目，当一个请求被调度到某台服务器，其连接数加1；当连接中止或超时，其连接数减一。
3、基于局部性的最少链接调度（Locality-Based Least Connections Scheduling，lblc）——针对请求报文的目标IP地址的负载均衡调度，目前主要用于Cache集群系统，因为在Cache集群中客户请求报文的目标IP地址是变化的。这里假设任何后端服务器都可以处理任一请求，算法的设计目标是在服务器的负载基本平衡情况下，将相同目标IP地址的请求调度到同一台服务器，来提高各台服务器的访问局部性和主存Cache命中率，从而整个集群系统的处理能力。LBLC调度算法先根据请求的目标IP地址找出该目标IP地址最近使用的服务器，若该服务器是可用的且没有超载，将请求发送到该服务器；若服务器不存在，或者该服务器超载且有服务器处于其一半的工作负载，则用“最少链接”的原则选出一个可用的服务器，将请求发送到该服务器。
4、带复制的基于局部性最少链接调度（Locality-Based Least Connections with Replication Scheduling，lblcr）——也是针对目标IP地址的负载均衡，目前主要用于Cache集群系统。它与LBLC算法的不同之处是它要维护从一个目标IP地址到一组服务器的映射，而 LBLC算法维护从一个目标IP地址到一台服务器的映射。对于一个“热门”站点的服务请求，一台Cache 服务器可能会忙不过来处理这些请求。这时，LBLC调度算法会从所有的Cache服务器中按“最小连接”原则选出一台Cache服务器，映射该“热门”站点到这台Cache服务器，很快这台Cache服务器也会超载，就会重复上述过程选出新的Cache服务器。这样，可能会导致该“热门”站点的映像会出现在所有的Cache服务器上，降低了Cache服务器的使用效率。LBLCR调度算法将“热门”站点映射到一组Cache服务器（服务器集合），当该“热门”站点的请求负载增加时，会增加集合里的Cache服务器，来处理不断增长的负载；当该“热门”站点的请求负载降低时，会减少集合里的Cache服务器数目。这样，该“热门”站点的映像不太可能出现在所有的Cache服务器上，从而提供Cache集群系统的使用效率。LBLCR算法先根据请求的目标IP地址找出该目标IP地址对应的服务器组；按“最小连接”原则从该服务器组中选出一台服务器，若服务器没有超载，将请求发送到该服务器；若服务器超载；则按“最小连接”原则从整个集群中选出一台服务器，将该服务器加入到服务器组中，将请求发送到该服务器。同时，当该服务器组有一段时间没有被修改，将最忙的服务器从服务器组中删除，以降低复制的程度。
5、目标地址散列调度（Destination Hashing，dh）算法也是针对目标IP地址的负载均衡，但它是一种静态映射算法，通过一个散列（Hash）函数将一个目标IP地址映射到一台服务器。目标地址散列调度算法先根据请求的目标IP地址，作为散列键（Hash Key）从静态分配的散列表找出对应的服务器，若该服务器是可用的且未超载，将请求发送到该服务器，否则返回空。
6、源地址散列调度（Source Hashing，sh）算法正好与目标地址散列调度算法相反，它根据请求的源IP地址，作为散列键（Hash Key）从静态分配的散列表找出对应的服务器，若该服务器是可用的且未超载，将请求发送到该服务器，否则返回空。它采用的散列函数与目标地址散列调度算法的相同。除了将请求的目标IP地址换成请求的源IP地址外，它的算法流程与目标地址散列调度算法的基本相似。在实际应用中，源地址散列调度和目标地址散列调度可以结合使用在防火墙集群中，它们可以保证整个系统的唯一出入口。

四、关于LVS追踪标记fwmark：
如果LVS放置于多防火墙的网络中，并且每个防火墙都用到了状态追踪的机制，那么在回应一个针对于LVS的连接请求时必须经过此请求连接进来时的防火墙，否则，这个响应的数据包将会被丢弃。

查看LVS上当前的所有连接
# ipvsadm -Lcn   
或者
#cat /proc/net/ip_vs_conn

查看虚拟服务和RealServer上当前的连接数、数据包数和字节数的统计值，则可以使用下面的命令实现：
# ipvsadm -l --stats

查看包传递速率的近似精确值，可以使用下面的命令：
# ipvsadm -l --rate


ipvs: 工作内核中netfilter INPUT钩子上，支持TCP,UDP,AH,EST,AH_EST,SCTP等诸多协议
	管理集群服务
		添加：-A -t|u|f service-address [-s scheduler]
			-t: TCP协议的集群 
			-u: UDP协议的集群
				service-address:     IP:PORT
			-f: FWM: 防火墙标记 
				service-address: Mark Number
		修改：-E
		删除：-D -t|u|f service-address

		# ipvsadm -A -t 172.16.100.1:80 -s rr

	管理集群服务中的RS
		添加：-a -t|u|f service-address -r server-address [-g|i|m] [-w weight]
			-t|u|f service-address：事先定义好的某集群服务
			-r server-address: 某RS的地址，在NAT模型中，可使用IP：PORT实现端口映射；
			[-g|i|m]: LVS类型	
				-g: DR
				-i: TUN
				-m: masquerade, NAT
			[-w weight]: 定义服务器权重
		修改：-e
		删除：-d -t|u|f service-address -r server-address

		# ipvsadm -a -t 172.16.100.1:80 -r 192.168.10.8 -m 
		# ipvsadm -a -t 172.16.100.1:80 -r 192.168.10.9 -m
	查看
		-L|l
			-n: 数字格式显示主机地址和端口
			--stats：统计数据
			--rate: 速率
			--timeout: 显示tcp、tcpfin和udp的会话超时时长
			-c: 显示当前的ipvs连接状况
			--sort
			--daemon
	删除所有集群服务
		-C：清空ipvs规则
	保存规则
		-S 
		# ipvsadm -S > /path/to/somefile
	载入此前的规则：
		-R
		# ipvsadm -R < /path/form/somefile

前提：
	各节点之间的时间偏差不应该超出1秒钟；
	时间服务器来同步：
	NTP：Network Time Protocol

############################## example for nat ##############################
LVS-NAT基于cisco的LocalDirector。VS/NAT不需要在RealServer上做任何设置，其只要能提供一个tcp/ip的协议栈即可，甚至其无论基于什么OS。基于VS/NAT，所有的入站数据包均由Director进行目标地址转换后转发至内部的RealServer，RealServer响应的数据包再由Director转换源地址后发回客户端。 
VS/NAT模式不能与netfilter兼容，因此，不能将VS/NAT模式的Director运行在netfilter的保护范围之中。现在已经有补丁可以解决此问题，但尚未被整合进ip_vs code。

        ____________
       |            |
       |  client    |
       |____________|                     
     CIP=192.168.0.253 (eth0)             
              |                           
              |                           
     VIP=192.168.0.220 (eth0)             
        ____________                      
       |            |                     
       |  director  |                     
       |____________|                     
     DIP=192.168.10.10 (eth1)         
              |                           
           (switch)------------------------
              |                           |
     RIP=192.168.10.2 (eth0)       RIP=192.168.10.3 (eth0)
        _____________               _____________
       |             |             |             |
       | realserver1 |             | realserver2 |
       |_____________|             |_____________|  

     
设置VS/NAT模式的LVS(这里以web服务为例)
Director:

建立服务
# ipvsadm -A -t VIP:PORT -s rr
如:
# ipvsadm -A -t 192.168.0.220:80 -s rr

设置转发：
# ipvsadm -a -t VIP:PORT -r RIP_N:PORT -m -w N
如：
# ipvsadm -a -t 192.168.0.220:80 -r 192.168.10.2 -m -w 1
# ipvsadm -a -t 192.168.0.220:80 -r 192.168.10.3 -m -w 1

打开路由转发功能
# echo "1" > /proc/sys/net/ipv4/ip_forward

服务控制脚本：

#!/bin/bash
#
# chkconfig: - 88 12
# description: LVS script for VS/NAT
#
. /etc/rc.d/init.d/functions
#
VIP=192.168.0.219
DIP=192.168.10.10
RIP1=192.168.10.11
RIP2=192.168.10.12
#
case "$1" in
start)           

  /sbin/ifconfig eth0:1 $VIP netmask 255.255.255.0 up

# Since this is the Director we must be able to forward packets
  echo 1 > /proc/sys/net/ipv4/ip_forward

# Clear all iptables rules.
  /sbin/iptables -F

# Reset iptables counters.
  /sbin/iptables -Z

# Clear all ipvsadm rules/services.
  /sbin/ipvsadm -C

# Add an IP virtual service for VIP 192.168.0.219 port 80
# In this recipe, we will use the round-robin scheduling method. 
# In production, however, you should use a weighted, dynamic scheduling method. 
  /sbin/ipvsadm -A -t $VIP:80 -s rr

# Now direct packets for this VIP to
# the real server IP (RIP) inside the cluster
  /sbin/ipvsadm -a -t $VIP:80 -r $RIP1 -m
  /sbin/ipvsadm -a -t $VIP:80 -r $RIP2 -m
  
  /bin/touch /var/lock/subsys/ipvsadm.lock
;;

stop)
# Stop forwarding packets
  echo 0 > /proc/sys/net/ipv4/ip_forward

# Reset ipvsadm
  /sbin/ipvsadm -C

# Bring down the VIP interface
  ifconfig eth0:1 down
  
  rm -rf /var/lock/subsys/ipvsadm.lock
;;

status)
  [ -e /var/lock/subsys/ipvsadm.lock ] && echo "ipvs is running..." || echo "ipvsadm is stopped..."
;;
*)
  echo "Usage: $0 {start|stop}"
;;
esac

############################## example for DR ##################################
ARP问题：
                     __________
                     |        |
                     | client |
                     |________|
 	                       |
                         |
                      (router)
                         |
                         |
                         |       __________
                         |  DIP |          |
                         |------| director |
                         |  VIP |__________|
                         |
                         |
                         |
       ------------------------------------
       |                 |                |
       |                 |                |
   RIP1, VIP         RIP2, VIP        RIP3, VIP
 ______________    ______________    ______________
|              |  |              |  |              |
| realserver1  |  | realserver2  |  | realserver3  |
|______________|  |______________|  |______________|

在如上图的VS/DR或VS/TUN应用的一种模型中（所有机器都在同一个物理网络），所有机器（包括Director和RealServer）都使用了一个额外的IP地址，即VIP。当一个客户端向VIP发出一个连接请求时，此请求必须要连接至Director的VIP，而不能是RealServer的。因为，LVS的主要目标就是要Director负责调度这些连接请求至RealServer的。
因此，在Client发出至VIP的连接请求后，只能由Director将其MAC地址响应给客户端（也可能是直接与Director连接的路由设备），而Director则会相应的更新其ipvsadm table以追踪此连接，而后将其转发至后端的RealServer之一。
如果Client在请求建立至VIP的连接时由某RealServer响应了其请求，则Client会在其MAC table中建立起一个VIP至RealServer的对就关系，并以至进行后面的通信。此时，在Client看来只有一个RealServer而无法意识到其它服务器的存在。
为了解决此问题，可以通过在路由器上设置其转发规则来实现。当然，如果没有权限访问路由器并做出相应的设置，则只能通过传统的本地方式来解决此问题了。这些方法包括：
1、禁止RealServer响应对VIP的ARP请求；
2、在RealServer上隐藏VIP，以使得它们无法获知网络上的ARP请求；
3、基于“透明代理（Transparent Proxy）”或者“fwmark （firewall mark）”；
4、禁止ARP请求发往RealServers；

传统认为，解决ARP问题可以基于网络接口，也可以基于主机来实现。Linux采用了基于主机的方式，因为其可以在大多场景中工作良好，但LVS却并不属于这些场景之一，因此，过去实现此功能相当麻烦。现在可以通过设置arp_ignore和arp_announce，这变得相对简单的多了。
Linux 2.2和2.4（2.4.26之前的版本）的内核解决“ARP问题”的方法各不相同，且比较麻烦。幸运的是，2.4.26和2.6的内核中引入了两个新的调整ARP栈的标志（device flags）：arp_announce和arp_ignore。基于此，在DR/TUN的环境中，所有IPVS相关的设定均可使用arp_announce=2和arp_ignore=1/2/3来解决“ARP问题”了。
arp_annouce：Define different restriction levels for announcing the local source IP address from IP packets in ARP requests sent on interface；
	0 - (default) Use any local address, configured on any interface.
	1 - Try to avoid local addresses that are not in the target's subnet for this interface. 
	2 - Always use the best local address for this target.
	
arp_ignore: Define different modes for sending replies in response to received ARP requests that resolve local target IP address.
	0 - (default): reply for any local target IP address, configured on any interface.
	1 - reply only if the target IP address is local address configured on the incoming interface.（进入的网卡上的IP地址）
	2 - reply only if the target IP address is local address configured on the incoming interface and both with the sender's IP address are part from same subnet on this interface.
	3 - do not reply for local address configured with scope host, only resolutions for golbal and link addresses are replied.
	4-7 - reserved
	8 - do not reply for all local addresses
	
在RealServers上，VIP配置在本地回环接口lo上。如果回应给Client的数据包路由到了eth0接口上，则arp通告或请应该通过eth0实现，因此，需要在sysctl.conf文件中定义如下配置：
#vim /etc/sysctl.conf
net.ipv4.conf.eth0.arp_ignore = 1
net.ipv4.conf.eth0.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2

以上选项需要在启用VIP之前进行，否则，则需要在Drector上清空arp表才能正常使用LVS。

到达Director的数据包首先会经过PREROUTING，而后经过路由发现其目标地址为本地某接口的地址，因此，接着就会将数据包发往INPUT(LOCAL_IN HOOK)。此时，正在运行内核中的ipvs（始终监控着LOCAL_IN HOOK）进程会发现此数据包请求的是一个集群服务，因为其目标地址是VIP。于是，此数据包的本来到达本机(Director)目标行程被改变为经由POSTROUTING HOOK发往RealServer。这种改变数据包正常行程的过程是根据IPVS表(由管理员通过ipvsadm定义)来实现的。

如果有多台Realserver，在某些应用场景中，Director还需要基于“连接追踪”实现将由同一个客户机的请求始终发往其第一次被分配至的Realserver，以保证其请求的完整性等。其连接追踪的功能由Hash table实现。Hash table的大小等属性可通过下面的命令查看：
# ipvsadm -lcn

为了保证其时效性，Hash table中“连接追踪”信息被定义了“生存时间”。LVS为记录“连接超时”定义了三个计时器：
	1、空闲TCP会话；
	2、客户端正常断开连接后的TCP会话；
	3、无连接的UDP数据包（记录其两次发送数据包的时间间隔）；
上面三个计时器的默认值可以由类似下面的命令修改，其后面的值依次对应于上述的三个计时器：
# ipvsadm --set 28800 30 600

数据包在由Direcotr发往Realserver时，只有目标MAC地址发生了改变(变成了Realserver的MAC地址)。Realserver在接收到数据包后会根据本地路由表将数据包路由至本地回环设备，接着，监听于本地回环设备VIP上的服务则对进来的数据库进行相应的处理，而后将处理结果回应至RIP，但数据包的原地址依然是VIP。


DR简单实验：DR模型中一定要配lo:0回环口的路由，不然内核不能用lo:0上的vip进行封装报文
***注意即使配了arp_announce、arp_ignore，一样要将lo:0配成32位掩码，抑制arp feedback，而且前面两个内核参数要提前改，因为先配了ip就会广播
Director:							
eth0,DIP:172.16.100.2				
eth0:0,VIP:172.16.100.1				
	#route add -host 172.16.100.1 dev eth0:0
	#curl http://172.16.100.7
	#ipvsadm -C
	#ipvsadm -A -t 172.16.100.1:80 -s wlc
	#ipvsadm -a -t 172.16.100.1:80 -r 172.16.100.7 -g -w 2
	#ipvsadm -a -t 172.16.100.1:80 -r 172.16.100.8 -g -w 1
	#ipvsadm -L -n
	#curl http://172.16.100.1(显示两次第一个网页，再显示一次第二个网页）
RS1:				
eth0,RIP1:172.16.100.7				
lo:0,VIP:172.16.100.1				
	#sysctl -w net.ipv4.conf.eth0.arp_announce=2			
	#sysctl -w net.ipv4.conf.all.arp_announce=2			
	#echo 1 > /proc/sys/net/ipv4/conf/eth0/arp_ignore
	#echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
	#ifconfig lo:0 172.16.100.1 netmask 255.255.255.255 broadcast 172.16.100.1 up
	#route add -host 172.16.100.1 dev lo:0
		地址是内核的，请求内核的地址从哪个接口进来默认从哪个接口出去
RS2:
eth0,RIP1:172.16.100.8
lo:0,VIP:172.16.100.1
	#sysctl -w net.ipv4.conf.eth0.arp_announce=2			
	#sysctl -w net.ipv4.conf.all.arp_announce=2			 
	#echo 1 > /proc/sys/net/ipv4/conf/eth0/arp_ignore
	#echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
	#ifconfig lo:0 172.16.100.1 netmask 255.255.255.255 broadcast 172.16.100.1 up
	#route add -host 172.16.100.1 dev lo:0

DR类型中，Director和RealServer的配置脚本示例：

Director脚本:
#!/bin/bash
#
# LVS script for VS/DR
# chkconfig: - 90 10
#
. /etc/rc.d/init.d/functions
#
VIP=172.16.100.1
DIP=172.16.100.2
RIP1=172.16.100.7
RIP2=172.16.100.8
PORT=80
RSWEIGHT1=2
RSWEIGHT2=5

#
case "$1" in
start)           

  /sbin/ifconfig eth0:1 $VIP broadcast $VIP netmask 255.255.255.255 up
  /sbin/route add -host $VIP dev eth0:0

# Since this is the Director we must be able to forward packets
  echo 1 > /proc/sys/net/ipv4/ip_forward

# Clear all iptables rules.
  /sbin/iptables -F

# Reset iptables counters.
  /sbin/iptables -Z

# Clear all ipvsadm rules/services.
  /sbin/ipvsadm -C

# Add an IP virtual service for VIP 192.168.0.219 port 80
# In this recipe, we will use the round-robin scheduling method. 
# In production, however, you should use a weighted, dynamic scheduling method. 
  /sbin/ipvsadm -A -t $VIP:80 -s wlc

# Now direct packets for this VIP to
# the real server IP (RIP) inside the cluster
  /sbin/ipvsadm -a -t $VIP:80 -r $RIP1 -g -w $RSWEIGHT1
  /sbin/ipvsadm -a -t $VIP:80 -r $RIP2 -g -w $RSWEIGHT2

  /bin/touch /var/lock/subsys/ipvsadm &> /dev/null
;; 

stop)
# Stop forwarding packets
  echo 0 > /proc/sys/net/ipv4/ip_forward

# Reset ipvsadm
  /sbin/ipvsadm -C

# Bring down the VIP interface
  /sbin/ifconfig eth0:0 down
  /sbin/route del $VIP
  
  /bin/rm -f /var/lock/subsys/ipvsadm
  
  echo "ipvs is stopped..."
;;

status)
  if [ ! -e /var/lock/subsys/ipvsadm ]; then
    echo "ipvsadm is stopped ..."
  else
    echo "ipvs is running ..."
    ipvsadm -L -n
  fi
;;
*)
  echo "Usage: $0 {start|stop|status}"
;;
esac


RealServer脚本:

#!/bin/bash
#
# Script to start LVS DR real server.
# chkconfig: - 90 10
# description: LVS DR real server
#
.  /etc/rc.d/init.d/functions

VIP=172.16.100.1

host=`/bin/hostname`

case "$1" in
start)
       # Start LVS-DR real server on this machine.
        /sbin/ifconfig lo down
        /sbin/ifconfig lo up
        echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
        echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce
        echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
        echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce

        /sbin/ifconfig lo:0 $VIP broadcast $VIP netmask 255.255.255.255 up
        /sbin/route add -host $VIP dev lo:0

;;
stop)

        # Stop LVS-DR real server loopback device(s).
        /sbin/ifconfig lo:0 down
        echo 0 > /proc/sys/net/ipv4/conf/lo/arp_ignore
        echo 0 > /proc/sys/net/ipv4/conf/lo/arp_announce
        echo 0 > /proc/sys/net/ipv4/conf/all/arp_ignore
        echo 0 > /proc/sys/net/ipv4/conf/all/arp_announce

;;
status)

        # Status of LVS-DR real server.
        islothere=`/sbin/ifconfig lo:0 | grep $VIP`
        isrothere=`netstat -rn | grep "lo:0" | grep $VIP`
        if [ ! "$islothere" -o ! "isrothere" ];then
            # Either the route or the lo:0 device
            # not found.
            echo "LVS-DR real server Stopped."
        else
            echo "LVS-DR real server Running."
        fi
;;
*)
            # Invalid entry.
            echo "$0: Usage: $0 {start|status|stop}"
            exit 1
;;
esac



curl命令选项：
	--cacert <file> CA证书 (SSL)
	--capath <directory> CA目录 (made using c_rehash) to verify peer against (SSL)
	--compressed 要求返回是压缩的形势 (using deflate or gzip)
	--connect-timeout <seconds> 设置最大请求时间
	-H/--header <line>自定义头信息传递给服务器
	-i/--include 输出时包括protocol头信息
	-I/--head 只显示文档信息
	--interface <interface> 使用指定网络接口/地址
	-s/--silent静音模式。不输出任何东西
	-u/--user <user[:password]>设置服务器的用户和密码
	-p/--proxytunnel 使用HTTP代理


RS健康状态检查脚本示例第一版：
#!/bin/bash
#
VIP=192.168.10.3
CPORT=80
FAIL_BACK=127.0.0.1
FBSTATUS=0
RS=("192.168.10.7" "192.168.10.8")
RSTATUS=("1" "1")
RW=("2" "1")
RPORT=80
TYPE=g

add() {
  ipvsadm -a -t $VIP:$CPORT -r $1:$RPORT -$TYPE -w $2
  [ $? -eq 0 ] && return 0 || return 1
}

del() {
  ipvsadm -d -t $VIP:$CPORT -r $1:$RPORT
  [ $? -eq 0 ] && return 0 || return 1
}

while :; do
  let COUNT=0
  for I in ${RS[*]}; do
    if curl --connect-timeout 1 http://$I &> /dev/null; then
      if [ ${RSTATUS[$COUNT]} -eq 0 ]; then
         add $I ${RW[$COUNT]}
         [ $? -eq 0 ] && RSTATUS[$COUNT]=1
      fi
    else
      if [ ${RSTATUS[$COUNT]} -eq 1 ]; then
         del $I
         [ $? -eq 0 ] && RSTATUS[$COUNT]=0
      fi
    fi
    let COUNT++
  done
  sleep 5
done


RS健康状态检查脚本示例第二版：
#!/bin/bash
#
VIP=192.168.10.3
CPORT=80
FAIL_BACK=127.0.0.1
RS=("192.168.10.7" "192.168.10.8")
declare -a RSSTATUS
RW=("2" "1")
RPORT=80
TYPE=g
CHKLOOP=3
LOG=/var/log/ipvsmonitor.log

addrs() {
  ipvsadm -a -t $VIP:$CPORT -r $1:$RPORT -$TYPE -w $2
  [ $? -eq 0 ] && return 0 || return 1
}

delrs() {
  ipvsadm -d -t $VIP:$CPORT -r $1:$RPORT 
  [ $? -eq 0 ] && return 0 || return 1
}

checkrs() {
  local I=1
  while [ $I -le $CHKLOOP ]; do 
    if curl --connect-timeout 1 http://$1 &> /dev/null; then
      return 0
    fi
    let I++
  done
  return 1
}

initstatus() {
  local I
  local COUNT=0;
  for I in ${RS[*]}; do
    if ipvsadm -L -n | grep "$I:$RPORT" && > /dev/null ; then
      RSSTATUS[$COUNT]=1
    else 
      RSSTATUS[$COUNT]=0
    fi
  let COUNT++
  done
}

initstatus
while :; do
  let COUNT=0
  for I in ${RS[*]}; do
    if checkrs $I; then
      if [ ${RSSTATUS[$COUNT]} -eq 0 ]; then
         addrs $I ${RW[$COUNT]}
         [ $? -eq 0 ] && RSSTATUS[$COUNT]=1 && echo "`date +'%F %H:%M:%S'`, $I is back." >> $LOG
      fi
    else
      if [ ${RSSTATUS[$COUNT]} -eq 1 ]; then
         delrs $I
         [ $? -eq 0 ] && RSSTATUS[$COUNT]=0 && echo "`date +'%F %H:%M:%S'`, $I is gone." >> $LOG
      fi
    fi
    let COUNT++
  done 
  sleep 5
done


LVS持久连接:
	无论使用什么调度算法，LVS持久连接都能实现在一定时间内，将来自同一个客户端请求派发至此前选定的RS。

	LVS持久连接模板(内存缓冲区)：记录客户来访并实时追踪，这个模板容量决定记录量，有上限
		每一个客户端  及分配给它的RS的映射关系；
		ipvsadm -L -c
		ipvsadm -L --persistent-conn
		相对于iptables的追踪模板，性能还是不错的

	ipvsadm -A|E ... -p timeout: 加入-p就是持久连接
		timeout: 持久连接时长，默认300秒；单位是秒；
	在基于SSL，需要用到持久连接；申请证书，发布证书等等，不然会出现多次请求
	
	持久类型：
	PPC(每端口持久)：将来自于同一个客户端对同一个集群服务的请求，始终定向至此前选定的RS；     持久端口连接
		#ipvsadm -A -t 192.168.10.3:23 -s rr
		#ipvsadm -a -t 192.168.10.3:23 -r 192.168.10.7 -g -w 2
		#ipvsadm -a -t 192.168.10.3:23 -r 192.168.10.8 -g -w 2
		
		#ipvsadm -E -t 192.168.10.3:23 -s rr -p 3600
	PCC(每客户端持久)：将来自于同一个客户端对所有端口的请求，始终定向至此前选定的RS；           持久客户端连接
		把所有端口统统定义为集群服务，一律向RS转发；就算没有定义过ssh，连接Director时，也转给RS
		#ipvsadm -C
		#ipvsadm -A -t 192.168.10.3:0 -s rr -p 600
		#ipvsadm -a -t 192.168.10.3:0 -r 192.168.10.7 -g -w 2
		#ipvsadm -a -t 192.168.10.3:0 -r 192.168.10.8 -g -w 1

	PNMPP：持久防火墙标记连接
		如何只让PCC的有限或指定服务加入集群而并非所有服务，此时要用到防火墙标记
	80： RS1
	23： 同一个RS
	
	防火墙标记：在PREROUTING链上将80和23都标记为同一个数值，作为集群服务，别的服务就不参与集群，持久连接可以再接着定义
		PREROUTING	
			80: 8
			23: 8
		#ipvsadm -C
		#service ipvsadm save
		#service ipvsadm restart
		#iptable -t mangle -A PREROUTING -d 192.168.10.3 -i eth0 -p tcp --dport 80 -j MARK --set-mark 8
		#iptable -t mangle -A PREROUTING -d 192.168.10.3 -i eth0 -p tcp --dport 23 -j MARK --set-mark 8
		#ipvsadm -A -f 8 -s rr
		#ipvsadm -a -f 8 -r 192.168.10.7 -g -w 2
		#ipvsadm -a -f 8 -r 192.168.10.8 -g -w 5

		#ipvsadm -E -f 8 -s rr -p 600
			持久连接会破坏负载均衡，但web上的session、cookie等需要持久有效
			但服务器端session共享(三种方式中的一种即集群复制)的话就不需要持久连接，但目前没有成熟
		
	实际上80一般和443一起标记才有意义：	
		80, 443
		http: 
		https: 
	

HA:衡量公式A=MTBF/(MTBF+MTTR)
	MTBF: Mean Time Between Failure
	MTTR: Mean Time To Repair

	0<A<1: 百分比
		90%, 95%, 99%
		99.9% 99.99% 99.999%(极别相当高,投入很大)
Message Layer:
	heartbeat(v1,v2,v3)
		heartbeat v3（分裂成三个小项目都相互独立）
			heartbeat, pacemaker,cluster-glue
	corosync（纯message layer）+ pacemaker 组合
		这就意味着corosync的决策与heartbeat v3相差无几
	cman
	keepalived
		一定程度上是为lvs创建的，但是上述两种对lvs的扩展也很到位
CRM：Cluster Resource Manage层是附着在Message Layer层之上的
	heartbeat自带的资源管理器
		v1: haresources
		v2: 有两个资源管理器
		    haresources（兼容v1）
		    crm（就叫crm，更进的版本，受欢迎）
	pacemaker(heartbeat v3, corosync)
		v3: 资源管理器crm发展为独立的项目
	rgmanager(cman)----------------配置接口：cluster.conf, system-config-cluster, conga(webgui), cman_tool-------------
所以组合方式：
	heartbeat v1 (haresources)-----配置接口：配置文件haresources-------
	heartbeat v2 (crm)-------------配置接口：每个节点运行一个crmd守护进程，有命令行接口crmsh; GUI: hb_gui---------------
	heartbeat v3 + pacemaker-------配置接口：crmsh, pcs; GUI: hawk(suse),LCMC, pacemaker-gui----------------
	corosync + pacemaker
		corosync v1 + pacemaker(plugin)
		corosync v2 + pacemaker(standalone service)
	cman(投票完善) + rgmanager(原本是天造地设一对)
	corosync v1 + cman(作插件) + pacemaker(比rgmanager强大)

	RHCS：red hat cluster pacemaker
		RHEL5: cman +　rgmanager + conga(ricci/luci)
		RHEL6: cman +　rgmanager + conga(ricci/luci)
			corosync + pacemaker
			corosync + cman + pacemaker
		RHEL7: corosync v2 + pacemaker(corosync终于有了投票完善机制,cman彻底抛弃)


DC(designated coordinate)：指派中心，有下面两种机制
	TE: Transaction engine 
	PE: Policy engine
crmd: 提供一个管理API(套接字接口）
	有很多GUI界面
		hb_gui命令
	也有CLI接口

RA: Resource Agent
	在每个节点上都有这些脚本，接受LRM传递过来的指令对资源进行管理
RA Classes: 为资源管理器提供功能，一般接受LCM提供的参数
	Legacy heartbeat v1 RA /etc/ha.d/haresources.d/目录下的脚本
		centos7改成统一的service
	LSB (/etc/rc.d/init.d/*)支持linux bash 风格的脚本都可以做为资源代理
	OCF (Open Cluster Framework)后来比LSB更优秀的脚本风格
		pacemaker
		linbit (drbd)
	STONITH（shoot the other node in the head） 专门用来管理硬件stonith设备的
	systemd /etc/systemd/system/...

Resource Type:
	primitive: 在某个时刻只能运行于一个节点上的资源，基本资源
	clone: 把主资源克隆成n份分别放到集群中的每个节点上同时运行起来，
		匿名克隆、全局惟一克隆、状态克隆（主动、被动）
		stonith设备，一个节点出故障，所有节点必须共同作用踢除
		dlm（Distributed Lock Manager）: 分布式锁管理器
	group: 将资源归类归组，同进同退
	multi-state(master/slave): 两个节点，一个主一个从
		drbd(Distributed replicated block device)：分布式复制块设备
	资源属性：
		priority: 优先级
		target-role：started, stopped, master;
		is-managed: 是否允许集群管理此资源
		resource-stickiness：资源粘性
		allow-migrate: 是否允许迁移
	资源粘性：资源对某点的依赖程度，通过score定义
		资源是否倾向于留在当前节点
		正数：乐意
		负数：离开
		若位置约束大于资源粘性则以位置约束为准（在同一节点上二者会相加）
		node1.magedu.com: 100, 200
		node2.magedu.com: 100, inf

		IPaddr::172.16.100.1/16/eth0 httpd

	资源约束：Constraint
		排列约束: (colocation)
			资源是否能够运行于同一节点
				score:
					正值：可以在一起
					负值：不能在一起
		位置约束：(location), score(分数)
			正值：倾向于此节点
			负值：倾向于逃离于此节点
			-inf: 负无穷
			inf: 正无穷
		顺序约束: (order)多个资源启动顺序依赖关系
				vip, ipvs
					ipvs-->vip
	安装配置：
		CentOS7：corosync v2 + pacemaker
			corosync v2：有了完善的vote system
			pacemaker：独立服务
		集群全生命周期管理工具
			pcs：agent(pcsd)
			crmsh: agentless(pssh)
				crm: 两种模式
				交互式：
					配置，执行commit命令以后才生效
					crm
					configure
					property stonith-enable
				批处理：
					立即生效
		配置集群前提：
			1、时间同步
			2、基于当前正在使用的主机名互相访问
			3、是否会用到仲裁设备
		资源：
			web service:
				vip: 192.168.154.111
				httpd
				这两个资源在一个node上
	Heartbeat信息传递
		Unicat, udpu
		Multicast, udp
		Broadcast
		组播地址：用于标识一个IP组播域，IANA把D类地址留给组播使用：224.0.0.0-239.255.255.255
			永久组播地址：224.0.0.0-224.0.0.255
			临时组播地址：224.0.1.0-238.255.255.255
			本地组播地址：239.0.0.0-239.255.255.255

		HeartBeat
		运行于备用主机上的Heartbeat可以通过以太网连接检测主服务器的运行状态，一旦其无法检测到主服务器的“心跳”则自动接管主服务器的资源。通常情况下，主、备服务器间的心跳连接是一个独立的物理连接，这个连接可以是串行线缆、一个由“交叉线”实现的以太网连接。Heartbeat甚至可同时通过多个物理连接检测主服务器的工作状态，而其只要能通过其中一个连接收到主服务器处于活动状态的信息，就会认为主服务器处于正常状态。从实践经验的角度来说，建议为Heartbeat配置多条独立的物理连接，以避免Heartbeat通信线路本身存在单点故障。
			1、串行电缆：被认为是比以太网连接安全性稍好些的连接方式，因为hacker无法通过串行连接运行诸如telnet、ssh或rsh类的程序，从而可以降低其通过已劫持的服务器再次侵入备份服务器的几率。但串行线缆受限于可用长度，因此主、备服务器的距离必须非常短。
			2、以太网连接：使用此方式可以消除串行线缆的在长度方面限制，并且可以通过此连接在主备服务器间同步文件系统，从而减少了从正常通信连接带宽的占用。
			
		基于冗余的角度考虑，应该在主、备服务器使用两个物理连接传输heartbeat的控制信息；这样可以避免在一个网络或线缆故障时导致两个节点同时认为自已是唯一处于活动状态的服务器从而出现争用资源的情况，这种争用资源的场景即是所谓的“脑裂”（split-brain）或“partitioned cluster”。在两个节点共享同一个物理设备资源的情况下，脑裂会产生相当可怕的后果。
		为了避免出现脑裂，可采用下面的预防措施：
		1、如前所述，在主、备节点间建立一个冗余的、可靠的物理连接来同时传送控制信息；
		2、一旦发生脑裂时，借助额外设备强制性地关闭其中一个节点；

		第二种方式即是俗称的“将其它节点‘爆头’（shoot the other node in the head）”，简称为STONITH。基于能够通过软件指令关闭某节点特殊的硬件设备，Heartbeat即可实现可配置的Stonith。但当主、备服务器是基于WAN进行通信时，则很难避免“脑裂”情景的出现。因此，当构建异地“容灾”的应用时，应尽量避免主、备节点共享物理资源。

		Heartbeat的控制信息：
		“心跳”信息: （也称为状态信息）仅150 bytes大小的广播、组播或多播数据包。可为以每个节点配置其向其它节点通报“心跳”信息的频率，以及其它节点上的heartbeat进程为了确认主节点出节点出现了运行等错误之前的等待时间。

		集群变动事务（transition）信息：ip-request和ip-request-rest是相对较常见的两种集群变动信息，它们在节点间需要进行资源迁移时为不同节点上heartbeat进程间会话传递信息。比如，当修复了主节点并且使其重新“上线”后，主节点会使用ip-request要求备用节点释放其此前从因主节点故障而从主节点那里接管的资源。此时，备用节点则关闭服务并使用ip-request-resp通知主节点其已经不再占用此前接管的资源。主接点收到ip-request-resp后就会重新启动服务。

		重传请求：在某集群节点发现其从其它节点接收到的heartbeat控制信息“失序”（heartbeat进程使用序列号来确保数据包在传输过程中没有被丢弃或出现错误）时，会要求对方重新传送此控制信息。 Heartbeat一般每一秒发送一次重传请求，以避免洪泛。

		上面三种控制信息均基于UDP协议进行传送，可以在/etc/ha.d/ha.cf中指定其使用的UDP端口或者多播地址（使用以太网连接的情况下）。

		此外，除了使用“序列号/确认”机制来确保控制信息的可靠传输外，Heartbeat还会使用MD5或SHA1为每个数据包进行签名以确保传输中的控制信息的安全性。

STONITH：
	split-brain: 集群节点无法有效获取其它节点的状态信息时，产生脑裂
		后果之一：抢占共享存储
vote system:
	少数服从多数：quorum
		total/2
		with quorum：拥有法定票数
		without quorum：不拥有法定票数
	两个节点(偶数个节点): 出现投标均等
		ping node 仲裁节点
		qdisk 仲裁磁盘

HA Cluster工作模型
	A/P：两节点模型active/passive;
		without-quorum-policy={stop|ignore|suicide|freeze}
	A/A：
资源隔离：
	节点级别：STONITH(shoot the other node on the head)
	资源级别：
		例如：FC SAN switch可以实现在存储资源级别拒绝某节点的访问(关闭光交换机的接口就行)
DAS:
	Direct Attached Storage
	直接接到主板总线，BUS
		文件：块级别
NAS：
	Network
	文件服务器：文件级别
SAN: 延长DAS线缆的设备
	主机-->封装scsi报文-->隧道封装光协议-->光缆远传-->主机解封-->识别块设备
	Storage Area network
	存储区域网络
		FC SAN：光报文
		IP SAN: iSCSI
SCSI: Small Computer System Interface


Stonith设备
1、Power Distribution Units (PDU)，电交换机，可以接受指令断掉对应节点电源
Power Distribution Units are an essential element in managing power capacity and functionality for critical network, server and data center equipment. They can provide remote load monitoring of connected equipment and individual outlet power control for remote power recycling.
2、Uninterruptible Power Supplies (UPS)
A stable power supply provides emergency power to connected equipment by supplying power from a separate source in the event of utility power failure.
3、Blade Power Control Devices
If you are running a cluster on a set of blades, then the power control device in the blade enclosure is the only candidate for fencing. Of course, this device must be
capable of managing single blade computers.
4、Lights-out Devices
Lights-out devices (IBM RSA, HP iLO, Dell DRAC) are becoming increasingly popular and may even become standard in off-the-shelf computers. However, they are inferior to UPS devices, because they share a power supply with their host (a cluster node). If a node stays without power, the device supposed to control it would be just as useless. In that case, the CRM would continue its attempts to fence the node indefinitely while all other resource operations would wait for the fencing/STONITH operation to complete.
5、Testing Devices
Testing devices are used exclusively for testing purposes. They are usually more gentle on the hardware. Once the cluster goes into production, they must be replaced
with real fencing devices.

ssh 172.16.100.1 'reboot'
meatware

STONITH的实现：
stonithd
stonithd is a daemon which can be accessed by local processes or over the network. It accepts the commands which correspond to fencing operations: reset, power-off, and power-on. It can also check the status of the fencing device.
The stonithd daemon runs on every node in the CRM HA cluster. The stonithd instance running on the DC node receives a fencing request from the CRM. It is up to this and other stonithd programs to carry out the desired fencing operation.
STONITH Plug-ins
For every supported fencing device there is a STONITH plug-in which is capable of controlling said device. A STONITH plug-in is the interface to the fencing device.
On each node, all STONITH plug-ins reside in /usr/lib/stonith/plugins (or in /usr/lib64/stonith/plugins for 64-bit architectures). All STONITH plug-ins look the same to stonithd, but are quite different on the other side reflecting the nature of the fencing device.
Some plug-ins support more than one device. A typical example is ipmilan (or external/ipmi) which implements the IPMI protocol and can control any device which supports this protocol.

epel
heartbeat v2
heartbeat - Heartbeat subsystem for High-Availability Linux
heartbeat-devel - Heartbeat development package
heartbeat-gui - Provides a gui interface to manage heartbeat clusters
heartbeat-ldirectord - Monitor daemon for maintaining high availability resources, 为ipvs高可用提供规则自动生成及后端realserver健康状态检查的组件；
heartbeat-pils - Provides a general plugin and interface loading library
heartbeat-stonith - Provides an interface to Shoot The Other Node In The Head


http://dl.fedoraproject.org/pub/epel/5/i386/repoview/letter_h.group.html


资源脚本：
资源脚本（resource scripts）即Heartbeat控制下的脚本。这些脚本可以添加或移除IP别名（IP alias)或从属IP地址（secondary IP address），或者包含了可以启动/停止服务能力之外数据包的处理功能等。通常，Heartbeat会到/etc/init.d/或/etc/ha.d/resource.d/目录中读取脚本文件。Heartbeat需要一直明确了解“资源”归哪个节点拥有或由哪个节点提供。在编写一个脚本来启动或停止某个资源时，一定在要脚本中明确判断出相关服务是否由当前系统所提供。
Heartbeat的配置文件：
/etc/ha.d/ha.cf
定义位于不同节点上的heartbeat进程间如何进行通信；
/etc/ha.d/haresources
定义对某个资源来说哪个服务器是主节点，以及哪个节点应该拥有客户端访问资源时的目标IP地址。
/etc/ha.d/authkeys
定义Heartbeat包在通信过程中如何进行加密。

当ha.cf或authkeys文件发生改变时，需要重新加载它们就可以使用之生效；而如果haresource文件发生了改变，则只能重启heartbeat服务方可使之生效。

尽管Heartbeat并不要求主从节点间进行时钟同步，但它们彼此间的时间差距不能超过1分钟，否则一些配置为高可用的服务可能会出异常。

Heartbeat当前也不监控其所控制的资源的状态，比如它们是否正在运行，是否运行良好以及是否可供客户端访问等。要想监控这些资源，冉要使用额外的Mon软件包来实现。

haresources配置文件介绍：
主从节点上的/etc/ra.d/raresource文件必须完全相同。文件每行通常包含以下组成部分：
1、服务器名字：指正常情况下资源运行的那个节点（即主节点），后跟一个空格或tab；这里指定的名字必须跟某个节点上的命令"uname -n"的返回值相同；
2、IP别名（即额外的IP地址，可选）：在启动资源之前添加至系统的附加IP地址，后跟空格或tab；IP地址后面通常会跟一个子网掩码和广播地址，彼此间用“/”隔开；
3、资源脚本：即用来启动或停止资源的脚本，位于/etc/init.d/或/etc/ha.d/resourcd.d目录中；如果需要传递参数给资源脚本，脚本和参数之间需要用两个冒号分隔，多个参数时彼此间也需要用两个冒号分隔；如果有多个资源脚本，彼此间也需要使用空格隔开；

 格式如下：
 primary-server [IPaddress[/mask/interface/broadcast]]  resource1[::arg1::arg2]  resource2[::arg1::arg2]
 
 例如：
 primary-server 221.67.132.195 sendmail httpd


实验一：
RHEL5.8 32bit
heartbeat v1
	ha web
	node1, node2
		节点名称：用/etc/hosts文件解析
		节点名称必须跟uname -n命令的执行结果一致
		ssh互信同信
		时间要同步
node1: 
	eth0	192.168.100.6
	node1.yuliang.com
	ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
	ssh -copy-id -i .ssh/id_rsa.pub root@192.168.100.7
	vim /etc/hosts
	192.168.100.6	node1.yuliang.com
	192.168.100.7	node2.yuliang.com
	scp /etc/hosts root@192.168.100.7:/etc/
	ntpdate 192.168.0.1
	crontab -e
	*/5 **** /sbin/ntpdata 192.168.0.1 &>/dev/null
	scp /var/spool/cron/root root@192.168.100.7:/var/spool/cron

	yum install heartbeat heartbeat-devel heartbeat-gui heartbeat-ldirectord heartbeat-pils heartbeat-stonith
	cd /etc/ha.d/
	cp /usr/share/doc/heartbeat-2.1.4/{authkeys,ha.cf,haresources} ./
	ls
	vim authkeys
	auth 1 （与下来对应就行）
	1 md5 ENCRYPTOIN_PASSWORD

	vim ha.cf
		logfacility	local0(不宜与以上日志定义同时用)
		keepalive 2 多长时间发一次心跳
		initdead 等第二个节点启动时间
		mcast eth0 225.0.0.1 694 1 0 在接口上多播
		auto_failback on 故障转移过去，恢复后是否转回
		node node1.yuliang.com 集群中所有的节点必须都列出来
		node node2.yuliang.com 一定要和uname -n结果一样
	
	vim haresources(资源管理器)
		(主节点	VIP	      RA资源代理  资源代理参数..........)
		(node1	192.168.100.6 Filesystem::/dev/sda1::/data1::ext2)
		
		这个VIP由/usr/lib/heartbeat/findif脚本定义到多个网卡中与VIP属于同一网段的对应网卡的别名上
		node1.yuliang.com IPaddr::192.168.100.1/16/eth0 httpd

		(IPaddr::VIP/MASK/INTERFACE/BROADCAST_IPADDRESS)
	ls resource.d/(都是资源代理脚本)
	ls /usr/lib/heartbeat(都是heartbeat运维相关的脚本)
	service httpd stop
	chkconfig httpd off （集群中一定不能开机自启）

	scp -p authkeys haresources ha.cf node2:/etc/ha.d/
	service heartbeat start
	tail -f /var/log/messages

	/usr/lib/heartbeat/hb_standby
	tail -f /var/log/messages

	vim /etc/ha.d/haresources
		node1.yuliang.com IPaddr::192.168.100.1/16/eth0 Filesystem::192.168.100.10:/web/htdocs::/var/www/html::nfs httpd
	scp /etc/ha.d/haresources node2:/etc/ha.d/
node2:
	eth0	192.168.100.7
	node2.yuliang.com
	ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
	ssh -copy-id -i .ssh/id_rsa.pub root@192.168.100.6
	yum install heartbeat heartbeat-devel heartbeat-gui heartbeat-ldirectord heartbeat-pils heartbeat-stonith


nfs:

实验二：
heartbeat v2，作为一个服务提供一个套接字接口，管理空间提高（如GUI界面），相当一个API
v2版本crmd为那些非ha-aware的应用程序提供调用的基础平台,一旦在ha.cf文件中定义crm respawn，那么此平台无法识别
haresources里面的定义的资源格式（不兼容），/usr/lib/heartbeat/下的haresources2cib.py脚本可以将haresources里面的资源
转换成xml格式放在/var/lib/heartbeat/crm目录里面，这样crm就可以读取
CIB：Cluster Information Base
	xml格式，语法复杂
	haresources2cid.py将harecources资源转成xml
	crm命令可以管理-->进化成pacemaker后crm命令异常强大
	
在实验一的基础上
ha.cf文件中启用crm respawn
/usr/lib/heartbeat/ha_propagate同步Node1配置文件到Node2上
启动heartbeat服务
netstat -tnlp 
mgmtd	5560

实验三：
	在实验一的基础上mysql<-->nfs
nfs:172.16.100.10
	groupadd -g 3306 mysql
	useradd -u 3306 -g mysql -s /sbin/nologin -M
	mkdir /mydata
	mount /dev/myvg/mydata /mydata
	mkdir /mydata/data
	chown -R mysql.mysql /mydata/data/
	vim /etc/exports
		/web/htdocs 172.16.0.0/255.255.0.0(ro)
		/mydata	    172.16.0.0/255.255.0.0(no_root_squash,rw)
	exportfs -arv
	
node1:172.16.100.6
	groupadd -g 3306 mysql
	useradd -g 3306 -u 3306 -s /sbin/nologin -M mysql
	mkdir /mydata
	mount 172.16.100.10:/mydata /mydata
	su - mysql(不让登)
	usermod -s /bin/bash
	su - mysql
	touch a(成功)
	usermod -s /sbin/nologin
	chown -R root:mysql /usr/local/mysql/
	cd /usr/local/mysql/
	scripts/mysql_install_db --user=mysql --datadir=/mydata/data
	cp support-files/my-large.cnf /etc/my.cnf
	vim /etc/my.cnf
		datadir=/mydata/data
		innodb_file_per_table = 1
	cp support-files/mysql.server /etc/init.d/mysqld
	chkconfig --add mysqld
	chkconfig mysqld off
	service	mysqld start
	umount /mydata

	vim /etc/ha.d/haresources
		node1.yuliang.com IPaddr::172.16.100.1/16/eth0 Filesystem::172.16.100.10:/web/htdocs::/var/www/html::nfs mysqld
	scp /etc/ha.d/haresources node2:/etc/ha.d/

node2:172.16.100.7
	groupadd -g 3306 mysql
	useradd -g 3306 -u 3306 -s /sbin/nologin -M mysql
	mkdir /mydata
	mount -t nfs 172.16.100.10:/mydata /mydata
	su - mysql(不让登)
	usermod -s /bin/bash
	su - mysql
	touch a(成功)
	usermod -s /sbin/nologin
	......
	umount /mydata

	

三个配置文件：
1、密钥文件，600权限, authkeys（两节点间加密传信）
2、heartbeat服务的配置配置ha.cf
3、资源管理配置文件haresources
/etc/ha.d/authkeys 该文件在两个版本作用是完全相同的，都必须设置，并且保证每个节点（node）内容一样；
/etc/ha.d/ha.cf 这个是主要配置文件，由其决定v1或v2 style格式
/etc/ha.d/haresources 这是v1的资源配置文件
/var/lib/heartbeat/crm/cib.xml 这是v2的资源配置文件，两者根据ha.cf的设定只能选其一


v2版本使用CRM管理工具，而cib.xml文件可有几种方式来编写：
	a）人工编写XML文件；
	b）使用admintools工具，其已经包含在heartbeat包中；
	c）使用GUI图形工具配置，也包含在heartbeat-gui包里面；
	d）使用python脚本转换1.x style的格式配置文件。


# more /etc/ha.d/ha.cf
#发送keepalive包的间隔时间
keepalive 2
#定义节点的失效时间
deadtime 30
#定义heartbeat服务启动后，等待外围其他设备（如网卡启动等）的等待时间
initdead 30
#使用udp端口694 进行心跳监测
udpport 694
#定义心跳
bcast   eth0 eth1               # Linux
#定义是否使用auto_failback功能
auto_failback off
#定义集群的节点
node    hatest3
node    hatest4
#使用heartbeat提供的日志服务，若use_logd设置为yes后，下面的三个选项会失效
use_logd yes
#logfile /var/log/ha_log/ha-log.log
#logfacility local7
#debugfile /var/log/ha_log/ha-debug.log
#设定一个监控网关，用于判断心跳是否正常
ping 192.168.0.254
deadping 5
#指定和heartbeat一起启动、关闭的进程
respawn hacluster /usr/local/lib64/heartbeat/ipfail
apiauth ipfail gid=haclient uid=hacluster


HA的LVS集群有两台Director，在启动时，主节点占有集群负载均衡资源（VIP和LVS的转发及高度规则），备用节点监听主节点的“心跳”信息并在主节点出现异常时进行“故障转移”而取得资源使用权，这包括如下步骤：
	1、添加VIP至其网络接口；
	2、广播GARP信息，通知网络内的其它主机目前本Director其占有VIP；
	3、创建IPVS表以实现入站请求连接的负载均衡；
	4、Stonith；
弃用resource脚本，改用ldirecotord来控制LVS：
ldirectord用来实现LVS负载均衡资源的在主、备节点间的故障转移。在首次启动时，ldirectord可以自动创建IPVS表。此外，它还可以监控各Realserver的运行状态，一旦发现某Realserver运行异常时，还可以将其从IPVS表中移除。
ldirectord进程通过向Realserver的RIP发送资源访问请求并通过由Realserver返回的响应信息来确定Realserver的运行状态。在Director上，每一个VIP需要一个单独的ldirector进程。如果Realserver不能正常响应Directord上ldirectord的请求，ldirectord进程将通过ipvsadm命令将此Realserver从IPVS表中移除。而一旦Realserver再次上线，ldirectord会使用正确的ipvsadm命令将其信息重新添加至IPVS表中。
例如，为了监控一组提供web服务的Realserver，ldirectord进程使用HTTP协议请求访问每台Realserver上的某个特定网页。ldirectord进程根据自己的配置文件中事先定义了的Realserver的正常响应结果来判断当前的返回结果是否正常。比如，在每台web服务器的网站目录中存放一个页面".ldirector.html"，其内容为"GOOD"，ldirectord进程每隔一段时间就访问一次此网页，并根据获取到的响应信息来判断Realserver的运行状态是否正常。如果其返回的信息不是"GOOD"，则表明服务不正常。
ldirectord需要从/etc/ha.d/目录中读取配置文件，文件名可以任意，但建议最好见名知义。
实现过程：

创建/etc/ha.d/ldirectord-192.168.0.219.cf，添加如下内容：
# Global Directives
checktimeout=20    
# ldirectord等待Realserver健康检查完成的时间，单位为秒；
# 任何原因的检查错误或超过此时间限制，ldirector将会将此Realserver从IPVS表中移除；
checkinterval=5
# 每次检查的时间间隔，即检查的频率；
autoreload=yes
# 此项用来定义ldirectord是否定期每隔一段时间检查此配置文件是否发生改变并自动重新加载此文件；
logfile="/var/log/ldirectord.log"
# 定义日志文件存放位置；
quiescent=yes
# 当某台Realserver出现异常，此项可将其设置为静默状态（即其权重为“0”）从而不再响应客户端的访问请求；

# For an http virtual service
virtual=192.168.0.219:80
# 此项用来定义LVS服务及其使用的VIP和PORT
        real=192.168.0.221:80 gate 100
        # 定义Realserver，语法：real=RIP:port gate|masq|ipip [weight]
        real=192.168.0.223:80 gate 300
        fallback=127.0.0.1:80 gate
        # 当IPVS表没有任何可用的Realserver时，此“地址：端口”作为最后响应的服务；
        # 一般指向127.0.0.1，并可以通过一个包含错误信息的页面通知用户服务发生了异常；
        service=http
        # 定义基于什么服务来测试Realserver；
        request=".ldirectord.html"
        receive="GOOD"
        scheduler=wlc 
        #persistent=600
        #netmask=255.255.255.255
        protocol=tcp
        # 定义此虚拟服务用到的协议；
        checktype=negotiate
        # ldirectord进程用于监控Realserver的方法；{negotiate|connect|A number|off}
        checkport=80
        
在/etc/hd.d/haresources中添加类似如下行：
 node1.example.com 192.168.0.219 ldirectord::ldirectord-192.168.0.219.cf       




corosync --> pacemaker
	SUSE Linux Enterprise Server: Hawk, WebGUI
	LCMC: Linux Cluster Management Console

	RHCS: Conga(luci/ricci)，红帽专用
		webGUI
		三层：第一层只装ricci不用装pacemaker,corosync
		      第二层装luci，用来连接第一层
		      第三层通过web连到luci上，用yum安装pacemaker,corosync到每个节点上，进行一切管理
		RHCS: 
		1、每个集群都有惟一集群名称；
		2、至少有一个fence设备；
		3、至少应该有三个节点；两个节点的场景中要使用qdisk；

	keepalived: VRRP, 2节点

	pacemaker原生制作依赖于heartbeat v3，不想依赖要自己制作
		 既然安装了heartbeat v3，没corosync也行，但是这
		 里用的就是corosync，heartbeat v3不启动即可


########################### corosync pacemaker 实战 ##################################

前提：
1）本配置共有两个测试节点，分别node1.magedu.com和node2.magedu.com，相的IP地址分别为172.16.100.11和172.16.100.12；
2）集群服务为apache的httpd服务；
3）提供web服务的地址为172.16.100.1；
4）系统为rhel5.8

1、准备工作

为了配置一台Linux主机成为HA的节点，通常需要做出如下的准备工作：

1）所有节点的主机名称和对应的IP地址解析服务可以正常工作，且每个节点的主机名称需要跟"uname -n“命令的结果保持一致；因此，需要保证两个节点上的/etc/hosts文件均为下面的内容：
172.16.100.11   node1.magedu.com node1
172.16.100.12   node2.magedu.com node2

为了使得重新启动系统后仍能保持如上的主机名称，还分别需要在各节点执行类似如下的命令：

Node1:
# sed -i 's@\(HOSTNAME=\).*@\1node1.magedu.com@g'  /etc/sysconfig/network
# hostname node1.magedu.com

Node2：
# sed -i 's@\(HOSTNAME=\).*@\1node2.magedu.com@g' /etc/sysconfig/network
# hostname node2.magedu.com

2）设定两个节点可以基于密钥进行ssh通信，这可以通过类似如下的命令实现：
Node1:
# ssh-keygen -t rsa
# ssh-copy-id -i ~/.ssh/id_rsa.pub root@node2

Node2:
# ssh-keygen -t rsa
# ssh-copy-id -i ~/.ssh/id_rsa.pub root@node1


2、安装如下rpm包：
libibverbs, librdmacm, lm_sensors, libtool-ltdl, openhpi-libs, openhpi, perl-TimeDate

3、安装corosync和pacemaker，首先下载所需要如下软件包至本地某专用目录（这里为/root/cluster）：
cluster-glue
cluster-glue-libs
heartbeat
resource-agents
corosync
heartbeat-libs
pacemaker
corosynclib
libesmtp
pacemaker-libs

下载地址：http://clusterlabs.org/rpm/。请根据硬件平台及操作系统类型选择对应的软件包；这里建议每个软件包都使用目前最新的版本。
  32bits rpm包下载地址：   http://clusterlabs.org/rpm/epel-5/i386/
  64bits rpm包下载地址：   http://clusterlabs.org/rpm/epel-5/x86_64/

使用如下命令安装：
# cd /root/cluster
# yum -y --nogpgcheck localinstall *.rpm

4、配置corosync，（以下命令在node1.magedu.com上执行）

# cd /etc/corosync
# cp corosync.conf.example corosync.conf

接着编辑corosync.conf，添加如下内容连带启动pacemaker：
service {
  ver:  0
  name: pacemaker
  # use_mgmtd: yes
}

aisexec {
  user: root
  group:  root
}
并稍加修改原来的配置
totem {
        version: 2
        secauth: on
        threads: 2
        interface {
                ringnumber: 0
                bindnetaddr: 192.168.3.0
                mcastaddr: 226.94.1.7
                mcastport: 5405
        }
}
logging {
        fileline: off
        to_stderr: no
        to_logfile: yes
        to_syslog: no
        logfile: /var/log/cluster/corosync.log
        debug: off
        timestamp: on
        logger_subsys {
                subsys: AMF
                debug: off
        }
}
man 5 corosync.conf精读配置命令

并设定此配置文件中 bindnetaddr后面的IP地址为你的网卡所在网络的网络地址，我们这里的两个节点在172.16.0.0网络，因此这里将其设定为172.16.0.0；如下
bindnetaddr: 172.16.0.0

生成节点间通信时用到的认证密钥文件：
# corosync-keygen

将corosync和authkey复制至node2:
# scp -p corosync authkey  node2:/etc/corosync/

分别为两个节点创建corosync生成的日志所在的目录：
# mkdir /var/log/cluster
# ssh node2  'mkdir /var/log/cluster'

5、尝试启动，（以下命令在node1上执行）：

# /etc/init.d/corosync start

查看corosync引擎是否正常启动：
# grep -e "Corosync Cluster Engine" -e "configuration file" /var/log/messages
Jun 14 19:02:08 node1 corosync[5103]:   [MAIN  ] Corosync Cluster Engine ('1.2.7'): started and ready to provide service.
Jun 14 19:02:08 node1 corosync[5103]:   [MAIN  ] Successfully read main configuration file '/etc/corosync/corosync.conf'.
Jun 14 19:02:08 node1 corosync[5103]:   [MAIN  ] Corosync Cluster Engine exiting with status 8 at main.c:1397.
Jun 14 19:03:49 node1 corosync[5120]:   [MAIN  ] Corosync Cluster Engine ('1.2.7'): started and ready to provide service.
Jun 14 19:03:49 node1 corosync[5120]:   [MAIN  ] Successfully read main configuration file '/etc/corosync/corosync.conf'.

查看初始化成员节点通知是否正常发出：
# grep  TOTEM  /var/log/messages
Jun 14 19:03:49 node1 corosync[5120]:   [TOTEM ] Initializing transport (UDP/IP).
Jun 14 19:03:49 node1 corosync[5120]:   [TOTEM ] Initializing transmit/receive security: libtomcrypt SOBER128/SHA1HMAC (mode 0).
Jun 14 19:03:50 node1 corosync[5120]:   [TOTEM ] The network interface [172.16.100.11] is now up.
Jun 14 19:03:50 node1 corosync[5120]:   [TOTEM ] A processor joined or left the membership and a new membership was formed.

检查启动过程中是否有错误产生：
# grep ERROR: /var/log/messages | grep -v unpack_resources

查看pacemaker是否正常启动：
# grep pcmk_startup /var/log/messages
Jun 14 19:03:50 node1 corosync[5120]:   [pcmk  ] info: pcmk_startup: CRM: Initialized
Jun 14 19:03:50 node1 corosync[5120]:   [pcmk  ] Logging: Initialized pcmk_startup
Jun 14 19:03:50 node1 corosync[5120]:   [pcmk  ] info: pcmk_startup: Maximum core file size is: 4294967295
Jun 14 19:03:50 node1 corosync[5120]:   [pcmk  ] info: pcmk_startup: Service: 9
Jun 14 19:03:50 node1 corosync[5120]:   [pcmk  ] info: pcmk_startup: Local hostname: node1.magedu.com

如果上面命令执行均没有问题，接着可以执行如下命令启动node2上的corosync
# ssh node2 -- /etc/init.d/corosync start

注意：启动node2需要在node1上使用如上命令进行，不要在node2节点上直接启动；

使用如下命令查看集群节点的启动状态：
# crm status
============
Last updated: Tue Jun 14 19:07:06 2011
Stack: openais
Current DC: node1.magedu.com - partition with quorum
Version: 1.0.11-1554a83db0d3c3e546cfd3aaff6af1184f79ee87
2 Nodes configured, 2 expected votes
0 Resources configured.
============

Online: [ node1.magedu.com node2.magedu.com ]

从上面的信息可以看出两个节点都已经正常启动，并且集群已经处于正常工作状态。

执行ps auxf命令可以查看corosync启动的各相关进程。
root      4665  0.4  0.8  86736  4244 ?        Ssl  17:00   0:04 corosync
root      4673  0.0  0.4  11720  2260 ?        S    17:00   0:00  \_ /usr/lib/heartbeat/stonithd
101       4674  0.0  0.7  12628  4100 ?        S    17:00   0:00  \_ /usr/lib/heartbeat/cib
root      4675  0.0  0.3   6392  1852 ?        S    17:00   0:00  \_ /usr/lib/heartbeat/lrmd
101       4676  0.0  0.4  12056  2528 ?        S    17:00   0:00  \_ /usr/lib/heartbeat/attrd
101       4677  0.0  0.5   8692  2784 ?        S    17:00   0:00  \_ /usr/lib/heartbeat/pengine
101       4678  0.0  0.5  12136  3012 ?        S    17:00   0:00  \_ /usr/lib/heartbeat/crmd


6、配置集群的工作属性，禁用stonith

corosync默认启用了stonith，而当前集群并没有相应的stonith设备，因此此默认配置目前尚不可用，这可以通过如下命令验正：

# crm_verify -L 
crm_verify[5202]: 2011/06/14_19:10:38 ERROR: unpack_resources: Resource start-up disabled since no STONITH resources have been defined
crm_verify[5202]: 2011/06/14_19:10:38 ERROR: unpack_resources: Either configure some or disable STONITH with the stonith-enabled option
crm_verify[5202]: 2011/06/14_19:10:38 ERROR: unpack_resources: NOTE: Clusters with shared data need STONITH to ensure data integrity
Errors found during check: config not valid
  -V may provide more details

我们里可以通过如下命令先禁用stonith：
# crm configure property stonith-enabled=false

使用如下命令查看当前的配置信息：
# crm configure show
node node1.magedu.com
node node2.magedu.com
property $id="cib-bootstrap-options" \
  dc-version="1.0.11-1554a83db0d3c3e546cfd3aaff6af1184f79ee87" \
  cluster-infrastructure="openais" \
  expected-quorum-votes="2" \
  stonith-enabled="false
  
从中可以看出stonith已经被禁用。

上面的crm，crm_verify命令是1.0后的版本的pacemaker提供的基于命令行的集群管理工具；可以在集群中的任何一个节点上执行。

7、为集群添加集群资源

corosync支持heartbeat，LSB和ocf等类型的资源代理，目前较为常用的类型为LSB和OCF两类，stonith类专为配置stonith设备而用；

可以通过如下命令查看当前集群系统所支持的类型：

# crm ra classes 
heartbeat
lsb
ocf / heartbeat pacemaker
stonith

如果想要查看某种类别下的所用资源代理的列表，可以使用类似如下命令实现：
# crm ra list lsb
# crm ra list ocf heartbeat
# crm ra list ocf pacemaker
# crm ra list stonith

# crm ra info [class:[provider:]]resource_agent
例如：
# crm ra info ocf:heartbeat:IPaddr

8、接下来要创建的web集群创建一个IP地址资源，以在通过集群提供web服务时使用；这可以通过如下方式实现：

语法：
primitive <rsc> [<class>:[<provider>:]]<type>
          [params attr_list]
          [operations id_spec]
            [op op_type [<attribute>=<value>...] ...]

op_type :: start | stop | monitor

例子：
 primitive apcfence stonith:apcsmart \
          params ttydev=/dev/ttyS0 hostlist="node1 node2" \
          op start timeout=60s \
          op monitor interval=30m timeout=60s

在bash下应用：
# crm configure primitive WebIP ocf:heartbeat:IPaddr params ip=172.16.100.1
# crm_mon --one-shot

在交互式模式下应用：
crm(live)configure# primitive WebIP ocf:heartbeat:IPaddr params ip=172.16.100.1
crm(live)configure# verify
crm(live)configure# commit
crm(live)configure# show
crm(live)configure# show xml
停止资源
crm(live)resource# stop webip
crm(live)resource# list

通过如下的命令执行结果可以看出此资源已经在node1.magedu.com上启动：
# crm status
============
Last updated: Tue Jun 14 19:31:05 2011
Stack: openais
Current DC: node1.magedu.com - partition with quorum
Version: 1.0.11-1554a83db0d3c3e546cfd3aaff6af1184f79ee87
2 Nodes configured, 2 expected votes
1 Resources configured.
============

Online: [ node1.magedu.com node2.magedu.com ]

 WebIP  (ocf::heartbeat:IPaddr):  Started node1.magedu.com

当然，也可以在node1上执行ifconfig命令看到此地址已经在eth0的别名上生效：
# ifconfig 
eth0:0    Link encap:Ethernet  HWaddr 00:0C:29:AA:DD:CF  
          inet addr:172.16.100.1  Bcast:192.168.0.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          Interrupt:67 Base address:0x2000 
          
而后我们到node2上通过如下命令停止node1上的corosync服务：
# ssh node1 -- /etc/init.d/corosync stop

查看集群工作状态：
# crm status
============
Last updated: Tue Jun 14 19:37:23 2011
Stack: openais
Current DC: node2.magedu.com - partition WITHOUT quorum
Version: 1.0.11-1554a83db0d3c3e546cfd3aaff6af1184f79ee87
2 Nodes configured, 2 expected votes
1 Resources configured.
============

Online: [ node2.magedu.com ]
OFFLINE: [ node1.magedu.com ]

上面的信息显示node1.magedu.com已经离线，但资源WebIP却没能在node2.magedu.com上启动。这是因为此时的集群状态为"WITHOUT quorum"，即已经失去了quorum，此时集群服务本身已经不满足正常运行的条件，这对于只有两节点的集群来讲是不合理的。因此，我们可以通过如下的命令来修改忽略quorum不能满足的集群状态检查：

# crm configure property no-quorum-policy=ignore

片刻之后，集群就会在目前仍在运行中的节点node2上启动此资源了，如下所示：
# crm status
============
Last updated: Tue Jun 14 19:43:42 2011
Stack: openais
Current DC: node2.magedu.com - partition WITHOUT quorum
Version: 1.0.11-1554a83db0d3c3e546cfd3aaff6af1184f79ee87
2 Nodes configured, 2 expected votes
1 Resources configured.
============

Online: [ node2.magedu.com ]
OFFLINE: [ node1.magedu.com ]

 WebIP  (ocf::heartbeat:IPaddr):  Started node2.magedu.com
 
好了，验正完成后，我们正常启动node1.magedu.com:
# ssh node1 -- /etc/init.d/corosync start

正常启动node1.magedu.com后，集群资源WebIP很可能会重新从node2.magedu.com转移回node1.magedu.com。资源的这种在节点间每一次的来回流动都会造成那段时间内其无法正常被访问，所以，我们有时候需要在资源因为节点故障转移到其它节点后，即便原来的节点恢复正常也禁止资源再次流转回来。这可以通过定义资源的黏性(stickiness)来实现。在创建资源时或在创建资源后，都可以指定指定资源黏性。

资源黏性值范围及其作用：
0：这是默认选项。资源放置在系统中的最适合位置。这意味着当负载能力“较好”或较差的节点变得可用时才转移资源。此选项的作用基本等同于自动故障回复，只是资源可能会转移到非之前活动的节点上；
大于0：资源更愿意留在当前位置，但是如果有更合适的节点可用时会移动。值越高表示资源越愿意留在当前位置；
小于0：资源更愿意移离当前位置。绝对值越高表示资源越愿意离开当前位置；
INFINITY：如果不是因节点不适合运行资源（节点关机、节点待机、达到migration-threshold 或配置更改）而强制资源转移，资源总是留在当前位置。此选项的作用几乎等同于完全禁用自动故障回复；
-INFINITY：资源总是移离当前位置；

我们这里可以通过以下方式为资源指定默认黏性值：
# crm configure rsc_defaults resource-stickiness=100

9、结合上面已经配置好的IP地址资源，将此集群配置成为一个active/passive模型的web（httpd）服务集群

为了将此集群启用为web（httpd）服务器集群，我们得先在各节点上安装httpd，并配置其能在本地各自提供一个测试页面。

Node1:
# yum -y install httpd
# echo "<h1>Node1.magedu.com</h1>" > /var/www/html/index.html

Node2:
# yum -y install httpd
# echo "<h1>Node2.magedu.com</h1>" > /var/www/html/index.html

而后在各节点手动启动httpd服务，并确认其可以正常提供服务。接着使用下面的命令停止httpd服务，并确保其不会自动启动（在两个节点各执行一遍）：
# /etc/init.d/httpd stop
# chkconfig httpd off


接下来我们将此httpd服务添加为集群资源。将httpd添加为集群资源有两处资源代理可用：lsb和ocf:heartbeat，为了简单起见，我们这里使用lsb类型：

首先可以使用如下命令查看lsb类型的httpd资源的语法格式：
# crm ra info lsb:httpd
lsb:httpd

Apache is a World Wide Web server.  It is used to serve \
         HTML files and CGI.

Operations' defaults (advisory minimum):

    start         timeout=15
    stop          timeout=15
    status        timeout=15
    restart       timeout=15
    force-reload  timeout=15
    monitor       interval=15 timeout=15 start-delay=15

接下来新建资源WebSite：
# crm configure primitive WebSite lsb:httpd

查看配置文件中生成的定义：
node node1.magedu.com
node node2.magedu.com
primitive WebIP ocf:heartbeat:IPaddr \
  params ip="172.16.100.1"
primitive WebSite lsb:httpd
property $id="cib-bootstrap-options" \
  dc-version="1.0.11-1554a83db0d3c3e546cfd3aaff6af1184f79ee87" \
  cluster-infrastructure="openais" \
  expected-quorum-votes="2" \
  stonith-enabled="false" \
  no-quorum-policy="ignore"
  
查看资源的启用状态：
# crm status
============
Last updated: Tue Jun 14 19:57:31 2011
Stack: openais
Current DC: node2.magedu.com - partition with quorum
Version: 1.0.11-1554a83db0d3c3e546cfd3aaff6af1184f79ee87
2 Nodes configured, 2 expected votes
2 Resources configured.
============

Online: [ node1.magedu.com node2.magedu.com ]

 WebIP  (ocf::heartbeat:IPaddr):  Started node1.magedu.com
 WebSite  (lsb:httpd):  Started node2.magedu.com
 
从上面的信息中可以看出WebIP和WebSite有可能会分别运行于两个节点上，这对于通过此IP提供Web服务的应用来说是不成立的，即此两者资源必须同时运行在某节点上。

由此可见，即便集群拥有所有必需资源，但它可能还无法进行正确处理。资源约束则用以指定在哪些群集节点上运行资源，以何种顺序装载资源，以及特定资源依赖于哪些其它资源。pacemaker共给我们提供了三种资源约束方法：
1）Resource Location（资源位置）：定义资源可以、不可以或尽可能在哪些节点上运行；
2）Resource Collocation（资源搭配）：搭配约束用以定义集群资源可以或不可以在某个节点上同时运行；
3）Resource Order（资源顺序）：顺序约束定义集群资源在节点上启动的顺序；

定义约束时，还需要指定分数。各种分数是集群工作方式的重要组成部分。其实，从迁移资源到决定在已降级集群中停止哪些资源的整个过程是通过以某种方式修改分数来实现的。分数按每个资源来计算，资源分数为负的任何节点都无法运行该资源。在计算出资源分数后，集群选择分数最高的节点。INFINITY（无穷大）目前定义为 1,000,000。加减无穷大遵循以下3个基本规则：
1）任何值 + 无穷大 = 无穷大
2）任何值 - 无穷大 = -无穷大
3）无穷大 - 无穷大 = -无穷大

定义资源约束时，也可以指定每个约束的分数。分数表示指派给此资源约束的值。分数较高的约束先应用，分数较低的约束后应用。通过使用不同的分数为既定资源创建更多位置约束，可以指定资源要故障转移至的目标节点的顺序。

因此，对于前述的WebIP和WebSite可能会运行于不同节点的问题，可以通过以下命令来解决：
# crm configure colocation website-with-ip INFINITY: WebSite WebIP

接着，我们还得确保WebSite在某节点启动之前得先启动WebIP，这可以使用如下命令实现：
# crm configure order httpd-after-ip mandatory: WebIP WebSite

此外，由于HA集群本身并不强制每个节点的性能相同或相近，所以，某些时候我们可能希望在正常时服务总能在某个性能较强的节点上运行，这可以通过位置约束来实现：
crm(live)configure# location prefer_node WebSite 200: node1.yuliang.com
这条命令实现了将WebSite约束在node1上，且指定其分数为200；

# crm crm(live)
# cib new active
INFO: active shadow CIB created
crm(active) # configure clone WebIP ClusterIP \
    meta globally-unique="true" clone-max="2" clone-node-max="2"
crm(active) # configure shownode pcmk-1
node pcmk-2
primitive WebData ocf:linbit:drbd \
    params drbd_resource="wwwdata" \
    op monitor interval="60s"
primitive WebFS ocf:heartbeat:Filesystem \
    params device="/dev/drbd/by-res/wwwdata" directory="/var/www/html" fstype="gfs2"
primitive WebSite ocf:heartbeat:apache \
    params configfile="/etc/httpd/conf/httpd.conf" \
    op monitor interval="1min"
primitive ClusterIP ocf:heartbeat:IPaddr2 \
    params ip="192.168.122.101" cidr_netmask="32" clusterip_hash="sourceip" \
    op monitor interval="30s"
ms WebDataClone WebData \
    meta master-max="1" master-node-max="1" clone-max="2" clone-node-max="1" notify="true"
clone WebIP ClusterIP \
    meta globally-unique="true" clone-max="2" clone-node-max="2"
colocation WebSite-with-WebFS inf: WebSite WebFS
colocation fs_on_drbd inf: WebFS WebDataClone:Master
colocation website-with-ip inf: WebSite WebIPorder WebFS-after-WebData inf: WebDataClone:promote WebFS:start
order WebSite-after-WebFS inf: WebFS WebSiteorder apache-after-ip inf: WebIP WebSite
property $id="cib-bootstrap-options" \
    dc-version="1.1.5-bdd89e69ba545404d02445be1f3d72e6a203ba2f" \
    cluster-infrastructure="openais" \
    expected-quorum-votes="2" \
    stonith-enabled="false" \
    no-quorum-policy="ignore"
rsc_defaults $id="rsc-options" \
    resource-stickiness="100"


1、所有realserver都down，如何处理？
2、自写监测脚本，完成维护模式切换？
3、如何在vrrp事务发生时，发送警告邮件给指定的管理员？

vrrp_script chk_haproxy {
    script "killall -0 haproxy"
    interval 2
        # check every 2 seconds
    weight -2
        # if failed, decrease 2 of the priority
    fall 2
        # require 2 failures for failures
    rise 1
        # require 1 sucesses for ok
}


vrrp_script chk_name {
		script ""
		inerval #
		weight #
		fall 2
		rise 1
}


    track_script {
        chk_schedown
    }


Paxos算法

在网络拥塞控制领域，我们知道有一个非常有名的算法叫做Nagle算法（Nagle algorithm），这是使用它的发明人John Nagle的名字来命名的，John Nagle在1984年首次用这个算法来尝试解决福特汽车公司的网络拥塞问题（RFC 896），该问题的具体描述是：如果我们的应用程序一次产生1个字节的数据，而这个1个字节数据又以网络数据包的形式发送到远端服务器，那么就很容易导致网络由于太多的数据包而过载。比如，当用户使用Telnet连接到远程服务器时，每一次击键操作就会产生1个字节数据，进而发送出去一个数据包，所以，在典型情况下，传送一个只拥有1个字节有效数据的数据包，却要发费40个字节长包头（即ip头20字节+tcp头20字节）的额外开销，这种有效载荷（payload）利用率极其低下的情况被统称之为愚蠢窗口症候群（Silly Window Syndrome）。可以看到，这种情况对于轻负载的网络来说，可能还可以接受，但是对于重负载的网络而言，就极有可能承载不了而轻易的发生拥塞瘫痪。
针对上面提到的这个状况，Nagle算法的改进在于：如果发送端欲多次发送包含少量字符的数据包（一般情况下，后面统一称长度小于MSS的数据包为小包，与此相对，称长度等于MSS的数据包为大包，为了某些对比说明，还有中包，即长度比小包长，但又不足一个MSS的包），则发送端会先将第一个小包发送出去，而将后面到达的少量字符数据都缓存起来而不立即发送，直到收到接收端对前一个数据包报文段的ACK确认、或当前字符属于紧急数据，或者积攒到了一定数量的数据（比如缓存的字符数据已经达到数据包报文段的最大长度）等多种情况才将其组成一个较大的数据包发送出去。

TCP中的Nagle算法默认是启用的，但是它并不是适合任何情况，对于telnet或rlogin这样的远程登录应用的确比较适合（原本就是为此而设计），但是在某些应用场景下我们却又需要关闭它。 

Negale算法是指发送方发送的数据不会立即发出, 而是先放在缓冲区, 等缓存区满了再发出. 发送完一批数据后, 会等待接收方对这批数据的回应, 然后再发送下一批数据。Negale 算法适用于发送方需要发送大批量数据, 并且接收方会及时作出回应的场合, 这种算法通过减少传输数据的次数来提高通信效率。如果发送方持续地发送小批量的数据, 并且接收方不一定会立即发送响应数据, 那么Negale算法会使发送方运行很慢. 对于GUI 程序, 如网络游戏程序(服务器需要实时跟踪客户端鼠标的移动), 这个问题尤其突出. 客户端鼠标位置改动的信息需要实时发送到服务器上, 由于Negale 算法采用缓冲, 大大减低了实时响应速度, 导致客户程序运行很慢。这个时候就需要使用TCP_NODELAY选项。


原理简介

　　组播报文的目的地址使用D类IP地址， 范围是从224.0.0.0到239.255.255.255。D类地址不能出现在IP报文的源IP地址字段。单播数据传输过程中，一个数据包传输的路径是从源地址路由到目的地址，利用“逐跳”（hop-by-hop）的原理在IP网络中传输。然而在ip组播环中，数据包的目的地址不是一个，而是一组，形成组地址。所有的信息接收者都加入到一个组内，并且一旦加入之后，流向组地址的数据立即开始向接收者传输，组中的所有成员都能接收到数据包。组播组中的成员是动态的，主机可以在任何时刻加入和离开组播组。


组播组分类
　　组播组可以是永久的也可以是临时的。组播组地址中，有一部分由官方分配的，称为永久组播组。永久组播组保持不变的是它的ip地址，组中的成员构成可以发生变化。永久组播组中成员的数量都可以是任意的，甚至可以为零。那些没有保留下来供永久组播组使用的ip组播地址，可以被临时组播组利用。
　　224.0.0.0～224.0.0.255为预留的组播地址（永久组地址），地址224.0.0.0保留不做分配，其它地址供路由协议使用；
　　224.0.1.0～224.0.1.255是公用组播地址，可以用于Internet；
　　224.0.2.0～238.255.255.255为用户可用的组播地址（临时组地址），全网范围内有效；
　　239.0.0.0～239.255.255.255为本地管理组播地址，仅在特定的本地范围内有效。


常用预留组播地址
　　列表如下：
　　224.0.0.0 基准地址（保留）
　　224.0.0.1 所有主机的地址 （包括所有路由器地址）
　　224.0.0.2 所有组播路由器的地址
　　224.0.0.3 不分配
　　224.0.0.4 dvmrp 路由器
　　224.0.0.5 ospf 路由器
　　224.0.0.6 ospf dr
　　224.0.0.7 st 路由器
　　224.0.0.8 st 主机
　　224.0.0.9 rip-2 路由器
　　224.0.0.10 Eigrp 路由器
　　224.0.0.11 活动代理
　　224.0.0.12 dhcp 服务器/中继代理
　　224.0.0.13 所有pim 路由器
　　224.0.0.14 rsvp 封装
　　224.0.0.15 所有cbt 路由器
　　224.0.0.16 指定sbm
　　224.0.0.17 所有sbms
　　224.0.0.18 vrrp
　　以太网传输单播ip报文的时候，目的mac地址使用的是接收者的mac地址。但是在传输组播报文时，传输目的不再是一个具体的接收者，而是一个成员不确定的组，所以使用的是组播mac地址。组播mac地址是和组播ip地址对应的。iana（internet assigned number authority）规定，组播mac地址的高24bit为0x01005e，mac 地址的低23bit为组播ip地址的低23bit。
　　由于ip组播地址的后28位中只有23位被映射到mac地址，这样就会有32个ip组播地址映射到同一mac地址上。



作业：
某公司的站点，平均页面对象有60个，静态内容45个，动态内容15个，并发访问量峰值有4000个/秒，日常访问量为2500个/秒；经测试，公司的服务器对动态内容的响应能力为500个/秒，对静态内容的响应能力为10000个/秒；混合响应能力为700个/秒；假设对数据的访问需求使用一台MySQL即可完成响应。
公司页面主要提供的服务为Discuz!X2.5所提供的论坛程序，允许用户上传附件。公司计划重新改造升级此系统，因此，需要重新设计此应用。请给出你的设计。



