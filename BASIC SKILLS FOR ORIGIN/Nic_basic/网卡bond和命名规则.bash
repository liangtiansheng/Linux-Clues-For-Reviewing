linux有七种网卡绑定模式：0. round robin，1.active-backup，2.load balancing (xor)，  3.fault-tolerance (broadcast)， 4.lacp (Link Aggregation Control Protocol，链路聚合控制协议)，  5.transmit load balancing， 6.adaptive load balancing。
摘要：
bond模式：
Mode=0(balance-rr) 表示负载分担round-robin，和交换机的聚合强制不协商的方式配合。
Mode=1(active-backup) 表示主备模式，只有一块网卡是active,另外一块是备的standby，这时如果交换机配的是捆绑，将不能正常工作，因为交换机往两块网卡发包，有一半包是丢弃的。
Mode=2(balance-xor) 表示XOR Hash负载分担，和交换机的聚合强制不协商方式配合。（需要xmit_hash_policy）
Mode=3(broadcast) 表示所有包从所有interface发出，这个不均衡，只有冗余机制...和交换机的聚合强制不协商方式配合。
Mode=4(802.3ad) 表示支持802.3ad协议，和交换机的聚合LACP(基于IEEE802.3ad标准的协议)方式配合（需要xmit_hash_policy）
Mode=5(balance-tlb) 是根据每个slave的负载情况选择slave进行发送，接收时使用当前轮到的slave
Mode=6(balance-alb) 在5的tlb基础上增加了rlb。
5和6不需要交换机端的设置，网卡能自动聚合。4需要支持802.3ad。0，2和3理论上需要静态聚合方式
但实测中0可以通过mac地址欺骗的方式在交换机不设置的情况下不太均衡地进行接收。

详述：
第一种：bond0:round robin
标准文档定义：round-robin policy: Transmit packets in sequential order from the first available slave through the last. This mode provides load balancing and fault tolerance.

特点：负载分担round-robin，增加带宽，同时支持容错能力，当有链路出问题，会把流量切换到正常的链路上。

实际绑定结果：
cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)
Bonding Mode: load balancing (round-robin)　　－－－－－ＲＲ的模式
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0
Slave Interface: eth0
MII Status: up
Link Failure Count: 0
Permanent HW addr: 74:ea:3a:6a:54:e3
Slave Interface: eth1
MII Status: up
Link Failure Count: 0

应用拓扑：交换机端需要配置聚合口，cisco叫port channel；华为叫Eth-Trunk
原理分析：
	mode 0下bond所绑定的网卡的IP都被修改成相同的mac地址，如果这些网卡都被接在同一个交换机，那么交换机的arp表里这个mac地址对应的端口就有多个，那么交换机接受到发往这个mac地址的包应该往哪个端口转发呢？正常情况下mac地址是全球唯一的，一个mac地址对应多个端口肯定使交换机迷惑 了。所以 mode 0下的bond如果连接到交换机，交换机这几个端口应该采取聚合方式，因为交换机做了聚合后，聚合下的几个端口也被捆绑成一个mac地址.我们的解决办法是，两个网卡接入不同的交换机即可。
	mode6模式下无需配置交换机，因为做bonding的这两块网卡是使用不同的MAC地址。




第二种：bond1:active-backup
标准文档定义：Active-backup policy: Only one slave in the bond is active. A different slave becomes active if, and only if, the active slave fails. The bond’s MAC address is externally visible on only one port (network adapter) to avoid confusing the switch. This mode provides fault tolerance. The primary option affects the behavior of this mode.

模式的特点： 主备模式，只有一块网卡是active,另外一块是备的standby，不会有流量。当主端口down掉时，从端口接手主状态。这时如果交换机配的是捆绑，将不能正常工作，因为交换机往两块网卡发包，有一半包是丢弃的。

实际绑定结果：
root@1:~# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)
Bonding Mode: fault-tolerance (active-backup) —–backup模式
Primary Slave: None
Currently Active Slave: eth0
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0
Slave Interface: eth0
MII Status: up
Link Failure Count: 0
Permanent HW addr: 74:ea:3a:6a:54:e3
Slave Interface: eth1
MII Status: up
Link Failure Count: 0
Permanent HW addr: d8:5d:4c:71:f9:94

应用拓扑：这种模式接入不需要交换机端支持，随便怎么接入都行。




第三种：bond2:load balancing (xor)
标准文档描述：XOR policy: Transmit based on [(source MAC address XOR\'d with destination MAC address) modulo slave count]. This selects the same slave for each destination MAC address. This mode provides load balancing and fault tolerance.

特点：该模式将限定流量，以保证到达特定对端的流量总是从同一个接口上发出。既然目的地是通过MAC地址来决定的，因此该模式在“本地”网络配置下可以工作得很好。如果所有流量是通过单个路由器（比如 “网关”型网络配置，只有一个网关时，源和目标mac都固定了，那么这个算法算出的线路就一直是同一条，那么这种模式就没有多少意义了。），那该模式就不是最好的选择。和balance-rr一样，交换机端口需要能配置为“port channel”。这模式是通过源和目标mac做hash因子来做xor算法来选路的。

实际绑定结果：
[root@localhost ~]# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.0.3 (March 23, 2006)
Bonding Mode: load balancing (xor) ——配置为xor模式
Transmit Hash Policy: layer2 (0)
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0
Slave Interface: eth1
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:d0:f8:40:f1:a0
Slave Interface: eth2
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:d0:f8:00:0c:0c

应用拓扑：同bond0一样的应用模型。这个模式也需要交换机配置聚合口。




第四种：bond3:fault-tolerance (broadcast)
标准文档定义：Broadcast policy: transmits everything on all slave interfaces. This mode provides fault tolerance.

特点:这种模式的特点是一个报文会复制两份往bond下的两个接口分别发送出去,当有对端交换机失效，我们感觉不到任何downtime,但此法过于浪费资源;不过这种模式有很好的容错机制。此模式适用于金融行业，因为他们需要高可靠性的网络，不允许出现任何问题。

实际绑定结果：
root@ubuntu12:~/ram# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)
Bonding Mode: fault-tolerance (broadcast) ——- fault-tolerance 模式
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0
Slave Interface: eth0
MII Status: up
Link Failure Count: 0
Permanent HW addr: 74:ea:3a:6a:54:e3
Slave Interface: eth1
MII Status: up
Link Failure Count: 0
Permanent HW addr: d8:5d:4c:71:f9:94

应用拓扑：这个模式也需要交换机配置聚合口。




第五种：bond4:lacp

标准文档定义：IEEE 802.3ad Dynamic link aggregation. Creates aggregation groups that share the same speed and duplex settings. Utilizes all slaves in the active aggregator according to the 802.3ad specification. Pre-requisites: 1. Ethtool support in the base drivers for retrieving.the speed and duplex of each slave. 2. A switch that supports IEEE 802.3ad Dynamic link
aggregation. Most switches will require some type of configuration to enable 802.3ad mode.

特点：802.3ad模式是IEEE标准，因此所有实现了802.3ad的对端都可以很好的互操作。802.3ad 协议包括聚合的自动配置，因此只需要很少的对交换机的手动配置（要指出的是，只有某些设备才能使用802.3ad）。802.3ad标准也要求帧按顺序（一定程度上）传递，因此通常单个连接不会看到包的乱序。802.3ad也有些缺点：标准要求所有设备在聚合操作时，要在同样的速率和双工模式，而且，和除了balance-rr模式外的其它bonding负载均衡模式一样，任何连接都不能使用多于一个接口的带宽。
此外，linux bonding的802.3ad实现通过对端来分发流量（通过MAC地址的XOR值），因此在“网关”型配置下，所有外出（Outgoing）流量将使用同一个设备。进入（Incoming）的流量也可能在同一个设备上终止，这依赖于对端802.3ad实现里的均衡策略。在“本地”型配置下，路两将通过 bond里的设备进行分发。

实际绑定结果：
root@:~# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)
Bonding Mode: IEEE 802.3ad Dynamic link aggregation
Transmit Hash Policy: layer2 (0)
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0
802.3ad info
LACP rate: slow
Aggregator selection policy (ad_select): stable
Active Aggregator Info:
Aggregator ID: 1
Number of ports: 1
Actor Key: 9
Partner Key: 1
Partner Mac Address: 00:00:00:00:00:00
Slave Interface: eth0
MII Status: up
Link Failure Count: 0
Permanent HW addr: 74:ea:3a:6a:54:e3
Aggregator ID: 1
Slave Interface: eth1
MII Status: up
Link Failure Count: 0
Permanent HW addr: d8:5d:4c:71:f9:94
Aggregator ID: 2

应用拓扑：应用拓扑同bond0,和bond2一样，不过这种模式除了配置port channel之外还要在port channel聚合口下开启LACP功能，成功协商后，两端可以正常通信。否则不能使用。
应用场景：我们这里聚合采用的是lacp模式，主要原因是我们还会使用PXE装机，而PXE只会初始化一块网卡去DHCP申请地址，在这个过程中去修改交换机配置显然是不合适的，只能选择动态聚合。注意lacp模式需要接入交换机支持。



第六种：bond5: transmit load balancing

标准文档定义：Adaptive transmit load balancing: channel bonding that does not require any special switch support. The outgoing traffic is distributed according to the current load (computed relative to the speed) on each slave. Incoming traffic is received by the current slave. If the receiving slave fails, another slave takes over the MAC address of the failed receiving slave. Prerequisite: Ethtool support in the base drivers for retrieving the speed of each slave.

特点：根据每个slave的负载情况选择slave进行发送，接收时使用当前轮到的slave
设备开始时会发送免费arp，以主端口eth1的mac为源，当客户端收到这个arp时就会在arp缓存中记录下这个mac对的ip。而在这个模式下，服务器每个端口在ping操作时，会根据算法算出出口，地址不断变化时他，这时会负载到不同端口。实验中ping1.1.1.3时往eth2发送，源mac为00:D0:F8:00:0C:0C，ping1.1.1.4是往eth1发送，源mac为00:D0:F8:40:F1:A0，以此类推，所以从服务器出去的流量负载到两条线路，但是由于服务发arp时只用00:D0:F8:40:F1:A0，这样客户端缓冲记录的是00:D0:F8:40:F1:A0对的ip，封装时目标mac：00:D0:F8:40:F1:A0。这样进入服务的流量都只往eth1（00:D0:F8:40:F1:A0）走。设备会一直发入snap报文，eth1发送源为00d0.f840.f1a0的snap报文，eth2发送源为00d0.f800.0c0c的snap报文。这个snap报文mac和目标mac一样都是网卡本地mac，源ip和目标ip也一样，这个报文的作用是检测线路是否正常的回环报文。
注：可以通过修改bond0的mac地址来引导他发修改后的源mac的免费arp（MACADDR=00:D0:F8:00:0C:0C）

实际配置结果：
cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.0.3 (March 23, 2006)
Bonding Mode: transmit load balancing —–TLB模式
Primary Slave: None
Currently Active Slave: eth1
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0
Slave Interface: eth1
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:d0:f8:40:f1:a0
Slave Interface: eth2
MII Status: up
Link Failure Count: 0
Permanent HW addr: 00:d0:f8:00:0c:0c

应用拓扑：这个模式下bond成员使用各自的mac，而不是上面几种模式是使用bond0接口的mac。不需要交换机端的设置，网卡能自动聚合。



第七种：bond6:adaptive load balancing
特点：该模式包含了balance-tlb模式，同时加上针对IPV4流量的接收负载均衡(receive load balance, rlb)，而且不需要任何switch(交换机)的支持。接收负载均衡是通过ARP协商实现的。bonding驱动截获本机发送的ARP应答，并把源硬件地址改写为bond中某个slave的唯一硬件地址，从而使得不同的对端使用不同的硬件地址进行通信。所有端口都会收到对端的arp请求报文，回复arp回时，bond驱动模块会截获所发的arp回复报文，根据算法算到相应端口，这时会把arp回复报文的源mac，send源mac都改成相应端口mac。从抓包情况分析回复报文是第一个从端口1发，第二个从端口2发。以此类推。
(还有一个点：每个端口除发送本端口回复的报文，也同样会发送其他端口回复的报文，mac还是其他端口的mac)这样来自服务器端的接收流量也会被均衡。
当本机发送ARP请求时，bonding驱动把对端的IP信息从ARP包中复制并保存下来。当ARP应答从对端到达时，bonding驱动把它的硬件地址提取出来，并发起一个ARP应答给bond中的某个slave(这个算法和上面一样，比如算到1口，就给发送arp请求，1回复时mac用1的mac)。使用ARP协商进行负载均衡的一个问题是：每次广播 ARP请求时都会使用bond的硬件地址，因此对端学习到这个硬件地址后，接收流量将会全部流向当前的slave。这个问题通过给所有的对端发送更新（ARP应答）来解决，往所有端口发送应答,应答中包含他们独一无二的硬件地址，从而导致流量重新分布。当新的slave加入到bond中时，或者某个未激活的slave重新激活时，接收流量也要重新分布。接收的负载被顺序地分布（round robin）在bond中最高速的slave上
当某个链路被重新接上，或者一个新的slave加入到bond中，接收流量在所有当前激活的slave中全部重新分配，通过使用指定的MAC地址给每个 client发起ARP应答。下面介绍的updelay参数必须被设置为某个大于等于switch(交换机)转发延时的值，从而保证发往对端的ARP应答不会被switch(交换机)阻截。
必要条件：
条件1：ethtool支持获取每个slave的速率；
条件2：底层驱动支持设置某个设备的硬件地址，从而使得总是有个slave(curr_active_slave)使用bond的硬件地址，同时保证每个bond 中的slave都有一个唯一的硬件地址。如果curr_active_slave出故障，它的硬件地址将会被新选出来的 curr_active_slave接管。

实际配置结果：
root@:/tmp# cat /proc/net/bonding/bond0
Ethernet Channel Bonding Driver: v3.6.0 (September 26, 2009)
Bonding Mode: adaptive load balancing
Primary Slave: None
Currently Active Slave: eth0
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0
Slave Interface: eth0
MII Status: up
Link Failure Count: 0
Permanent HW addr: 74:ea:3a:6a:54:e3
Slave Interface: eth1
MII Status: up
Link Failure Count: 0
Permanent HW addr: d8:5d:4c:71:f9:94

应用拓扑：不需要交换机端的设置，网卡能自动聚合

演示：
A是双网卡绑定，B是第一个交换接口，C是第二个交换机接口
当B 发送一个arp请求到达A时，按正常情况A会回应一个arp回应报文，源mac为bond的mac，源就是bond的ip。但是这个模式下bonding驱动会截获这个arp回应，把源mac改成bond状态 下其中某一个网卡的mac:mac1，这样B收到这个arp回应时就会在arp缓存中记录下ip：1.1.1.1对应的mac为mac1。这样B的过来的流量都走MAC1.
当C 发送一个arp请求到达A时，按正常情况A会回应一个arp回应报文，源mac为bond的mac，源就是bond的ip。但是这个模式下bonding驱动会截获这个arp回应，把源mac改成bond状态 下其中某一个网卡的mac:mac2，这样C收到这个arp回应时就会在arp缓存中记录下ip：1.1.1.1对应的mac为mac2。这样C的过来的流量都走MAC2.
这样就可以做到回来让回来的流量也负载均衡。出方向均衡和MODE=5一致，不同地址会根据xor算法算出不同出口


bonding配置参数
	在内核文档中，列举了许多bonding驱动的参数，然后本文不是文档的翻译，因此不再翻译文档和介绍和主题无关的参数，仅对比较重要的参数进行介绍，并且这些介绍也不是翻译，而是一些建议或者心得。

	ad_select： 802.3ad相关。如果不明白这个，那不要紧，抛开Linux的bonding驱动，直接去看802.3ad的规范就可以了。列举这个选项说明linux bonding驱动完全支持了动态端口聚合协议。

	arp_interval和arp_ip_target： 以一个固定的间隔向某些固定的地址发送arp，以监控链路。有些配置下，需要使用arp来监控链路，因为这是一种三层的链路监控 ，使用网卡状态或者链路层pdu监控只能监控到双绞线两端的接口 的健康情况，而监控不到到下一条路由器或者目的主机之间的全部链路的健康状况。

	primary： 表示优先权，顺序排列，当出现某种选择事件时，按照从前到后的顺序选择网口，比如802.3ad协议中的选择行为。

	fail_over_mac： 对于热备模式是否使用同一个mac地址，如果不使用一个mac的话，就要完全依赖免费arp机制更新其它机器的arp缓存了。比如，两个有网卡，网卡1和网卡2处于热备模式，网卡1的mac是mac1，网卡2的mac是mac2，网卡1一直是master，但是网卡1突然down掉了，此时需要网卡2接替，然而网卡2的mac地址与之前的网卡1不同，别的主机回复数据包的时候还是使用网卡1的mac地址来回复的，由于mac1已经不在网络上了，这就会导致数据包将不会被任何网卡接收。因此网卡2接替了master的角色之后，最好有一个回调事件，处理这个事件的时候，进行一次免费的arp广播，广播自己更换了mac地址。

	lacp_rate： 发送802.3ad的LACPDU，以便对端设备自动获取链路聚合的信息。

	max_bonds： 初始时创建bond设备接口的数量，默认值是1。但是这个参数并不影响可以创建的最大的bond设备数量。

	use_carrier： 使用MII的ioctl还是使用驱动获取保持的状态，如果是前者的话需要自己调用mii的接口进行硬件检测，而后者则是驱动自动进行硬件检测(使用watchdog或者定时器)，bonding驱动只是获取结果，然而这依赖网卡驱动必须支持状态检测，如果不支持的话，网卡的状态将一直是on。

	mode： 这个参数最重要，配置以什么模式运行，这个参数在bond设备up状态下是不能更改的，必须先down设备(使用ifconfig bondX down)才可以配置，主要的有以下几个：

	balance-rr or 0： 轮转方式的负载均衡模式，流量轮流在各个bondX的真实设备之间分发。注意，一定要用状态检测机制，否则如果一个设备down掉以后，由于没有状态检测，该设备将一直是up状态，仍然接受发送任务，这将会出现丢包。
	active-backup or 1： 热备模式。在比较高的版本中，免费arp会在切换时自动发送，避免一些故障，比如fail_over_mac参数描述的故障。
	balance-xor or 2： 我不知道既然bonding有了xmit_hash_policy这个参数，为何还要将之单独设置成一种模式，在这个模式中，流量也是分发的，和轮转负载不同的是，它使用源/目的mac地址为自变量通过xor|mod函数计算出到底将数据包分发到哪一个口。
	broadcast or 3： 向所有的口广播数据，这个模式很XX，但是容错性很强大。
	802.3ad or 4： 这个就不多说了，就是以802.3ad的方式运行。
	xmit_hash_policy： 这个参数的重要性我认为仅次于mode参数，mode参数定义了分发模式 ，而这个参数定义了分发策略 ，文档上说这个参数用于mode2和mode4，我觉得还可以定义更为复杂的策略呢。

	layer2： 使用二层帧头作为计算分发出口的参数，这导致通过同一个网关的数据流将完全从一个端口发送，为了更加细化分发策略，必须使用一些三层信息，然而却增加了计算开销，天啊，一切都要权衡！
	layer2+3： 在1的基础上增加了三层的ip报头信息，计算量增加了，然而负载却更加均衡了，一个个主机到主机的数据流形成并且同一个流被分发到同一个端口，根据这个思想，如果要使负载更加均衡，我们在继续增加代价的前提下可以拿到4层的信息。
	layer3+4： 这个还用多说吗？可以形成一个个端口到端口的流，负载更加均衡。然而且慢！ 事情还没有结束，虽然策略上我们不想将同一个tcp流的传输处理并行化以避免re-order或者re-transmit，因为tcp本身就是一个串行协议，比如Intel的8257X系列网卡芯片都在尽量减少将一个tcp流的包分发到不同的cpu，同样，端口聚合的环境下，同一个tcp流也应该使用本policy使用同一个端口发送，但是不要忘记，tcp要经过ip，而ip是可能要分段的，分了段的ip数据报中直到其被重组(到达对端或者到达一个使用nat的设备)都再也不能将之划为某个tcp流了。ip是一个完全无连接的协议，它只关心按照本地的mtu进行分段而不管别的，这就导致很多时候我们使用layer3+4策略不会得到完全满意的结果。可是事情又不是那么严重，因为ip只是依照本地的mtu进行分段，而tcp是端到端的，它可以使用诸如mss以及mtu发现之类的机制配合滑动窗口机制最大限度减少ip分段，因此layer3+4策略，很OK！
	miimon和arp： 使用miimon仅能检测链路层的状态，也就是链路层的端到端连接(即交换机某个口和与之直连的本地网卡口)，然而交换机的上行口如果down掉了还是无法检测到，因此必然需要网络层的状态检测，最简单也是最直接的方式就是arp了，可以直接arp网关，如果定时器到期网关还没有回复arp reply，则认为链路不通了



网卡命名
一、为什么需要这个
服务器通常有多块网卡，有板载集成的，同时也有插在PCIe插槽的。Linux系统的命名原来是eth0,eth1这样的形式，但是这个编号往往不一定准确对应网卡接口的物理顺序。

为解决这类问题，dell开发了biosdevname方案。

systemd v197版本中将dell的方案作了进一步的一般化拓展。

目前的Centos既支持dell的biosdevname，也支持systemd的方案。

二、Centos7中的命名策略
Scheme 1: 如果从BIOS中能够取到可用的，板载网卡的索引号，则使用这个索引号命名，例如: eno1，如不能则尝试Scheme 2

Scheme 2: 如果从BIOS中能够取到可以用的，网卡所在的PCI-E热插拔插槽(注：pci槽位号)的索引号，则使用这个索引号命名，例如: ens1，如不能则尝试Scheme 3

Scheme 3：如果能拿到设备所连接的物理位置（PCI总线号+槽位号？）信息，则使用这个信息命名，例如:enp2s0，如不能则尝试Scheme 5

Scheme 5：传统的kernel命名方法，例如: eth0，这种命名方法的结果不可预知的，即可能第二块网卡对应eth0，第一块网卡对应eth1。

Scheme 4 使用网卡的MAC地址来命名，这个方法一般不使用。

三、biosdevname和net.ifnames两种命名规范
net.ifnames的命名规范为:   设备类型+设备位置+数字

设备类型：

en 表示Ethernet

wl 表示WLAN

ww 表示无线广域网WWAN

实际的例子:

eno1 板载网卡

enp0s2  pci网卡

ens33   pci网卡

wlp3s0  PCI无线网卡

wwp0s29f7u2i2   4G modem

wlp0s2f1u4u1   连接在USB Hub上的无线网卡

enx78e7d1ea46da pci网卡

biosdevname的命名规范为

实际的例子:

em1 板载网卡

p3p4 pci网卡

p3p4_1 虚拟网卡

四、systemd中的实际执行顺序
按照如下顺序执行udev的rule

1./usr/lib/udev/rules.d/60-net.rules

2./usr/lib/udev/rules.d/71-biosdevname.rules

3./lib/udev/rules.d/75-net-description.rules

4./usr/lib/udev/rules.d/80-net-name-slot.rules

1）60-net.rules 

使用/lib/udev/rename_device这个程序，去查询/etc/sysconfig/network-scripts/下所有以ifcfg-开头的文件，如果在ifcfg-xx中匹配到HWADDR=xx:xx:xx:xx:xx:xx参数的网卡接口则选取DEVICE=yyyy中设置的名字作为网卡名称。

2）71-biosdevname.rules

如果系统中安装了biosdevname，且内核参数指定biosdevname=1，且上一步没有重命名网卡，则按照biosdevname的命名规范，从BIOS中取相关信息来命名网卡。

主要是取SMBIOS中的type 9 (System Slot) 和 type 41 (Onboard Devices Extended Information)不过要求SMBIOS的版本要高于2.6，且系统中要安装biosdevname程序。

3）75-net-description.rules

udev通过检查网卡信息，填写如下这些udev的属性值

ID_NET_NAME_ONBOARD

ID_NET_NAME_SLOT

ID_NET_NAME_PATH

ID_NET_NAME_MAC 

4）80-net-name-slot.rules

如果在60-net.rules ，71-biosdevname.rules这两条规则中没有重命名网卡，且内核指定net.ifnames=1参数，则udev依次尝试使用以下属性值来命名网卡，如果这些属性值都没有，则网卡不会被重命名。

ID_NET_NAME_ONBOARD

ID_NET_NAME_SLOT

ID_NET_NAME_PATH

上边的71-biosdevname.rules 是实际执行biosdevname的策略

75-net-description.rules和80-net-name-slot.rules实际执行上面策略的1,2,3。

根据上述的过程，可见网卡命名受 biosdevname和net.ifnames这两个内核参数影响。

这两个参数都可以在grub配置中提供。

biosdevname=0是系统默认值（dell服务器默认是1），net.ifnames=1是系统默认值:

修改默认参数：如回归默认命名方式：

1.编辑内核参数
在GRUB_CMDLINE_LINUX中加入net.ifnames=0即可

[root@centos7 ~]$vim /etc/default/grub

GRUB_CMDLINE_LINUX="crashkernel=auto net.ifnames=0 rhgb quiet"

2.为grub2生成配置文件
编辑完grub配置文件以后不会立即生效，需要生成配置文件。

[root@centos7 ~]$grub2-mkconfig -o /etc/grub2.cfg

第二节所说的Scheme的策略顺序是系统默认的。

如系统BIOS符合要求，且系统中安装了biosdevname，且biosdevname=1启用，则biosdevname优先；

如果BIOS不符合biosdevname要求或biosdevname=0，则仍然是systemd的规则优先。

如果用户自己定义了udev rule来修改内核设备名字，则用户规则优先。

内核参数组合使用的时候，其结果如下：

默认内核参数(biosdevname=0，net.ifnames=1):  网卡名 "enp5s2"

biosdevname=1，net.ifnames=0：网卡名 "em1"

biosdevname=0，net.ifnames=0：网卡名 "eth0" (最传统的方式,eth0 eth1 傻傻分不清)






