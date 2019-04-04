第一种简单的方式:
    服务端：配置pptd
        ubuntu系统：安装pptpd
            1、我们要使用PPTP协议，首先验证服务器是否支持MPPE模块，在服务器终端输入
                modprobe ppp-compress-18 && echo MPPE is ok
                若显示MPPE is ok，则说明服务器的linux内核支持MPPE模块，否则请升级linux内核到2.6.15以上版本，或者给内核打上MPPE的补丁，相应具体详细配置请点击，这里不再赘述。

            2、安装pptpd插件，ubuntu下使用下面指令安装，其他linux指令不再赘述
                sudo apt-get install pptpd
            3、编辑配置文件pptpd.conf，添加建立VPN虚拟网络时的主机ip（网关）和这个虚拟主机分配给其他设备的虚拟ip 段。注意这个VPN虚拟ip主机和我们的服务器的ip没有关系，可以任意设置。而且最好避免和服务器所在网段内的其他设备ip冲突。输入下面指令，打开配置文件，编辑器使用vim的话替换参数即可。
                sudo emacs /etc/pptpd.conf
                在文件最后添加下面两行
                localip  192.168.2.1
                remote 192.168.2.10-99
                这里我将参数localip也就是VPN虚拟网络的主机（网关）设置成了192.168.2.1，而我们要配置的服务器所在的网段的主机（网关），也就是实验室的路由器的ip为192.168.0.1，这样可以避免将来在外网登陆VPN时，VPN虚拟主机分配的ip与实验室内网的ip冲突。而参数rempteip表示VPN最多接受90个外网链接。

            4、编辑配置文件pptpd-options，设置这个VPN虚拟网络的DNS，输入下面，指令打开配置文件
                sudo emacs /etc/ppp/pptpd-options
                修改以下部分，这里使用google的DNS
                ms-dns 8.8.8.8
                ms-dns 8.8.4.4
                这里也可以填上，服务器主机所在网络使用的DNS地址。
                ***注意：这一步是为了可以在vpn的环境下上网，不过这不够，还要配置iptables SNAT将ppp0环境的ip地址SNAT出去
            5、编辑配置文件chap-secrets，设置这个VPN的登陆账号和密码，输入下面指令打开配置文件
                sudo emacs /etc/ppp/chap-secrets
                添加一行，依次为：用户名，服务，密码，限制ip：
                user pptpd 123 *
                *表示ip无限制。
            6、输入下面指令以重启服务
                sudo /etc/init.d/pptpd restart
    客户端：
        ubuntu系统：安装pptp-linux生成pptp、pptpsetup
            1.要下载pptp的客户端
                sudo apt-get install pptp-linux

            2.创建连接
                sudo pptpsetup --create haha --server 123.45.67.89 --username lige --password fk --encrypt --start
                其中，
                --create后的是创建的连接名称，可以为任意名称; 
                --server后接的是vpn服务器的IP; 
                --username是用户名
                --password是密码，在这也可以没这个参数，命令稍后会自动询问。这样可以保证账号安全
                --encrypt 是表示需要加密，不必指定加密方式，命令会读取配置文件中的加密方式
                --start是表示创建连接完后马上连接，如果你不想连，就不写
                ***这里面“haha”是创建的pptp客户端的名称，随便写一个就行，命令运行完会生成文件/etc/ppp/peers/haha
                ***注意：有的时候遇到：LCP terminated by peer (MPPE required but peer refused)
                ***这说明服务端要求MPPE加密，但是客户端不支持，也就是在运行pptpsetup命令时漏掉了：--encrypt
            
            3. 连上vpn
                如果刚才你没有输入--start选项或者是下次再想连接时，输入的命令就更简单了
                sudo pon haha
                haha就是刚才创建的连接名。如果你曾经用过pppoe(ADSL)连网，会对这个命令很亲切的。
                这个命令一般不会返回任何信息。查看连接的状态，可以用这个命令
                plog

            4. 中断vpn连接
                更简单，和pppoe一样（因为都是点到点的连接，呵呵）
                sudo poff

            5.高级主题
                pptp是通过点到点的方式连接到服务器，所以pptp连接实际上是需要依赖ppp软件包的。
                安装pptp-linux软件包后，在/etc/ppp/目录下会出现一个新的文件“options.pptp” 
                这个是pptp-linux的唯一配置文件，定义了pptp加密方式。一般情况下不需要进行更改，除非你知道vpn服务器没有用默认的加密方式

                可能有些人觉得用pptpsetup还不够geek，想手动创建连接。那么方法如下：
                (1) 修改/etc/ppp/chap-secrets
                在文件末尾加上
                user haha pwd *
                lige和fk分别为用户名和密码，haha为连接名称。最后一项代表希望获得的IP，*表示任意IP都行

                (2)创建文件/etc/ppp/peers/haha
                pty "pptp 222.197.180.168 --nolaunchpppd"
                lock
                noauth
                nobsdcomp
                nodeflate
                name lige
                remotename haha
                ipparam haha
                require-mppe-128

                文件中每行的含义，可以在/etc/ppp/options.pptp中查看

                (3)连接和断开
                sudo pon haha
                sudo poff
第二种方式：如果有一个路由隔开，想要通过这个路由拔号进入内网，那这个路由器必须支持vpn穿透才行
第三种方式：就是用openvpn，这个功能强大，要配置证书
    Ubuntu 16.04搭建OpenVPN服务器以及客户端的使用(启动时注意用户权限，比如root用户启动)
    OpenVPN版本：OpenVPN 2.3.10(这是2.x版本的样式，3.x版本就不一样了，参考样式https://blog.rj-bai.com/post/136.html)
        1、安装前准备
            ***安装openssl和lzo，lzo用于压缩通讯数据加快传输速度
            # sudo apt-get install openssl libssl-dev
            # sudo apt-get install lzop
        2、安装及配置OpenVPN和easy-rsa
            ***安装openvpn和easy-rsa
            # sudo apt-get install openvpn
            # sudo apt-get install easy-rsa
            ***修改vars文件 
            # sudo su
            # cd /usr/share/easy-rsa/ 
            # vim vars
                ***修改注册信息，比如公司地址、公司名称、部门名称等。
                export KEY_COUNTRY="CN"
                export KEY_PROVINCE="Shandong"
                export KEY_CITY="Qingdao"
                export KEY_ORG="MyOrganization"
                export KEY_EMAIL="me@myhost.mydomain"
                export KEY_OU="MyOrganizationalUnit"
            ***初始化环境变量
            # source vars
            ***清除keys目录下所有与证书相关的文件
            ***下面步骤生成的证书和密钥都在/usr/share/easy-rsa/keys目录里
            # ./clean-all
            ***生成根证书ca.crt和根密钥ca.key（一路按回车即可）
            # ./build-ca
            ***为服务端生成证书和私钥（一路按回车，直到提示需要输入y/n时，输入y再按回车，一共两次）
            # ./build-key-server server
            ***每一个登陆的VPN客户端需要有一个证书，每个证书在同一时刻只能供一个客户端连接，下面建立2份
            ***为客户端生成证书和私钥（一路按回车，直到提示需要输入y/n时，输入y再按回车，一共两次）
            # ./build-key client1
            # ./build-key client2
            ***创建迪菲·赫尔曼密钥，会生成dh2048.pem文件（生成过程比较慢，在此期间不要去中断它）
            # ./build-dh
            ***生成ta.key文件（防DDos攻击、UDP淹没等恶意攻击）
            # openvpn --genkey --secret keys/ta.key
        3、创建服务器端配置文件
            ***将需要用到的openvpn证书和密钥复制一份到根目录下/etc/openvpn中
            # cp /usr/share/easy-rsa/keys/{ca.crt,server.{crt,key},dh2048.pem,ta.key} /etc/openvpn
            ***复制一份服务器端配置文件模板server.conf到/etc/openvpn/
            # gzip -d /usr/share/doc/openvpn/examples/sample-config-files/server.conf.gz
            # cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/
            ***查看server.conf里的配置参数
            # grep '^[^#;]' /etc/openvpn/server.conf
            ***编辑server.conf
            # vim /etc/openvpn/server.conf 
                # 注意这个文件使用的都是相对路径，根目录是/etc/openvpn/，如果在根目录下创建了一个keys目录，证书和密钥放在keys下，那引用就是keys/ca.crt ##########
                #OpenVPN应该监听本机的哪些IP地址？
                #该命令是可选的，如果不设置，则默认监听本机的所有IP地址。
                ;local a.b.c.d
                # OpenVPN应该监听哪个TCP/UDP端口？
                # 如果你想在同一台计算机上运行多个OpenVPN实例，你可以使用不同的端口号来区分它们。
                # 此外，你需要在防火墙上开放这些端口。
                port 1194
                #OpenVPN使用TCP还是UDP协议?
                proto tcp
                ;proto udp
                # 指定OpenVPN创建的通信隧道类型。
                # "dev tun"将会创建一个路由IP隧道，
                # "dev tap"将会创建一个以太网隧道。
                # 如果你是以太网桥接模式，并且提前创建了一个名为"tap0"的与以太网接口进行桥接的虚拟接口，则你可以使用"dev tap0"
                # 如果你想控制VPN的访问策略，你必须为TUN/TAP接口创建防火墙规则。
                # 在非Windows系统中，你可以给出明确的单位编号(unit number)，例如"tun0"。
                # 在Windows中，你也可以使用"dev-node"。
                # 在多数系统中，除非你部分禁用或者完全禁用了TUN/TAP接口的防火墙，否则VPN将不起作用。
                ;dev tap
                dev tun
                # 如果你想配置多个隧道，你需要用到网络连接面板中TAP-Win32适配器的名称(例如"MyTap")。
                # 在XP SP2或更高版本的系统中，你可能需要有选择地禁用掉针对TAP适配器的防火墙
                # 通常情况下，非Windows系统则不需要该指令。
                ;dev-node MyTap
                # 设置SSL/TLS根证书(ca)、证书(cert)和私钥(key)。
                # 每个客户端和服务器端都需要它们各自的证书和私钥文件。
                # 服务器端和所有的客户端都将使用相同的CA证书文件。
                # 通过easy-rsa目录下的一系列脚本可以生成所需的证书和私钥。
                # 记住，服务器端和每个客户端的证书必须使用唯一的Common Name。
                # 你也可以使用遵循X509标准的任何密钥管理系统来生成证书和私钥。
                # OpenVPN 也支持使用一个PKCS #12格式的密钥文件(详情查看站点手册页面的"pkcs12"指令)
                ca ca.crt
                cert server.crt
                key server.key  # 该文件应该保密
                # 指定迪菲・赫尔曼参数。
                # 你可以使用如下名称命令生成你的参数：
                # openssl dhparam -out dh1024.pem 1024
                # 如果你使用的是2048位密钥，使用2048替换其中的1024。
                dh dh1024.pem
                # 设置服务器端模式，并提供一个VPN子网，以便于从中为客户端分配IP地址。
                # 在此处的示例中，服务器端自身将占用10.8.0.1，其他的将提供客户端使用。
                # 如果你使用的是以太网桥接模式，请注释掉该行。更多信息请查看官方手册页面。
                server 10.8.0.0 255.255.255.0
                # 指定用于记录客户端和虚拟IP地址的关联关系的文件。
                # 当重启OpenVPN时，再次连接的客户端将分配到与上一次分配相同的虚拟IP地址
                ifconfig-pool-persist ipp.txt
                # 该指令仅针对以太网桥接模式。
                # 首先，你必须使用操作系统的桥接能力将以太网网卡接口和TAP接口进行桥接。
                # 然后，你需要手动设置桥接接口的IP地址、子网掩码；
                # 在这里，我们假设为10.8.0.4和255.255.255.0。
                # 最后，我们必须指定子网的一个IP范围(例如从10.8.0.50开始，到10.8.0.100结束)，以便于分配给连接的客户端。
                # 如果你不是以太网桥接模式，直接注释掉这行指令即可。
                ;server-bridge 10.8.0.4 255.255.255.0 10.8.0.50 10.8.0.100
                # 该指令仅针对使用DHCP代理的以太网桥接模式，
                # 此时客户端将请求服务器端的DHCP服务器，从而获得分配给它的IP地址和DNS服务器地址。
                # 在此之前，你也需要先将以太网网卡接口和TAP接口进行桥接。
                # 注意：该指令仅用于OpenVPN客户端，并且该客户端的TAP适配器需要绑定到一个DHCP客户端上。
                ;server-bridge
                # 推送路由信息到客户端，以允许客户端能够连接到服务器背后的其他私有子网。
                # (简而言之，就是允许客户端访问VPN服务器自身所在的其他局域网)
                # 记住，这些私有子网也要将OpenVPN客户端的地址池(10.8.0.0/255.255.255.0)反馈回OpenVPN服务器。
                ;push "route 192.168.10.0 255.255.255.0"
                ;push "route 192.168.20.0 255.255.255.0"
                push "route 172.16.16.0 255.255.255.0"
                push "route 10.0.200.0 255.255.255.0"
                push "route 10.10.10.0 255.255.255.0"
                # 为指定的客户端分配指定的IP地址，或者客户端背后也有一个私有子网想要访问VPN，
                # 那么你可以针对该客户端的配置文件使用ccd子目录。
                # (简而言之，就是允许客户端所在的局域网成员也能够访问VPN)
                # 举个例子：假设有个Common Name为"Thelonious"的客户端背后也有一个小型子网想要连接到VPN，该子网为192.168.40.128/255.255.255.248。
                # 首先，你需要去掉下面两行指令的注释：
                ;client-config-dir ccd
                ;route 192.168.40.128 255.255.255.248
                # 然后创建一个文件ccd/Thelonious，该文件的内容为：
                # iroute 192.168.40.128 255.255.255.248
                # 这样客户端所在的局域网就可以访问VPN了。
                # 注意，这个指令只能在你是基于路由、而不是基于桥接的模式下才能生效。
                # 比如，你使用了"dev tun"和"server"指令。
                # 再举个例子：假设你想给Thelonious分配一个固定的IP地址10.9.0.1。
                # 首先，你需要去掉下面两行指令的注释：
                ;client-config-dir ccd
                ;route 10.9.0.0 255.255.255.252
                # 然后在文件ccd/Thelonious中添加如下指令：
                # ifconfig-push 10.9.0.1 10.9.0.2
                # 如果你想要为不同群组的客户端启用不同的防火墙访问策略，你可以使用如下两种方法：
                # (1)运行多个OpenVPN守护进程，每个进程对应一个群组，并为每个进程(群组)启用适当的防火墙规则。
                # (2) (进阶)创建一个脚本来动态地修改响应于来自不同客户的防火墙规则。
                # 关于learn-address脚本的更多信息请参考官方手册页面。
                ;learn-address ./script
                # 如果启用该指令，所有客户端的默认网关都将重定向到VPN，这将导致诸如web浏览器、DNS查询等所有客户端流量都经过VPN。
                # (为确保能正常工作，OpenVPN服务器所在计算机可能需要在TUN/TAP接口与以太网之间使用NAT或桥接技术进行连接)
                ;push "redirect-gateway def1 bypass-dhcp"
                # 某些具体的Windows网络设置可以被推送到客户端，例如DNS或WINS服务器地址。
                # 下列地址来自opendns.com提供的Public DNS 服务器。
                ;push "dhcp-option DNS 208.67.222.222"
                ;push "dhcp-option DNS 208.67.220.220"
                # 去掉该指令的注释将允许不同的客户端之间相互"可见"(允许客户端之间互相访问)。
                # 默认情况下，客户端只能"看见"服务器。为了确保客户端只能看见服务器，你还可以在服务器端的TUN/TAP接口上设置适当的防火墙规则。
                ;client-to-client
                # 如果多个客户端可能使用相同的证书/私钥文件或Common Name进行连接，那么你可以取消该指令的注释。
                # 建议该指令仅用于测试目的。对于生产使用环境而言，每个客户端都应该拥有自己的证书和私钥。
                # 如果你没有为每个客户端分别生成Common Name唯一的证书/私钥，你可以取消该行的注释(但不推荐这样做)。
                ;duplicate-cn
                # keepalive指令将导致类似于ping命令的消息被来回发送，以便于服务器端和客户端知道对方何时被关闭。
                # 每10秒钟ping一次，如果120秒内都没有收到对方的回复，则表示远程连接已经关闭。
                keepalive 10 120
                # 出于SSL/TLS之外更多的安全考虑，创建一个"HMAC 防火墙"可以帮助抵御DoS攻击和UDP端口淹没攻击。
                # 你可以使用以下命令来生成：
                # openvpn --genkey --secret ta.key
                # 服务器和每个客户端都需要拥有该密钥的一个拷贝。
                # 第二个参数在服务器端应该为'0'，在客户端应该为'1'。
                ;tls-auth ta.key 0 # 该文件应该保密
                # 选择一个密码加密算法。
                # 该配置项也必须复制到每个客户端配置文件中。
                ;cipher BF-CBC        # Blowfish (默认)
                ;cipher AES-128-CBC   # AES
                ;cipher DES-EDE3-CBC  # Triple-DES
                # 在VPN连接上启用压缩。
                # 如果你在此处启用了该指令，那么也应该在每个客户端配置文件中启用它。
                comp-lzo
                # 允许并发连接的客户端的最大数量
                ;max-clients 100
                # 在完成初始化工作之后，降低OpenVPN守护进程的权限是个不错的主意。
                # 该指令仅限于非Windows系统中使用。
                ;user nobody
                ;group nobody
                # 持久化选项可以尽量避免访问那些在重启之后由于用户权限降低而无法访问的某些资源。
                persist-key
                persist-tun
                # 输出一个简短的状态文件，用于显示当前的连接状态，该文件每分钟都会清空并重写一次。
                status openvpn-status.log
                # 默认情况下，日志消息将写入syslog(在Windows系统中，如果以服务方式运行，日志消息将写入OpenVPN安装目录的log文件夹中)。
                # 你可以使用log或者log-append来改变这种默认情况。
                # "log"方式在每次启动时都会清空之前的日志文件。
                # "log-append"这是在之前的日志内容后进行追加。
                # 你可以使用两种方式之一(但不要同时使用)。
                ;log         openvpn.log
                ;log-append  openvpn.log
                # 为日志文件设置适当的冗余级别(0~9)。冗余级别越高，输出的信息越详细。
                # 0 表示静默运行，只记录致命错误。
                # 4 表示合理的常规用法。
                # 5 和 6 可以帮助调试连接错误。
                # 9 表示极度冗余，输出非常详细的日志信息。
                verb 3
                # 重复信息的沉默度。
                # 相同类别的信息只有前20条会输出到日志文件中。
                ;mute 20
        4、配置内核和防火墙，启动服务
            ***开启路由转发功能
            # sed -i '/net.ipv4.ip_forward/s/0/1/' /etc/sysctl.conf
            # sed -i '/net.ipv4.ip_forward/s/#//' /etc/sysctl.conf
            # sysctl -p
            ***配置防火墙，别忘记保存
            # iptables -I INPUT -p tcp --dport 1194 -m comment --comment "openvpn" -j ACCEPT
            ***这一句可以保证客户端可以与服务器所在的其它网段主机通信，甚至可以上网
            # iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j MASQUERADE
            # mkdir /etc/iptables
            # iptables-save > /etc/iptables/iptables.conf
            ***关闭ufw防火墙，改成iptables，这一步按需要设置，比较ufw在Ubuntu默认关闭的。iptables和ufw任选一个即可。
            # ufw disable
            ***启动openvpn并设置为开机启动
            # systemctl start openvpn@server  
            # systemctl enable openvpn@server  
            ***在systemd单元文件的后面，我们通过指定特定的配置文件名来作为一个实例变量来开启OpenVPN服务，我们的配置文件名称为/etc/openvpn/server.conf，所以我们在systemd单元文件的后面添加@server来开启OpenVPN服务
        5、配置client
            ***安装软件，可以和服务器安装的保持一致：
            ***安装openssl和lzo，lzo用于压缩通讯数据加快传输速度
            # sudo apt-get install openssl libssl-dev
            # sudo apt-get install lzop
            ***安装openvpn和easy-rsa
            # sudo apt-get install openvpn
            # sudo apt-get install easy-rsa
        6、创建客户端配置文件client.ovpn（用于客户端软件使用）
            ***复制一份client.conf模板命名为client.ovpn
            # cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf /etc/openvpn/client.ovpn  
            ***编辑client.ovpn
            # vim /etc/openvpn/client.ovpn
                client
                dev tun # 路由模式
                # 改为tcp
                proto tcp
                # OpenVPN服务器的外网IP和端口
                remote 119.18.192.104 1194
                resolv-retry infinite
                nobind
                persist-key
                persist-tun
                ca ca.crt
                # client1的证书
                cert client1.crt
                # client1的密钥
                key client1.key
                ns-cert-type server
                # 去掉前面的注释
                tls-auth ta.key 1
                comp-lzo
                verb 5
        7、将第2步中创建的客户端相关证书密钥及ca证书密钥等复制过来
            [root@linux64 openvpn]# scp root@119.18.192.104:/usr/share/easy-rsa/keys /etc/openvpn/
            [root@linux64 openvpn]# pwd
            /etc/openvpn
            [root@linux64 openvpn]# ls
            ca.crt client1.crt client1.key client.ovpn conf ta.key
            ***启动客户端
            # openvpn --daemon --cd /etc/openvpn --config client.ovpn --log-append /var/log/openvpn.log &
            ***上面是以守护进程启动的，可以把上面脚本放在/etc/rc.local实现开机启动。或者使用以服务的形式启动，如果想清晰明了，建议放在启动脚本。

        友情提示：经过生产环境多次测试，如果vpn不能拔通，一定要仔细检查服务器端server.conf和客户端的client.ovpn两个配置文件，只有相对应的项匹配才能拔通，比如两端是tcp还是udp，是否都开启tls-auth等

openvpn的高级用法：
openvpn的连接方式有两种

dev tap 基于桥接模式
dev tun 基于路由模式
包含基于路由模式的VPN服务器端的多台计算机(dev tun)
VPN既然能够让服务器和客户端之间具备点对点的通信能力，那么扩展VPN的作用范围，从而使客户端能够访问服务器所在网络的其他计算机，而不仅仅是服务器自己。

我们来做这样一个假设，服务器端所在局域网的网段为10.66.0.0/24，VPN IP地址池使用10.8.0.0/24作为OpenVPN服务器配置文件中server指令的传递参数。

首先，你必须声明，对于VPN客户端而言，10.66.0.0/24网段是可以通过VPN进行访问的。你可以通过在服务器端配置文件中简单地配置如下指令来实现该目的：

push "route 10.66.0.0 255.255.255.0"
下一步，你必须在服务器端的局域网网关创建一个路由，从而将VPN的客户端网段(10.8.0.0/24)路由到OpenVPN服务器(只有OpenVPN服务器和局域网网关不在同一计算机才需要这样做)。

另外，请确保你已经在OpenVPN服务器所在计算机上启用了IP和TUN/TAP转发。

增加此条路由转发

iptables -t nat -A POSTROUTING -s 10.8.0.0/255.255.255.0 -j SNAT --to-source  10.66.0.xx
包含基于桥接模式的VPN服务器端的多台计算机(dev tap)
使用以太网桥接的好处之一就是你无需进行任何额外的配置就可以实现该目的。

让客户端所在网段中的服务器都添加进网络，与服务端网络互通信
包含基于路由模式的VPN客户端的多台计算机(dev tun)
在典型的远程访问方案中，客户端都是作为单一的计算机连接到VPN。但是，假设客户端计算机是本地局域网的网关(例如一个家庭办公室)，并且你想要让客户端局域网中的每台计算机都能够通过VPN。

举这样一个例子，我们假设你的客户端局域网网段为192.168.4.0/24，VPN客户端使用的证书的Common Name为client2。我们的目标是建立一个客户端局域网的计算机和服务器局域网的计算机都能够通过VPN进行相互通讯。

在创建之前，下面是一些基本的前提条件：

客户端局域网网段(在我们的例子中是192.168.4.0/24)不能和VPN的服务器或任意客户端使用相同的网段。每一个以路由方式加入到VPN的子网网段都必须是唯一的。
该客户端的证书的Common Name必须是唯一的(在我们的例子中是"client2")，并且OpenVPN服务器配置文件不能使用duplicate-cn标记。
首先，请确保该客户端所在计算机已经启用了IP和TUN/TAP转发。

下一步，我们需要在服务器端做一些必要的配置更改。如果当前的服务器配置文件没有引用一个客户端配置目录，请添加一个：

client-config-dir ccd
在上面的指令中，ccd是一个已经在OpenVPN服务器运行的默认目录中预先创建好的文件夹的名称。在Linux中，运行的默认目录往往是/etc/openvpn；在Windows中，其通常是OpenVPN安装路径/config。当一个新的客户端连接到OpenVPN服务器，后台进程将会检查配置目录(这里是ccd)中是否存在一个与连接的客户端的Common Name匹配的文件(这里是"client2")。如果找到了匹配的文件，OpenVPN将会读取该文件，作为附加的配置文件指令来处理，并应用于该名称的客户端。

下一步就是在ccd目录中创建一个名为client2的文件。该文件应该包含如下内容：

iroute 192.168.4.0 255.255.255.0
这将告诉OpenVPN服务器：子网网段192.168.4.0/24应该被路由到client2。
接着，在OpenVPN服务器配置文件(不是ccd/client2文件)中添加如下指令：

route 192.168.4.0 255.255.255.0
你可能会问，为什么需要多余的route和iroute语句？原因是，route语句控制从系统内核到OpenVPN服务器的路由，iroute控制从OpenVPN服务器到远程客户端的路由。它们都是必要的。[详见最后附录]

下一步，请考虑是否允许client2所在的子网(192.168.4.0/24)与OpenVPN服务器的其他客户端进行相互通讯。如果允许，请在服务器配置文件中添加如下语句：

client-to-client
push "route 192.168.4.0 255.255.255.0"
这将导致OpenVPN服务器向其他正在连接的客户端宣告client2子网的存在。

最后一步，这也是经常被忘记的一步：在服务器的局域网网关处添加一个路由，用以将192.168.4.0/24定向到OpenVPN服务器(如果OpenVPN服务器和局域网网关在同一计算机上，则无需这么做)。假设缺少了这一步，当你从192.168.4.8向服务器局域网的某台计算机发送ping命令时，这个外部ping命令很可能能够到达目标计算机，但是却不知道如何路由一个ping回复，因为它不知道如何达到192.168.4.0/24。主要的使用规则是：当全部的局域网都通过VPN时(并且OpenVPN服务器和局域网网关不在同一计算机)，请确保在局域网网关处将所有的VPN子网都路由到VPN服务器所在计算机。

类似地，如果OpenVPN客户端和客户端局域网网关不在同一计算机上，请在客户端局域网网关处创建路由，以确保通过VPN的所有子网都能转向OpenVPN客户端所在计算机。

包含基于桥接模式的VPN客户端的多台计算机(dev tap)
这需要更加复杂的设置(实际操作可能并不复杂，但详细解释就比较麻烦)：

你必须将客户端的TAP接口与连接局域网的网卡进行桥接。
你必须手动设置客户端TAP接口的IP/子网掩码。
你必须配置客户端计算机使用桥接子网中的IP/子网掩码，这可能要通过查询OpenVPN服务器的DHCP服务器来完成。

关于iroute：

解释起来就是internal route，其实就是独立于系统路由之外的OpenVPN的路由，该路由起到了访问控制的作用，特别是是在多对一即server模式的OpenVPN拓扑中，该机制可以在防止地址欺骗的同时更加灵活的针对每一个接入的客户端进行单独配置。在多对一的情况下，必须要有机制检查访问内网资源的用户就是开始接入的那个用户，由于OpenVPN是第三层的VPN，而且基于独立于OpenVPN进程之外的虚拟网卡，那么一定要防止单独的客户端盗用其它接入客户端的地址的情况。在特定客户端的上下文中配置iroute选项，它是一个ip子网，默认是客户端虚拟ip地址掩码是32位，你可以在保证路由以及IP地址不混乱的前提下任意配置它，OpenVPN仅仅让载荷数据包的源IP地址在iroute选项中配置的子网内的主机通过检查，其它数据载荷一律drop。比如客户端虚拟IP地址是172.16.0.2，而OpenVPN服务器针对该客户端的iroute参数是10.0.0.0/24,那么只要载荷数据包的源IP地址在10.0.0.0/24这个子网中，一律可以通过检查。iroute是OpenVPN内部维护的一个路由，它主要用于维护和定位多个客户端所在的子网以及所挂接的子网，鉴于此，OpenVPN对所谓的网对网拓扑的支持其实超级灵活，它能做到这个虚拟专用网到哪里终止以及从哪里开始。



