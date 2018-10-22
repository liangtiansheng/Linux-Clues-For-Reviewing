综述：    
        VirtualBox网络连接方式概要
        VirtualBox图形界面下有四种网络接入方式，它们分别是：
            1、NAT 网络地址转换模式(NAT,Network Address Translation)
            2、Bridged Adapter 桥接模式
            3、Internal 内部网络模式
            4、Host-only Adapter 主机模式
        而在CommandLine下则有八种方式，除上面列出的四种外还有下列四种：
            1.UDP Tunnel networking
            2.VDE networking
            3.Limiting bandwidth  for network I/O
            4.Improving network performance
        
        VirturalBox为每个虚拟机提供八种虚拟的PCI 网卡，对于每一种虚拟网卡，你可以从下列六种网络硬件中任选一种：
            AMD PCNet PCI II (Am79C970A)
            AMD PCNet FAST III (Am79C973, the default)
            Intel PRO/1000 MT Desktop (82540EM)（Windows Vista and later versions）
            Intel PRO/1000 T Server (82543GC)（Windows XP）
            Intel PRO/1000 MT Server (82545EM)（OVF imports from other platforms）
            Paravirtualized network adapter (virtio-net)
一、NAT模式
    特点：
        虚拟机与主机关系： 只能单向访问，虚拟机可以通过网络访问到主机，主机无法通过网络访问到虚拟机。
                        虚拟机可以ping通主机（此时ping虚拟机的网关，即是ping主机）
        虚拟机与网络中其他主机的关系： 只能单向访问，虚拟机可以访问到网络中其他主机，其他主机不能通过网络访问到虚拟机。
        虚拟机与虚拟机之间的关系： 相互不能访问，虚拟机与虚拟机各自完全独立，相互间无法通过网络访问彼此。
    
    应用场景：
        虚拟机只要求可以上网，无其它特殊要求，满足最一般需求

    配置方法：
        连接方式 选择 网络地址转换（NAT）
        高级-控制芯片 选择 PCnet-FAST III
        高级-混杂模式 拒绝
        高级-接入网线 √
        （虚拟机ip自动获取）

        ip样式：
        ip 10.0.2.15
        网关 10.0.2.2
        DNS 10.0.2.3
        注意此处的网关在不同虚拟机中可能是同一个值，但是这归属于不同的NAT Engine，因此实际上各个虚拟机用的不是同一个网关

    原理：
        虚拟机的请求传递给NAT Engine，由它来利用主机进行对外的网络访问，返回的数据包再由NAT Engine给虚拟机。
二、Bridged Adapter模式（桥接模式）
    注意：注意如果主机是直接用拨号上网的，不是通过路由，那么此方式不可用。
            只有主机能上网，虚拟机才能上网
    特点：
        
        虚拟机与主机关系： 可以相互访问，因为虚拟机在真实网络段中有独立IP，主机与虚拟机处于同一网络段中，彼此可以通过各自IP相互访问。
        虚拟机于网络中其他主机关系：以相互访问，同样因为虚拟机在真实网络段中有独立IP，
                        虚拟机与所有网络其他主机处于同一网络段中，彼此可以通过各自IP相互访问。
        虚拟机于虚拟机关系： 可以相互访问，原因同上。


    应用场景：
        虚拟机要求可以上网，且虚拟机完全模拟一台实体机

    配置方法：
        连接方式 选择 桥接网卡
        界面名称 选择 （如果你的笔记本有无线网卡和有线网卡，需要根据现在的上网方式对应选择）
        高级-控制芯片 选择 PCnet-FAST III
        高级-混杂模式 拒绝
        高级-接入网线 √
        （虚拟机ip自动获取）

    ip样式：
        ip 与本机ip在同一网段内
        网关 与本机网关相同

    原理：
        通过主机网卡，架设一条桥，直接连入到网络中。它使得虚拟机能被分配到一个网络中独立的IP，所有网络功能完全和
        在网络中的真实机器一样。 
        （虚拟机是通过主机所在网络中的DHCP服务得到ip地址的，所以按理来说，两者是完全独立的，但事实却是虚拟机是没
        有独立硬件的，它还是要依靠主机的网卡，因此，主机要断开网络，虚拟机也就没法拿到ip了，所以呵呵~~所有特点全
        消失咯）

    缺点：
        1、会获取跟宿主机一个段的ip地址，比如宿主机ip 192.168.1.101 ,虚拟机会获取192.168.1.103的ip，
        但是公司的ip应该都是严格管理的，所以这种方法不好维护，如果主机所在局域网中得其他机器不需要使用虚拟机上的功能，最好使用Host-Only建立独立局域网
        
        2、如果宿主机上通过PPPOE拨号上网的，虚拟机也无法使用桥接

    最佳方案
        网卡一 NAT 方式和宿主机共享网络，虚拟机可以联网，方便下载安装各种软件

        网卡二 与主机建立独立局域网，和路由上其他的机器分离，(现在看这种方式太对了，我后来把mac带到公司用了，因为要演示hadoop集群计算，而公司的ip是需要向网管申请的)
        每一台虚拟机的ip固定，因为hadoop集群要设置master，ip要固定下来
三、Host-only Adapter模式
        主机模式，这是一种比较复杂的模式，需要有比较扎实的网络基础知识才能玩转。可以说前面几种模式所实现的功能，在这种模式下，通过虚拟机及网卡的设置都可以被实现。
        我们可以理解为Vbox在主机中模拟出一张专供虚拟机使用的网卡，所有虚拟机都是连接到该网卡上的，我们可以通过设置这张网卡来实现上网及其他很多功能，比如（网卡共享、网卡桥接等）。


    特点：

        虚拟机与主机关系 ：默认不能相互访问，双方不属于同一IP段，host-only网卡默认IP段为192.168.56.X 子网掩码为255.255.255.0，后面的虚拟机被分配到的也都是这个网段。通过网卡共享、网卡桥接等，可以实现虚拟机于主机相互访问。
            虚拟机访问主机： 用的是主机的VirtualBox Host-Only Network网卡的IP：192.168.56.1 ，不管主机“本地连接”有无红叉，永远通。
                        （注意虚拟机与主机通信是通过主机的名为VirtualBox Host-Only Network的网卡，因此ip是该网卡ip 192.168.56.1，而不是你现在正在上网所用的ip）

            主机访问虚拟机，用是的虚拟机的网卡的IP： 192.168.56.101 ，不管主机“本地连接”有无红叉，永远通。
                            主机可以访问主机下的所有虚拟机，和192.168.56.1(是VirtualBox Host-Only Network网卡[在主机中模拟出的网卡，不是虚拟机中虚拟的网卡]的IP)

        虚拟机与网络主机关系 ：默认不能相互访问，也不能上网，原因同上，通过设置，可以实现相互访问。

        虚拟机与虚拟机关系 ：默认可以相互访问，都是同处于一个网段。



    应用场景：
        在主机无法上网的情况下（主机可以上网的情况下可以用host-only，也可以用桥接），需要搭建一个模拟局域网，所有机器可以互访

    配置方法：
        连接方式 选择 仅主机（Host-Only）适配器
        界面名称 选择 VirtualBox Host-Only Ethernet Adapter
            如果无法设置界面名称，可以：In VirtualBox > Preferences > Network, set up a host-only network
        高级-控制芯片 选择 PCnet-FAST III
        高级-混杂模式 拒绝
        高级-接入网线 √
        （虚拟机ip自动获取，也可以自己进行配置，网关配置为主机中虚拟网卡的地址【默认为192.168.56.1】，ip配置为与虚拟网卡地址同网段地址）

    ip样式：
        ip 与本机VirtualBox Host-Only Network的网卡ip在同一网段内（默认192.168.56.*）
        网关 本机VirtualBox Host-Only Network的网卡ip（默认192.168.56.1）

    原理：
        通过VirtualBox Host-Only Network网卡进行通信，虚拟机以此ip作为网关，因此模拟了一个本机与各个虚拟机的局域网，如名称所指，
        应该是无法上网的（但是有人说可以通过对VirtualBox Host-Only Network网卡进行桥接等操作使虚拟机可以上网，但如此就不如直接
        采用桥接来的容易了，而且，呵呵，我没试成功，有的人也说不可以，因为主机不提供路由服务，我也不好乱说到底行不行，你自己试吧~~）
四、Internal模式（内网模式）虚拟机与外网完全断开，只实现虚拟机于虚拟机之间的内部网络模式。
    特点：
    虚拟机与主机关系： 不能相互访问，彼此不属于同一个网络，无法相互访问。
    虚拟机与网络中其他主机关系： 不能相互访问，理由同上。
    虚拟机与虚拟机关系： 可以相互访问，前提是在设置网络时，两台虚拟机设置同一网络名称。



    应用场景：
        让各台虚拟机处于隔离的局域网内，只让它们相互通信，与外界（包括主机）隔绝

    配置方法：
        连接方式 选择 内部网络
        界面名称 选择 intnet（可以重新命名，所有放在同一局域网内的虚拟机此名称相同）
        高级-控制芯片 选择 PCnet-FAST III
        高级-混杂模式 拒绝
        高级-接入网线 √
        （虚拟机ip：对于XP自动获取ip即可，但对于linux，必须手动配置ip和子网掩码，手动配置时需保证各个虚拟机ip在同一网段）
            如果是centos7，可依照如下操作，其它linux大同小异
                centos7中手动添加ip和子网掩码的方法：
                    ip addr                                         查看虚拟机上有哪些网卡
                    vi /etc/sysconfig/network-scripts/ifcfg-xxx　　xxx为具体的网卡名
                        修改BOOTPROTO＝“none”或者“static”，这样设置成手动，默认是“dhcp“是动态获取ip，
                        最后增加IPADDR＝”192.168.1.1“，NETMASK＝”255.255.255.0“
                    :wq　退出保存
                    service network restart     重启服务，生效

                以同样的方法，设置另1台centos7虚拟机

    ip样式：
        ip 192.168.1.1
        子网掩码 255.255.255.0
        默认网关 无

        或者如下
            ip 169.254.147.9
            子网掩码 255.255.0.0
            默认网关 无

    原理：
        各个虚拟机利用VirtualBox内置的DHCP服务器得到ip，数据包传递不经过主机所在网络，因此安全性高，防止外部抓包~
五、NAT模式+端口映射
    将虚拟机某端口映射到主机某端口，可以使主机和外部机器访问虚拟机提供的服务哦~~
    命令如下：
    （在命令行模式下，先到VirtualBox的安装目录下面，否则找不到命令）
    vboxmanage setextradata <VM name> "VBoxInternal/Devices/pcnet/0/LUN#0/Config/<rule name>/Protocol" TCP

    vboxmanage setextradata <VM name> "VBoxInternal/Devices/pcnet/0/LUN#0/Config/<rule name>/GuestPort" 80

    vboxmanage setextradata <VM name> "VBoxInternal/Devices/pcnet/0/LUN#0/Config/<rule name>/HostPort" 8000
六、以下配置centos虚拟机里面能上外网，而主机与centos虚拟机也能连通。
1、关掉虚拟机
－》在VBX主界面中，选中具体的centos7虚拟机，点击设置，
－》网络，网卡1中，选择　NAT　网络，网卡2中选择Host-Only
－》启动centos虚拟机，
    就可以利用2张网卡，通过网卡1上网，通过网卡2同主机通讯，
    同时，在些宿主机下的所有虚拟机默认都通过网卡2中指定的VirtualBox Host-Only Network网卡的ip,192.168.56.1，255.255.255.0，组成了192.168.56.x的内部局域网


2、具体也可参考收下办法
    最好的办法就是使用两块网卡，nat(虚拟机访问互联网，使用10.0.2.x段)和host-only(虚拟机和主机互相通信，使用192.168.56.x段)，而virtualbox配置的网络的地方是：打开主机界，按Ctrl+G，然后network，就可以启用vboxnet0了。

    打开虚拟机的配置，在networking里面添加第二块网卡为host-only。

    接下来在virtualbox中安装centos。

    ping baidu，不通，需要在/etc/sysconfig/network-scripts/ifcfg-eth0中将ONBOOT="no"改为yes，再添加BOOTPROTO="dhcp"，保存，退出，重启。再ping 百度，通了。此时可以用命令route看一下，记录一下路由，如果后面出现不能上网，再用route看一下什么异常

    再ping主机上的虚拟网卡192.168.56.1，发现也没有问题，是通的，但是主机访问不了虚拟机，这就头痛了，这个时候就要用到我们的第二块网卡host-only来完成主机对虚拟机的访问。操作如下：

    在/etc/sysconfig/network-scripts/下面看有没有ifcfg-eth1文件，如果没有，将ifcfg-eth0复制一份，改名为ifcfg-eth1，然后将ONBOOT值改为yes，这里我设置成静态IP，配置如下：

    BOOTPROTO=static    #获取IP的方式是dhcp或bootp自动获取，static是固定IP，none是手动
    IPADDR=192.168.56.2
    NETMASK=255.255.255.0

    注意不能设置GATEWAY，原因：
    linux双网卡默认路由问题
    在安装第二块网卡后出现无法上网问题，使用route发现是默认路由出现问题，经过多 发查证，才晓得原来linux在加载网卡配置文件的时候是先加载eth0,再加载eht1的，这样，如果eth1设置了gateway项，则会覆盖掉 eth0中的gateway设置，因此解决方法就是删除eth1的gateway设置
    ========================
    我使用的是第二种方式，Bridged Adapter桥接模式
    修改centos7的网卡IP地址与主机是同一网段
    $>cd /etc/sysconfig/network-scripts  
    $>vi ifcfg-enp0s3  
      修改
      BOOTPROTO=NONE
      IPADDR0=192.168.1.10  与主机一个网段
      PREFIX0=24
     :wq   保存退出
    重启网络
    $>service network restart
