什么是tmpfs?
tmpfs是Linux/Unix系统上的一种基于内存的文件系统。tmpfs可以使用您的内存或swap分区来存储文件。由此可见，temfs主要存储暂存的文件。

linux内核中的VM子系统负责在后台管理虚拟内存资源Virtual Memory，即RAM和swap资源，透明地将RAM页移动到交换分区或从交换分区到RAM页，tmpfs文件系统需要VM子系统的页面来存储文件。 

VM由RM+Swap两部分组成，因此tmpfs最大的存储空间可达（The size of RM + The size of Swap）。 但是对于tmpfs本身而言，它并不知道自己使用的空间是RM还是Swap，这一切都是由内核的vm子系统管理的。tmpfs自己并不知道这些页面是在交换分区还是在RAM中；做这种决定是VM子系统的工作。tmpfs文件系统所知道的就是它正在使用某种形式的虚拟内存。

tmpfs默认的大小是RM的一半，假如你的物理内存是1024M，那么tmpfs默认的大小就是512M

一般情况下，是配置的小于物理内存大小的。

tmpfs配置的大小并不会真正的占用这块内存，如果/dev/shm/下没有任何文件，它占用的内存实际上就是0字节；如果它最大为1G，里头放有100M文件，那剩余的900M仍然可为其它应用程序所使用，但它所占用的100M内存，是不会被系统回收重新划分的。

tmpfs基于内存，因而速度是相当的，另外tmpfs使用的VM资源是动态的，当删除tmpfs中文件，tmpfs 文件系统驱动程序会动态地减小文件系统并释放 VM 资源，当然在其中创建文件时也会动态的分配VM资源。另外，tmpfs不具备持久性，重启后数据不保留，原因很明显，它是基于内存的。

编译内核时，启用“Virtual memory file system support”就可以使用tmpfs,linux kernel从2.4以后都开始支持tmpfs。目前主流的linux系统默认已启用tmpfs，如Redhat。



tmpfs应用
tmpfs是基于内存的，速度是不用说的，硬盘和它没法比。

Oracle 中的Automatic Memory Management特性就使用了/dev/shm。

另外如果在网站运维中好好利用tmpfs，将有意想不到的收获。

我们先在/dev/shm建一个tmp，并与/tmp绑定。

[root@GoGo shm]# mkdir /dev/shm/tmp

[root@GoGo shm]# chmod 1777 /dev/shm/tmp  //注意一下权限

[root@GoGo shm]# mount –bind /dev/shm/tmp /tmp

[root@GoGo tmp]# ls -ld /tmp

drwxrwxrwt 2 root root 40 Aug 29 23:58 /tmp

当然您也可以不绑定，直接mount在现有的安装点上使用tmpfs,如：

#umount   /tmp

#mount  tmpfs  /tmp   -t tmpfs   -o size=512M

 
也很方便吧，不需要使用mkfs等命令创建。

 
以下/tmp使用tmpfs文件系统。

(1)将squid的缓存目录cache_dir放到/tmp下

cache_dir ufs /tmp 256 16 256

重启一下squid服务，这样缓存目录都放在了tmpfs文件中了，速度不用说吧。

(2)将php的session文件放在/tmp下

通过phpinfo测试文件查看你的php session存储位置，如果不在/tmp下，修改php.ini文件，修改如下：

session.save_path = “/tmp”

当然如果您的网站访问量比较大，可/tmp下设置分层目录存储session,语法如下：

session.save_path=”N;/save_path”，N 为分级的级数，save_path 为开始目录。

(3)将服务的socket文件放在/tmp下

如nginx.socket和mysql.sock



Tmpfs大小调整
有时候，当应用程序使用到Tmpfs时，而在部署的时候如果没有对应用程序占用的内存做足够的评估时，就有可能把Tmpfs用满，这个时候就需要调整Tmpfs的大小了，当然，调整的大小不能大于你机器内存大小，否则，你只能换机器了，又或是优化你的应用程序。

可以看到tmpfs的大小为3G，比如我们想调整到5G。

1） umount tmpfs
在这里要注意，由于umount 会把卸载tmpfs 文件系统，意味着你的应用程序使用的共享内存将会被删除，如果数据较重要，在umount 前记得备份。

root@TENCENT64 /dev]# umount /dev/shmumount: /dev/shm: device is busy.
(In some cases useful info about processes that use
the device is found by lsof(8) or fuser(1))</P>
这里可以看到，umount失败了，原因比较明显，/dev/shm被其它进程使用了，所以在umount前需要把使用/dev/shm的所有进程都停掉。

如错误说明，可以使用fuser –km /dev/shm命令把加载的进程都kill掉，再进行umount

fuser –km /dev/shm
umount /dev/shm</P>
2） 调整tmpfs的大小
通过修改/etc/fstab文件来修改/dev/shm的容量，在文件中修改tmpfs行，如下：

tmpfs /dev/shm tmpfs defaults,size=600M 0 0

tmpfs /tmp tmpfs defaults,size=25M 0 0

修改后，重新mount tmpfs即可。



调整tmpfs大小大致有以下三种方法：

1.直接挂载到需要的目录--比如系统的临时目录-可以根据实际需要挂载某个程序的临时文件的目录

[root@bys3 ~]# mount -t tmpfs -o size=20m tmpfs /tmp

[root@bys3 ~]# df -h

Filesystem Size Used Avail Use% Mounted on

/dev/sda2 16G 10G 4.7G 69% /

/dev/sda1 99M 21M 74M 22% /boot

tmpfs 502M 0 502M 0% /dev/shm

tmpfs 20M 0 20M 0% /tmp

由于没有挂载之前/tmp目录下的文件也许正在被使用，因此挂载之后系统也许有的程序不能正常工作。可以写入/etc/fstab，这样重启后也有效。


2./etc/fstab文件来修改/dev/shm的容量(增加size=100M选项即可),修改后，重新挂载即可：

[root@bys3 ~]# cat /etc/fstab 

LABEL=/ / ext3 defaults 1 1

LABEL=/boot /boot ext3 defaults 1 2

tmpfs /dev/shm tmpfs defaults,size=600M 0 0

tmpfs /tmp tmpfs defaults,size=25M 0 0

devpts /dev/pts devpts gid=5,mode=620 0 0

sysfs /sys sysfs defaults 0 0

proc /proc proc defaults 0 0

LABEL=SWAP-sda3 swap swap defaults 0 0

/dev/sda5 swap swap defaults 0 0

[root@bys3 ~]# mount -a --测试/etc/fstab无错误，重启OS系统

[oracle@bys3 ~]$ df -h  重启后的信息如下，tmpfs文件系统的对应条目已经改变为配置的

Filesystem Size Used Avail Use% Mounted on

/dev/sda2 16G 10G 4.7G 69% /

/dev/sda1 99M 21M 74M 22% /boot

tmpfs 600M 0 600M 0% /dev/shm

tmpfs 25M 0 25M 0% /tmp


3./dev/shm建一个tmp目前，并与/tmp绑定。 --这方法有点烦琐，不如方法1方便快捷。

[root@bys3 ~]# mkdir /dev/shm/tmp

[root@bys3 ~]# chmod 1777 /dev/shm/tmp

[root@bys3 ~]# mount --bind /dev/shm/tmp /tmp -注意mount --bind 这里bind前是两个-

[root@bys3 ~]# ls -ld /tmp

drwxrwxrwt 2 root root 40 Dec 8 12:15 /tmp

[root@bys3 ~]# df -h

Filesystem Size Used Avail Use% Mounted on

/dev/sda2 16G 10G 4.7G 69% /

/dev/sda1 99M 21M 74M 22% /boot

tmpfs 600M 0 600M 0% /dev/shm

tmpfs 600M 0 600M 0% /tmp ----可以看到/tmp使用到了 /dev/shm的空间。