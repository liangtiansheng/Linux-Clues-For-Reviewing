!!!!!!!!!注意：下文提到的ip_conntrack在CenterOS6以后被nf_conntrack取代，位置也稍有不同!!!!!!!!!

Linux：网络防火墙
	netfilter: Frame
	iptables: 数据报文过滤，NAT、mangle等规则生成的工具；

***数据报文的两条出路：
PREROUTING-->Routing Decision-->FORWARD-->POSTROUTING-->从网卡出去
PREROUTING-->Routing Decision-->INPUT-->Local Process-->OUTPUT-->POSTROUTING-->从网卡出去

网络：根据IP报文首部，TCP报文首部来制定规则

规则：匹配标准
	IP: SIP, DIP
	TCP: SPORT, DPORT 
		tcp第一次握手规格：SYN=1,FIN=0,RST=0,ACK=0;   
		tcp第二次握手规格：SYN=1,ACK=1,FIN=0,RST=0; 
		tcp第三次握手规格：ACK=1,SYN=0,RST=0,FIN=0(ESTABLISHED)
	UDP: SPORT, DPORT
	ICMP：icmp-type
iptables：四表五链
	添加规则时的考量点：
		1、要实现哪种功能，判断添加在哪张表上
		2、报文流经的路径，判断添加在哪个链上
	链：链上规则的次序，即为检查的次序，因此隐含一定的法则
		1、同类规则，匹配范围小的放上面
		2、不同类规则，匹配到报文频率大的放上面
		3、将那些可由一条规则描述的多个规则合并为一个
		4、设置默认策略

filter(过滤)：表
	INPUT
	OUTPUT
	FORWARD

nat(地址转换)：表
	PREROUTING
	OUTPUT
	POSTROUTING

mangle(拆开、修改、封装)：表
	PREROUTING
	INPUT
	FORWARD
	OUTPUT
	POSTROUTING

raw():只能放在下面两个链上
	PREROUTING
	OUTPUT

***规则链太多
*能否使用自定义链？
	可以使用自定链，但只在被调用时才能发挥作用，而且如果没有自定义链中的任何规则匹配，还应该有返回机制；
	用户可以删除自定义的空链
	默认链无法删除

*每个规则都有两个内置的计数器:
	1、pkts：被匹配的报文个数
	2、bytes：被匹配的报文大小之和
	数字越大匹配次数越多，如果相似的多条链上链匹配次数在增,下链没变，说明上链匹配取代了或不执行下链，要汇总


****规则：匹配标准，处理动作
	iptables [-t TABLE] COMMAND CHAIN [num] 匹配标准 -j 处理办法

匹配标准：
	通用匹配
		-s, --src: 指定源地址
		-d, --dst：指定目标地址
		-p {tcp|udp|icmp}：指定协议
		-i INTERFACE: 指定数据报文流入的接口
			可用于定义标准的链：PREROUTING,INPUT,FORWARD
		-o INTERFACE: 指定数据报文流出的接口
			可用于标准定义的链：OUTPUT,POSTROUTING,FORWARD
	扩展匹配(man iptables-extensions)
		隐含扩展：对-p protocal指明的协议进行的扩展，可省略-m选项
			-p tcp
				--sport PORT[-PORT]: 源端口
				--dport PORT[-PORT]: 目标端口
				--tcp-flags mask comp（mask列表和comp列表之间用空格隔开，各自列表用逗号隔开，mask是列表范围，comp指定mask里面相同的标记都为1其余为0）
					SYN ACK FIN RST PUSH(立即发送，不缓存) URG(紧急是否有效)
					--tcp-flags SYN,FIN,ACK,RST SYN 
						这就表示SYN为1其余都为0，相当于--syn第一次握手
					--tcp-flags ALL NONE
						匹配所有标记都未置1的包
				--syn：表示是否为新生请求的第一次握手

			-p icmp
				--icmp-type 
					0: echo-reply
					8: echo-request
						# iptables -A OUTPUT -s 172.16.100.9/24 -p icmp --icmp-type 8 -j ACCEPT
						# iptables -A INPUT -d 172.16.100.9/24 -p icmp --icmp-type 0 -j ACCEPT

			-p udp
				--sport
				--dport

			
		显式扩展: 使用额外的匹配机制
			
			-m EXTESTION --spe-opt

			state: 状态扩展、追踪功能由内核完成，在繁忙服务器上消耗很大
				调整连接追踪功能所能够容纳的最大连接数量(CenterOS6以前是ip_conntrack)
					/proc/sys/net/nf_conntrack_max
				已经追踪到并记录下的连接
					/proc/net/nf_conntrack
				结合ip_conntrack连接追踪会话的状态
					NEW: 新连接请求
					ESTABLISHED：已建立的连接
					INVALID：非法连接
					RELATED：相关联的
						如vsftpd协议命令连接与数据连接之间的关系
                            主动FTP：
                            　　命令连接：客户端 >1023端口 -> 服务器 21端口
                            　　数据连接：客户端 >1023端口 <- 服务器 20端口 
                        　　被动FTP：
                            　　命令连接：客户端 >1023端口 -> 服务器 21端口
                            　　数据连接：客户端 >1023端口 -> 服务器 >1023端口 
				首先要装载ip_conntrack_ftp和ip_nat_ftp模块
				#iptables -A INPUT -d 172.16.100.7/24 -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
				
				对80端口伪装木马、不允许新请求出去
				#iptables -I INPUT -d 172.16.100.9/24 -p tcp --dport 80 -m stat --stat NEW,ESTABLISHED -j ACCEPT
				#iptables -I OUTPUT -s 172.16.100.9/24 -p tcp --sport 80 -m stat --stat ESTABLISHED -j ACCEPT
			multiport: 离散的多端口匹配扩展
				--source-ports
				--destination-ports
				--ports

			-m multiport --destination-ports 21,22,80 -j ACCEPT
			-m iprange：匹配地址范围
				--src-range
				--dst-range

				-s, -d
				-s IP, NET
					172.16.0.0/16, 172.16.100.3-172.16.100.100

				iptables -A INPUT -p tcp --dport 22 -m iprange --src-range 172.16.100.3-172.16.100.100 -m state --state NEW,ESTABLISHED -j ACCEPT

			-m connlimit: 连接数限制（迅雷，bt等多线程软件）
				! --connlimit-above n：连接的数量大于n
				--connlimit-upto n：连接的数量小于等于n

					iptables -A INPUT -d 172.16.100.7/24 -p tcp --dport 80 -m connlimit !--connlimit-above 2 -j ACCEPT
					iptables -A INPUT -d 172.16.100.7/24 -p tcp --dport 80 -m connlimit --connlimit-above 2 -j DROP
			
			-m limit：控制服务器被正常访问机制（避免人蜂拥而至资源过耗）
				令牌桶过滤器(类似摩天轮排队原理)
				--limit RATE：控制每秒可以访问多少人
				--limit-burst ：控制一批拥入可以多少人
					iptables -R INPUT 3 -d 172.16.100.7/24 -p icmp --icmp-type 8 -m limit --limit 5/minute --limit-burst 6 -j ACCEPT
					iptables -R OUTPUT 1 -S 172.16.100.7/24 -m state --state RELATED,ESTABLISHED -j ACCEPT

			-m string：可以限定访问内容中的字符串（2.6.14内核以上）
				--algo {bm|kmp}
					字符串比对算法，必须选项
				--string "STRING"
					*注意请求的页面是从服务器出去的，如果是请求服务器INPUT那么限定的就只能是网址
					iptables -I OUTPUT 1 -s 172.16.100.7/24 -m string --algo kmp --string "h7n9" -j REJECT

-j TARGET
	LOG
		--log-prefix "STRING"
			*注意放的位置如果前面有ACCEPT或DROP那就直接匹配了，此时就不会生效，要写在其前面
			iptables -I INPUT 4 -d 172.16.100.7/24 -p icmp --icmp-type 8 -j LOG --log-prefix "--firewall log for icmp--"


条件取反：!，-s ! 172.16.100.6

命令：
	管理规则
		-A：附加一条规则，添加在链的尾部
		-I CHAIN [num]: 插入一条规则，插入为对应CHAIN上的第num条；
		-D CHAIN [num]: 删除指定链中的第num条规则；
		-R CHAIN [num]: 替换指定的规则；
	管理链：
		-F [CHAIN]：flush，清空指定规则链，如果省略CHAIN，则可以实现删除对应表中的所有链
		-P CHAIN: 设定指定链的默认策略；
		-N：自定义一个新的空链
		-X: 删除一个自定义的空链，默认清除所有自定义空链
		-Z：置零指定链中所有规则的计数器；
		-E: 重命名自定义的链；
	查看类：
		-L: 显示指定表中的规则；
			-n: 以数字格式显示主机地址和端口号；
			-v: 显示链及规则的详细信息
			-vv: 
			-x: 显示计数器的精确值
			--line-numbers: 显示规则号码

动作(target)：
	ACCEPT：放行
	DROP：丢弃
	REJECT：拒绝
	DNAT：目标地址转换
	SNAT:源地址转换
	REDIRECT：端口重定向
	MASQUERADE：地址伪装
	LOG：日志
	MARK：打标记

***开放172.16.100.7，sshd：22/tcp
iptables -t filter -A INPUT -s 172.16.0.0/16 -d 172.16.100.7/16 -p tcp --dport 22 -j ACCEPT
iptables -t filter -A OUTPUT -s 172.16.100.7/16 -d 172.16.0.0/16 -p tcp --sport 22 -j ACCEPT

***iptables不是服务，但有服务脚本；服务脚本的主要作用在于管理保存的规则
	即时装载及移除iptables/netfilter相关的内核模块；
		iptables_nat, iptables_filter, iptables_mangle, iptables_raw, ip_nat, ip_conntrack
		值得注意：ip_conntract模块加载后内核里面就会随时记录当前会话连接条目，为了避免内存大量消耗，ip_conntrack有上限，
			  但是一旦客户请求量达到上限，其余的就会终止会话连接，在繁忙服务器上是致命的；所以一般不启用此模块，但
			  是模块之间有依赖关系，如使用了iptables -t nat -L就会激活ip_conntrack，所以一定注意。

*ip_conntrack模块的信息位置(CenterOS6以后被nf_conntrack取代)
/proc/net/ip_conntrack
/proc/sys/net/ipv4/ip_conntrack_max
cat /proc/slabinfo

*iptstate命令可以查看iptables依赖的众多模块
目录：/proc/sys/net/ipv4/netfilter/
	ip_conntrack_tcp_timeout_established默认情况下 timeout 是5天（432000秒）

保存规则：
	# service iptables save
		默认保存/etc/sysconfig/iptables
	# iptables-save > /etc/sysconfig/iptables.2013041801
		自定义保存，重启不会生效
	# iptables-restore < /etc/sysconfig/iptables.2013041801
		让自定义的生效

*****下面举几个例子：千万注意以下的前提条件，否则后果自负
前题：
    1、如果想用状态追踪(NEW,ESTABLISHED,INVALID,RELATED)必须首先启用nf_conntrack,nf_conntrack_ftp,nf_nat_ftp(后两者是ftp专用)
    2、地址的掩码，没有掩码，iptables自动计算很容易出错，自己精确计算才有保证(如：192.168.2.84/24这样会被计算成192.168.2.0/24; )
    3、写iptables时，关于端口精确把握的问题，一定要搞清楚流量的走动方向，是自己去请求别人，还是别人来请求自己，这个决定了端口到底是sport还是dport
/*
例1：状态检测
***放行sshd(server 192.168.2.84/24)
*选择1：
[root@osd3 ~]# iptables -A OUTPUT -s 192.168.2.84/24 -d 0.0.0.0/0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
[root@osd3 ~]# iptables -A INPUT -s 0.0.0.0/0 -d 192.168.2.84/24 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
[root@osd3 ~]# iptables -L -n
Chain INPUT (policy DROP)
target     prot opt source               destination         
ACCEPT     tcp  --  0.0.0.0/0            192.168.2.0/24       tcp dpt:22 state NEW,ESTABLISHED

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy DROP)
target     prot opt source               destination         
ACCEPT     tcp  --  192.168.2.0/24       0.0.0.0/0            tcp spt:22 state ESTABLISHED
[root@osd3 ~]#

*选择2：
[root@osd3 ~]# iptables -A INPUT -s 0.0.0.0/0 -d 192.168.2.84/32 -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
[root@osd3 ~]# iptables -A OUTPUT -s 192.168.2.84/32 -d 0.0.0.0/0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
[root@osd3 ~]# iptables -L -n
Chain INPUT (policy DROP)
target     prot opt source               destination         
ACCEPT     tcp  --  0.0.0.0/0            192.168.2.84         tcp dpt:22 state NEW,ESTABLISHED

Chain FORWARD (policy ACCEPT)
target     prot opt source               destination         

Chain OUTPUT (policy DROP)
target     prot opt source               destination         
ACCEPT     tcp  --  192.168.2.84         0.0.0.0/0            tcp spt:22 state ESTABLISHED
[root@osd3 ~]#

***放行httpd, icmp(Server: 172.16.100.7/24)
iptables -A INPUT -s 0.0.0.0/0 -d 172.16.100.7/24 -p tcp -dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -s 172.16.100.7/24 -d 0.0.0.0/0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT

iptables -A INPUT -d 172.16.100.7/24 -p icmp --icmp-type 8 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -s 172.16.100.7/24 -p icmp --icmp-type 0 -m state --state ESTABLISHED -j ACCEPT

iptstate（追踪时间默认5天，超时就退出）
ls /proc/sys/net/ipv4/netfilter（可以追踪很多状态，icmp和udp只追踪超时）
cat /proc/sys/net/ipv4/netfilter/ip_conntract_tcp_timeout_established（嫌时太长也可以更改）
sysctl -w net.ipv4.ip_conntrack_max=65536（更改追踪最大个数，想永久有效写入/etc/sysctl.conf）
****站在TCP三次握手的角度，此时从服务器出去的只可能是响应报文，而不可能出去的是新请求报文

iptables -L -n --line-numbers -v
	查看规则时会发现，其实OUTPUT规则里面三条都是只允许出响应报文，所以这里可以汇总为
	iptables -A OUTPUT -s 172.16.100.7 -m state --state ESTABLISHED -j ACCEPT
		没指明的扩展为任意

例2：ftp放行，被动模式
    主动FTP：
   　　命令连接：客户端 >1023端口 -> 服务器 21端口
   　　数据连接：客户端 >1023端口 <- 服务器 20端口 

　　被动FTP：
   　　命令连接：客户端 >1023端口 -> 服务器 21端口
   　　数据连接：客户端 >1023端口 -> 服务器 >1023端口 
*由于ftp服务很特殊，所以首先要让iptables装载两个模块
1、装载ftp追踪时的专用的模块
	# modprobe nf_conntrack_ftp
    # modprobe nf_nat_ftp
2、放行请求报文
	命令连接：NEW,ESTABLISHED
	数据连接：RELATED,ESTABLISHED
	#iptables -A INPUT -d 192.168.154.139/24 -p tcp --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT
	#iptables -A INPUT -d 192.168.154.139/24 -p tcp  -m state --state RELATED,ESTABLISHED -j ACCEPT
3、放行响应报文
	ESTABLISHED
	#iptables -A OUTPUT -s 192.168.154.139/24 -p tcp -m state --state ESTABLISHED -j ACCEPT

vim /etc/sysconfig/iptables-config
	启用IPTABLES_MODULES="ip_nat_ftp ip_conntrack_ftp"
iptables -A INPUT -d 172.16.100.7/24 -p tcp --dport 21 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptalbes -A OUTPUT -o lo -j ACCEPT
***以上只放行了命令连接，那数据连接没法建立，为了不开放大于1024的所有端口，这里只能用到状态追踪的方式， 而有个RELATED的状态扩展专为此设计，
iptables -A INPUT -d 172.16.100.7/24 -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
***出去的只需将例1中的汇总加一个RELATED即可：
iptables -R OUTPUT 1 -s 172.16.100.7/24 -m state --state ESTABLISHED,RELATED -j ACCEPT


 小结：进来的都有ESTABLISHED，为了提高效率可以写为如下，而三个NEW可以写成如下：
 iptables -A INPUT -d 172.16.100.7/24 -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
 iptables -A INPUT -d 172.16.100.7/24 -p tcp -m multiport --destination-ports 21,22,80 -m state --state NEW -j ACCEPT

例3：一般公司最开始的安全策略可以这样设置
***避免flush后默认规则都是DROP那就完蛋了
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F

***首先可以让ssh能连接
iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

***保证apt-get可以使用
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m multiport --destination-ports 80,53 -m state --state NEW -j ACCEPT
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

***正常情况这个总是要配置的,自己要能跟自己通信
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

***以上配置都正确则可以设置默认DROP,这个比较危险，老手也容易翻船，建议在写iptables前写个at计划或者crontab来清空规则
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

*** 注意保存规则
centos7:
    # iptables-save > /etc/sysconfig/iptables
ubuntu 16.04:
    # iptables-save > /etc/iptables-rules
    在/etc/network/interface后面加上一行
    post-up iptables-restore < /etc/iptables-rules
        补充：pre-up是网卡启动前要执行的动作、pre-down是网卡关闭前要执行的动作、post-up是网卡启动后要执行的动作、post-down是网卡关闭后要执行的动作
        有人用pre-up来恢复iptables规则，不懂这个逻辑，实际上经过测试在ubuntu16.04上也实现不了iptables的恢复，用post-up可以实现，而且也符合逻辑啊，网卡启动了再用iptables是不是更合适，毕竟规则中用到了网卡接口

注意：以上的规则可以汇总
    比如ssh的--dport 22可以和 -m multiport --destination-ports合并
*/



练习：判断下述规则的意义：
*自定义链
# iptables -N clean_in

*为自定义链新增规则
# iptables -A clean_in -d 255.255.255.255 -p icmp -j DROP
# iptables -A clean_in -d 172.16.255.255 -p icmp -j DROP

*只有tcp才有syn
# iptables -A clean_in -p tcp ! --syn -m state --state NEW -j DROP
# iptables -A clean_in -p tcp --tcp-flags ALL ALL -j DROP
# iptables -A clean_in -p tcp --tcp-flags ALL NONE -j DROP

*执行到最后一条就返回主链
# iptables -A clean_in -d 172.16.100.7/24 -j RETURN 

*主链调用自定义链clean_in
# iptables -A INPUT -d 172.16.100.7/24 -j clean_in

# iptables -A INPUT  -i lo -j ACCEPT
# iptables -A OUTPUT -o lo -j ACCEPT


# iptables -A INPUT  -i eth0 -m multiport -p tcp --dports 53,113,135,137,139,445 -j DROP
# iptables -A INPUT  -i eth0 -m multiport -p udp --dports 53,113,135,137,139,445 -j DROP
# iptables -A INPUT  -i eth0 -p udp --dport 1026 -j DROP
# iptables -A INPUT  -i eth0 -m multiport -p tcp --dports 1433,4899 -j DROP

# iptables -A INPUT  -p icmp -m limit --limit 10/second -j ACCEPT




利用iptables的recent模块来抵御DOS攻击
ssh: 远程连接，

iptables -I INPUT -p tcp --dport 22 -m connlimit --connlimit-above 3 -j DROP
iptables -I INPUT  -p tcp --dport 22 -m state --state NEW -m recent --set --name SSH
iptables -I INPUT  -p tcp --dport 22 -m state --state NEW -m recent --update --seconds 300 --hitcount 3 --name SSH -j DROP


1.利用connlimit模块将单IP的并发设置为3；会误杀使用NAT上网的用户，可以根据实际情况增大该值；

2.利用recent和state模块限制单IP在300s内只能与本机建立3个新连接。被限制五分钟后即可恢复访问。
下面对最后两句做一个说明：
1.第二句是记录访问tcp 22端口的新连接，记录名称为SSH
	--set 记录数据包的来源IP，如果IP已经存在将更新已经存在的条目
2.第三句是指SSH记录中的IP，300s内发起超过3次连接则拒绝此IP的连接。
	--update 是指每次建立连接都更新列表；
	--seconds必须与--rcheck或者--update同时使用
	--hitcount必须与--rcheck或者--update同时使用

3.iptables的记录：/proc/net/ipt_recent/SSH(RHEL6以后是xt_recent)


也可以使用下面的这句记录日志：
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -m recent --update --name SSH --second 300 --hitcount 3 -j LOG --log-prefix "SSH Attack"


*****有一个概念一定要搞清楚，Linux中ip地址是属于内核不是网卡，只要开启转发功能走路由不作NAT，linux内核中两个
     不同ip地址连接的局域网之间可以互相通信（不一定是两个网卡，一个网卡也可以配两个不同网段的地址）
*****NAT的作用只是因为私有地址没有办法从公有地址路由进来，才会让NAT翻译成公有地址
*****FORWARD不完全等同于内核转发功能：内核转发功能是实现内核中不同网段之间通信要走的桥梁，而FORWARD是某人用自己的主机
     通过本主机去请求别的主机时，来制定规则允不允许通过本主机或允许哪些地址端口通过等

NAT：Network Address Translation
DNAT：目标地址转换
SNAT：源地址转换
	-j SNAT
		--to-source
iptables -t nat -A POSTROUTING -s 192.168.10.0/24 -j SANT --to-source 172.16.100.7
iptables -t nat -L -n
*拨号上网一般如下：
iptables -t nat -A POSTROUTING -s 192.168.3.0/24 -o ppp0 -j SNAT --to-source 125.89.200.221
iptables -t nat -A POSTROUTING -s 192.168.3.0/24 -o ppp0 -j SNAT MASQUERADE

*阻止别人用自己的主机通过本机去ping别外一台主机
iptables -A FORWARD -s 192.168.3.0/24 -p icmp -j REJECT

*FORWARD链放行web和ping，别的不让过
iptables -P FORWARD DROP
iptables -A FORWARD -m state --state ESTABLISHED -j ACCEPT（可以应付下面两条请求）
iptables -A FORWARD -s 192.168.3.0/24 -p tcp --dport 80 -m state --state NEW -j ACCEPT
iptables -A FORWARD -s 192.168.3.0/24 -p icmp --icmp-type 8 -m state --state NEW -j ACCEPT

*外网进内网访问web
*DNAT
iptables -t nat -A PREROUTING -d 172.16.100.7/32 -p tcp --dport 80 -j DNAT --to-destination 192.168.10.22
*PNAT
iptables -t nat -R PREROUTING -d 172.16.100.7/32 -p tcp --dport 80 -j DNAT --to -destination 192.168.10.22:8080
*过滤h7n9
iptables -A FORWARD -m string --algo kmp --string "h7n9" -j DROP









***layer7 -- l7
应用层：xunlei, qq, netfilter<--patch
	-m layer7 --l7proto xunlei -j DROP

***想要在iptables上面实现layer7应用过滤，首先要执行下面三步：
1、给内核打补丁，并重新编译内核（kernel, patch）
2、给iptables源码打补丁，并重新编译iptables（iptables, patch）
3、安装l7proto

Kernel Patch
# tar zxvf  linux-2.6.28.10.tar.gz  -C  /usr/src
# tar zxvf  netfilter-layer7-v2.22.tar.gz  -C  /usr/src
# cd /usr/src
# ln –s  linux-2.6.28.10  linux
# cd /usr/src/linux/
# patch -p1  <  ../netfilter-layer7-v2.22/kernel-2.6.25-2.6.28-layer7-2.22.patch 

# cp /boot/config-2.6.18-164.el5  /usr/src/linux/.config
# make  menuconfig


Networking support → Networking Options →Network packet filtering framework →Core Netfilter Configuration
<M>  Netfilter connection tracking support 
<M>  “layer7” match support
<M>  “string” match support
<M>  “time”  match support
<M>  “iprange”  match support
<M>  “connlimit”  match support
<M>  “state”  match support
<M>  “conntrack”  connection  match support
<M>  “mac”  address  match support
<M>   "multiport" Multiple port match support


Networking support → Networking Options →Network packet filtering framework → IP: Netfilter Configuration
<M> IPv4 connection tracking support (required for NAT)
<M>   Full NAT
	<M>     MASQUERADE target support                                                                                   
	<M>     NETMAP target support                                                                               
	<M>     REDIRECT target support 


# make 
# make modules_install
# make install


Compiles iptables :

# cp /etc/init.d/iptables ~/iptables
# cp /etc/sysconfig/iptables-config ~/
# rpm  -e  iptables-ipv6  iptables  iptstate  --nodeps
# tar jxvf iptables-1.4.6.tar.bz2 –C  /usr/src
# cd /usr/src/iptables-1.4.6
# cp ../netfilter-layer7-v2.22/iptables-1.4.3forward-for-kernel-2.6.20forward/libxt_layer7.*   ./extensions/


# ./configure  --prefix=/usr  --with-ksource=/usr/src/linux
# make
# make install
***官方脚本Iptables命令脚本中/sbin/iptables改成/usr/sbin/iptables后可以使用



# tar zxvf l7-protocols-2009-05-28.tar.gz（协议特征包，可用来识别像qq，迅雷等这样的东西）
# cd l7-protocols-2009-05-28
# make install

# mv ~/iptables  /etc/rc.d/init.d/

# service iptables start


l7-filter uses the standard iptables extension syntax 
ls /etc/l7-protocols/protocols/（查看支持的协议）
# iptables [specify table & chain] -m layer7 --l7proto [protocol name] -j [action] 

iptables -t nat -A POSTROUTING -s 192.168.3.0/24 -j SNAT --to-source 172.16.100.7
iptables -A FORWARD -s 192.168.3.0/24 -m layer7 --l7proto qq -j DROP
	QQ:UDP，上过线没有退出，也阻不了，最好刚上线效果明显

-m time
	--datestart --datetop
	--timestart --timestop
iptables -A FORWARD -s 192.168.3.0/24 -m time --timestart 08:10:00 --timestop 12:00:00 -j DROP
iptables -A FORWARD -s 192.168.3.0/24 -m time --timestart 14:30:00 --timestop 18:20:00 -j DROP
保存命令：
serviece iptables save
iptables-save > /etc/sysconfig/iptables.tus
iptables-restore < /etc/sysconfig/iptables.tus

iptables脚本：
#!/bin/bash
#
ipt=/usr/sbin/iptables
einterface=eht1
iinterface=eth0

eip=172.16.100.7
iip=192.168.3.6

$ipt -t nat -F
$ipt -t filter -F
$ipt -t mangle -F

$ipt -N clean_up
$ipt -A clean_up -d 255.255.255.255 -p icmp -j DROP
$ipt -A clean_up -j RETURN










***tcp_wrapper：是一个简单的服务器访问控制插件，作为一个共享库集成于某个服务中，如果服务器中没有这个共享库，也就不能为其提供访问控制
***可以用ldd二进制命令来查看服务器是否有libwrap.so
***注意控制列表的限定流程：/etc/hosts.allow-->/etc/hosts.deny-->默认规则(y)
***注意列表中用到的是服务的二进制命令
*定义格式：daemon_list: client_list [:options]

*sshd仅允许172.16.0.0/16网段访问：
方法：
1、/etc/hosts.allow
	sshd:	172.16.
2、/etc/hosts.deny
	sshd:	ALL


*telnet服务不允许172.16.0.0/255.255.0.0，但允许172.16.100.200访问：
其他客户端不做控制
方法1：
1、/etc/hosts.allow
	in.telnetd:	172.16.100.200
2、/etc/hosts.deny
	in.telnetd:	172.16.

方法2：
1、/etc/hosts.allow
	不定义
2、/etc/hosts.deny
	in.telnetd:	172.16. EXCEPT 172.16.100.200

方法3：
1、/etc/hosts.allow
	in.telnetd:	ALL EXCEPT 172.16. EXCEPT 172.16.100.200
2、/etc/hosts.deny
	in.telnetd:	ALL


** *如果用到Options就该是：
*不允许172.16.0.0/16
/etc/hosts.allow
	in.telnetd: 172.16. :DENY

*但是更常用的是spawn作options，成功或失败都可记录日志：
/etc/hosts.allow
	in.telnetd: 172.16. :spawn echo "somebody entered, `date`" >> /var/log/tcpwrapper.log

tcp wrapper macro:
%c: client information(user@host)
%s: service info(server@host)
%h: client hostname
%p: server PID

# man 5 hosts_access

spawn echo "`date`, Login attempt from %c to %s" >> /var/log/tcpwrapper.log




