功能：
    自动装箱、自动修复、水平扩展、服务发现和负载均衡、自动发布和回滚
    密钥和配置管理(类似entrypoint传递环境变量给容器)
        手动定制
        中心化配置
    存储编排、批量处理执行

k8s即集群：
    有中心的系统(master-node)
    ha: 3 master+ # node
    master/node:
        master: API Server、Schedular、controller-manager
        node: kubelet、容器引擎(docker....)
    Pod:
        Label: key=value
        Label Selector:
    Pod:
        自主式Pod
            kind: Pod
        控制器Pod
            kind: ReplicationController(最早只有这一个)
                滚动更新
            kind: ReplecaSet
                不直接使用，一般是被Deployment调用
            kind: Deployment
                无状态
            kind: StatefulSet
                有状态
            kind: DaemonSet
                只运行一个副本
            kind: Job/CronJob
                计划任务，执行完任务即可退出
        HPA控制器(HorizontalPodAutoscaler)
            监控pod,如果pod承受不了，则由定义的自动生成多个pod
    AddOns: 附件
    网络：有三层网络，节点网络，service网络，pod网络,后两者都是cluster网络，默认不能被外网访问
k8s安装：
    安装时注意指定pod网络，service网络，版本，忽略Swap错误(在/etc/sysconfig/kubelet中指定--fail-swap-on=false)
    命令行初始化：
        #kubeadm init --kubernetes-version=v1.11.1 --pod-network-cidr=10.244.0.0/16 --service-cidr=10.96.0.0/12 --ignore-preflight-errors=Swap

        跑两个服务
        #kubectl run nginx-deploy --image=nginx:1.14-alpine --port=80 --replicas=1
        #kubectl run myapp-deploy --image=ikubernetes/myapp:v1 --port=80 --replicas=3
        可以看到pod的标签供service使用
        #kubectl get pod --show-labels
        创建服务
        #kubectl expose deployment nginx-deploy --name=nginx --port=80 --target-port=80 --protol=TCP
        #改容器中的镜像
        #kubectl set image deployment myapp myapp=ikubernetes/myapp:v2

    RESTful风格的api
        方法：get put delete post....
        命令调用：kubectl run/get/edit.....
    资源对象：
        workload: Pod, ReplicaSet, Deployment, StatefulSet, DaemonSet, Job, CronJob....
        服务发现及均衡：Service, Ingress....
        配置与存储：Volume, CSI(容器存储接口,支持第三方各种存储)
            跟配置文件中心相关：ConfigMap, Secret
            外部资源输出给容器：DownwardAPI
        集群级资源
            Namespace, Node, Role, ClusterRole, RoleBinding, ClusterRoleBinding
        元数据型资源
            HPA, PodTemplate, LimitRange

        创建资源方法：
            apiserver仅接收JSON格式的资源定义：
            yaml格式提供配置清单，apiserver可自动将其转为json格式，而后提交
        大部分资源的配置清单
            apiVersion: group/version(group省略就是core，像v1就是核心群)
            #kubectl api-versions
                alpha内测-->beta公测-->稳定版
            kind: 资源类别
                Pod, ReplicaSet, Deployment, StatefulSet, DaemonSet, Job, CronJob...
            metadata: 元数据
                name：什么名字
                namespace：是k8s定义的域
                labels：标签
                annotations：
                每个资源的引用PATH
                    /api/GROUP/VERSION/namespaces/NAMESPACE/TYPE/NAMESPACE/TYPE/NAMESPACE
            spec: 用户期望的状态
                spec.containers<[]object>
                - name: <string>
                  image: <string>
                  imagePullPolicy: <string> ###签为latest就是always，否则是IfNotPresent,这个字段是cannot be updated，即不允许更改，之前遇到的ClusterIP改动就不允许

            status: 当前状态，本字段由k8s集群自维护
                当两种状态不一致时，当前状态会无限接近期望状态

                #kubectl explain pod 可以查看资源定义格式
                #kubectl explain pod.metadata 查看子格式

                #kubectl explain pod.spec.container 查看container定义格式
                #kubectl explain pod.spec.containers.livenessProbe

            例1：
            apiVersion: v1
            kind: Pod
            metadata:
              name: pod-demo
              namespace: default
              labels:
                app: myapp 基于应用类别打标签
                tier: frontend 基于应用的逻辑层次
            spec:
              containers：
              - name: myapp
              image: ikubernetes/myapp:v1
              ports:
              - name: http
                containerPort: 80
              - name: https
                containerPort: 443
              - name: busybox
              image: busybox:latest
              imagePullPolicy: IfNotPresent ###注意下面是两种格式任选一种，所有的列表可以直接用中括号表示，所有的映射可以用花括号表示
              command: ["/bin/sh","-c","sleep 3600"]
              - "/bin/sh"
              - "-c"
              - "sleep 3600"
            #kubectl apply -f myapp.yml
            Run a command in a shell
            command: ["/bin/sh"]
                args: ["-c", "while true; do echo hello; sleep 10;done"]

                Image Entrypoint	Image Cmd	Container command	Container args	Command run
                [/ep-1]				[foo bar]	<not set>			<not set>		[ep-1 foo bar]
                [/ep-1]				[foo bar]	[/ep-2]				<not set>		[ep-2]
                [/ep-1]				[foo bar]	<not set>			[zoo boo]		[ep-1 zoo boo]
                [/ep-1]				[foo bar]	[/ep-2]				[zoo boo]		[ep-2 zoo boo]
                详情：https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#run-a-command-in-a-shell

            标签：
                Key=value
                    key: 字母、数字、_、-、.
                    value: 可以为空, 只能字母或数字开头及结尾, 中间可使用
                #kubectl get pods --show-labels 显示所有pod的标签
                #kubectl get pods -l app --show-labels 标签过滤

                #kubectl label pods pod-demo release=stable 打标签,如果已有release则用--over-write

            标签选择器：
                等值关系：=, ==, !=
                    #kubectl get pods -l release=stable --show-labels
                    #kubectl get pods -l release=stable, app=myapp
                集合关系：
                    key in (value1,value2)
                    key notin(value1,value2)

            许多资源支持内嵌字段定义其使用的标签选择器：
                matchLabels: 直接给定键值
                matchExpressions: 基于给定的表达式来定义使用标签选择器{key:"KEY",operator:"OPERRATOR",values:[val1,val2...]}
                    操作符：
                        In, NotIn: values字段的值必须为非空列表
                        Exists, NotExits: values字段的值必须为空列表

            nodeSelector <map[string]string>
                节点标签选择器
            nodeName <string>
                直接指定
            annotations:
                与label不同的地方在于，它不能用于挑选资源对象，仅用于为对象提供“元数据”


            Pod的生命周期：
                状态：Pending调度失败、Running、Failed、Succeeded、Unknown

                Pod生命周期中的重要行为：
                    初始化容器
                    容器探测：
                        liveness probe: 容器是否存活
                        readiness probe: 容器是否能提供服务
            restartPolicy:
                Always(default), OnFailure, Never


            liveness和readiness的探针类型三种：ExecAction、TCPSocketAction、HTTPGetAction
            例1：liveness
            apiVersion: v1
            kind: Pod
            metadata:
              name: liveness-httpget-pod
              namespace: default
            spec:
              containers:
              - name: liveness-httpget-container
                image: ikubernetes/myapp:v2
                ports:
                - name: http
                  containerPort: 80
              livenessProbe:
                httpGet:
                  port: http
                  path: /index.html
              initialDelaySeconds: 1
              periodSeconds: 3

            #探针格式如下：
            [root@node1 ~]# kubectl explain pod.spec.containers.livenessProbe.httpGet
            KIND:     Pod
            VERSION:  v1

            RESOURCE: httpGet <Object>

            DESCRIPTION:
                HTTPGet specifies the http request to perform.

                HTTPGetAction describes an action based on HTTP Get requests.

            FIELDS:
                host	<string>
                Host name to connect to, defaults to the pod IP. You probably want to set
                "Host" in httpHeaders instead.

                httpHeaders	<[]Object>
                Custom headers to set in the request. HTTP allows repeated headers.

                path	<string>
                Path to access on the HTTP server.

                port	<string> -required-
                Name or number of the port to access on the container. Number must be in
                the range 1 to 65535. Name must be an IANA_SVC_NAME.

                scheme	<string>
                Scheme to use for connecting to the host. Defaults to HTTP.

                例2：readiness
                apiVersion: v1
                kind: Pod
                metadata:
                  name: readiness-httpget-pod
                  namespace: default
                spec:
                  containers:
                  - name: readiness-httpget-container
                    image: ikubernetes/myapp:v2
                    ports:
                    - name: http
                      containerPort: 80
                  readinessProbe:
                    httpGet:
                      port: http
                      path: /index.html
                  initialDelaySeconds: 1
                  periodSeconds: 3

            还有一种叫lifecycle的pod启动前后可以执行的动作
            [root@node1 ~]# kubectl explain pod.spec.containers.lifecycle
            KIND:     Pod
            VERSION:  v1

            RESOURCE: lifecycle <Object>

            DESCRIPTION:
                 Actions that the management system should take in response to container
                 lifecycle events. Cannot be updated.

                 Lifecycle describes actions that the management system should take in
                 response to container lifecycle events. For the PostStart and PreStop
                 lifecycle handlers, management of the container blocks until the action is
                 complete, unless the container process fails, in which case the handler is
                 aborted.

            FIELDS:
                 postStart	<Object>
                 PostStart is called immediately after a container is created. If the
                 handler fails, the container is terminated and restarted according to its
                 restart policy. Other management of the container blocks until the hook
                 completes. More info:
                 https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#con
            tainer-hooks
                 preStop	<Object>
                 PreStop is called immediately before a container is terminated. The
                 container is terminated after the handler completes. The reason for
                 termination is passed to the handler. Regardless of the outcome of the
                 handler, the container is eventually terminated. Other management of the
                 container blocks until the hook completes. More info:
                 https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#con
            tainer-hooks
            [root@node1 ~]#
            例3：lifecycle
            apiVersion: v1
            kind: Pod
            metadata:
              name: poststart-pod
            spec:
              containers:
              - name: busybox-httpd
                image: busybox
                imagePullPolicy: IfNotPresent
                lifecycle:
                  postStart:
                    exec:
                      command: ["/bin/sh","-c","mkdir -p /data/web/html;echo hello >> /data/web/html/index.html"]
                commnad: ["/bin/httpd"]
                args: ["-f","-h /data/web/html"]
                #特别注意：后面的这个command先执行，很显然这个先后顺序导致文件不存在出错

            Pod控制器：
                ReplicationController: 早期用的，后来废弃了
                ReplicaSet: 保证用户自定义的副本个数并达到期望状态
                例1：
                apiVersion: apps/v1
                kind: ReplicaSet
                metadata:
                  name: myapp
                  namespace: default
                spec: ###这是控制器的spec
                  replicas: 2
                  selector:
                    matchLabels:
                      app: myapp
                      release: canary
                  template:
                    metadata:
                      name: myapp-pod ###这个名字没太大意义，pod的名字k8s用"控制器名+随机字串"
                      labels: ###注意这里的标签一定要对应上面控制器中的标签选择器，否则此pod没有意义
                        app: myapp
                        release: canary
                    spec: ###这是pod的spec
                      containers:
                      - name: myapp-container
                        image: ikubernetes/myapp:v1
                        ports:
                        - name: http
                          containerPort: 80
                    灰度发布-->canary发布-->蓝绿发布
                        灰度发布：手动edit replicaset升级image版本-->手动杀一个pod v1版, replicaset起动一个pod v2版
                        canary发布：手动起一个replicaset v2版,与v1版的replicaset同时提供服务,再干掉v1版replicaset
                        蓝绿发布：Deployment控制多个replicaset自动控制最大突增pod数和最少存活副本数间的平衡进行滚动更新，自动化但业务不中断，注意readiness的使有，不然有可能滚动更新完没有一个可以提供服务


                Deployment: 通过控制ReplicaSet来控制Pod
                    无状态的守护进程
                    例1：
                    apiVersion: apps/v1
                    kind: Deployment
                    metadata:
                      name: myapp-deploy
                      namespace: default
                    spec:
                      replicas: 2
                      selector:
                        matchLabels:
                          app: myapp
                          release: canary
                      template:
                        metadata:
                          labels:
                            app: myapp
                            release: canary
                        spec:
                          containers:
                          - name: myapp
                            image: ikubernetes/myapp:v1
                            ports:
                            - name: http
                              containerPort: 80
                        #kubectl apply -f xxx --record=true 记录历史以便更新
                        #kubectl rollup history deployment xxx
                        #kubeclt rollup undo deployment ###
                        #kubectl
                        改文件中的image版本
                        #kubectl get pods -w 动态显示滚动更新
                        或者用kubectl set image更改版本
                        #kubectl set image deployment xxx xxx
                        也可以用json格式打补丁修改
                        #kubectl patch deployment myapp-deploy -p '{"spec":{"replicas":5}}'

                        #用json格式修改strategy中的maxSurge,maxUnavailable
                        #kubectl patch deployment myapp-deploy -p '{"spec":{"strategy":{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}'
                DaemonSet: 用于确保每个节点只运行一个Pod，一般用于系统级别的守护进程
                    可以部分部署DaemonSet，比如监控有ssd硬盘的节点
                    无状态的守护进程
                    也是滚动更新，不过只有maxUavailable值，因为每个节点只能生成一个Pod
                    apiVersion：apps/v1
                    kind: Deployment
                    metadata:
                      name: redis
                      namespace: default
                    spec:
                      replicas: 1
                      selector:
                        matchLabels:
                          app: redis
                          role: logstor
                      template:
                        metadata:
                          labels:
                            app: redis
                            role: logstor
                        spec:
                          containers:
                          - name: redis
                            image: redis:4.0-alpine
                            ports:
                            - name: redis
                              containerPort: 6379
                    ---
                    apiVersion: apps/v1
                    kind: DaemonSet
                    metadata:
                      name: filebeat-ds
                      namespace: default
                    spec:
                      selector:
                        matchlabels:
                          app: filebeat
                          release: stable
                      templates:
                        metadata:
                          labels:
                            app: filebeat
                            release: stable
                        spec:
                          containers:
                          - name: filebeat
                            image: ikubernetes/filebeat:5.6.5-alpine
                            env: ###这两个环境变量是filebeat要求的,通过这些变量让pod间进行通信,协同工作
                            - name: REDIS_HOST
                              value: redis.default.svc.cluster.local
                            - name: REDIS_LOG_LEVEL
                              value: info
                Job：执行一次性作业
                CronJob: 周期性执行作业
                StatefulSet：有状态，需要持久存储的应用
                    每个应用的配置方式都不一样，定义起来很繁琐
                    于是出现了：
                        TPR: Third Part Resources, 1.2+出现 1.7后废了
                        CDR：Custom Defined Resources, 1.8+出现
                    再后来出现了：
                        Helm：

            Service:
                node network,pod network两个地址是实际配置的地址
                service network 是一种virtual ip

                三种工作模式：userspace(v1.1-), iptables(v1.10-), ipvs(v1.11+),google搜图谱查看很清淅
                    #要支持ipvs：1、/etc/sysconfig/kubelet-->KUBELET_EXTRA_ARGS="KUBE_PROXY_MODE=ipvs"
                                             2、开启内核模块ip_vs, ip_vs_rr, ip_vs_wrr, ip_vs_sh, nf_conntrack_ipv4
                    第一种是用户空间的kube-proxy转发：pod request-->service ip-->kube-proxy(socks)-->service ip-->另外的kube-proxy-->dest pod
                    第二种是iptables直接调度：pod request-->service ip(iptables)-->dest pod
                    第三种是ipvs调度：pod request-->ipvs-->dest pod
                    ###如果有新的pod加进来，api会让其记录在etcd中,kube-proxy监听到再转给iptables(ipvs)

                类型：ExternalName, ClusterIP, NodePort, LoadBalancer
                ClusterIP:
                例1：
                apiVersion: v1
                kind: Service
                metadata:
                  name: redis
                  namespace: default
                spec:
                    selector:
                      app: redis
                      role: logstor #这两个标签是在之前的pod中指定的
                    clusterIP: 10.97.7.7 ###最好不要自己指，有可能冲突
                    type: ClusterIP
                    ports:
                    - port: 6379 #service ip port
                      targetPort: 6379 #pod ip port
                ###实际上service是通过一个endpoint再到pod，这个endpoint也可以手动指定
                资源记录格式：
                    SVC_NAME.NS_NAME.DOMAIN.LTD(域名后缀).
                    svc.cluster.local.
                    redis.default.svc.cluster.local.
                如果要用nodePort，把type改成nodePort即可

                NodePort:
                例2：
                apiVersion: v1
                kind: Service
                metadata:
                  name: myapp
                  namespace: default
                spec:
                  selector:
                    app: myapp
                    release: canary #这两个标签是在之前的pod中指定的
                  clusterIP: 10.97.7.8 ###最好不要自己指，有可能冲突
                  type: nodePort
                  ports:
                  - port: 80 #service ip port
                    targetPort: 80 #pod ip port
                    nodePort: 30080	#不指就动态分配
                LoadBalancer:
                    云服务的LBaas-->NodePort-->pods
                ExternalName:
                当查询主机 my-service.prod.svc.CLUSTER时，集群的 DNS 服务将返回一个值为 my.database.example.com 的 CNAME 记录。 访问这个服务的工作方式与其它的相同，唯一不同的是重定向发生在 DNS 层，而且不会进行代理或转发。 如果后续决定要将数据库迁移到 Kubernetes 集群中，可以启动对应的 Pod，增加合适的 Selector 或 Endpoint，修改 Service 的 type。
                    kind: Service
                    apiVersion: v1
                    metadata:
                      name: my-service
                      namespace: prod
                    spec:
                      type: ExternalName
                      externalName: my.database.example.com

                sessionAffinity：
                    把来自同一客户的请求调到同一个Pod上
                    #kubectl pacth svc myapp -p '{"spec":{"sessionAffinity":"ClientIP"}}'

                headlessService:
                    一般一个service_name对应一个ClusterIP
                    无头指的是把service_name解析到pod_ip上
                例3：
                apiVersion: v1
                kind: Service
                metadata:
                    name: myapp-svc
                    namespace: default
                spec:
                    selector:
                        app: myapp
                    release: canary #这两个标签是在之前的pod中指定的
                    clusterIP: None ###None就是无头
                    ports:
                    - port: 80 #service ip port
                      targetPort: 80 #pod ip port


            Ingress: 也是标准的k8s资源
                架构关系：
                    1、一般情况下一个hostname(www.ly.com)通过多路径(/bbs,/eshop,/erp)映射到后端的不同的业务pods(bbs.index.html,eshop.index.html,erp.index.html)
                    2、pods有生命周期,随时ip会变,前端的upstream server不能动态识别，但是service资源有这个能力(通过labels随时关联至动态pods)
                    3、问题是service更新的状态如何给到upstream server呢,就需要用到Ingress这种资源动态跟service连通,再把pods变化的情况注入到upstream server(也就是ingress controller)
                    Note1：这个逻辑用到的service仅仅是利用service的分类能力，但不是通过它来调度,调度还是由可以借用ingress动态更新的ingress controller(upstream server)来调度
                    Note2：ingress controller(upstream server)由很多种，像nginx,envoy,traefik都可以
                例1：
                https://kubernetes.github.io/ingress-nginx/deploy/#generic-deployment
                1、定义好namespace-->rbac-->ingress controller-->pods-->service后
                #kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/mandatory.yaml
                2、定义ingress：
                apiVersion: extensions/v1beta1
                kind: Ingress
                metadata:
                    name: ingress-myapp
                    namespace: default
                    annotations: #注意这个现在就比较关键了，指明ingress controller是谁,不是envoy，不是traefik，是nginx
                        kubernetes.io/ingress.class: "nginx"
                spec:
                    rules:
                    - host: myapp.ly.com
                      http:
                        paths:
                        - path:
                          backend:
                            serviceName: myapp
                            servicePort: 80
                3、执行完ingress后，应该就能看到ingress controller(nginx)中的配置改成了这里定义的
                4、注意以上步骤定义完了只能在集群内部访问，想让集群以外的人访问有两种方式
                    (1)、可以定义一个Service Ingress为ingress controller映射外部ip
                        参考https://pascalnaber.wordpress.com/2017/10/27/configure-ingress-on-kubernetes-using-azure-container-service/
                    (2)、让ingress controller共享宿主机的网络栈,修改ingress controller yaml文件在deployment.spec.template.spec.containers.ports字段加上hostPort或者在deployment.spec.template.spec字段加上hostNetwork


            Volume:
                emptydir:
                    例1：
                    apiVersion: v1
                    kind: Pod
                    metadata:
                        name: pod-demo
                        namespace: default
                        labels:
                            app: myapp
                        tier: frontend
                        annotations:
                        ly.com/created-by: "cluster admin"
                    spec:
                        containers:
                        - name: consumer
                          image: busybox
                          imagePullPolicy: IfNotPresent
                          command: ['/bin/sh','-c','mkdir -p /data/web/html;while true;do cat /data/web/html/index.html; sleep 1;done']
                          volumeMounts:
                          - name: testvolume
                            mountPath: /data/web/html
                        - name: producer
                          image: busybox
                          imagePullPolicy: IfNotPresent
                          volumeMounts:
                          - name: testvolume
                            mountPath: /data/web/html
                          command: ['/bin/sh','-c','while true; do echo `date` >> /data/web/html/index.html; sleep 2;done']
                        volumes:
                        - name: testvolume
                          emptyDir: {}
                    *****注意: 这里的command放的位置有讲究，经验证，这个yaml文件执行有顺序，如果command放在volumeMount前面会报找不到/data/web/html错误，所以要在command中手动创建/data/web/html;
                             如果command放在volumeMount后面，那么vomumeMount中的/data/web/html即便没有也会自动创建，command命令也就可以用到此目录而无需手动创建

                network storage:
                    SAN: iSCSI
                    NAS: nfs,cifs
                    glusterfs:
                    cephfs
                云存储：
                    EBS, Azure Disk,
                pv&&pvc
                    静态情况下是先定义好多个pv,然后直接申请pvc即可，根据pvc要求的大小，bound到最佳的pv，大小不一定一样，但至少有pv是大于等于pvc
                    例1：
                    apiVersion: v1
                    kind: PersistentVolume
                    metadata:
                        name: pv001
                        labels:
                            name: pv001
                    spec:
                        nfs:
                            path: /data/volumes/v1
                            server: 192.168.1.41
                        accessModes: ["ReadWriteMany","ReadWriteOnce"]
                        capacity:
                            storage: 5Gi
                    ---
                    apiVersion: v1
                    kind: PersistentVolume
                    metadata:
                        name: pv002
                        labels:
                            name: pv002
                    spec:
                        nfs:
                            path: /data/volumes/v2
                            server: 192.168.1.41
                        accessModes: ["ReadWriteMany","ReadWriteOnce"]
                        capacity:
                            storage: 10Gi
                    ---
                    apiVersion: v1
                    kind: PersistentVolumeClaim
                    metadata:
                        name: mypvc
                        namespace: default
                    spec:
                        accessModes: ["ReadWriteMany"]
                        resources:
                            requests:
                                storage: 6Gi
                    ---
                    apiVersion: v1
                    kind: Pod
                    metadata:
                        name: pod-vol-pvc
                        namespace: default
                    spec:
                        containers:
                        - name: myapp
                          image: ikubernetes/myapp:v1
                          volumeMounts:
                          - name: html
                            mountPath: /usr/share/nginx/html/
                        volumes:
                        - name: html
                          persistentVolumeClaim:
                            claimName: mypvc

                    生产最多用的是动态
                        关键是定义好存储类


配置容器化应用的方式：
    1、自定义命令行参数：
        arg: []
    2、把配置文件直接焙进镜像
    3、环境变量
        (1) Cloud Native的应用程序一般可直接通过环境变量加载配置
        (2) 通过entrypoint脚本来预处理变量为配置文件中的配置信息
    4、存储卷
    configMap:
        #kubeclt create configmap nginx-config --from-literal=nginx_port=80 --from-literal=nignx_name=www.ly.com
        #kubectl create configmap nginx-config --from-file=./nginx.conf
        例1：
        apiVersion: v1
        kind: Pod
        metadata:
            name: pod-cm-1
            namespace: default
            labels:
                app: myapp
                tier: frontend
            annotations:
                ly.com/created-by: "cluster admin"
        spec:
            container:
            - name: myapp
              image: ikubernetes/myapp:v1
              ports:
              - name: http
              containerPort: 80
            env:
            - name: NGINX_SERVER_PORT
                valueFrom:
                  configMapKeyRef:
                    name: nginx-config
                    key: nginx_port
            - name: NGINX_SERVER_NAME
                valueFrom:
                  configMapKRef:
                    name: nginx-config
                    key: nginx_name
            例2：
            apiVersion: v1
            kind: Pod
            metadata:
                name: pod-cm-1
                namespace: default
                labels:
                    app: myapp
                    tier: frontend
                annotations:
                    ly.com/created-by: "cluster admin"
            spec:
                container:
                - name: myapp
                  image: ikubernetes/myapp:v1
                  ports:
                  - name: http
                    containerPort: 80
                  volumeMounts:
                  - name: nginxconf
                    mountPath: /etc/nginx/config.d/
                    readOnly: true
                volumes:
                - name: nginxconf
                    configMap:
                      name: nginx-config
            #Note: 如果是环镜变量这种方式，改了configmap后，pod中的env不会立即改变，但是volume的方式会立即改变
    secret:
        有三种：
            generic
                其它的就是generic
            tls
                向secret中放证书则用这个
            docker-registry
                pod中有个字段是imagePullSecret专门传递认证到私有库仓
        #kubeclt create secret generic mysql-root-password --from-literal=password=hello@ly.com

        apiVersion: v1
        kind: Pod
        metadata:
            name: pod-secret-1
            namespace: default
            labels:
                app: myapp
                tier: frontend
            annotations:
                ly.com/created-by: "cluster admin"
        spec:
            container:
            - name: myapp
              image: ikubernetes/myapp:v1
            ports:
            - name: http
              containerPort: 80
              env:
              - name: MYSQL_ROOT_PASSWORD
                valueFrom:
                  secrectKeyRef:
                    name: mysql-root-password
                    key: password
StatefulSet:
    PetSet-->StatefulSet
    1、稳定且惟一的网络标识
    2、稳定且持久的存储
    3、有序、平滑地部署和扩展
    4、有序、平滑地删除和终止
    5、有序的滚动更新
    三个组件：headless service、StatufulSet、volumeClaimTemplate(statufulSet每个pod必须要有自己独立的存储卷,每个都独自申请一个pvc)
    ***要解析Pod的名称，要在pod前加上无头服务的名称
        pod_name.service_name.ns_name.svc.cluster.local
        myapp-0.myapp.default.svc.cluster.local
    升级，扩容，缩容跟前面的controller一样
    *这种有状态的应用比较复杂，生产环境不太好用，关键有状态应用也不建义用在k8s上，网上有很多模板，经过大量学习后再偿试

认证、授权、准入控制(级联资源是否允许操作): 都是以插件方式
    认证：
        客户端-->API server
        user: 基于用户username,uid
        group: 基于用户组
        extra: 附加额外信息

        API是各种资源组，都是RestFul风格，所以以uri方式来认证
            Request path: 获取方式(用到的kubectl、kubeadm之类的都要转化成http格式)
                /apis/apps/v1/namespaces/default/deployments/myapp-deploy/
                k8s api监听在6443端口，这是https协议，所以要求双向证书认证，安装完了k8s后，要配置的admin.conf环境变量就是客户端的证书信息，所以kubectl没有再要求认证
                但如果用curl那就会要求证书认证，可以配置一个kubectl proxy监听在本地的某个端口8080
                #kubectl proxy --port=8080
                #curl http://localhost:8080/api/v1/namespace 返回所有namespace资源json格式
                #curl http://localhost:8080/apis/apps/v1/namespaces/kube-system 注意是复数，只有核心资源才可以用单数
            客户端用第一种请求会被k8s转化成第二种
            HTTP reques verb:
                get,post,put,delete
            API request verbs:
                get,list,create,update,patch,watch,proxy,redirect,delete,deletecollection
                    Resource:
                    Subresource:
                    Namespace:
                    API group:
            k8s维护两种用户：
                客户端向apiserver认证的userAccount
                pod向apiserver认证用的serviceAccount(serviceAccountName)

                ***pod跟apiServer通信是要专门用这个service转换的，service关联pod是要有一个中间层endpoints，这个可以手动创建关联service和pods

                ***默认kubernetes service为k8s组件pod提供apiserver访问，显然内部组件用的是pod网络，这个service解决的是网络问题
                [root@node1 ~]# kubectl describe svc kubernetes
                Name:              kubernetes
                Namespace:         default
                Labels:            component=apiserver
                                     provider=kubernetes
                Annotations:       <none>
                Selector:          <none>
                Type:              ClusterIP
                IP:                10.96.0.1
                Port:              https  443/TCP
                TargetPort:        6443/TCP
                Endpoints:         192.168.1.41:6443
                Session Affinity:  None
                Events:            <none>

                ***这个默认的serviceaccount就是为k8s 组件pod提供向apiserver认证的，权限很小，只用来获取k8s组件自身的信息，这个serviceaccount解决的是认证的问题
                [root@node1 ~]# kubectl get sa
                NAME      SECRETS   AGE
                default   1         11d
                [root@master ~]# kubectl describe serviceaccounts default
                Name:                default
                Namespace:           default
                Labels:              <none>
                Annotations:         <none>
                Image pull secrets:  <none>
                Mountable secrets:   default-token-xn62h
                Tokens:              default-token-xn62h
                Events:              <none>


                ***如果想让pod有很大的权限，可以自定义serviceaccount，当然需要用到rbac来定义授权，注意认证不代表授权，能认证进去但是干不了别的事
                [root@node1 ~]# kubectl create serviceaccount admin
                serviceaccount/admin created
                [root@node1 ~]# kubectl describe sa admin
                Name:                admin
                Namespace:           default
                Labels:              <none>
                Annotations:         <none>
                Image pull secrets:  <none> ###下载私有仓库时有两种:在pod中定义imagePullSecret,或者定义serviceAccountName中间也有image pull secrets字段，建议后者
                Mountable secrets:   admin-token-tn4qv
                Tokens:              admin-token-tn4qv
                Events:              <none>
                [root@node1 ~]# kubectl get secrets
                NAME                  TYPE                                  DATA      AGE
                admin-token-tn4qv     kubernetes.io/service-account-token   3         30s
                default-token-ghv7b   kubernetes.io/service-account-token   3         11d
                [root@node1 ~]#
                创建pod使用自定义account
                例1：
                apiVersion: v1
                kind: Pod
                metadata:
                    name: pod-sa-demo
                    namespace: default
                    labels:
                        app: myapp
                        tier: frontend
                    annotations:
                        ly.com/created-by: "cluster admin"
                spec:
                    container:
                    - name: myapp
                      image: ikubernetes/myapp:v1
                      ports:
                      - name: http
                        containerPort: 80
                    serviceAccountName: admin
                #kubectl apply -f pod-sa-demo
                #kubectl describe pod-sa-demo

            ***客户端认证要用到的KUBECONFIG文件，注意这一个配置文件可以定义多个集群多个用户的交叉访问
            [root@node1 ~]# kubectl config view
            apiVersion: v1
            clusters: ###集群列表
            - cluster:
                certificate-authority-data: REDACTED
                server: https://192.168.1.41:6443
              name: kubernetes
            contexts: ###上下文列表，保证可以控制多个集群，用哪个账号访问哪个集群
            - context:
                cluster: kubernetes
                user: kubernetes-admin
              name: kubernetes-admin@kubernetes
            current-context: kubernetes-admin@kubernetes ###当前用哪个集群上的哪个用户去访问
            kind: Config
            preferences: {}
            users: ###用户列表
            - name: kubernetes-admin
              user:
                client-certificate-data: REDACTED
                client-key-data: REDACTED

            自定义一个config
            #cd /etc/kubernetes/pki/ #用k8s的CA来签才有用
            #(umask 077; openssl genrsa -out ly.key 2048)
            #openssl req -new -key ly.key -out ly.csr -subj "/CN=ly" ###注意这个CN表示的是用户名(useradd添加即可)，很关键，将此用户名记录进crt后对认证才有效，用kubectl没有指用户名就是因为这个原因
            #openssl x509 -req -in ly.csr -CA ./ca.crt -CAkey ./ca.key  -CAcreateserial -out ly.crt -days 365

            #kubectl config set-credentials lystring --client-certificate=./ly.crt --client-key=./ly.key
            #kuebctl config set-context ly@kubernetes --cluster=kubernetes --user=ly
            #kubectl config use-context ly@kubernetes

            #kubectl config set-cluster mycluster --kubeconfig=/tmp/test.conf --server="https://192.168.1.41:6443" --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true
            #kubectl config view --kubeconfig=/tmp/test.conf

            ***经过上述一系列操作后再看这个KUBECONFIG，里面加入了ly这个用户的信息，并且当前context切换成了ly，所以kubectl get pod报了下面错误，因为没授权
            [root@master ~]# kubectl config view
            apiVersion: v1
            clusters:
            - cluster:
                certificate-authority-data: REDACTED
                server: https://192.168.2.11:6443
              name: kubernetes
            contexts:
            - context:
                cluster: kubernetes
                user: kubernetes-admin
              name: kubernetes-admin@kubernetes
            - context:
                cluster: kubernetes
                user: ly
              name: ly@kubernetes
            current-context: ly@kubernetes
            kind: Config
            preferences: {}
            users:
            - name: cluster-ly
              user:
                client-certificate: pki/ly.crt
                client-key: pki/ly.key
            - name: kubernetes-admin
              user:
                client-certificate-data: REDACTED
                client-key-data: REDACTED
            [root@master ~]#
            [root@master ~]# kubectl get pods --all-namespaces
            No resources found.
            Error from server (Forbidden): pods is forbidden: User "system:anonymous" cannot list pods at the cluster scope
            [root@master ~]#


    授权插件：Node, ABAC-->RBAC, Webhook(http的回调机制)
        RBAC: Role-based Access Control
        角色：Role
        许可：Permissions
            能扮演角色的有两个“人”、“Pod serviceAccountName”
            定义方式：
                1、namespace A 中：定义role-->rolebinding 授权给ly,则ly只能在namespace A 中用role定义的权限

                2、cluster A 中：定义clusterrole-->clusterrolebinding 授权给tom,则tom可以在所有名称空间中用clusterrole定义的权限

                3、namespace A、cluster A 中：定义clusterrole-->rolebinding 授权给jimmy,则jimmy只能在namespace A中用clusterrole定义的权限
                ***第三种的好处在于一般10个用户要定义10个独自名称空间role-->rolebinding,但用第三种只需定义一个clusterrole,10个用户再用rolebinding到clusterrole上就限定10个用户在自己名称空间用clusterrole定义的权限

            #kubectl create role pods-reader --verb=get,list,watch --resource=pods --dry-run -o yaml 输出框架，用这个定义即可
            apiVersion: rbac.authorization.k8s.io/v1
            kind: Role
            metadata:
                creationTimestamp: null
                name: pods-reader
            rules:
            - apiGroups:
                - ""
                resources:
                - pods
                verbs:
                - get
                - list
                - watch
            #kubectl create rolebinding ly-read-pods --role=pods-reader --user=ly --dry-run -o yaml
            apiVersion: rbac.authorization.k8s.io/v1
            kind: RoleBinding
            metadata:
                creationTimestamp: null
                name: ly-read-pods
            roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: Role
                name: pods-reader
            subjects:
            - apiGroup: rbac.authorization.k8s.io
                kind: User
                name: ly

            #kubectl create clusterrole cluster-reader --verb=get,list,watch --resource=pods --dry-run -o yaml
            apiVersion: rbac.authorization.k8s.io/v1
            kind: ClusterRole
            metadata:
                creationTimestamp: 2018-09-07T13:26:59Z
                name: cluster-reader
                resourceVersion: "208471"
                selfLink: /apis/rbac.authorization.k8s.io/v1/clusterroles/cluster-reader
                uid: b326d6de-b2a1-11e8-a462-000c29ec001b
            rules:
            - apiGroups:
                - ""
                resources:
                - pods
                verbs:
                - get
                - list
                - watch

            #kubectl create clusterrolebinding ly-read-all-pods --clusterrole=cluster-reader --user=ly --dry-run -o yaml
            apiVersion: rbac.authorization.k8s.io/v1beta1
            kind: ClusterRoleBinding
            metadata:
                creationTimestamp: null
                name: ly-read-all-pods
            roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-reader
            subjects:
            - apiGroup: rbac.authorization.k8s.io
                kind: User
                name: ly

dashboard: 用k8s的KUBECONFIG登陆出错不是因为非k8s CA签署出错，实际上这个地方即便是别的CA签署，点信任也是可以的，刚才用k8s的kubeconfig文件之所以不能通过认证是用户主体错了，我们用的k8s kubeconfig是kubernetes-admin用户，这里需要的是serviceAccount类型的用户
    1、部署：$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
    2、将service改为NodePort
        # kubectl patch svc kubernetes-dashboard -p '{"spec":{"type":"NodePort"}}' -n kube-system
    3、认证：有两种方式，一种是token，一种是username(password); kubeconfig也是要封装token或者username(password)才能通过认证
        认证时的账号必须为ServiceAccount: 被dashboard pod拿来由kubernetes进行认证
        token:
            (1) 创建ServiceAccount，根据其管理目标，使用rolebinding或clusterrolebinding绑定至合理role或clusterrole;
            # kubectl create serviceaccount dashboard-admin -n kube-system
            # kubectl create clusterrolebinding dashboard-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin
            
            (2) 获取到此ServiceAccount的secret，查看secret的详细信息，其中就有token
            ***注意当创建serviceaccount dashboard-admin时就有dashboard-admin-token-prfwf，拿着里面的token是可以进入dashboard，只不过没有做上面的授权是没有操作权限的
            #kubectl describe secrets -n kube-system dashboard-admin-token-prfwf 拿着这里面的token就可以进入dashboard并拥有上面授权的权限
        
        
        kubeconfig: 不用专门生成证书，直接把servcieAccount的token封装为kubeconfig文件，而后用这个文件去登陆
            (1) 创建ServiceAccount，根据其管理目标，使用rolebinding或clusterrolebinding绑定至合理role或clusterrole;
            # kubectl create serviceaccount def-ns-admin -n default
            # kubectl create rolebinding def-ns-admin --clusterrole=admin --serviceaccount=default:def-ns-admin
            
            (2) 创建KUBECONFIG，把serviceaccount的token注入进KUBECONFIG
            # kubectl config set-cluster kubernetes --certificate-authority=./ca.crt --server="https://192.168.1.41:6443" --embed-certs=true --kubeconfig=/root/def-ns-admin.conf
            
            ***注意创建的serviceaccount生成的secret中的token是用base64编码过的，要先解码
            # SERVICEACCOUNT_SECRET_NAME=`kubectl get secret -n default | awk '/^def-ns-admin/{print $1}'`
            # KUBE_TOKEN=$(kubectl get secret $SERVICEACCOUNT_SECRET_NAME -o jsonpath={.data.token} | base64 -d)
            # kubectl config set-credentials def-ns-admin --token=$KUBE_TOKEN --kubeconfig=/root/def-ns-admin.conf
            
            # kubectl config set-context def-ns-admin@kubernetes --cluster=kubernetes --user=def-ns-admin --kubeconfig=/root/def-ns-admin.conf
            # kubectl config use-context def-ns-admin@kubernetes --kubeconfig=/root/def-ns-admin.conf
            
        *****kubeconfig基于secret认证或者证书认证实践都失败，目前还不确定这种方式行不行

kubernetes网络通信：
    1、容器间通信：同一个pod内的多个容器间的通信，通过lo就可以实现
    2、pod通信：Pod IP <--> Pod IP 直接通信，不能通过地址转换
    3、pod与serivce通信：PodIP <--> ClusterIP
    4、service与集群外部客户端的通信
    #kubectl edit configmaps -n kube-system kube-proxy 改kube-proxy的mode模式，注意改成ipvs也不能替代iptables，只能负载均横
CNI：k8s不提供集群网络解决方案，但可以用此插件借用第三方网络架构，flannel,calico,canel......
    解决方案：
        虚拟网桥：叠加的方式，借用Vxlan隧道封装flannel.1接口，创建pod后就出现cin0接口
        多路复用：macVlan,一个网卡虚拟多个mac
        硬件交换：SR-IOV单根IO虚拟化
    加载第三方插件的方式很间单：
        /etc/cni/net.d/中定义即可
    flannel: 任何用kubelet守护进程的node都要部署flannel，因为kubelet要为pod分配网络
        运行机制有两种：
            1、系统级守护进程，用systemd管理
            2、用K8s部署成pod
                #kubectl get configmap kube-flannel-cfg -o json -n kube-system
                flannel配置参数：
                    network: flannel使用的CIDR格式的网络地址，用于为Pod配置网络功能
                        规模小一点：
                        10.244.0.0/16 ->
                            master: 10.244.0.0/24
                            node01: 10.244.1.0/24
                            ......
                            node255: 10.244.255.0/24
                        规模大一点：
                        10.0.0.0/8
                            10.0.0.0/24
                            .....
                            10.255.255.0/24
                    subnetLen: 把Network切分子网供各节点使用时，使用多长的掩码进行切分，默认为24位
                    subnetMin: 指定切分的第一个子网从什么开始，如10.244.10.0/24，前面的就不能用了
                    subnetMax: 指定切分的最后一个子网截止段，如10.244.100.0/24，后面的就不能用
        支持多种后端：
            Vxlan: 有很多开销"数据帧-->vxlan首部-->udp首部--ip首部-->以太网首部"
            host-gw: 借用路由表(所以大规模会很大),这个只能在同一网络当中，如果大规模时有路由就不适用了
            ***二者可以结合，如果在同一网络用host-gw，如果要跨网段则降级为vxlan
                Note: 直接用kubectl edit原文件不能生效，所以下载kube-flannel.yaml后修改
                #wget https://raw.githubusercontent.com/coreos/flannel/v0.10.0/Documentation/kube-flannel.yml
                    将cni-conf.json字段中的Backend Type下加一句"Directrouting": true
                    {
                        "Network": "10.244.0.0/16",
                        "Backend": {
                            "Type": "vxlan",
                            "Directrouting": true
                        }
                    }
            UDP: 性能最差，上面两种不支持才用



    calico: https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/flannel

        apiVersion: networking.k8s.io/v1
        kind: NetworkingPolicy
        metadata:
            name: deny-all-ingress
            namespace: dev
        spec:
            podSelector: {} ###为空则是整个名称空间
            policyTypes: ###不指定就默认Ingress/Egress都允许
                Ingress: ###指定Ingress，说明Ingress生效，为空则拒绝所有


        apiVersion: networking.k8s.io/v1
        kind: NetworkPolicy
        metadtaa:
            name: allow-myapp-ingress
        spec:
            podSelector:
                matchLabels:
                app: myapp
            ingress:
            - from:
                - ipBlock:
                    cidr:10.244.0.0/16
                except:
                - 10.244.1.2/32
            ports:
            - protocol: TCP
                port: 80

        #kubectl get netpol -n dev

Schedular:
    predicts:
        CheckNodeCondition:
        GeneralPredicates:
            HostName: 检查pod对象是否定义了pod.spec.hostname
            PodFitsHostPorts: pods.spec.containers.ports.hostPort
            MatchNodeSelector: pods.spec.nodeSelector
            PodFitsResources: 检查Pod的资源需求是否能被节点
        NoDiskConflict：检查Pod依赖的存储卷是否能满足需求
        PodToleratesNodeTaints(默认不启用): 检查Pod上的pod.spec.tolerations可容忍的污点是否完全包含节点上的污点
        PodToleratesNodeNoExecuteTaints(默认不启用): NoExecute是污点的一种属性
        CheckNodeLabelPresence(默认不启用): 检查nodelabel的存在与否
    priority:
        LeastRequested:
            (cpu((capacity-sum(requested))*10/capacity)+memory((capacity-sum(requested))*10/capacity))/2
        BalanceResourceAllocation:
            cpu和内存资源被占用率相近的胜出
        NodePreferAvoidPods:
            节点注解信息"scheduler.alpha.kubernetes.io/preferAvoidPods"
        TainToleration: 将Pod对象的spec.tolerations列表项与节点的taints列表项进行匹配度检查，匹配条目越多，得分越低
        SelectorSpreading:
    select:
        选择总得分最高的

        节点选择器：nodeSelector, nodeName(主机名)
            例1：
            apiVersion: v1
            kind: Pod
            metadata:
                name: pod-demo
                labels:
                    app: myapp
                    tier: frontend
            spec:
                container:
                - name: myapp
                  image: ikubernetes/myapp:v1
                nodeSelector:
                  disk: ssd ###如果节点没有这个标签pod就会pending,表示调度失败

        节点亲和调度： nodeAffinity
            例1：
            apiVersion: v1
            kind: Pod
            metadata:
                name: pod-node-affinity-demo
                labels:
                    app: myapp
                    tier: frontend
            spec:
                containers:
                - name: myapp
                  image: ikubernetes/myapp:v1
                affinity:
                  nodeAffinity:
                    requiredDuringSchedulingIgnoredDuringExecution:
                      nodeSelectorTerms:
                      - matchExpressions:
                        - key: zone
                            operator: In
                            values:
                        - foo
                        - bar
            例2：
            apiVersion: v1
            kind: Pod
            metadata:
                name: pod-node-affinity-demo-2
                labels:
                    app: myapp
                tier: frontend
            spec:
                containers:
                - name: myapp
                    image: ikubernetes/myapp:v1
                affinity:
                    nodeAffinity:
                    preferredDuringSchedulingIgnoredDuringExecution:
                    - preference:
                        matchExpressions:
                        - key: zone
                            operator: In
                            values:
                        - foo
                        - bar
                    weight: 60

        pod亲和调度： podAffinity
            例1：
            apiVersion: v1
            kind: Pod
            metadata:
                name: pod-affinity-1
                labels:
                    app: myapp
                    tier: frontend
            spec:
                containers:
                - name: myapp
                  image: ikubernetes/myapp:v1
            ---
            apiVersion: v1
            kind: Pod
            metadata:
                name: pod-affinity-2
                labels:
                    app: db
                    tier: db
            spec:
                containers:
                - name: busybox
                  image: busybox:latest
                imagePullPolicy: IfNotPresent
                command: ["sh","-c","sleep 3600"]
                affinity:
                    podAffinity: (podAtiAffinity则相反，不亲和某pod)
                        requiredDuringSchedulingIgnoredDuringExecution:
                    - labelSelector:
                            matchExpressions:
                        - {key: app, operator: In, values: ["myapp"]} (亲和于某一pod)
                    topologyKey: kubernetes.io/hostname(亲和在何处，k8s默认的同一主机名)
                    ###可以自己打标签kubectl label node node1 zone=foo;kubectl label node node2 zone=foo
                        topologyKey: zone
        污点调度：
            taint的effect定义对Pod排斥效果
                NoSchedule: 仅影响高度过程，对现存的Pod对象不产生影响
                NoExecute: 既影响调度过程，也影响现在的Pod对象；不容忍Pod对象将被驱逐
                PreferNoSchecule: 不容忍不让调度，但是没有地方去，也是可以的

            ###[root@node1 ~]# kubectl taint node node2 node-type=production:NoSchedule
            #节点上定义污点后只有在pod中定义可容忍此污点才能接受调度
            apiVersion: apps/v1
            kind: Deployment
            metadata:
                name: deployment-app
            spec:
                replicas: 3
                selector:
                matchLabels:
                    app: myapp
                    release: cannery
                template:
                metadata:
                    name: pod-app
                    namespace: default
                    labels:
                        app: myapp
                        release: cannery
                spec:
                    containers:
                    - name: container-app
                      image: ikubernetes/myapp:v1
                      imagePullPolicy: IfNotPresent
                      ports:
                      - name: web-port
                        containerPort: 80
                    tolerations:
                    - key: "node-type"
                      operator: "Equal"
                      value: "production"
                      effect: "NoSchedule"

容器的资源需求，资源限制
    requests: 需求，最低保障
    limits：限制，硬限制

    CPU：
        1颗逻辑cpu
            1=1000millicores
                500m=0.5CPU
    内存：
        Ei、Pi、Ti、Gi、Mi、Ki
            cpu.limits=500m
            cpu.requests=200m
    QoS: 三种属性，一般自动配置归类
        Guranteed: 同时设置cpu和内存的requests和limits
            cpu.limits=cpu.requests
            memory.limits=memory.request
        Burstable: 至少有一个容器设置cpu或内存资源的requests属性
        BestEffort: 没有任何一个容器设置

    apiVersion: v1
    kind: Pod
    metadata:
        name: pod-demo
        namespace: default
        labels:
            app: myapp
            tier: frontend
    spec:
        containers:
        - name: myapp
          image: ikubernetes/stress-ng
        command: ["/usr/bin/stress-ng","-m 1","-c 1","--metrics-brief"]
        ports:
        - name: http
          containerPort: 80
        - name: https
          containerPort: 443
        resources:
            requests:
                cpu: "200m"
                memory: "128Mi"
            limits:
                cpu: "500m"
                memory: "200Mi"


资源指标新一代架构：
    核心指标流水线(必须要提供,以前由heapster提供,现在是metric-server)：由kubelet、metrics-server以及由API server提供的api组成；cpu累积使用率、内存实时使用率，pod的资源占用率及容器的磁盘占用率；
    监控流水线(仅此于k8s项目的prometheus项目提供方案)：用于从系统收集各种指标数据并提供给终端用户、存储系统以及HPA，它们包含核心指标及许多非核心指标，非核心指标本身不能被k8s解析
    Note: metrics-server API有自己的跟k8s apiserver一样的资源组，为了两种API同时向外提供服务，需要一个kube-aggregator将二者聚合起来，当然还可以加入别的api

    ***以后测试时可以用Kubernetes主分支中的addons中的各个子项目(都通过了e2e测试)
    https://github.com/kubernetes/kubernetes/tree/master/cluster/addons/metrics-server e2e测试的官方版

    ***用最新版的metrics-server无论怎么调试都无法部署上，所以在k8s/metrics-server中降级使用v1.11.3才可以部署上
    ***部署上也无法获取数据，因为metrics-server默认用10255端中拉取数据，而10255是http非加密端口，所以kubeadm部署时自动就禁用了10255，而只保留https的10250端口，因此要做如下修改
    [root@node1 old]# vim metrics-server-deployment.yaml
    将这个：- --source=kubernetes.summary_api:''
        换成：- --source=kubernetes.summary_api:https://kubernetes.default?kubeletHttps=true&kubeletPort=10250&insecure=true

    ***还要修改以下配置
    [root@node1 metrics-server]# vim resource-reader.yaml
    在resources中加一行
    - nodes/stats

    ***最终可以使用kubectl top命令
    [root@node1 ~]# kubectl top nodes
    NAME      CPU(cores)   CPU%      MEMORY(bytes)   MEMORY%
    node1     523m         13%       1262Mi          67%
    node2     169m         4%        549Mi           29%
    node3     198m         4%        997Mi           52%
    [root@node1 ~]# kubectl top pods -n kube-system
    NAME                                     CPU(cores)   MEMORY(bytes)
    coredns-78fcdf6894-69vrm                 4m           21Mi
    coredns-78fcdf6894-dfbbk                 5m           18Mi
    etcd-node1                               44m          101Mi
    kube-apiserver-node1                     99m          536Mi
    kube-controller-manager-node1            174m         83Mi
    kube-flannel-ds-amd64-45fgk              6m           23Mi
    kube-flannel-ds-amd64-gbdlv              6m           35Mi
    kube-flannel-ds-amd64-pz2j7              4m           20Mi
    kube-flannel-ds-fpj9f                    6m           19Mi
    kube-flannel-ds-phrfk                    6m           20Mi
    kube-flannel-ds-tf7jp                    3m           24Mi
    kube-proxy-6pmq8                         14m          27Mi
    kube-proxy-fcwc6                         7m           32Mi
    kube-proxy-t28wn                         14m          24Mi
    kube-scheduler-node1                     54m          30Mi
    metrics-server-v0.2.1-7778c67844-549xz   4m           26Mi
    [root@node1 ~]#


hpa: 自动扩展功能，hpa有两个版本发v1和v2版
    v1版基于核心指标
    v1版例1：
    #kubectl run myapp --image=ikubernetes/myapp:v1 --replicas=1 --requests='cpu=50m,memory=256Mi' --labels='app=myapp' --expose --port=80
    #kubectl patch svc myapp -p '{"spec":{"type":"NodePort"}}'
    #kubectl autoscale deployment myapp --min=1 --max=8 --cpu-percent=60
    #ab -c 1000 -n 100000 http://192.168.58.41:31047/index.html
    现象：可以看到pod从一个自动扩展到了3个

    v2版可以基于扩展指标
    v2版例1：
    apiVersion: autoscaling/v2beta1
    kind: HorizontalPodAutoscaler
    metadata:
        name: myapp-hpa-v2
    spec:
        scaleTargetRef:
            apiVersion: apps/v1
        kind: Deployment
        name: myapp
        minReplicas: 1
        maxReplicas: 10
        metrics:
        - type: Resource
            resource:
            name: cpu
            targetAverageUtilization: 55
        - type: Resource
            resource:
            name: memory ###v1版只能用cpu,v2可以用内存
            targetAverageUtilization: 50

    #ab -c 1000 -n 100000 http://192.168.58.41:31047/index.html
    现象：可以看到pod从一个自动扩展到了4个


Helm:
    核心术语：
        chart：一个helm程序包；
        Repository：Charts仓库，https/http服务器；
        Release： 特定的Chart部署于目标集群上的一个实例；

        chart-->Config-->Release

    程序架构：
        helm：客户端，管理本地的Chart仓库，管理Chart, 与Tiller服务器交互，发送Chart,实例安装、查询、卸载等操作
        Tiller：服务端，接收helm发来的Chart与Config，合并生成release
            https://github.com/helm/helm/blob/master/docs/rbac.md 
            RBAC配置文件
            apiVersion: v1
            kind: ServiceAccount
            metadata:
                name: tiller
                namespace: kube-system
            ---
            apiVersion: rbac.authorization.k8s.io/v1beta1
            kind: ClusterRoleBinding
            metadata:
                name: tiller
            roleRef:
                apiGroup: rbac.authorization.k8s.io
                kind: ClusterRole
                name: cluster-admin
            subjects:
                - kind: ServiceAccount
                name: tiller
                namespace: kube-system
            [root@node1 linux-amd64]# kubectl get serviceaccounts -n kube-system | grep tiller
            tiller                               1         45s
            [root@node1 linux-amd64]#
        ***有了pod rbac权限然后初始化
            helm init --service-account=tiller

            *目前官方的chart库列表
            https://hub.kubeapps.com/

            helm常用命令：
                release管理：
                    install
                    delete
                    upgrade/rollback
                    list
                    history：release的历史信息
                    status: 获取release状态信息
                chart管理
                    create
                    fetch
                    get
                    inspect
                    package
                    verify
        https://www.helm.sh/
        ***通过官方文档更好的使用helm和开发自己的chart

k8s下载可以直接下载官方打包文件:
    最新的版本一般直接在kubernets.io
    https://kubernetes.io/docs/setup/release/
    
    以前的版本都托管到github上了，选择CHANGELOG-1.10.md
    https://github.com/kubernetes/kubernetes

    或者直接到仓库下载
    https://storage.googleapis.com/kubernetes-release/release/v1.11.1/kubernetes-server-linux-arm64.tar.gz



































