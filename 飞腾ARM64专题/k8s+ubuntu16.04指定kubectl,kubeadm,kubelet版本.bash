环境约束：kubeadm支持的Ubuntu 16.04+, CentOS 7 or HypriotOS v1.0.1+三种操作系统。
环境约束：Kubernetes1.9.0最大支持docker版本为17.03.X。

一、采用kubeadm
1. 安装docker
    可以直接通过apt-get udpate && apt-get install -y docker.io 
		docker version 得出版本为：Client/Server 1.13.1
    这里也可以指定docker版本下载，因为目前docker分为docker ce和docker ee两个版本，我们只能安装免费的docker ce。需要先安装相关工具：
		# apt-get update
		# apt-get install -y \
			apt-transport-https \
			ca-certificates \
			curl \
			software-properties-common
    添加秘钥
		# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    通过上面安装的add-apt-respostitory工具，将软件源添加到/etc/apt/source.list中
		# add-apt-repository \
		   "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
		   $(lsb_release -cs) \
		   stable"
     最后，根据你自己想下载的docker版本进行下载：
		# apt-get update && apt-get install -y docker-ce= \
			$(apt-cache madison docker-ce | grep 17.03 | head -1 | awk '{print $3}')
2. 在每台机器上安装kubectl，kubelet，kubeadm
    先下载一个工具
		# apt-get update && apt-get install -y apt-transport-https
    接下来添加秘钥
		# curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
	经测试这里可能报错： gpg:no valid OpenPGP data found
		注意：需要通过下面两条命令来解决：curl -O https://packages.cloud.google.com/apt/doc/apt-key.gpg 先保存一个apt-key.gpg的文件，再通过apt-key add apt-key.gpg来加载。

	添加Kubernetes软件源
		# cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
		deb http://apt.kubernetes.io/ kubernetes-xenial main
		EOF
   安装命令：
		# apt-get update && apt-get install -y kubelet kubeadm kubectl 这里采用对应版本安装，或者从已安装的机器上copy
   当然，以上的curl -O命令和apt-get命令，如果不成功，可以尝试加上proxychains前缀，通过socks代理实现下载，亲测可用。

		注意：在ubuntu14.04中kubelet kubectl kubeadm三个二进制文件存放目录为/usr/local/bin; 在ubuntu16.04中kubelet kubectl kubeadm三个二进制文件存放目录为/usr/bin/; 当然需要chmod a+x kubelet kubectl kubeadm 才能执行二进制文件。

3. 在master节点上运行Kubernetes
    通过1,2之后，发现还是无法使用kubectl，这里还需要执行如下命令：
		# export KUBECONFIG=/etc/kubernetes/admin.conf
			注意：这里如果只在终端里执行export，只能在当前终端中实现；可用在~/.bashrc文件中添加，也可以在/etc/profile文件中添加，区别就是对于当前用户还是所有用户生效，这里在/etc/profile中添加，使其生效可执行： source  /etc/profile
    在master节点上执行： 
		# kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=*.*.*.* --kubernetes-version=v1.9.0 --ignore-preflight-errors=Swap 
	init成功后，copy kubeadm join代码：
		# kubeadm join --token 39d241.e7c2601a87fdde0d 192.168.40.234:6443 --discovery-token-ca-cert-hash sha256:7629e2390cb578e06df313ece69754b9c82525da94532f0403bda3a9b5d2ba00
			注意1： /lib/systemd/system/docker.service.d/socks5-proxy.conf 中设置了docker的socks5代理。
					[Service]
					Environment="ALL_PROXY=socks5://192.168.0.10:1080"
			注意2：/etc/systemd/system/kubelet.service.d/10-kubeadm.conf 中设置了kubelet和docker同一 类型cgroupfs，因为kubelet默认的是systemd类型。
					Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=cgroupfs" 
	问题1：运行了kubeadm init后master的状态为notReady
	原因是：需要安装network addon，这里我们使用Flannel

		# kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.9.1/Documentation/kube-flannel.yml
			注意：如果运行出错，可能是需要添加， --iface=ens33，对应的是网卡名称
					image: quay.io/coreos/flannel:v0.9.1-amd64
					command: [ "/opt/bin/flanneld", "--ip-masq", "--kube-subnet-mgr", "--iface=ens33" ]
	问题2： 怎么让master可以作为work节点，因为默认是不允许master作为工作节点的。
		# kubectl taint nodes --all node-role.kubernetes.io/master-
	问题3： 怎么在apt-get install kubectl kubeadm kubelet时，选择特定版本下载安装？
		a.通过apt-cache showpkg kubeadm
            root@master1:~# apt-cache showpkg kubeadm
            Package: kubeadm
            Versions: 
            1.11.3-00 (/var/lib/dpkg/status)
            Description Language: 
                            File: /var/lib/dpkg/status
                            MD5: bb3c7836839894793de38af875e01b30
            Reverse Depends: 
            Dependencies: 
            1.11.3-00 - kubelet (2 1.6.0) kubectl (2 1.6.0) kubernetes-cni (5 0.6.0) cri-tools (2 1.11.0) 
            Provides: //这里是手动下载了1.11.3这个版本，所以只有这一个提供了，官方实际提供了所有的版本http://apt.kubernetes.io/
            1.11.3-00 - 
            Reverse Provides: 
            root@master1:~# 
            然后执行安装相应的版本
            root@master1:~# apt install kubeadm=1.11.3-00 
        b.也可以通过二进制来安装
            # curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/v1.9.0/bin/linux/amd64/{kubeadm,kubelet,kubectl}
            # curl -L --remote-name-all https://storage.googleapis.com/kubernetes-release/release/v1.10.9/bin/linux/arm64/{kubeadm,kubelet,kubectl}
                其中的$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)，可以替换成你想要的版本，比如：v1.11.1
	        这里还需要获取/etc/systemd/system/kubelet.service文件
		    # curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/kubelet.service" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service
            再创建/etc/systemd/system/kubelet.service.d/10-kubeadm.conf文件
		    # mkdir -p /etc/systemd/system/kubelet.service.d
		    # curl -sSL "https://raw.githubusercontent.com/kubernetes/kubernetes/${RELEASE}/build/debs/10-kubeadm.conf" | sed "s:/usr/bin:/opt/bin:g" > /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
	问题4： 为什么执行kubeamd join之后，虽然在master上可以查看到节点，但是仍然为notReady？
		这里还需要将admin.conf文件从master节点上拷贝到node节点上，同样可以写入/etc/profile
		# scp root@<masterIp>:/etc/kubernetes/admin.conf /etc/kubernetes/admin.conf
		# echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /etc/profile
		# source /etc/profile
			注意： 这里经过测试发现，在node节点上执行完kubeadm join之后，会在/etc/kubernetes目录下生成kubelet.conf文件，则不需要copy admin.conf文件，只需将
		# export KUBECONFIG=/etc/kubernetes/kubelet.conf添加至/etc/profile，并执行source /etc/profile。

	问题5： 为什么kubectl proxy命令显示start server 127.0.0.1:8001，但是访问不了？
		这是因为kubectl proxy如果没有任何参数的话，默认是只在本地开启访问，ip地址只能是127.0.0.1才能访问。但是可以通过添加参数，达到外界可以访问的目的：
		# kubectl proxy --address='0.0.0.0' --port=30099 --accept-hosts='^*$'  
		这样就可以通过http://{nodeIP}:30099/访问到api了，这里在任何一台node上都可以。

4. 运行master以及通过kubeadm join添加node之后，也可以删除node节点   
	# kubectl drain nodeName --delete-local-data --force --ignore-daemonsets
	# kubectl delete node nodeName 
	并且在node上执行如下命令进行清理：
	# kubeadm reset
	# ifconfig cni0 down
	# ip link delete cni0
	# ifconfig flannel.1 down
	# ip link delete flannel.1
	# rm -rf /var/lib/cni/
	# rm -rf /etc/kubernetes/
	
	#以下命令相当于reset,比reset更彻底，例如删除了/etc/kubernetes目录
	# systemctl stop kubelet;
	# docker rm -f -v $(docker ps -q);
	# find /var/lib/kubelet | xargs -n 1 findmnt -n -t tmpfs -o TARGET -T | uniq | xargs -r umount -v;
	# rm -r -f /etc/kubernetes /var/lib/kubelet /var/lib/etcd;
5. 测试dns是否生效
	# kubectl run curl --image=radial/busyboxplus:curl -i --tty
	nslookup kubernetes.default
	结果如下：
	Server:    10.96.0.10
	Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

	Name:      kubernetes.default
	Address 1: 10.96.0.1 kubernetes.default.svc.cluster.local
 
附加1：在ubuntu16.04.03中，开启内核IP转发，以及内核调优
	# vim /etc/sysctl.conf  
	# echo "net.netfilter.nf_conntrack_max=1000000" >> /etc/sysctl.conf
	# echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
	# echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
	使其立即生效： sysctl -p
附加2：Docker从1.13版本开始调整了默认的防火墙规则，禁用了iptables filter表中FOWARD链，这样会引起Kubernetes集群中跨Node的Pod无法通信，在各个Docker节点执行下面的命令：
	# iptables -P FORWARD ACCEPT
	查看iptables -nvL 
附加3：Kubernetes 1.8开始要求关闭系统的Swap，如果不关闭，默认配置下kubelet将无法启动。可以通过kubelet的启动参数--fail-swap-on=false更改这个限制。 我们这里关闭系统的Swap:
	# swapoff -a
	通过free -m查看是否关闭
	这里如果在kubelet.service文件中添加一个参数，则可以忽略Swap，这样比较优雅，不会影响其他应用。
	# vim /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
		Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"
		ExecStart=...$KUBELET_EXTRA_ARGS
附加4：通过kubectl命令获取secret，以及token，用于登录dashboard ui
	# kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin | awk '{print $1}')
附加5：k8s 1.6之后都采用了RBAC授权模型
	默认cluster-admin是拥有全部权限的，将用户和cluster-admin bind这样用户就有cluster-admin的权限。
	# kubectl get clusterrole cluster-admin -o yaml 查看cluster-admin的权限。
	那我们将用户和cluster-admin 绑定在一起这样用户也拥有cluster-admin的权限：
	# kubectl create clusterrolebinding login-on-dashboard-with-cluster-admin --clusterrole=cluster-admin --user=root
	通过kubectl get clusterrolebinding/login-on-dashboard-with-cluster-admin -o yaml命令可以查看新建的用户权限。
附加6： 安装heapster插件，目前github上最新的tag是1.5.3版本
	$ wget https://github.com/kubernetes/heapster/archive/v1.5.3.zip
	$ unzip v1.5.3.zip
	$ cd heapster-1.5.3/deploy/kube-config/influxdb
	$ ls
	grafana.yaml  heapster.yaml  influxdb.yaml
	具体还需要通过kubectl create -f ./  运行yaml文件，并配置其中的参数。
	RBAC Authorization的基本概念是Role和RoleBinding。Role是一些permission的集合；而RoleBinding则是将Role授权给某些User、某些Group或某些ServiceAccount。K8s官方博客《RBAC Support in Kubernetes》一文的中的配图对此做了很生动的诠释：
	可以看到，在rules设定中，cluster-admin似乎拥有了“无限”权限。不过注意：这里仅仅授权给了一个service account，并没有授权给user或group。并且这里的kubernetes-dashboard是dashboard访问apiserver时使用的(下图右侧流程)，并不是user访问APIServer时使用的。
			 user authentication			   service authentication
	browser ---------------------> apiserver <------------------------ dashboard

	本文是通过在dashboard的service中添加NodePort作为对外提供服务的端口。
	1. kubectl describe secret $(kubectl get secret -n kube-system |grep admin|awk "{print $1}")
	   获取token
	2. kubectl get svc -n kube-system
	   获取到对外提供的NodePort
	3. 这里用火狐浏览器访问：https://nodeIp:NodePort/即可。
	   在谷歌浏览器上出现非安全连接的https证书问题。
	我们需要给登录dashboard或者说apiserver的user(图左侧)进行授权。


