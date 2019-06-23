run pod with ceph rbd volume
------------------------------

本示例将分别创建nginx和mysql，通过flexVolume来使用ceph rbd块设备，使其作为volume挂载到容器中。

# 示例1: nginx
```
$ rbd create -p hyper --size 1G frakti-rbd-nginx
$ kubectl create -f yaml pod-nginx-rbd.yaml

$ kubectl get pods nginx-rbd-pod
$ nginx-rbd-pod   1/1       Running             0          31m

$ kubectl exec -it nginx-rbd-pod df  | grep sda
/dev/sda          999320     1288    929220   1% /var/lib/nginx
```

# 示例2: mysql
```
$ rbd create -p hyper --size 1G frakti-rbd-mysql
$ kubectl create -f yaml pod-mysql-rbd.yaml

$ kubectl get pods mysql-rbd-pod
NAME            READY     STATUS    RESTARTS   AGE
mysql-rbd-pod   1/1       Running   0          17m

$ kubectl exec -it mysql-rbd-pod sh
# df -hT
Filesystem     Type      Size  Used Avail Use% Mounted on
share_dir      9p         77G   49G   25G  67% /
devtmpfs       devtmpfs   58M     0   58M   0% /dev
tmpfs          tmpfs      60M     0   60M   0% /dev/shm
rootfs         rootfs     58M   13M   45M  22% /etc/hostname
/dev/sda       ext4      976M  1.3M  908M   1% /var/lib/mysql
```