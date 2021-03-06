CFSSL工具
CFSSL介绍
项目地址： https://github.com/cloudflare/cfssl
下载地址： https://pkg.cfssl.org/
参考链接： https://blog.cloudflare.com/how-to-build-your-own-public-key-infrastructure/
CFSSL是CloudFlare开源的一款PKI/TLS工具。 CFSSL 包含一个命令行工具 和一个用于 签名，验证并且捆绑TLS证书的 HTTP API 服务。 使用Go语言编写。
CFSSL包括：
    一组用于生成自定义 TLS PKI 的工具
    cfssl程序，是CFSSL的命令行工具
    multirootca程序是可以使用多个签名密钥的证书颁发机构服务器
    mkbundle程序用于构建证书池
    cfssljson程序，从cfssl和multirootca程序获取JSON输出，并将证书，密钥，CSR和bundle写入磁盘
PKI借助数字证书和公钥加密技术提供可信任的网络身份。通常，证书就是一个包含如下身份信息的文件：
    证书所有组织的信息
    公钥
    证书颁发组织的信息
    证书颁发组织授予的权限，如证书有效期、适用的主机名、用途等
    使用证书颁发组织私钥创建的数字签名

安装cfssl
这里我们只用到cfssl工具和cfssljson工具：
    wget https://pkg.cfssl.org/R1.2/cfssl_linux-amd64
    wget https://pkg.cfssl.org/R1.2/cfssljson_linux-amd64
    wget https://pkg.cfssl.org/R1.2/cfssl-certinfo_linux-amd64
    chmod +x cfssl_linux-amd64 cfssljson_linux-amd64 cfssl-certinfo_linux-amd64
    mv cfssl_linux-amd64 /usr/local/bin/cfssl
    mv cfssljson_linux-amd64 /usr/local/bin/cfssljson
    mv cfssl-certinfo_linux-amd64 /usr/bin/cfssl-certinfo
cfssl工具，子命令介绍：
    bundle: 创建包含客户端证书的证书包
    genkey: 生成一个key(私钥)和CSR(证书签名请求)
    scan: 扫描主机问题
    revoke: 吊销证书
    certinfo: 输出给定证书的证书信息， 跟cfssl-certinfo 工具作用一样
    gencrl: 生成新的证书吊销列表
    selfsign: 生成一个新的自签名密钥和 签名证书
    print-defaults: 打印默认配置，这个默认配置可以用作模板
    serve: 启动一个HTTP API服务
    gencert: 生成新的key(密钥)和签名证书
        -ca：指明ca的证书
        -ca-key：指明ca的私钥文件
        -config：指明请求证书的json文件
        -profile：与-config中的profile对应，是指根据config中的profile段来生成证书的相关信息
            容器相关证书类型:
                client certificate： 用于服务端认证客户端,例如etcdctl、etcd proxy、fleetctl、docker客户端
                server certificate: 服务端使用，客户端以此验证服务端身份,例如docker服务端、kube-apiserver
                peer certificate: 双向证书，用于etcd集群成员间通信
    ocspdump
    ocspsign
    info: 获取有关远程签名者的信息
    sign: 签名一个客户端证书，通过给定的CA和CA密钥，和主机名
    ocsprefresh
    ocspserve

创建认证中心(CA)
CFSSL可以创建一个获取和操作证书的内部认证中心。
运行认证中心需要一个CA证书和相应的CA私钥。任何知道私钥的人都可以充当CA颁发证书。因此，私钥的保护至关重要。
生成CA证书和私钥(root 证书和私钥)
# mkdir /opt/ssl
# cd /opt/ssl
# cfssl print-defaults config > ca-config.json
配置证书生成策略，让CA软件知道颁发什么样的证书。
修改ca-config.json,分别配置针对三种不同证书类型的profile,其中有效期43800h为5年
    {
    "signing": {
        "default": {
            "expiry": "43800h"
        },
        "profiles": {
            "server": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth"
                ]
            },
            "client": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "client auth"
                ]
            },
            "peer": {
                "expiry": "43800h",
                "usages": [
                    "signing",
                    "key encipherment",
                    "server auth",
                    "client auth"
                ]
            }
        }
    }
    }
这个策略，有一个默认的配置，和三个profile
    默认策略，指定了证书的有效期是一年(8760h)
    server,client,peer策略，指定了证书的用途
    signing, 表示该证书可用于签名其它证书；生成的 ca.pem 证书中 CA=TRUE
    server auth：表示 client 可以用该 CA 对 server 提供的证书进行验证
    client auth：表示 server 可以用该 CA 对 client 提供的证书进行验证

# cfssl print-defaults csr > ca-csr.json
修改ca-csr.json
    {
    "CN": "Self Signed Ca",
    "key": {
        "algo": "rsa",
        "size": 2048
    },
    "names": [
        {
            "C": "CN",
            "L": "SH",
            "O": "Netease",
            "ST": "SH",            
            "OU": "OT"
        }    ]
    }

术语介绍:
    CN: Common Name，浏览器使用该字段验证网站是否合法，一般写的是域名。非常重要。浏览器使用该字段验证网站是否合法
    C: Country， 国家
    L: Locality，地区，城市
    O: Organization Name，组织名称，公司名称
    OU: Organization Unit Name，组织单位名称，公司部门
    ST: State，州，省

生成CA证书和CA私钥和CSR(证书签名请求):
    # cfssl gencert -initca ca-csr.json | cfssljson -bare ca  ## 初始化ca
    # ls ca*
    ca.csr  ca-csr.json  ca-key.pem  ca.pem
    该命令会生成运行CA所必需的文件ca-key.pem（私钥）和ca.pem（证书），还会生成ca.csr（证书签名请求），用于交叉签名或重新签名。

小提示：
    使用现有的CA私钥，重新生成：
        # cfssl gencert -initca -ca-key key.pem ca-csr.json | cfssljson -bare ca
    使用现有的CA私钥和CA证书，重新生成：
        # cfssl gencert -renewca -ca cert.pem -ca-key key.pem
    查看cert(证书信息):
        # cfssl certinfo -cert ca.pem
    查看CSR(证书签名请求)信息：
        # cfssl certinfo -csr ca.csr

签发Server Certificate
    # cfssl print-defaults csr &gt; server.json
    # vim server.json
    {
        "CN": "Server",
        "hosts": [
            "192.168.1.1"
        ],
        "key": {
            "algo": "ecdsa",
            "size": 256
        },
        "names": [
            {
                "C": "CN",
                "L": "SH",
                "ST": "SH"
            }
        ]
    }
    生成服务端证书和私钥
    # cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=server server.json | cfssljson -bare server

签发Client Certificate
    # cfssl print-defaults csr &gt; client.json
    # vim client.json
    {
        "CN": "Client",
        "hosts": [],
        "key": {
            "algo": "ecdsa",
            "size": 256
        },
        "names": [
            {
                "C": "CN",
                "L": "SH",
                "ST": "SH"
            }
        ]
    }
    生成客户端证书和私钥
    # cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=client client.json | cfssljson -bare client
签发peer certificate
    # cfssl print-defaults csr &gt; member1.json
    # vim member1.json
    {
        "CN": "member1",
        "hosts": [
            "192.168.1.1"
        ],
        "key": {
            "algo": "ecdsa",
            "size": 256
        },
        "names": [
            {
                "C": "CN",
                "L": "SH",
                "ST": "SH"
            }
        ]
    }
    为节点member1生成证书和私钥:
    # cfssl gencert -ca=ca.pem -ca-key=ca-key.pem -config=ca-config.json -profile=peer member1.json | cfssljson -bare member1
    针对etcd服务,每个etcd节点上按照上述方法生成相应的证书和私钥


最后校验证书
校验生成的证书是否和配置相符
    # openssl x509 -in ca.pem -text -noout
    # openssl x509 -in server.pem -text -noout
    # openssl x509 -in client.pem -text -noout

cfssl常用命令：
    cfssl gencert -initca ca-csr.json | cfssljson -bare ca ## 初始化ca
    cfssl gencert -initca -ca-key key.pem ca-csr.json | cfssljson -bare ca ## 使用现有私钥, 重新生成
    cfssl certinfo -cert ca.pem
    cfssl certinfo -csr ca.csr


