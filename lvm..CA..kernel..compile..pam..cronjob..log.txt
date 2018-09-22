磁盘管理
mkfs: make file system
	-t FSTYPE 
	
mkfs -t ext2 = mkfs.ext2 两种写法一样
mkfs -t ext3 = mkfs.ext3

[root@lcfyl ~]# mkfs -t ext2 /dev/sdb5
mke2fs 1.41.12 (17-May-2010)
文件系统标签=
操作系统:Linux
块大小=4096 (log=2)
分块大小=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
131648 inodes, 526120 blocks
26306 blocks (5.00%) reserved for the super user
第一个数据块=0
Maximum filesystem blocks=541065216
17 block groups
32768 blocks per group, 32768 fragments per group
7744 inodes per group
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912

正在写入inode表: 完成                            
Writing superblocks and filesystem accounting information: 完成

This filesystem will be automatically checked every 22 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.

[root@lcfyl ~]# mkfs.vfat /dev/sdb6
mkfs.vfat 3.0.9 (31 Jan 2010)
***这个就是fat32的文件系统格式，放在windows上可以直接识别的


专门管理ext系列文件：
mke2fs
	-j: 创建ext3类型文件系统
		[root@lcfyl ~]# mke2fs -j /dev/sdb5
		mke2fs 1.41.12 (17-May-2010)
		文件系统标签=
		操作系统:Linux
		块大小=4096 (log=2)
		分块大小=4096 (log=2)
		Stride=0 blocks, Stripe width=0 blocks
		131648 inodes, 526120 blocks
		26306 blocks (5.00%) reserved for the super user
		第一个数据块=0
		Maximum filesystem blocks=541065216
		17 block groups
		32768 blocks per group, 32768 fragments per group
		7744 inodes per group
		Superblock backups stored on blocks: 
			32768, 98304, 163840, 229376, 294912

		正在写入inode表: 完成                            
		Creating journal (16384 blocks): 完成
		Writing superblocks and filesystem accounting information: 完成

		This filesystem will be automatically checked every 22 mounts or
		180 days, whichever comes first.  Use tune2fs -c or -i to override.

	-b BLOCK_SIZE: 指定块大小，默认为4096；可用取值为1024、2048或4096；
		[root@lcfyl ~]# mke2fs -b 2048 /dev/sdb5
		mke2fs 1.41.12 (17-May-2010)
		文件系统标签=
		操作系统:Linux
		块大小=2048 (log=1)
		分块大小=2048 (log=1)

	-L LABEL：指定分区卷标；
		[root@lcfyl ~]# mke2fs -L MYDATA /dev/sdb5
		mke2fs 1.41.12 (17-May-2010)
		文件系统标签=MYDATA
		操作系统:Linux
		块大小=4096 (log=2)
		分块大小=4096 (log=2)

	-m #: 指定预留给超级用户的块数百分比
		[root@lcfyl ~]# mke2fs -m 3 /dev/sdb5
		mke2fs 1.41.12 (17-May-2010)
		文件系统标签=
		操作系统:Linux
		块大小=4096 (log=2)
		分块大小=4096 (log=2)
		Stride=0 blocks, Stripe width=0 blocks
		131648 inodes, 526120 blocks
		15783 blocks (3.00%) reserved for the super user

	-i #: 用于指定为多少字节的空间创建一个inode，默认为8192；这里给出的数值应该为块大小的2^n倍；
		[root@lcfyl ~]# mke2fs -i 4096 /dev/sdb5
		mke2fs 1.41.12 (17-May-2010)
		文件系统标签=
		操作系统:Linux
		块大小=4096 (log=2)
		分块大小=4096 (log=2)
		Stride=0 blocks, Stripe width=0 blocks
		526320 inodes, 526120 blocks
		26306 blocks (5.00%) reserved for the super user
		第一个数据块=0
		Maximum filesystem blocks=540801024
		17 block groups
		32752 blocks per group, 32752 fragments per group
		30960 inodes per group

	-N #: 指定inode个数；
	-F: 强制创建文件系统；
	-E: 用户指定额外文件系统属性; 

blkid: 查询或查看磁盘设备的相关属性
	UUID：磁盘太多，唯一标识
	TYPE
	LABEL
	
e2label: 用于查看或定义卷标
	e2label 设备文件 卷标: 设定卷标
		[root@lcfyl ~]# e2label /dev/sdb5

		[root@lcfyl ~]# e2label /dev/sdb5 HELLO
		[root@lcfyl ~]# e2label /dev/sdb5
		HELLO

	
tune2fs: 调整文件系统的相关属性（重新格式化会损伤以前文件，这个命令可以无损操作）
	-j: 不损害原有数据，将ext2升级为ext3；
		[root@lcfyl ~]# blkid /dev/sdb5
		/dev/sdb5: UUID="db2ecb12-2a03-433d-bc2d-d5939862b88c" TYPE="ext2" LABEL="HELLO" 
		[root@lcfyl ~]# tune2fs -j /dev/sdb5 
		tune2fs 1.41.12 (17-May-2010)
		Creating journal inode: 完成
		This filesystem will be automatically checked every 26 mounts or
		180 days, whichever comes first.  Use tune2fs -c or -i to override.
		[root@lcfyl ~]# blkid /dev/sdb5
		/dev/sdb5: LABEL="HELLO" UUID="db2ecb12-2a03-433d-bc2d-d5939862b88c" SEC_TYPE="ext2" TYPE="ext3" 

	-L LABEL: 设定或修改卷标; 
		[root@lcfyl ~]# blkid /dev/sdb5
		/dev/sdb5: LABEL="HELLO" UUID="db2ecb12-2a03-433d-bc2d-d5939862b88c" SEC_TYPE="ext2" TYPE="ext3" 
		[root@lcfyl ~]# tune2fs -L MYDATA /dev/sdb5
		tune2fs 1.41.12 (17-May-2010)
		[root@lcfyl ~]# blkid /dev/sdb5 
		/dev/sdb5: LABEL="MYDATA" UUID="db2ecb12-2a03-433d-bc2d-d5939862b88c" SEC_TYPE="ext2" TYPE="ext3" 
		[root@lcfyl ~]# 

	-m #: 调整预留百分比；
	-r #: 指定预留块数；
	-o: 设定默认挂载选项；
		acl
	-c #：指定挂载次数达到#次之后进行自检，0或-1表关闭此功能；
	-i #: 每挂载使用多少天后进行自检；0或-1表示关闭此功能；
	-l: 显示超级块中的信息；
		[root@lcfyl ~]# tune2fs -l /dev/sdb5
		tune2fs 1.41.12 (17-May-2010)
		Filesystem volume name:   MYDATA
		Last mounted on:          <not available>
		Filesystem UUID:          db2ecb12-2a03-433d-bc2d-d5939862b88c
		Filesystem magic number:  0xEF53
		Filesystem revision #:    1 (dynamic)
		Filesystem features:      has_journal ext_attr resize_inode dir_index filetype sparse_super large_file
		Filesystem flags:         signed_directory_hash 
		Default mount options:    (none)
		Filesystem state:         clean
		Errors behavior:          Continue
		Filesystem OS type:       Linux
		Inode count:              526320
		Block count:              526120
		Reserved block count:     26306
		Free blocks:              476004
		Free inodes:              526309
		First block:              0
		Block size:               4096
		Fragment size:            4096
		Reserved GDT blocks:      128
		Blocks per group:         32752
		Fragments per group:      32752
		Inodes per group:         30960
		Inode blocks per group:   1935
		Filesystem created:       Thu Mar 17 09:51:00 2016
		Last mount time:          n/a
		Last write time:          Thu Mar 17 10:07:50 2016
		Mount count:              0
		Maximum mount count:      26
		Last checked:             Thu Mar 17 09:51:00 2016
		Check interval:           15552000 (6 months)
		Next check after:         Tue Sep 13 09:51:00 2016
		Reserved blocks uid:      0 (user root)
		Reserved blocks gid:      0 (group root)
		First inode:              11
		Inode size:	          256
		Required extra isize:     28
		Desired extra isize:      28
		Journal inode:            8
		Default directory hash:   half_md4
		Directory Hash Seed:      65a30783-594a-44ff-8497-2f0584151723
		Journal backup:           inode blocks

	
dumpe2fs: 显示文件属性信息
	-h: 只显示超级块中的信息
	
fsck: 检查并修复Linux文件系统
	-t FSTYPE: 指定文件系统类型（不能指错）
	-a: 自动修复
	
e2fsck: 专用于修复ext2/ext3文件系统
	-f: 强制检查；
	-p: 自动修复；
[root@lcfyl ~]# e2fsck /dev/sdb5
e2fsck 1.41.12 (17-May-2010)
MYDATA: clean, 11/526320 files, 50116/526120 blocks
	

	
挂载：将新的文件系统关联至当前根文件系统
卸载：将某文件系统与当前根文件系统的关联关系预以移除；

mount：挂载
mount 设备 挂载点
	设备：可以用下面三种方式
		设备文件：/dev/sda5
		卷标：LABEL=“”
		UUID： UUID=“”
	挂载点：目录
		要求：
			1、此目录没有被其它进程使用；
			2、目录得事先存在；
			3、目录中的原有的文件将会暂时隐藏；

mount: 显示当前系统已经挂载的设备及挂载点（不带任何参数）
mount [options：这个指命令选项] [-o options：这个指功能选项] DEVICE MOUNT_POINT
	-a: 表示挂载/etc/fstab文件中定义的所有文件系统
	-n: 默认情况下，mount命令每挂载一个设备，都会把挂载的设备信息保存至/etc/mtab文件；使用—n选项意味着挂载设备时，不把信息写入此文件；
	-t FSTYPE: 指定正在挂载设备上的文件系统的类型；不使用此选项时，mount会调用blkid命令获取对应文件系统的类型；
	-r: 只读挂载，挂载光盘时常用此选项
	-w: 读写挂载
	
	-o: 指定额外的挂载选项，也即指定文件系统启用的属性；
		async：先保存到内存中
		acl：启用acl功能
		remount: 重新挂载当前文件系统
		ro: 挂载为只读
			[root@lcfyl ~]# mount -o ro /dev/cdrom /media
		rw: 读写挂载
			[root@lcfyl ~]# mount -o remount,rw /dev/cdrom /media
	
			
挂载完成后，要通过挂载点访问对应文件系统上的文件；

umount: 卸载某文件系统
	umount 设备
	umount 挂载点	

	卸载注意事项：
		挂载的设备没有进程使用；
		
练习：
1、创建一个2G的分区，文件系统为ext2，卷标为DATA，块大小为1024，预留管理空间为磁盘分区的8%；
挂载至/backup目录，要求使用卷标进行挂载，且在挂载时启动此文件系统上的acl功能；
# mke2fs -L DATA -b 1024 -m 8  /dev/sda7

# mount -o acl LABEL=DATA /backup

# tune2fs -o acl /dev/sda7
# mount LABEL=DATA /backup

2、将此文件系统的超级块中的信息中包含了block和inode的行保存至/tmp/partition.txt中；
# tune2fs -l DEVICE| egrep -i  "block|inode" >> /tmp/partition.txt  
# dumpe2fs -h |
3、复制/etc目录中的所有文件至此文件系统；而后调整此文件系统类型为ext3，要求不能损坏已经复制而来的文件；
# cp -r /etc/*  /backup
# tune2	-j /dev/sda7
4、调整其预留百分比为3%；
# tune2fs -m 3 -L DATA /dev/sda7
5、以重新挂载的方式挂载此文件系统为不更新访问时间戳，并验正其效果；
# stat /backup/inittab
# cat /backup/inittab
# stat
 
# mount -o remount,noatime /backup
# cat 
# stat

6、对此文件系统强行做一次检测；
e2fsck -f /dev/sda7
7、删除复制而来的所有文件，并将此文件系统重新挂载为同步(sync)；而后再次复制/etc目录中的所有文件至此挂载点，体验其性能变化；
# rm -rf /backup/*
# mount -o remount,sync /backup
# cp -r /etc/* /backup



swap分区：
free：查看物理内存和交换内存的信息
	-mh：以兆显示

创建交换分区：
mkswap /dev/sda8
	-L LABEL

swapon /dev/sda8
	-a:启用所有的定义在/etc/fstab文件中的交换设备
swapoff /dev/sda8

1、fdisk命令中，调整分区类型为82；
***初始化的分区类型是为了方便管理的，如果不指将来很难与文件系统匹配
2、创建交换分区系统
3、启用交换分区
[root@lcfyl ~]# fdisk /dev/sdb
Command (m for help): n
Command action
   l   logical (5 or over)
   p   primary partition (1-4)
l
First cylinder (2225-2610, default 2225): 
Using default value 2225
Last cylinder, +cylinders or +size{K,M,G} (2225-2610, default 2610): +1G
Command (m for help): t
Partition number (1-7): 7
Hex code (type L to list codes): 82
Changed system type of partition 7 to 82 (Linux swap / Solaris)

Command (m for help): w
The partition table has been altered!
[root@lcfyl ~]# partprobe /dev/sdb7
[root@lcfyl ~]# mkswap /dev/sdb7
Setting up swapspace version 1, size = 1060252 KiB
no label, UUID=10180c6d-9e4e-4374-8a07-d00cd6c81f30
[root@lcfyl ~]# swapon /dev/sdb7
[root@lcfyl ~]# free -m
             total       used       free     shared    buffers     cached
Mem:          2023        184       1839          0         10         67
-/+ buffers/cache:        106       1916
Swap:         5099          0       5099
[root@lcfyl ~]# swapoff /dev/sdb7
[root@lcfyl ~]# free -m
             total       used       free     shared    buffers     cached
Mem:          2023        183       1839          0         10         67
-/+ buffers/cache:        105       1917
Swap:         4063          0       4063


回环设备
loopback: 使用软件来模拟实现硬件

创建一个镜像文件，120G

****dd命令：
	if=数据来源
	of=数据存储目标
	bs=1（以多少字节为单位）
	count=2（复制多少个单位）
	seek=#: 创建数据文件时，跳过的空间大小；
	
dd if=/dev/sda of=/mnt/usb/mbr.backup bs=512 count=1（从最开始复制512个字节，就是备份MBR）
dd if=/mnt/usb/mbr.backup of=/dev/sda bs=512 count=1（还原MBR）

dd if=/dev/zero of=/var/swapfile bs=1M count=1024
/dev/zero：泡泡设备，一直吐零
/dev/null：黑洞设备，吞没一切
	

****因为iso镜像不在光驱也就是不在设备文件中，只能用下列方式挂载使用
mount命令，可以挂载iso镜像；
mount DEVICE MOUNT_POINT
	-o loop: 挂载本地回环设备
	#mount -o loop /root/rhci-5.8-1.iso /media

wget ftp://172.16.0.1/pub/isos/rhci-5.8-1.iso



mount /dev/sda5 /mnt/test


文件系统的配置文件/etc/fstab
	OS在初始时，会自动挂载此文件中定义的每个文件系统
	
要挂载的设备	挂载点	     文件系统类型      挂载选项	    转储频率(每多少天做一次完全备份)   文件系统检测次序(只有根可以为1)		
/dev/sda5      /mnt/test	ext3	       defaults		0				0

***mount -a：挂载/etc/fstab文件中定义的所有文件系统
***每当 mount 挂载分区、umount 卸载分区，都会动态更新 mtab,mtab 总是保持着当前系统中已挂载的分区信息，fdisk、df 这类程序，
   必须要读取 mtab 文件，才能获得当前系统中最新的分区挂载情况
	[root@mail ~]# df
	Filesystem           1K-blocks      Used Available Use% Mounted on
	/dev/sda2              9920624   4496784   4911772  48% /
	/dev/sda1               101086     11564     84303  13% /boot
	tmpfs                   517316         0    517316   0% /dev/shm
	[root@mail ~]# cat /etc/mtab 
	/dev/sda2 / ext3 rw 0 0
	proc /proc proc rw 0 0
	sysfs /sys sysfs rw 0 0
	devpts /dev/pts devpts rw,gid=5,mode=620 0 0
	/dev/sda1 /boot ext3 rw 0 0
	tmpfs /dev/shm tmpfs rw 0 0
	none /proc/sys/fs/binfmt_misc binfmt_misc rw 0 0
	sunrpc /var/lib/nfs/rpc_pipefs rpc_pipefs rw 0 0
	[root@mail ~]# mount -o loop /root/cn_windows_server_2008_r2\ sp1.iso /media/
	[root@mail ~]# mount /dev/sda6 /mnt/
	[root@mail ~]# cat /etc/mtab 
	/dev/sda2 / ext3 rw 0 0
	proc /proc proc rw 0 0
	sysfs /sys sysfs rw 0 0
	devpts /dev/pts devpts rw,gid=5,mode=620 0 0
	/dev/sda1 /boot ext3 rw 0 0
	tmpfs /dev/shm tmpfs rw 0 0
	none /proc/sys/fs/binfmt_misc binfmt_misc rw 0 0
	sunrpc /var/lib/nfs/rpc_pipefs rpc_pipefs rw 0 0
	/root/cn_windows_server_2008_r2\040sp1.iso /media udf rw,loop=/dev/loop0 0 0
	/dev/sda6 /mnt ext3 rw 0 0
	[root@mail ~]# df -h
	Filesystem            Size  Used Avail Use% Mounted on
	/dev/sda2             9.5G  4.3G  4.7G  48% /
	/dev/sda1              99M   12M   83M  13% /boot
	tmpfs                 506M     0  506M   0% /dev/shm
	/root/cn_windows_server_2008_r2 sp1.iso
			      2.0G  2.0G     0 100% /media
	/dev/sda6             9.1G  150M  8.7G   2% /mnt
	[root@mail ~]# 
fuser: 验正进程正在使用的文件或套接字文件
	-v: 查看某文件上正在运行的进程
	-k: 结束正在进行的进程
	-m：针对挂载点的文件
	
	fuser -km MOUNT_POINT：终止正在访问此挂载点的所有进程
	
练习：
1、创建一个5G的分区，文件系统为ext3，卷标为MYDATA，块大小为1024，预留管理空间为磁盘分区的3%，要求开机后可以自动挂载至/data目录，
   并且自动挂载的设备要使用卷标进行引用；
[root@lcfyl ~]# mke2fs -j -L MYDATA -b 1024 -m 3 /dev/sdb5
[root@lcfyl ~]# mkdir /data
[root@lcfyl ~]# vim /etc/fstab 
/dev/mapper/vg_lcfyl-lv_swap swap                    swap    defaults        0 0
tmpfs                   /dev/shm                tmpfs   defaults        0 0
devpts                  /dev/pts                devpts  gid=5,mode=620  0 0
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
LABEL=MYDATA            /data                   ext3    defaults        0 0

2、创建一个本地回环文件/var/swaptemp/swapfile来用于swap，要求大小为512MB，卷标为SWAP-FILE，且开机自动启用此交换设备；
# mkdir /var/swaptemp
# dd if=/dev/zero of=/var/swaptemp/swapfile bs=1M count=512
# mkswap LABLE=SWAP-FILE /var/swaptemp/swapfile

/etc/fstab
/var/swaptemp/swapfile  	swap		swap		defaults		0 0
3、上述第一问，如何让其自动挂载的同时启用ACL功能；
/etc/fstab
LABEL='MYDATA'		/data		ext3		defaults,acl	0 0
***如果要在挂载时添加新功能，就直接在defaults后面加即可



压缩、解压缩命令
压缩格式：gz, bz2, xz, zip, Z

压缩算法：算法不同，压缩比也会不同；

compress: FILENAME.Z
uncompress

gzip: .gz
	gzip /PATH/TO/SOMEFILE：压缩完成后会删除原文件
		-d： 解压缩
		-#：1-9，指定压缩比，默认是6；
[root@lcfyl ~]# cp /var/log/messages ./
[root@lcfyl ~]# ls -lh messages 
-rw-------. 1 root root 404K  3月 17 16:40 messages
[root@lcfyl ~]# gzip messages 
[root@lcfyl ~]# ls -lh messages.gz 
-rw-------. 1 root root 67K  3月 17 16:40 messages.gz
[root@lcfyl ~]# 
	
gunzip: 
	gunzip /PATH/TO/SOMEFILE.gz: 解压完成后会删除原文件
[root@lcfyl ~]# gunzip messages.gz 
-rw-------. 1 root root 404K  3月 17 16:40 messages

zcat /PATH/TO/SOMEFILE.gz： 不解压的情况，查看文本文件的内容
	

bzip2: .bz2
比gzip有着更大压缩比的压缩工具，使用格式近似
	bzip2 /PATH/TO/SOMEFILE
		-d：解压缩
		-#: 1-9,默认是6
		-k: 压缩时保留原文件
		
	bunzip2 /PATH/TO/SOMEFILE.bz2
	bzcat

xz: .xz
	xz /PATH/TO/SOMEFILE
		-d：解压缩
		-#: 1-9, 默认是6
		-k: 压缩时保留原文件
		
	unxz：解压
	xzdec：解压到屏幕
	xzcat ：不解压显示

zip: 既归档又压缩的工具
	zip FILENAME.zip（自己指定名字） FILE1 FILE2 ...: 压缩后不删除原文件
	unzip FILENAME.zip
***可以压缩目录
[root@lcfyl ~]# zip backup.zip backup/*
  adding: backup/test/ (stored 0%)
[root@lcfyl ~]# ls 
anaconda-ks.cfg  backup.zip  index.html   install.log.syslog  showlogged1.sh
backup           case.sh     install.log  messages.xz         showlogged.sh

	
archive: 归档，归档本身并不意味着压缩

xz, bz2, gz


tar: 归档工具, .tar（只归档不压缩）
	-c: 创建归档文件
	-C：指定解压后的路径，默认为当前目录
	-f FILE.tar: 操作的归档文件
		[root@lcfyl ~]# ls 
		anaconda-ks.cfg  backup.zip  index.html   install.log.syslog  showlogged1.sh
		backup           case.sh     install.log  messages.xz         showlogged.sh
		[root@lcfyl ~]# tar -cf i.tar i*
		[root@lcfyl ~]# ls 
		anaconda-ks.cfg  case.sh      install.log.syslog  showlogged1.sh
		backup           index.html   i.tar               showlogged.sh
		backup.zip       install.log  messages.xz
		[root@lcfyl ~]# 

	-x: 展开归档
	--xattrs: 归档时，保留文件的扩展属性信息
	-t: 不展开归档，直接查看归档了哪些文件
		[root@lcfyl ~]# tar -tf i.tar 
		index.html
		install.log
		install.log.syslog

	-zcf: 归档并调用gzip压缩
	-zxf: 调用gzip解压缩并展开归档，-z选项可省略
	
	-jcf: 归档并调用bzip2压缩
	-jxf: 调用bzip2解压缩并展开归档
	
	-Jcf: xz
	-Jxf:
		[root@lcfyl ~]# ls
		anaconda-ks.cfg  case.sh      install.log.syslog  showlogged1.sh
		backup           index.html   i.tar               showlogged.sh
		backup.zip       install.log  messages.xz
		[root@lcfyl ~]# tar -Jcf i.tar.xz i*
		[root@lcfyl ~]# ls
		anaconda-ks.cfg  case.sh      install.log.syslog  messages.xz
		backup           index.html   i.tar               showlogged1.sh
		backup.zip       install.log  i.tar.xz            showlogged.sh
		[root@lcfyl ~]# tar -Jtf i.tar.xz 
		index.html
		install.log
		install.log.syslog
		i.tar
		[root@lcfyl ~]# 


cpio: 归档工具
	

	
练习：写一个脚本
从键盘让用户输入几个文件，脚本能够将此几个文件归档压缩成一个文件；
read:
[root@lcfyl ~]# read NAME
abc
[root@lcfyl ~]# echo $NAME
abc
[root@lcfyl ~]# read NAME AGE
jerry 18
[root@lcfyl ~]# echo $NAME
jerry
[root@lcfyl ~]# echo $AGE
18

	-p “PROMPT": 给出提示
	-t 3：表示输入时间在3秒内
#!/bin/bash
#
read -t 3 -p "Input two integers:" A B
[ -z $A ] && A=100
[ -z $B ] && B=1000
echo "$A plus $B is : $[$A+$B]"

#!/bin/bash
#
read -p "Three files:" FILE1 FILE2 FILE3
read -p "Destination:" DEST

tar -jcf $DEST.tar.bz2 $FILE1 $FILE2 $FILE3

	

脚本编程：
	顺序结构
	选择结构
		if
		case
	循环结构
		for
		while
		until
		
while循环：适用于循环次数未知的场景，要有退出条件
语法：
	while CONDITION; do
	  statement
	  ...
	done
	
计算100以内所有正整数的和

#!/bin/bash
declare -i I=1
declare -i SUM=0

while [ $I -le 100 ]; do
  let SUM+=$I
  let I++
done

echo $SUM

练习：转换用户输入的字符为大写，除了quit:
#!/bin/bash
#
read -p "Input something: " STRING

while [ $STRING != 'quit' ]; do
  echo $STRING | tr 'a-z' 'A-Z'
  read -p "Input something: " STRING
done

练习：每隔5秒查看hadoop用户是否登录，如果登录，显示其登录并退出；否则，显示当前时间，并说明hadoop尚未登录：
#!/bin/bash
#
who | grep "hadoop" &> /dev/null
RETVAL=$?

while [ $RETVAL -ne 0 ]; do
  echo "`date`, hadoop is not log." 
  sleep 5
  who | grep "hadoop" &> /dev/null
  RETVAL=$?
done

echo "hadoop is logged in."

写一个脚本:
1) 显示一个菜单给用户：
d|D) show disk usages.
m|M) show memory usages. 
s|S) show swap usages.
*) quit.
2) 当用户给定选项后显示相应的内容；
   
扩展：
	当用户选择完成，显示相应信息后，不退出；而让用户再一次选择，再次显示相应内容；除了用户使用quit；
#!/bin/bash
#
cat << EOF
d|D) show disk usages.
m|M) show memory usages.
s|S) show swap usages.
*) quit.
EOF

read -p "Your choice: " CHOICE
while [ $CHOICE != 'quit' ];do
  case $CHOICE in
  d|D)
    echo "Disk usage: "
    df -Ph ;;
  m|M)
    echo "Memory usage: "
    free -m | grep "Mem" ;;
  s|S)
    echo "Swap usage: "
    free -m | grep "Swap" ;;
  *)
    echo "Unknown.." ;;
  esac

read -p "Again, your choice: " CHOICE
done	

颜色显示（前景色背景色数字位置可以不讲究顺序）：
格式：echo -e "\033[ ; m …… \033[0m"
字背景颜色范围:40----49

40:黑 41:深红 42:绿 43:黄色 44:蓝色 45:紫色 46:深绿 47:白色

字颜色:30-----------39

30:黑 31:红 32:绿 33:黄 34:蓝色 35:紫色 36:深绿 37:白色

ANSI控制码的说明

\033[0m 关闭所有属性 \033[1m 设置高亮度 \033[4m 下划线 \033[5m 闪烁 \033[7m 反显 \033[8m 消隐

\033[nA 光标上移n行 \033[nB 光标下移n行 \033[nC 光标右移n行 \033[nD 光标左移n行 \033[y;xH设置光标位置

\033[2J 清屏 \033[K 清除从光标到行尾的内容 \033[s 保存光标位置 \033[u 恢复光标位置 \033[?25l 隐藏光标

\033[?25h 显示光标

[root@lcfyl ~]# echo -e "\033[1mHello\033[0m,world."
Hello,world.
[root@lcfyl ~]# echo -e "\033[31mHello\033[0m,world."
Hello,world.
[root@lcfyl ~]# echo -e "\033[32mHello\033[0m,world."
Hello,world.
[root@lcfyl ~]# echo -e "\033[42mHello\033[0m,world."
Hello,world.
[root@lcfyl ~]# echo -e "\033[31;42mHello\033[0m,world."
Hello,world.
[root@lcfyl ~]# echo -e "\033[1;31;42mHello\033[0m,world."
Hello,world.


ext2: 文件系统块组组成：
超级块、GDT、block bitmap、inode bitmap、data blocks

文件系统挂载时的注意事项：
1、挂载点事先存在；
2、目录是否已经被其它进程使用；
3、目录中的原有文件会被暂时隐藏；

mount DEVICE MOUNT_POINT
1、设备文件；
2、LABEL
3、UUID

/etc/fstab文件格式：
设备		挂载点		文件系统类型		挂载选项		转储频率  检测次序


安装RHEL6.3 x86_64的方法（前提：请确保你的CPU支持硬件虚拟化技术）：
1、创建虚拟机；
2、下载isos目录中的rhci-rhel-6.3-1.iso，并导入虚拟机的虚拟光驱；
3、在boot提示符输入：linux ip=172.16.x.1 netmask=255.255.0.0 gateway=172.16.0.1 dns=172.16.0.1 ks=http://172.16.0.1/rhel6.cfg
	


RAID: 

级别：仅代表磁盘组织方式不同，没有上下之分；
0： 条带
	性能提升: 读，写
	冗余能力（容错能力）: 无
	空间利用率：nS
	至少2块盘
1： 镜像
	性能表现：写性能下降，读性能提升
	冗余能力：有
	空间利用率：1/2
	至少2块盘
2:
3:
4: 
5: 
	性能表现：读，写提升
	冗余能力：有
	空间利用率：(n-1)/n
	至少需要3块
10:
	性能表现：读、写提升
	冗余能力：有
	空间利用率：1/2
	至少需要4块
01:
	性能表现：读、写提升
	冗余能力：有
	空间利用率：1/2
	至少需要4块
50:
	性能表现：读、写提升
	冗余能力：有
	空间利用率：(n-2)/n
    至少需要6块
jbod:
	性能表现：无提升
	冗余能力：无
	空间利用率：100%
	至少需要2块



逻辑RIAD：
/dev/md0
/dev/md1



md: 内核模块，系统一定要支持
mdadm: 将任何块设备做成RAID
模式化的命令：
	创建模式
		-C 
			专用选项：
				-l: 级别
				-n #: 设备个数
				-a {yes|no}: 是否自动为其创建设备文件
				-c: CHUNK大小, 2^n，默认为64K
				-x #: 指定空闲盘个数
	管理模式
		--add, --remove, --fail
		mdadm /dev/md# --fail /dev/sda7
	监控模式
		-F
	增长模式
		-G
	装配模式
		-A

查看RAID阵列的详细信息
mdadm -D /dev/md#
	--detail
	
****有时阵列在重启后定义的设备路径发生变化，如：
/dev/md0变成/dev/md126
解决办法就是修改/etc/mdadm.conf
[root@lcfyl ~]# mdadm -D --scan
ARRAY /dev/md/lcfyl:0 metadata=1.2 name=lcfyl:0 UUID=4290bb50:5a418efb:a49b6654:c38f4c7e
ARRAY /dev/md/lcfyl:1 metadata=1.2 name=lcfyl:1 UUID=d941f938:670d700f:def156ca:33ba60f6
[root@lcfyl ~]# mdadm -D --scan >> /etc/mdadm.conf 
[root@lcfyl ~]# vim /etc/mdadm.conf 
将新增两行中的/dev/md/lcfyl:0改成/dev/md/md0（也就是根据这个格式定义成自己想要的）即可

****有时用partprobe内核重读磁盘，会出现磁盘忙资源占用的情况，出现这种情况的原因一般有两个
[root@lcfyl ~]# partprobe /dev/sdb
Warning: WARNING: the kernel failed to re-read the partition table on /dev/sdb (设备或资源忙). 
As a result, it may not reflect all of your changes until after reboot.
1、磁盘处于挂载状态
2、磁盘处于阵列应用当中
解决办法：
[root@lcfyl ~]# umount /mnt
[root@lcfyl ~]# mdadm -S /dev/md5
mdadm: stopped /dev/md5
[root@lcfyl ~]# partprobe /dev/sdb
[root@lcfyl ~]# 


RAID0
	2G:
		4: 512MB
		2: 1G
***1、为阵列创建新分区，并将分区类型改成"Linux raid autodetect"
[root@lcfyl ~]# fdisk /dev/sdb
Command (m for help): t
Partition number (1-6): 5
Hex code (type L to list codes): fd
Changed system type of partition 5 to fd (Linux raid autodetect)

Command (m for help): t
Partition number (1-6): 6
Hex code (type L to list codes): fd
Changed system type of partition 6 to fd (Linux raid autodetect)

Command (m for help): p
Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1         654     5253223+  83  Linux
/dev/sdb2             655        1308     5253255   83  Linux
/dev/sdb3            1309        2610    10458315    5  Extended
/dev/sdb5            1309        1440     1060258+  fd  Linux raid autodetect
/dev/sdb6            1441        1572     1060258+  fd  Linux raid autodetect

***2、内核重新识别磁盘，读取分区
[root@lcfyl ~]# partprobe /dev/sdb
[root@lcfyl ~]# cat /proc/partitions 
major minor  #blocks  name
8       17    5253223 sdb1
   8       18    5253255 sdb2
   8       19          1 sdb3
   8       21    1060258 sdb5
   8       22    1060258 sdb6
 253        0   16293888 dm-0
 253        1    4161536 dm-1
 
 ***3、开始创建阵列，在mdadm的创建模式下完成
[root@lcfyl ~]# mdadm -C /dev/md0 -a yes -l 0 -n 2 /dev/sdb{5,6}
mdadm: /dev/sdb5 appears to contain an ext2fs file system
    size=5253220K  mtime=Sat Mar 19 07:19:41 2016
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.

***4、内存中有一个专门模块mdstat记录当前系统下的阵列
[root@lcfyl ~]# cat /proc/mdstat 
Personalities : [raid0] 
md0 : active raid0 sdb6[1] sdb5[0]
      2117632 blocks super 1.2 512k chunks
      
unused devices: <none>

***5、格式化阵列
[root@lcfyl ~]# mke2fs -j /dev/md0
mke2fs 1.41.12 (17-May-2010)
文件系统标签=
操作系统:Linux
块大小=4096 (log=2)
分块大小=4096 (log=2)
Stride=128 blocks, Stripe width=256 blocks
132464 inodes, 529408 blocks
26470 blocks (5.00%) reserved for the super user
第一个数据块=0
Maximum filesystem blocks=545259520
17 block groups
32768 blocks per group, 32768 fragments per group
7792 inodes per group
Superblock backups stored on blocks: 
	32768, 98304, 163840, 229376, 294912

正在写入inode表: 完成                            
Creating journal (16384 blocks): 完成
Writing superblocks and filesystem accounting information: 完成

This filesystem will be automatically checked every 37 mounts or
180 days, whichever comes first.  Use tune2fs -c or -i to override.

***6、可以挂载使用了
[root@lcfyl ~]# mount /dev/md0 /mnt
[root@lcfyl ~]# ls /mnt/
lost+found
[root@lcfyl ~]# 
[root@lcfyl ~]# cat /proc/mdstat 
Personalities : [raid0] 
md0 : active raid0 sdb6[1] sdb5[0]
      2117632 blocks super 1.2 512k chunks



RAID1
***1、为阵列创建新分区，并且将分区类型改成阵列专用"Linux raid autodetect"
[root@lcfyl ~]# fdisk /dev/sdb
Command (m for help): t
Partition number (1-8): 7
Hex code (type L to list codes): fd
Changed system type of partition 7 to fd (Linux raid autodetect)
Command (m for help): t
Partition number (1-8): 8
Hex code (type L to list codes): fd
Changed system type of partition 8 to fd (Linux raid autodetect)

Command (m for help): w
The partition table has been altered!

***2、开始创建阵列，在mdadm的创建模式下进行
[root@lcfyl ~]# mdadm -C /dev/md1 -a yes -l 1 -n 2 /dev/sdb{7,8}
mdadm: Note: this array has metadata at the start and
    may not be suitable as a boot device.  If you plan to
    store '/boot' on this device please ensure that
    your boot-loader understands md/v1.x metadata, or use
    --metadata=0.90
Continue creating array? y
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md1 started.

***3、在内存mdstat模块中查看
[root@lcfyl ~]# cat /proc/mdstat 
Personalities : [raid0] [raid1] 
md1 : active raid1 sdb8[1] sdb7[0]
      2103447 blocks super 1.2 [2/2] [UU]
      
md0 : active raid0 sdb6[1] sdb5[0]
      2117632 blocks super 1.2 512k chunks
      
unused devices: <none>

***4、查看阵列的详细信息		
[root@lcfyl ~]# mdadm -D /dev/md1
/dev/md1:
        Version : 1.2
  Creation Time : Sat Mar 19 17:41:26 2016
     Raid Level : raid1
     Array Size : 2103447 (2.01 GiB 2.15 GB)
  Used Dev Size : 2103447 (2.01 GiB 2.15 GB)
   Raid Devices : 2
  Total Devices : 2
    Persistence : Superblock is persistent

    Update Time : Sat Mar 19 18:21:40 2016
          State : clean
 Active Devices : 2
Working Devices : 2
 Failed Devices : 0
  Spare Devices : 0

           Name : lcfyl:1  (local to host lcfyl)
           UUID : 3420e731:b02964e0:c6057e58:164b349d
         Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       23        0      active sync   /dev/sdb7
       1       8       24        1      active sync   /dev/sdb8
[root@lcfyl ~]#

***5、模拟第8个分区坏了
[root@lcfyl ~]# mdadm /dev/md1 -f /dev/sdb8
mdadm: set /dev/sdb8 faulty in /dev/md1
[root@lcfyl ~]# cat  /proc/mdstat 
Personalities : [raid1] [raid0] 
md126 : active raid0 sdb6[1] sdb5[0]
      2117632 blocks super 1.2 512k chunks
      
md127 : active (auto-read-only) raid1 sdb7[0]
      2103447 blocks super 1.2 [2/1] [U_]

***6、移除坏掉的第8个分区
[root@lcfyl ~]# mdadm /dev/md1 -r /dev/sdb8
mdadm: hot removed /dev/sdb8 from /dev/md1
[root@lcfyl ~]# mdadm -D /dev/md1
 Number   Major   Minor   RaidDevice State
       0       8       23        0      active sync   /dev/sdb7
       1       0        0        1      removed

***7、重新补上第9个分区
[root@lcfyl ~]# mdadm /dev/md127 -a /dev/sdb9
mdadm: added /dev/sdb9

***8、RAID1镜像分区会同步更新数据到新增的一块分区上
[root@lcfyl ~]# cat /proc/mdstat 
Personalities : [raid1] [raid0] 
md126 : active raid0 sdb6[1] sdb5[0]
      2117632 blocks super 1.2 512k chunks
      
md127 : active raid1 sdb9[2] sdb7[0]
      2103447 blocks super 1.2 [2/2] [UU]
      
unused devices: <none>

***8、再加一个分区上来
[root@lcfyl ~]# mdadm /dev/md127 -a /dev/sdb8
mdadm: re-added /dev/sdb8

***9、新加的分区会显示为空闲，其作用是冗余
[root@lcfyl ~]# mdadm -D /dev/md127
/dev/md127:
  Number   Major   Minor   RaidDevice State
       0       8       23        0      active sync   /dev/sdb7
       2       8       25        1      active sync   /dev/sdb9

       1       8       24        -      spare   /dev/sdb8

***10、watch命令可以隔指定秒数进行查看某种状态，默认2秒
[root@lcfyl ~]# watch 'cat /proc/mdstat'

***11、再次模拟损坏RAID1中的一块分区
[root@lcfyl ~]# mdadm /dev/md127 -f /dev/sdb9
mdadm: set /dev/sdb9 faulty in /dev/md127

***12、RAID1中的空闲分区会自动顶上来
[root@lcfyl ~]# mdadm -D /dev/md127
/dev/md127:
 Number   Major   Minor   RaidDevice State
       0       8       23        0      active sync   /dev/sdb7
       1       8       24        1      active sync   /dev/sdb8

       2       8       25        -      faulty spare   /dev/sdb9

***13、指定条带大小，一定程度上可以优化阵列性能（条带stride=chunk/block，以后就不用每次都计算chunk（默认KB），block默认Bytes）

[root@lcfyl ~]# mke2fs -j -E stride=16 -b 4096 /dev/md126
		
watch: 周期性地执行指定命令，并以全屏方式显示结果
	-n #：指定周期长度，单位为秒，默认为2
格式： watch -n # 'COMMAND'

***14、停止阵列：停止也可以重新启动
	mdadm -S /dev/md#
		--stop
[root@lcfyl ~]# mdadm -S /dev/md1
mdadm: stopped /dev/md1
[root@lcfyl ~]# cat /proc/mdstat 
Personalities : [raid1] [raid0] 
md0: active raid0 sdb6[1] sdb5[0]
      2117632 blocks super 1.2 512k chunks
      
unused devices: <none>
[root@lcfyl ~]# 

***15、重新启动：注意，重新启动时一定要准确指明以前阵列的对应磁盘
	将当前RAID信息保存至配置文件，以后进行装配时不用再指设备，它会自动查询此配置文件
	mdamd -D --scan > /etc/mdadm.conf（此文件默认没有，但是很有必要手动建立，因为系统启动要用到此文件生成设备文件）
	mdadm -A /dev/md1即可
[root@lcfyl ~]# mdadm -A /dev/md1 /dev/sdb7 /dev/sdb9
mdadm: /dev/md1 has been started with 2 drives.
[root@lcfyl ~]# cat /proc/mdstat 
Personalities : [raid1] [raid0] 
md1 : active raid1 sdb7[0] sdb9[2]
      2103447 blocks super 1.2 [2/2] [UU]
      
md0 : active raid0 sdb6[1] sdb5[0]
      2117632 blocks super 1.2 512k chunks
      
unused devices: <none>
[root@lcfyl ~]# 

*****关于删除RAID网上文件都很难，有的方法根本就是一坨屎
1、卸载raid	#umount /dev/md0
2、停止raid	#mdadm -S /dev/md0
3、删除配件	#mdadm --misc --zero-superblock /dev/sde
4、删除配置文件	#rm -rf /etc/mdadm.conf
5、清除fstab里面的md0挂载行

创建一个空间大小为10G的RAID5设备；其chuck大小为32k；要求此设备开机时可以自动挂载至/backup目录；
RAID5: 此raid5的常见用法在raid1中已经全部演示
	2G: 3, 1G


cat /proc/filesystems : 查看当前内核所支持文件系统类型

RAID: 独立冗余磁盘阵列
Linux：硬件，软件
	/dev/md#


MD, DM	
MD: Multi Device, 多设备
	/dev/md#
	meta device

DM: Device Mapper
	逻辑设备
		RAID, LVM2
		
DM: LVM2依赖的核心
	快照
	多路径（线路冗余）
一、扩展逻辑卷；
lvextend：扩展物理边界（一定要注意与逻辑边界的顺序）
	-L [+]# /PATH/TO/LV

2G, +3G：加3G
5G：到5G
	
resize2fs：扩展逻辑边界
	resize2fs -p /PATH/TO/LV
			-p：物理边界多大扩展多大


二、缩减逻辑卷（风险很大，严格执行下列三步）；
注意：1、不能在线缩减，得先卸载；
	2、确保缩减后的空间大小依然能存储原有的所有数据；
	  3、在缩减之前应该先强行检查文件，以确保文件系统处于一至性状态；
df -lh
umount 
e2fsck -f
	  	  
resize2fs 
	resize2fs /PATH/TO/PV 3G

lvreduce -L [-]# /PATH/TO/LV

重新挂载


三、快照卷（快照卷其实和复制归档的功能一样，只是快照的速度非常快，大量数据备份时优势非常明显，原理经实验查出，本尊和快照中的文件指向的是同一inode，和硬链接一个理儿）
1、生命周期为整个数据时长；在这段时长内，数据的增长量不能超出快照卷大小；
2、快照卷应该是只读的；
3、跟原卷在同一卷组内；


lvcreate 
	-s：快照卷选项
	-p r|w
	
lvcreate -s -L # -n SLV_NAME -p r /PATH/TO/LV
***实现逻辑卷要分三层组合三层管理
***和非LVM系统将包含分区信息的元数据保存在位于分区的起始位置的分区表中一样，逻辑卷以及卷组相关的元数据也是保存在位于物理卷起始处的VGDA（卷组描述符区域）中。VGDA包括以下内容：PV描述符、VG描述符、LV描述符、和一些PE描述符。
***每一个物理卷PV被划分为称为PE（Physical Extents）的基本单元，具有唯一编号的PE是可以被LVM寻址的最小单元。PE的大小是可配置的，默认为4MB。所以物理卷（PV）由大小等同的基本单元PE组成。
***逻辑卷LV也被划分为可被寻址的基本单位，称为LE。在同一个卷组中，LE的大小和PE是相同的，并且一一对应。
***每个LV最多有65534个PE，即256GB，所以每个LV会受PE限制
0、准备好分区，并将分区类型改成8e(Linux LVM)
1、创建physical volume（PV），也就是物理卷
[root@lcfyl ~]# pvcreate /dev/sdb{5,6}
  Physical volume "/dev/sdb5" successfully created
  Physical volume "/dev/sdb6" successfully created
[root@lcfyl ~]# pvs
  PV         VG       Fmt  Attr PSize  PFree
  /dev/sda2  vg_lcfyl lvm2 a-   19.51g    0 
  /dev/sdb5           lvm2 a-    2.01g 2.01g
  /dev/sdb6           lvm2 a-    2.01g 2.01g
[root@lcfyl ~]# pvdisplay 
  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               vg_lcfyl
  PV Size               19.51 GiB / not usable 3.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              4994
  Free PE               0
  Allocated PE          4994
  PV UUID               GdR2W9-UugK-rI5D-41a2-TT92-LAPf-toRnY5
   
  "/dev/sdb5" is a new physical volume of "2.01 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb5
  VG Name               
  PV Size               2.01 GiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               sZcRrT-pnzC-Jr1a-g13U-25Os-3dOy-Z8SmOJ
   
  "/dev/sdb6" is a new physical volume of "2.01 GiB"
  --- NEW Physical volume ---
  PV Name               /dev/sdb6
  VG Name               
  PV Size               2.01 GiB
  Allocatable           NO
  PE Size               0   
  Total PE              0
  Free PE               0
  Allocated PE          0
  PV UUID               OXcfmC-BDsV-TB3c-L3bX-D5X0-6ALD-5hswJM
   
[root@lcfyl ~]# pvscan 
  PV /dev/sda2   VG vg_lcfyl        lvm2 [19.51 GiB / 0    free]
  PV /dev/sdb5                      lvm2 [2.01 GiB]
  PV /dev/sdb6                      lvm2 [2.01 GiB]
  Total: 3 [23.52 GiB] / in use: 1 [19.51 GiB] / in no VG: 2 [4.01 GiB]

2、创建volume group（VG），也就是卷组
[root@lcfyl ~]# vgcreate myvg /dev/sdb{5,7}
  No physical volume label read from /dev/sdb7
  Physical volume "/dev/sdb7" successfully created
  Volume group "myvg" successfully created
[root@lcfyl ~]# vgs
  VG       #PV #LV #SN Attr   VSize  VFree
  myvg       2   0   0 wz--n-  7.01g 7.01g
  vg_lcfyl   1   2   0 wz--n- 19.51g    0 
[root@lcfyl ~]# vgremove myvg
  Volume group "myvg" successfully removed
[root@lcfyl ~]# vgscan 
  Reading all physical volumes.  This may take a while...
  Found volume group "vg_lcfyl" using metadata type lvm2
[root@lcfyl ~]# vgcreate -s 8 myvg /dev/sdb{5,6}
  Volume group "myvg" successfully created
[root@lcfyl ~]# pvmove /dev/sdb6
  No data to move for myvg
[root@lcfyl ~]# vgreduce myvg /dev/sdb6
  Removed "/dev/sdb6" from volume group "myvg"
[root@lcfyl ~]# pvs
  PV         VG       Fmt  Attr PSize  PFree
  /dev/sda2  vg_lcfyl lvm2 a-   19.51g    0 
  /dev/sdb5  myvg     lvm2 a-    2.00g 2.00g
  /dev/sdb6           lvm2 a-    2.01g 2.01g
  /dev/sdb7           lvm2 a-    5.01g 5.01g
[root@lcfyl ~]# vgs
  VG       #PV #LV #SN Attr   VSize  VFree
  myvg       1   0   0 wz--n-  2.00g 2.00g
  vg_lcfyl   1   2   0 wz--n- 19.51g    0 
[root@lcfyl ~]# pvremove /dev/sdb6
  Labels on physical volume "/dev/sdb6" successfully wiped
[root@lcfyl ~]# pvs
  PV         VG       Fmt  Attr PSize  PFree
  /dev/sda2  vg_lcfyl lvm2 a-   19.51g    0 
  /dev/sdb5  myvg     lvm2 a-    2.00g 2.00g
  /dev/sdb7           lvm2 a-    5.01g 5.01g
[root@lcfyl ~]# vgs
  VG       #PV #LV #SN Attr   VSize  VFree
  myvg       1   0   0 wz--n-  2.00g 2.00g
  vg_lcfyl   1   2   0 wz--n- 19.51g    0 
[root@lcfyl ~]# 
[root@lcfyl ~]# pvcreate /dev/sdb7
  Physical volume "/dev/sdb7" successfully created
[root@lcfyl ~]# vgextend myvg /dev/sdb7
  Volume group "myvg" successfully extended
[root@lcfyl ~]# pvs
  PV         VG       Fmt  Attr PSize  PFree
  /dev/sda2  vg_lcfyl lvm2 a-   19.51g    0 
  /dev/sdb5  myvg     lvm2 a-    2.00g 2.00g
  /dev/sdb7  myvg     lvm2 a-    5.01g 5.01g
[root@lcfyl ~]# vgs
  VG       #PV #LV #SN Attr   VSize  VFree
  myvg       2   0   0 wz--n-  7.01g 7.01g
  vg_lcfyl   1   2   0 wz--n- 19.51g    0 

3、创建logical volume(LV)，也就是逻辑卷
***创建逻辑卷，注意格式
[root@lcfyl ~]# lvcreate -L 50M -n testlv myvg(lvcreate -l 100%FREE -n myvg_lv myvg)
  Rounding up size to full physical extent 56.00 MiB
  Logical volume "testlv" created
[root@lcfyl ~]# lvs
  LV      VG       Attr   LSize  Origin Snap%  Move Log Copy%  Convert
  testlv  myvg     -wi-a- 56.00m                                      
  lv_root vg_lcfyl -wi-ao 15.54g                                      
  lv_swap vg_lcfyl -wi-ao  3.97g
 ***显示逻辑卷详细信息
[root@lcfyl ~]# lvdisplay /dev/myvg/testlv 
  --- Logical volume ---
  LV Name                /dev/myvg/testlv
  VG Name                myvg
  LV UUID                dEdoAk-QjND-KfsW-F3QM-S7J6-xXG8-9V9Ba3
  LV Write Access        read/write
  LV Status              available
  # open                 0
  LV Size                56.00 MiB
  Current LE             7
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2
***创建文件系统
[root@lcfyl ~]# mke2fs -j /dev/myvg/testlv
***建立的逻辑卷实际上是一个软链接
[root@lcfyl ~]# ls -l /dev/mapper/myvg-testlv 
lrwxrwxrwx. 1 root root 7  3月 23 08:16 /dev/mapper/myvg-testlv -> ../dm-2
[root@lcfyl ~]# ls -l /dev/myvg/
总用量 0
lrwxrwxrwx. 1 root root 7  3月 23 08:16 testlv -> ../dm-2
***移除逻辑卷
[root@lcfyl ~]# lvremove /dev/myvg/testlv 
Do you really want to remove active logical volume testlv? [y/n]: y
  Logical volume "testlv" successfully removed
[root@lcfyl ~]# lvs
  LV      VG       Attr   LSize  Origin Snap%  Move Log Copy%  Convert
  lv_root vg_lcfyl -wi-ao 15.54g                                      
  lv_swap vg_lcfyl -wi-ao  3.97g                              
***重新创建逻辑卷并格式化文件系统
[root@lcfyl ~]# lvcreate -L 2G -n testlv myvg
  Logical volume "testlv" created
[root@lcfyl ~]# mkfs.ext3 /dev/myvg/testlv 
***挂载测试
[root@lcfyl ~]# mount /dev/myvg/testlv /mnt
[root@lcfyl ~]# cp /etc/inittab /mnt/
[root@lcfyl ~]# ls /mnt/
inittab  lost+found
***只有挂载文件系统才能识别(/etc/mtab)
[root@lcfyl ~]# df -lh
文件系统	      容量  已用  可用 已用%% 挂载点
/dev/mapper/vg_lcfyl-lv_root
                       16G  2.0G   13G  14% /
tmpfs                1012M     0 1012M   0% /dev/shm
/dev/sda1             485M   29M  432M   7% /boot
/dev/mapper/myvg-testlv
                      2.0G   68M  1.9G   4% /mnt
[root@lcfyl ~]# vgs
  VG       #PV #LV #SN Attr   VSize  VFree
  myvg       2   1   0 wz--n-  7.01g 5.01g
  vg_lcfyl   1   2   0 wz--n- 19.51g    0 
 ***扩大逻辑卷边界
[root@lcfyl ~]# lvextend -L 5G /dev/myvg/testlv 
  Extending logical volume testlv to 5.00 GiB
  Logical volume testlv successfully resized
 ***此时显示的是逻辑卷边界扩大，但是文件系统边界没有扩大（因为卷在应用之前要格式化成文件系统，扩大卷之后的部分并没有格式化文件系统）
[root@lcfyl ~]# lvs
  LV      VG       Attr   LSize  Origin Snap%  Move Log Copy%  Convert
  testlv  myvg     -wi-ao  5.00g                                      
  lv_root vg_lcfyl -wi-ao 15.54g                                      
  lv_swap vg_lcfyl -wi-ao  3.97g                                      
[root@lcfyl ~]# df -lh
文件系统	      容量  已用  可用 已用%% 挂载点
/dev/mapper/vg_lcfyl-lv_root
                       16G  2.0G   13G  14% /
tmpfs                1012M     0 1012M   0% /dev/shm
/dev/sda1             485M   29M  432M   7% /boot
/dev/mapper/myvg-testlv
                      2.0G   68M  1.9G   4% /mnt
***进一步扩大文件系统的边界（为扩大的逻辑卷部分划分文件系统）
[root@lcfyl ~]# resize2fs -p /dev/myvg/testlv 
resize2fs 1.41.12 (17-May-2010)
Filesystem at /dev/myvg/testlv is mounted on /mnt; on-line resizing required
old desc_blocks = 1, new_desc_blocks = 1
Performing an on-line resize of /dev/myvg/testlv to 1310720 (4k) blocks.
The filesystem on /dev/myvg/testlv is now 1310720 blocks long.

[root@lcfyl ~]# df -lh
文件系统	      容量  已用  可用 已用%% 挂载点
/dev/mapper/vg_lcfyl-lv_root
                       16G  2.0G   13G  14% /
tmpfs                1012M     0 1012M   0% /dev/shm
/dev/sda1             485M   29M  432M   7% /boot
/dev/mapper/myvg-testlv
                      5.0G   69M  4.7G   2% /mnt
***测试扩大之前的数据有没损坏
[root@lcfyl ~]# cat /mnt/inittab 


*****lvextend -L +5G -f -r /dev/myvg/myvg_lv1其实这一步就可以实现物理边界和文件系统同时扩大-r表示resize2fs


***缩减逻辑卷，由于风险较大，严格执行三步走

***首先确保缩减后的空间大小依然能存储原有的所有数据
[root@lcfyl ~]# df -lh
文件系统	      容量  已用  可用 已用%% 挂载点
/dev/mapper/vg_lcfyl-lv_root
                       16G  2.0G   13G  14% /
tmpfs                1012M     0 1012M   0% /dev/shm
/dev/sda1             485M   29M  432M   7% /boot
/dev/mapper/myvg-testlv
                      5.0G   69M  4.7G   2% /mnt
***其次不能在线缩减，先卸载
[root@lcfyl ~]# umount /mnt

***最后在缩减之前应该先强行检查文件，以确保文件系统处于一至性状态
[root@lcfyl ~]# e2fsck -f /dev/myvg/testlv 

***开始缩减文件系统，注意逻辑顺序，先减文件系统再减逻辑卷
[root@lcfyl ~]# resize2fs /dev/myvg/testlv 3G

***lvresize是lvextend和lvreduce组合
[root@lcfyl ~]# lvreduce -L 3G /dev/myvg/testlv 
  WARNING: Reducing active logical volume to 3.00 GiB
  THIS MAY DESTROY YOUR DATA (filesystem etc.)
Do you really want to reduce testlv? [y/n]: y
  Reducing logical volume testlv to 3.00 GiB
  Logical volume testlv successfully resized
***重新挂载测试，看文件是否损坏
[root@lcfyl ~]# mount /dev/myvg/testlv /mnt/
[root@lcfyl ~]# df -lh
文件系统	      容量  已用  可用 已用%% 挂载点
/dev/mapper/vg_lcfyl-lv_root
                       16G  2.0G   13G  14% /
tmpfs                1012M     0 1012M   0% /dev/shm
/dev/sda1             485M   29M  432M   7% /boot
/dev/mapper/myvg-testlv
                      3.0G   68M  2.8G   3% /mnt
[root@lcfyl ~]# cat /mnt/inittab 
# inittab is only used by upstart for the default runlevel.
#
# ADDING OTHER CONFIGURATION HERE WILL HAVE NO EFFECT ON YOUR SYSTEM.
#
# System initialization is started by /etc/init/rcS.conf
#
# Individual runlevels are started by /etc/init/rc.conf
#
# Ctrl-Alt-Delete is handled by /etc/init/control-alt-delete.conf
#
# Terminal gettys are handled by /etc/init/tty.conf and /etc/init/serial.conf,
# with configuration in /etc/sysconfig/init.
#
# For information on how to write upstart event handlers, or how
# upstart works, see init(5), init(8), and initctl(8).
#
# Default runlevel. The runlevels used are:
#   0 - halt (Do NOT set initdefault to this)
#   1 - Single user mode
#   2 - Multiuser, without NFS (The same as 3, if you do not have networking)
#   3 - Full multiuser mode
#   4 - unused
#   5 - X11
#   6 - reboot (Do NOT set initdefault to this)
# 
id:3:initdefault:
[root@lcfyl ~]# 


*****lvreduce -L -5G -r -f /dev/myvg/myvg_lv2同样的这一个命令可以完成物理边界和文件系统同时缩减


***创建快照卷，采用COW的机制，所以创建的快照卷并不需要跟原始卷一样大小，这个根据原始卷要写多少数据进去（也就是要复制多少数据到快照卷)来决定
如果快照卷跟原始卷一样大小或更大，完全不用担心快照卷会被挤爆
[root@lcfyl ~]# lvcreate -L 50M -n testlv-snap -s -p r /dev/myvg/testlv (lvcreate -s -l 20%ORIGIN -n myvg_lv1_snapshot /dev/myvg/myvg_lv1)
  Rounding up size to full physical extent 56.00 MiB
  Logical volume "testlv-snap" created
[root@lcfyl ~]# lvs
  LV          VG       Attr   LSize  Origin Snap%  Move Log Copy%  Convert
  testlv      myvg     owi-ao  3.00g                                      
  testlv-snap myvg     sri-a- 56.00m testlv   0.02                        
  lv_root     vg_lcfyl -wi-ao 15.54g                                      
  lv_swap     vg_lcfyl -wi-ao  3.97g                                      
[root@lcfyl ~]# mount /dev/myvg/testlv-snap /mnt
mount: block device /dev/mapper/myvg-testlv--snap is write-protected, mounting read-only
[root@lcfyl ~]# ls /mnt
inittab  lost+found
[root@lcfyl mnt]# wc -l inittab 
26 inittab
[root@lcfyl mnt]# mount /dev/myvg/testlv /media
[root@lcfyl mnt]# cd /media/
[root@lcfyl media]# ls
inittab  lost+found
***在原文件中删除两行
[root@lcfyl media]# vim inittab 
[root@lcfyl media]# wc -l inittab 
17 inittab
***查看快照中是否保留原数据
[root@lcfyl mnt]# wc -l inittab 
26 inittab
***再演示一个快照备份，非增量备份，快照之后若原文件改变则快照不能备份改变的部份
[root@lcfyl ~]# mount /dev/myvg/testlv /media/
[root@lcfyl ~]# cd /media/
[root@lcfyl media]# ls
inittab  lost+found
[root@lcfyl media]# cp /etc/issue ./
[root@lcfyl media]# ls
inittab  issue  lost+found
[root@lcfyl ~]# lvcreate -s -L 20M -p r -n testlv-snap /dev/myvg/testlv 
[root@lcfyl media]# cp /var/log/messages ./
[root@lcfyl media]# ls
inittab  issue  lost+found  messages
[root@lcfyl mnt]# mount /dev/myvg/testlv-snap /mnt
mount: block device /dev/mapper/myvg-testlv--snap is write-protected, mounting read-only
[root@lcfyl ~]# cd /mnt/
***创建快照后原文件中新增的message在快照中没有
[root@lcfyl mnt]# ls
inittab  issue  lost+found
***将快照归档，以备日后将快照恢复
[root@lcfyl mnt]# tar -jcf /tmp/testlv.tar.bz2 inittab issue 
[root@lcfyl mnt]# cd 
[root@lcfyl ~]# umount /mnt/
***归档后快照生命周期结束，可以移除
[root@lcfyl ~]# lvremove /dev/myvg/testlv-snap 
Do you really want to remove active logical volume testlv-snap? [y/n]: y
  Logical volume "testlv-snap" successfully removed
[root@lcfyl ~]# cd /media/
[root@lcfyl media]# ls
inittab  issue  lost+found  messages
***模拟原文件丢失
[root@lcfyl media]# rm inittab issue messages 
rm：是否删除普通文件 "inittab"？y
rm：是否删除普通文件 "issue"？y
rm：是否删除普通文件 "messages"？y
***将快照恢复到原文件的位置，此时可以看出快照做完后新增的message没有恢复，可见要新增快照才能恢复message 
[root@lcfyl media]# tar xf /tmp/testlv.tar.bz2 -C ./（-C表示解压到另外的路径，默认当前路径）
[root@lcfyl media]# ls 
inittab  issue  lost+found
[root@lcfyl media]# 

练习：创建一个由两个物理卷组成的大小为20G的卷组myvg，要求其PE大小为16M；而后在此卷组中创建一个大小为5G的逻辑卷lv1，
此逻辑卷要能在开机后自动挂载至/users目录，且支持ACL功能；缩减前面创建的逻辑卷lv1的大小至2G；
vgcreate VG_NAME /PATH/TO/PV
	-s #: PE大小，默认为4MB
	
lvcreate -n LV_NAME -L #G VG_NAME

练习：镜像LVM
[root@localhost ~]# pvs
  PV         VG   Fmt  Attr PSize  PFree 
  /dev/sda2  myvg lvm2 a--  10.00g 10.00g
  /dev/sda3       lvm2 ---  10.00g 10.00g
[root@localhost ~]# vgs
  VG   #PV #LV #SN Attr   VSize  VFree 
  myvg   1   0   0 wz--n- 10.00g 10.00g
[root@localhost ~]# vgextend myvg /dev/sda3
  Volume group "myvg" successfully extended
[root@localhost ~]# pvs
  PV         VG   Fmt  Attr PSize  PFree 
  /dev/sda2  myvg lvm2 a--  10.00g 10.00g
  /dev/sda3  myvg lvm2 a--  10.00g 10.00g
***现在只有20G的PV，如果是镜像只有50%的利用率
  [root@localhost ~]# lvcreate -m1 -L 20G -n myvg_lv myvg
  Volume group "myvg" has insufficient free space (5118 extents): 5120 requ
ired.[root@localhost ~]# lvcreate -m1 -L 10G -n myvg_lv myvg
  Insufficient free space: 5122 extents needed, but only 5118 available
[root@localhost ~]# lvcreate -m1 -L 9G -n myvg_lv myvg
  Logical volume "myvg_lv" created.
[root@localhost ~]#
[root@localhost ~]# lvs -a -o +devices
  LV                 VG   Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices                                
  myvg_lv            myvg rwi-a-r--- 9.00g                                    100.00           myvg_lv_rimage_0(0),myvg_lv_rimage_1(0)
  [myvg_lv_rimage_0] myvg iwi-aor--- 9.00g                                                     /dev/sda2(1)                           
  [myvg_lv_rimage_1] myvg iwi-aor--- 9.00g                                                     /dev/sda3(1)                           
  [myvg_lv_rmeta_0]  myvg ewi-aor--- 4.00m                                                     /dev/sda2(0)                           
  [myvg_lv_rmeta_1]  myvg ewi-aor--- 4.00m                                                     /dev/sda3(0)                           
[root@localhost ~]#
*损坏一个
[root@localhost ~]# dd if=/dev/zero of=/dev/sda3 bs=512 count=2
2+0 records in
2+0 records out
1024 bytes (1.0 kB) copied, 0.000184267 s, 5.6 MB/s
[root@localhost ~]#
[root@localhost ~]# lvs -a -o +devices
  WARNING: Device for PV dN8sWl-oO6R-Xy80-nvX5-AS63-h6fq-8ZJlD9 not found or rejected by a filter.
  WARNING: Device for PV dN8sWl-oO6R-Xy80-nvX5-AS63-h6fq-8ZJlD9 not found or rejected by a filter.
  LV                 VG   Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices                                
  myvg_lv            myvg rwi-a-r-p- 9.00g                                    100.00           myvg_lv_rimage_0(0),myvg_lv_rimage_1(0)
  [myvg_lv_rimage_0] myvg iwi-aor--- 9.00g                                                     /dev/sda2(1)                           
  [myvg_lv_rimage_1] myvg iwi-aor-p- 9.00g                                                     unknown device(1)                      
  [myvg_lv_rmeta_0]  myvg ewi-aor--- 4.00m                                                     /dev/sda2(0)                           
  [myvg_lv_rmeta_1]  myvg ewi-aor-p- 4.00m                                                     unknown device(0)                      
[root@localhost ~]# 
[root@localhost ~]# vgs
  WARNING: Device for PV dN8sWl-oO6R-Xy80-nvX5-AS63-h6fq-8ZJlD9 not found or rejected by a filter.  
  WARNING: Device for PV dN8sWl-oO6R-Xy80-nvX5-AS63-h6fq-8ZJlD9 not found or rejected by a filter.
  VG   #PV #LV #SN Attr   VSize  VFree
  myvg   2   1   0 wz-pn- 19.99g 1.98g
[root@localhost ~]# pvs
  WARNING: Device for PV dN8sWl-oO6R-Xy80-nvX5-AS63-h6fq-8ZJlD9 not found or rejected by
 a filter.  WARNING: Device for PV dN8sWl-oO6R-Xy80-nvX5-AS63-h6fq-8ZJlD9 not found or rejected by
 a filter.  PV             VG   Fmt  Attr PSize  PFree   
  /dev/sda2      myvg lvm2 a--  10.00g 1016.00m
  unknown device myvg lvm2 a-m  10.00g 1016.00m
[root@localhost ~]#
[root@localhost ~]# vgreduce --removemissing myvg --force
  WARNING: Device for PV dN8sWl-oO6R-Xy80-nvX5-AS63-h6fq-8ZJlD9 not found or rejected by
 a filter.  WARNING: Device for PV dN8sWl-oO6R-Xy80-nvX5-AS63-h6fq-8ZJlD9 not found or rejected by
 a filter.  Wrote out consistent volume group myvg
[root@localhost ~]#
*解除lv层镜像
[root@localhost ~]# lvconvert -m0 /dev/myvg/myvg_lv
[root@localhost ~]# lvs -a -o +devices
  LV      VG   Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices     
  myvg_lv myvg -wi-a----- 9.00g                                                     /dev/sda2(1)
[root@localhost ~]#
*加PV自动修复
[root@localhost ~]# pvcreate /dev/sda4
  Physical volume "/dev/sda4" successfully created
[root@localhost ~]# pvs
  PV         VG   Fmt  Attr PSize  PFree   
  /dev/sda2  myvg lvm2 a--  10.00g 1020.00m
  /dev/sda4       lvm2 ---  10.00g   10.00g
[root@localhost ~]# vgextend myvg /dev/sda4
  Volume group "myvg" successfully extended
[root@localhost ~]# lvconvert -m1 /dev/myvg/myvg_lv 
[root@localhost ~]# lvs -a -o +devices
  LV                 VG   Attr       LSize Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert Devices                                
  myvg_lv            myvg rwi-aor--- 9.00g                                    4.17             myvg_lv_rimage_0(0),myvg_lv_rimage_1(0)
  [myvg_lv_rimage_0] myvg Iwi-aor--- 9.00g                                                     /dev/sda2(1)                           
  [myvg_lv_rimage_1] myvg Iwi-aor--- 9.00g                                                     /dev/sda4(1)                           
  [myvg_lv_rmeta_0]  myvg ewi-aor--- 4.00m                                                     /dev/sda2(0)                           
  [myvg_lv_rmeta_1]  myvg ewi-aor--- 4.00m                                                     /dev/sda4(0)                           
[root@localhost ~]#



进入循环：条件满足
退出循环：条件不满足
while CONDITION; do
  statment
done
		
until CONDITION; do
  statement
  ...
done

#!/bin/bash
#
who | grep "hadoop" &> /dev/null
RETVAL=$?

until [ $RETVAL -eq 0 ];do
  echo "hadoop has not come"
  sleep 5
  who | grep "hadoop"  &> /dev/null
  RETVAL=$?
done
echo "hadoop has logged in "
***以上代码可以简化成下面代码，while、if等条件引导句都可以这种格式
until who | grep "hadoop" &> /dev/null;do
    echo "hadoop has not come"
    sleep 5
done
echo "hadoop has logged in"

break: 提前退出循环
continue：提前结束本轮循环，而进入下一轮循环；

while的特殊用法一：
***死循环
while :;do
	结构体
done

while的特殊用法二：
while read LINE; do
	结构体
done < /PATH/TO/SOMEFILE

例：
#!/bin/bash
FILE=/etc/passwd
let I=0
while read LINE;do
	[ `echo $LINE | awk -F : '{print $3}'` -le 499 ] && continue
	[ `echo $LINE | awk -F : '{print $7}'` = '/bin/bash' ] && echo $LINE | awk -F : '{print $1}' && let I++
	[ $I -eq 6 ] && break
done < $FILE


for 变量 in 列表; do 
	循环体
done
		
for (( expr1 ; expr2 ; expr3 )); do 
  循环体
done

#!/bin/bash
declare -i sum1=0
for I in {1..100};do
  let sum1+=$I
done
echo $sum1

***两种表达都可以，下面的一个和Java很像
declare -i sum2=0
for ((J=1;J<=100;J++));do
  let sum2+=$J
done
echo $sum2


写一个脚本：
1、通过ping命令测试192.168.0.151到192.168.0.254之间的所有主机是否在线，
	如果在线，就显示"ip is up."，其中的IP要换为真正的IP地址，且以绿色显示；
	如果不在线，就显示"ip is down."，其中的IP要换为真正的IP地址，且以红色显示；

要求：分别使用while，until和for(两种形式)循环实现。
ping
	-c
	-W
#!/bin/bash
#
declare -i i=1
declare ipaddr="192.168.3.$i"
while [ $i -le 29 ];do
     if ping -c 1 $ipaddr  &> /dev/null;then

         echo -e "\033[32m$ipaddr is up\033[0m"
     else
         echo -e "\033[31m$ipaddr is not  up\033[0m"
     fi
         let i++
declare ipaddr="192.168.3.$i"
done


awk 'PATTERN{ACTION}' file
	print $1

[root@lcfyl ~]# df -Ph |awk '{print $1}'
文件系统
/dev/mapper/vg_lcfyl-lv_root
tmpfs
/dev/sda1

***$NF 指最后一个字段
[root@lcfyl ~]# df -Ph |awk '{print $NF}'
挂载点
/
/dev/shm
/boot

***-F指定定界符，默认为空格
[root@lcfyl ~]# awk -F: '{print $1,$3}' /etc/passwd
root 0
bin 1
daemon 2
adm 3
lp 4
sync 5
shutdown 6
halt 7

写一个脚本(前提：请为虚拟机新增一块硬盘，假设它为/dev/sdb)，为指定的硬盘创建分区：
1、列出当前系统上所有的磁盘，让用户选择，如果选择quit则退出脚本；如果用户选择错误，就让用户重新选择；
2、当用户选择后，提醒用户确认接下来的操作可能会损坏数据，并请用户确认；如果用户选择y就继续，n就退出；否则，让用户重新选择；
3、抹除那块硬盘上的所有分区(提示，抹除所有分区后执行sync命令，并让脚本睡眠3秒钟后再分区)；并为其创建三个主分区，第一个为20M，
第二个为512M, 第三个为128M，且第三个为swap分区类型；(提示：将分区命令通过echo传送给fdisk即可实现)

#!/bin/bash
#
echo "Initial a disk..."
echo -e "\033[31mWarning:\033[0m"
fdisk -l 2> /dev/null | grep -o "^Disk /dev/[sh]d[a-z]"


read -p "your choice:" PARTDISK

if [ $PARTDISK == "quit" ]; then
        echo "quit"
        exit 7
fi

until fdisk -l 2> /dev/null | grep -o "^Disk /dev/[sh]d[a-z]" | grep "^Disk $PARTDISK$" &> /dev/null;do
        read -p "Wrong option, your choice again:" PARTDISK
done

read -p "Will destroy all data, continue:" CHOICE
until [ $CHOICE == "y" -o $CHOICE == "n" ];do
read -p "Will destroy all data, continue:" CHOICE
done
if [ $CHOICE == 'n' ];then
        echo "Quit"
        exit 9
else
dd if=/dev/zero of=$PARTDISK bs 512 count=1 &> /dev/null
sync
sleep 3
echo "n
p
1

+20M
n
p
2

+512M
n
p
3

+128M
t
3
82
w" | fdisk $PARTDISK &> /dev/null
sleep 2
partprobe $PARTDISK
sync
sleep 2
mke2fs -j ${PARTDISK}1 &> /dev/null
mke2fs -j ${PARTDISK}2 &> /dev/null
mkswap ${PARTDISK}3 &> /dev/null
fi


A类: 255.0.0.0， 8：
	0 000 0001 - 0 111 1111 
	127个A类，127用于回环，1-126
	2^7-1个A类
	容纳多少个主机：2^24-2
	主机位全0：网络地址
	主机位全1：广播地址
B类：255.255.0.0， 16
	10 00 0000- 10 11 1111
	128-191
	129.1.0.0.
	130.1.0.0
	64个B类，2^14个B类网
	容纳多少个主机:2^16-2
C类：255.255.255.0， 24
	110 0 0000 - 110 1 1111
	192-223
	32个C类, 2^21个C类网
	容纳多个少个主机：2^8-2

私有地址：
	A类：10.0.0.0/8
	B类：172.16.0.0/16-172.31.0.0/16
	C类：192.168.0.0/24-192.168.255.0/24

ifconfig [ethX] 
	-a: 显示所有接口的配置住处
	
ifconfig ethX IP/MASK [up|down] 
	配置的地址立即生效，但重启网络服务或主机，都会失效；
	
网络服务：
RHEL5:	/etc/init.d/network {start|stop|restart|status}
RHEL6: /etc/init.d/NetworkManager {start|stop|restart|status}

网关：
route 
	add: 添加
		-host: 主机路由
		-net：网络路由
			-net 0.0.0.0
	route add -net|-host DEST gw NEXTHOP
	route add default gw NEXTHOP


del：删除
	-host
	-net 
	
	route del -net 10.0.0.0/8 
	route del -net 0.0.0.0
	route del default

	所做出的改动重启网络服务或主机后失效；
路由：
/etc/sysconfig/network-scripts/route-ethX
添加格式一：
DEST	via 	NEXTHOP

添加格式二：
ADDRESS0=
NETMASK0=
GATEWAY0=

网络接口配置文件：
/etc/sysconfig/network-scripts/ifcfg-INTERFACE_NAME
DEVICE=: 关联的设备名称，要与文件名的后半部“INTERFACE_NAME”保持一致; 
BOOTPROTO={static|none|dhcp|bootp}: 引导协议；要使用静态地址，使用static或none；dhcp表示使用DHCP服务器获取地址；
IPADDR=: IP地址
NETMASK=：子网掩码
GATEWAY=：设定默认网关；
ONBOOT=：开机时是否自动激活此网络接口；
HWADDR=： 硬件地址，要与硬件中的地址保持一致；可省；
USERCTL={yes|no}: 是否允许普通用户控制此接口；
PEERDNS={yes|no}: 是否在BOOTPROTO为dhcp时接受由DHCP服务器指定的DNS地址；

不会立即生效，但重启网络服务或主机都会生效；

DNS服务器指定方法只有一种：
/etc/resolv.conf
nameserver DNS_IP_1
nameserver DNS_IP_2

指定本地解析：
/etc/hosts
主机IP	主机名	主机别名
172.16.0.1		www.magedu.com		www

配置主机名：
hostname HOSTNAME
立即生效，但不是永久有效；

要想永久有效要改配置文件
/etc/sysconfig/network
HOSTNAME=
NETWORKING=yes：这是网络总开关，改为no就不能用网络

RHEL5：
	setup: system-config-network-tui
	system-config-network-gui

iproute2：这是一个强大的软件包，有以下常用命令
	ip
		link: 网络接口属性
		addr: 协议地址
		route: 路由

		link
			show
				#ip -s link show
			set
				#ip link set DEV {up|down}
				
		addr
			add
				#ip addr add ADDRESS dev DEV
				#ip addr add ADDRESS/MASK brd + dev enp0s3
					brd：broadcast广播地址, "+"代表内核自己计算
				#ip addr add 192.168.1.11/24 brd + dev enp0s3 label enp0s3:0
				#ip addr add 192.168.1.11/24 brd + dev enp0s3 label enp0s3:ly
			del
				#ip addr del ADDRESS dev DEV
			show
				#ip addr show dev DEV to PREFIX：指定前缀，以PREFIX开头的都显示出来
			flush
				#ip addr flush dev DEV to PREFIX
[root@lcfyl ~]# ip addr add 10.0.0.1 dev eth0
[root@lcfyl ~]# ip addr show
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UNKNOWN qlen 1000
    link/ether 00:0c:29:1b:54:b9 brd ff:ff:ff:ff:ff:ff
    inet 192.168.3.123/24 brd 192.168.3.255 scope global eth0
    inet 10.0.0.1/32 scope global eth0
    inet6 fe80::20c:29ff:fe1b:54b9/64 scope link 
       valid_lft forever preferred_lft forever
[root@lcfyl ~]# ping 10.0.0.1
PING 10.0.0.1 (10.0.0.1) 56(84) bytes of data.
64 bytes from 10.0.0.1: icmp_seq=1 ttl=64 time=0.089 ms
64 bytes from 10.0.0.1: icmp_seq=2 ttl=64 time=0.047 ms
		
		
一块网卡可以使用多个地址：
网络设备可以别名：
eth0
	ethX:X, eth0:0, eth0:1, ...
***在集群中一个网卡接口要配多个IP地址的时候可以用下列方法	
配置方法：
	ifconfig ethX:X IP/NETMASK
	
	/etc/sysconfig/network-scripts/ifcfg-ethX:X
	DEVICE=ethX:X

	非主要地址不能使用DHCP动态获取; 

ip
	eth1, 添加个地址192.168.100.1
	
ip addr add 192.168.100.1/24 dev eth1 label eth1:0
primary address
secondary adress


路由:
route add -net 10.0.1.0/24 gw 192.168.100.6
ip route add to 10.0.1.0/24 dev eth1 via 192.168.100.6
	add, change, show, flush, replace
	
ifconfig eth0, 172.16.200.33/16
ifconfig eth0:0 172.16.200.33/16

TCP:
	URG 
	SYN
	ACK
	PSH
	RST
	FIN
-------------------------------------------------------------
-------------------------------------------------------------
RHEL7以后的变化
-------------------------------------------------------------
systemd接口命名规则：自上而下进行方案备用
eno1:
	合并固件或者BIOS的名称为板载设备或嵌入式设备提供索引号
ens1:
	合并固件或者BIOS的名称为PCI热插拔设备提供索引号
enp0s1:
	合并硬件连接器物理位置的名称
enx78e7d1ea46da:
	合并接口MAC地址的名称
eth0:
	以上都失败，则用传统的不可预测内核属性ehtX命名
	
***如果系统启用了biosdevname或者udev rules，则系统会用这些规则替代systemd
   如：将net.ifnames=0 biosdevname=0传递给内核，grub2-mkconfig -o /boot/grub2/grub.cfg
   则修改ifcf-***会成为自己指定的
***/etc/resolve文件会被networdmanager更改，所以自定义的不能保存
	nmcli con mod enp0s3 ipv4.ignore-auto-dns yes
		可以将enp0s3配置文件PEERDNS改成no
udev之间是通过makedev的脚本生成大量潜在的dev设备作为备用，进而调用mknod生成主次设备放在/dev目录下
而udev则可以动态加载设备，只创建内核探测到的设备，而它们会被贮存在ramfs中，一个内存中的文件系统，
不占用任何磁盘空间，并且占用的内存也基本可以忽略
NetworkManager：支持更多网络设备
	GSM、UMTS、CDMA等称动宽带设备
	支持蓝牙PAN、DUN
	支持IPv6自动配置和静态IP
	nmcli：每执行一次nmcli都直接对网络设备配置文件进行直接更改
		支持缩写方式
			connection=conn
			disconection=dis
			delete=del
			modify=mod
			...
	nmcli dev status         列出所有设备
	nmcli con show           列出所有连接设备
	nmcli con show --active  列示所有活动的设备
	nmcli con up "<ID>"      启用设备，ID为设备的逻辑标识名（此名自定义）
	nmcli con down "<ID>"    关闭设备，但如果服务重启将会再次激活此设备
	nmcli dev dis <DEV>      关闭设备，如需激活设备需手工激活
	nmcli con add....        添加一个新的链接
	nmcli con mod....        修改一个现有的链接
	nmcli con del....        删除一个现有的链接
	nmcli net off....        关闭所有的被管理的网络设备
		default(enp0s3)
		#nmcli dev wifi 查看所有无线网络信息
		#nmcli -p con show enp0s3
		#nmcli con add con-name "default" type ethernet ifname enp0s3
			修改指定的设备名称
		#nmcli con show default
			验证
		#nmcli con add con-name "default" ifname enp0s3 autoconnect no type ethernet ip4 192.168.100.1/24 gw4 192.168.100.254
			为指定网络设备添加网络地址/子网
				ip4：ipv4地址 gw4：ipv4网关地址
				autoconnect：不随Linux启动而激活接口
		#nmcli con up "default"
			启动配置完的网络设备
		#nmcli dev disconnect enp0s3
			断开链接
		#nmcli con mod "default" connection.autoconnect no
			自启动改为不自启动
		#nmcli con mod "default" ipv4.dns 8.8.8.8
			增加ipv4的DNS
		#nmcli con mod "default" + ipv4.dns 9.9.9.9
			增加第2个DNS
		#nmcli con mod "default" ipv4.address "192.168.10.1/24 192.168.10.254"
			修改default的IP地址及网关
		
		#nmcli con mod "default" + ipv4.address "192.168.10.1/24"
		#nmcli con delete delete default
			删除现有一个链接文件
		#nmcli con mod "default" ipv4.dns "202.106.148.1 202.106.0.20"
			同时给两个IP地址
		-------------------------------------------------------------------
		-------------------------------------------------------------------
		#nmcli dev wifi list
			列出当前区域的wifi
		方法一：
		#nmcli con add con-name myhome ifname wlan0 type wifi ssid wifi2ly ip4 192.168.1.1/24 gw4 192.168.1.1
			对wlan0进行配置
		#nmcli con modify myhome wifi-sec.key-mgmt wpa-psk
			设定wifi的安全类型
		#nmcli con modify myhome wifi-sec.psk sdfasdfasdfsa
			设定wifi的密码
		方法二：
		#nmcli dev wifi con "wifi2ly" password asdfasdfasdf name 'myhome'
			或者nmcli dev wifi con 'wifi2ly' passsword asdfaasdf ifname wlan0
		#nmcli con mod if 'myhome' 802-11-wireless.mtu 1350
			指定WIFI链接的MTU
		#nmcli con reload
			重读取所有的网络设备配置文件
		--------------------------------------------------------------------------
		--------------------------------------------------------------------------
		#man nm-settings
		#nmcli con add help
			查看帮助
		#man nmcli-examples
			查看模板
		



软件包管理

应用程序：
	程序，Architecture
应用程序存放位置：
	二进制程序：
		/bin, /sbin
		/usr/bin, /usr/sbin:
		/usr/local/bin, /usr/local/sbin:
	库文件：
		/lib, /usr/lib
		***注意库文件由很多人开发供调用，有时系统找不到库文件，而是依赖以下配置文件指明路径
		/etc/ld.so.conf, /etc/ld.so.conf.d/*.conf
		***当不同人之前相互调用彼此开发的库文件时，会出现由于库文件格式不统一而无法识别，无法调用的情况
		   此时必须要有一个配置文件辅助
		/usr/include 头文件：指明涵数的格式参数等信息供别人明确参考进而调用
	配置文件：
		/etc
		如：/etc/httpd/
	帮助文件：
		/usr/share/man
			/etc/man.config ***系统同样需要配置文件指明的路径
		/usr/share/doc
操作系统主要组成：kernel, glibc（公共库或者标准库）,app
	
C语言：源代码-->（编译）二进制格式
脚本：解释器（二进制程序）

源代码-->编译-->链接-->运行


程序组成部分：
	二进制程序
	库
	配置文件
	帮助文件
	
/boot
/etc
/usr
/var
/dev
/lib
/tmp
/bin
/sbin
/proc
/sys
/mnt
/media
/home
/root
/misc
/opt
/srv

/etc, /bin, /sbin, /lib
	系统启动就需要用到的程序，这些目录不能挂载额外的分区，必须在根文件系统的分区上
	

/usr/
	bin
	sbin
	lib
	
	操作系统核心功能，可以单独分区，2.4内核以后很多程序也移植到了此目录文件下，最好不分区
	
/usr/local
	bin
	sbin
	lib
	etc
	man
	安装系统之后第三方软件，与操作系统和核心功能没有关系，尽量独立分区，将这种分区挂
	载在别的主机系统下完全可以独立运行，因为/usr/local是一个独立王国

/opt：早先第三方软件安装在此目录下，现在统一在/usr/local下

/proc、/sys
	内核映射必备，不能单独分区，默认为空；
	
/dev: 设备，不能单独分区；
	udev：后来内核更进此设备文件的存在可以完全通过驱动按需分配，不再像/dev那样系统启动后就将所有设备都预备好，浪费资源
	
/root: 不能单独分区

/var：建议单独分区

/boot：内核，initrd(initramfs)

POST-->BIOS(HD)-->(MBR)bootloader(文件系统结构，ext2, ext3, xfs)-->内核


软件包管理器的核心功能：
1、制作软件包；
2、安装、卸载、升级、查询、校验；

Redhat, SUSE, Debian

Redhat, SUSE: RPM
	Redhat Package Manager
	RPM is Package Manager
Debian: dpt

依赖关系：
	X-->Y-->Z
	
	X-->Y-->Z-->Y
	
前端工具：yum, apt-get
后端工具：RPM, dpt

yum: Yellowdog Update Modifier
	yum


rpm命令：
	rpm:
		数据库:/var/lib/rpm
	rpmbuild:
	
安装、查询、卸载、升级、校验、数据库的重建、验正数据包等工作；

rpm命名：
包：组成部分
	主包：
		bind-9.7.1-1.el5.i586.rpm
	子包：
		bind-libs-9.7.1-1.el5.i586.rpm
		bind-utils-9.7.1-1.el5.i586.rpm
包名格式：
	name-version-release.arch.rpm
	bind-major.minor.release-release.arch.rpm

主版本号：重大改进
次版本号：某个子功能发生重大变化
发行号：修正了部分bug，调整了一点功能

bind-9.7.1.tar.gz	

rpm包：
	二进制格式
		rpm包作者下载源程序，编译配置完成后，制作成rpm包
		bind-9.7.1-1.noarch.rpm
		bind-9.7.1-1.ppc.rpm

rpm:

1、安装
rpm包中包含的内容：
	要安装的文件：
	要执行的脚本：
		pre：安装前要执行的脚本
		post：安装后要执行的脚本
		preun：卸载前要执行的脚本
		postun：卸载后要执行的脚本

rpm -i /PATH/TO/PACKAGE_FILE
	-h: 以#显示进度；每个#表示2%; 
	-v: 显示详细过程
	-vv: 更详细的过程
	
rpm -ivh /PATH/TO/PACKAGE_FILE

	--nodeps: 忽略依赖关系；
	--replacepkgs: 重新安装，替换原有安装；
	--force: 强行安装，可以实现重装或降级；
	--test：测试安装，不真正安装
2、查询
rpm -q PACKAGE_NAME： 查询指定的包是否已经安装
rpm -qa : 查询已经安装的所有包

rpm -qi PACKAGE_NAME: 查询指定包的说明信息；
rpm -ql PACKAGE_NAME: 查询指定包安装后生成的文件列表；
rpm -qc PACEAGE_NEME：查询指定包安装的配置文件；
rpm -qd PACKAGE_NAME: 查询指定包安装的帮助文件；

rpm -q --scripts PACKAGE_NAME: 查询指定包中包含的脚本
	
rpm -qf /path/to/somefile: 查询指定的文件是由哪个rpm包安装生成的；
	
如果某rpm包尚未安装，我们需查询其说明信息、安装以后会生成的文件；
rpm -qpi /PATH/TO/PACKAGE_FILE
rpm -qpl 

3、升级
rpm -Uvh /PATH/TO/NEW_PACKAGE_FILE: 如果装有老版本的，则升级；否则，则安装；
rpm -Fvh /PATH/TO/NEW_PACKAGE_FILE：如果装有老版本的，则升级；否则，退出；
	--oldpackage: 降级
	
4、卸载
rpm -e PACKAGE_NAME
	--nodeps
	
5、校验
	rpm -V PACKAGE_NAME：检验包是否完整，缺少什么文件，有没有什么文件被改动过
	rpm -K PACKAGE_NAME：检查包签名，如下诠释
6、重建数据库（/var/lib/rpm）
[root@lcfyl Packages]# ls -l /var/lib/rpm/
总用量 28352
-rw-r--r--. 1 root root  2650112  3月 18 20:55 Basenames
-rw-r--r--. 1 root root    12288  1月 23 00:15 Conflictname
-rw-r--r--. 1 root root    24576  3月 28 05:10 __db.001
-rw-r--r--. 1 root root   188416  3月 28 05:10 __db.002
-rw-r--r--. 1 root root  1318912  3月 28 05:10 __db.003
-rw-r--r--. 1 root root   491520  3月 28 05:10 __db.004
-rw-r--r--. 1 root root   462848  3月 18 20:55 Dirnames
-rw-r--r--. 1 root root  2654208  3月 18 20:55 Filedigests
-rw-r--r--. 1 root root    16384  3月 28 05:10 Group
-rw-r--r--. 1 root root    16384  3月 28 05:10 Installtid
-rw-r--r--. 1 root root    40960  3月 28 05:10 Name
-rw-r--r--. 1 root root    12288  1月 23 00:15 Obsoletename
-rw-r--r--. 1 root root 21049344  3月 28 05:10 Packages
-rw-r--r--. 1 root root   737280  3月 28 05:10 Providename
-rw-r--r--. 1 root root   524288  3月 28 05:10 Provideversion
-rw-r--r--. 1 root root    12288  3月 28 05:10 Pubkeys
-rw-r--r--. 1 root root   208896  3月 18 20:55 Requirename
-rw-r--r--. 1 root root   147456  3月 18 20:55 Requireversion
-rw-r--r--. 1 root root    86016  3月 18 20:55 Sha1header
-rw-r--r--. 1 root root    45056  3月 18 20:55 Sigmd5
-rw-r--r--. 1 root root    12288  1月 23 00:15 Triggername

	rpm 
		--rebuilddb: 重建数据库，一定会重新建立；
		--initdb：初始化数据库，没有才建立，有就不用建立；


7、检验来源合法性，及软件包完整性；
加密类型：
	对称：加密解密使用同一个密钥
	公钥：一对儿密钥，公钥，私钥；公钥隐含于私钥中，可以提取出来，并公开出去；
	rpm包签名：提取特征码，附加在软件包上；使用自己的私钥加密此特征码；
	验证签名：
		用官方的公钥解密这段加密的特征码，得到可靠的官方提供的特征码；
		自己再使用同样的方法提取特征码，并比较和解密出来的特征码是否一致；
	单向加密，散列加密：提取数据特征码，常用于数据完整性校验
		1、雪崩效应
		2、定长输出
			MD5：Message Digest, 128位定长输出
			SHA1：Secure Hash Algorithm, 160位定长输出	
	
*发送方用自己的私钥加密数据，可以实现身份验证
*发送方用对方的公钥加密数据，可以保证数据机密性
PKI: Public Key Infrastructure
CA: Certificate Authority
证书格式：x509, pkcs12
x509（通行的格式）：包括1、公钥及其有效期限 2、证书的合法拥有者 3、证书该如何被使用
			4、CA的信息 5、CA签名的校验码
PKI现在实现的管理机制有：TLS(Transport Layer Security)和SSL(x509)
PKI: OpenPG
对称加密：
	DES：Data Encription Standard, 56bit
	3DES: 三重DES
	AES：Advanced Encription Standard
		AES192, AES256, AES512（越长速度越慢）
	Blowfish
单向加密：
	MD4
	MD5
	SHA1
	SHA192, SHA256, SHA384（指的是输出长度）
	CRC-32：只是一种校验码机制，没什么安全机制

公钥加密：加密、签名
	身份认证（数字签名）
	数据加密
	密钥交换
		RSA：即可以加密又能签名
		DSA：只能实现签名
		ELGamal：商业算法，要钱的
OpenSSL: ssl的开源实现，功能强大
	三部分组成：
		libcrypto: 加密库
		libssl: TLS/SSL的实现
			基于会话的、实现了身份认证、数据机密性的会话完整性的TLS/SSL库
		openssl: 多用途命令行工具
			模拟实现私有证书颁发机构
			很多子命令
				[root@RHEL5 ~]# openssl speed des
				Doing des cbc for 3s on 16 size blocks: 6908673 des cbc's in 2.85s
				Doing des cbc for 3s on 64 size blocks: 1758401 des cbc's in 2.87s
				Doing des cbc for 3s on 256 size blocks: 440491 des cbc's in 2.88s
				
				[root@RHEL5 ~]# whatis passwd
				passwd               (1)  - update a user's authentication tokens(s)
				passwd               (5)  - password file
				passwd              (rpm) - The passwd utility for setting/changing passwords using PAM
				passwd [sslpasswd]   (1ssl)  - compute password hashes
				[root@RHEL5 ~]# man sslpasswd

				[root@RHEL5 ~]# cp /etc/inittab ./
				[root@RHEL5 ~]# openssl enc -des3 -salt -a -in inittab -out inittab.des3
				enter des-ede3-cbc encryption password:
				Verifying - enter des-ede3-cbc encryption password:
				[root@RHEL5 ~]# 
				[root@RHEL5 ~]# openssl enc -des3 -d -salt -a -in inittab.des3 -out inittab
				enter des-ede3-cbc decryption password:
				[root@RHEL5 ~]# cat inittab
				***查看特征码
				[root@RHEL5 ~]# openssl dgst -sha1 inittab
				SHA1(inittab)= 78ef239097844c223671e99a79d6b533dced8d3b
				[root@RHEL5 ~]# sha1sum inittab
				78ef239097844c223671e99a79d6b533dced8d3b  inittab
				[root@RHEL5 ~]# openssl dgst -md5 inittab
				MD5(inittab)= 92a39a223f68e67e9e6c412443851aeb
				[root@RHEL5 ~]# md5sum inittab
				92a39a223f68e67e9e6c412443851aeb  inittab
				
				***加密一段密码，默认加过salt
				[root@RHEL5 ~]# openssl passwd -1
				Password: 
				Verifying - Password: 
				$1$oj3oKtyb$0Sn8XB6YM7yTM.kBYxJTF/
				[root@RHEL5 ~]# openssl passwd -1
				Password: 
				Verifying - Password: 
				$1$PVifRx3F$56BEzYAwkHiMhT1QS011m.
				[root@RHEL5 ~]# openssl passwd -1 -salt oj3oKtyb
				Password: 
				$1$oj3oKtyb$0Sn8XB6YM7yTM.kBYxJTF/
				[root@RHEL5 ~]# 


1、创建CA
	自己生成一对密钥：
	生成自签证书：
2、客户端
	生成一对密钥：
	生成证书颁发请求，.csr：
	将请求发给CA：
3、CA端
	签署此证书：
	传送给客户端：
openssl: 实现私有CA
1、生成一对密钥
2、生成自签署证书
	openssl genrsa -out /PATH/TO/KEYFILENAME NUMBITS
	openssl rsa -in /PATH/TO/KEYFILENAME -pubout（从私钥中提取出公钥）

***公钥私钥的生成方法
[root@RHEL5 ~]# (umask 077; openssl genrsa -out server.key 1024)
Generating RSA private key, 1024 bit long modulus
...........++++++
..............++++++
e is 65537 (0x10001)
[root@RHEL5 ~]# ls -l
total 7428
-rw------- 1 root root     887 Apr 14 14:25 server.key
[root@RHEL5 ~]# umask 
0022
[root@RHEL5 ~]# openssl rsa -in server.key -pubout
writing RSA key
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDRXaqHKQVDfcOyGWSfYVUnZxKS
P2Jg072Cw4ONI7nhkvBsFii78DjEVTzh7lyExLCcrnYH+3VxA8SAsZ41KcmbOZeP
lREaZ3vvJorH6dcbsmOXZaZDukBrb+C6wE8OKbDYnhF8PbVmHzlcX8Hoh04jAjji
a8LbOjQkDJmPGkO/owIDAQAB
-----END PUBLIC KEY-----
[root@RHEL5 ~]# 

全步骤：先改一下配置文件的默认选项，等到生成的时候就不用指定
[root@RHEL5 ~]# vim /etc/pki/tls/openssl.cnf 
dir             = /etc/pki/CA           # Where everything is kept
countryName_default             = CN
stateOrProvinceName_default     = HuBei
localityName_default            = WuHan
0.organizationName_default      = MageEdu
organizationalUnitName_default  =Tech
[root@RHEL5 ~]# cd /etc/pki/CA/
[root@RHEL5 CA]# (umask 077; openssl genrsa -out private/cakey.pem 2048)
Generating RSA private key, 2048 bit long modulus
.......+++
...............................................+++
e is 65537 (0x10001)
[root@RHEL5 CA]# ls -l private/
total 8
-rw------- 1 root root 1679 Apr 14 15:05 cakey.pem

***使用-x509表示生成自签署证书，如果是向服务器申请就不要-x509
[root@RHEL5 CA]# openssl req -new -x509 -key private/cakey.pem -out cacert.pem
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [CN]:
State or Province Name (full name) [HuBei]:
Locality Name (eg, city) [WuHan]:
Organization Name (eg, company) [MageEdu]:
Organizational Unit Name (eg, section) [Tech]:
Common Name (eg, your name or your server's hostname) []:magedu.com
Email Address []:caadminmagedu.com
[root@RHEL5 CA]# mkdir certs newcerts crl
[root@RHEL5 CA]# ls
cacert.pem  certs  crl  newcerts  private
[root@RHEL5 CA]# touch index.txt
[root@RHEL5 CA]# touch serial
[root@RHEL5 CA]# echo "01" > serial
[root@RHEL5 CA]# ls
cacert.pem  certs  crl  index.txt  newcerts  private  serial
[root@RHEL5 CA]# 
[root@RHEL5 CA]# cd
[root@RHEL5 ~]# mkdir /etc/httpd
[root@RHEL5 ~]# cd /etc/httpd/
[root@RHEL5 httpd]# mkdir ssl
[root@RHEL5 httpd]# cd ssl/
[root@RHEL5 ssl]# (umask 077; openssl genrsa -out httpd.key 1024)
Generating RSA private key, 1024 bit long modulus
...............++++++
.........++++++
e is 65537 (0x10001)

***申请书都是自己填的，CA最后只审核盖章即可
[root@RHEL5 ssl]# openssl req -new -key httpd.key -out httpd.csr 
You are about to be asked to enter information that will be incorporated
into your certificate request.
What you are about to enter is what is called a Distinguished Name or a DN.
There are quite a few fields but you can leave some blank
For some fields there will be a default value,
If you enter '.', the field will be left blank.
-----
Country Name (2 letter code) [CN]:
State or Province Name (full name) [HuBei]:
Locality Name (eg, city) [WuHan]:
Organization Name (eg, company) [MageEdu]:
Organizational Unit Name (eg, section) [Tech]:
Common Name (eg, your name or your server's hostname) []:www.magedu.com
Email Address []:www.adminmagedu.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
[root@RHEL5 ssl]# ls
httpd.csr  httpd.key

***这个实验是在同一台主机上的，可以直接签署，如果向服务器请求则一定要将写好的证书发送给服务器
[root@RHEL5 ssl]# openssl ca -in httpd.csr -out httpd.crt -days 365
Using configuration from /etc/pki/tls/openssl.cnf
Check that the request matches the signature
Signature ok
Certificate Details:
        Serial Number: 1 (0x1)
        Validity
            Not Before: Apr 14 19:15:39 2016 GMT
            Not After : Apr 14 19:15:39 2017 GMT
        Subject:
            countryName               = CN
            stateOrProvinceName       = HuBei
            organizationName          = MageEdu
            organizationalUnitName    = Tech
            commonName                = www.magedu.com
            emailAddress              = www.adminmagedu.com
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Comment: 
                OpenSSL Generated Certificate
            X509v3 Subject Key Identifier: 
                F7:02:66:CE:EE:1D:E3:18:AB:7E:97:19:B2:DF:FA:F8:2A:AD:F8:F5
            X509v3 Authority Key Identifier: 
                keyid:C4:22:C0:59:B6:6D:5B:36:09:1E:1A:4F:0F:6E:82:CD:21:D5:BF:E5

Certificate is to be certified until Apr 14 19:15:39 2017 GMT (365 days)
Sign the certificate? [y/n]:y


1 out of 1 certificate requests certified, commit? [y/n]y
Write out database with 1 new entries
Data Base Updated
[root@RHEL5 ssl]# ls
httpd.crt  httpd.csr  httpd.key
[root@RHEL5 ssl]# cd /etc/pki/CA/
[root@RHEL5 CA]# cat index.txt
V	170414191539Z		01	unknown	/C=CN/ST=HuBei/O=MageEdu/OU=Tech/CN=www.magedu.com/emailAddress=www.adminmagedu.com
[root@RHEL5 CA]# cat serial
02
[root@RHEL5 CA]# 


***x509作req选项时表示自签，作命令时功能非常多，可以查看证书，改证书，甚至跟ca命令一样签署证书申请
[root@RHEL6 CA]# openssl x509 -text -in cacert.pem
Display the contents of a certificate: openssl x509 -in cert.pem -noout -text
Display the certificate serial number: openssl x509 -in cert.pem -noout -serial
Display the certificate subject name:  openssl x509 -in cert.pem -noout -subject
...
Convert a certificate from PEM to DER format: openssl x509 -in cert.pem -inform PEM -out cert.der -outform DER
Convert a certificate to a certificate request: openssl x509 -x509toreq -in cert.pem -out req.pem -signkey key.pem
Convert a certificate request into a self signed certificate using extensions for a CA: openssl x509 -req -in careq.pem -extfile openssl.cnf -extensions v3_ca -signkey key.pem -out cacert.pem
...
Sign a certificate request using the CA certificate above and add user certificate extensions: openssl x509 -req -in req.pem -extfile openssl.cnf -extensions v3_usr -CA cacert.pem -CAkey key.pem -CAcreateserial
...
Set a certificate to be trusted for SSL client use and change set its alias to "Steve’s Class 1 CA": openssl x509 -in cert.pem -addtrust clientAuth -setalias "Steve’s Class 1 CA" -out trust.pem

例1、写一个脚本，实现CA认证中心并且模拟用户申请CA证书

# ls /etc/pki/rpm-gpg/
	RPM-GPG-KEY-redhat-release
	
rpm -K /PAPT/TO/PACKAGE_FILE
	dsa, gpg: 验正来源合法性，也即验正签名；可以使用--nosignature，略过此项
	sha1, md5: 验正软件包完整性；可以使用--nodigest，略过此项
	
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release: 导入密钥文件
[root@lcfyl Packages]# rpm -K zsh-4.3.10-4.1.el6.i686.rpm 
zsh-4.3.10-4.1.el6.i686.rpm: RSA sha1 ((MD5) PGP) md5 NOT OK (MISSING KEYS: (MD5) PGP#fd431d51) 
[root@lcfyl Packages]# rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release 
[root@lcfyl Packages]# rpm -K zsh-4.3.10-4.1.el6.i686.rpm 
zsh-4.3.10-4.1.el6.i686.rpm: rsa sha1 (md5) pgp md5 OK



rpm --> yum（源：repository）

HTML: HyperText Mark Language
XML: eXtended Mark Language
XML, JSON: 半结构化的数据

yum仓库中repodate元数据文件：
***repodata目录的父目录就是yum源
primary.xml.gz
	所有RPM包的列表；
	依赖关系；
	每个RPM安装生成的文件列表；
filelists.xml.gz
	当前仓库中所有RPM包的所有文件列表；
other.xml.gz
	额外信息，RPM包的修改日志；

repomd.xml
	记录的是上面三个文件的时间戳和校验和，对比更新数据；
***以上四个文件可用一个命令生成：createrepo	

comps*.xml: RPM包分组信息

rpm包包组的定义：
yum：命令，有许多子命令
	/etc/yum.conf：主配置文件
	/etc/yum.repos.d/*.repo：记载了如何找到yum元数据repodata进而从repodata中找到软件包的各种依赖关系各种属性
	/etc/yum/pluginconf.d

配置文件：分为两段
全局配置：/etc/yum.conf
分段配置：/etc/yum.repos.d/*.repo, /etc/yum/pluginconf.d ..........
[repo1]
[repo2]
[repo3]

ftp://172.16.0.1/pub/{Server,VT,Cluster,ClusterStorage}
ftp://USERNAME:PASSWORD@192.168.0.254/pub/Server/
如何为yum定义repo文件
[Repo_ID]
name=Description(等号两边没空格）
baseurl=ftp://172.16.0.1/pub/{Server,VT,Cluster,ClusterStorage}

	ftp://
	http://
	file:///
enabled={1|0}
gpgcheck={1|0}：是否检查签名
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release


yum [options] [command] [package ...]
	-y: 自动回答为yes
	--nogpgcheck

list: 列表 
	支持glob
	all
	available：可用的，仓库中有但尚未安装的
	installed: 已经安装的
	updates: 可用的升级

clean: 清理缓存（一般在/var/cache/yum下有元数据、rpm包等缓存，可清理）
	[ packages | headers | metadata | dbcache | all ]
	
repolist: 显示有多少个repodata，也就是所有的yum源
	all
	enabled： 默认
	disabled

install: 安装
yum install PACKAGE_NAME
search "KEYWORD"：模糊匹配
update: 升级
update_to: 升级为指定版本

remove|erase：卸载

info "package_name"：显示一个包的相关信息 

provides| whatprovides: 查看指定的文件或特性是由哪个包安装生成的; 
	
groupinfo "group_name"：显示指定组里面有哪些软件包
grouplist：显示库中的包组有哪些
groupinstall：安装包组
groupremove：卸载包组
groupupdate：包组更新
***
localinstall 安装本地包（独立于yum库外）时，若依赖的包在yum库中，此命令可以将依赖的包从yum库中下下来

如何创建yum仓库：
1、安装createrepo命令
	createrepo
	-g FILE：指定包组定义文件
2、将所需的软件包都下载到本地的某个目录下面，如/var/my/yum
3、然后执行命令createrepo /var/my/yum，则会在这个目录下面生成repodata，但是，关于这些软件包怎么分组，只能手动写文件
4、如果有别人写好的包组定义文件，并且有对应的软件包，则可直接用createrepo -g FILE指定即可。


yum高级用法：
镜像服务器（中国服务器=荷兰服务器）
mirror
baseurl=ftp://192.168.0.254/pub/mirrorlist.txt
mirrorlist.txt指定路径


http://172.16.0.1/yum/{Server,VT}



练习：
1、将系统安装光盘挂载至/media/yum目录，用其实现yum仓库；
2、配置使用http://172.16.0.1/yum/{Server,VT,Cluster,ClusterStorage}为可用yum仓库；


写一个脚本，完成以下功能：
说明：此脚本能于同一个repo文件中创建多个Yum源的指向；
1、接受一个文件名做为参数，此文件存放至/etc/yum.repos.d目录中，且文件名以.repo为后缀；要求，此文件不能事先存，否则，报错；
2、在脚本中，提醒用户输入repo id；如果为quit，则退出脚本；否则，继续完成下面的步骤；
3、repo name以及baseurl的路径，而后以repo文件的格式将其保存至指定的文件中；
4、enabled默认为1，而gpgcheck默认设定为0；
5、此脚本会循环执行多次，除非用户为repo id指定为quit；

if [ -e $1 ]; then
  echo "$1 exist."
  exit 5
fi

[repo id]
name=
baseurl=
enabled=
gpgcheck=

#!/bin/bash
STRING=/etc/yum.repos.d/$1
if [ ${STRING:0-5} != ".repo" ];then
        echo "Usage:./repo.sh *.repo"
        exit 4
fi

if [ -e $STRING ];then
        echo "$STRING exists"
        exit 5
else
        read -p "Input repo id:" REPOID
        until [ $REPOID = "quit" ];do
                echo "[$REPOID]" >> $STRING
                read -p "Input name:" NAME
                echo "name=$NAME" >> $STRING
                read -p "Input baseurl:" BASEURL
                echo "baseurl=$BASEURL" >> $STRING
                read -p "Input enabled:" ENABLED
                echo "enabled=$ENABLED" >> $STRING
                read -p "Input gpgcheck:" GPGCHECK
                echo "gpgcheck=$GPGCHECK" >> $STRING
                read -p "Input repo id:"  REPOID
        done
fi



写一个脚本，完成如下功能：
说明：此脚本能够为指定网卡创建别名，则指定地址；使用格式如：mkethalias.sh -v|--verbose -i ethX
1、-i选项用于指定网卡；指定完成后，要判断其是否存在，如果不存在，就退出；
2、如果用户指定的网卡存在，则让用户为其指定一个别名，此别名可以为空；如果不空，请确保其事先不存在，否则，要报错，并让用户重新输入；
3、在用户输入了一个正确的别名后，请用户输入地址和掩码；并将其配置在指定的别名上；
4、如果用户使用了-v选项，则在配置完成后，显示其配置结果信息；否则，将不显示；



RPM安装：
	二进制格式：
	源程序-->编译-->二进制格式
		有些特性是编译选定的，如果编译未选定此特性，将无法使用；
		rpm包的版本会落后于源码包，甚至落后很多；bind-9.8.7, bind-9.7.2
		
定制：手动编译安装
	编译环境，开发环境
	开发库，开发工具
	
	c语言编译器
	gcc: GNU C Complier

make: 项目管理工具，
	makefile: 定义了make（gcc,g++）按何种次序去编译这些源程序文件中的源程序

makefile文件并非源文件自带，源文件自带的是makefile.in文件，一般情况下也会带configure可执行脚本，再通过
	执行configure将makefile.in转换成makefile

***configure和makefile.in虽然由源文件自带，但是并非是由作者自己写的，由两个命令生成
automake命令生成 --> makefile.in
autoconf命令生成 --> configure


编译安装的三步骤：
前提：准备开发环境(编译环境)
安装"Development Tools"和"Development Libraries" 

# tar 
# cd
# ./configure  
	--help 
	--prefix=/path/to/somewhere：指定安装路径
	--sysconfdir=/PATH/TO/CONFFILE_PATH：指定配置文件的安装路径
	功能：1、让用户选定编译特性；2、检查编译环境；
# make
# make install

# tar xf tengine-1.4.2.tar.gz
# cd tengine-1.4.2
# ./configure --prefix=/usr/local/tengine --conf-path=/etc/tengine/tengine.conf
# make
# make install
# /usr/local/tengine/sbin/nginx

****如果安装在非默认路径下，系统无法搜索到软件相关路径，则要严格执行下列步骤
1、修改PATH环境变量，以能够识别此程序的二进制文件路径；
	修改/etc/profile文件
	在/etc/profile.d/目录建立一个以.sh为名称后缀的文件，在里面定义export PATH=$PATH:/path/to/somewhere
2、默认情况下，系统搜索库文件的路径/lib, /usr/lib; 要增添额外搜寻路径：
	在/etc/ld.so.conf.d/中创建以.conf为后缀名的文件，而后把要增添的路径直接写至此文件中；
	# ldconfig 通知系统重新搜寻库文件
		-v: 显示重新搜寻库的过程
3、头文件：输出给系统
	默认：/usr/include
	增添头文件（头文件是用户应用程序和函数库之间的桥梁和纽带，编译时，编译器通过头文件找到对应的函数库，进而把已引用函数的实际内容导出来代替原有函数。进而在硬件层面实现功能。）搜寻路径，使用链接进行：
		/usr/local/tengine/include/   /usr/include/
		两种方式：
		ln -s /usr/local/tengine/include/* /usr/include/ 或
		ln -s /usr/local/tengine/include  /usr/include/tengine
4、man文件路径：安装在--prefix指定的目录下的man目录；/usr/share/man	
		1、man -M /PATH/TO/MAN_DIR COMMAND
		2、在/etc/man.config中添加一条MANPATH
		

		
netstat命令：
	-r: 显示路由表
	-n: 以数字方式显示
	
	-t: 建立的tcp连接
	-u: 显示udp连接
	-l: 显示监听状态的连接
	-p: 显示监听指定的套接字的进程的进程号及进程名

在编绎文件之前看源代码中的
INSTALL
README

perl
#perl Makefile.PL
#make
#make install 

***1、下面以编绎安装tengine为例
[root@lcfyl ~]# tar -xf tengine-1.5.1.tar.gz 
[root@lcfyl ~]# cd tengine-1.5.1
[root@lcfyl tengine-1.5.1]# ls
AUTHORS.te  CHANGES.cn  conf       docs     man              src
auto        CHANGES.ru  configure  html     README           tests
CHANGES     CHANGES.te  contrib    LICENSE  README.markdown  THANKS.te
[root@lcfyl tengine-1.5.1]# ./configure --prefix=/usr/local/tengine/ --conf-path=/etc/tengine/tengine.conf
checking for OS
 + Linux 2.6.32-71.el6.i686 i686
checking for C compiler ... not found

./configure: error: C compiler gcc is not found

[root@lcfyl tengine-1.5.1]# yum groupinstall Development Tools
[root@lcfyl tengine-1.5.1]# ./configure --prefix=/usr/local/tengine --conf-path=/etc/tengine/tengine.conf
./configure: error: the HTTP rewrite module requires the PCRE library.
You can either disable the module by using --without-http_rewrite_module
option, or install the PCRE library into the system, or build the PCRE library
statically from the source with nginx by using --with-pcre=<path> option.
[root@lcfyl tengine-1.5.1]# yum install pcre-devel（或者是根据提示命令不安装）
[root@lcfyl tengine-1.5.1]# ./configure --prefix=/usr/local/tengine/ --conf-path=/etc/tengine/tengine.conf
./configure: error: SSL modules require the OpenSSL library.
You can either do not enable the modules, or install the OpenSSL library
into the system, or build the OpenSSL library statically from the source
with nginx by using --with-openssl=<path> option.
[root@lcfyl tengine-1.5.1]# ./configure --prefix=/usr/local/tengine --conf-path=/etc/tengine/tengine.conf
./configure: error: the HTTP gzip module requires the zlib library.
You can either disable the module by using --without-http_gzip_module
option, or install the zlib library into the system, or build the zlib library
statically from the source with nginx by using --with-zlib=<path> option.
***一直出现缺少library，可能是前面只装了Development Tools而没有装Development Libraries，所以两个都要装，
   在rhel5上面两个都有，在rhel6上面只有Development Tools，只能一个一个装Libraries
***因为不知道名字只能泛指
[root@lcfyl tengine-1.5.1]# yum install openssl*
[root@lcfyl tengine-1.5.1]# yum install zlib*
[root@lcfyl tengine-1.5.1]# ./configure --prefix=/usr/local/tengine/ --conf-path=/etc/tengine/tengine.conf

[root@lcfyl tengine-1.5.1]# make

[root@lcfyl tengine-1.5.1]# make install

[root@lcfyl sbin]# vim /etc/profile
加一行PATH=$PATH:/usr/local/tengine/sbin
[root@lcfyl sbin]# source /etc/profile
[root@lcfyl ~]# nginx 
[root@lcfyl ~]# netstat -tnlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State       PID/Program name   
tcp        0      0 0.0.0.0:111                 0.0.0.0:*                   LISTEN      1369/rpcbind        
tcp        0      0 0.0.0.0:80                  0.0.0.0:*                   LISTEN      23374/nginx: master 
tcp        0      0 :::111                      :::*                        LISTEN      1369/rpcbind        
[root@lcfyl ~]# 

***2、下面以编绎安装httpd为例
[root@RHEL6 bin]# tar -xf httpd-2.2.9.tar.gz -C ~
[root@RHEL6 bin]# cd httpd-2.2.9/
[root@RHEL6 bin]# rpm -q httpd
[root@RHEL6 bin]# ./configure --prefix=/usr/local/apache --sysconfdir=/etc/httpd
[root@RHEL6 bin]# make
[root@RHEL6 bin]# make install
[root@RHEL6 bin]# cd /usr/local/apache/	
[root@RHEL6 apache]# ls
bin    cgi-bin  htdocs  include  logs  manual
build  error    icons   lib      man   modules
[root@RHEL6 apache]# cd bin/
[root@RHEL6 bin]# ls
ab            apu-1-config  dbmmanage    htcacheclean  htpasswd   logresolve
apachectl     apxs          envvars      htdbm         httpd      rotatelogs
apr-1-config  checkgid      envvars-std  htdigest      httxt2dbm
[root@RHEL6 bin]# htpasswd
-bash: htpasswd: command not found
***在/etc/profile.d/下面建一个后缀为.sh的文件，然后在里面写上一句 export PATH=$PATH:/usr/local/apache/bin
[root@RHEL6 bin]# vim /etc/profile.d/httpd.sh
export PATH=$PATH:/usr/local/apache/bin
[root@RHEL6 ~]# echo $PATH
/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin://usr/local/tengine/sbin:/usr/local/apache/bin:/root/bin
[root@RHEL6 ~]# htpasswd 
Usage:
	htpasswd [-cmdpsD] passwordfile username
	htpasswd -b[cmdpsD] passwordfile username password

	htpasswd -n[mdps] username
	htpasswd -nb[mdps] username password
[root@RHEL6 ~]# ldconfig -v | grep apr
	libapr-1.so.0 -> libapr-1.so.0.3.9
	libaprutil-1.so.0 -> libaprutil-1.so.0.3.9
[root@RHEL6 bin]# vim /etc/ld.so.conf.d/httpd.conf
/usr/local/apache/lib
[root@RHEL6 ~]# ldconfig -v | grep apr
	libaprutil-1.so.0 -> libaprutil-1.so.0.3.0
	libapr-1.so.0 -> libapr-1.so.0.3.0
	libapr-1.so.0 -> libapr-1.so.0.3.9
	libaprutil-1.so.0 -> libaprutil-1.so.0.3.9
[root@RHEL6 ~]# cd /usr/local/apache/
[root@RHEL6 apache]# ls include/
ap_compat.h         apr_md4.h             apu_version.h
ap_config_auto.h    apr_md5.h             apu_want.h
ap_config.h         apr_memcache.h        expat.h
ap_config_layout.h  apr_mmap.h            http_config.h
ap_listen.h         apr_network_io.h      http_connection.h
ap_mmn.h            apr_optional.h        http_core.h
ap_mpm.h            apr_optional_hooks.h  httpd.h
ap_provider.h       apr_poll.h            http_log.h
apr_allocator.h     apr_pools.h           http_main.h
apr_anylock.h       apr_portable.h        http_protocol.h
apr_atomic.h        apr_proc_mutex.h      http_request.h
apr_base64.h        apr_queue.h           http_vhost.h
apr_buckets.h       apr_random.h          mod_auth.h
apr_date.h          apr_reslist.h         mod_cgi.h
apr_dbd.h           apr_ring.h            mod_core.h
apr_dbm.h           apr_rmm.h             mod_dav.h
[root@RHEL6 apache]# ln -sv /usr/local/apache/include /usr/include/httpd
`/usr/include/httpd' -> `/usr/local/apache/include'
[root@RHEL6 apache]# ls bin/
ab            apu-1-config  dbmmanage    htcacheclean  htpasswd   logresolve
apachectl     apxs          envvars      htdbm         httpd      rotatelogs
apr-1-config  checkgid      envvars-std  htdigest      httxt2dbm
[root@RHEL6 apache]# man htpasswd
No manual entry for htpasswd
[root@RHEL6 apache]# ls man/man
man1/ man8/
***如果源man/man1(man8)目录下有htpasswd文件，则可以通过man的连接命令进行man查询
[root@RHEL6 apache]# ls man/man1
dbmmanage.1  htdbm.1  htdigest.1  htpasswd.1
[root@RHEL6 apache]# man -M /usr/local/apache/man htpasswd
***以上方式只能临时有效，所以最好还是下面改配置文件
[root@RHEL6 apache]# vim /etc/man.config 
加一行：
MANPATH /usr/local/apache/man
[root@RHEL6 apache]# netstat -ltnp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State       PID/Program name   
tcp        0      0 0.0.0.0:80                  0.0.0.0:*                   LISTEN      7425/ngi
[root@RHEL6 apache]# kill 7425
[root@RHEL6 apache]# netstat -ltnp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State       PID/Program name   
[root@RHEL6 apache]#
[root@RHEL6 apache]# apachectl start
[root@RHEL6 apache]# netstat -tnlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State       PID/Program name  
tcp        0      0 :::80                       :::*                        LISTEN      27782/httpd         


写一个脚本，完成以下功能：
1、提示用户输入一个用户名；
2、显示一个菜单给用户，形如：
U|u  show UID
G|g  show GID
S|s  show SHELL
Q|q  quit
3、提醒用户选择一个选项，并显示其所选择的内容；

如果用户给的是一个非上述所提示的选项，则提醒用户给出的选项错误，并请其重新选择后执行；


写一个脚本：
1、判断一个指定的bash脚本是否有语法错误；如果有错误，则提醒用户键入Q或者q无视错误并退出，其它任何键可以通过vim打开这个指定的脚本；
2、如果用户通过vim打开编辑后保存退出时仍然有错误，则重复第1步中的内容；否则，就正常关闭退出。

./syntax.sh a.sh

until bash -n $1 &> /dev/null; do
	read -p "Syntax error, [Qq] to quit, others for editing: "  CHOICE
	case $CHOICE in
	q|Q)
	    echo "Something wrong, quiting."
	    exit 5
	    ;;
	*)
		vim + $1
		;;
	esac
done

echo "0K"


脚本编程之函数：
function: 功能
	结构化编程，不能独立运行，需要调用时执行，可以被多次调用

定义一个函数：
第一种：
function FUNCNAME {
  command
}

第二种：
FUNCNAME() {
  command
}


自定义执行状态返回值：
return #
0-255
  1 #!/bin/bash
  2 #
  3 ADDUSER(){
  4 USERNAME=hadoop
  5 if ! id -u $USERNAME &> /dev/null ;then
  6         useradd $USERNAME
  7         echo $USERNAME | passwd --stdin $USERNAME &> /dev/null
  8         return 0
  9 else
 10         return 1
 11 fi
 12 }
 13 
 14 ADDUSER
 15 if [ $? -eq 0 ];then
 16         echo "add user finished.."
 17 else
 18         echo "failure.."
 19 fi

接受参数的函数：
./a.sh m n 
$1: m
$2: n

#!/bin/bash
#
function twoint {
         sum=$[$1+$2]
        echo "$sum"

}

twoint 5 6

TWOINT 5 6
$1: 5
$2: 6

练习：写一个脚本，判定192.168.0.200-192.168.0.254之间的主机哪些在线。要求：
1、使用函数来实现一台主机的判定过程；
2、在主程序中来调用此函数判定指定范围内的所有主机的在线情况。

#!/bin/bash
#
PING() {
  for I in {200..254};do
    if ping -c 1 -W 1 192.168.0.$I &> /dev/null; then
      echo "192.168.0.$I is up."
    else
      echo "192.168.0.$I is down."
    fi
  done
}

PING

#!/bin/bash
#
PING() {
    if ping -c 1 -W 1 $1 &> /dev/null; then
      echo "$1 is up."
    else
      echo "$1 is down."
    fi
}

for I in {200..254}; do
  PING 192.168.0.$I
done


#!/bin/bash
#
PING() {
    if ping -c 1 -W 1 $1 &> /dev/null; then
      return 0
    else
      return 1
    fi
}

for I in {200..254}; do
  PING 192.168.0.$I
  if [ $? -eq 0 ]; then
    echo "192.168.0.$I is up."
  else
    echo "192.168.0.$I is down."
  fi
done


写一个脚本：使用函数完成
1、函数能够接受一个参数，参数为用户名；
   判断一个用户是否存在
   如果存在，就返回此用户的shell和UID；并返回正常状态值；
   如果不存在，就说此用户不存在；并返回错误状态值；
2、在主程序中调用函数；

扩展1：在主程序中，让用户自己输入用户名后，传递给函数来进行判断；
扩展2：在主程序中，输入用户名判断后不退出脚本，而是提示用户继续输入下一个用户名；如果用户输入的用户不存在，请用户重新输入；但如果用户输入的是q或Q就退出；

#!/bin/bash
#
user () {
if id $1 &> /dev/null ;then
echo "`grep ^$1  /etc/passwd | cut -d: -f3,7`"
   return 0
else
   echo "no $1"
    return 1
fi
}
read -p "please input username:" username
until [ $username == q -o $username == Q ]; do
	user $username
	if [ $? == 0 ];then
		read -p "please input again:" username
	else
		read -p "no $username,please input again:" username
	fi
done



进程及作业管理

Uninterruptible sleep: 不可中断的睡眠
Interruptible sleep：可中断睡眠

进程优先级，
100-139：用户可控制
0-99：内核调整的

O：大O标准，2.6内核上改进成O(1)标准，再多不同优先级的进程，取出时间都一样，2.4内核以前则正比增长
	O(1)
	O(n)
	O(logn)
	O(n^2)
	O(2^n)
	
init: 进程号为1

VSZ：进程所使用的虚拟内存大小(Virtual Size)
RSS: 进程使用的驻留集大小或实际内存的大小(Kbytes)
TTY：进程在哪个TTY执行的
STAT：进程状态
ps: Process State
	BSD风格:
	a: 所有与终端有关的进程 
	u：显示是哪个用户发起等信息
	x: 所有与终端无关的进程
1、查看系统占用内存最高的进程的TOP５
#ps aux | sort -rn -k4 | head -5 | awk '{print $4,$11}'
2、查看系统占用CPU最高的进程的TOP5
#ps aux | sort -rn -k3 | sed '/%CPU/d' | head -5 | awk '{print $3,%11}'
3、生成新的报表
#ps -o pid,pcpu,nice,comm
4、生成新的进程报表
#ps -axef -o comm,pid,nice,pcpu

进程的分类：
	跟终端相关的进程
	跟终端无关的进程

进程状态：
	D：不可中断的睡眠
	R：运行或就绪
	S：可中断的睡眠
	T：停止
	Z：僵尸
	
	X：退出状态
	<：高优先级的进程
	N：低优先级的进程
	l: 多线程进程
	+：前台进程组中的进程
	s: 会话进程的领导者
	
	SysV风格：-
ps	
	-elF
	-ef
	-eF

**手动指定显示哪些字段
ps -o PROPERTY1,PROPERTY2


ps -o pid,comm,ni
[root@RHEL6 1]# ps -o pid,comm,ni
  PID COMMAND          NI
 2016 bash              0
 2595 ps                0

	
	
pstree: 显示当前系统上的进程树

top：top状态下直接敲对应字母即可
	M: 根据驻留内存大小进行排序
	P：根据CPU使用百分比进行排序
	T: 根据累计时间进行排序
	W：将当前设置写入~/.toprc配置文件
	
	l: 是否显示平均负载和启动时间
	t: 是否显示进程和CPU状态相关信息
	m: 是否显示内存相关信息
	
	c: 是否显示完整的命令行信息
	q: 退出top
	k: 终止某个进程
	r：定义一个进程的优先级
	s：设置刷新时间，单位为秒
	space：立刻刷新
	u：查看指定账户的进程信息
	H：显示/关闭线程信息
	B：在标头，正在运行的程序上以加粗字体显示

top ：选项功能
	-d: 指定延迟时长，单位是秒
	-b: 批模式
	-n #：在批模式下，共显示多少批
第1行：当前系统时间、uptime时间、当前登入系统的账户总数、
       当前系统1、5、15分钟的系统负载值（即任务队列的平均长度），数值一般超过5即负载过太
第2行：当前进程总数、运行状态的进程总数、休眠状态的进程总数、停止太态进程总数、僵尸状态的进程总数
第3行：us用户空间占用CPU%、
       sy内核空间占用CPU%、
       ni改变过优先级的进程占CPU％、
       id空闲CPU%
       wa指IO等待占用CPU％、
       hi硬中断占用CPU%、
       si软中断占用CPU%、
       st指Xen Hypervisor服务分配给虚拟机上的任务占用CPU%
第4行：物理内存总数、空闲内存总数、使用的内存总数、缓存总数
第5行：swap总数、
       swap空闲内存总数、
       使用swap的内存总数、
       缓冲交换区总数
第7行：PID进程ID、
       USER进程使用者、
       PR进程优先级、
       NI优先级值、
       VIRT使用的虚拟内存总量(kb)VIRT=SWAT+RES
       RES进程使用的没有被置换出来的物理内存(kb)、
       SHR共享内存的大小(kb)、
       S状态、
       %CPU进程自上次更新后到本次更新所占用的CPU%、
       %MEM进程自上次更新后到本次更新所占用的MEM%、
       TIME+进程使用的CPU时间总计单位１/100秒、
       COMMANM进程生成的命令及参数、
lsof：命令可以列出被进程所打开的文件的信息，被打开的文件可以是
      file、directory、network filesystem file、character device file、share lib、pipe、links、socks、and so on
COMMAND：进程名称
PID：进程标识符
USRE：进程所有者
FD：文件描述符，应用程序通过文件描述符识别该文件，如cwd、txt等TYPE，如DIR、REG等
DEVICE：指定磁盘的名称
SIZE：文件的大小
NODE：索引节点(文件在磁盘上的标识)
NAME：打开文件的确切名称
1、列出所打开的文件
#lsof | less
2、查看哪个进程在使用指定的文件
#lsof /filepath/file_name
3、递归查看某个目录的文件信息
#lsof +D /filepath/filepath2/
4、查看指定目录的所有文件
#lsof | grep etc
5、列出指定用户打开的文件信息
#lsof -u user1
6、列出某个程序所打开的文件
#lsof -c cron
7、列出某个用户使用某个程序打开的文件
#lsof -u root -c cron
8、列出除了某个用户外被打开的文件
#lsof -u ^root
9、列出某个PID所打开的文件
#lsof -p 123
10、列出多个PID所打开的文件
#lsof -p 123、234、232
取反
#lsof -p ^123
11、列出多个程序多打开的文件
#lsof -c cron -c at
12、显示哪个进程在使用指定sudo的可执行文件
#lsof `which sudo`
13、显示哪个进程在使用光驱
#lsof /dev/cdrom


进程间通信（IPC: Inter Process Communication）
	共享内存
	信号: Signal
	Semaphore
	
重要的信号：
1：SIGHUP: 让一个进程不用重启，就可以重读其配置文件，并让新的配置信息生效；
2: SIGINT：Ctrl+c: 中断一个进程
9: SIGKILL：杀死一个进程
15: SIGTERM：终止一个进程, 默认信号
	
发送一个信号：kill -SIGNAL PID

kill PID：结束对应进程
killall COMMAND：如果一个命令的进程号太多可以用这种方法kill


调整nice值：
调整已经启动的进程的nice值：
renice NI PID
[root@RHEL6 ~]# renice 3 1691
1691: old priority 0, new priority 3
[root@RHEL6 ~]# 

在启动时指定nice值：
nice -n NI COMMAND
[root@RHEL6 ~]# nice -n -3 useradd hbase


前台作业：占据了命令提示符
后台作业：启动之后，释放命令提示符，后续的操作在后台完成

前台-->后台：
	Ctrl+z: 把正在前台的作业送往后台，但是会停止作业
	COMMAND &：让命令在后台执行，作业继续进行，直到完成终止
		[root@RHEL6 ~]# tar -Jcf etc.jar.xz /etc/* &
		[1] 1800
		[root@RHEL6 ~]# tar: Removing leading `/' from member names

		[root@RHEL6 ~]# ps aux | grep tar
		root      1800  0.0  0.1   4772  1156 pts/0    S    17:20   0:00 tar -Jcf etc.jar.xz /etc/abrt /etc/acpi /etc/adjtime /etc/aliases /etc/aliases.db /etc/alsa /etc/alternatives /etc/anacrontab /etc/asound.conf /etc/at.deny /etc/audisp /etc/audit /etc/autofs_ldap_auth.conf /etc/auto.master /etc/auto.misc /etc/auto.net /etc/auto.smb /etc/bash_completion.d /etc/bashrc /etc/blkid /etc/cas.conf /etc/certmonger /etc/cgconfig.conf /etc/cgrules.conf /etc/chkconfig.d /etc/ConsoleK
bg: 让后台的停止作业继续运行
	bg [[%]JOBID]

jobs: 查看后台的所有作业
	作业号，不同于进程号
		+：命令将默认操作的作业
		-：命令将第二个默认操作的作业
		
fg: 将后台的作业调回前台
	fg [[%]JOBID]
	
kill %JOBID: 终止某作业（这个%不能省）

iostat 选项 延迟 计数
1、查看本地服务器的CPU与硬盘的信息
[root@localhost ~]# iostat -d
Linux 3.10.0-229.el7.x86_64 (localhost.localdomain) 	12/05/2017 	_x86_64_	(4 CPU)

Device:            tps    kB_read/s    kB_wrtn/s    kB_read    kB_wrtn
sda               0.56         4.87        60.49     264001    3276328
scd0              0.29        33.86         0.00    1833964          0

[root@localhost ~]#
第1行：kernel版本（完整的主机名称）、报告生成日期、系统架构（CPU数）
第3行：%user在用户运行进程所占用的CPU百分比
       %nice进程优先级操作所占用的CPU百分比
       %sys系统级别(kernel)运行所使用的CPU百分比
       %iowait指CPU等待硬件I/O时所占用的CPU百分比
       %idle指CPU空闲时间的百分比
第6行：tps每秒钟传输的IO请求的数量
       Blk_read/s块设备每秒钟读取的数量
       BlK_wrtn/s块设备每秒钟写入的数量
       Blk_read块设备读出的总数
       blk_wrtn块设备写入的总数
iostat：参数
        -c 仅显示CPU信息
	-d 仅显示磁盘信息
	-k 以K为单位显示磁盘每秒请求的块数
	-t 显示报告生成时间
	-p device | all 显示指定或所有的块设备的信息
	-x 输出扩展信息[与-p参数冲突]
	-N 显示设备映射名
	-V 显示iostat版本信息
2、每2秒，显示一次设备统计信息
#iostat -d 2
3、每2秒显示一次设备统计信息、共计6次
#iostat -d 2 6
4、每2秒以K为单位显示一次设备统计信息，且显示LVM映射名称，共计10次
#iostat -dNk 2 10
	

vmstat：系统状态查看命令
功能：监控CPU、内存、虚拟内存交换、IO读写等各种情况的使用
语法：
	vmstat [选项] [延迟] [计数]
	
vmstat 1 5：每隔一秒钟显示一次，共显示5次
[root@RHEL6 ~]# vmstat
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0      0 843176  11440  64668   18    0     0     9   34   13  1  0 98  0  0	
[root@RHEL6 ~]# 

进程proc：
	r 表示运行队列(即：多少进程真正的分配到CPU)
	b 阻塞队列(等待资源分配的进程数)
内存memory：
	swap 当前swap使用k数的情况
	free 当前物理内存空闲的k数
	buff 内存使用的buff总数，一般为块设备操作，文档权限记录等
	cache 内存使用的cache总数，一般打开文件，运行程序等使用
虚拟内存swap：
	si 每秒钟从磁盘读入到swap的大小，不可长期>0
	so 每秒钟从swap写入到磁盘的大小，不可长期>0
块设备IO
	bi 块设备每秒接收到的块数
	bo 块设备每秒发送的块数
系统情况System:
	in 系统每秒中断数总计（含时钟中断）
	cs 每秒上下文切换的次数（系统调用，环境变化等）
cpu情况：
	us 用户（及优先级）占用cpu时间
	sy 系统（kernel）占用CPU时间
	id 闲置CPU时间
	wa io等待CPU时间
	st 一个虚拟机占用的CPU时间(如xen/kvm)

pkill：控制同名程序的所有进程
	pkill [选项] [pattern]
踢出某个终端：pkill -kill -t pts/2
按用户名踢出用户：pkill -kill -U suse
强制使arisa账户登出：pkill -9 -u suse

pgrep：程序检查在系统中活动进程，报告进程属性匹配命令行上指定条件的进程的ID
获得以root账户执行的sshd PID：pgrep -x -u root sshd
显示指定账户lisa所执行的PID及相关名称：pgrep -l -u lisa

pidstat：监控被linux内核管理的独立任务
	 它输出每个受内核管理的任务的相关信息，也可以用来监控特定进程子进程
	 间隔参数用于指定每次报告间的时间间隔。它的值为0说明进程的统计数据
	 的时间是从系统启动开始计算的。
pidstat [选项]
#pidstat
PID：被监控的任务的进程号
%usr：当在用户层执行时这个任务的CPU使用率，和nice优先级无关，注意这个字段计算的CPU
      时间不包括在虚拟处理器中花去的时间
%system：这个任务在系统层使用时的CPU使用率
%guest：任务花费在虚拟机上的CPU使用率（运行在虚拟处理器）
%CPU：任务总的CPU使用率。在SMP环境（多处理器）中，如果在命令行中输入-I参数的话，CPU
      使用率会除以你的CPU数量
CPU：正在运行这个任务的处理器编号
Command：这个任务的命令名称
***每个选项详见man

killall5：控制系统中的所有进程
关闭所有进程：killall5 -9


Linux系统启动流程
PC: OS(Linux)
POST-->BIOS(Boot Sequence)-->MBR(bootloader,446)-->Kernel-->initrd-->(ROOTFS)/sbin/init(/etc/inittab)
****其实bootloader识别到硬盘中的Kernel和Initrd并加载，由Kernel取得控制权，再通中间接口Initrd
     调用驱动识别根系统，最后进行初始化命令

启动的服务不同：
	运行级别：0-6（这6种模式可以遇到不同问题时进行维护）
		0：halt
		1: single user mode, 直接以管理员身份切入， s,S,single
		2：multi user mode, no NFS
		3: multi user mode, text mode
		4：reserved（保留的模式，没有定义）
		5: multi user mode, graphic mode
		6: reboot

详解启动过程
	bootloader(MBR)（安装操作系统时生成的）
		LILO: LInux LOader（linux以前用的bootloader，不支持大硬盘，嵌入式系统还可以）
		GRUB: GRand Unified Bootloader（现在用的bootloader，分两阶段）
			Stage1: 载入MBR，这一阶段只为引导第二阶段
			Stage1.5: 识别常见的不同类别的文件系统
			Stage2: /boot/grub/

grub.conf			

default=0  # 设定默认启动的title的编号，从0开始
timeout=5  # 等待用户选择的超时时长，单位是秒
splashimage=(hd0,0)/grub/splash.xpm.gz  # grub的背景图片
hiddenmenu # 隐藏菜单

***password redhat 可以在这个位置直接给grub设置一个密码
***password --md5 $1$HKXJ51$B9Z8A.X//XA.AtzU1.KuG. 这个是加密模式更安全
title Red Hat Enterprise Linux Server (2.6.18-308.el5)  # 内核标题，或操作系统名称，字符串，可自由修改
	root (hd0,0)  # 内核文件所在的设备；对grub而言，所有类型硬盘一律hd，格式为(hd#,N)；hd#, #表示第几个磁盘；最后的N表示对应磁盘的分区；
	kernel /vmlinuz-2.6.18-308.el5 ro root=/dev/vol0/root rhgb quiet   # 内核文件路径，及传递给内核的参数
	initrd /initrd-2.6.18-308.el5.img # ramdisk文件路径（安装系统最后一步生成的）

title Install Red Hat Enterprise Linux 5
	root (hd0,0)
	kernel /vmlinuz-5 ks=http://172.16.0.1/workstation.cfg ksdevice=eth0 noipv6
	initrd /initrd-5
	password --md5 $1$FSUEU/$uhUUc8USBK5QAXc.BfW4m.



查看运行级别：
runlevel: 
who -r

查看内核release号：
	uname -r

***修复grub技能
****安装grub stage1:这个过程是将/boot/grub文件里面的stage1复制进MBR，如果/boot/grub文件
		     里面没有stage1, 1.5, 2,则可以由下面的grub-install创建完整的/boot/grub，不过
		     grub-install在创建的时候也同时将stage1写入了MBR，所以如果Bootloader
		     坏了，则完全可以由grub-install再写一次即可

****安装grub：（指到父目录，它会自己找到boot，并在下面建grub）
*grub-install命令可以一键生成stage1, 1.5, 2并同时完成bootloader
# grub-install --root-directory=/path/to/boot's_parent_dir  /PATH/TO/DEVICE

*grub命令只能在原本就有stage1的前提下才能完成bootloader
# grub
grub> root (hd0,0)（这个时候一定要注意正确判断对应的磁盘）
grub> setup (hd0)

[root@mail ~]# grub
 grub> root (hd1,0)
 Filesystem type is ext2fs, partition type 0x83

grub> setup (hd1)
 Checking if "/boot/grub/stage1" exists... no
 Checking if "/grub/stage1" exists... no

Error 15: File not found

grub> 
[root@mail ~]# grub-install --root-directory=/mnt/ /dev/sdb
Probing devices to guess BIOS drives. This may take a long time.
Installation finished. No error reported.
This is the contents of the device map /mnt//boot/grub/device.map.
Check if this is correct or not. If any of the lines is incorrect,
fix it and re-run the script `grub-install'.

(fd0)	/dev/fd0
(hd0)	/dev/sda
(hd1)	/dev/sdb
[root@mail ~]# grub
grub> root (hd1,0)
 Filesystem type is ext2fs, partition type 0x83

grub> setup (hd1)
 Checking if "/boot/grub/stage1" exists... yes
 Checking if "/boot/grub/stage2" exists... yes
 Checking if "/boot/grub/e2fs_stage1_5" exists... yes
 Running "embed /boot/grub/e2fs_stage1_5 (hd1)"...  15 sectors are embedded.
succeeded
 Running "install /boot/grub/stage1 (hd1) (hd1)1+15 p (hd1,0)/boot/grub/stage2 /
boot/grub/grub.conf"... succeeded
Done.

grub> 


例2：制作一个bootloader作为独立启动盘
[root@RHEL5 ~]# fdisk /dev/sdb 
[root@RHEL5 ~]# mkdir /mnt/boot
[root@RHEL5 ~]# fdisk -l
Disk /dev/sdb: 21.4 GB, 21474836480 bytes
255 heads, 63 sectors/track, 2610 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1           3       24066   83  Linux
/dev/sdb2               4          66      506047+  83  Linux
/dev/sdb3              67          83      136552+  82  Linux swap / Solaris
[root@RHEL5 ~]# mount /dev/sdb1 /mnt/boot/
***这时它会自动在boot父目录下找到boot并安装grub
[root@RHEL5 ~]# grub-install --root-directory=/mnt  /dev/sdb
Probing devices to guess BIOS drives. This may take a long time.
Installation finished. No error reported.
This is the contents of the device map /mnt/boot/grub/device.map.
Check if this is correct or not. If any of the lines is incorrect,
fix it and re-run the script `grub-install'.

(fd0)	/dev/fd0
(hd0)	/dev/sda
(hd1)	/dev/sdb
[root@RHEL5 ~]# cd /mnt/boot/
[root@RHEL5 boot]# ls
grub  lost+found
[root@RHEL5 boot]# ls grub/
device.map     ffs_stage1_5      minix_stage1_5     stage2           xfs_stage1_5
e2fs_stage1_5  iso9660_stage1_5  reiserfs_stage1_5  ufs2_stage1_5
fat_stage1_5   jfs_stage1_5      stage1             vstafs_stage1_5
[root@RHEL5 boot]# 
[root@RHEL5 boot]# vim /mnt/boot/grub/grub.conf
#假装写一个grub.conf
default=0
timeout=5
title Red Hat Enterprise Linux Server (2.6.18-194.el5)
        root (hd0,0)
        kernel /vmlinuz-2.6.18-194.el5 ro root=LABEL=/ rhgb quiet
        initrd /initrd-2.6.18-194.el5.img

[root@RHEL5 ~]# umount /mnt/boot/



***此时仅仅是grub.conf配置文件不见了或是坏了，处理办法
grub> find 
grub> root (hd#,N)
grub> kernel /PATH/TO/KERNEL_FILE
grub> initrd /PATH/TO/INITRD_FILE
grub> boot

例1：如果grub.conf文件没了，启动系统的时候会出现一个grub界面，就按以上步骤配置
***找哪个上面有内核
grub> find (hd0,0)/
grub> root (hd0,0)
grub> kernel /vmli...
grub> initrd /initrd
grub> boot

Kernel初始化的过程：
1、设备探测
2、驱动初始化
3、以只读挂载根文件系统；（此时只读是为安全，不让bug侵入，系统启动后就会重读写挂载）
4、装载第一个进程init（PID：1）


/sbin/init：（/etc/inittab）
	upstart（新开发的，比init要快）: ubuntu, d-bus, event-driven
	systemd：真正意义上并行启动进程，速度最快，以前不是很稳定，在RHEL7上刚刚稳定实现 

id:runlevels:action:process
id: 标识符
runlevels: 在哪个级别运行此行；
action: 在什么情况下执行此行；
process: 要运行的程序; 

id:3:initdefault:

si::sysinit:/etc/rc.d/rc.sysinit	


ACTION:
initdefault: 设定默认运行级别
sysinit: 系统初始化
wait: 等待级别切换至此级别时执行
respawn: 一旦程序终止，会重新启动

/etc/rc.d/rc.sysinit完成的任务：
#task 1:激活udev和selinux
#task 2:根据/etc/sysctl.conf文件设定内核参数
#task 3:检查根文件系统，并以读写方式重新挂载/（此处用动态配置文件/etc/mtab）
#task 4:根据/etc/fstab文件挂载其他所有文件系纺
#task 5:设置主机名
#task 6:设置时钟时间
#task 7:装载键盘映射
#task 8:激活swap交换分区
#task 9:激活lvm和raid
#task 10:清理过期的锁和pid
#task 11:启用磁盘配额

for I in /etc/rc3.d/K*; do
  $I stop
done

for I in /etc/rc3.d/S*; do
  $I start
done

****服务的关闭和开启是有先后顺序的，因为服务之间也有依赖关系
##: 关闭或启动的优先次序，数据越小越优先被选定
先关闭以K开头的服务，后启动以S开头的服务；


内核设计风格：

RedHat, SUSE
核心：动态加载 内核模块
内核：/lib/modules/“内核版本号命名的目录”/

vmlinuz-2.6.32：内核名称
/lib/modules/2.6.32/：独立于内核之外的模块，可以提供驱动、映射、内存管理，进程管理等等，保证内核体积很小

***这个驱动存放的位置是内存，将内存中的一段模拟成硬盘使用
   其实initrd(initramfs)是在安装系统最后生成的文件，由于安装
   系统时就识别出了硬盘的文件系统类型，所以initrd(initramfs)
   只需存放对应的驱动程序即可，保证initrd(initramfs)文件不至于
   太大
RedHat5: ramdisk-->initrd
RedHat6: ramfs-->initramfs

	单内核：Linux (LWP轻量级进程)
		核心：ko(kernel object)模块
		/boot/vmlinuz-version
		/lib/modules/version/
	微内核：Windows, Solaris (真正实现线程)

	****由于内核开始把initrd(initramfs)当成了第一个根文件系统
     在里面生成的有/proc、/sys、/dev等文件，然后识别出真正的
     根文件系统后，就把这些相关的文件直接搬到真正的根文件系统
     最后进行根切换，切换过程类似下面的过程，只不过在initrd(initramfs)里面
     用到的是nash里面的switch root
chroot: chroot /PATH/TO/TEMPROOT [COMMAND...]
	chroot /test/virrrot  /bin/bash
	
ldd /PATH/TO/BINARY_FILE：显示二进制文件所依赖的共享库
[root@RHEL5 ~]# mkdir /test/virroot -pv
mkdir: created directory `/test'
mkdir: created directory `/test/virroot'
[root@RHEL5 ~]# chroot /test/virroot/
chroot: cannot run command `/bin/bash': No such file or directory
[root@RHEL5 ~]# mkdir /test/virroot/bin
[root@RHEL5 ~]# cp /bin/bash /test/virroot/bin/
[root@RHEL5 ~]# chroot /test/virroot/
chroot: cannot run command `/bin/bash': No such file or directory
[root@RHEL5 ~]# ls /test/virroot/bin/
bash
[root@RHEL5 ~]# ldd /bin/bash 
        linux-gate.so.1 =>  (0x00f73000)
        libtermcap.so.2 => /lib/libtermcap.so.2 (0x00c31000)
        libdl.so.2 => /lib/libdl.so.2 (0x00c2b000)
        libc.so.6 => /lib/libc.so.6 (0x00aba000)
        /lib/ld-linux.so.2 (0x00a9c000)
[root@RHEL5 ~]# mkdir /test/virroot/lib
[root@RHEL5 ~]# cp /lib/libtermcap.so.2 /test/virroot/lib
[root@RHEL5 ~]# cp /lib/libdl.so.2 /test/virroot/lib/
[root@RHEL5 ~]# cp /lib/libc.so.6 /test/virroot/lib/
[root@RHEL5 ~]# cp /lib/ld-linux.so.2 /test/virroot/lib/
[root@RHEL5 ~]# tree /test/virroot/
/test/virroot/
|-- bin
|   `-- bash
`-- lib
    |-- ld-linux.so.2
    |-- libc.so.6
    |-- libdl.so.2
    `-- libtermcap.so.2

2 directories, 5 files
[root@RHEL5 ~]# chroot /test/virroot/
bash-3.2# 
bash-3.2# 
bash-3.2# cd lib/
bash-3.2# cd root
bash: cd: root: No such file or directory
bash-3.2# 




MBR（bootloader）--> Kernel --> initrd(initramfs) --> (ROOTFS) --> /sbin/init(/etc/inittab)
	/etc/inittab, /etc/init/*.conf
	upstart

****注意init启动的时候要开启和关闭的服务是根据启动级别来定义的，下面将详细介绍服务启动的过程：
***第一个要注意的是各文件之间的链接关系,像那样创建链接是为了能统一启动服务和关闭服务
init /etc/inittab
id:runlevels:action:process

id:5:initdefault:

si::sysinit:/etc/rc.d/rc.sysinit
OS初始化

l0:0:wait:/etc/rc.d/rc 0
	rc0.d/
		K*
			stop
		S*
			start
			
/etc/rc.d/init.d, /etc/init.d

服务类脚本：
	start
	
	SysV： /etc/rc.d/init.d
		start|stop|restart|status
		reload|configtest

# chkconfig: runlevels SS KK	
	当chkconfig命令来为此服务脚本在rc#.d目录创建链接时，只在runlevels这些级别下开启此服务，创建的链接是S开头优先级就是此处的SS，
	其他级别就是关闭此服务，创建的链接是K开头，优先级就是此处的KK，-表示没有级别开启此服务
	（S后面的启动优先级为SS所表示的数字；K后面关闭优先次序为KK所表示的数字）
# description: 用于说明此脚本的简单功能； \, 续行
chkconfig命令
chkconfig --list： 查看所有独立守护服务的启动设定；独立守护进程！
	chkconfig --list SERVICE_NAME
***只要将脚本按照下面这个命令执行，就会自动创建链接	
chkconfig --add SERVICE_NAME

***删除某个服务就会删掉所有对应的链接
chkconfig --del SERVICE_NAME

***指定某个级别下开启或者关闭
chkconfig [--level RUNLEVELS] SERVICE_NAME {on|off}
	如果省略级别指定，默认为2345级别；


样例脚本：
[root@RHEL5 ~]# vim myservice.sh 
#!/bin/bash
#
# chkconfig: 2345 77 22
# description: Test Service
# 
LOCKFILE=/var/lock/subsys/myservice

status() {
  if [ -e $LOCKFILE ]; then
    echo "Running..."
  else
    echo "Stopped."
  fi
}

usage() {
  echo "`basename $0` {start|stop|restart|status}"
}

case $1 in
start)
  echo "Starting..." 
  touch $LOCKFILE ;;
stop)
  echo "Stopping..." 
  rm -f $LOCKFILE &> /dev/null
  ;;
restart)
  echo "Restarting..." ;;
status)
  status ;;
*)
  usage ;;
esac
[root@RHEL5 ~]# cp myservice.sh /etc/rc.d/init.d/myservice
[root@RHEL5 ~]# chkconfig --list myservice
service myservice supports chkconfig, but is not referenced in any runlevel (run 'chkconfig --add myservice')
[root@RHEL5 ~]# chkconfig --add myservice
[root@RHEL5 ~]# find /etc/rc.d -name "*myservice*"
/etc/rc.d/rc6.d/K22myservice
/etc/rc.d/rc3.d/S77myservice
/etc/rc.d/rc2.d/S77myservice
/etc/rc.d/init.d/myservice
/etc/rc.d/rc4.d/S77myservice
/etc/rc.d/rc1.d/K22myservice
/etc/rc.d/rc0.d/K22myservice
/etc/rc.d/rc5.d/S77myservice
[root@RHEL5 ~]# 
[root@RHEL5 ~]# chkconfig --list myservice
myservice      	0:off	1:off	2:on	3:on	4:on	5:on	6:off
[root@RHEL5 ~]# chkconfig --level 24 myservice off
[root@RHEL5 ~]# chkconfig --list myservice
myservice      	0:off	1:off	2:off	3:on	4:off	5:on	6:off
[root@RHEL5 ~]# chkconfig --del myservice
[root@RHEL5 ~]# find /etc/rc.d -name "*myservice*"
/etc/rc.d/init.d/myservice
[root@RHEL5 ~]# 


/etc/rc.d/rc.local：系统最后启动的一个服务，准确说，应该执行的一个脚本；

/etc/inittab的任务：
1、设定默认运行级别；
2、运行系统初始化脚本；
3、运行指定运行级别对应的目录下的脚本；
4、设定Ctrl+Alt+Del组合键的操作；
5、定义UPS电源在电源故障/恢复时执行的操作；
6、启动虚拟终端(2345级别)；
7、启动图形终端(5级别)；

守护进程的类型：
	独立守护进程
	xinetd：超级守护进程，代理人
		瞬时守护进程：没有运行级别，由xinetd运行级别表达
		/etc/xinetd.conf
		/etc/xinetd.d/*
		配置文件主要有两部分：
			1、全局配置（服务的默认配置）
			2、服务配置
service telnet
{
        disable = no				//chkconfig可以改变yes或no
        flags           = REUSE			//可多次使用的服务，其他的服务器都默认REUSE
        socket_type     = stream		//套接字类型，这是tcp流，udp是dgram，共有三种tcp,udp,rpc（由portmap应用提供）
        wait            = no			//后面用户是否等待前面用户完成后才进来，tcp可以等，udp不能等		
        user            = root			//以root身份启动
        server          = /usr/sbin/in.telnetd	//启动服务对应的二进制文件
        log_on_failure  += USERID		//失败时记录日志格式，+= 在默认基础上追加记录
}

[root@RHEL6 ~]# yum install xinetd
[root@RHEL6 ~]# chkconfig --list xinetd
xinetd         	0:off	1:off	2:off	3:on	4:on	5:on	6:off
[root@RHEL6 ~]# service xinetd start
Starting xinetd:                                           [  OK  ]
[root@RHEL6 ~]# chkconfig --list
xinetd based services:
	chargen-dgram: 	off（这些就都是瞬时守护进程）
	chargen-stream:	off
	cvs:           	off
	daytime-dgram: 	off
	daytime-stream:	off
	discard-dgram: 	off
	discard-stream:	off
	echo-dgram:    	off
	echo-stream:   	off
	rsync:         	off
	tcpmux-server: 	off
	time-dgram:    	off
	time-stream:   	off
[root@RHEL6 ~]# 
		
	


	
用户空间访问、监控内核的方式：
/proc, /sys

/proc/sys: 此目录中的文件很多是可读写的
/sys/： 某些文件可写


设定内核参数值的方法：
echo VALUE > /proc/sys/TO/SOMEFILE
sysctl -w kernel.hostname=
[root@RHEL6 sys]# sysctl -w kernel.hostname="mylab"
kernel.hostname = mylab
[root@RHEL6 sys]# hostname
mylab
[root@RHEL6 sys]# 
	
***能立即生效，但无法永久有效；要想永久有效：/etc/sysctl.conf


修改文件完成之后，执行如下命令可立即生效：
sysctl -p：通知内核重读/etc/sysctl.conf文件	
sysctl -a: 显示所有内核参数及其值

内核模块管理：
lsmod: 查看内核模块

modprobe MOD_NAME：装载某模块
modprobe -r MOD_NAME: 卸载某模块
[root@RHEL5 ~]# lsmod | grep "floppy"
floppy                 57125  0 
[root@RHEL5 ~]# modprobe -r floppy
[root@RHEL5 ~]# lsmod | grep "floppy"
[root@RHEL5 ~]# 

modinfo MOD_NAME: 查看模块的具体信息

***还有一套装卸载模块，但是一定要指明路径了
insmod /PATH/TO/MODULE_FILE: 装载模块	
[root@RHEL5 ~]# insmod /lib/modules/2.6.18-194.el5/kernel/drivers/block/floppy.ko
[root@RHEL5 ~]# lsmod | grep "floppy"
floppy                 57125  0 
[root@RHEL5 ~]# 

rmmod MOD_NAME
[root@RHEL5 ~]# rmmod floppy
[root@RHEL5 ~]# lsmod | grep "floppy"
[root@RHEL5 ~]# 

***查看模块依赖关系
depmod /PATH/TO/MODILES_DIR


***内核中的功能除了核心功能之外，在编译时，大多功能都有三种选择：
1、不使用此功能；
2、编译成内核模块；
	这时一般是要用到modprobe或者是insmod来装载的
3、编译进内核；

如何手动编译内核：
***内核的编绎非常复杂，不像以前的./configure那样简单，必需借助如下专业工具

***如何实现部分编译：
1、只编译某子目录下的相关代码：
	make dir/
	make arch/：编绎内核核心
	make drivers/net/：只编绎与网络相关驱动
2、只编译部分模块
	make M=drivers/net/
3、只编译某一模块
	make drivers/net/pcnet32.ko
4、将编译完成的结果放置于别的目录中
	make O=/tmp/kernel 
5、交叉编译
	make ARCH=

第一种：
make gconfig: Gnome桌面环境使用，需要安装图形开发库组：GNOME Software Development
make kconfig: KDE桌面环境使用，需要安装图形开发库：KDE Software Development

第二种：

第一步：make menuconfig: 在界面里将内核的功能定制完成后
[root@RHEL5 ~]# ln -sv linux-2.6.28.10 linux
create symbolic link `linux' to `linux-2.6.28.10'
[root@RHEL5 ~]# ls
anaconda-ks.cfg  linux  linux-2.6.28.10
[root@RHEL5 ~]# cd linux
[root@RHEL5 linux]# ls
arch     Documentation  init    MAINTAINERS  REPORTING-BUGS  usr
block    drivers        ipc     Makefile     samples         virt
COPYING  firmware       Kbuild  mm           scripts
CREDITS  fs             kernel  net          security
crypto   include        lib     README       sound
[root@RHEL5 linux]# make menuconfig（一定要在内核目录下执行此命令）
***在弹出的图形界面上定制想要的内核功能，完成后会在linux目录下生
     成一个.config的隐藏文件，make编绎时就根据这个配置文件来编绎
     （相当于我们前面编绎软件时的makefile文件）
***在这里的实验我们将rhel官方的配置文件复制过来再修改
***下面的config-2.6.18-194.el5就是官方在编绎内核时用到的配置文件
[root@RHEL5 ~]# ls /boot/
config-2.6.18-194.el5  initrd-2.6.18-194.el5.img  symvers-2.6.18-194.el5.gz  vmlinuz-2.6.18-194.el5
grub                   lost+found                 System.map-2.6.18-194.el5
[root@RHEL5 ~]# cp /boot/config-2.6.18-194.el5 linux/.config
cp: overwrite `linux/.config'? y
[root@RHEL5 ~]# 
[root@RHEL5 ~]# cd linux
[root@RHEL5 linux]# make menuconfig
***由于官方要兼容太多人的电脑，所以有很多设置为了兼容性都设置了，但是对
   于我们自己的主机有很多没有必要，可以去掉
第二步：make 编绎
第三步：make modules_install 先装模块
第四步：make install


screen命令：内核编绎需要很长时间，恐怕终端会断开导致崩溃，这时可以用到screen打开多个窗口
screen -ls: 显示已经建立的屏幕
screen: 直接打开一个新的屏幕
	Ctrl+a松开再按d: 拆除屏幕
screen -r ID: 还原回某屏幕
exit: 退出


二次编译时清理，清理前，如果有需要，请备份配置文件.config：
make clean
make mrproper



****系统裁剪
grub-->kernel-->initrd-->ROOTFS(/sbin/init, /bin/bash)
mkinitrd  initrd文件路径  内核版本号
mkinitrd  /boot/initrd-`uname -r`.img  `uname -r`
[root@RHEL5 ~]# mkdir /mnt/{boot,sysroot}
[root@RHEL5 ~]# ls /mnt
boot  sysroot
[root@RHEL5 ~]# mount /dev/hda1 /mnt/boot/
[root@RHEL5 ~]# mount /dev/hda2 /mnt/sysroot/
[root@RHEL5 ~]# grub-install --root-directory=/mnt /dev/hda
Probing devices to guess BIOS drives. This may take a long time.
Installation finished. No error reported.
This is the contents of the device map /mnt/boot/grub/device.map.
Check if this is correct or not. If any of the lines is incorrect,
fix it and re-run the script `grub-install'.

(fd0)	/dev/fd0
(hd0)	/dev/hda
(hd1)	/dev/sda
[root@RHEL5 ~]# ls /mnt/boot/
grub  lost+found
[root@RHEL5 ~]# cp /boot/vmlinuz-2.6.18-194.el5 /mnt/boot/vmlinuz
***下一步是生成initrd(initramfs)，但这个文件是安装系统时生成的，如果说RHEL5、RHEL6重新
   创建，如下：
rhel5: [root@RHEL5 ~]# mkinitrd /boot/initrd-`uname -r`.img `uname -r`
rhel6: [root@RHEL6 ~]# dracut /boot/initramfs-`uname -r`.img `uname -r`

***当然此处不能用这个命令创建，因为我们是想模拟另外一块硬盘成为系统盘，而上述命令是对当
   前系统重新构造initrd(initramfs)
***所以我们把当前系统的initrd复制过来修改一下
[root@RHEL5 ~]# cp /boot/initrd-2.6.18-194.el5.img ~
[root@RHEL5 ~]# ls
anaconda-ks.cfg  etc.jar.bz2                install.log         mbox
Desktop          initrd-2.6.18-194.el5.img  install.log.syslog
[root@RHEL5 ~]# file initrd-2.6.18-194.el5.img 
initrd-2.6.18-194.el5.img: gzip compressed data, from Unix, last modified: Tue Mar 29 10:34:19 2016, max compression
[root@RHEL5 ~]# mv initrd-2.6.18-194.el5.img initrd-2.6.18-194.el5.img.gz
[root@RHEL5 ~]# gzip -d initrd-2.6.18-194.el5.img.gz 
[root@RHEL5 ~]# file initrd-2.6.18-194.el5.img 
initrd-2.6.18-194.el5.img: ASCII cpio archive (SVR4 with no CRC)
[root@RHEL5 ~]# mkdir iso
[root@RHEL5 ~]# cd iso/
[root@RHEL5 iso]# zcat /boot/initrd-2.6.18-194.el5.img | cpio -id
11855 blocks
[root@RHEL5 iso]# ls
bin  dev  etc  init  lib  proc  sbin  sys  sysroot
[root@RHEL5 iso]# 
[root@RHEL5 iso]# file init
init: a /bin/nash script text executable
[root@RHEL5 iso]# vim init 
mkrootdev -t ext3 -o defaults,ro sda2
改成：
mkrootdev -t ext3 -o defaults,ro /dev/hda2
将此行注释掉，因为没有swap
#resume LABEL=SWAP-sda3
[root@RHEL5 iso]# pwd
/root/iso
[root@RHEL5 iso]# find . | cpio -H newc --quiet -o | gzip -9 > /mnt/boot/initrd.gz
[root@RHEL5 ~]# cd /mnt/boot/
[root@RHEL5 boot]# ls
grub  initrd.gz  lost+found  vmlinuz
[root@RHEL5 boot]# vim /mnt/boot/grub/grub.conf
default=0
timeout=5
title Test Linix
        root (hd0,0)
        kernel /vmlinuz
        initrd /initrd.gz
[root@RHEL5 boot]# cd /mnt/sysroot/
[root@RHEL5 sysroot]# mkdir proc sys dev etc/rc.d lib bin sbin boot home var/log usr/{bin,sbin} root tmp -pv
[root@RHEL5 sysroot]# tree
.
|-- bin
|-- boot
|-- dev
|-- etc
|   `-- rc.d
|-- home
|-- lib
|-- lost+found
|-- proc
|-- root
|-- sbin
|-- sys
|-- tmp
|-- usr
|   |-- bin
|   `-- sbin
`-- var
    `-- log

18 directories, 0 files
[root@RHEL5 sysroot]# cp /sbin/init
init     initlog  
[root@RHEL5 sysroot]# cp /sbin/init /mnt/sysroot/sbin/
[root@RHEL5 sysroot]# cp /bin/bash /mnt/sysroot/bin/
[root@RHEL5 sysroot]# ldd /sbin/init
	linux-gate.so.1 =>  (0x00bfb000)
	libsepol.so.1 => /lib/libsepol.so.1 (0x00c85000)
	libselinux.so.1 => /lib/libselinux.so.1 (0x00c6b000)
	libc.so.6 => /lib/libc.so.6 (0x00110000)
	libdl.so.2 => /lib/libdl.so.2 (0x00c2b000)
	/lib/ld-linux.so.2 (0x00a9c000)
[root@RHEL5 sysroot]# cp /lib/libsepol.so.1 /mnt/sysroot/lib/
[root@RHEL5 sysroot]# cp /lib/libselinux.so.1 /mnt/sysroot/lib/
[root@RHEL5 sysroot]# cp /lib/libc.so.6 /mnt/sysroot/lib/
[root@RHEL5 sysroot]# cp /lib/libdl.so.2 /mnt/sysroot/lib/
[root@RHEL5 sysroot]# cp /lib/ld-linux.so.2 /mnt/sysroot/lib/
[root@RHEL5 sysroot]# 
[root@RHEL5 sysroot]# ldd /bin/bash 
	linux-gate.so.1 =>  (0x00cbe000)
	libtermcap.so.2 => /lib/libtermcap.so.2 (0x00c31000)
	libdl.so.2 => /lib/libdl.so.2 (0x00c2b000)
	libc.so.6 => /lib/libc.so.6 (0x00aba000)
	/lib/ld-linux.so.2 (0x00a9c000)
[root@RHEL5 sysroot]# cp /lib/libtermcap.so.2 /mnt/sysroot/lib/
[root@RHEL5 ~]# chroot /mnt/sysroot/
bash-3.2#  
bash-3.2# exit
exit
[root@RHEL5 ~]# sync
[root@RHEL5 ~]# cd /mnt/sysroot/
[root@RHEL5 sysroot]# pwd
/mnt/sysroot
[root@RHEL5 sysroot]# tree etc/
etc/
`-- rc.d

1 directory, 0 files
[root@RHEL5 sysroot]# vim etc/inittab
id:3:initdefault:
si::sysinit:/etc/rc.d/rc.sysinit
[root@RHEL5 sysroot]# vim etc/rc.d/rc.sysinit
#!/bin/bash
#
echo -e "\tWelcome to \033[31mMageEdu Team\033[0m Linux."
/bin/bash
[root@RHEL5 sysroot]# sync
[root@RHEL5 sysroot]# sync
[root@RHEL5 sysroot]# chmod +x etc/rc.d/rc.sysinit 


${parameter#*word}
${parameter##*word}
              The word is expanded to produce a pattern just as in pathname expansion.  If the pattern matches the beginning of the value of
              parameter, then the result of the expansion is the expanded value of parameter with the shortest matching pattern  (the  ?..?.
              case)  or  the  longest  matching pattern (the ?..#?..case) deleted.  If parameter is @ or *, the pattern removal operation is
              applied to each positional parameter in turn, and the expansion is the resultant list.  If parameter is an array variable sub-
              scripted  with  @ or *, the pattern removal operation is applied to each member of the array in turn, and the expansion is the
              resultant list.

FILE=/usr/local/src
${FILE#*/}: usr/local/src
${FILE##*/}: src

${FILE%/*}: /usr/local
${FILE%%/*}:



${parameter%word*}
${parameter%%word*}
              The word is expanded to produce a pattern just as in pathname expansion.  If the pattern matches a  trailing  portion  of  the
              expanded  value  of  parameter, then the result of the expansion is the expanded value of parameter with the shortest matching
              pattern (the ?..?..case) or the longest matching pattern (the ?..%?..case) deleted.  If parameter  is  @  or  *,  the  pattern
              removal  operation  is applied to each positional parameter in turn, and the expansion is the resultant list.  If parameter is
              an array variable subscripted with @ or *, the pattern removal operation is applied to each member of the array in  turn,  and
              the expansion is the resultant list.
***查看屏宽和显示其线性输出速率
[root@RHEL5 etc]# stty -F /dev/console size
25 80
[root@RHEL5 etc]# man stty
[root@RHEL5 etc]# stty -F /dev/console speed
38400

***有时虚拟机磁盘在两边切换快了会导致文件系统崩溃，修复方法
[root@RHEL5 /]# cd /mnt/sysroot/
[root@RHEL5 sysroot]# find . | cpio -H newc --quiet -o | gzip > /root/sysroot.gz
[root@RHEL5 sysroot]# cd
[root@RHEL5 ~]# umount /dev/sdb2
umount: /mnt/sysroot: device is busy
umount: /mnt/sysroot: device is busy
[root@RHEL5 ~]# fuser -km /dev/sdb2
/dev/sdb2:            3374c  3518c
[root@RHEL5 ~]# umount /dev/sdb2
[root@RHEL5 ~]# mke2fs -j /dev/sdb2
[root@RHEL5 ~]# mount /dev/sdb2 /mnt/sysroot/
[root@RHEL5 ~]# cd /mnt/sysroot/
[root@RHEL5 sysroot]# zcat /root/sysroot.gz |cpio -id
17030 blocks
[root@RHEL5 sysroot]# ls
bin   dev  home  lost+found  root  sys  usr
boot  etc  lib   proc        sbin  tmp  var
[root@RHEL5 sysroot]# cat etc/inittab 
id:3:initdefault:
si::sysinit:/etc/rc.d/rc.sysinit


l0:0:wait:/etc/rc.d/rc 0
l3:3:wait:/etc/rc.d/rc 3
l6:6:wait:/etc/rc.d/rc 6

1:2345:respawn:/sbin/agetty -n -l /bin/bash 38400 tty1
2:2345:respawn:/sbin/agetty -n -l /bin/bash 38400 tty2
[root@RHEL5 sysroot]# 


复制二进制程序及其依赖的库文件的脚本：
#!/bin/bash
#
DEST=/mnt/sysroot
libcp() {
  LIBPATH=${1%/*}
  [ ! -d $DEST$LIBPATH ] && mkdir -p $DEST$LIBPATH
  [ ! -e $DEST${1} ] && cp $1 $DEST$LIBPATH && echo "copy lib $1 finished."
}

bincp() {
  CMDPATH=${1%/*}
  [ ! -d $DEST$CMDPATH ] && mkdir -p $DEST$CMDPATH
  [ ! -e $DEST${1} ] && cp $1 $DEST$CMDPATH

  for LIB in  `ldd $1 | grep -o "/.*lib\(64\)\{0,1\}/[^[:space:]]\{1,\}"`; do
    libcp $LIB
  done
}

read -p "Your command: " CMD
until [ $CMD == 'q' ]; do
   ! which $CMD &> /dev/null && echo "Wrong command" && read -p "Input again:" CMD && continue
  COMMAND=` which $CMD | grep -v "^alias" | grep -o "[^[:space:]]\{1,\}"`
  bincp $COMMAND
  echo "copy $COMMAND finished."
  read -p "Continue: " CMD
done

***在裁减系统上执行下列任务：
1、关机和重启；
2、主机名；
3、运行对应服务脚本；
4、启动终端；
5、运行用户；
6、定义单用户级别；
7、装载网卡驱动，启用网络功能；
8、提供一个web服务器；
9、设定内核参数；

/etc/rc.d/init.d/functions脚本，可用于控制服务脚本的信息显示：
SCREEN=`stty -F /dev/console size 2>/dev/null`
COLUMNS=${SCREEN#* }
[ -z $COLUMNS ] && COLUMNS=80

SPA_COL=$[$COLUMNS-14]

RED='\033[31m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'
NORMAL='\033[0m'


success() {
  string=$1
  RT_SPA=$[$SPA_COL-${#string}]
  echo -n "$string"
  for I in `seq 1 $RT_SPA`;do
    echo -n " "
  done
  echo -e "[   ${GREEN}OK${NORMAL}   ]"
}

failure() {
  string=$1
  RT_SPA=$[$SPA_COL-${#string}]
  echo -n "$string"
  for I in `seq 1 $RT_SPA`;do
    echo -n " "
  done
  echo -e "[ ${RED}FAILED${NORMAL} ]"
}	
	
	
/etc/rc.d/init.d/tserver脚本，测试SysV服务的定义格式：
#!/bin/bash
#
# chkconfig: 35 66 33
# description: test service script
#
. /etc/rc.d/init.d/functions

prog=tserver
lockfile=/var/lock/subsys/$prog

start() {
  touch $lockfile
  [ $? -eq 0 ] && success "Starting $prog" || failure "Staring $prog"
}

stop() {
  rm -f $lockfile
  [ $? -eq 0 ] && success "Stopping $prog" || failure "Stopping $prog"
}

status() {
  if [ -f $lockfile ]; then
    echo "Running..."
  else
    echo "Stopped..."
  fi
}

usage() {
  echo "Usage: $prog {start|stop|status|restart}"
}

case $1 in
start)
  start ;;
stop)
  stop ;;
restart)
  stop 
  start
  ;;
status)
  status
  ;;
*)
  usage
  exit 1
  ;;
esac	
	
/etc/inittab文件示例：
id:3:initdefault:
si::sysinit:/etc/rc.d/rc.sysinit

l0:0:wait:/etc/rc.d/rc 0
l3:3:wait:/etc/rc.d/rc 3
l6:6:wait:/etc/rc.d/rc 6

1:2345:respawn:/sbin/agetty -n -l /bin/bash 38400 tty1
2:2345:respawn:/sbin/agetty -n -l /bin/bash 38400 tty2	
	

/etc/fstab文件示例：
/dev/sda2	/	ext3	defaults	0 0
/dev/sda1	/boot	ext3	defaults	0 0
proc		/proc	proc	defaults	0 0
sysfs		/sys	sysfs	defaults	0 0


/etc/rc.d/rc.sysinit脚本示例：
#!/bin/bash
#
echo -e "\tWelcome to \033[34mMageEdu\033[0m Linux"
. /etc/rc.d/init.d/functions

echo "Remount rootfs..."
mount -n -o remount,rw /
[ $? -eq 0 ] && success "Remount rootfs" || failure "Remount rootfs"
mount -a
[ $? -eq 0 ] && sucess "Mount others filesystem" || failure "Mount others filesystem"

echo "Set the hostname..."
[ -f /etc/sysconfig/network ] && . /etc/sysconfig/network
[ -z $HOSTNAME -o "$HOSTNAME" == '(none)' ] && HOSTNAME=localhost
/bin/hostname $HOSTNAME
[ $? -eq 0 ] && success "Set the hostname" || failure "Set the hostname"

echo "Initializing network device..."
/sbin/insmod /lib/modules/mii.ko
/sbin/insmod /lib/modules/pcnet32.ko
[ $? -eq 0 ] && success "Initializing network device" || failure "Initializing network device"

ifconfig lo 127.0.0.1/8
[ $? -eq 0 ] && success "Activating loopback network device" || failure "Activating loopback network device"

sysctl -p &> /dev/null
[ $? -eq 0 ] && success "Set kernel parameter" || failure "Set kernel parameter"


/etc/rc.d/rc脚本示例：
#!/bin/bash
#
RUNLEVEL=$1

for I in /etc/rc.d/rc$RUNLEVEL.d/K*; do
  $I stop
done

for I in /etc/rc.d/rc$RUNLEVEL.d/S*; do
  $I start
done	


1、关机和重启；
2、终端
3、主机名
4、IP地址(模块的装载和服务的实现)
5、functions

6、终端提示信息
/etc/issue文件的内容
***命令提示符的样式可以如下定义
[root@RHEL5 ~]# vim .bash_profile
PS1='[\u@\h \W]\$' （\u用户名，\h主机名，\W工作目录基名（小w是全名），\$表示管理员为#普通用户为$）
export PS1


7、rc.sysinit：挂载/etc/fstab中定义的其它文件系统；

8、设定内核参数
/etc/sysctl.conf

sysctl -p 重读配置生效


9、用户
用户的认证机制是通过基于PAM的多个配置文件来实现的，比较复杂，这里绕过PAM认证来作实验
PAM: Pluggable Authentication Module
/etc/pam.d/*

***login在编绎时就已经定义了其功能，不可能说在编绎时指定/etc/passwd、/etc/shadow、/etc/group等
        文件查询认证信息，而想要在另外的认证库中查询信息时重新编绎login，因此，为了应对login查
	询认证信息时更加灵活，就加了一个中介层nsswitch，然后根据nsswitch.conf配置文件到另外的文
	件或是数据库中查询用户信息。
	顺序是：login请求-->nsswitch.conf（指定多个文件时有优先级，在前面的优先）-->libnss_file.so（或者libnss_nis.so, libnsss_ldap.so）-->/etc/passwd...（或者 另外）
login: 验证

nsswitch: Network Service Switch
配置文件: /etc/nsswitch.conf
库：libnss_file.so, libnss_nis.so, libnsss_ldap.so
框架：/etc/passwd, /etc/shadow, /etc/group
	
库文件的位置：
[root@RHEL5 ~]# ls -l /lib/libnss*
-rwxr-xr-x 1 root root   36348 Mar 10  2010 /lib/libnss_compat-2.5.so
lrwxrwxrwx 1 root root      20 Mar 29 10:31 /lib/libnss_compat.so.2 -> libnss_compat-2.5.so
-rwxr-xr-x 1 root root  824548 Dec 11  2007 /lib/libnss_db-2.2.so
lrwxrwxrwx 1 root root      16 Mar 29 10:33 /lib/libnss_db.so.2 -> libnss_db-2.2.so
-rwxr-xr-x 1 root root   21876 Mar 10  2010 /lib/libnss_dns-2.5.so
lrwxrwxrwx 1 root root      17 Mar 29 10:31 /lib/libnss_dns.so.2 -> libnss_dns-2.5.so
[root@RHEL5 ~]# ls -l /usr/lib/libnss*
-rwxr-xr-x 1 root root 1188804 Jun 19  2009 /usr/lib/libnss3.so
-rwxr-xr-x 1 root root  373992 Jun 19  2009 /usr/lib/libnssckbi.so
lrwxrwxrwx 1 root root      28 Apr  5 12:51 /usr/lib/libnss_compat.so -> ../../lib/libnss_compat.so.2
lrwxrwxrwx 1 root root      24 Mar 29 10:33 /usr/lib/libnss_db.so -> ../../lib/libnss_db.so.2
lrwxrwxrwx 1 root root      25 Apr  5 12:51 /usr/lib/libnss_dns.so -> ../../lib/libnss_dns.so.2
lrwxrwxrwx 1 root root      27 Apr  5 12:51 /usr/lib/libnss_files.so -> ../../lib/libnss_files.so.2

***示例：
***这个login二进制是特制的，可以绕过PAM认证，方便实验
[root@RHEL5 ~]# cp login /mnt/sysroot/bin/

[root@RHEL5 ~]# cp -d /lib/libnss_files* /mnt/sysroot/lib/
cp: overwrite `/mnt/sysroot/lib/libnss_files-2.5.so'? y
cp: overwrite `/mnt/sysroot/lib/libnss_files.so.2'? y
[root@RHEL5 ~]# 
[root@RHEL5 ~]# cp -d /usr/lib/libnss_files.so /mnt/sysroot/usr/lib/
cp: overwrite `/mnt/sysroot/usr/lib/libnss_files.so'? y
[root@RHEL5 ~]# cp -d /usr/lib/libnss3.so /usr/lib/libnssckbi.so /usr/lib/libnss
libnss3.so         libnss_files.so    libnssutil3.so
libnssckbi.so      libnss_hesiod.so   libnss_winbind.so
libnss_compat.so   libnss_ldap.so     libnss_wins.so
libnss_db.so       libnss_nisplus.so  
libnss_dns.so      libnss_nis.so      
[root@RHEL5 ~]# cp -d /usr/lib/libnss3.so /usr/lib/libnssckbi.so /usr/lib/libnssutil3.so /mnt/sysroot/usr/lib/
cp: overwrite `/mnt/sysroot/usr/lib/libnss3.so'? y
cp: overwrite `/mnt/sysroot/usr/lib/libnssckbi.so'? y
cp: overwrite `/mnt/sysroot/usr/lib/libnssutil3.so'? y
[root@RHEL5 ~]# 
[root@RHEL5 ~]# vim /mnt/sysroot/etc/nsswitch.conf
passwd:     files
shadow:     files
group:      files
hosts:      files dns
[root@RHEL5 ~]# useradd hadoop
[root@RHEL5 ~]# passwd hadoop
[root@RHEL5 ~]# grep -E "^(root|hadoop)\>" /etc/passwd > /mnt/sysroot/etc/passwd
[root@RHEL5 ~]# grep -E "^(root|hadoop)\>" /etc/shadow > /mnt/sysroot/etc/
shadow
[root@RHEL5 ~]# grep -E "^(root|hadoop)\>" /etc/group > /mnt/sysroot/etc/group
[root@RHEL5 ~]# sync
[root@RHEL5 ~]# sync

10、单用户模式
exec /sbin/init S

busybox: 1M（可以模拟数百个命令）
Kernel: 

RHEL5, RHEL6
定制安装：
	自动化安装
	定制引导盘
	
mount
	-n: 挂载时不更新/etc/mtab文件;
	
cat /proc/mounts



脚本编程知识点：
1、变量中字符的长度：${#VARNAME}

2、变量赋值等：
${parameter:-word}：如果parameter为空或未定义，则变量展开为“word”；否则，展开为parameter的值；
[root@RHEL5 ~]# unset A
[root@RHEL5 ~]# echo ${A:-30}
30
[root@RHEL5 ~]# echo $A

[root@RHEL5 ~]# 

${parameter:+word}：如果parameter为空或未定义，不做任何操作；否则，则展开为“word”值；
[root@RHEL5 ~]# unset A
[root@RHEL5 ~]# A=10
[root@RHEL5 ~]# echo ${A:+30}
30
[root@RHEL5 ~]# echo $A
10
[root@RHEL5 ~]# 

${parameter:=word}：如果parameter为空或未定义，则变量展开为“word”，并将展开后的值赋值给parameter；
[root@RHEL5 ~]# unset A
[root@RHEL5 ~]# echo ${A:=30}
30
[root@RHEL5 ~]# echo $A
30
[root@RHEL5 ~]# 

${parameter:offset}
${parameter:offset:length}：取子串，从offset处的后一个字符开始，取lenth长的子串；
A=www.hao123.com
echo ${A:3}：表示从第4个开始到最后
.hao123.com

echo ${A:0-5}：表示从倒数第5个开始到最后
3.com

echo ${A:3:8}：表示从第4个开始往后共截8个字符
.hao123.
***脚本示例：
#!/bin/bash
#
for I in /etc/*;do
        String=${I:5:1}
        [ $String = 'p' ] && echo "$I"  

done

3、脚本配置文件
/etc/rc.d/init.d/服务脚本
服务脚本支持配置文件：/etc/sysconfig/服务脚本同名的配置文件
***怎么让服务脚本关联配置文件（一般情况下脚本与配置文件名称是一样的）
vim a.conf
TEST=hello,world

vim a.sh
#!/bin/bash
. /root/a.conf
TEST=${TEST:-info}
[ -n $TEST ] && echo "$TEST"

4、局部变量
local VAR_NAME=

a=1

test() {
  a=$[3+4]
}

test
for I in `seq $a 10`; do
  echo $I
done  

5、命令mktemp
创建临时文件或目录

mktemp /tmp/file.XX（XX系统可以自动改变数值，避免与其他文件重名）
	-d: 创建为目录
	
6、信号
kill -SIGNAL PID：发送信号到某个进程
	1: SIGHUP
	2: SIGINT
	9: SIGKILL
	15: SIGTERM
	
脚本中，能实现信号捕捉，但9和15无法捕捉

Ctrl+c: SIGINT

trap命令：捕捉信号
	trap 'COMMAND' SIGNAL...
#!/bin/bash
#
NET=192.168.3
trap 'echo "quit" ; exit 1' SIGINT
for I in {34..124};do
        if ping -c 1 -W 1 $NET.$I &> /dev/null;then
                echo "$NET.$I is up."
        else
                echo "$NET.$I is down."
        fi
done


任务计划：

1、在未来的某个时间点执行一次某任务；
	at
	batch
	
	at 时间：
	at> COMMAND
	at> Ctrl+d：提交
	
	指定时间：
		绝对时间：HH:MM， DD.MM.YY  MM/DD/YY
		相对时间：now+#
			单位：minutes, hours, days, weeks
		模糊时间：noon, midnight, teatime
	
	命令的执行结果：将以邮件的形式发送给安排任务的用户
	/etc/at.allow, /etc/at.deny：允许和不允许哪些用户使用at任务
	
	at -l = atq：显示队列
	at -d AT_JOB_ID = atrm  AT_JOB_ID：删除某个作业
			[root@RHEL5 ~]# at now+3
			syntax error. Last token seen: 3
			Garbled time
			[root@RHEL5 ~]# at now+3minutes
			at> ls /var
			at> cat /etc/fstab
			at> <EOT>
			job 1 at 2016-04-09 08:38
			[root@RHEL5 ~]# 
	
	
2、周期性地执行某任务；
	cron：自身是一个不间断运行的服务
	anacron: cron的补充，能够实现让cron因为各种原因在过去的时间该执行而未执行的任务在恢复正常执行一次；
	
	cron: 
		系统cron任务：系统任务就定义在以下的配置文件里面，跟用户没关系，比如系统清理垃圾、优化系统之类的。
			/etc/crontab
				分钟  小时  天  月  周  用户  任务
		用户cron任务：用户任务可以定义在以下配置文件里面，以用户名命名，但最好用crontab命令，此命令可以帮助检查语法错误 
			/var/spool/cron/USERNAME
				分钟  小时  天  月  周  任务
			
		时间的有效取值：
			分钟：0-59
			小时：0-23
			天：1-31
			月：1-12
			周：0-7，0和7都表示周日
			
		时间通配表示：
			*: 对应时间的所有有效取值
				3 * * * * 
				3 * * * 7
				13 12 6 7 *
			,: 离散时间点： 
				10,40 02 * * 2,5 
			-：连续时间点：
				10 02 * * 1-5
			/#: 对应取值范围内每多久一次
				*/3 * * * *
				
		每两小时执行一次：
			08 */2 * * *
		每两天执行一次：
			10 04 */2 * *
	
	执行结果将以邮件形式发送给管理员：
		*/3 * * * * /bin/cat /etc/fstab &> /dev/null 
		
	cron的环境变量：cron执行所有命令都去PATH环境变量指定的路径下去找，而一般用户自定义
			的环境变量cron找不到，所以执行cron时最好用绝对路径，而脚本里面则当
			场定义环境变量（export PATH=）
		PATH  /bin:/sbin:/usr/bin:/usr/sbin

	用户任务的管理：
		crontab
			-l: 列出当前用户的所有cron任务
			-e: 编辑 ，会帮助查语法错误
			-r: 移除所有任务
			-u USERNAME: 管理其他用户的cron任务
				[root@RHEL5 ~]# crontab -u hadoop -e
				no crontab for hadoop - using an empty one
				crontab: installing new crontab
				*/3 * * * * /bin/echo "How are you"
				[root@RHEL5 ~]# ls /var/spool/cron/
				hadoop
				[root@RHEL5 ~]# su hadoop
				[hadoop@RHEL5 root]$ crontab -l 
				*/3 * * * * /bin/echo "How are you"


			
	anacron：cron的补充，替代不了cron
		[root@RHEL5 ~]# cat /etc/anacrontab 
		# /etc/anacrontab: configuration file for anacron

		# See anacron(8) and anacrontab(5) for details.

		SHELL=/bin/sh
		PATH=/sbin:/bin:/usr/sbin:/usr/bin
		MAILTO=root

		1	65	cron.daily		run-parts /etc/cron.daily（已经有一天没执行了，在开机后65分钟执行一次）
		7	70	cron.weekly		run-parts /etc/cron.weekly（已经有七天没执行了，在开机后70分钟执行一次）
		30	75	cron.monthly		run-parts /etc/cron.monthly（已经有三十天没执行了，在开机后75分钟执行一次）
		
		[root@RHEL5 ~]# 
		[root@RHEL5 ~]# service crond status
		crond (pid  3179) is running...
		[root@RHEL5 ~]# service anacron status
		anacron is stopped（RHEL在服务器上运行的，一般不需要anacron，PC机上一般开启，要想执行任务计划，一定要开启任务计划）

	
***查看本机硬件设备信息：
1、cat /proc/cpuinfo

2、lsusb

3、lspci

4、hal-device
	Hardware Abstract Layer

Kernel + initrd(busybox制作，提供ext3文件系统模块) + ROOTFS (busybox制作)

make arch/：可以编绎内核核心
	arch/x86/boot/bzImage
make SUBDIR=arch/
make arch/x86/
	
	硬件驱动：initrd
		initrd: 仅需要提供内核访问真正的根文件系统所在设备需要的驱动
			存储设备和文件系统相关的模块
		系统初始化rc.sysinit: 初始其它硬件的驱动程序；
		
	ROOTFS: busybox, init不支持运行级别，但可以移植RHEL里面的init就有了
			/etc/inittab: 格式也不尽相同，如果是移植就得一一对应，因为编绎时已就定义好了
		busybox只有ash, hush，要bash就得移植，
****如何编译busybox-->组装小系统
[root@RHEL5 ~]# grub-install --root-directory=/mnt/ /dev/hda1
[root@RHEL5 ~]# cp /boot/vmlinuz-2.6.18-194.el5 /mnt/boot/vmlinuz
[root@RHEL5 ~]# cd /usr/src/
[root@RHEL5 src]# ls
busybox-1.20.2  debug  kernels  linux-2.6.38.5  redhat
[root@RHEL5 src]# mkdir busybox-1.20.2/include/mtd
[root@RHEL5 src]# cp /usr/src/linux-2.6.38.5/include/mtd/ubi-user.h busybox-1.20.2/include/mtd/
[root@RHEL5 src]# cd busybox-1.20.2/
[root@RHEL5 busybox-1.20.2]# make menuconfig
***只需将这一项选中改成静态编绎即可
 [*] Build BusyBox as a static binary (no shared libs)
[root@RHEL5 busybox-1.20.2]# make install
[root@RHEL5 busybox-1.20.2]# mkdir /tmp/initrd
[root@RHEL5 busybox-1.20.2]# cp _install/* /tmp/initrd/ -a
[root@RHEL5 busybox-1.20.2]# 
[root@RHEL5 busybox-1.20.2]# cd /tmp/initrd/
[root@RHEL5 initrd]# ls
bin  linuxrc  sbin  usr
[root@RHEL5 initrd]# rm -rf linuxrc 
[root@RHEL5 initrd]# mkdir proc sys mnt/sysroot dev tmp lib/modules etc -pv
mkdir: created directory `proc'
mkdir: created directory `sys'
mkdir: created directory `mnt'
mkdir: created directory `mnt/sysroot'
mkdir: created directory `dev'
mkdir: created directory `tmp'
mkdir: created directory `lib'
mkdir: created directory `lib/modules'
mkdir: created directory `etc'
***别的设备以后可以控测到，但是这两个预先要用的，所以手动创建
[root@RHEL5 initrd]# mknod dev/console c 5 1
[root@RHEL5 initrd]# mknod dev/null c 1 3
[root@RHEL5 initrd]# ls dev/ -l
total 8
crw-r--r-- 1 root root 5, 1 Apr 10 11:46 console
crw-r--r-- 1 root root 1, 3 Apr 10 11:46 null
[root@RHEL5 initrd]# 
[root@RHEL5 _install]# sbin/switch_root --help
BusyBox v1.20.2 (2016-04-10 11:40:52 EDT) multi-call binary.

Usage: switch_root [-c /dev/console] NEW_ROOT NEW_INIT [ARGS]

Free initramfs and switch to another root fs:
chroot to NEW_ROOT, delete all in /, move NEW_ROOT to /,
execute NEW_INIT. PID must be 1. NEW_ROOT must be a mountpoint.

	-c DEV	Reopen stdio to DEV after switch
[root@RHEL5 initrd]# vim init
#!/bin/sh
#
#这里要强调的是必须要挂载这两个伪文件系统，内核探测到硬件设备并通过这两个文件系统输出给用户空间
mount -t proc proc /proc
mount -t sysfs sysfs /sys

echo "Load ext3 modules..."
insmod /lib/modules/jbd.ko
insmod /lib/modules/ext3.ko

echo "Detect and export hardware informations..."
mdev -s

echo "Mount real rootfs to /mnt/sysroot..."
mount -t ext3 /dev/hda2 /mnt/sysroot

echo "Switch to real rootfs..."
exec switch _root /mnt/sysroot /sbin/init
[root@RHEL5 initrd]# chmod +x init 
[root@RHEL5 initrd]# ls 
bin  dev  etc  init  lib  mnt  proc  sbin  sys  tmp  usr
[root@RHEL5 initrd]# modinfo ext3
filename:       /lib/modules/2.6.18-194.el5/kernel/fs/ext3/ext3.ko
license:        GPL
description:    Second Extended Filesystem with journaling extensions
author:         Remy Card, Stephen Tweedie, Andrew Morton, Andreas Dilger, Theodore Ts'o and others
srcversion:     4892892BC4F1C4BCF3E12BD
depends:        jbd
vermagic:       2.6.18-194.el5 SMP mod_unload 686 REGPARM 4KSTACKS gcc-4.1
module_sig:	883f3504ba0374c1e1fa4939f6a6293112c5b209e271a375ce142129d4c7c5e14d5bc0bd95e6144a0a0e481e143a1356258150a76edb91e87449ea4999
[root@RHEL5 initrd]# modinfo jbd
filename:       /lib/modules/2.6.18-194.el5/kernel/fs/jbd/jbd.ko
license:        GPL
srcversion:     E70A64C9E8C56BDB65DABF4
depends:        
vermagic:       2.6.18-194.el5 SMP mod_unload 686 REGPARM 4KSTACKS gcc-4.1
module_sig:	883f3504ba0374c1e1fa4939f6a629311268b30a0c3cee95f963cb7b69bce6ac4ed7a75e8ebd1e50a08f75217224626608ea438a8364acac74fc8e3f
***一定要注意，这些模块的版本一定要跟内核的版本匹配
[root@RHEL5 initrd]# cp  /lib/modules/2.6.18-194.el5/kernel/fs/jbd/jbd.ko lib/modules/
[root@RHEL5 initrd]# cp /lib/modules/2.6.18-194.el5/kernel/fs/ext3/ext3.ko lib/modules/
[root@RHEL5 initrd]# 
[root@RHEL5 initrd]# find . | cpio -H newc --quiet -o | gzip -9 > /mnt/boot/initrd.gz
[root@RHEL5 initrd]# cd /mnt/boot/
[root@RHEL5 boot]# vim grub/grub.conf
default=0
timeout=3
title Yuliang Linux (2.6.18)
        root(hd0,0)
        kernel /vmlinuz ro root=/dev/hda2
        initrd /initrd.gz
***下面就制作根文件系统
[root@RHEL5 boot]# cp /usr/src/busybox-1.20.2/_install/* /mnt/sysroot/ -a
cp: overwrite `/mnt/sysroot/linuxrc'? y
[root@RHEL5 boot]# cd /mnt/sysroot/
[root@RHEL5 sysroot]# ls
bin  linuxrc  lost+found  sbin  usr
[root@RHEL5 sysroot]# rm -rf linuxrc 
[root@RHEL5 sysroot]# 
[root@RHEL5 sysroot]# mkdir boot root etc/rc.d/init.d var/{log,lock,run} proc sys dev lib/modules tmp home mnt media -pv
[root@RHEL5 sysroot]# mknod dev/console c 5 1
[root@RHEL5 sysroot]# mknod dev/null c 1 3
[root@RHEL5 sysroot]# vim etc/inittab
::sysinit:/etc/rc.d/rc.sysinit
console::respawn:-/bin/sh
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
[root@RHEL5 sysroot]# vim etc/rc.d/rc.sysinit
#!/bin/sh
#
echo -e "\tWelcome to \033[34mYuliang Little\033[0m Linux"

echo "Remount the rootfs..."
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t ext3 -o remount,rw /dev/hda2 /

echo "Mount the others filesystem..."
mount -a
[root@RHEL5 sysroot]# chmod +x etc/rc.d/rc.sysinit 
[root@RHEL5 sysroot]# vim etc/fstab
sysfs                   /sys                    sysfs   defaults        0 0
proc                    /proc                   proc    defaults        0 0
/dev/hda1               /boot                   ext3    defaults        0 0
/dev/hda2               /                       ext3    defaults        1 1
[root@RHEL5 sysroot]# sync
[root@RHEL5 sysroot]# sync




Linux上的日志系统
	RHEL7以前的日志系统
syslog
syslog-ng: 开源

日志系统：syslog()
syslog服务：由两个守护进程(klogd、syslogd)和一个配置文件(syslog.conf)组成，klogd不使用配置文件

	
klogd
kernel --> 物理终端(/dev/console) --> /var/log/dmesg
# dmesg：此命令产生的信息与/var/log/dmesg相似
# cat /var/log/dmesg:记载内核探测到的硬件、驱动等信息，也就是在init执行前记录的信息

syslogd
/sbin/init ：启动之后的信息记录在以下文件中
	/var/log/messages: 系统标准错误日志信息；非内核产生引导信息；各子系统产生的信息；
	/var/log/maillog: 邮件系统产生的日志信息；
	/var/log/secure: 关于系统安全记录

日志需要滚动(日志切割)：避免日志大，耗内存，后缀越大历史越久
logrotate命令可以借助自己的配置文件/etc/logrotate.conf来定义滚动方法
messages messages.1 messages.2 messages.3


syslog: syslogd和klogd
信息详细程序：子系统（facility），日志级别（priority），动作（action）

配置文件定义格式为: facility.priority        action 
 facility,可以理解为日志的来源或设备目前常用的facility有以下几种： 
    auth      			# 认证相关的 
    authpriv  			# 权限,授权相关的 
    cron      			# 任务计划相关的 
    daemon    			# 守护进程相关的 
    kern      			# 内核相关的 
    lpr      			 # 打印相关的 
    mail     			 # 邮件相关的 
    mark     			 # 标记相关的 
    news     			 # 新闻相关的 
    security 			# 安全相关的,与auth 类似  
    syslog  			 # syslog自己的 
    user    			 # 用户相关的 
    uucp    			 # unix to unix cp 相关的 
    local0 到 local7 	# 用户自定义使用 
    *        			# *表示所有的facility 

 
 priority(log level)日志的级别,一般有以下几种级别(从低到高) 
    debug           # 程序或系统的调试信息 
    info            # 一般信息
    notice          # 不影响正常功能,需要注意的消息 
    warning/warn    # 可能影响系统功能,需要提醒用户的重要事件 
    err/error       # 错误信息 
    crit            # 比较严重的 
    alert           # 必须马上处理的 
    emerg/panic     # 会导致系统不可用的 
    *               # 表示所有的日志级别 
    none            # 跟* 相反,表示啥也没有 
     
 action(动作)日志记录的位置 
    系统上的绝对路径    # 普通文件 如： /var/log/xxx 
    |                   # 管道  通过管道送给其他的命令处理 
    终端              # 终端   如：/dev/console 
    @HOST               # 远程主机记录日志 如： @10.0.0.1      
    用户              # 系统用户 如： root 
    *                   # 登录到系统上的所有用户，一般emerg级别的日志是这样定义的 
    -			# 表示异步写入

定义格式例子： 
mail.info   /var/log/mail.log # 表示将mail相关的,级别为info及info以上级别的信息记录到/var/log/mail.log文件中 
auth.=info  @10.0.0.1         # 表示将auth相关的,级别为info的信息记录到10.0.0.1主机上去前提是10.0.0.1要能接收其他主机发来的日志信息 
user.!=error                  # 表示记录user相关的,不包括error级别的信息 
user.!error                   # 与user.error相反 
*.info                        # 表示记录所有的日志信息的info级别 
mail.*                        # 表示记录mail相关的所有级别的信息 
*.*                           # 你懂的. 
cron.info;mail.info           # 多个日志来源可以用";" 隔开 
cron,mail.info                # 与cron.info;mail.info 是一个意思 
mail.*;mail.!=info            # 表示记录mail相关的所有级别的信息,但是不包括info级别的 

RHEL7以后的日志系统
	两个服务组成：
	systemd-journald
		改进的日志系统，记录各项守护进程中的启动、运行及相关信息
		按一定标准、结构记录、持续性记录、不漏记
		将所有信息集中记录在一个数据库中
		将系统消息通过systemd-journald传到rsyslog上进行进一步处理
			如此，systemd-journald需要更早启动起来，记录内核初
			始化阶段、内存初始化阶段、前期启动步骤以及主要系统执
			行过程的日志
	rsyslogd
		多线程
		UDP、TCP、SSL、TLS、RELP；
		MySQL、PGSQL、Oracle实现志存储
		强大的过滤器，可实现过滤日志信息中任何部分
		自定义输出格式
		
		网上有一个elasticsearch专业的分布式日志管理系统
			elasticsearch,logstash,kibana = elk

		通过logrotate的相关配置及其命令，来实现周期性的检测信息并将这些信处
		写入/var/log
		/var/log
			message格式：
				产生日志时间
				哪个主机所发送的日志消息
				哪个服务或进程所发送的日志消息
				消息内容
			secure
				安全认证相关
			mail
				邮件相关
			cron
				计划任务相关
			boot.log
				系统启动相关
		rsyslog配置文件/etc/rsyslog.conf
			配置格式跟RHEL7以前相同，见上
		target:
			文件件路径：记录于指定的日志文件中，通常应该是/var/log目录下，-导步写入
			用户：将日志通知给指定用户
				*：所有用户
			日志服务器：@host
				host：必须要监听在tcp或udp协议514端口上提供服务
			管道：| COMMAND
			有些二进制格式：wtmp、btmp
				/var/log/wtmp：当前系统上成功登录的日志
					last显示
				/var/log/btmp：当前系统上失败登录的日志
					lastb显示

					lastlog：当前所有用户最近一次登陆的情况

		
	logger命令：
		logger [选项] [消息]
		logger -t kern -p err 'hello, the world'
	logrotate命令：
		对日志文件进行周期检测优化
		可能在周期执行间隙，文件已快速增长超过预期
		logrotate [选项] config_file
			-v: 打开详细模式
			-d: 打开调试模式
			-f：告诉logrotate强制轮调
		#vim /etc/logrotate.d/test
			/var/log/test.log {
				missingok
				rotate 5
				size 1K
				create 0640 root root
			}
		dd if=/dev/zero of=/var/log/test.log bs=1024 count=1000
		#logrotate -v /etc/logrotate.conf
		#ls -l /var/log/test.log*
	journalctl命令：
		journalctl [ 选项 ] [ 标记 ]
		# journalctl 查看当前系统日志
		# journalctl -n 5 显示最新的5条日志记录
		# journalctl -p err 仅列示出err的错误信息
		# journalctl -f 实时查看日志信息
		# journalctl --since today 查看今天的日志
		# journalctl --yesterday 查看昨天
		# journalctl --since "2014-09-09" --until "2014-09-15" 查看时间段
		# journalctl --since "2014-09-09 12:00:00" --until "2014-09-15 13:00:00"
		# journalctl -o verbose -n 10 显示10个服务/进程的详细信息
		# journalctl --since 9:00 _SYSTEMD_UNIT=sshd.service
		# journalctl -b 查看从系统启动后的全部信息
		# journalctl -k,--dmesg 显示kernel信息
		# man systemd.journal-fields 查看更多的指定单元的信息
	systemd命令
		# systemd-analyze 显示本次启动系统过程中用户、initrd及kernel所花费的时间
		# systemd-analyze blame 显示每个启动项所花费的时间明细
		# systemd-analyze critical-chain 按时间顺序打印UNIT树
		# systemd-analyze plot > bootplot.svg
		# systemd-analyze dot | dot -Tsvg > systemd.svg 为开机启动过程生成向量图
			需要graphviz软件包
			颜色标识：
				黑色(black)：需要启动相关关联
				深蓝(dark blue)：必须
				深灰(black grey)：需求
				红色(red)：冲突
				绿色(green)：after（之后）
	实验一：自定义日志，找一个有日志定义的服务，如sshd
		sshd Server：sshd_conf加一行
			SyslogFacility	local2
		rsyslog：rsyslog.conf加一行
			local2.*	/var/log/sshd.log
		可验证
		
	实验二：远程记录日志，记录在/var/log/message下
		Server端：开启tcp/udp端口
			# Provides UDP syslog reception
			$ModLoad imudp
			$UDPServerRun 514

			# Provides TCP syslog reception
			$ModLoad imtcp
			$InputTCPServerRun 
		Client端：在rsyslog.conf里写一行
			*.info;mail.none;authpriv.none;cron.none        @192.168.154.66
	实验三：mysql记录日志
		[root@RHEL6 ~]# yum install rsyslog-mysql
		[root@RHEL6 ~]# rpm -ql rsyslog-mysql
		/lib64/rsyslog/ommysql.so
			主要是加载这个模块支持记录在mysql
		/usr/share/doc/rsyslog-mysql-5.8.10
		/usr/share/doc/rsyslog-mysql-5.8.10/createDB.sql
			在mysql中要执行的脚本
		[root@localhost ~]# yum install mariadb mariadb-server
			MariaDB [(none)]> grant all on Syslog.* to 'syslog'@'192.168.%.%' identified by 'syslogpass';
		[root@RHEL6 ~]# mysql -usyslog -h192.168.154.66 -p < /usr/share/doc/rsyslog-mysql-5.8.10/createDB.sql
		Enter password: 
		[root@RHEL6 ~]#
		------在rsyslog.conf中的module区块(位置不能乱放)-------
			$ModLoad ommysql
			
		-------再加一个日志方式-------
			:ommysql:192.168.154.66,Syslog,syslog,syslogpass
		配置loganalyzer
			1、配置httpd,php
			2、cp -r loganalyzer-3.6.5/src /var/www/html/loganalyzer
			   cp loganalyzer-3.6.5/contrib/*.sh /var/www/html/loganalyzer
			   cd /var/www/html/loganalyzer
			   chmod +x *.sh
			   ./configure.sh
			   ./secure.sh
			   chmod 666 config.php



telnet: 远程登录协议， 23/tcp
	C/S
	S：telnet服务器
	C：telnet客户端
	
ssh: Secure SHell， 应用层协议，22/tcp	
	通信过程及认证过程是加密的，主机认证
	用户认证过程加密
	数据传输过程加密
	
ssh： version1, version2
 man-in-middle：version1避免不了中间人攻击，最好用sshv2
 
认证过程：
	基于口令认证：
	基于密钥认证:
	
协议：规范
实现：服务器端、客户端

Linux: openSSH
	C/S
		服务器端：sshd, 配置文件/etc/ssh/sshd_config
		客户端：ssh, 配置文件/etc/ssh/ssh_config
			ssh-keygen: 密钥生成器
			ssh-copy-id: 将公钥传输至远程服务器（它会自动将密钥保存到对应位置）
			scp：跨主机安全复制工具
				
			
		ssh: 想以远程主机中的某个用户登陆，可以用如下三种方式
			ssh USERNAME@HOST
			ssh -l USERNAME HOST
			ssh USERNAME@HOST 'COMMAND'
			
		scp: 两主机之间加密传输文件
			scp SRC DEST
				-r
				-a
			scp USERNAME@HOST:/path/to/somefile  /path/to/local
			scp /path/to/local  USERNAME@HOST:/path/to/somewhere
			
		ssh-keygen
			-t rsa：加密方式	
				~/.ssh/id_rsa：私钥所在地
				~/.ssh/id_rsa.pub：公钥所在地
			-f /path/to/KEY_FILE：直接指定密钥文件所在地，创建过程就不会询问
			-P '': 指定加密私钥的密码
		基于密钥的认证方式：
		公钥追加保存到远程主机某用户的家目录下的.ssh/authorized_keys文件或.ssh/authorized_keys2文件中

		ssh-copy-id：指定主机即可，它会自动将密钥保存到对应位置
			-i ~/.ssh/id_rsa.pub
			ssh-copy-id -i ~/.ssh/id_rsa.pub USERNAME@HOST
			
dropbear: 嵌入式系统专用的ssh服务器端和客户端工具
	服务器端：dropbear
		  dropbearkey：生成主机密钥
	
	客户端：dbclient
		   
	dropbear默认使用nsswitch实现名称解析
		/etc/nsswitch.conf
		/lib/libnss_files*
		/usr/lib/libnss3.so
		/usr/lib/libnss_files*
		
	dropbear会在用户登录检查其默认shell是否当前系统的安全shell
		/etc/shells 所以在系统里面要创建此文件
				
	主机密钥默认位置：
		/etc/dropbear/
			RSA: dropbear_rsa_host_key
				长度可变, 只要是8的整数倍，默认为1024
			DSS: dropbear_dss_host_key
				长度固定，默认为1024
		dropbearkey
			-t rsa|dsa 
			-f /path/to/KEY_FILE
			-s SIZE

sudo命令: 某个用户能够以另外哪一个用户的身份通过哪些主机执行什么命令
	-l: 列出当前用户可以使用的所有sudo类命令
	-k: 让认证信息失效
sudo的配置文件/etc/sudoers
visudo命令：专门编辑/etc/sudoers，可以查语法错误，避免并发访问系统崩溃
sudo条目：who	which_hosts=(runas)	command
为了管理方便， 这些条目可以定义别名，相当于组的概念
who: User_Alias
which_hosts: Host_Alias
runas: Runas_Alias
command: Cmnd_Alias
别名必须全部而且只能使用大写英文字母的组合
[root@RHEL5 ~]# visudo 
添加一行sudo条目：
hadoop  ALL=(root)      /usr/sbin/useradd, /usr/sbin/usermod（一定要是绝对路径）
如果不想每次都输入密码，可以在命令前加标签
hadoop  ALL=(root)      NOPASSWD:/usr/sbin/useradd, PASSWD:/usr/sbin/userdel
[root@RHEL5 ~]# su - hadoop
[hadoop@RHEL5 ~]$ sudo /usr/sbin/useradd tom
[sudo] password for hadoop: hadoop自己的密码 
[hadoop@RHEL5 ~]$
***如果加上标签NOPASSWD，则NOPASSWD后面所有的命令都不要密码（加PASSWD也无效，想部分加部分不加就要排好顺序）
[root@RHEL5 ~]# visudo 
[root@RHEL5 ~]# su - hadoop
[hadoop@RHEL5 ~]$ sudo /usr/sbin/useradd jerry
[hadoop@RHEL5 ~]$ 

用户别名：
User_Alias USERADMIN=
	用户的用户名
	组名，使用%引导
	还可以包含其它已经用户别名
Host_Alias
	主机名
	IP
	网络地址
	其它主机别名
Runas_Alias
	命令路径
	目录（此目录内的所有命令）
	其它事先定义的命令别名
***别名应用
[root@RHEL5 ~]# visudo
User_Alias USERADMIN=hadoop, %hadoop, %useradmin（%为组）
Cmnd_Alias USERADMINCMND=/usr/sbin/useradd, /usr/sbin/usermod, /usr/sbin/userdel, /usr/bin/passwd [A-Za-z]*, ! /usr/bin/passwd root（排除改root密码）
USERADMIN	ALL=(root)	NOPASSWD: USERADMINCMND
[root@RHEL5 ~]# 
***强调一个! /usr/bin/passwd root对于/usr/bin/passwd没用，而/usr/bin/passwd不接参数默认就是对root

script可以linux屏幕录像