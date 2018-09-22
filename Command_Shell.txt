CPU硬件架构及历史
1971年历史第一颗CPU 4044
	2300个晶体管、4位
1978年i8086、i8087
	指令集相互兼容 称x86指令集 16位
1979年8088芯片
	第一块成功用于个人电脑
1982年80286芯片
	数据总线16位、地址总线24位、寻址16MB内存
1985年80386芯片
	内部外部数据总线都是32位、寻址4GB内存
1989年80486芯片
	第一次晶体管集成120万个，一个时钟周期执行2条指令
--------------------------------------------------------------
90年代末intel引入MMX技术CPU可超频
P4、P5、至强四核 、酷睿四核、I7、I3、I5

90年代末intel投资64位处理器研发放弃x86体系，最终失败；AMD研发出兼容x86前期产品的64位CPU，终于出头

相同生产线下的主频越高速度越快
	工艺不同、效果完全不同
	前期CPU与主板速度一样
		后期CPU变快，主板外频X倍数就是现在CPU的计算速度
前端总线频率FSB
	CPU与内存交换的频率
	FSB:400MHz
	(400x64bit)/8bit/Byte=3200MB
缓存：L2、L3高速数据交换
SMP：对称多处理器（服务器）
--------------------------------------------------------------
Linux的基本原则：
1、由目的单一的小程序组成；组合小程序完成复杂任务；
2、一切皆文件；
3、尽量避免捕获用户接口；
4、配置文件保存为纯文本格式；

GUI接口：图形化
CLI接口：命令行
	命令提示符，prompt, bash(shell)
		#: root
		$: 普通用户
	命令：

命令格式：
	命令  选项  参数
		选项：
			短选项： -
				多个选项可以组合：-a -b = -ab
			长选项： --
		参数：命令的作用对象
			
虚拟终端(terminal)：Ctrl+Alt+F1-F6

密码复杂性规则：
Linuxedu@126.com
	1、使用4种类别字符中至少3种；
	2、足够长，大于7位；
	3、使用随机字符串；
	4、定期更换；
	5、循环周期足够大；
	
认证机制：Authentication
授权：Authorization
审计：Audition (日志)

命令基本格式：
# command  options...  arguments...
ls
	-l：长格式
		文件类型：
			-：普通文件 (f)
			d: 目录文件
			b: 块设备文件 (block)
			c: 字符设备文件 (character)
			l: 符号链接文件(symbolic link file)
			p: 命令管道文件(pipe)
			s: 套接字文件(socket)
		文件权限：9位，每3位一组，每一组：rwx(读，写，执行), r--
		文件硬链接的次数
		文件的属主(owner)
		文件的属组(group)
		文件大小(size)，单位是字节
		时间戳(timestamp)：最近一次被修改的时间
			访问:access
			修改:modify，文件内容发生了改变
			改变:change，metadata，元数据
	-h：做单位转换(KB,MB,GB)
	-a: 显示以.开头的隐藏文件
		. 表示当前目录
		.. 表示父目录
	-A: 显示隐藏文件，但不包含 . 或 ..
	-d: 显示目录自身属性
	-i: index node, inode
	-r: 逆序显示
	-R: 递归(recursive)显示
	
cd: change directory
	家目录，主目录, home directory
	cd ~USERNAME: 进入指定用户的家目录
	cd -:在当前目录和前一次所在的目录之间来回切换

命令类型：
	内置命令(shell内置)，内部，内建
	外部命令：在文件系统的某个路径下有一个与命令名称相应的可执行文件
	
环境变量：命名的内存空间
	变量赋值
		NAME=Jerry
		
	PATH: 使用冒号分隔的路径
	O(1)

type: 显示指定属于哪种类型
	type: type [-afptP] name [name ...]
	Display information about command type.
	
date：时间管理
	-R, --rfc-2822
              output date and time in RFC 2822 format.  Example: Mon, 07 Aug 2006 12:34:56 -0600
	-u
	   UTC(Universal Time Coordinated)
		与GMT含义一样
		CST是我们自己的标准时间
date [+format]
	[root@localhost ~]# date +%c
	Mon 23 Oct 2017 05:37:33 PM EDT
	[root@localhost ~]# 

	%s 以1970年1月1日0时0分开始计算到目前所经过的时间
	%j 显示一年中的第几天 %M 分钟(00-59)
	[root@localhost ~]# date +%D
	10/24/17
	[root@localhost ~]# date +%A
	Tuesday
	[root@localhost ~]# date +%H
	14
	[root@localhost ~]# date +%H%D
	1410/24/17
	[root@localhost ~]# 

例：1. 查看1945年8月15日是星期几(当前时间为2017-10-24)
	[root@localhost ~]# date -d "-72 year -2 month -9 days"
	Wed Aug 15 15:01:16 CST 1945
	[root@localhost ~]#
    2. 查看2045年8月15日是星期几(当前时间为2017-10-24)
	[root@localhost ~]# date -d "+28 years -2 months -9 days"
	Tue Aug 15 15:30:11 CST 2045
	[root@localhost ~]# 
    3. 查看2015-9-9距1970-1-1多少秒
	[root@localhost ~]# date -d "2015-10-25" +%s
	1445702400
	[root@localhost ~]# 
Linux: rtc

	硬件时钟
	系统时钟

hwclock 硬件时钟
	hwclock -w systohc
	hwclock -s hctosys

tzselect 时区选择
	[root@localhost ~]# tzselect 
	Please identify a location so that time zone rules can be set correctly.
	Please select a continent or ocean.
	 1) Africa
	 2) Americas
	 3) Antarctica
	 4) Arctic Ocean
	 5) Asia
	 6) Atlantic Ocean
	 7) Australia
	 8) Europe
	 9) Indian Ocean
	10) Pacific Ocean
	11) none - I want to specify the time zone using the Posix TZ format.
	#? 

timedatectl 显示各项时间
	[root@localhost ~]# timedatectl 
	      Local time: Tue 2017-10-24 15:36:43 CST
	  Universal time: Tue 2017-10-24 07:36:43 UTC
		RTC time: Tue 2017-10-24 07:36:43
		Timezone: n/a (CST, +0800)
	     NTP enabled: n/a
	NTP synchronized: no
	 RTC in local TZ: no
	      DST active: n/a
	[root@localhost ~]# 
显示系统所支持的时间区域
	[root@localhost ~]# timedatectl list-timezones | more
	Africa/Abidjan
	Africa/Accra
	Africa/Addis_Ababa
	Africa/Algiers
	........
设置当前时区
	[root@localhost ~]# timedatectl set-timezone Asia/Shanghai
	[root@localhost ~]# 
设置当前系统时间
	[root@localhost ~]# timedatectl set-time "2017-9-9 12:00:00"
	[root@localhost ~]# date
	Sat Sep  9 12:00:01 CST 2017
	[root@localhost ~]# 
设置ntp时间同步是否开启（前提ntp服务器开启）
	[root@localhost ~]# timedatectl set-ntp true


获得命令的使用帮助：
内部命令：
	help COMMAND
外部命令：
	COMMAND --help
	
命令手册：manual
man COMMAND

whatis COMMAND

分章节：
1：用户命令(/bin, /usr/bin, /usr/local/bin)
2：系统调用
3：库用户
4：特殊文件(设备文件)
5：文件格式(配置文件的语法)
6：游戏
7：杂项(Miscellaneous)
8: 管理命令(/sbin, /usr/sbin, /usr/local/sbin)

<>：必选
[]：可选
...：可以出现多次
|：多选一
{}：分组

MAN：
	NAME：命令名称及功能简要说明
	SYNOPSIS：用法说明，包括可用的选项
	DESCRIPTION：命令功能的详尽说明，可能包括每一个选项的意义
	OPTIONS：说明每一个选项的意义
	FILES：此命令相关的配置文件
	BUGS：
	EXAMPLES：使用示例
	SEE ALSO：另外参照

翻屏：
	向后翻一屏：SPACE
	向前翻一屏：b
	向后翻一行：ENTER
	向前翻一行：k

查找：
/KEYWORD: 向后
n: 下一个
N：前一个 

?KEYWORD：向前
n: 下一个
N：前一个 

q: 退出

练习：
	使用date单独获取系统当前的年份、月份、日、小时、分钟、秒
	
hwclock
	-w: 系统时钟到硬件
	-s: 硬件时钟到系统


cal: calendar

练习：
1、echo是内部命令还是外部命令？
2、其作用？
3、如何显示“The year is 2013. Today is 26.”为两行？

转义，逃逸

练习：
1、printf是内部命令还是外部命令？
2、其作用？
3、如何显示“The year is 2013. Today is 26.”为两行？

文件系统：
rootfs: 根文件系统

FHS：Linux

/boot: 系统启动相关的文件，如内核、initrd，以及grub(bootloader)
/dev: 设备文件
	设备文件：
		块设备：随机访问，数据块
		字符设备：线性访问，按字符为单位
		设备号：主设备号（major）和次设备号（minor）
/etc：配置文件
/home：用户的家目录，每一个用户的家目录通常默认为/home/USERNAME
/root：管理员的家目录；
/lib：库文件
	静态库,  .a
	动态库， .dll, .so (shared object)
	/lib/modules：内核模块文件
/media：挂载点目录，移动设备
/mnt：挂载点目录，额外的临时文件系统
/opt：可选目录，第三方程序的安装目录
/proc：伪文件系统，内核映射文件
/sys：伪文件系统，跟硬件设备相关的属性映射文件
/tmp：临时文件, /var/tmp
/var：可变化的文件
/bin: 可执行文件, 用户命令
/sbin：管理命令

/usr：shared, read-only
	/usr/bin
	/usr/sbin
	/usr/lib
	
/usr/local：（可理解为第三方软件的共享程序，不影响操作系统）
	/usr/local/bin
	/usr/local/sbin
	/usr/local/lib

命名规则：
1、长度不能超过255个字符；
2、不能使用/当文件名
3、严格区分大小写
	
mkdir：创建空目录
	-p: 没有的目录自动创建（mkdir -p m/n/p，自动创建m n p目录)
	-v: verbose （显示详尽信息，显示创建过程）
/root/x/y/z

/mnt/test/x/m,y
mkdir -pv /mnt/test/x/m /mnt/test/y
mkdir -pv /mnt/test/{x/m,y}

~USERNAME 

命令行展开：
/mnt/test2/
a_b, a_c, d_b, d_c
(a+d)(b+c)=ab+ac+db+dc
{a,d}_{b,c}


# tree：查看目录树

删除目录：rmdir (remove directory)
	删除空目录
	-p
	
文件创建和删除
# touch	改变时间戳
	-a: change only the access time
	-m: change only the modification time
	-t STAMP
              use [[CC]YY]MMDDhhmm[.ss] instead of current time
	-c, --no-create
              do not create any files
# stat  查看时间戳
stat 查看文件详细状态
	[root@localhost ~]# stat -f /
	  File: "/"
	    ID: b53d57595370a614 Namelen: 255     Type: ext2/ext3
	Block size: 4096       Fundamental block size: 4096
	Blocks: Total: 2547534    Free: 2303699    Available: 2172627
	Inodes: Total: 655360     Free: 627590
	[root@localhost ~]# 

删除文件：rm
	-i：在删除文件之前需要手工确认
	-f: force 强制删除，不问yes or no
	-r: recursive 递归，删除目录下面所有的目录及文件
	
rm -rf / :删除所有的根文件，是致命的命令

练习：
1、创建目录
(1)在/mnt下创建boot和sysroot；
(2)在/mnt/boot下创建grub；
(3)在/mnt/sysroot下创建proc, sys, bin, sbin, lib, usr, var, etc, dev, home, root, tmp
	a)在/mnt/sysroot/usr下创建bin, sbin, lib
	b)在/mnt/sysroot/lib下创建modules
	c)在/mnt/sysroot/var下创建run, log, lock
	d)在/mnt/sysroot/etc下创建init.d
	

复制和移动文件
cp： copy
cp SRC DEST
	-r：递归，将目录及文件一次性复制到目的地
	-i：cp 是 cp -i 的别名，就是覆盖前提示
	-f
	-p：保留属主，属组
	-a：归档复制，常用于备份
	

cp file1 file2 file3
一个文件到一个文件
多个文件到一个目录
cp /etc/{passwd,inittab,rc.d/rc.sysinit} /tmp/

mv [选项] 源文件 目的路径
	-i 如果目的地有相同文件名时会出现提示
	-v 在搬移文件时显示进度，在移动多文件
	时非常有用
	-u 当移动时只有源文件比目的文件新的时候才会移动或者目标文件消失才移动
	-f 强制覆盖已有的文件
	

install
	-d DIRECOTRY ... ：创建目录
	SRC DEST
install -t DIRECTORY SRC...

作业1：
1、创建目录/backup
# mkdir -v /backup
2、复制目录/etc至/backup目录中，并重命名为“etc-当前日期”，如etc-2013-02-26；要求保留文件原来的属性，保持链接文件；
cp
	-r 
	-p
	-d
# cp -a /etc /backup/etc-2013-02-28

命令替换
	
3、复制文件/etc/inittab为/tmp/inittab.new，并删除inittab.new文件的后两行；
# cp /etc/inittab  /tmp/inittab.new
# nano /tmp/inittab.new

作业4：
1、如何获取Linux当前最新的内核版本号？
	www.kernel.org
2、列出你所了解的Linux发行版，并说明其跟Linux内核的关系。
	Linux, GNU: GNU/Linux, 源代码
	
	发行版：Fedora, RedHat(CentOS), SUSE, Debian(Ubuntu, Mint), Gentoo, LFS(Linux From Scratch)
	
目录管理：
ls、cd、pwd、mkdir、rmdir、tree

文件管理：
touch、stat、file、rm、cp、mv、nano

日期时间：
date、clock、hwclock、cal

查看文本：
cat、tac、more、less、head、tail

cat：连接并显示
	-s 将多个空行合并成一个空行输出
	-b 显示文件内容的时候显示行数
	-n：显示行号
	-E：Linux中换行符为$，而windows是dollar符加换行符，linux的文本在windows中只显示一行
tac：倒序显示（作特殊用途）	

Ctrl+c

分屏显示：
more、less

more [选项] 文件名
	+行数  直接从给定的行数开始显示
	-s 将多个空行压缩成一个空行
	-p 清除屏幕后再显示

head [选项] 文件
	-n <行数> 显示文件的最前指定的行
	-c <字节数> 显示文件前N个字节数里的内容
	-q 不输出文件头的内容
	-v 输出文件头的内容
	[root@localhost ~]# head -10 -v /etc/fstab 
	==> /etc/fstab <==

	#
	# /etc/fstab
	# Created by anaconda on Mon Oct 23 14:49:30 2017
	#
	# Accessible filesystems, by reference, are maintained under '/dev/disk'
	# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
	#
	UUID=debeb2cd-b005-4c53-87e9-8f78a4a33c00 /                       ext3    defaults        1 1
	UUID=732a5dec-be83-4581-bba0-29395eed3552 /boot                   xfs     defaults        0 0
	[root@localhost ~]# 

tail [选项] 文件
	-f 循环读取
	-c <字节数> 显示文件前N个字节数里的内容
	-q 不输出文件头的内容
	-n <行数> 指定所显示的行数
	-v 输出文件头的内容

diff [选项] file1 file2
	显示信息:
	a 为需要附加
	d 为需要删除
	c 为需要修改
	[root@localhost ~]# diff a.txt b.txt 
	4d3
	< d
	7c6
	< this is what we want
	---
	> you know that's tough
	[root@localhost ~]# cat a.txt 
	a
	b
	c
	d
	1
	2
	this is what we want
	[root@localhost ~]# cat b.txt 
	a
	b
	c
	1
	2
	you know that's tough
	[root@localhost ~]# 

tail:查看后n行
	-n ：显示n行
	可写成 tail -n 2 /etc/inittab 或 tail -2 /etc/inittab
	
tail -f: 查看文件尾部，不退出，等待显示后续追加至此文件的新内容；


文本处理：
cut、join、sed、awk

cut:
	-d: 指定字段分隔符，默认是空格
	-f: 指定要显示的字段
		-f 1,3 第一和第三个
		-f 1-3 一到三
	#cut -d : -f 1 /etc/passwd
	
文本排序：sort
	-n：数值排序
	-r: 降序
	-t: 字段分隔符
	-k: 以哪个字段为关键字进行排序
	-u: 排序后相同的行只显示一次
	-f: 排序时忽略字符大小写
	
uniq:	只把相邻的行认为重复行，并且只保留一行
	-c: 显示文件中行重复的次数
	-d: 只显示重复的行
	
文本统计：wc (word count)
	-l：只显示行数
	-w：只显示单词数
	-c：只显示字节数
	-L：显示最长一行包含多少字符

字符处理命令：tr —— 转换或删除字符
tr [OPTION]... SET1 [SET2]
	-d: 删除出现在字符集中的所有字符


#tr ab AB
abc
ABc
begin
Begin
access
Access

#tr 'a-z' 'A-Z' < /etc/passwd
#tr -d ab


bash及其特性：
shell: 外壳
GUI：Gnome, KDE, Xfce
CLI: sh, csh, ksh, bash, tcsh, zsh

root, student
程序  进程

进程：在每个进程看来，当前主机上只存在内核和当前进程
进程是程序的副本，进程是程序执行实例（程序可能一个，但可以有多个进程副本，内核识别进程用进程号）

用户工作环境：
bash:
	#
	$
	
	tom, jerry
	
shell，子shell（shell中可以打开shell）

bash--bash

bash: 
1、命令历史、命令补全
2、管道、重定向
3、命令别名
4、命令行编辑
5、命令行展开
6、文件名通配
7、变量
8、编程

命令行编辑：
光标跳转：
	Ctrl+a：跳到命令行首
	Ctrl+e：跳到命令行尾
	Ctrl+u: 删除光标至命令行首的内容
	Ctrl+k: 删除光标至命令行尾的内容
	Ctrl+l: 清屏
	
命令历史：
查看命令历史：history
	-c：清空命令历史
	-d OFFSET [n]: 删除指定位置的命令，删除n个
	-w：保存命令历史至历史文件中
	
环境变量
PATH：命令搜索路径
HISTSIZE: 命令历史缓冲区大小
#echo $HISTSIZE


命令历史的使用技巧：
!n：执行命令历史中的第n条命令；
!-n:执行命令历史中的倒数第n条命令； 
!!: 执行上一条命令；
!string：执行命令历史中最近一个以指定字符串开头的命令

!$:引用前一个命令的最后一个参数; （Esc, .Alt+.）


命令补全，路径补全
	命令补全：搜索PATH环境变量所指定的每个路径下以我们给出的字符串开头的可执行文件，如果多于一个，两次tab，可以给出列表；否则将直接补全；
	路径补全：搜索我们给出的起始路径下的每个文件名，并试图补全；


命令别名
alias CMDALIAS='COMMAND [options] [arguments]'
在shell中定义的别名仅在当前shell生命周期中有效；别名的有效范围仅为当前shell进程；
如果想做到永久有效，可以Bash配置文件中更改可全局永久有效，可以是自己家目录.bashrc也可以是全局/etc/bashrc

unalias CMDALIAS

\CMD


命令替换: $(COMMAND), 反引号：`COMMAND`
把命令中某个子命令替换为其执行结果的过程
file-2013-02-28-14-53-31.txt  


bash支持的引号：
``: 命令替换
"": 弱引用，可以实现变量替换
'': 强引用，不完成变量替换


文件名通配, globbing
*: 任意长度的任意字符
?：任意单个字符
[]：匹配指定范围内的任意单个字符
	[abc], [a-m], [a-z], [A-Z], [0-9], [a-zA-Z], [0-9a-zA-Z]
	[:space:]：空白字符
	[:punct:]：标点符号
	[:lower:]：小写字母
	[:upper:]: 大写字母
	[:alpha:]: 大小写字母
	[:digit:]: 数字
	[:alnum:]: 数字和大小写字母
	
# man 7 glob
[^]: 匹配指定范围之外的任意单个字符

[[:alpha:]]*[[:space:]]*[^[:alpha:]]


练习：
1、创建a123, cd6, c78m, c1 my, m.z, k 67, 8yu, 789等文件；注意，以上文件是以逗号隔开的，其它符号都是文件名的组成部分；
2、显示所有以a或m开头的文件；
ls [am]*
3、显示所有文件名中包含了数字的文件；
ls *[0-9]* 
ls *[[:digit:]]*
4、显示所有以数字结尾且文件名中不包含空白的文件；
ls *[^[:space:]]*[0-9]   ?????????
5、显示文件名中包含了非字母或数字的特殊符号的文件；
ls *[^[:alnum:]]*



权限：
r, w, x

文件：
r：可读，可以使用类似cat等命令查看文件内容；
w：可写，可以编辑或删除此文件；
x: 可执行，eXacutable，可以命令提示符下当作命令提交给内核运行；

目录：
r: 可以对此目录执行ls以列出内部的所有文件；
w: 可以在此目录创建文件；
x: 可以使用cd切换进此目录，也可以使用ls -l查看内部文件的详细信息；

rwx:
	r--:只读
	r-x:读和执行
	---：无权限
	
0 000 ---：无权限
1 001 --x: 执行
2 010 -w-: 写
3 011 -wx: 写和执行
4 100 r--: 只读
5 101 r-x: 读和执行
6 110 rw-: 读写
7 111 rwx: 读写执行

755：rwxr-xr-x
640：rw-r----- 

用户：UID, /etc/passwd 这就是用户对应的ID号配置文件
组：GID, /etc/group 这就是组对应的组ID号配置文件

影子口令：
用户：/etc/shadow
组：/etc/gshadow

用户类别：
管理员：0
普通用户： 1-65535 (RHEL7以后变了)
	系统用户：1-499   
	（系统用户只负责后台运行内核必要进程，不需要登陆系统（一般要限制））
	（每个进程都应该以用户权限运行，系统启动时，为避免权限太大，进程则以系统用户（内核自建）运行，黑客劫持进程时，权限不至于过大）
	一般用户：500-60000

用户组类别：
管理员组：
普通组：
	系统组：
	一般组：
	
用户组类别：
	私有组：创建用户时，如果没有为其指定所属的组，系统会自动为其创建一个与用户名同名的组
	基本组：用户的默认组
	附加组，额外组：默认组以外的其它组
	
/etc/passwd
account: 登录名
password: 密码 （x代表密码占位符，真正的密码在/etc/shadow）
UID：
GID：基本组ID
comment: 注释
HOME DIR：家目录
SHELL：用户的默认shell（用户登陆默认打开的shell）

/etc/shadow
account: 登录名
encrypted password: 加密的密码



用户管理：
	useradd, userdel, usermod, passwd, chsh, chfn, finger, id, chage

组管理：
	groupadd, groupdel, groupmod, gpasswd
	
权限管理：
	chown, chgrp, chmod, umask


/etc/passwd:
用户名：密码：UID:GID：注释：家目录 ：默认SHELL

/etc/group:
组名：密码：GID:以此组为其附加组的用户列表

/etc/shadow：
用户名：密码：最近一次修改密码的时间：最短使用期限：最长使用期限：警告时间：非活动时间：过期时间：

用户管理：
	useradd, userdel, usermod, passwd, chsh, chfn, finger, id, chage


useradd  [options]  USERNAME 
	-u UID
	-g GID（基本组）
	-G GID,...  （附加组）
	-c "COMMENT" 指定注释信息
	-d /path/to/directory 指定家目录的
	-s SHELL 指定shell路径
	-m -k (为用户自动创建家目录，并将/etc/skel这个用户的环境配置文件复制到用户的家目录）
		1.如果在新建用户时，没有自动建立用户根目录，则无法调用到此框架目录。
		2.如果不想以默认的/etc/skel目录作为框架目录，可以在运行useradd命令时指定新的框架目录。例如：sudo useradd -d /home/chen -m -k /etc/my_skel chen上述命令将新建用户chen，设置用户根目录为/home/chen，并且此目录会自动建立；同时指定框架目录为/etc/my_skel。
		3.如果不想在每次新建用户时，都重新指定新的框架目录，可以通过修改/etc/default/useradd配置文件来改变默认的框架目录，方法如下：查找SKEL变量的定义，如果此变量的定义已被注释掉，可以取消注释，然后修改其值：SKEL=/etc/my_skel
	-M：不建立用户家目录
	-r: 添加系统用户
	
/etc/login.defs
	
环境变量：
	PATH
	HISTSIZE
	SHELL  
（目前为止出现的现境变量)
	
	
/etc/shells：指定了当前系统可用的安全shell
	

userdel:
userdel [option] USERNAME （默认情况下不会删除用户的家目录）
	-r: 同时删除用户的家目录

id：查看用户的帐号属性信息
	-u：只显示UID
	-g：只显示GID
	-G：所有组的GID
	-n：显示名称而不是ID号

finger: 查看用户帐号信息
finger USERNAME

修改用户帐号属性：
usermod
	-u UID 
	-g GID
	-a -G GID：不使用-a选项，会覆盖此前的附加组；
	-c：注释信息
	-d -m：为用户指定新的家目录，并将以前家目录中的配置文件移动到新的家目录
	-s：改shell
	-l NEW_NAME：可以改用户的登陆名
	-L：锁定帐号
	-U：解锁帐号
	
chsh: 修改用户的默认shell

chfn：修改注释信息

密码管理：
passwd [USERNAME]
	--stdin
	-l：锁定账号
	-u：解锁账号
	-d: 删除用户密码

pwck：检查用户帐号完整性（有无隐患和问题）


组管理：
创建组:groupadd
groupadd 
	-g GID
	-r：添加为系统组
	
groupmod
	-g GID
	-n GRPNAME

groupdel

gpasswd：为组设定密码

newgrp GRPNAME 可切换用户的基本组 <--> exit 可直接切回原基本组
	


练习：
1、创建一个用户mandriva，其ID号为2002，基本组为distro（组ID为3003），附加组为linux；
# groupadd -g 3003 distro
# groupadd linux
# useradd -u 2002 -g distro -G linux mandriva
2、创建一个用户fedora，其全名为Fedora Community，默认shell为tcsh；
# useradd -c "Fedora Community" -s /bin/tcsh fedora
3、修改mandriva的ID号为4004，基本组为linux，附加组为distro和fedora；
# usermod -u 4004 -g linux -G distro,fedora mandriva
4、给fedora加密码，并设定其密码最短使用期限为2天，最长为50天；
# passwd -n 2 -x 50 fedora

5、将mandriva的默认shell改为/bin/bash; 
usermod -s /bin/bash mandirva
6、添加系统用户hbase，且不允许其登录系统；
# useradd -r -s /sbin/nologin hbase
7、

chage
	-d: 最近一次的修改时间
	-E: 过期时间
	-I：非活动时间
	-m: 最短使用期限
	-M: 最长使用期限
	-W: 警告时间

chown: 改变文件属主(只有管理员可以使用此命令)
# chown USERNAME file,...
	-R: 修改目录及其内部文件的属主
	--reference=/path/to/somefile file,... 将文件的属主设为跟此路径文件一样


两个特殊用法：
直接用chown命令用以下两种格式一起改变属主属组
chown USERNAME:GRPNAME file,... 
chown USERNAME.GRPNAME file,...
	
# chgrp GRPNAME file,...直接把某个文件的基本组给改了
	-R
	--reference=/path/to/somefile file,...
	

chmod: 修改文件的权限
修改三类用户的权限：
chmod MODE file,...
	-R
	--reference=/path/to/somefile file,...

rwxr-x---
#chmod 750 /tmp/abc

修改某类用户或某些类用户权限：
u,g,o,a
chmod 用户类别=MODE file,...
#chmod u=rwx /tmp/abc
#chmod g=rw /tmp/abc
#chmod o=rx /tmp/abc
或
#chmod u=rwx,g=rx,o= /tmp/abc

修改某类用户的某位或某些位权限：
u,g,o,a
chmod 用户类别+|-MODE file,...
#chmod u+x,g-x /tmp/abc
#chmod +x /tmp/abc 三种用户全加x


练习：
1、新建一个没有家目录的用户openstack；
# useradd -M openstack
2、复制/etc/skel为/home/openstack；
# cp -r /etc/skel /home/openstack
3、改变/home/openstack及其内部文件的属主属组均为openstack；
# chown -R openstack:openstack /home/openstack
4、/home/openstack及其内部的文件，属组和其它用户没有任何访问权限
# chmod -R go= /home/openstack


su - openstack

***手动添加用户hive, 基本组为hive (5000)，附加组为mygroup
#nano /etc/passwd
 hive:x:5000:5000:HIVE:/home/hive:/bin/bash
#nano /etc/group
 hive:x:5000:
 另外在附加组Mygroup最后一个冒号后面加上hive
#nano /etc/shadow
 hive:!!:169416:0:99999:7:::
#cp -r /etc/skel /home/hive

#openssl passwd -1 -salt '1234'
 redhat
 将产生的$1$1234$ENeVaZLw04WKGqfo6an9S/ 粘贴到 /etc/shadow 里面，将两个！！换掉



umask：遮罩码
666-umask 创建文件时运用此算法得到最终权限
777-umask 创建目录时运用此算法得到最终权限
默认 管理员是    022
     一般用户是  002
# umask 显示遮罩码
# umask 022 自定义遮罩码

***文件默认不能具有执行权限，如果算得的结果中有执行权限，则将其权限加1；

umask: 023
文件：666-023=643 默认情况下643也会自动+1变成644
目录：777-023=754


站在用户登录的角度来说，SHELL的类型：
登录式shell:
	正常通过某终端登录
	su - USERNAME 
	su -l USERNAME

非登录式shell:
	su USERNAME
	图形终端下打开命令窗口
	自动执行的shell脚本

	
bash的配置文件：
全局配置
	/etc/profile, /etc/profile.d/*.sh, /etc/bashrc
个人配置
	~/.bash_profile, ~/.bashrc
	
profile类的文件：
	设定环境变量
	运行命令或脚本

bashrc类的文件：
	设定本地变量
	定义命令别名
	
登录式shell如何读取配置文件？
/etc/profile --> /etc/profile.d/*.sh --> ~/.bash_profile --> ~/.bashrc --> /etc/bashrc

非登录式shell如何配置文件?
~/.bashrc --> /etc/basrc --> /etc/profile.d/*.sh


管道和重定向：> < >> << 

运算器、控制器： CPU
存储器：RAM
输入设备/输出设备

程序：指令和数据

控制器：指令
运算器：
存储器：

地址总线：内存寻址
数据总线：传输数据
控制总线：控制指令

寄存器：CPU暂时存储器

I/O: 硬盘，

程序

INPUT设备：

OUTPUT设备


系统设定
	默认输出设备：标准输出，STDOUT, 1
	默认输入设备：标准输入, STDIN, 0
	标准错误输出：STDERR, 2
	
标准输入：键盘
标准输出和错误输出：显示器

I/O重定向：

Linux:
>: 覆盖输出
>>：追加输出
***很多情况下，操作失误会覆盖重要文件，所以系统内建以下命令

set -C: 禁止对已经存在文件使用覆盖重定向；
	强制覆盖输出，则使用 >|
set +C: 关闭上述功能

***标准输出与错误输出是两种不同的数据流

2>: 重定向错误输出
2>>: 追加方式

***如果想把正确或者错误都定向到一个目录，可以用以下思路
#ls /var > /tmp/var4.out 2> /tmp/var4.out
[root@lcfyl ~]# ls /var > /tmp/var4.out 2> /tmp/var4.out
[root@lcfyl ~]# cat /tmp/var4.out
account cache crash cvs db empty games lib local lock log mail nis opt preserve report run spool tmp yp
[root@lcfyl ~]# ls /varr > /tmp/var4.out 2> /tmp/var4.out
[root@lcfyl ~]# cat /tmp/var4.out
ls: 无法访问/varr: 没有那个文件或目录


***以上两种混合重定向可以合并成以下一种表达
&>: 重定向标准输出或错误输出至同一个文件
#ls /var &> /tmp/var4.out

<：输入重定向
#tr 'a-z' 'A-Z' < /etc/fstab
***实际上tr命令格式是不支持后面接文件的，而是等待键盘（I/O设备）输入，而此时的I/O重定向输入
   可完全由文件代替键盘输入
<<：Here Document：在此处生成文档（输入不存在追加这种说法）
[root@lcfyl ~]# cat << END
> The first line
> The second line
> END
The first line
The second line
[root@lcfyl ~]#

***特殊表达，技巧运用，可以在脚本中生成文档
[root@lcfyl ~]# cat >> /tmp/myfile.txt <<EOF
> This is first line
> This is second line
> EOF
[root@lcfyl ~]# cat /tmp/myfile.txt
This is first line
This is second line
[root@lcfyl ~]#

管道：前一个命令的输出，作为后一个命令的输入

命令1 | 命令2 | 命令3 | ...
#echo "hello, world." | tr 'a-z' 'A-Z'（前一个命令的输出当作后一个命令的输入）
#cut -d: -f3 /etc/passwd | sort -n（前一个命令的输出当作后一个命令的输入）
#cut -d: -f1 /etc/passwd | sort |tr 'a-z' 'A-Z'（可以使用多重管道）

tee的用法：保存在一个地方，并可以显示在屏幕
[root@lcfyl ~]# echo "Hello, World" | tee /tmp/hello.out
Hello, World
[root@lcfyl ~]# cat /tmp/hello.out
Hello, World


练习：
1、统计/usr/bin/目录下的文件个数；
# ls /usr/bin | wc -l
2、取出当前系统上所有用户的shell，要求，每种shell只显示一次，并且按顺序进行显示；
# cut -d: -f7 /etc/passwd | sort -u
3、思考：如何显示/var/log目录下每个文件的内容类型？

4、取出/etc/inittab文件的第6行；
# head -6 /etc/inittab | tail -1
5、取出/etc/passwd文件中倒数第9个用户的用户名和shell，显示到屏幕上并将其保存至/tmp/users文件中；
# tail -9 /etc/passwd | head -1 | cut -d: -f1,7 | tee /tmp/users
6、显示/etc目录下所有以pa开头的文件，并统计其个数；
# ls -d /etc/pa* | wc -l
7、不使用文本编辑器，将alias cls=clear一行内容添加至当前用户的.bashrc文件中；
# echo "alias cls=clear" >> ~/.bashrc

	

	
grep, egrep, fgrep（不支持正则表达式）	

grep: 根据模式搜索文本，并将符合模式的文本行显示出来。
Pattern: 文本字符和正则表达式的元字符组合而成匹配条件
#grep 'root' /etc/passwd（如果没有变量则单引双引号都是一样的）

grep [options] PATTERN [FILE...]
	-i：不考虑大小写（--ignore-case)
	--color：把匹配的字符用特殊颜色显示出来
	-v: 显示没有被模式匹配到的行
	-o：只显示被模式匹配到的字符串
	-E: 使用扩展正则表达式
	-A #: 同时显示匹配行和后几行
	-B #: 同时显示匹配行和前几行
	-C #: 同时显示匹配行和前后几行

正则表达式：REGular EXPression, REGEXP
元字符：
.: 匹配任意单个字符
[]: 匹配指定范围内的任意单个字符
[^]：匹配指定范围外的任意单个字符
	字符集合：[:digit:], [:lower:], [:upper:], [:punct:], [:space:], [:alpha:], [:alnum:]

匹配次数【贪婪模式（尽可能多的匹配）】：

*: 匹配其前面的字符任意次（特别需要注意的是，一串字符中不一定要整串字符完全匹配才显示出来，其中部分满足就会显示该串字符，满足的部分会用颜色显示）	
	a, b, ab, aab, acb, adb, amnb
	a*b（a出现任意次后面接个b）， a?b
	a.*b

	.*: 任意长度的任意字符
\?: 匹配其前面的字符1次或0次
\{m,n\}:匹配其前面的字符至少m次，至多n次（\为转逸符，避免花括号被shell直接识别）
	\{1,\}
	\{0,3\}
[root@lcfyl ~]# grep --color "a\{1,\}b" test
ab
aab


位置锚定：
^: 锚定行首，此字符后面的任意内容必须出现在行首
#grep '^r..t' /etc/passwd
$: 锚定行尾，此字符前面的任意内容必须出现在行尾
#grep 'b..h$' /etc/passwd
^$: 空白行

\<或\b: 锚定词首，其后面的任意字符必须作为单词首部出现
\>或\b: 锚定词尾，其前面的任意字符必须作为单词的尾部出现
[root@lcfyl ~]# grep --color "root\>" test.txt
This is root.
The usre is mroot.
chroot is a command.
mroot is not a word.
[root@lcfyl ~]# grep --color "\<root" test.txt
This is root.
rooter is a dog's name.
[root@lcfyl ~]# grep --color "\<root\>" test.txt
This is root.


分组：
\(\)
	\(ab\)*：ab整体出现任意次
	后向引用
	\1: 引用第一个左括号以及与之对应的右括号所包括的所有内容
	\2: 引用第二个...........
	\3: 引用第三个...........
	
He love his lover.
She like her liker.
He like his lover.

l..e
\|：或者
C\|cat：C或者cat

练习：
1、显示/proc/meminfo文件中以不区分大小的s开头的行；
grep -i '^s' /proc/meminfo
grep '^[sS]' /proc/meminfo
2、显示/etc/passwd中以nologin结尾的行; 
grep 'nologin$' /etc/passwd

取出默认shell为/sbin/nologin的用户列表
grep "nologin$' /etc/passwd | cut -d: -f1

取出默认shell为bash，且其用户ID号最小的用户的用户名
grep 'bash$' /etc/passwd | sort -n -t: -k3 | head -1 | cut -d: -f1

3、显示/etc/inittab中以#开头，且后面跟一个或多个空白字符，而后又跟了任意非空白字符的行；
grep "^#[[:space:]]\{1,\}[^[:space:]]" /etc/inittab

4、显示/etc/inittab中包含了:一个数字:(即两个冒号中间一个数字)的行；
grep ':[0-9]:' /etc/inittab

5、显示/boot/grub/grub.conf文件中以一个或多个空白字符开头的行；
grep '^[[:space:]]\{1,\}' /boot/grub/grub.conf

6、显示/etc/inittab文件中以一个数字开头并以一个与开头数字相同的数字结尾的行；
grep '^\([0-9]\).*\1$' /etc/inittab

练习：
1、找出某文件中的，1位数，或2位数；
grep '[0-9]\{1,2\}' /proc/cpuinfo
grep --color '\<[0-9]\{1,2\}\>' /proc/cpuinfo

2、找出ifconfig命令结果中的1-255之间的整数；

3、查找当前系统上名字为student(必须出现在行首)的用户的帐号的相关信息, 文件为/etc/passwd
grep '^student\>' /etc/passwd | cut -d: -f3
id -u student

student1
student2

练习：分析/etc/inittab文件中如下文本中前两行的特征(每一行中出现在数字必须相同)，请写出可以精确找到类似两行的模式：
l1:1:wait:/etc/rc.d/rc 1
l3:3:wait:/etc/rc.d/rc 3

grep '^l\([0-9]\):\1.*\1$' /etc/inittab


扩展正则表达式：字符含义跟基本正则表达字符含义一样，只是不需要转义字符了。

字符匹配：与基本正则一样
	.
	[]
	[^]

次数匹配：与基本正则一样，多了一个+号
	*: 
	?:
	+: 匹配其前面的字符至少1次
	{m,n}

位置锚定：与基本正则一样
	^
	$
	\<
	\>

分组：与基本正则一样
	()：分组
	\1, \2, \3, ...

或者：与基本正则一样
	|: or的意思
	C|cat:  C或cat
可以相互转换：grep -E = egrep 



4、显示所有以数字结尾且文件名中不包含空白的文件；
ls *[^[:space:]]*[0-9]   ?????????


找出/boot/grub/grub.conf文件中1-255之间的数字；
\<([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>

\.

ifconfig | egrep '\<([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>\.\<([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>\.\<([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>\.\<([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>' 

ifconfig | egrep --color '(\<([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>\.){3}\<([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>' 

IPv4: 
5类：A B C D E
A：1-127
B：128-191
C：192-223

\<([1-9]|[1-9][0-9]|1[0-9]{2}|2[01][0-9]|22[0-3])\>(\.\<([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])\>){2}\.\<([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])\>


编程概念：
	编程语言：机器语言、汇编语言、高级语言

静态语言：编译型语言
	强类型(变量)
	事先转换成可执行格式
	C、C++、JAVA、C#
	
动态语言：解释型语言， on the fly
	弱类型
	边解释边执行
	PHP、SHELL、python、perl

	
面向过程：Shell, C
面向对象: JAVA, Python, perl, C++

变量：命名的内存空间

内存：编址的存储单元

变量类型：事先确定数据的存储格式和长度
	字符
	数值
		整型：整数类型
		浮点型: 11.23， 1.123*10^1, 0.1123*10^2
	日期
		2017/10/31
	Boolean
		真、假
	
	
逻辑：1+1>2
逻辑运算：与、或、非、异或
1: 真
0: 假

1 & 0  = 0
0 & 1 = 0
0 & 0 = 0
1 & 1 = 1

或：

非：
! 真 = 假
! 假 = 真

shell: 弱类型编程语言
	强：变量在使用前，必须事先声明，甚至还需要初始化；
	弱：变量用时声明，甚至不区分类型；
变量赋值：VAR_NAME=VALUE

bash变量类型：
	环境变量
	本地变量(局部变量)
	位置变量
	特殊变量
	
本地变量：
set VARNAME=VALUE: 作用域为整个bash进程；

局部变量：
local VARNAME=VALUE：作用域为当前代码段；

环境变量：作用域为当前shell进程及其子进程；
export VARNAME=VALUE
VARNAME=VALUE
export VARNAME
	“导出”

位置变量：
$1, $2, ...

特殊变量：
$?: 上一个命令的执行状态返回值；

程序执行，可能有两类返回值：
	程序执行结果
	程序状态返回代码（0-255）
		0: 正确执行
		1-255：错误执行，1，2，127系统预留；
		

撤消变量：
unset VARNAME

查看当shell中变量：
set

查看当前shell中的环境变量：
printenv
env
export

脚本：命令的堆砌，按实际需要，结合命令流程控制机制实现的源程序

shebang: 魔数
#!/bin/bash
# 注释行，不执行

/dev/null: 软件设备， bit bucket，数据黑洞	

	
脚本在执行时会启动一个子shell进程；
	命令行中启动的脚本会继承当前shell环境变量；
	系统自动执行的脚本(非命令行启动)就需要自我定义需要各环境变量；
	
练习：写一个脚本，完成以下任务
1、添加5个用户, user1,..., user5
2、每个用户的密码同用户名，而且要求，添加密码完成后不显示passwd命令的执行结果信息；
3、每个用户添加完成后，都要显示用户某某已经成功添加；
useradd user1
echo "user1" | passwd --stdin user1 &> /dev/null
echo "Add user1 successfully."


条件判断：
	如果用户不存在
		添加用户，给密码并显示添加成功；
	否则
		显示如果已经存在，没有添加；

bash中如何实现条件判断？
条件测试类型：
	整数测试
	字符测试
	文件测试

条件测试的表达式：
	[ expression ]
	[[ expression ]]
	test expression
	
整数比较:
	-eq: 测试两个整数是否相等；比如 $A -eq $B
	#A=3
	#B=6
	#[ $A -eq $B ]（注意括号与字符间一定有空格）
	#echo $?（一个命令执行完返回两个值，除命令本身外还有一个状态值，用$?）
	1

	-ne: 测试两个整数是否不等；不等，为真；相等，为假；

	-gt: 测试一个数是否大于另一个数；大于，为真；否则，为假；

	-lt: 测试一个数是否小于另一个数；小于，为真；否则，为假；

	-ge: 大于或等于

	-le：小于或等于
	
命令间的逻辑关系：
	逻辑与： &&
		第一个条件为假时，第二条件不用再判断，最终结果已经有；
		第一个条件为真时，第二条件必须得判断；
		#id student2 &> /dev/null && ehco "Hello, student2."
		无反应
		#useradd student2 
		#id student2 &> /dev/null && echo "Hello, student2."
		Hello, student2
	逻辑或： ||
	
如果用户user6不存在，就添加用户user6
! id user6 && useradd user6
id user6 || useradd user6

如果/etc/inittab文件的行数大于100，就显示好大的文件；
[ `wc -l /etc/inittab | cut -d' ' -f1` -gt 100 ] && echo "Large file."

变量名称：
	1、只能包含字母、数字和下划线，并且不能数字开头；
	2、不应该跟系统中已有的环境变量重名；
	3、最好做到见名知义；

如果用户存在，就显示用户已存在；否则，就添加此用户；
id user1 && echo "user1 exists." || useradd user1

如果用户不存在，就添加；否则，显示其已经存在；
! id user1 && useradd user1 || echo "user1 exists."

如果用户不存在，添加并且给密码；否则，显示其已经存在；
#!/bin/bash
! id user1 && useradd user1 && echo "user1" | passwd --stdin user1	|| echo "user1 exists."
! id user2 && useradd user2 && echo "user2" | passwd --stdin user2	|| echo "user2 exists."
! id user3 && useradd user3 && echo "user3" | passwd --stdin user3	|| echo "user3 exists."
USERS=`wc -l /etc/passwd | cut -d: -f1`
echo "$USERS users."


练习，写一个脚本，完成以下要求：
1、添加3个用户user1, user2, user3；但要先判断用户是否存在，不存在而后再添加；
2、添加完成后，显示一共添加了几个用户；当然，不能包括因为事先存在而没有添加的；
3、最后显示当前系统上共有多少个用户；

练习，写一个脚本，完成以下要求：
给定一个用户：
	1、如果其UID为0，就显示此为管理员；
	2、否则，就显示其为普通用户；
	#!/bin/bash
	NAME=user1
	USERID=`id -u $NAME`
	[ $USERID -eq 0 ] && echo "Admin" || echo "Common user"

如果 UID为0；那么
  显示为管理员
否则
  显示为普通用户
  
NAME=user16
USERID=`id -u $NAME`
if [ $USERID -eq 0 ]; then
  echo "Admin"
else
  echo "common user."
fi



NAME=user16
if [ `id -u $NAME` -eq 0 ]; then
  echo "Admin"
else
  echo "common user."
fi


if id $NAME; then
  
练习：写一个脚本
判断当前系统上是否有用户的默认shell为bash；
   如果有，就显示有多少个这类用户；否则，就显示没有这类用户；
grep "bash$" /etc/passwd &> /dev/null
RETVAL=$?
if [ $RETVAL -eq 0 ]; then
   
if grep "bash$" /etc/passwd &> /dev/null; then
	
提示：“引用”一个命令的执行结果，要使用命令引用；比如: RESAULTS=`wc -l /etc/passwd | cut -d: -f1`；
      使用一个命令的执行状态结果，要直接执行此命令，一定不能引用；比如: if id user1一句中的id命令就一定不能加引号；
	  如果想把一个命令的执行结果赋值给某变量，要使用命令引用，比如USERID=`id -u user1`;
      如果想把一个命令的执行状态结果保存下来，并作为命令执行成功与否的判断条件，则需要先执行此命令，而后引用其状态结果，如
		id -u user1
		RETVAL=$?
		此句绝对不可以写为RETVAL=`id -u user1`；
	
	
练习：写一个脚本
判断当前系统上是否有用户的默认shell为bash；
   如果有，就显示其中一个的用户名；否则，就显示没有这类用户；

练习：写一个脚本
给定一个文件，比如/etc/inittab
判断这个文件中是否有空白行；
如果有，则显示其空白行数；否则，显示没有空白行。
#!/bin/bash
A=`grep '^$' /etc/inittab | wc -l`
if [ $A -gt 0 ]; then
 echo "$A"
else
 echo "meiyoukongbaihang"
fi
                 —— by 张帅
				 
#!/bin/bash
FILE=/etc/inittab
if [ ! -e $FILE ]; then
  echo "No $FILE."
  exit 8
fi

if grep "^$" $FILE &> /dev/null; then
  echo "Total blank lines: `grep "^$" $FILE | wc -l`."
else
  echo "No blank line."
fi

练习：写一个脚本
给定一个用户，判断其UID与GID是否一样
如果一样，就显示此用户为“good guy”；否则，就显示此用户为“bad guy”。
#!/bin/bash
USERNAME=user1
USERID=`id -u $USERNAME`
GROUPID=`id -g $USERNAME`
if [ $USERID -eq $GROUPID ]; then
  echo "Good guy."
else
  echo "Bad guy."
fi

进一步要求：不使用id命令获得其id号；

#!/bin/bash
#
USERNAME=user1
if ! grep "^$USERNAME\>" /etc/passwd &> /dev/null; then
  echo "No such user: $USERNAME."
  exit 1
fi

USERID=`grep "^$USERNAME\>" /etc/passwd | cut -d: -f3`
GROUPID=`grep "^$USERNAME\>" /etc/passwd | cut -d: -f4`
if [ $USERID -eq $GROUPID ]; then
  echo "Good guy."
else
  echo "Bad guy."
fi


练习：写一个脚本
给定一个用户，获取其密码警告期限；
而后判断用户密码使用期限是否已经小于警告期限；
	提示：计算方法，最长使用期限减去已经使用的天数即为剩余使用期限；
	
如果小于，则显示“Warning”；否则，就显示“OK”。

圆整：丢弃小数点后的所有内容

#!/bin/bash
W=`grep "student" /etc/shadow | cut -d: -f6`
S=`date +%s`
T=`expr $S/86400`
L=`grep "^student" /etc/shadow | cut -d: -f5`
N=`grep "^student" /etc/shadow | cut -d: -f3`
SY=$[$L-$[$T-$N]]

if [ $SY -lt $W ]; then
  echo 'Warning'
else
  echo 'OK'
fi

						—— by 董利东


练习：写一个脚本
判定命令历史中历史命令的总条目是否大于1000；如果大于，则显示“Some command will gone.”；否则显示“OK”。


shell中如何进行算术运算（默认情况下Linux定义变量为字符，若要作算术用以下方法）：
A=3
B=6
1、let 算术运算表达式
	let C=$A+$B
2、$[算术运算表达式]
	C=$[$A+$B]
3、$((算术运算表达式))
	C=$(($A+$B))
4、expr 算术运算表达式，表达式中各操作数及运算符之间要有空格，而且要使用命令引用
	C=`expr $A + $B`

内部算数 bc

[root@lcfyl ~]# echo "scale=2;111/22;" | bc
5.04
[root@lcfyl ~]# bc <<< "scale=2;111/22;"
5.04

条件判断，控制结构：

单分支if语句
if 判断条件; then
  statement1
  statement2
  ...
fi

双分支的if语句：
if 判断条件; then
	statement1
	statement2
	...
else
	statement3
	statement4
	...
fi

多分支的if语句：
if 判断条件1; then
  statement1
  ...
elif 判断条件2; then
  statement2
  ...
elif 判断条件3; then
  statement3
  ...
else
  statement4
  ...
fi

#!/bin/bash
FILE=/etc/rc.d/rc.sysinit

if [ ! -e $FILE ]; then
   echo "No such file."
   exit 6
 fi

if [ -f $FILE ]; then
   echo "Common file."
elif [ -d $FILE ]; then 
   echo "Directory"
else
   echo "Unknow"
 fi


测试方法：
[ expression ]
[[ expression ]]
test expression

bash中常用的条件测试有三种：
整数测试：
	-gt
	-le
	-ne
	-eq
	-ge
	-lt

INT1=63
INT2=77
[ $INT1 -eq $INI2 ]
[[ $INT1 -eq $INT2 ]]
test $INT1 -eq $INT2  
		
文件测试：	
-e FILE：测试文件是否存在
-f FILE: 测试文件是否为普通文件
-d FILE: 测试指定路径是否为目录
-r FILE: 测试当前用户对指定文件是否有读取权限；
-w
-x	

[ -e /etc/inittab ]
[ -x /etc/rc.d/rc.sysinit ]

练习：写一个脚本
给定一个文件：
如果是一个普通文件，就显示之；
如果是一个目录，亦显示之；
否则，此为无法识别之文件；

定义脚本退出状态码

exit: 退出脚本
exit #
如果脚本没有明确定义退出状态码，那么，最后执行的一条命令的退出码即为脚本的退出状态码；


bash -x 脚本：单步执行



bash变量的类型：
	本地变量(局部变量):当前shell进程
	环境变量：当前shell进程及其子进程
	位置变量: 
		$1, $2, ...
		shift [n]（可强制退出前n个参数，第n+1个参数变成$1，没有n时默认为1）
		#nano shift.sh
			#！/bin/bash
			echo $1
			shift
			echo $1
			shift
			echo $1
		#./shift.sh 1 2 3
		1
		2
		3
	特殊变量：
		$?
		$#：参数的个数
		$*: 参数列表
		$@：参数列表
	
./filetest.sh /etc/fstab /etc/inittab
$1: /etc/fstab 就是对应的第一个参数
$2: /etc/inittab 就是对应的第二个参数

练习：写一脚本
能接受一个参数(文件路径)
判定：此参数如果是一个存在的文件，就显示“OK.”；否则就显示"No such file."
#!/bin/bash
if [ -e $1 ];then
    echo "ok"
 else
    echo "no such file"
 fi
 
./filetest.sh /etc/rc.d/rc.sysinit（此处接受的路径就是脚本中的$1）

练习：写一个脚本
给脚本传递两个参数(整数)；
显示此两者之和，之乘积；
#!/bin/bash
#
if [ $# -lt 2 ]; then
  echo "Usage: cacl.sh ARG1 ARG2"
  exit 8
fi

echo "The sum is: $[$1+$2]."
echo "The prod is: $[$1*$2]."

	
练习：写一个脚本，完成以下任务
1、使用一个变量保存一个用户名；
2、删除此变量中的用户，且一并删除其家目录；
3、显示“用户删除完成”类的信息；
	

bash: 引用变量：${VARNAME}, 括号有时可省略。

grep, sed(流编辑器), awk 	

sed基本用法：
sed: Stream EDitor
	行编辑器 (全屏编辑器: vi)
	
sed: 模式空间（内存空间）
默认不编辑原文件，仅对模式空间中的数据做处理；而后，处理结束后，将模式空间打印至屏幕；


sed [options] 'AddressCommand' file ...
	-n: 静默模式，不再默认显示模式空间中的内容
	-i: 直接修改原文件
	-e SCRIPT -e SCRIPT:可以同时执行多个脚本
	-f /PATH/TO/SED_SCRIPT
		sed -f /path/to/scripts  file
	-r: 表示使用扩展正则表达式
	
Address：
1、StartLine,EndLine
	比如1,100  从第一行到100行
	$：最后一行
2、/RegExp/
	/^root/  所有以root开头的行
3、/pattern1/,/pattern2/
	第一次被pattern1匹配到的行开始，至第一次被pattern2匹配到的行结束，这中间的所有行
4、LineNumber
	指定的行
5、StartLine, +N
	从startLine开始，向后的N行；
	一共N+1行
	
Command：
	d: 删除符合条件的行；
		# sed "1,2d" /etc/fstab
		# sed "1,+2d" /etc/fstab
		# sed "/oot/d" /etc/fstab
		# sed "/^\//d" /etc/fstab
	p: 显示符合条件的行；
		# sed "/^\//p" /etc/fstab
		结果会重复出现两次，sed默认显示处理结果一次，p命令显示一次，
		所以这里要用到选项-n,代表sed 本身静默不显示
		# sed -n "/^\//p" /etc/fstab 

	a \string: 在指定的行后面追加新行，内容为string
		# sed "/^\//a \# hello world" /etc/fstab
		\n：可以用于换行
		# sed "/^\//a \# hello world\n# hello,Linux" /etc/fstab
	i \string: 在指定的行前面添加新行，内容为string
		
	r FILE: 将指定的文件的内容添加至符合条件的行处
		# sed "2r /etc/issue" /etc/fstab
	w FILE: 将地址指定的范围内的行另存至指定的文件中; 
		# sed "/oot/w /tmp/oot.txt" /etc/fstab
	s/pattern/string/修饰符: 查找并替换，默认只替换每行中第一次被模式匹配到的字符串
		# sed "s/oot/OOT/" /etc/fstab
		# sed "s/^\//#/" /etc/fstab
		加修饰符
		g: 全局替换
		# sed "s/^\//#/g" /etc/fstab
		i: 忽略字符大小写
	s///: s###, s@@@ （s后面的分隔符可以是这三种）	
		\(\), \1, \2
		
	
		  
		 
	
	&: 引用模式匹配整个串（&就是引用整个pattern）
		l..e: like-->liker
		      love-->lover
		      两种都行
		# sed "s#l..e#&r#g" sed.txt
		# sed "s@\(l..e@\)\1r@g" sed.txt
		      有的时候只能用后项引用
		      like-->Like
		      love-->Love
		# sed "s/l\(..e\)/L\1/g" sed.txt
		

sed练习：
1、删除/etc/grub.conf文件中行首的空白符；
sed -r 's@^[[:spapce:]]+@@g' /etc/grub.conf
2、替换/etc/inittab文件中"id:3:initdefault:"一行中的数字为5；
sed 's@\(id:\)[0-9]\(:initdefault:\)@\15\2@g' /etc/inittab
3、删除/etc/inittab文件中的空白行；
sed '/^$/d' /etc/inittab
4、删除/etc/inittab文件中开头的#号; 
sed 's@^#@@g' /etc/inittab
5、删除某文件中开头的#号及后面的空白字符，但要求#号后面必须有空白字符;
sed -r 's@^#[[:space:]]+@@g' /etc/inittab
6、删除某文件中以空白字符后面跟#类的行中的开头的空白字符及#
sed -r 's@^[[:space:]]+#@@g' /etc/inittab
7、取出一个文件路径的父目录名称;
echo "/etc/rc.d/" | sed -r 's#^(/.*/)[^/]+/?#\1#g'	
基名：
echo "/etc/rc.d/" | sed -r 's@^/.*/([^/]+)/?@\1@g'	

练习：
传递一个用户名参数给脚本，判断此用户的用户名跟其基本组的组名是否一致，并将结果显示出来。

字符测试：
==：测试是否相等，相等为真，不等为假
[root@lcfyl ~]# A=hello
[root@lcfyl ~]# B=hi
[root@lcfyl ~]# [ $A=$B ]
[root@lcfyl ~]# echo $?
0
[root@lcfyl ~]# [ $A = $B ]
[root@lcfyl ~]# echo $?
1
[root@lcfyl ~]#
***一定要注意，等号两边一定要有空格，==可以用=代替


!=: 测试是否不等，不等为真，等为假
>
<
-z string: 测试指定字符串是否为空，空则真，不空则假
-n string: 测试指定字符串是否不空，不空为真，空则为假

练习：写一个脚本
传递一个参数(单字符就行)给脚本，如参数为q，就退出脚本；否则，就显示用户的参数；

练习：写一个脚本
传递一个参数(单字符就行)给脚本，如参数为q、Q、quit或Quit，就退出脚本；否则，就显示用户的参数；
#!/bin/bash
#
if [ $1 = 'q' ];then
  echo "Quiting..."
  exit 1
elif [ $1 = 'Q' ];then
  echo "Quiting..."
  exit 2  
elif [ $1 = 'quit' ];then
  echo "Quiting..."
  exit 3 
elif [ $1 = 'Quit' ];then
  echo "Quiting..."
  exit 4  
else
  echo $1
fi

练习：
传递三个参数给脚本，第一个为整数，第二个为算术运算符，第三个为整数，将计算结果显示出来，要求保留两位精度。形如：
./calc.sh 5 / 2

练习：
传递3个参数给脚本，参数均为用户名。将此些用户的帐号信息提取出来后放置于/tmp/testusers.txt文件中，并要求每一行行首有行号。

#!/bin/bash
#
for I in `seq 1 $#`;do
        string="$I `grep "^$1" /etc/passwd`"
        echo "$string" >> /tmp/testusers.txt
shift
done

写一个脚本：
判断当前主机的CPU生产商，其信息在/proc/cpuinfo文件中vendor_id一行中。
如果其生产商为AuthenticAMD，就显示其为AMD公司；
如果其生产商为GenuineIntel，就显示其为Intel公司；
否则，就说其为非主流公司；
#!/bin/bash
#
TYPE=`sed -n '2p' /proc/cpuinfo | cut -d: -f2 | sed -r 's/^[[:space:]]+//g'`
if [ $TYPE == 'AuthenticAMD' ];then
       echo "The cpu is AMD company."
elif [ $TYPE == 'GenuineIntel' ];then
       echo "The cpu is Inter company."
else
       echo "The cpu is otherd company."
fi


写一个脚本：
给脚本传递三个整数，判断其中的最大数和最小数，并显示出来。
MAX=0
MAX -eq $1
MAX=$1
MAX -lt $2
MAX=$2


循环：进入条件，退出条件
三种：
	for 循环
	while 循环
	until 循环

for 变量 in 列表; do
  循环体
done

for I in 1 2 3 4 5 6 7 8 9 10; do
  加法运算
done

遍历完成之后，退出；

如何生成列表：
{1..100}
`seq [起始数 [步进长度]] 结束数`
[root@lcfyl ~]# seq 1 2 10
1
3
5
7
9

declare -i SUM=0
	-i：integer
	-x：声明一个变量为环境变量
#!/bin/bash
#
declare -i SUM=0
for I in {1..100}; do
  let SUM=$SUM+$I
done

echo "The sum is:$SUM."

***一个命令行表达
[root@lcfyl ~]# LINES=`wc -l /etc/passwd | cut -d' ' -f1`
[root@lcfyl ~]# for I in `seq 1 $LINES`; do echo "Hello, `head -n $I /etc/passwd | tail -1 | cut -d: -f1`";done
Hello, root
Hello, bin
Hello, daemon
Hello, adm
Hello, lp
Hello, sync
Hello, shutdown
Hello, halt
	

写一个脚本：
1、设定变量FILE的值为/etc/passwd
2、依次向/etc/passwd中的每个用户问好，并显示对方的shell，形如：  
	Hello, root, your shell: /bin/bash
3、统计一共有多少个用户


只向默认shell为bash的用户问声好
#!/bin/bash
#
declare -i sum=0
FILE=/etc/passwd
NUM=`wc -l $FILE | cut -d" " -f1`
for I in `seq 1 $NUM`;do
        SHELL=`head -$I /etc/passwd | tail -1 | cut -d: -f7`
        if [[ $SHELL = "/bin/bash" ]];then
        NAME=`head -$I /etc/passwd | tail -1 | cut -d: -f1`
        echo "Hello $NAME"
        let sum=$sum+1
        fi
done
        echo 
        echo "People whose shell is bash are totally $sum."


****关于测试方法中的[] [[]]这两个说一下：
	[]是把两边当作固定字符串比较，而[[]]是把两边当作匹配模式比较
		[ $SHELL = "/bin/bash" ]同[[ $SHELL = /bin/bas? ]]是一样的
		也就是说[[]]支持通配符，功能强大，所以经常用[[]]可以避免很多错误

写一个脚本：
1、添加10个用户user1到user10，密码同用户名；但要求只有用户不存在的情况下才能添加；

扩展：
接受一个参数：
add: 添加用户user1..user10
del: 删除用户user1..user10
其它：退出
adminusers user1,user2,user3,hello,hi



写一个脚本：
计算100以内所有能被3整除的正整数的和；
取模，取余:%
3%2=1
100%55=45

写一个脚本：
计算100以内所有奇数的和以及所有偶数的和；分别显示之；

写一个脚本，分别显示当前系统上所有默认shell为bash的用户和默认shell为/sbin/nologin的用户，并统计各类shell下的用户总数。显示结果形如：
BASH，3users，they are:
root,redhat,gentoo

NOLOGIN, 2users, they are:
bin,ftp


#!/bin/bash
#
NUMBASH=`grep "bash$" /etc/passwd | wc -l`
BASHUSERS=`grep "bash$" /etc/passwd | cut -d: -f1`
BASHUSERS=`echo $BASHUSERS | sed 's@[[:space:]]@,@g'`

echo "BASH, $NUMBASH users, they are:"
echo "$BASHUSERS

测试：
整数测试
	-le
	-lt
	-ge
	-gt
	-eq
	-ne
字符测试
	==
	!=
	>
	<
	-n
	-z
文件测试
	-e
	-f
	-d
	-r
	-w
	-x
	
if [ $# -gt 1 ]; then

组合测试条件
	-a: 与关系
	-o: 或关系
	!： 非关系
	
if [ $# -gt 1 -a $# -le 3 ]
if [ $# -gt 1 ] && [ $# -le 3 ]

q, Q, quit, Quit

#!/bin/bash
#
if [ $1 == 'q' -o $1 == 'Q' -o $1 == 'quit' -o $1 == 'Quit' ]; then
   echo "Quiting..."
   exit 0
else
   echo "Unknown Argument."
   exit 1
fi



vim编辑器(nano, sed)
	ASCII码、字处理器
	vi: Visual Interface
	vim: VI iMproved

	全屏编辑器，模式化编辑器

vim模式：
编辑模式(命令模式)
输入模式
末行模式

模式转换：
编辑-->输入：
	i: 在当前光标所在字符的前面，转为输入模式；
	I：在当前光标所在行的行首，转换为输入模式

	a: 在当前光标所在字符的后面，转为输入模式；
	A：在当前光标所在行的行尾，转换为输入模式

	o: 在当前光标所在行的下方，新建一行，并转为输入模式；
	O：在当前光标所在行的上方，新建一行，并转为输入模式；

	
输入-->编辑：
	ESC
	
编辑-->末行：
	：

末行-->编辑：
	ESC, ESC

一、打开文件
# vim /path/to/somefile
	vim +#:打开文件，并定位于第#行 
	vim +：打开文件，定位至最后一行
	vim +/PATTERN : 打开文件，定位至第一次被PATTERN匹配到的行的行首

	默认处于编辑模式
	
二、关闭文件
1、末行模式关闭文件
:q  退出
:wq 保存并退出
:q! 不保存并退出
:w 保存
:w! 强行保存
:wq 可以同 :x
2、编辑模式下退出
ZZ: 保存并退出

三、移动光标(编辑模式)
1、逐字符移动：
	h: 左
	l: 右
	j: 下
	k: 上
 #h: 移动#个字符；
	J：当前行与下一行合并
2、以单词为单位移动
	w: 移至下一个单词的词首
	e: 跳至当前或下一个单词的词尾
	b: 跳至当前或前一个单词的词首
	
	#w: 
	
3、行内跳转：
	0: 绝对行首
	^: 行首的第一个非空白字符
	$: 绝对行尾

4、行间跳转
	#G：跳转至第#行；
	G：最后一行
	gg:第一行
	g~:将当前行大小写转换
	
	末行模式下，直接给出行号即可
	
四、翻屏
Ctrl+f: 向下翻一屏
Ctrl+b: 向上翻一屏

Ctrl+d: 向下翻半屏
Ctrl+u: 向上翻半屏

五、删除单个字符
x: 删除光标所在处的单个字符
#x: 删除光标所在处及向后的共#个字符

六、删除命令: d
d命令跟跳转命令组合使用；
#dw, #de, #db

dd: 删除当前光标所在行
#dd: 删除包括当前光标所在行在内的#行；

末行模式下：
StartADD,EndADDd
	.: 表示当前行
	$: 最后一行
	+#: 向下的#行
	
七、粘贴命令 p
p: 如果删除或复制为整行内容，则粘贴至光标所在行的下方，如果复制或删除的内容为非整行，则粘贴至光标所在字符的后面；
P: 如果删除或复制为整行内容，则粘贴至光标所在行的上方，如果复制或删除的内容为非整行，则粘贴至光标所在字符的前面；

八、复制命令 y
	用法同d命令
	
九、修改：先删除内容，再转换为输入模式
	c: 用法同d命令

十、替换：r
R: 替换模式

十一、撤消编辑操作 u
u：撤消前一次的编辑操作
	连续u命令可撤消此前的n次编辑操作
#u: 直接撤消最近#次编辑操作

撤消最近一次撤消操作：Ctrl+r

十二、重复前一次编辑操作
.

十三、可视化模式
v: 按字符选取
V：按矩形选取

十四、查找
/PATTERN
?PATTERN
	n
	N

十五、查找并替换
在末行模式下使用s命令
ADDR1,ADDR2s@PATTERN@string@gi
1,$
%：表示全文

练习：将/etc/yum.repos.d/server.repo文件中的ftp://instructor.example.com/pub替换为http://172.16.0.1/yum

%s/ftp:\/\/instructor\.example\.com\/pub/http:\/\/172.16.0.1\/yum/g
%s@ftp://instructor\.example\.com/pub@http://172.16.0.1/yum@g

文件内容如下：
# repos on instructor for classroom use

# Main rhel5 server
[base]
name=Instructor Server Repository
baseurl=ftp://172.16.0.1/pub/Server
gpgcheck=0

# This one is needed for xen packages
[VT]
name=Instructor VT Repository
baseurl=ftp://172.16.0.1/pub/VT
gpgcheck=0

# This one is needed for clustering packages
[Cluster]
name=Instructor Cluster Repository
baseurl=ftp://172.16.0.1/pub/Cluster
gpgcheck=0

# This one is needed for cluster storage (GFS, iSCSI target, etc...) packages
[ClusterStorage]
name=Instructor ClusterStorage Repository
baseurl=ftp://172.16.0.1/pub/ClusterStorage
gpgcheck=0

十六、使用vim编辑多个文件
vim FILE1 FILE2 FILE3
:next 切换至下一个文件
:prev 切换至前一个文件
:last 切换至最后一个文件
:first 切换至第一个文件

退出
:qa 全部退出

十七、分屏显示一个文件
Ctrl+w, s: 水平拆分窗口
Ctrl+w, v: 垂直拆分窗口

在窗口间切换光标：
Ctrl+w+w

:qa 关闭所有窗口

十八、分窗口编辑多个文件
vim -o : 水平分割显示
vim -O : 垂直分割显示

十九、将当前文件中部分内容另存为另外一个文件
末行模式下使用w命令
:w
:ADDR1,ADDR2w /path/to/somewhere

二十、将另外一个文件的内容填充在当前文件中
:r /path/to/somefile

二十一、跟shell交互
:! COMMAND（不用退出当前文件就直接相当于在shell下用命令，用完再Enter回来）

二十二、高级话题
1、显示或取消显示行号
:set number
:set nu

:set nonu

2、显示忽略或区分字符大小写
:set ignorecase
:set ic

:set noic

3、设定自动缩进
:set autoindent
:set ai
:set noai

4、查找到的文本高亮显示或取消
:set hlsearch
:set nohlsearch

5、语法高亮
:syntax on
:syntax off

二十三、配置文件
/etc/vimrc
~/.vimrc

vim: 
****有一点需要注意的是，当在使vim编辑的时候如果非法退出，则会在
     编辑的文件所在目录下生成一个与文件同名后缀为.swp的文件，每次再
     编辑这个文件的时候，就会出现提醒，而且.swp文件不会消失，这时可以
     手动删除
     如：rm -f .inittab.swp

ldd [选项] 文件
	[root@localhost ~]# ldd /bin/ls
		linux-vdso.so.1 =>  (0x00007fff4ad25000)
		libselinux.so.1 => /lib64/libselinux.so.1 (0x00007f673d161000)
		libcap.so.2 => /lib64/libcap.so.2 (0x00007f673cf5c000)
		libacl.so.1 => /lib64/libacl.so.1 (0x00007f673cd52000)
		libc.so.6 => /lib64/libc.so.6 (0x00007f673c991000)
		libpcre.so.1 => /lib64/libpcre.so.1 (0x00007f673c730000)
		liblzma.so.5 => /lib64/liblzma.so.5 (0x00007f673c50a000)
		libdl.so.2 => /lib64/libdl.so.2 (0x00007f673c306000)
		/lib64/ld-linux-x86-64.so.2 (0x00007f673d38c000)
		libattr.so.1 => /lib64/libattr.so.1 (0x00007f673c101000)
		libpthread.so.0 => /lib64/libpthread.so.0 (0x00007f673bee4000)
	[root@localhost ~]#


whereis 
	-b 查找2进制程序
	-m 查找文档
	-s 查找源码
	[root@localhost ~]# whereis -bms cat
	cat: /usr/bin/cat /usr/share/man/man1/cat.1.gz
	[root@localhost ~]# 

which
	[root@localhost ~]# which ls
	alias ls='ls --color=auto'
		/usr/bin/ls
	[root@localhost ~]# which cat
	/usr/bin/cat
	[root@localhost ~]#

文件查找：
locate:
	非实时，模糊匹配，查找是根据全系统文件数据库进行的；
# updatedb, 手动生成文件数据库(刚安装的系统没有数据库，locate用不了，必须updatedb生成，但是要花很长时间）
速度快
locate 关键字
	数据库生成: updatedb
	数据库目录: /var/lib/mlocate/mlocate.db
	
	-i 不区分大小写
	[root@localhost ~]# locate -i inittab
	/etc/inittab
	/usr/share/vim/vim74/syntax/inittab.vim
	[root@localhost ~]#
	
	-r 支持正则表达式
	[root@localhost ~]# locate -r conf$ | grep nss
	/etc/nsswitch.conf
	/etc/prelink.conf.d/nss-softokn-prelink.conf
	/usr/lib/dracut/dracut.conf.d/50-nss-softokn.conf
	/var/lib/authconfig/last/nsswitch.conf
	[root@localhost ~]# 

updatedb：
1.updatedb -U <path> 对指定的path制作数据库
2.updatedb -e <path> 除指定的path以外目录都建立数据库
3.updatedb -o file 指定生成的数据库文件

find：
	实时
	精确
	支持众多查找标准
	遍历指定目录中的所有文件完成查找，速度慢；
语法：
find DIRICTORY Cretiria ACTION	
find 查找路径 查找标准 查找到以后的处理运作
查找路径：默认为当前目录
查找标准：默认为指定路径下的所有文件
处理运作：默认为显示

匹配标准：
	-name 'FILENAME'：对文件名作精确匹配
		[root@lcfyl ~]# find /etc/ -name 'passwd'
		/etc/pam.d/passwd
		/etc/passwd

		文件名通配：
			*：任意长度的任意字符
			?
			[]
	-iname 'FILENAME': 文件名匹配时不区分大小写
	-regex PATTERN：基于正则表达式进行文件名匹配（这个地方很奇怪的是要全路径匹配，不能只截取某个文件）
		[root@mail ~]# find /etc/ -regex ".*ifcfg.*"
		/etc/sysconfig/network-scripts/ifcfg-eth0
		/etc/sysconfig/network-scripts/ifcfg-lo
		[root@mail ~]# 
		下面就是错误的，什么都找不到
		[root@mail ~]# find /etc/ -regex "ifcfg.*"
	-user USERNAME: 根据属主查找
		[root@lcfyl ~]# find /home -user mandriva
		/home/mandriva
		/home/mandriva/.bash_logout
		/home/mandriva/.gnome2
		/home/mandriva/.bash_profile
		/home/mandriva/.bashrc

	-group GROUPNAME: 根据属组查找
	
	-uid [+/-]UID: 根据UID查找
		[root@localhost ~]# find /etc/ -uid -500 | wc -l
		1067
		[root@localhost ~]# 

	-gid [+/-]GID: 根据GID查找
		***有的时候用户删了，其属主属组丢失变成其ID号

	-used [+/-]n：什么时间用过的文件
		[root@localhost ~]# find /etc/ -used -1 | wc -l
		481
		[root@localhost ~]#
	-fstype <文件系统类型> 在指定的文件系统类型上查找文件
	-link <n> 查找n个硬链接数的文件
	-inum i节点ID 查找指定的i节点号

	-nouser：查找没有属主的文件
	-nogroup: 查找没有属组的文件
	-empty：查找空文件
	-newer <文件名> 查找比文件更新的文件
		1. 查找比test.txt文件更改时间新的文件
		[root@localhost ~]# find ~ -newer a.txt 
		/root
		/root/.num.sh.swp
		/root/anaconda-ks.cfg
		/root/.lesshst
		/root/initial_repo_backup
		/root/.bash_history
		/root/.viminfo
		[root@localhost ~]# 
		2. 查找比test.txt文件访问时间新的文件
		[root@localhost ~]# find /etc/ -anewer /etc/terminfo | wc -l
		1030
		[root@localhost ~]#
	-cnewer：File's status was last changed more recently than file  was  modified

	-type 
		f: 普通文件
		d：目录
		c：字符文件
		b：block
		l: link
		p: pipe
		s: socks
	
	-size [+|-]：+/-是表示大于小于的意思
		
		#b 块(512字节)
		#c 字节
		#k KB
		#M MB
			[root@localhost ~]# find /etc/ -size -1M -ls | head -4
			360657    0 -rw-------   1 root     root            0 Mar  6  2015 /etc/security/opasswd
			360483    0 -rw-r--r--   1 root     root            0 Oct 29  2014 /etc/environment
			360872    0 -rw-r--r--   1 root     root            0 Jun 10  2014 /etc/sysconfig/run-parts
			360493    0 -rw-r--r--   1 root     root            0 Jun  7  2013 /etc/motd
			[root@localhost ~]#
		#G GB
		
组合条件：
	-a
		#find /tmp -nouser -a -type d
	-o
		#find /tmp -nouser -o -type d
	-not 
		#find /tmp -not -type d
		
	
/tmp目录，不是目录，并且还不能套接字类型的文件
#find /tmp -not -user user1 -a -not -user user2
#find /tmp -not \( -user user1 -o -user user2 \) ****这个就是摩根定律（与或非的转换）

/tmp/test目录下，属主不是user1，也不是user2的文件；

根据时间戳来查找：
	-mtime（默认单位是天）
	-ctime
	-atime
		[+|-]#
		#find /tmp -atime +5 至少有5天没有访问过了（如果没有+、-代表正好是那个时间点）
	-mmin（默认单位是分）
	-cmin
	-amin
		[+|-]#
		
	-perm MODE：精确匹配（根据文件权限）
		/MODE: 任意一位匹配即满足条件
		-MODE: 文件权限能完全包含此MODE时才符合条件
		
		-644
		644: rw-r--r--
		755: rwxr-xr-x
		750: rwxr-x---
	find ./ -perm -001


运作：
	-print: 显示（默认）
	-ls：类似ls -l的形式显示每一个文件的详细
	-ok COMMAND {} \; 每一次操作都需要用户确认
		#find ./-perm -006 -ok chmod o-w {} \;
	-exec COMMAND {} \; 不需要确认
		#find ./-type d -exec chmod +x {} \;
		#find ./ -perm -020 -exec mv {} {}.new \;（只要引用了这个文件的名字就要用{}代替）
		#find ./-name "*.sh" -a -perm -111 -exec chmod o-x {} \;
	xargs（单独命令）
		#find /etc/ -size +1M -exec echo {} >> /tmp/etc.largefiles \;
		#find /etc/ -size +1M | xargs echo >> /tmp/etc.largefiles

1、查找/var目录下属主为root并且属组为mail的所有文件；
find /var -user root -a -group mail

2、查找/usr目录下不属于root,bin,和student的文件；
find /usr -not -user root -a -not -user bin -a -not -user student
find /usr -not \( -user root -o -user bin -o -user student \)

3、查找/etc目录下最近一周内内容修改过且不属于root及student用户的文件；
find /etc -mtime -7 -not \ ( -user root -o -user student \)
find /etc -mtime -7 -not -user root -a -not -user student


4、查找当前系统上没有属主或属组且最近1天内曾被访问过的文件，并将其属主属组均修改为root；
find / \( -nouser -o -nogroup \) -a -atime -1 -exec chown root:root {} \; 

5、查找/etc目录下大于1M的文件，并将其文件名写入/tmp/etc.largefiles文件中；
find /etc -size +1M >> /tmp/etc.largefiles

6、查找/etc目录下所有用户都没有写权限的文件，显示出其详细信息；
find /etc -not -perm /222 -ls

7. 查找比a.txt文件更改时间新但比b.txt时间旧的文件
find ~ -newer a.txt ! -newer b.txt

8. 查找3天前使用过的文件或目录
find ~ -used +3

9. 在非ext4上查找文件名test.txt文件
find ~ -name test.txt ! -fstype ext4

10. 查找硬链接数大于2但小于5的文件
find ~ -links +2 -links -5

11. 查找i节点号为12345的文件
find ~ -inum 12345

补：
文件的 Access time，atime 是在读取文件或者执行文件时更改的。
文件的 Modified time，mtime 是在写入文件时随文件内容的更改而更改的。
文件的 Create time，ctime 是在写入文件、更改所有者、权限或链接设置时随 Inode 的内容更改而更改的。
示例:
1. 查找.conf文件并确定文本类型
#find /etc -name “*.conf” | xargs file
2. iso-url.txt中有大量链接,可通过xargs逐一下载
#cat iso-url.txt | xargs wget -c
注:wget为命令行下载工具,-c为断点续传	




特殊权限
passwd:s

SUID: 运行某程序时，相应进程的属主是程序文件自身的属主，而不是启动者；
	chmod u+s FILE
	chmod u-s FILE
	***如果FILE本身原来就有执行权限，则SUID显示为s；否则显示S；
	[root@lcfyl ~]# ls -l /bin/cat
	-rwxr-xr-x. 1 root root 48008  6月 14 2010 /bin/cat
	[root@lcfyl ~]# ls -l /etc/shadow
	----------. 1 root root 1260  3月 10 16:52 /etc/shadow
	[root@lcfyl ~]# su mandriva
	[mandriva@lcfyl root]$ cat /etc/shadow
	cat: /etc/shadow: 权限不够
	[mandriva@lcfyl root]$ su
	密码：
	[root@lcfyl ~]# chmod u+s /bin/cat
	[root@lcfyl ~]# ls -l /bin/cat
	-rwsr-xr-x. 1 root root 48008  6月 14 2010 /bin/cat
	[root@lcfyl ~]# su mandriva
	[mandriva@lcfyl root]$ cat /etc/shadow
	root:$6$XL7K9QOmIRLHlTzO$OVs2QPjZhgAcPMwHWuaUSvvqfOr5j0u9Bjxbvx4MXAFEOuDOxqXRrCHB63b0TC0Xc42gEbkL.8W32yMPvIyVO1:16822:0:99999:7:::
	bin:*:14790:0:99999:7:::
	daemon:*:14790:0:99999:7:::
	adm:*:14790:0:99999:7:::
	lp:*:14790:0:99999:7:::


SGID: 运行某程序时，相应进程的属组是程序文件自身的属组，而不是启动者所属的基本组；
	chmod g+s FILE
	chmod g-s FILE
		多个成员：hadoop, hbase, hive
		公共目录：/tmp/project/
		功能：都能在公共目录创文件并且相互之间可以修改删除
		实现：创建成员附加组develop，将公共目录组改成develop加写权限，此时都能在里面创建删除各自文件但不能相互
		      修改删除，此时就用g+s就可以了
		[root@mail ~]# useradd hadoop && echo "hadoop" | passwd --stdin hadoop
		[root@mail ~]# useradd hive && echo "hive" | passwd --stdin hive
		[root@mail ~]# useradd hbase && echo "hbase" | passwd --stdin hbase
		[root@mail ~]# mkdir /tmp/project
		[root@mail ~]# groupadd develop
		[root@mail ~]# usermod -a -G develop hadoop
		[root@mail ~]# usermod -a -G develop hbase
		[root@mail ~]# usermod -a -G develop hive
		[root@mail ~]# chown -R .develop /tmp/project/
		[root@mail ~]# ll /tmp/project/ -d
		drwxr-xr-x 2 root develop 4096 Jun 15 00:50 /tmp/project/
		[root@mail ~]# chmod -R g+w /tmp/project/
		[root@mail ~]# ll /tmp/project/ -d
		drwxrwxr-x 2 root develop 4096 Jun 15 00:50 /tmp/project/
		[root@mail ~]# su - hadoop
		[hadoop@mail ~]$ cd /tmp/project/
		[hadoop@mail project]$ touch a.hadoop
		[hadoop@mail project]$ ls
		a.hadoop
		[root@mail ~]# su - hbase
		[hbase@mail ~]$ cd /tmp/project/
		[hbase@mail project]$ touch a.hbase
		*很显然不能修改别人文件内容
		[hbase@mail project]$ ll
		total 0
		-rw-rw-r-- 1 hadoop hadoop 0 Jun 15 01:08 a.hadoop
		-rw-rw-r-- 1 hbase  hbase  0 Jun 15 01:11 a.hbase
		[root@mail project]# chmod g+s /tmp/project/
		[root@mail project]# ll -d
		drwxrwsr-x 2 root develop 4096 Jun 15 01:43 .
		[hadoop@mail project]$ touch b.hadoop
		[hbase@mail project]$ touch b.hbase
		*此时SGID生效，可以修改别人的文件
		[hbase@mail project]$ ll
		total 0
		-rw-rw-r-- 1 hadoop hadoop  0 Jun 15 01:08 a.hadoop
		-rw-rw-r-- 1 hbase  hbase   0 Jun 15 01:11 a.hbase
		-rw-rw-r-- 1 hadoop develop 0 Jun 15 01:56 b.hadoop
		-rw-rw-r-- 1 hbase  develop 0 Jun 15 01:56 b.hbase

*****由于公共目录的公共组有写的权限，所以此目录下的文件可以相互删除，为了避免删除别人目录引入Sticky
Sticky: 在一个公共目录，每个都可以创建文件，删除自己的文件，但不能删除别人的文件；
	chmod o+t DIR
	chmod o-t DIR
		[root@mail ~]# su - hive
		[hive@mail project]$ ll
		total 4
		-rw-rw-r-- 1 hadoop develop 0 Jun 15 02:01 a.hadoop
		-rw-rw-r-- 1 hbase  hbase   0 Jun 15 01:11 a.hbase
		-rw-rw-r-- 1 hadoop develop 4 Jun 15 01:59 b.hadoop
		-rw-rw-r-- 1 hbase  develop 0 Jun 15 01:56 b.hbase
		[hive@mail project]$ rm -f a.hadoop 
		[hive@mail project]$ ls
		a.hbase  b.hadoop  b.hbase
		[root@mail ~]# chmod o+t /tmp/project/
		[root@mail ~]# ll -d /tmp/project/
		drwxrwsr-t 2 root develop 4096 Jun 15 02:01 /tmp/project/
		[hive@mail project]$ rm -rf a.hbase 
		rm: cannot remove `a.hbase': Operation not permitted
		[hive@mail project]$ 


***SUID,SGID,Sticky可以组合成一个特殊权限组合加到文件的权限列中放在首位
文件特殊权限
	SUID: s
	SGID: s
	Sticky: t 

	chmod u+s
	      g+s
	      o+t
		  
chmod 5755 /backup/test
umask 0022 这个前面的一个0就是特殊权限的组合


练习：写一个脚本
写一个脚本，显示当前系统上shell为-s指定类型的用户，并统计其用户总数。-s选项后面跟的参数必须是/etc/shells文件中存在的shell类型，
否则不执行此脚本。另外，此脚本还可以接受--help选项，以显示帮助信息。脚本执行形如：
./showshells.sh -s bash
显示结果形如：
BASH，3users，they are:
root,redhat,gentoo


#!/bin/bash
#
if [ $1 == '-s' ]; then
  ! grep "${2}$" /etc/shells &> /dev/null && echo "Invalid shell." && exit 7
elif [ $1 == '--help' ];then
  echo "Usage: showshells.sh -s SHELL | --help"
  exit 0
else
  echo "Unknown Options."
  exit 8
fi

NUMOFUSER=`grep "${2}$" /etc/passwd | wc -l`
SHELLUSERS=`grep "${2}$" /etc/passwd | cut -d: -f1`
SHELLUSERS=`echo $SHELLUSERS | sed 's@[[:space:]]@,@g'`

echo -e "$2, $NUMOFUSER users, they are: \n$SHELLUSERS"

文件系统访问列表：
FACL：Filesystem Access Control List
利用文件扩展保存额外的访问控制权限

jerry: rw-

setfacl：设定
	-m: 设定
		u:UID:perm
		g:GID:perm
			[mandriva@lcfyl facl]$ echo "456" >>inittab
			-bash: inittab: 权限不够
			[root@lcfyl ~]# setfacl -m u:mandriva:rw /tmp/facl/inittab 
			[root@lcfyl ~]# getfacl /tmp/facl/inittab 
			getfacl: Removing leading '/' from absolute path names
			# file: tmp/facl/inittab
			# owner: root
			# group: root
			user::rw-
			user:mandriva:rw-
			group::r--
			mask::rw-（***这个mask的意思是指定的权限一定不能超过这个mask权限，否则截掉）
			other::r--
			[mandriva@lcfyl facl]$ echo "456" >> inittab
			[mandriva@lcfyl facl]$ tail -5 inittab
			#   6 - reboot (Do NOT set initdefault to this)
			# 
			id:3:initdefault:
			456

	-x：取消
		u:UID
		g:GID
			[root@lcfyl ~]# setfacl -x u:mandriva /tmp/facl/inittab 
			[root@lcfyl ~]# getfacl /tmp/facl/inittab 
			getfacl: Removing leading '/' from absolute path names
			# file: tmp/facl/inittab
			# owner: root
			# group: root
			user::rw-
			group::r--
			mask::r--
			other::r--

*** [root@lcfyl ~]# ls -l /tmp/facl/inittab 
    -rw-r--r--+ 1 root root 892  3月 12 18:56 /tmp/facl/inittab
***可以看到这个权限位上有一个+号，表明有扩展权限setfacl（通过复制或归档都不会显示，除非用到特殊命令）
getfacl:获取显示访问控制权限列表

EXAMPLES
       Granting an additional user read access
              setfacl -m u:lisa:r file

       Revoking  write  access  from  all  groups and all named
       users (using the effective rights mask)
              setfacl -m m::rx file

       Removing a named group entry from a file’s ACL
              setfacl -x g:staff file

       Copying the ACL of one file to another
              getfacl file1 | setfacl --set-file=- file2

       Copying the access ACL into the Default ACL
              getfacl --access dir | setfacl -d -M- dir

***内核读取权限的顺序
一般：owner-group-other
特殊：owner-(facl,user)-group-(facl,group)-other

几个命令：
w：谁登陆了，正在干什么，比who更详细
[root@lcfyl ~]# w
 19:38:22 up  4:10,  4 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
root     tty1     -                19:29    8:30   0.04s  0.04s -bash
root     pts/0    192.168.3.28     15:28    0.00s  0.22s  0.07s w
mandriva pts/1    192.168.3.28     15:53   19:30   0.08s  0.08s -bash
hadoop   pts/2    192.168.3.28     15:53    3:31m  0.05s  0.05s -bash

who：谁登陆了
[root@lcfyl ~]# who
root     pts/0        2016-03-12 15:28 (192.168.3.28)
mandriva pts/1        2016-03-12 15:53 (192.168.3.28)
hadoop   pts/2        2016-03-12 15:53 (192.168.3.28)
***连到系统上的终端
终端类型：
	console: 控制台
	pty: 物理终端 (VGA)
	tty#: 虚拟终端 (VGA)
	ttyS#: 串行终端
	pts/#: 伪终端
还有几个常用选项：
[root@lcfyl ~]# who -r
         运行级别 3 2016-03-12 15:27
[root@lcfyl ~]# who -H
名称   线路       时间           备注
root     tty1         2016-03-12 19:29
root     pts/0        2016-03-12 15:28 (192.168.3.28)
mandriva pts/1        2016-03-12 15:53 (192.168.3.28)
hadoop   pts/2        2016-03-12 15:53 (192.168.3.28)

last，显示/var/log/wtmp文件，显示用户登录历史及系统重启历史
	-n #: 显示最近#次的相关信息
[root@lcfyl ~]# last -n 5
root     tty1                          Sat Mar 12 19:29   still logged in   
hadoop   pts/2        192.168.3.28     Sat Mar 12 15:53   still logged in   
mandriva pts/1        192.168.3.28     Sat Mar 12 15:53   still logged in   
hadoop   pts/2        192.168.3.28     Sat Mar 12 15:29 - 15:52  (00:23)    
mandriva pts/1        192.168.3.28     Sat Mar 12 15:29 - 15:52  (00:23)    
wtmp begins Sat Jan 23 00:17:21 2016



lastb，/var/log/btmp文件，显示用户错误的登录尝试
	-n #: 显示最近#次的相关信息
lastlog: 显示每一个用户最近一次的成功登录信息；
	-u USERNAME: 显示特定用户最近的登录信息

basename：取一个文件的基名
	$0: 执行脚本时的脚本路径全称（避免脚本改名，脚本还得改路径）
	
mail：默认系统装一个邮件服务，自动监控系统资源，如果有异常就发给用户

[root@lcfyl ~]# mail -s "How are you?" root < /etc/fstab

或者：

[root@lcfyl ~]# cat /etc/fstab | mail -s "How are you?" root
[root@lcfyl ~]# mail
Heirloom Mail version 12.4 7/29/08.  Type ? for help.
"/var/spool/mail/root": 1 message 1 new
>N  1 root                  Sat Mar 12 19:56  32/1354  "How are you?"
& n
Message  1:
From root@lcfyl.localdomain  Sat Mar 12 19:56:31 2016
Return-Path: <root@lcfyl.localdomain>
X-Original-To: root
Delivered-To: root@lcfyl.localdomain
Date: Sat, 12 Mar 2016 19:56:31 +0800
To: root@lcfyl.localdomain
Subject: How are you?
User-Agent: Heirloom mailx 12.4 7/29/08
Content-Type: text/plain; charset=us-ascii
From: root@lcfyl.localdomain (root)
Status: R
# /etc/fstab
# Created by anaconda on Sat Jan 23 00:08:19 2016


hostname: 显示主机名
如果当前主机的主机名不是www.magedu.com，就将其改为www.magedu.com

如果当前主机的主机名是localhost，就将其改为www.magedu.com

如果当前主机的主机名为空，或者为(none)，或者为localhost，就将其改为www.magedu.com
[ -z `hostname` ] || [ `hostname` == '(none)' -o `hostname` == 'localhost' ] && hostname www.magedu.com
[ root@lcfyl ~]# [ `hostname` = "" -o `hostname`="(none)" -o `hostname`="localhost" ] && hostname "www.lcfyl.com"
[ root@lcfyl ~]# hostname
www.lcfyl.com


生成随机数
RANDOM: 0-32768

随机数生成器：熵池
/dev/random:
/dev/urandom:

写一个脚本，利用RANDOM生成10个随机数，并找出其中的最大值，和最小值；
#!/bin/bash
#
declare -i MAX=0
declare -i MIN=0

for I in {1..10}; do
  MYRAND=$RANDOM
  [ $I -eq 1 ] && MIN=$MYRAND
  if [ $I -le 9 ]; then
    echo -n "$MYRAND,"
  else
    echo "$MYRAND"
  fi
  [ $MYRAND -gt $MAX ] && MAX=$MYRAND
  [ $MYRAND -lt $MIN ] && MIN=$MYRAND
done

echo $MAX, $MIN

面向过程
	控制结构
		顺序结构
		选择结构
		循环结构

选择结构：
if: 单分支、双分支、多分支
if CONDITION; then
  statement
  ...
fi

if CONDITION; then
  statement
  ...
else
  statement
  ...
fi

if CONDITION1; then
  statement
  ...
elif CONDITION2; then
  statement
  ...
else
  statement
  ...
fi


case语句：选择结构

case SWITCH in 
value1)
  statement
  ...
  ;;
value2)
  statement
  ...
  ;;
*)
  statement
  ...
  ;;
esac

只接受参数start,stop,restart,status其中之一
#!/bin/bash
#
DEBUG=0
ADD=0
DEL=0
if [ $# -lt 1 ];then
		echo "Usage: `basename $0` --add USER_LIST --del USER_LIST -v|--verbose -h|--help"
		exit 7
else
	for I in `seq 1 $#`;do
		case $1 in
		-v|--verbose)
			DEBUG=1
			shift;;
		-h|--help)
			echo "Usage: `basename $0` --add USER_LIST --del USER_LIST -v|--verbose -h|--help"
			exit 0
			;;
		--add)
			ADD=1
			ADDUSERS=$2
			shift 2
			;;
		--del)
			DEL=1
			DELUSERS=$2
			shift 2
			;;
		*)
			if  [[ $1 != '' ]];then
				echo "Usage: `basename $0` --add USER_LIST --del USER_LIST -v|--verbose -h|--help"
				exit 7
			fi
			;;
		esac
	done
fi
			
if [ $ADD -eq 1 ];then
	for USER in `echo $ADDUSERS | sed 's@,@ @g'`;do
		if id $USER &> /dev/null;then
			echo "$USER exits."
		else
			useradd $USER
			[ $DEBUG -eq 1 ]&&echo "$USER was added already"
		fi
	done
fi
if [ $DEL -eq 1 ];then
	for USER in `echo $DELUSERS | sed 's@,@ @g'`;do
		if id $USER &> /dev/null;then
			userdel -r $USER
			[ $DEBUG -eq 1 ] && echo "$USER was deleted already"
		else
			echo "$USER doesn't exit"
		fi
	done
fi

练习：写一个脚本showlogged.sh，其用法格式为：
showlogged.sh -v -c -h|--help
其中，-h选项只能单独使用，用于显示帮助信息；-c选项时，显示当前系统上登录的所有用户数；如果同时使用了-v选项，则既显示同时登录的用户数，又显示登录的用户的相关信息；如
Logged users: 4. 

They are:
root     tty2         Feb 18 02:41
root     pts/1        Mar  8 08:36 (172.16.100.177)
root     pts/5        Mar  8 07:56 (172.16.100.177)
hadoop   pts/6        Mar  8 09:16 (172.16.100.177)

#!/bin/bash
#
declare -i SHOWNUM=0
declare -i SHOWUSERS=0

for I in `seq 1 $#`; do
  if [ $# -gt 0 ]; then
    case $1 in
    -h|--help)
      echo "Usage: `basename $0` -h|--help -c|--count -v|--verbose"
      exit 0 ;;
    -v|--verbose)
      let SHOWUSERS=1
      shift ;;
    -c|--count)
      let SHOWNUM=1
      shift ;;
    *)
      echo "Usage: `basename $0` -h|--help -c|--count -v|--verbose"
      exit 8 ;;
    esac
  fi
done

if [ $SHOWNUM -eq 1 ]; then
  echo "Logged users: `who | wc -l`."
  if [ $SHOWUSERS -eq 1 ]; then
    echo "They are:"
    who
  fi
fi

	
shell: 链接
ln [-s -v] SRC DEST
ln [选项] 源文件 链接文件
	-f 删除已存在的目的文件
	-i 如果碰到有重复名字的提示如何操作
	-v 显示操作信息
	-s 软链接选项
硬链接
[root@lcfyl backup]# cp /etc/rc.d/rc.sysinit ./abc
[root@lcfyl backup]# mkdir test
[root@lcfyl backup]# ln abc test/abc2
[root@lcfyl backup]# ls -i
784280 abc  784282 test
[root@lcfyl backup]# ls -li test/abc2 
784280 -rwxr-xr-x. 2 root root 19088  3月 14 15:37 test/abc2


软链接
[root@lcfyl ~]# mkdir backup
[root@lcfyl ~]# cd backup/
[root@lcfyl backup]# cp /etc/rc.d/rc.sysinit abc1
[root@lcfyl backup]# mkdir test
[root@lcfyl backup]# ln -sv /root/backup/abc1 test/abc2
"test/abc2" -> "/root/backup/abc1"
[root@lcfyl backup]# ls -li test/
总用量 0
784282 lrwxrwxrwx. 1 root root 12  3月 15 12:20 abc2 -> /root/backup/abc1
[root@lcfyl backup]# rm -rf abc1 
[root@lcfyl backup]# cat test/abc2 
cat: test/abc2: 没有那个文件或目录
[root@lcfyl backup]# cp /etc/inittab /root/backup/abc1
[root@lcfyl backup]# cat test/abc2 
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
[root@lcfyl backup]# ls -li test/
总用量 0
784282 lrwxrwxrwx. 1 root root 12  3月 15 12:20 abc2 -> /root/backup/abc1

*** 也就是说软链接指的只是路径，就算换一个文件，inode号变了，但是路径没变，依然生效


硬链接：
	1、只能对文件创建，不能应用于目录；
	2、不能跨文件系统；
	3、创建硬链接会增加文件被链接的次数；
	
符号链接：
	1、可应用于目录；
	2、可以跨文件系统；
	3、不会增加被链接文件的链接次数；
	4、其大小为指定的路径所包含的字符个数；

du ：显示目录下每个文件的大小
	-s 
	-h
[root@lcfyl ~]# du -sh /etc/issue
4.0K	/etc/issue

	
df: 显示文件系统利用情况
	
链接

设备文件：
	b: 按块为单位，随机访问的设备；
	c：按字符为单位，线性设备；
	
	b: 硬盘
	c: 键盘
	
/dev
	主设备号 （major number）
		标识设备类型
	次设备号 （minor number）
		标识同一种类型中不同设备
创建设备文件
mknod
mknod [OPTION]... NAME TYPE [MAJOR MINOR]
	-m MODE
	
硬盘设备的设备文件名：
IDE, ATA：hd
SATA：sd
SCSI: sd
USB: sd
	a,b,c,...来区别同一种类型下的不同设备
	
IDE: 
	第一个IDE口：主、从
		/dev/hda, /dev/hdb
	第二个IDE口：主、从
		/dev/hdc, /dev/hdd

sda, sdb, sdc, ...

hda: 
	hda1: 第一个主分区
	hda2: 
	hda3:
	hda4:
	hda5: 第一个逻辑分区（只能从5开始算逻辑分区）
	
查看当前系统识别了几块硬盘：
fdisk -l [/dev/to/some_device_file]

管理磁盘分区：
fdisk /dev/sda
	p: 显示当前硬件的分区，包括没保存的改动
	n: 创建新分区
		e: 扩展分区
		p: 主分区
	d: 删除一个分区
	w: 保存退出
	q: 不保存退出
	t: 修改分区类型
		L: 
	l: 显示所支持的所有类型
	
partprobe：通知内核重读分区表（新建分区不会立即生效）
[root@lcfyl ~]# partprobe /dev/sdb
[root@lcfyl ~]# cat /proc/partitions 
major minor  #blocks  name

   8        0   20971520 sda
   8        1     512000 sda1
   8        2   20458496 sda2
   8       16   20971520 sdb
   8       17    5253223 sdb1
   8       18    5253255 sdb2
   8       19          1 sdb3
   8       21    5253223 sdb5
 253        0   16293888 dm-0
 253        1    4161536 dm-1




练习：写一个脚本
通过命令行传递一个文件路径参数给脚本：
	如果参数多了或少了，报错；
	如果参数指定的路径对应的是目录而不是文件，报错；
而后，检查路径指定的文件是否为空或不存在，如果是，则新建此文件，并在文件中生成如下内容
#!/bin/bash
# 
而后，使用vim编辑器打开此文件，并让光标处于这个文件的最后一行；



写个脚本，按如下方式执行：
mkscript.sh -v|--version VERSION -a|--author AUTHOR -t|--time DATETIME -d|--description DESCRIPTION -f|--file /PATH/TO/FILE -h|--help 

1、此脚本能创建或打开-f选项指向的文件/PATH/TO/FILE；如果其为空文件，能自动为其生成第一行；如果文件不空，且第一行不是#!/bin/bash，则中止此脚本，并报错“The file is not a bash script."；否则，则直接使用vim 打开此文件；
提示：/PATH/TO/FILE，要判断其目录是否存在；如果不存在，则报错；

2、如果为空文件，自动生成的第一行内容为：
#!/bin/bash
3、如果为空文件，且使用了-a选项，则在文件中添加“# Author: -a选项的参数”，比如：
# Author: Jerry
4、如果为空文件，且使用了-t选项，则在文件中添加“# Date: 脚本执行-t选项后指定的时间”，比如：
# Date: 2013-03-08 18:05
5、如果为空文件，且使用了-d选项，则在文件中添加“# Description: -d选项的内容”，比如：
# Description: Create a bash script file head.
6、如果为空文件，且使用了-v选项，则在文件添加“# Version: -v后跟的参数”，比如:
# Version: 0.1
6、-h选项只能单独使用，用于显示使用帮助；
7、其它选项，显示帮助信息；

说明：
这是一个用于创建脚本的脚本，它可以自动帮助创建一个bash脚本的文件头，这样，以后使用此脚本来创建其它脚本将变得比较高效。比如：
#!/bin/bash
# Author: Jerry(jerry@magedu.com)
# Date: 2013-03-08 18:05
# Description: Create a bash script file head.
# Version: 0.1
#


***脚本生成器：
*系统内置命令或变量getopts, $OPTIND, $OPTARG
***getopts用法：
这里变量$OPTARG存储相应选项的参数，而$OPTIND总是存储原始$*中下一个要处理的元素位置。
while getopts ":a:bc" opt  #字符后面的冒号表示该选项必须有自己的参数，如果没有参数会报错，但是最前面有一个：号那就会忽略错误
代码实例(getopts.sh)：
echo $*
while getopts ":a:bc" opt
do
        case $opt in
                a ) echo $OPTARG
                    echo $OPTIND;;
                b ) echo "b $OPTIND";;
                c ) echo "c $OPTIND";;
                ? ) echo "error"
                    exit 1;;
        esac
done
echo $OPTIND
shift $(($OPTIND - 1))#通过shift $(($OPTIND - 1))的处理，$*中就只保留了除去选项内容的参数，可以在其后进行正常的shell编程处理了。
echo $0
echo $*
执行命令：./getopts.sh -a 11 -b -c
-a 11 -b -c
11
3
b 4
c 5
5
./getopts.sh


#!/bin/bash
# Name: mkscripts
# Description: Create a script
# Author: Mr_yu
# Version: 0.0.1
# Datetime: 2017-11-8 
# Usage: mkscript FILENAME
if [ $# -eq 0 ];then
	echo "Usage: `basename $0` [-d DESCRIPTION] FILENAME"
	exit 8
fi
while getopts ":d:" opt;do
	case $opt in
	d)
		DESC=$OPTARG;;
	\?)
		echo "Usage: `basename $0` [-d DESCRIPTION] FILENAME"
		exit 8
		;;
	esac
done
shift $[$OPTIND-1]
if [[ $1 = "" ]];then
	echo "Usage: `basename $0` [-d DESCRIPTION] FILENAME"
	exit 8
fi
	
if ! grep "[^[:space:]]" $1 &> /dev/null;then
cat >> $1 <<EOF
#!/bin/bash
# Name: `basename $1`
# Description: $DESC
# Author: Mr_yu
# Version: 0.0.1
# Datetime: `date +"%F %T"`
# Usage: `basename $1`
EOF
fi

vim + $1

until bash -n $1 &> /dev/null;do
	read -p "Syntax error,q|Q for quiting, others for editing:" OPT
	case $OPT in
	q|Q)
		echo "quiting..."
		exit 8
		;;
	*)	
		vim + $1
		;;
	esac
done
chmod +x $1
