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















