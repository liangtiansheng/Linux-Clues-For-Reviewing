***注意这里的坑，systemd用到的文件要手动创建,mkdir /var/lib/etcd, touch /etc/etcd/etcd.conf
***注意这里的systemd没有指明用户，那就是root，所以手动创建的目录属主属组也是root，要对应
***三个etcd出现有某个etcd起不来，修改文件后重启一直说member已加入，只有先删掉这个etcd，再加进来，加进来时千万注意，修改systemd文件中的new改成existing，删除/var/lib/etcd/member，再重启，否则这个服务怎么都起不来的
    # etcdctl --ca-file=/etc/etcd/ssl/ca.pem --cert-file=/etc/etcd/ssl/etcd.pem --key-file=/etc/etcd/ssl/etcd-key.pem --endpoints=https://192.168.2.11:2379,https://192.168.2.22:2379,https://192.168.2.33:2379 member remove 830e0a58a878a0ce
    # etcdctl --ca-file=/etc/etcd/ssl/ca.pem --cert-file=/etc/etcd/ssl/etcd.pem --key-file=/etc/etcd/ssl/etcd-key.pem --endpoints=https://192.168.2.11:2379,https://192.168.2.22:2379,https://192.168.2.33:2379 member add etcd03 https://192.168.2.33:2380



***k8s中关于systemd和docker用到的cgroup不一致的情况，可以手动更改
Sep 23 16:34:58 master kubelet: E0923 16:34:58.814833   11405 summary.go:102] Failed to get system container stats for "/system.slice/kubelet.service": failed to get cgroup stats for "/system.slice/kubelet.service": failed to get container info for "/system.slice/kubelet.service": unknown container "/system.slice/kubelet.service"
安装完成后就报这种错误
解决办法：在/etc/sysconfig/kubelet中传递如下参数：
    KUBELET_EXTRA_ARGS="--runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice"



***k8s用ceph做后端的dynamic动态存储时出现如下问题：
    root@master1:~# kubectl describe pvc
    Name:          ceph-claim
    Namespace:     default
    StorageClass:  dynamic
    Status:        Pending
    Volume:        
    Labels:        <none>
    Annotations:   volume.beta.kubernetes.io/storage-provisioner=kubernetes.io/rbd
    Finalizers:    [kubernetes.io/pvc-protection]
    Capacity:      
    Access Modes:  
    Events:
    Type     Reason              Age                From                         Message
    ----     ------              ----               ----                         -------
    Warning  ProvisioningFailed  4m (x261 over 1h)  persistentvolume-controller  Failed to provision volume with StorageClass "dynamic": failed to create rbd image: executable file not found in $PATH, command output:
    root@master1:~# 
    root@master1:~# kubectl logs -n kube-system kube-controller-manager-master3 | tail -10
    I1127 03:32:29.970182       1 event.go:221] Event(v1.ObjectReference{Kind:"PersistentVolumeClaim", Namespace:"default", Name:"ceph-claim", UID:"7083f3aa-f1e5-11e8-a51b-00073e908804", APIVersion:"v1", ResourceVersion:"102512", FieldPath:""}): type: 'Warning' reason: 'ProvisioningFailed' Failed to provision volume with StorageClass "dynamic": failed to create rbd image: executable file not found in $PATH, command output: 
    W1127 03:32:44.970517       1 rbd_util.go:596] failed to create rbd image, output 
    E1127 03:32:44.970562       1 rbd.go:672] rbd: create volume failed, err: failed to create rbd image: executable file not found in $PATH, command output: 
    I1127 03:32:44.970669       1 event.go:221] Event(v1.ObjectReference{Kind:"PersistentVolumeClaim", Namespace:"default", Name:"ceph-claim", UID:"7083f3aa-f1e5-11e8-a51b-00073e908804", APIVersion:"v1", ResourceVersion:"102512", FieldPath:""}): type: 'Warning' reason: 'ProvisioningFailed' Failed to provision volume with StorageClass "dynamic": failed to create rbd image: executable file not found in $PATH, command output: 
    W1127 03:32:59.970740       1 rbd_util.go:596] failed to create rbd image, output 
    E1127 03:32:59.970784       1 rbd.go:672] rbd: create volume failed, err: failed to create rbd image: executable file not found in $PATH, command output: 
    I1127 03:32:59.970913       1 event.go:221] Event(v1.ObjectReference{Kind:"PersistentVolumeClaim", Namespace:"default", Name:"ceph-claim", UID:"7083f3aa-f1e5-11e8-a51b-00073e908804", APIVersion:"v1", ResourceVersion:"102512", FieldPath:""}): type: 'Warning' reason: 'ProvisioningFailed' Failed to provision volume with StorageClass "dynamic": failed to create rbd image: executable file not found in $PATH, command output: 
    W1127 03:33:14.970845       1 rbd_util.go:596] failed to create rbd image, output 
    E1127 03:33:14.970891       1 rbd.go:672] rbd: create volume failed, err: failed to create rbd image: executable file not found in $PATH, command output: 
    I1127 03:33:14.971008       1 event.go:221] Event(v1.ObjectReference{Kind:"PersistentVolumeClaim", Namespace:"default", Name:"ceph-claim", UID:"7083f3aa-f1e5-11e8-a51b-00073e908804", APIVersion:"v1", ResourceVersion:"102512", FieldPath:""}): type: 'Warning' reason: 'ProvisioningFailed' Failed to provision volume with StorageClass "dynamic": failed to create rbd image: executable file not found in $PATH, command output: 
    root@master1:~#
    解释：在提供ceph动态pv存储时需要kube-controller-manager去调用rbd这样的命令做image映射，很显然kubeadm创建的集群组件都运行在pod当中，而kube-controller-manager并没有集成ceph rbd环境，所以大
    致有两种解决方案：
    1、临时可以停掉kube-controller-manager，手动启动kube-controller-manager进程，运行在物理机上，物理机上装有ceph环境(换句话来说如果k8s是纯手动安装的，以systemd管理的话，那kube-controller-manager可以直接调用rbd，还未测试)
    2、可以用https://github.com/kubernetes-incubator/external-storage/tree/master/ceph/rbd来提供外挂环境
    实现：基于arm64v8环境下搭建编译环境
    # mkdir /opt/go
    # export GOPATH=/opt/go/
    # mkdir -pv /opt/go/src/github.com/kubernetes-incubator(众所周知，go语言源码中有定义好的相对路径，相关目录要创建对才行，错误中都有提示)
    # cd /opt/go/src/github.com/kubernetes-incubator/
    # git clone https://github.com/kubernetes-incubator/external-storage.git
    # cd external-storage/ceph/rbd/
    # make
    # make push(这一步可以创建镜像，但是源码中就会上传至quay.io/external_storage/rbd-provisioner:latest，没有权限，可以上传到自己的仓库)

***以下根据操作思路来进行，具体问题具体分析，以下文件都是成功测试后复制下来的
    1、修改external-storage中的deploy文件
        root@master1:~/dynamic_pvc/official_env# cat clusterrolebinding.yaml 
        kind: ClusterRoleBinding
        apiVersion: rbac.authorization.k8s.io/v1
        metadata:
        name: rbd-provisioner
        subjects:
        - kind: ServiceAccount
            name: rbd-provisioner
            namespace: default
        roleRef:
          kind: ClusterRole
          name: rbd-provisioner
          apiGroup: rbac.authorization.k8s.io

        root@master1:~/dynamic_pvc/official_env# cat clusterrole.yaml 
        kind: ClusterRole
        apiVersion: rbac.authorization.k8s.io/v1
        metadata:
          name: rbd-provisioner
        rules:
        - apiGroups: [""]
          resources: ["persistentvolumes"]
          verbs: ["get", "list", "watch", "create", "delete"]
        - apiGroups: [""]
          resources: ["persistentvolumeclaims"]
          verbs: ["get", "list", "watch", "update"]
        - apiGroups: ["storage.k8s.io"]
          resources: ["storageclasses"]
          verbs: ["get", "list", "watch"]
        - apiGroups: [""]
          resources: ["events"]
          verbs: ["create", "update", "patch"]
        - apiGroups: [""]
          resources: ["services"]
          resourceNames: ["kube-dns","coredns"]
          verbs: ["list", "get"]
        - apiGroups: [""]
          resources: ["endpoints"]
          verbs: ["get", "list", "watch", "create", "update", "patch"]
        root@master1:~/dynamic_pvc/official_env# 
        root@master1:~/dynamic_pvc/official_env# cat deployment.yaml 
        apiVersion: extensions/v1beta1
        kind: Deployment
        metadata:
        name: rbd-provisioner
        spec:
        replicas: 1
        strategy:
            type: Recreate
        template:
            metadata:
            labels:
                app: rbd-provisioner
            spec:
            containers:
            - name: rbd-provisioner
                image: "quay.io/external_storage/rbd-provisioner"
                resources:
                limits: ###关于这个资源定义问题，下面会着重强调
                    memory: "800Mi"
                imagePullPolicy: IfNotPresent
                env:
                - name: PROVISIONER_NAME
                value: ceph.com/rbd
            serviceAccount: rbd-provisioner
        root@master1:~/dynamic_pvc/official_env#
        root@master1:~/dynamic_pvc/official_env# cat rolebinding.yaml 
        apiVersion: rbac.authorization.k8s.io/v1
        kind: RoleBinding
        metadata:
          name: rbd-provisioner
        roleRef:
          apiGroup: rbac.authorization.k8s.io
          kind: Role
          name: rbd-provisioner
        subjects:
        - kind: ServiceAccount
          name: rbd-provisioner
          namespace: default
        root@master1:~/dynamic_pvc/official_env# 
        root@master1:~/dynamic_pvc/official_env# cat role.yaml 
        apiVersion: rbac.authorization.k8s.io/v1
        kind: Role
        metadata:
          name: rbd-provisioner
        rules:
        - apiGroups: [""]
          resources: ["secrets"]
          verbs: ["get"]
        - apiGroups: [""]
          resources: ["endpoints"]
          verbs: ["get", "list", "watch", "create", "update", "patch"]
        root@master1:~/dynamic_pvc/official_env# cat serviceaccount.yaml 
        apiVersion: v1
        kind: ServiceAccount
        metadata:
          name: rbd-provisioner
        root@master1:~/dynamic_pvc/official_env# 
    2、自定义几个文件
        root@master1:~/dynamic_pvc# cat ceph-storageclass.yaml 
        apiVersion: storage.k8s.io/v1beta1
        kind: StorageClass
        metadata:
          name: dynamic
          annotations:
            storageclass.beta.kubernetes.io/is-default-class: "true"
        #provisioner: kubernetes.io/rbd
        provisioner: ceph.com/rbd
        parameters:
          monitors: 172.16.4.61:6789,172.16.4.62:6789,172.16.4.63:6789 ##ceph的monitor用逗号隔开
          adminId: admin ##可以在存储池创建镜像的客户端ID，默认情况下是admin
          adminSecretName: ceph-secret ##admin客户端的密钥文件，密钥文件必须要有type kubernetes.io/rbd，这里用的是外挂，所以改成外挂对应的type: ceph.com/rbd
          adminSecretNamespace: default ##admin客户端的名称空间，默认是default
          pool: kube ##ceph的rbd pool，默认是rbd，但是不建议
          userId: kube ##用来映射ceph rbd镜像的客户端ID，默认情况下也是admin
          userSecretName: ceph-user-secret ##映射ceph rbd镜像客户端的密钥文件，必须跟pvc处于同一名称空间，必须要有，除非设成新项目的默认值，可参考https://docs.openshift.com/container-platform/3.5/install_config/storage_examples/ceph_rbd_dynamic_example.html
        root@master1:~/dynamic_pvc# 

        $ ceph osd pool create kube 1024
        $ ceph auth get-or-create client.kube mon 'allow r' osd 'allow class-read object_prefix rbd_children, allow rwx pool=kube' -o ceph.client.kube.keyring
        root@master1:~/dynamic_pvc# cat ceph_secret.yaml 
        apiVersion: v1
        kind: Secret
        metadata:
          name: ceph-secret
        data:
          key: QVFEeWR2ZGJ1ZjdpRkJBQTB2WVVGSmNxOTRWbE1tTXMzTHQyY2c9PQ==
        type: ceph.com/rbd
        root@master1:~/dynamic_pvc# 
        ##在mon节点上用ceph auth get-key client.admin | base64 获得key
        ##ceph提供动态存储时要用到ceph-secret

        root@master1:~/dynamic_pvc# cat ceph_user_secret.yaml 
        apiVersion: v1
        kind: Secret
        metadata:
          name: ceph-user-secret
        data:
          key: QVFCMW1meGJtbHVOSUJBQUU0Uk92czNYU2kzWUJvR1BIZmRoMkE9PQ==
        type: ceph.com/rbd
        root@master1:~/dynamic_pvc# 
        ##映射ceph rbd镜像客户端的密钥

        root@master1:~/dynamic_pvc# cat ceph-claim.yaml 
        kind: PersistentVolumeClaim
        apiVersion: v1
        metadata:
          name: ceph-claim
        spec:
        accessModes:
        - ReadWriteOnce
        resources:
          requests:
            storage: 2Gi
        root@master1:~/dynamic_pvc# 
        ##创建pvc事例
    问题1、出现rbd-provisioner寻找admin的secret错误，因为两个文件直接下载下来是在不同名称空间内的，所以要调整在一个名称空间
    问题2、这次实验修改了Dockerfile中的基础镜像，分别以centos7和ubuntu:16.04进行编译，都可以成功，上传时报错，源码是要直接上传至quay.io上去，没权限，不要紧，上传到自己的dockerhub
    问是2、最棘手的报错是ImportError: librados.so.2: cannot map zero-fill pages，进入rbd容器后执行ceph命令都是这种错，原因最终查得是pod的内存分配有问题，默认的是128M，改成limits 800M后，成功实现
















