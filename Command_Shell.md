CPUӲ���ܹ�����ʷ
1971����ʷ��һ��CPU 4044
	2300������ܡ�4λ
1978��i8086��i8087
	ָ��໥���� ��x86ָ� 16λ
1979��8088оƬ
	��һ��ɹ����ڸ��˵���
1982��80286оƬ
	��������16λ����ַ����24λ��Ѱַ16MB�ڴ�
1985��80386оƬ
	�ڲ��ⲿ�������߶���32λ��Ѱַ4GB�ڴ�
1989��80486оƬ
	��һ�ξ���ܼ���120�����һ��ʱ������ִ��2��ָ��
--------------------------------------------------------------
90���ĩintel����MMX����CPU�ɳ�Ƶ
P4��P5����ǿ�ĺ� ������ĺˡ�I7��I3��I5

90���ĩintelͶ��64λ�������з�����x86��ϵ������ʧ�ܣ�AMD�з�������x86ǰ�ڲ�Ʒ��64λCPU�����ڳ�ͷ

��ͬ�������µ���ƵԽ���ٶ�Խ��
	���ղ�ͬ��Ч����ȫ��ͬ
	ǰ��CPU�������ٶ�һ��
		����CPU��죬������ƵX������������CPU�ļ����ٶ�
ǰ������Ƶ��FSB
	CPU���ڴ潻����Ƶ��
	FSB:400MHz
	(400x64bit)/8bit/Byte=3200MB
���棺L2��L3�������ݽ���
SMP���Գƶദ��������������
--------------------------------------------------------------
Linux�Ļ���ԭ��
1����Ŀ�ĵ�һ��С������ɣ����С������ɸ�������
2��һ�н��ļ���
3���������Ⲷ���û��ӿڣ�
4�������ļ�����Ϊ���ı���ʽ��

GUI�ӿڣ�ͼ�λ�
CLI�ӿڣ�������
	������ʾ����prompt, bash(shell)
		#: root
		$: ��ͨ�û�
	���

�����ʽ��
	����  ѡ��  ����
		ѡ�
			��ѡ� -
				���ѡ�������ϣ�-a -b = -ab
			��ѡ� --
		��������������ö���
			
�����ն�(terminal)��Ctrl+Alt+F1-F6

���븴���Թ���
Linuxedu@126.com
	1��ʹ��4������ַ�������3�֣�
	2���㹻��������7λ��
	3��ʹ������ַ�����
	4�����ڸ�����
	5��ѭ�������㹻��
	
��֤���ƣ�Authentication
��Ȩ��Authorization
��ƣ�Audition (��־)

���������ʽ��
# command  options...  arguments...
ls
	-l������ʽ
		�ļ����ͣ�
			-����ͨ�ļ� (f)
			d: Ŀ¼�ļ�
			b: ���豸�ļ� (block)
			c: �ַ��豸�ļ� (character)
			l: ���������ļ�(symbolic link file)
			p: ����ܵ��ļ�(pipe)
			s: �׽����ļ�(socket)
		�ļ�Ȩ�ޣ�9λ��ÿ3λһ�飬ÿһ�飺rwx(����д��ִ��), r--
		�ļ�Ӳ���ӵĴ���
		�ļ�������(owner)
		�ļ�������(group)
		�ļ���С(size)����λ���ֽ�
		ʱ���(timestamp)�����һ�α��޸ĵ�ʱ��
			����:access
			�޸�:modify���ļ����ݷ����˸ı�
			�ı�:change��metadata��Ԫ����
	-h������λת��(KB,MB,GB)
	-a: ��ʾ��.��ͷ�������ļ�
		. ��ʾ��ǰĿ¼
		.. ��ʾ��Ŀ¼
	-A: ��ʾ�����ļ����������� . �� ..
	-d: ��ʾĿ¼��������
	-i: index node, inode
	-r: ������ʾ
	-R: �ݹ�(recursive)��ʾ
	
cd: change directory
	��Ŀ¼����Ŀ¼, home directory
	cd ~USERNAME: ����ָ���û��ļ�Ŀ¼
	cd -:�ڵ�ǰĿ¼��ǰһ�����ڵ�Ŀ¼֮�������л�

�������ͣ�
	��������(shell����)���ڲ����ڽ�
	�ⲿ������ļ�ϵͳ��ĳ��·������һ��������������Ӧ�Ŀ�ִ���ļ�
	
�����������������ڴ�ռ�
	������ֵ
		NAME=Jerry
		
	PATH: ʹ��ð�ŷָ���·��
	O(1)

type: ��ʾָ��������������
	type: type [-afptP] name [name ...]
	Display information about command type.
	
date��ʱ�����
	-R, --rfc-2822
              output date and time in RFC 2822 format.  Example: Mon, 07 Aug 2006 12:34:56 -0600
	-u
	   UTC(Universal Time Coordinated)
		��GMT����һ��
		CST�������Լ��ı�׼ʱ��
date [+format]
	[root@localhost ~]# date +%c
	Mon 23 Oct 2017 05:37:33 PM EDT
	[root@localhost ~]# 

	%s ��1970��1��1��0ʱ0�ֿ�ʼ���㵽Ŀǰ��������ʱ��
	%j ��ʾһ���еĵڼ��� %M ����(00-59)
	[root@localhost ~]# date +%D
	10/24/17
	[root@localhost ~]# date +%A
	Tuesday
	[root@localhost ~]# date +%H
	14
	[root@localhost ~]# date +%H%D
	1410/24/17
	[root@localhost ~]# 

����1. �鿴1945��8��15�������ڼ�(��ǰʱ��Ϊ2017-10-24)
	[root@localhost ~]# date -d "-72 year -2 month -9 days"
	Wed Aug 15 15:01:16 CST 1945
	[root@localhost ~]#
    2. �鿴2045��8��15�������ڼ�(��ǰʱ��Ϊ2017-10-24)
	[root@localhost ~]# date -d "+28 years -2 months -9 days"
	Tue Aug 15 15:30:11 CST 2045
	[root@localhost ~]# 
    3. �鿴2015-9-9��1970-1-1������
	[root@localhost ~]# date -d "2015-10-25" +%s
	1445702400
	[root@localhost ~]# 
Linux: rtc

	Ӳ��ʱ��
	ϵͳʱ��

hwclock Ӳ��ʱ��
	hwclock -w systohc
	hwclock -s hctosys

tzselect ʱ��ѡ��
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

timedatectl ��ʾ����ʱ��
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
��ʾϵͳ��֧�ֵ�ʱ������
	[root@localhost ~]# timedatectl list-timezones | more
	Africa/Abidjan
	Africa/Accra
	Africa/Addis_Ababa
	Africa/Algiers
	........
���õ�ǰʱ��
	[root@localhost ~]# timedatectl set-timezone Asia/Shanghai
	[root@localhost ~]# 
���õ�ǰϵͳʱ��
	[root@localhost ~]# timedatectl set-time "2017-9-9 12:00:00"
	[root@localhost ~]# date
	Sat Sep  9 12:00:01 CST 2017
	[root@localhost ~]# 
����ntpʱ��ͬ���Ƿ�����ǰ��ntp������������
	[root@localhost ~]# timedatectl set-ntp true


��������ʹ�ð�����
�ڲ����
	help COMMAND
�ⲿ���
	COMMAND --help
	
�����ֲ᣺manual
man COMMAND

whatis COMMAND

���½ڣ�
1���û�����(/bin, /usr/bin, /usr/local/bin)
2��ϵͳ����
3�����û�
4�������ļ�(�豸�ļ�)
5���ļ���ʽ(�����ļ����﷨)
6����Ϸ
7������(Miscellaneous)
8: ��������(/sbin, /usr/sbin, /usr/local/sbin)

<>����ѡ
[]����ѡ
...�����Գ��ֶ��
|����ѡһ
{}������

MAN��
	NAME���������Ƽ����ܼ�Ҫ˵��
	SYNOPSIS���÷�˵�����������õ�ѡ��
	DESCRIPTION������ܵ��꾡˵�������ܰ���ÿһ��ѡ�������
	OPTIONS��˵��ÿһ��ѡ�������
	FILES����������ص������ļ�
	BUGS��
	EXAMPLES��ʹ��ʾ��
	SEE ALSO���������

������
	���һ����SPACE
	��ǰ��һ����b
	���һ�У�ENTER
	��ǰ��һ�У�k

���ң�
/KEYWORD: ���
n: ��һ��
N��ǰһ�� 

?KEYWORD����ǰ
n: ��һ��
N��ǰһ�� 

q: �˳�

��ϰ��
	ʹ��date������ȡϵͳ��ǰ����ݡ��·ݡ��ա�Сʱ�����ӡ���
	
hwclock
	-w: ϵͳʱ�ӵ�Ӳ��
	-s: Ӳ��ʱ�ӵ�ϵͳ


cal: calendar

��ϰ��
1��echo���ڲ�������ⲿ���
2�������ã�
3�������ʾ��The year is 2013. Today is 26.��Ϊ���У�

ת�壬����

��ϰ��
1��printf���ڲ�������ⲿ���
2�������ã�
3�������ʾ��The year is 2013. Today is 26.��Ϊ���У�

�ļ�ϵͳ��
rootfs: ���ļ�ϵͳ

FHS��Linux

/boot: ϵͳ������ص��ļ������ںˡ�initrd���Լ�grub(bootloader)
/dev: �豸�ļ�
	�豸�ļ���
		���豸��������ʣ����ݿ�
		�ַ��豸�����Է��ʣ����ַ�Ϊ��λ
		�豸�ţ����豸�ţ�major���ʹ��豸�ţ�minor��
/etc�������ļ�
/home���û��ļ�Ŀ¼��ÿһ���û��ļ�Ŀ¼ͨ��Ĭ��Ϊ/home/USERNAME
/root������Ա�ļ�Ŀ¼��
/lib�����ļ�
	��̬��,  .a
	��̬�⣬ .dll, .so (shared object)
	/lib/modules���ں�ģ���ļ�
/media�����ص�Ŀ¼���ƶ��豸
/mnt�����ص�Ŀ¼���������ʱ�ļ�ϵͳ
/opt����ѡĿ¼������������İ�װĿ¼
/proc��α�ļ�ϵͳ���ں�ӳ���ļ�
/sys��α�ļ�ϵͳ����Ӳ���豸��ص�����ӳ���ļ�
/tmp����ʱ�ļ�, /var/tmp
/var���ɱ仯���ļ�
/bin: ��ִ���ļ�, �û�����
/sbin����������

/usr��shared, read-only
	/usr/bin
	/usr/sbin
	/usr/lib
	
/usr/local���������Ϊ����������Ĺ�����򣬲�Ӱ�����ϵͳ��
	/usr/local/bin
	/usr/local/sbin
	/usr/local/lib

��������
1�����Ȳ��ܳ���255���ַ���
2������ʹ��/���ļ���
3���ϸ����ִ�Сд
	
mkdir��������Ŀ¼
	-p: û�е�Ŀ¼�Զ�������mkdir -p m/n/p���Զ�����m n pĿ¼)
	-v: verbose ����ʾ�꾡��Ϣ����ʾ�������̣�
/root/x/y/z

/mnt/test/x/m,y
mkdir -pv /mnt/test/x/m /mnt/test/y
mkdir -pv /mnt/test/{x/m,y}

~USERNAME 

������չ����
/mnt/test2/
a_b, a_c, d_b, d_c
(a+d)(b+c)=ab+ac+db+dc
{a,d}_{b,c}


# tree���鿴Ŀ¼��

ɾ��Ŀ¼��rmdir (remove directory)
	ɾ����Ŀ¼
	-p
	
�ļ�������ɾ��
# touch	�ı�ʱ���
	-a: change only the access time
	-m: change only the modification time
	-t STAMP
              use [[CC]YY]MMDDhhmm[.ss] instead of current time
	-c, --no-create
              do not create any files
# stat  �鿴ʱ���
stat �鿴�ļ���ϸ״̬
	[root@localhost ~]# stat -f /
	  File: "/"
	    ID: b53d57595370a614 Namelen: 255     Type: ext2/ext3
	Block size: 4096       Fundamental block size: 4096
	Blocks: Total: 2547534    Free: 2303699    Available: 2172627
	Inodes: Total: 655360     Free: 627590
	[root@localhost ~]# 

ɾ���ļ���rm
	-i����ɾ���ļ�֮ǰ��Ҫ�ֹ�ȷ��
	-f: force ǿ��ɾ��������yes or no
	-r: recursive �ݹ飬ɾ��Ŀ¼�������е�Ŀ¼���ļ�
	
rm -rf / :ɾ�����еĸ��ļ���������������

��ϰ��
1������Ŀ¼
(1)��/mnt�´���boot��sysroot��
(2)��/mnt/boot�´���grub��
(3)��/mnt/sysroot�´���proc, sys, bin, sbin, lib, usr, var, etc, dev, home, root, tmp
	a)��/mnt/sysroot/usr�´���bin, sbin, lib
	b)��/mnt/sysroot/lib�´���modules
	c)��/mnt/sysroot/var�´���run, log, lock
	d)��/mnt/sysroot/etc�´���init.d
	

���ƺ��ƶ��ļ�
cp�� copy
cp SRC DEST
	-r���ݹ飬��Ŀ¼���ļ�һ���Ը��Ƶ�Ŀ�ĵ�
	-i��cp �� cp -i �ı��������Ǹ���ǰ��ʾ
	-f
	-p����������������
	-a���鵵���ƣ������ڱ���
	

cp file1 file2 file3
һ���ļ���һ���ļ�
����ļ���һ��Ŀ¼
cp /etc/{passwd,inittab,rc.d/rc.sysinit} /tmp/

mv [ѡ��] Դ�ļ� Ŀ��·��
	-i ���Ŀ�ĵ�����ͬ�ļ���ʱ�������ʾ
	-v �ڰ����ļ�ʱ��ʾ���ȣ����ƶ����ļ�
	ʱ�ǳ�����
	-u ���ƶ�ʱֻ��Դ�ļ���Ŀ���ļ��µ�ʱ��Ż��ƶ�����Ŀ���ļ���ʧ���ƶ�
	-f ǿ�Ƹ������е��ļ�
	

install
	-d DIRECOTRY ... ������Ŀ¼
	SRC DEST
install -t DIRECTORY SRC...

��ҵ1��
1������Ŀ¼/backup
# mkdir -v /backup
2������Ŀ¼/etc��/backupĿ¼�У���������Ϊ��etc-��ǰ���ڡ�����etc-2013-02-26��Ҫ�����ļ�ԭ�������ԣ����������ļ���
cp
	-r 
	-p
	-d
# cp -a /etc /backup/etc-2013-02-28

�����滻
	
3�������ļ�/etc/inittabΪ/tmp/inittab.new����ɾ��inittab.new�ļ��ĺ����У�
# cp /etc/inittab  /tmp/inittab.new
# nano /tmp/inittab.new

��ҵ4��
1����λ�ȡLinux��ǰ���µ��ں˰汾�ţ�
	www.kernel.org
2���г������˽��Linux���а棬��˵�����Linux�ں˵Ĺ�ϵ��
	Linux, GNU: GNU/Linux, Դ����
	
	���а棺Fedora, RedHat(CentOS), SUSE, Debian(Ubuntu, Mint), Gentoo, LFS(Linux From Scratch)
	
Ŀ¼����
ls��cd��pwd��mkdir��rmdir��tree

�ļ�����
touch��stat��file��rm��cp��mv��nano

����ʱ�䣺
date��clock��hwclock��cal

�鿴�ı���
cat��tac��more��less��head��tail

cat�����Ӳ���ʾ
	-s ��������кϲ���һ���������
	-b ��ʾ�ļ����ݵ�ʱ����ʾ����
	-n����ʾ�к�
	-E��Linux�л��з�Ϊ$����windows��dollar���ӻ��з���linux���ı���windows��ֻ��ʾһ��
tac��������ʾ����������;��	

Ctrl+c

������ʾ��
more��less

more [ѡ��] �ļ���
	+����  ֱ�ӴӸ�����������ʼ��ʾ
	-s ���������ѹ����һ������
	-p �����Ļ������ʾ

head [ѡ��] �ļ�
	-n <����> ��ʾ�ļ�����ǰָ������
	-c <�ֽ���> ��ʾ�ļ�ǰN���ֽ����������
	-q ������ļ�ͷ������
	-v ����ļ�ͷ������
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

tail [ѡ��] �ļ�
	-f ѭ����ȡ
	-c <�ֽ���> ��ʾ�ļ�ǰN���ֽ����������
	-q ������ļ�ͷ������
	-n <����> ָ������ʾ������
	-v ����ļ�ͷ������

diff [ѡ��] file1 file2
	��ʾ��Ϣ:
	a Ϊ��Ҫ����
	d Ϊ��Ҫɾ��
	c Ϊ��Ҫ�޸�
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

tail:�鿴��n��
	-n ����ʾn��
	��д�� tail -n 2 /etc/inittab �� tail -2 /etc/inittab
	
tail -f: �鿴�ļ�β�������˳����ȴ���ʾ����׷�������ļ��������ݣ�


�ı�����
cut��join��sed��awk

cut:
	-d: ָ���ֶηָ�����Ĭ���ǿո�
	-f: ָ��Ҫ��ʾ���ֶ�
		-f 1,3 ��һ�͵�����
		-f 1-3 һ����
	#cut -d : -f 1 /etc/passwd
	
�ı�����sort
	-n����ֵ����
	-r: ����
	-t: �ֶηָ���
	-k: ���ĸ��ֶ�Ϊ�ؼ��ֽ�������
	-u: �������ͬ����ֻ��ʾһ��
	-f: ����ʱ�����ַ���Сд
	
uniq:	ֻ�����ڵ�����Ϊ�ظ��У�����ֻ����һ��
	-c: ��ʾ�ļ������ظ��Ĵ���
	-d: ֻ��ʾ�ظ�����
	
�ı�ͳ�ƣ�wc (word count)
	-l��ֻ��ʾ����
	-w��ֻ��ʾ������
	-c��ֻ��ʾ�ֽ���
	-L����ʾ�һ�а��������ַ�

�ַ��������tr ���� ת����ɾ���ַ�
tr [OPTION]... SET1 [SET2]
	-d: ɾ���������ַ����е������ַ�


#tr ab AB
abc
ABc
begin
Begin
access
Access

#tr 'a-z' 'A-Z' < /etc/passwd
#tr -d ab


bash�������ԣ�
shell: ���
GUI��Gnome, KDE, Xfce
CLI: sh, csh, ksh, bash, tcsh, zsh

root, student
����  ����

���̣���ÿ�����̿�������ǰ������ֻ�����ں˺͵�ǰ����
�����ǳ���ĸ����������ǳ���ִ��ʵ�����������һ�����������ж�����̸������ں�ʶ������ý��̺ţ�

�û�����������
bash:
	#
	$
	
	tom, jerry
	
shell����shell��shell�п��Դ�shell��

bash--bash

bash: 
1��������ʷ�����ȫ
2���ܵ����ض���
3���������
4�������б༭
5��������չ��
6���ļ���ͨ��
7������
8�����

�����б༭��
�����ת��
	Ctrl+a��������������
	Ctrl+e������������β
	Ctrl+u: ɾ��������������׵�����
	Ctrl+k: ɾ�������������β������
	Ctrl+l: ����
	
������ʷ��
�鿴������ʷ��history
	-c�����������ʷ
	-d OFFSET [n]: ɾ��ָ��λ�õ����ɾ��n��
	-w������������ʷ����ʷ�ļ���
	
��������
PATH����������·��
HISTSIZE: ������ʷ��������С
#echo $HISTSIZE


������ʷ��ʹ�ü��ɣ�
!n��ִ��������ʷ�еĵ�n�����
!-n:ִ��������ʷ�еĵ�����n����� 
!!: ִ����һ�����
!string��ִ��������ʷ�����һ����ָ���ַ�����ͷ������

!$:����ǰһ����������һ������; ��Esc, .Alt+.��


���ȫ��·����ȫ
	���ȫ������PATH����������ָ����ÿ��·���������Ǹ������ַ�����ͷ�Ŀ�ִ���ļ����������һ��������tab�����Ը����б�����ֱ�Ӳ�ȫ��
	·����ȫ���������Ǹ�������ʼ·���µ�ÿ���ļ���������ͼ��ȫ��


�������
alias CMDALIAS='COMMAND [options] [arguments]'
��shell�ж���ı������ڵ�ǰshell������������Ч����������Ч��Χ��Ϊ��ǰshell���̣�
���������������Ч������Bash�����ļ��и��Ŀ�ȫ��������Ч���������Լ���Ŀ¼.bashrcҲ������ȫ��/etc/bashrc

unalias CMDALIAS

\CMD


�����滻: $(COMMAND), �����ţ�`COMMAND`
��������ĳ���������滻Ϊ��ִ�н���Ĺ���
file-2013-02-28-14-53-31.txt  


bash֧�ֵ����ţ�
``: �����滻
"": �����ã�����ʵ�ֱ����滻
'': ǿ���ã�����ɱ����滻


�ļ���ͨ��, globbing
*: ���ⳤ�ȵ������ַ�
?�����ⵥ���ַ�
[]��ƥ��ָ����Χ�ڵ����ⵥ���ַ�
	[abc], [a-m], [a-z], [A-Z], [0-9], [a-zA-Z], [0-9a-zA-Z]
	[:space:]���հ��ַ�
	[:punct:]��������
	[:lower:]��Сд��ĸ
	[:upper:]: ��д��ĸ
	[:alpha:]: ��Сд��ĸ
	[:digit:]: ����
	[:alnum:]: ���ֺʹ�Сд��ĸ
	
# man 7 glob
[^]: ƥ��ָ����Χ֮������ⵥ���ַ�

[[:alpha:]]*[[:space:]]*[^[:alpha:]]


��ϰ��
1������a123, cd6, c78m, c1 my, m.z, k 67, 8yu, 789���ļ���ע�⣬�����ļ����Զ��Ÿ����ģ��������Ŷ����ļ�������ɲ��֣�
2����ʾ������a��m��ͷ���ļ���
ls [am]*
3����ʾ�����ļ����а��������ֵ��ļ���
ls *[0-9]* 
ls *[[:digit:]]*
4����ʾ���������ֽ�β���ļ����в������հ׵��ļ���
ls *[^[:space:]]*[0-9]   ?????????
5����ʾ�ļ����а����˷���ĸ�����ֵ�������ŵ��ļ���
ls *[^[:alnum:]]*



Ȩ�ޣ�
r, w, x

�ļ���
r���ɶ�������ʹ������cat������鿴�ļ����ݣ�
w����д�����Ա༭��ɾ�����ļ���
x: ��ִ�У�eXacutable������������ʾ���µ��������ύ���ں����У�

Ŀ¼��
r: ���ԶԴ�Ŀ¼ִ��ls���г��ڲ��������ļ���
w: �����ڴ�Ŀ¼�����ļ���
x: ����ʹ��cd�л�����Ŀ¼��Ҳ����ʹ��ls -l�鿴�ڲ��ļ�����ϸ��Ϣ��

rwx:
	r--:ֻ��
	r-x:����ִ��
	---����Ȩ��
	
0 000 ---����Ȩ��
1 001 --x: ִ��
2 010 -w-: д
3 011 -wx: д��ִ��
4 100 r--: ֻ��
5 101 r-x: ����ִ��
6 110 rw-: ��д
7 111 rwx: ��дִ��

755��rwxr-xr-x
640��rw-r----- 

�û���UID, /etc/passwd ������û���Ӧ��ID�������ļ�
�飺GID, /etc/group ��������Ӧ����ID�������ļ�

Ӱ�ӿ��
�û���/etc/shadow
�飺/etc/gshadow

�û����
����Ա��0
��ͨ�û��� 1-65535 (RHEL7�Ժ����)
	ϵͳ�û���1-499   
	��ϵͳ�û�ֻ�����̨�����ں˱�Ҫ���̣�����Ҫ��½ϵͳ��һ��Ҫ���ƣ���
	��ÿ�����̶�Ӧ�����û�Ȩ�����У�ϵͳ����ʱ��Ϊ����Ȩ��̫�󣬽�������ϵͳ�û����ں��Խ������У��ڿͽٳֽ���ʱ��Ȩ�޲����ڹ���
	һ���û���500-60000

�û������
����Ա�飺
��ͨ�飺
	ϵͳ�飺
	һ���飺
	
�û������
	˽���飺�����û�ʱ�����û��Ϊ��ָ���������飬ϵͳ���Զ�Ϊ�䴴��һ�����û���ͬ������
	�����飺�û���Ĭ����
	�����飬�����飺Ĭ���������������
	
/etc/passwd
account: ��¼��
password: ���� ��x��������ռλ����������������/etc/shadow��
UID��
GID��������ID
comment: ע��
HOME DIR����Ŀ¼
SHELL���û���Ĭ��shell���û���½Ĭ�ϴ򿪵�shell��

/etc/shadow
account: ��¼��
encrypted password: ���ܵ�����



�û�����
	useradd, userdel, usermod, passwd, chsh, chfn, finger, id, chage

�����
	groupadd, groupdel, groupmod, gpasswd
	
Ȩ�޹���
	chown, chgrp, chmod, umask


/etc/passwd:
�û��������룺UID:GID��ע�ͣ���Ŀ¼ ��Ĭ��SHELL

/etc/group:
���������룺GID:�Դ���Ϊ�丽������û��б�

/etc/shadow��
�û��������룺���һ���޸������ʱ�䣺���ʹ�����ޣ��ʹ�����ޣ�����ʱ�䣺�ǻʱ�䣺����ʱ�䣺

�û�����
	useradd, userdel, usermod, passwd, chsh, chfn, finger, id, chage


useradd  [options]  USERNAME 
	-u UID
	-g GID�������飩
	-G GID,...  �������飩
	-c "COMMENT" ָ��ע����Ϣ
	-d /path/to/directory ָ����Ŀ¼��
	-s SHELL ָ��shell·��
	-m -k (Ϊ�û��Զ�������Ŀ¼������/etc/skel����û��Ļ��������ļ����Ƶ��û��ļ�Ŀ¼��
		1.������½��û�ʱ��û���Զ������û���Ŀ¼�����޷����õ��˿��Ŀ¼��
		2.���������Ĭ�ϵ�/etc/skelĿ¼��Ϊ���Ŀ¼������������useradd����ʱָ���µĿ��Ŀ¼�����磺sudo useradd -d /home/chen -m -k /etc/my_skel chen��������½��û�chen�������û���Ŀ¼Ϊ/home/chen�����Ҵ�Ŀ¼���Զ�������ͬʱָ�����Ŀ¼Ϊ/etc/my_skel��
		3.���������ÿ���½��û�ʱ��������ָ���µĿ��Ŀ¼������ͨ���޸�/etc/default/useradd�����ļ����ı�Ĭ�ϵĿ��Ŀ¼���������£�����SKEL�����Ķ��壬����˱����Ķ����ѱ�ע�͵�������ȡ��ע�ͣ�Ȼ���޸���ֵ��SKEL=/etc/my_skel
	-M���������û���Ŀ¼
	-r: ���ϵͳ�û�
	
/etc/login.defs
	
����������
	PATH
	HISTSIZE
	SHELL  
��ĿǰΪֹ���ֵ��־�����)
	
	
/etc/shells��ָ���˵�ǰϵͳ���õİ�ȫshell
	

userdel:
userdel [option] USERNAME ��Ĭ������²���ɾ���û��ļ�Ŀ¼��
	-r: ͬʱɾ���û��ļ�Ŀ¼

id���鿴�û����ʺ�������Ϣ
	-u��ֻ��ʾUID
	-g��ֻ��ʾGID
	-G���������GID
	-n����ʾ���ƶ�����ID��

finger: �鿴�û��ʺ���Ϣ
finger USERNAME

�޸��û��ʺ����ԣ�
usermod
	-u UID 
	-g GID
	-a -G GID����ʹ��-aѡ��Ḳ�Ǵ�ǰ�ĸ����飻
	-c��ע����Ϣ
	-d -m��Ϊ�û�ָ���µļ�Ŀ¼��������ǰ��Ŀ¼�е������ļ��ƶ����µļ�Ŀ¼
	-s����shell
	-l NEW_NAME�����Ը��û��ĵ�½��
	-L�������ʺ�
	-U�������ʺ�
	
chsh: �޸��û���Ĭ��shell

chfn���޸�ע����Ϣ

�������
passwd [USERNAME]
	--stdin
	-l�������˺�
	-u�������˺�
	-d: ɾ���û�����

pwck������û��ʺ������ԣ��������������⣩


�����
������:groupadd
groupadd 
	-g GID
	-r�����Ϊϵͳ��
	
groupmod
	-g GID
	-n GRPNAME

groupdel

gpasswd��Ϊ���趨����

newgrp GRPNAME ���л��û��Ļ����� <--> exit ��ֱ���л�ԭ������
	


��ϰ��
1������һ���û�mandriva����ID��Ϊ2002��������Ϊdistro����IDΪ3003����������Ϊlinux��
# groupadd -g 3003 distro
# groupadd linux
# useradd -u 2002 -g distro -G linux mandriva
2������һ���û�fedora����ȫ��ΪFedora Community��Ĭ��shellΪtcsh��
# useradd -c "Fedora Community" -s /bin/tcsh fedora
3���޸�mandriva��ID��Ϊ4004��������Ϊlinux��������Ϊdistro��fedora��
# usermod -u 4004 -g linux -G distro,fedora mandriva
4����fedora�����룬���趨���������ʹ������Ϊ2�죬�Ϊ50�죻
# passwd -n 2 -x 50 fedora

5����mandriva��Ĭ��shell��Ϊ/bin/bash; 
usermod -s /bin/bash mandirva
6�����ϵͳ�û�hbase���Ҳ��������¼ϵͳ��
# useradd -r -s /sbin/nologin hbase
7��

chage
	-d: ���һ�ε��޸�ʱ��
	-E: ����ʱ��
	-I���ǻʱ��
	-m: ���ʹ������
	-M: �ʹ������
	-W: ����ʱ��

chown: �ı��ļ�����(ֻ�й���Ա����ʹ�ô�����)
# chown USERNAME file,...
	-R: �޸�Ŀ¼�����ڲ��ļ�������
	--reference=/path/to/somefile file,... ���ļ���������Ϊ����·���ļ�һ��


���������÷���
ֱ����chown�������������ָ�ʽһ��ı���������
chown USERNAME:GRPNAME file,... 
chown USERNAME.GRPNAME file,...
	
# chgrp GRPNAME file,...ֱ�Ӱ�ĳ���ļ��Ļ����������
	-R
	--reference=/path/to/somefile file,...
	

chmod: �޸��ļ���Ȩ��
�޸������û���Ȩ�ޣ�
chmod MODE file,...
	-R
	--reference=/path/to/somefile file,...

rwxr-x---
#chmod 750 /tmp/abc

�޸�ĳ���û���ĳЩ���û�Ȩ�ޣ�
u,g,o,a
chmod �û����=MODE file,...
#chmod u=rwx /tmp/abc
#chmod g=rw /tmp/abc
#chmod o=rx /tmp/abc
��
#chmod u=rwx,g=rx,o= /tmp/abc

�޸�ĳ���û���ĳλ��ĳЩλȨ�ޣ�
u,g,o,a
chmod �û����+|-MODE file,...
#chmod u+x,g-x /tmp/abc
#chmod +x /tmp/abc �����û�ȫ��x


��ϰ��
1���½�һ��û�м�Ŀ¼���û�openstack��
# useradd -M openstack
2������/etc/skelΪ/home/openstack��
# cp -r /etc/skel /home/openstack
3���ı�/home/openstack�����ڲ��ļ������������Ϊopenstack��
# chown -R openstack:openstack /home/openstack
4��/home/openstack�����ڲ����ļ�������������û�û���κη���Ȩ��
# chmod -R go= /home/openstack


su - openstack

***�ֶ�����û�hive, ������Ϊhive (5000)��������Ϊmygroup
#nano /etc/passwd
 hive:x:5000:5000:HIVE:/home/hive:/bin/bash
#nano /etc/group
 hive:x:5000:
 �����ڸ�����Mygroup���һ��ð�ź������hive
#nano /etc/shadow
 hive:!!:169416:0:99999:7:::
#cp -r /etc/skel /home/hive

#openssl passwd -1 -salt '1234'
 redhat
 ��������$1$1234$ENeVaZLw04WKGqfo6an9S/ ճ���� /etc/shadow ���棬��������������



umask��������
666-umask �����ļ�ʱ���ô��㷨�õ�����Ȩ��
777-umask ����Ŀ¼ʱ���ô��㷨�õ�����Ȩ��
Ĭ�� ����Ա��    022
     һ���û���  002
# umask ��ʾ������
# umask 022 �Զ���������

***�ļ�Ĭ�ϲ��ܾ���ִ��Ȩ�ޣ������õĽ������ִ��Ȩ�ޣ�����Ȩ�޼�1��

umask: 023
�ļ���666-023=643 Ĭ�������643Ҳ���Զ�+1���644
Ŀ¼��777-023=754


վ���û���¼�ĽǶ���˵��SHELL�����ͣ�
��¼ʽshell:
	����ͨ��ĳ�ն˵�¼
	su - USERNAME 
	su -l USERNAME

�ǵ�¼ʽshell:
	su USERNAME
	ͼ���ն��´������
	�Զ�ִ�е�shell�ű�

	
bash�������ļ���
ȫ������
	/etc/profile, /etc/profile.d/*.sh, /etc/bashrc
��������
	~/.bash_profile, ~/.bashrc
	
profile����ļ���
	�趨��������
	���������ű�

bashrc����ļ���
	�趨���ر���
	�����������
	
��¼ʽshell��ζ�ȡ�����ļ���
/etc/profile --> /etc/profile.d/*.sh --> ~/.bash_profile --> ~/.bashrc --> /etc/bashrc

�ǵ�¼ʽshell��������ļ�?
~/.bashrc --> /etc/basrc --> /etc/profile.d/*.sh


�ܵ����ض���> < >> << 

���������������� CPU
�洢����RAM
�����豸/����豸

����ָ�������

��������ָ��
��������
�洢����

��ַ���ߣ��ڴ�Ѱַ
�������ߣ���������
�������ߣ�����ָ��

�Ĵ�����CPU��ʱ�洢��

I/O: Ӳ�̣�

����

INPUT�豸��

OUTPUT�豸


ϵͳ�趨
	Ĭ������豸����׼�����STDOUT, 1
	Ĭ�������豸����׼����, STDIN, 0
	��׼���������STDERR, 2
	
��׼���룺����
��׼����ʹ����������ʾ��

I/O�ض���

Linux:
>: �������
>>��׷�����
***�ܶ�����£�����ʧ��Ḳ����Ҫ�ļ�������ϵͳ�ڽ���������

set -C: ��ֹ���Ѿ������ļ�ʹ�ø����ض���
	ǿ�Ƹ����������ʹ�� >|
set +C: �ر���������

***��׼����������������ֲ�ͬ��������

2>: �ض���������
2>>: ׷�ӷ�ʽ

***��������ȷ���ߴ��󶼶���һ��Ŀ¼������������˼·
#ls /var > /tmp/var4.out 2> /tmp/var4.out
[root@lcfyl ~]# ls /var > /tmp/var4.out 2> /tmp/var4.out
[root@lcfyl ~]# cat /tmp/var4.out
account cache crash cvs db empty games lib local lock log mail nis opt preserve report run spool tmp yp
[root@lcfyl ~]# ls /varr > /tmp/var4.out 2> /tmp/var4.out
[root@lcfyl ~]# cat /tmp/var4.out
ls: �޷�����/varr: û���Ǹ��ļ���Ŀ¼


***�������ֻ���ض�����Ժϲ�������һ�ֱ��
&>: �ض����׼�������������ͬһ���ļ�
#ls /var &> /tmp/var4.out

<�������ض���
#tr 'a-z' 'A-Z' < /etc/fstab
***ʵ����tr�����ʽ�ǲ�֧�ֺ�����ļ��ģ����ǵȴ����̣�I/O�豸�����룬����ʱ��I/O�ض�������
   ����ȫ���ļ������������
<<��Here Document���ڴ˴������ĵ������벻����׷������˵����
[root@lcfyl ~]# cat << END
> The first line
> The second line
> END
The first line
The second line
[root@lcfyl ~]#

***������������ã������ڽű��������ĵ�
[root@lcfyl ~]# cat >> /tmp/myfile.txt <<EOF
> This is first line
> This is second line
> EOF
[root@lcfyl ~]# cat /tmp/myfile.txt
This is first line
This is second line
[root@lcfyl ~]#

�ܵ���ǰһ��������������Ϊ��һ�����������

����1 | ����2 | ����3 | ...
#echo "hello, world." | tr 'a-z' 'A-Z'��ǰһ����������������һ����������룩
#cut -d: -f3 /etc/passwd | sort -n��ǰһ����������������һ����������룩
#cut -d: -f1 /etc/passwd | sort |tr 'a-z' 'A-Z'������ʹ�ö��عܵ���

tee���÷���������һ���ط�����������ʾ����Ļ
[root@lcfyl ~]# echo "Hello, World" | tee /tmp/hello.out
Hello, World
[root@lcfyl ~]# cat /tmp/hello.out
Hello, World


��ϰ��
1��ͳ��/usr/bin/Ŀ¼�µ��ļ�������
# ls /usr/bin | wc -l
2��ȡ����ǰϵͳ�������û���shell��Ҫ��ÿ��shellֻ��ʾһ�Σ����Ұ�˳�������ʾ��
# cut -d: -f7 /etc/passwd | sort -u
3��˼���������ʾ/var/logĿ¼��ÿ���ļ����������ͣ�

4��ȡ��/etc/inittab�ļ��ĵ�6�У�
# head -6 /etc/inittab | tail -1
5��ȡ��/etc/passwd�ļ��е�����9���û����û�����shell����ʾ����Ļ�ϲ����䱣����/tmp/users�ļ��У�
# tail -9 /etc/passwd | head -1 | cut -d: -f1,7 | tee /tmp/users
6����ʾ/etcĿ¼��������pa��ͷ���ļ�����ͳ���������
# ls -d /etc/pa* | wc -l
7����ʹ���ı��༭������alias cls=clearһ�������������ǰ�û���.bashrc�ļ��У�
# echo "alias cls=clear" >> ~/.bashrc

	

	
grep, egrep, fgrep����֧��������ʽ��	

grep: ����ģʽ�����ı�����������ģʽ���ı�����ʾ������
Pattern: �ı��ַ���������ʽ��Ԫ�ַ���϶���ƥ������
#grep 'root' /etc/passwd�����û�б�������˫���Ŷ���һ���ģ�

grep [options] PATTERN [FILE...]
	-i�������Ǵ�Сд��--ignore-case)
	--color����ƥ����ַ���������ɫ��ʾ����
	-v: ��ʾû�б�ģʽƥ�䵽����
	-o��ֻ��ʾ��ģʽƥ�䵽���ַ���
	-E: ʹ����չ������ʽ
	-A #: ͬʱ��ʾƥ���кͺ���
	-B #: ͬʱ��ʾƥ���к�ǰ����
	-C #: ͬʱ��ʾƥ���к�ǰ����

������ʽ��REGular EXPression, REGEXP
Ԫ�ַ���
.: ƥ�����ⵥ���ַ�
[]: ƥ��ָ����Χ�ڵ����ⵥ���ַ�
[^]��ƥ��ָ����Χ������ⵥ���ַ�
	�ַ����ϣ�[:digit:], [:lower:], [:upper:], [:punct:], [:space:], [:alpha:], [:alnum:]

ƥ�������̰��ģʽ�������ܶ��ƥ�䣩����

*: ƥ����ǰ����ַ�����Σ��ر���Ҫע����ǣ�һ���ַ��в�һ��Ҫ�����ַ���ȫƥ�����ʾ���������в�������ͻ���ʾ�ô��ַ�������Ĳ��ֻ�����ɫ��ʾ��	
	a, b, ab, aab, acb, adb, amnb
	a*b��a��������κ���Ӹ�b���� a?b
	a.*b

	.*: ���ⳤ�ȵ������ַ�
\?: ƥ����ǰ����ַ�1�λ�0��
\{m,n\}:ƥ����ǰ����ַ�����m�Σ�����n�Σ�\Ϊת�ݷ������⻨���ű�shellֱ��ʶ��
	\{1,\}
	\{0,3\}
[root@lcfyl ~]# grep --color "a\{1,\}b" test
ab
aab


λ��ê����
^: ê�����ף����ַ�������������ݱ������������
#grep '^r..t' /etc/passwd
$: ê����β�����ַ�ǰ����������ݱ����������β
#grep 'b..h$' /etc/passwd
^$: �հ���

\<��\b: ê�����ף������������ַ�������Ϊ�����ײ�����
\>��\b: ê����β����ǰ��������ַ�������Ϊ���ʵ�β������
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


���飺
\(\)
	\(ab\)*��ab������������
	��������
	\1: ���õ�һ���������Լ���֮��Ӧ������������������������
	\2: ���õڶ���...........
	\3: ���õ�����...........
	
He love his lover.
She like her liker.
He like his lover.

l..e
\|������
C\|cat��C����cat

��ϰ��
1����ʾ/proc/meminfo�ļ����Բ����ִ�С��s��ͷ���У�
grep -i '^s' /proc/meminfo
grep '^[sS]' /proc/meminfo
2����ʾ/etc/passwd����nologin��β����; 
grep 'nologin$' /etc/passwd

ȡ��Ĭ��shellΪ/sbin/nologin���û��б�
grep "nologin$' /etc/passwd | cut -d: -f1

ȡ��Ĭ��shellΪbash�������û�ID����С���û����û���
grep 'bash$' /etc/passwd | sort -n -t: -k3 | head -1 | cut -d: -f1

3����ʾ/etc/inittab����#��ͷ���Һ����һ�������հ��ַ��������ָ�������ǿհ��ַ����У�
grep "^#[[:space:]]\{1,\}[^[:space:]]" /etc/inittab

4����ʾ/etc/inittab�а�����:һ������:(������ð���м�һ������)���У�
grep ':[0-9]:' /etc/inittab

5����ʾ/boot/grub/grub.conf�ļ�����һ�������հ��ַ���ͷ���У�
grep '^[[:space:]]\{1,\}' /boot/grub/grub.conf

6����ʾ/etc/inittab�ļ�����һ�����ֿ�ͷ����һ���뿪ͷ������ͬ�����ֽ�β���У�
grep '^\([0-9]\).*\1$' /etc/inittab

��ϰ��
1���ҳ�ĳ�ļ��еģ�1λ������2λ����
grep '[0-9]\{1,2\}' /proc/cpuinfo
grep --color '\<[0-9]\{1,2\}\>' /proc/cpuinfo

2���ҳ�ifconfig�������е�1-255֮���������

3�����ҵ�ǰϵͳ������Ϊstudent(�������������)���û����ʺŵ������Ϣ, �ļ�Ϊ/etc/passwd
grep '^student\>' /etc/passwd | cut -d: -f3
id -u student

student1
student2

��ϰ������/etc/inittab�ļ��������ı���ǰ���е�����(ÿһ���г��������ֱ�����ͬ)����д�����Ծ�ȷ�ҵ��������е�ģʽ��
l1:1:wait:/etc/rc.d/rc 1
l3:3:wait:/etc/rc.d/rc 3

grep '^l\([0-9]\):\1.*\1$' /etc/inittab


��չ������ʽ���ַ�����������������ַ�����һ����ֻ�ǲ���Ҫת���ַ��ˡ�

�ַ�ƥ�䣺���������һ��
	.
	[]
	[^]

����ƥ�䣺���������һ��������һ��+��
	*: 
	?:
	+: ƥ����ǰ����ַ�����1��
	{m,n}

λ��ê�������������һ��
	^
	$
	\<
	\>

���飺���������һ��
	()������
	\1, \2, \3, ...

���ߣ����������һ��
	|: or����˼
	C|cat:  C��cat
�����໥ת����grep -E = egrep 



4����ʾ���������ֽ�β���ļ����в������հ׵��ļ���
ls *[^[:space:]]*[0-9]   ?????????


�ҳ�/boot/grub/grub.conf�ļ���1-255֮������֣�
\<([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>

\.

ifconfig | egrep '\<([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>\.\<([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>\.\<([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>\.\<([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>' 

ifconfig | egrep --color '(\<([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>\.){3}\<([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])\>' 

IPv4: 
5�ࣺA B C D E
A��1-127
B��128-191
C��192-223

\<([1-9]|[1-9][0-9]|1[0-9]{2}|2[01][0-9]|22[0-3])\>(\.\<([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])\>){2}\.\<([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-4])\>


��̸��
	������ԣ��������ԡ�������ԡ��߼�����

��̬���ԣ�����������
	ǿ����(����)
	����ת���ɿ�ִ�и�ʽ
	C��C++��JAVA��C#
	
��̬���ԣ����������ԣ� on the fly
	������
	�߽��ͱ�ִ��
	PHP��SHELL��python��perl

	
������̣�Shell, C
�������: JAVA, Python, perl, C++

�������������ڴ�ռ�

�ڴ棺��ַ�Ĵ洢��Ԫ

�������ͣ�����ȷ�����ݵĴ洢��ʽ�ͳ���
	�ַ�
	��ֵ
		���ͣ���������
		������: 11.23�� 1.123*10^1, 0.1123*10^2
	����
		2017/10/31
	Boolean
		�桢��
	
	
�߼���1+1>2
�߼����㣺�롢�򡢷ǡ����
1: ��
0: ��

1 & 0  = 0
0 & 1 = 0
0 & 0 = 0
1 & 1 = 1

��

�ǣ�
! �� = ��
! �� = ��

shell: �����ͱ������
	ǿ��������ʹ��ǰ������������������������Ҫ��ʼ����
	����������ʱ�������������������ͣ�
������ֵ��VAR_NAME=VALUE

bash�������ͣ�
	��������
	���ر���(�ֲ�����)
	λ�ñ���
	�������
	
���ر�����
set VARNAME=VALUE: ������Ϊ����bash���̣�

�ֲ�������
local VARNAME=VALUE��������Ϊ��ǰ����Σ�

����������������Ϊ��ǰshell���̼����ӽ��̣�
export VARNAME=VALUE
VARNAME=VALUE
export VARNAME
	��������

λ�ñ�����
$1, $2, ...

���������
$?: ��һ�������ִ��״̬����ֵ��

����ִ�У����������෵��ֵ��
	����ִ�н��
	����״̬���ش��루0-255��
		0: ��ȷִ��
		1-255������ִ�У�1��2��127ϵͳԤ����
		

����������
unset VARNAME

�鿴��shell�б�����
set

�鿴��ǰshell�еĻ���������
printenv
env
export

�ű�������Ķ�������ʵ����Ҫ������������̿��ƻ���ʵ�ֵ�Դ����

shebang: ħ��
#!/bin/bash
# ע���У���ִ��

/dev/null: ����豸�� bit bucket�����ݺڶ�	

	
�ű���ִ��ʱ������һ����shell���̣�
	�������������Ľű���̳е�ǰshell����������
	ϵͳ�Զ�ִ�еĽű�(������������)����Ҫ���Ҷ�����Ҫ������������
	
��ϰ��дһ���ű��������������
1�����5���û�, user1,..., user5
2��ÿ���û�������ͬ�û���������Ҫ�����������ɺ���ʾpasswd�����ִ�н����Ϣ��
3��ÿ���û������ɺ󣬶�Ҫ��ʾ�û�ĳĳ�Ѿ��ɹ���ӣ�
useradd user1
echo "user1" | passwd --stdin user1 &> /dev/null
echo "Add user1 successfully."


�����жϣ�
	����û�������
		����û��������벢��ʾ��ӳɹ���
	����
		��ʾ����Ѿ����ڣ�û����ӣ�

bash�����ʵ�������жϣ�
�����������ͣ�
	��������
	�ַ�����
	�ļ�����

�������Եı��ʽ��
	[ expression ]
	[[ expression ]]
	test expression
	
�����Ƚ�:
	-eq: �������������Ƿ���ȣ����� $A -eq $B
	#A=3
	#B=6
	#[ $A -eq $B ]��ע���������ַ���һ���пո�
	#echo $?��һ������ִ���귵������ֵ����������⻹��һ��״ֵ̬����$?��
	1

	-ne: �������������Ƿ񲻵ȣ����ȣ�Ϊ�棻��ȣ�Ϊ�٣�

	-gt: ����һ�����Ƿ������һ���������ڣ�Ϊ�棻����Ϊ�٣�

	-lt: ����һ�����Ƿ�С����һ������С�ڣ�Ϊ�棻����Ϊ�٣�

	-ge: ���ڻ����

	-le��С�ڻ����
	
�������߼���ϵ��
	�߼��룺 &&
		��һ������Ϊ��ʱ���ڶ������������жϣ����ս���Ѿ��У�
		��һ������Ϊ��ʱ���ڶ�����������жϣ�
		#id student2 &> /dev/null && ehco "Hello, student2."
		�޷�Ӧ
		#useradd student2 
		#id student2 &> /dev/null && echo "Hello, student2."
		Hello, student2
	�߼��� ||
	
����û�user6�����ڣ�������û�user6
! id user6 && useradd user6
id user6 || useradd user6

���/etc/inittab�ļ�����������100������ʾ�ô���ļ���
[ `wc -l /etc/inittab | cut -d' ' -f1` -gt 100 ] && echo "Large file."

�������ƣ�
	1��ֻ�ܰ�����ĸ�����ֺ��»��ߣ����Ҳ������ֿ�ͷ��
	2����Ӧ�ø�ϵͳ�����еĻ�������������
	3�������������֪�壻

����û����ڣ�����ʾ�û��Ѵ��ڣ����򣬾���Ӵ��û���
id user1 && echo "user1 exists." || useradd user1

����û������ڣ�����ӣ�������ʾ���Ѿ����ڣ�
! id user1 && useradd user1 || echo "user1 exists."

����û������ڣ���Ӳ��Ҹ����룻������ʾ���Ѿ����ڣ�
#!/bin/bash
! id user1 && useradd user1 && echo "user1" | passwd --stdin user1	|| echo "user1 exists."
! id user2 && useradd user2 && echo "user2" | passwd --stdin user2	|| echo "user2 exists."
! id user3 && useradd user3 && echo "user3" | passwd --stdin user3	|| echo "user3 exists."
USERS=`wc -l /etc/passwd | cut -d: -f1`
echo "$USERS users."


��ϰ��дһ���ű����������Ҫ��
1�����3���û�user1, user2, user3����Ҫ���ж��û��Ƿ���ڣ������ڶ�������ӣ�
2�������ɺ���ʾһ������˼����û�����Ȼ�����ܰ�����Ϊ���ȴ��ڶ�û����ӵģ�
3�������ʾ��ǰϵͳ�Ϲ��ж��ٸ��û���

��ϰ��дһ���ű����������Ҫ��
����һ���û���
	1�������UIDΪ0������ʾ��Ϊ����Ա��
	2�����򣬾���ʾ��Ϊ��ͨ�û���
	#!/bin/bash
	NAME=user1
	USERID=`id -u $NAME`
	[ $USERID -eq 0 ] && echo "Admin" || echo "Common user"

��� UIDΪ0����ô
  ��ʾΪ����Ա
����
  ��ʾΪ��ͨ�û�
  
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
  
��ϰ��дһ���ű�
�жϵ�ǰϵͳ���Ƿ����û���Ĭ��shellΪbash��
   ����У�����ʾ�ж��ٸ������û������򣬾���ʾû�������û���
grep "bash$" /etc/passwd &> /dev/null
RETVAL=$?
if [ $RETVAL -eq 0 ]; then
   
if grep "bash$" /etc/passwd &> /dev/null; then
	
��ʾ�������á�һ�������ִ�н����Ҫʹ���������ã�����: RESAULTS=`wc -l /etc/passwd | cut -d: -f1`��
      ʹ��һ�������ִ��״̬�����Ҫֱ��ִ�д����һ���������ã�����: if id user1һ���е�id�����һ�����ܼ����ţ�
	  ������һ�������ִ�н����ֵ��ĳ������Ҫʹ���������ã�����USERID=`id -u user1`;
      ������һ�������ִ��״̬�����������������Ϊ����ִ�гɹ������ж�����������Ҫ��ִ�д��������������״̬�������
		id -u user1
		RETVAL=$?
		�˾���Բ�����дΪRETVAL=`id -u user1`��
	
	
��ϰ��дһ���ű�
�жϵ�ǰϵͳ���Ƿ����û���Ĭ��shellΪbash��
   ����У�����ʾ����һ�����û��������򣬾���ʾû�������û���

��ϰ��дһ���ű�
����һ���ļ�������/etc/inittab
�ж�����ļ����Ƿ��пհ��У�
����У�����ʾ��հ�������������ʾû�пհ��С�
#!/bin/bash
A=`grep '^$' /etc/inittab | wc -l`
if [ $A -gt 0 ]; then
 echo "$A"
else
 echo "meiyoukongbaihang"
fi
                 ���� by ��˧
				 
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

��ϰ��дһ���ű�
����һ���û����ж���UID��GID�Ƿ�һ��
���һ��������ʾ���û�Ϊ��good guy�������򣬾���ʾ���û�Ϊ��bad guy����
#!/bin/bash
USERNAME=user1
USERID=`id -u $USERNAME`
GROUPID=`id -g $USERNAME`
if [ $USERID -eq $GROUPID ]; then
  echo "Good guy."
else
  echo "Bad guy."
fi

��һ��Ҫ�󣺲�ʹ��id��������id�ţ�

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


��ϰ��дһ���ű�
����һ���û�����ȡ�����뾯�����ޣ�
�����ж��û�����ʹ�������Ƿ��Ѿ�С�ھ������ޣ�
	��ʾ�����㷽�����ʹ�����޼�ȥ�Ѿ�ʹ�õ�������Ϊʣ��ʹ�����ޣ�
	
���С�ڣ�����ʾ��Warning�������򣬾���ʾ��OK����

Բ��������С��������������

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

						���� by ������


��ϰ��дһ���ű�
�ж�������ʷ����ʷ���������Ŀ�Ƿ����1000��������ڣ�����ʾ��Some command will gone.����������ʾ��OK����


shell����ν����������㣨Ĭ�������Linux�������Ϊ�ַ�����Ҫ�����������·�������
A=3
B=6
1��let ����������ʽ
	let C=$A+$B
2��$[����������ʽ]
	C=$[$A+$B]
3��$((����������ʽ))
	C=$(($A+$B))
4��expr ����������ʽ�����ʽ�и��������������֮��Ҫ�пո񣬶���Ҫʹ����������
	C=`expr $A + $B`

�ڲ����� bc

[root@lcfyl ~]# echo "scale=2;111/22;" | bc
5.04
[root@lcfyl ~]# bc <<< "scale=2;111/22;"
5.04

�����жϣ����ƽṹ��

����֧if���
if �ж�����; then
  statement1
  statement2
  ...
fi

˫��֧��if��䣺
if �ж�����; then
	statement1
	statement2
	...
else
	statement3
	statement4
	...
fi

���֧��if��䣺
if �ж�����1; then
  statement1
  ...
elif �ж�����2; then
  statement2
  ...
elif �ж�����3; then
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


���Է�����
[ expression ]
[[ expression ]]
test expression

bash�г��õ��������������֣�
�������ԣ�
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
		
�ļ����ԣ�	
-e FILE�������ļ��Ƿ����
-f FILE: �����ļ��Ƿ�Ϊ��ͨ�ļ�
-d FILE: ����ָ��·���Ƿ�ΪĿ¼
-r FILE: ���Ե�ǰ�û���ָ���ļ��Ƿ��ж�ȡȨ�ޣ�
-w
-x	

[ -e /etc/inittab ]
[ -x /etc/rc.d/rc.sysinit ]

��ϰ��дһ���ű�
����һ���ļ���
�����һ����ͨ�ļ�������ʾ֮��
�����һ��Ŀ¼������ʾ֮��
���򣬴�Ϊ�޷�ʶ��֮�ļ���

����ű��˳�״̬��

exit: �˳��ű�
exit #
����ű�û����ȷ�����˳�״̬�룬��ô�����ִ�е�һ��������˳��뼴Ϊ�ű����˳�״̬�룻


bash -x �ű�������ִ��



bash���������ͣ�
	���ر���(�ֲ�����):��ǰshell����
	������������ǰshell���̼����ӽ���
	λ�ñ���: 
		$1, $2, ...
		shift [n]����ǿ���˳�ǰn����������n+1���������$1��û��nʱĬ��Ϊ1��
		#nano shift.sh
			#��/bin/bash
			echo $1
			shift
			echo $1
			shift
			echo $1
		#./shift.sh 1 2 3
		1
		2
		3
	���������
		$?
		$#�������ĸ���
		$*: �����б�
		$@�������б�
	
./filetest.sh /etc/fstab /etc/inittab
$1: /etc/fstab ���Ƕ�Ӧ�ĵ�һ������
$2: /etc/inittab ���Ƕ�Ӧ�ĵڶ�������

��ϰ��дһ�ű�
�ܽ���һ������(�ļ�·��)
�ж����˲��������һ�����ڵ��ļ�������ʾ��OK.�����������ʾ"No such file."
#!/bin/bash
if [ -e $1 ];then
    echo "ok"
 else
    echo "no such file"
 fi
 
./filetest.sh /etc/rc.d/rc.sysinit���˴����ܵ�·�����ǽű��е�$1��

��ϰ��дһ���ű�
���ű�������������(����)��
��ʾ������֮�ͣ�֮�˻���
#!/bin/bash
#
if [ $# -lt 2 ]; then
  echo "Usage: cacl.sh ARG1 ARG2"
  exit 8
fi

echo "The sum is: $[$1+$2]."
echo "The prod is: $[$1*$2]."

	
��ϰ��дһ���ű��������������
1��ʹ��һ����������һ���û�����
2��ɾ���˱����е��û�����һ��ɾ�����Ŀ¼��
3����ʾ���û�ɾ����ɡ������Ϣ��
	

bash: ���ñ�����${VARNAME}, ������ʱ��ʡ�ԡ�

grep, sed(���༭��), awk 	

sed�����÷���
sed: Stream EDitor
	�б༭�� (ȫ���༭��: vi)
	
sed: ģʽ�ռ䣨�ڴ�ռ䣩
Ĭ�ϲ��༭ԭ�ļ�������ģʽ�ռ��е��������������󣬴�������󣬽�ģʽ�ռ��ӡ����Ļ��


sed [options] 'AddressCommand' file ...
	-n: ��Ĭģʽ������Ĭ����ʾģʽ�ռ��е�����
	-i: ֱ���޸�ԭ�ļ�
	-e SCRIPT -e SCRIPT:����ͬʱִ�ж���ű�
	-f /PATH/TO/SED_SCRIPT
		sed -f /path/to/scripts  file
	-r: ��ʾʹ����չ������ʽ
	
Address��
1��StartLine,EndLine
	����1,100  �ӵ�һ�е�100��
	$�����һ��
2��/RegExp/
	/^root/  ������root��ͷ����
3��/pattern1/,/pattern2/
	��һ�α�pattern1ƥ�䵽���п�ʼ������һ�α�pattern2ƥ�䵽���н��������м��������
4��LineNumber
	ָ������
5��StartLine, +N
	��startLine��ʼ������N�У�
	һ��N+1��
	
Command��
	d: ɾ�������������У�
		# sed "1,2d" /etc/fstab
		# sed "1,+2d" /etc/fstab
		# sed "/oot/d" /etc/fstab
		# sed "/^\//d" /etc/fstab
	p: ��ʾ�����������У�
		# sed "/^\//p" /etc/fstab
		������ظ��������Σ�sedĬ����ʾ������һ�Σ�p������ʾһ�Σ�
		��������Ҫ�õ�ѡ��-n,����sed ����Ĭ����ʾ
		# sed -n "/^\//p" /etc/fstab 

	a \string: ��ָ�����к���׷�����У�����Ϊstring
		# sed "/^\//a \# hello world" /etc/fstab
		\n���������ڻ���
		# sed "/^\//a \# hello world\n# hello,Linux" /etc/fstab
	i \string: ��ָ������ǰ��������У�����Ϊstring
		
	r FILE: ��ָ�����ļ�����������������������д�
		# sed "2r /etc/issue" /etc/fstab
	w FILE: ����ַָ���ķ�Χ�ڵ��������ָ�����ļ���; 
		# sed "/oot/w /tmp/oot.txt" /etc/fstab
	s/pattern/string/���η�: ���Ҳ��滻��Ĭ��ֻ�滻ÿ���е�һ�α�ģʽƥ�䵽���ַ���
		# sed "s/oot/OOT/" /etc/fstab
		# sed "s/^\//#/" /etc/fstab
		�����η�
		g: ȫ���滻
		# sed "s/^\//#/g" /etc/fstab
		i: �����ַ���Сд
	s///: s###, s@@@ ��s����ķָ��������������֣�	
		\(\), \1, \2
		
	
		  
		 
	
	&: ����ģʽƥ����������&������������pattern��
		l..e: like-->liker
		      love-->lover
		      ���ֶ���
		# sed "s#l..e#&r#g" sed.txt
		# sed "s@\(l..e@\)\1r@g" sed.txt
		      �е�ʱ��ֻ���ú�������
		      like-->Like
		      love-->Love
		# sed "s/l\(..e\)/L\1/g" sed.txt
		

sed��ϰ��
1��ɾ��/etc/grub.conf�ļ������׵Ŀհ׷���
sed -r 's@^[[:spapce:]]+@@g' /etc/grub.conf
2���滻/etc/inittab�ļ���"id:3:initdefault:"һ���е�����Ϊ5��
sed 's@\(id:\)[0-9]\(:initdefault:\)@\15\2@g' /etc/inittab
3��ɾ��/etc/inittab�ļ��еĿհ��У�
sed '/^$/d' /etc/inittab
4��ɾ��/etc/inittab�ļ��п�ͷ��#��; 
sed 's@^#@@g' /etc/inittab
5��ɾ��ĳ�ļ��п�ͷ��#�ż�����Ŀհ��ַ�����Ҫ��#�ź�������пհ��ַ�;
sed -r 's@^#[[:space:]]+@@g' /etc/inittab
6��ɾ��ĳ�ļ����Կհ��ַ������#������еĿ�ͷ�Ŀհ��ַ���#
sed -r 's@^[[:space:]]+#@@g' /etc/inittab
7��ȡ��һ���ļ�·���ĸ�Ŀ¼����;
echo "/etc/rc.d/" | sed -r 's#^(/.*/)[^/]+/?#\1#g'	
������
echo "/etc/rc.d/" | sed -r 's@^/.*/([^/]+)/?@\1@g'	

��ϰ��
����һ���û����������ű����жϴ��û����û������������������Ƿ�һ�£����������ʾ������

�ַ����ԣ�
==�������Ƿ���ȣ����Ϊ�棬����Ϊ��
[root@lcfyl ~]# A=hello
[root@lcfyl ~]# B=hi
[root@lcfyl ~]# [ $A=$B ]
[root@lcfyl ~]# echo $?
0
[root@lcfyl ~]# [ $A = $B ]
[root@lcfyl ~]# echo $?
1
[root@lcfyl ~]#
***һ��Ҫע�⣬�Ⱥ�����һ��Ҫ�пո�==������=����


!=: �����Ƿ񲻵ȣ�����Ϊ�棬��Ϊ��
>
<
-z string: ����ָ���ַ����Ƿ�Ϊ�գ������棬�������
-n string: ����ָ���ַ����Ƿ񲻿գ�����Ϊ�棬����Ϊ��

��ϰ��дһ���ű�
����һ������(���ַ�����)���ű��������Ϊq�����˳��ű������򣬾���ʾ�û��Ĳ�����

��ϰ��дһ���ű�
����һ������(���ַ�����)���ű��������Ϊq��Q��quit��Quit�����˳��ű������򣬾���ʾ�û��Ĳ�����
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

��ϰ��
���������������ű�����һ��Ϊ�������ڶ���Ϊ�����������������Ϊ����������������ʾ������Ҫ������λ���ȡ����磺
./calc.sh 5 / 2

��ϰ��
����3���������ű���������Ϊ�û���������Щ�û����ʺ���Ϣ��ȡ�����������/tmp/testusers.txt�ļ��У���Ҫ��ÿһ���������кš�

#!/bin/bash
#
for I in `seq 1 $#`;do
        string="$I `grep "^$1" /etc/passwd`"
        echo "$string" >> /tmp/testusers.txt
shift
done

дһ���ű���
�жϵ�ǰ������CPU�����̣�����Ϣ��/proc/cpuinfo�ļ���vendor_idһ���С�
�����������ΪAuthenticAMD������ʾ��ΪAMD��˾��
�����������ΪGenuineIntel������ʾ��ΪIntel��˾��
���򣬾�˵��Ϊ��������˾��
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


дһ���ű���
���ű����������������ж����е����������С��������ʾ������
MAX=0
MAX -eq $1
MAX=$1
MAX -lt $2
MAX=$2


ѭ���������������˳�����
���֣�
	for ѭ��
	while ѭ��
	until ѭ��

for ���� in �б�; do
  ѭ����
done

for I in 1 2 3 4 5 6 7 8 9 10; do
  �ӷ�����
done

�������֮���˳���

��������б�
{1..100}
`seq [��ʼ�� [��������]] ������`
[root@lcfyl ~]# seq 1 2 10
1
3
5
7
9

declare -i SUM=0
	-i��integer
	-x������һ������Ϊ��������
#!/bin/bash
#
declare -i SUM=0
for I in {1..100}; do
  let SUM=$SUM+$I
done

echo "The sum is:$SUM."

***һ�������б��
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
	

дһ���ű���
1���趨����FILE��ֵΪ/etc/passwd
2��������/etc/passwd�е�ÿ���û��ʺã�����ʾ�Է���shell�����磺  
	Hello, root, your shell: /bin/bash
3��ͳ��һ���ж��ٸ��û�


ֻ��Ĭ��shellΪbash���û�������
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


****���ڲ��Է����е�[] [[]]������˵һ�£�
	[]�ǰ����ߵ����̶��ַ����Ƚϣ���[[]]�ǰ����ߵ���ƥ��ģʽ�Ƚ�
		[ $SHELL = "/bin/bash" ]ͬ[[ $SHELL = /bin/bas? ]]��һ����
		Ҳ����˵[[]]֧��ͨ���������ǿ�����Ծ�����[[]]���Ա���ܶ����

дһ���ű���
1�����10���û�user1��user10������ͬ�û�������Ҫ��ֻ���û������ڵ�����²�����ӣ�

��չ��
����һ��������
add: ����û�user1..user10
del: ɾ���û�user1..user10
�������˳�
adminusers user1,user2,user3,hello,hi



дһ���ű���
����100���������ܱ�3�������������ĺͣ�
ȡģ��ȡ��:%
3%2=1
100%55=45

дһ���ű���
����100�������������ĺ��Լ�����ż���ĺͣ��ֱ���ʾ֮��

дһ���ű����ֱ���ʾ��ǰϵͳ������Ĭ��shellΪbash���û���Ĭ��shellΪ/sbin/nologin���û�����ͳ�Ƹ���shell�µ��û���������ʾ������磺
BASH��3users��they are:
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

���ԣ�
��������
	-le
	-lt
	-ge
	-gt
	-eq
	-ne
�ַ�����
	==
	!=
	>
	<
	-n
	-z
�ļ�����
	-e
	-f
	-d
	-r
	-w
	-x
	
if [ $# -gt 1 ]; then

��ϲ�������
	-a: ���ϵ
	-o: ���ϵ
	!�� �ǹ�ϵ
	
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



vim�༭��(nano, sed)
	ASCII�롢�ִ�����
	vi: Visual Interface
	vim: VI iMproved

	ȫ���༭����ģʽ���༭��

vimģʽ��
�༭ģʽ(����ģʽ)
����ģʽ
ĩ��ģʽ

ģʽת����
�༭-->���룺
	i: �ڵ�ǰ��������ַ���ǰ�棬תΪ����ģʽ��
	I���ڵ�ǰ��������е����ף�ת��Ϊ����ģʽ

	a: �ڵ�ǰ��������ַ��ĺ��棬תΪ����ģʽ��
	A���ڵ�ǰ��������е���β��ת��Ϊ����ģʽ

	o: �ڵ�ǰ��������е��·����½�һ�У���תΪ����ģʽ��
	O���ڵ�ǰ��������е��Ϸ����½�һ�У���תΪ����ģʽ��

	
����-->�༭��
	ESC
	
�༭-->ĩ�У�
	��

ĩ��-->�༭��
	ESC, ESC

һ�����ļ�
# vim /path/to/somefile
	vim +#:���ļ�������λ�ڵ�#�� 
	vim +�����ļ�����λ�����һ��
	vim +/PATTERN : ���ļ�����λ����һ�α�PATTERNƥ�䵽���е�����

	Ĭ�ϴ��ڱ༭ģʽ
	
�����ر��ļ�
1��ĩ��ģʽ�ر��ļ�
:q  �˳�
:wq ���沢�˳�
:q! �����沢�˳�
:w ����
:w! ǿ�б���
:wq ����ͬ :x
2���༭ģʽ���˳�
ZZ: ���沢�˳�

�����ƶ����(�༭ģʽ)
1�����ַ��ƶ���
	h: ��
	l: ��
	j: ��
	k: ��
 #h: �ƶ�#���ַ���
	J����ǰ������һ�кϲ�
2���Ե���Ϊ��λ�ƶ�
	w: ������һ�����ʵĴ���
	e: ������ǰ����һ�����ʵĴ�β
	b: ������ǰ��ǰһ�����ʵĴ���
	
	#w: 
	
3��������ת��
	0: ��������
	^: ���׵ĵ�һ���ǿհ��ַ�
	$: ������β

4���м���ת
	#G����ת����#�У�
	G�����һ��
	gg:��һ��
	g~:����ǰ�д�Сдת��
	
	ĩ��ģʽ�£�ֱ�Ӹ����кż���
	
�ġ�����
Ctrl+f: ���·�һ��
Ctrl+b: ���Ϸ�һ��

Ctrl+d: ���·�����
Ctrl+u: ���Ϸ�����

�塢ɾ�������ַ�
x: ɾ��������ڴ��ĵ����ַ�
#x: ɾ��������ڴ������Ĺ�#���ַ�

����ɾ������: d
d�������ת�������ʹ�ã�
#dw, #de, #db

dd: ɾ����ǰ���������
#dd: ɾ��������ǰ������������ڵ�#�У�

ĩ��ģʽ�£�
StartADD,EndADDd
	.: ��ʾ��ǰ��
	$: ���һ��
	+#: ���µ�#��
	
�ߡ�ճ������ p
p: ���ɾ������Ϊ�������ݣ���ճ������������е��·���������ƻ�ɾ��������Ϊ�����У���ճ������������ַ��ĺ��棻
P: ���ɾ������Ϊ�������ݣ���ճ������������е��Ϸ���������ƻ�ɾ��������Ϊ�����У���ճ������������ַ���ǰ�棻

�ˡ��������� y
	�÷�ͬd����
	
�š��޸ģ���ɾ�����ݣ���ת��Ϊ����ģʽ
	c: �÷�ͬd����

ʮ���滻��r
R: �滻ģʽ

ʮһ�������༭���� u
u������ǰһ�εı༭����
	����u����ɳ�����ǰ��n�α༭����
#u: ֱ�ӳ������#�α༭����

�������һ�γ���������Ctrl+r

ʮ�����ظ�ǰһ�α༭����
.

ʮ�������ӻ�ģʽ
v: ���ַ�ѡȡ
V��������ѡȡ

ʮ�ġ�����
/PATTERN
?PATTERN
	n
	N

ʮ�塢���Ҳ��滻
��ĩ��ģʽ��ʹ��s����
ADDR1,ADDR2s@PATTERN@string@gi
1,$
%����ʾȫ��

��ϰ����/etc/yum.repos.d/server.repo�ļ��е�ftp://instructor.example.com/pub�滻Ϊhttp://172.16.0.1/yum

%s/ftp:\/\/instructor\.example\.com\/pub/http:\/\/172.16.0.1\/yum/g
%s@ftp://instructor\.example\.com/pub@http://172.16.0.1/yum@g

�ļ��������£�
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

ʮ����ʹ��vim�༭����ļ�
vim FILE1 FILE2 FILE3
:next �л�����һ���ļ�
:prev �л���ǰһ���ļ�
:last �л������һ���ļ�
:first �л�����һ���ļ�

�˳�
:qa ȫ���˳�

ʮ�ߡ�������ʾһ���ļ�
Ctrl+w, s: ˮƽ��ִ���
Ctrl+w, v: ��ֱ��ִ���

�ڴ��ڼ��л���꣺
Ctrl+w+w

:qa �ر����д���

ʮ�ˡ��ִ��ڱ༭����ļ�
vim -o : ˮƽ�ָ���ʾ
vim -O : ��ֱ�ָ���ʾ

ʮ�š�����ǰ�ļ��в����������Ϊ����һ���ļ�
ĩ��ģʽ��ʹ��w����
:w
:ADDR1,ADDR2w /path/to/somewhere

��ʮ��������һ���ļ�����������ڵ�ǰ�ļ���
:r /path/to/somefile

��ʮһ����shell����
:! COMMAND�������˳���ǰ�ļ���ֱ���൱����shell�������������Enter������

��ʮ�����߼�����
1����ʾ��ȡ����ʾ�к�
:set number
:set nu

:set nonu

2����ʾ���Ի������ַ���Сд
:set ignorecase
:set ic

:set noic

3���趨�Զ�����
:set autoindent
:set ai
:set noai

4�����ҵ����ı�������ʾ��ȡ��
:set hlsearch
:set nohlsearch

5���﷨����
:syntax on
:syntax off

��ʮ���������ļ�
/etc/vimrc
~/.vimrc

vim: 
****��һ����Ҫע����ǣ�����ʹvim�༭��ʱ������Ƿ��˳��������
     �༭���ļ�����Ŀ¼������һ�����ļ�ͬ����׺Ϊ.swp���ļ���ÿ����
     �༭����ļ���ʱ�򣬾ͻ�������ѣ�����.swp�ļ�������ʧ����ʱ����
     �ֶ�ɾ��
     �磺rm -f .inittab.swp

ldd [ѡ��] �ļ�
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
	-b ����2���Ƴ���
	-m �����ĵ�
	-s ����Դ��
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

�ļ����ң�
locate:
	��ʵʱ��ģ��ƥ�䣬�����Ǹ���ȫϵͳ�ļ����ݿ���еģ�
# updatedb, �ֶ������ļ����ݿ�(�հ�װ��ϵͳû�����ݿ⣬locate�ò��ˣ�����updatedb���ɣ�����Ҫ���ܳ�ʱ�䣩
�ٶȿ�
locate �ؼ���
	���ݿ�����: updatedb
	���ݿ�Ŀ¼: /var/lib/mlocate/mlocate.db
	
	-i �����ִ�Сд
	[root@localhost ~]# locate -i inittab
	/etc/inittab
	/usr/share/vim/vim74/syntax/inittab.vim
	[root@localhost ~]#
	
	-r ֧��������ʽ
	[root@localhost ~]# locate -r conf$ | grep nss
	/etc/nsswitch.conf
	/etc/prelink.conf.d/nss-softokn-prelink.conf
	/usr/lib/dracut/dracut.conf.d/50-nss-softokn.conf
	/var/lib/authconfig/last/nsswitch.conf
	[root@localhost ~]# 

updatedb��
1.updatedb -U <path> ��ָ����path�������ݿ�
2.updatedb -e <path> ��ָ����path����Ŀ¼���������ݿ�
3.updatedb -o file ָ�����ɵ����ݿ��ļ�

find��
	ʵʱ
	��ȷ
	֧���ڶ���ұ�׼
	����ָ��Ŀ¼�е������ļ���ɲ��ң��ٶ�����
�﷨��
find DIRICTORY Cretiria ACTION	
find ����·�� ���ұ�׼ ���ҵ��Ժ�Ĵ�������
����·����Ĭ��Ϊ��ǰĿ¼
���ұ�׼��Ĭ��Ϊָ��·���µ������ļ�
����������Ĭ��Ϊ��ʾ

ƥ���׼��
	-name 'FILENAME'�����ļ�������ȷƥ��
		[root@lcfyl ~]# find /etc/ -name 'passwd'
		/etc/pam.d/passwd
		/etc/passwd

		�ļ���ͨ�䣺
			*�����ⳤ�ȵ������ַ�
			?
			[]
	-iname 'FILENAME': �ļ���ƥ��ʱ�����ִ�Сд
	-regex PATTERN������������ʽ�����ļ���ƥ�䣨����ط�����ֵ���Ҫȫ·��ƥ�䣬����ֻ��ȡĳ���ļ���
		[root@mail ~]# find /etc/ -regex ".*ifcfg.*"
		/etc/sysconfig/network-scripts/ifcfg-eth0
		/etc/sysconfig/network-scripts/ifcfg-lo
		[root@mail ~]# 
		������Ǵ���ģ�ʲô���Ҳ���
		[root@mail ~]# find /etc/ -regex "ifcfg.*"
	-user USERNAME: ������������
		[root@lcfyl ~]# find /home -user mandriva
		/home/mandriva
		/home/mandriva/.bash_logout
		/home/mandriva/.gnome2
		/home/mandriva/.bash_profile
		/home/mandriva/.bashrc

	-group GROUPNAME: �����������
	
	-uid [+/-]UID: ����UID����
		[root@localhost ~]# find /etc/ -uid -500 | wc -l
		1067
		[root@localhost ~]# 

	-gid [+/-]GID: ����GID����
		***�е�ʱ���û�ɾ�ˣ����������鶪ʧ�����ID��

	-used [+/-]n��ʲôʱ���ù����ļ�
		[root@localhost ~]# find /etc/ -used -1 | wc -l
		481
		[root@localhost ~]#
	-fstype <�ļ�ϵͳ����> ��ָ�����ļ�ϵͳ�����ϲ����ļ�
	-link <n> ����n��Ӳ���������ļ�
	-inum i�ڵ�ID ����ָ����i�ڵ��

	-nouser������û���������ļ�
	-nogroup: ����û��������ļ�
	-empty�����ҿ��ļ�
	-newer <�ļ���> ���ұ��ļ����µ��ļ�
		1. ���ұ�test.txt�ļ�����ʱ���µ��ļ�
		[root@localhost ~]# find ~ -newer a.txt 
		/root
		/root/.num.sh.swp
		/root/anaconda-ks.cfg
		/root/.lesshst
		/root/initial_repo_backup
		/root/.bash_history
		/root/.viminfo
		[root@localhost ~]# 
		2. ���ұ�test.txt�ļ�����ʱ���µ��ļ�
		[root@localhost ~]# find /etc/ -anewer /etc/terminfo | wc -l
		1030
		[root@localhost ~]#
	-cnewer��File's status was last changed more recently than file  was  modified

	-type 
		f: ��ͨ�ļ�
		d��Ŀ¼
		c���ַ��ļ�
		b��block
		l: link
		p: pipe
		s: socks
	
	-size [+|-]��+/-�Ǳ�ʾ����С�ڵ���˼
		
		#b ��(512�ֽ�)
		#c �ֽ�
		#k KB
		#M MB
			[root@localhost ~]# find /etc/ -size -1M -ls | head -4
			360657    0 -rw-------   1 root     root            0 Mar  6  2015 /etc/security/opasswd
			360483    0 -rw-r--r--   1 root     root            0 Oct 29  2014 /etc/environment
			360872    0 -rw-r--r--   1 root     root            0 Jun 10  2014 /etc/sysconfig/run-parts
			360493    0 -rw-r--r--   1 root     root            0 Jun  7  2013 /etc/motd
			[root@localhost ~]#
		#G GB
		
���������
	-a
		#find /tmp -nouser -a -type d
	-o
		#find /tmp -nouser -o -type d
	-not 
		#find /tmp -not -type d
		
	
/tmpĿ¼������Ŀ¼�����һ������׽������͵��ļ�
#find /tmp -not -user user1 -a -not -user user2
#find /tmp -not \( -user user1 -o -user user2 \) ****�������Ħ�����ɣ����ǵ�ת����

/tmp/testĿ¼�£���������user1��Ҳ����user2���ļ���

����ʱ��������ң�
	-mtime��Ĭ�ϵ�λ���죩
	-ctime
	-atime
		[+|-]#
		#find /tmp -atime +5 ������5��û�з��ʹ��ˣ����û��+��-�����������Ǹ�ʱ��㣩
	-mmin��Ĭ�ϵ�λ�Ƿ֣�
	-cmin
	-amin
		[+|-]#
		
	-perm MODE����ȷƥ�䣨�����ļ�Ȩ�ޣ�
		/MODE: ����һλƥ�伴��������
		-MODE: �ļ�Ȩ������ȫ������MODEʱ�ŷ�������
		
		-644
		644: rw-r--r--
		755: rwxr-xr-x
		750: rwxr-x---
	find ./ -perm -001


������
	-print: ��ʾ��Ĭ�ϣ�
	-ls������ls -l����ʽ��ʾÿһ���ļ�����ϸ
	-ok COMMAND {} \; ÿһ�β�������Ҫ�û�ȷ��
		#find ./-perm -006 -ok chmod o-w {} \;
	-exec COMMAND {} \; ����Ҫȷ��
		#find ./-type d -exec chmod +x {} \;
		#find ./ -perm -020 -exec mv {} {}.new \;��ֻҪ����������ļ������־�Ҫ��{}���棩
		#find ./-name "*.sh" -a -perm -111 -exec chmod o-x {} \;
	xargs���������
		#find /etc/ -size +1M -exec echo {} >> /tmp/etc.largefiles \;
		#find /etc/ -size +1M | xargs echo >> /tmp/etc.largefiles

1������/varĿ¼������Ϊroot��������Ϊmail�������ļ���
find /var -user root -a -group mail

2������/usrĿ¼�²�����root,bin,��student���ļ���
find /usr -not -user root -a -not -user bin -a -not -user student
find /usr -not \( -user root -o -user bin -o -user student \)

3������/etcĿ¼�����һ���������޸Ĺ��Ҳ�����root��student�û����ļ���
find /etc -mtime -7 -not \ ( -user root -o -user student \)
find /etc -mtime -7 -not -user root -a -not -user student


4�����ҵ�ǰϵͳ��û�����������������1�����������ʹ����ļ�������������������޸�Ϊroot��
find / \( -nouser -o -nogroup \) -a -atime -1 -exec chown root:root {} \; 

5������/etcĿ¼�´���1M���ļ����������ļ���д��/tmp/etc.largefiles�ļ��У�
find /etc -size +1M >> /tmp/etc.largefiles

6������/etcĿ¼�������û���û��дȨ�޵��ļ�����ʾ������ϸ��Ϣ��
find /etc -not -perm /222 -ls

7. ���ұ�a.txt�ļ�����ʱ���µ���b.txtʱ��ɵ��ļ�
find ~ -newer a.txt ! -newer b.txt

8. ����3��ǰʹ�ù����ļ���Ŀ¼
find ~ -used +3

9. �ڷ�ext4�ϲ����ļ���test.txt�ļ�
find ~ -name test.txt ! -fstype ext4

10. ����Ӳ����������2��С��5���ļ�
find ~ -links +2 -links -5

11. ����i�ڵ��Ϊ12345���ļ�
find ~ -inum 12345

����
�ļ��� Access time��atime ���ڶ�ȡ�ļ�����ִ���ļ�ʱ���ĵġ�
�ļ��� Modified time��mtime ����д���ļ�ʱ���ļ����ݵĸ��Ķ����ĵġ�
�ļ��� Create time��ctime ����д���ļ������������ߡ�Ȩ�޻���������ʱ�� Inode �����ݸ��Ķ����ĵġ�
ʾ��:
1. ����.conf�ļ���ȷ���ı�����
#find /etc -name ��*.conf�� | xargs file
2. iso-url.txt���д�������,��ͨ��xargs��һ����
#cat iso-url.txt | xargs wget -c
ע:wgetΪ���������ع���,-cΪ�ϵ�����	




����Ȩ��
passwd:s

SUID: ����ĳ����ʱ����Ӧ���̵������ǳ����ļ�����������������������ߣ�
	chmod u+s FILE
	chmod u-s FILE
	***���FILE����ԭ������ִ��Ȩ�ޣ���SUID��ʾΪs��������ʾS��
	[root@lcfyl ~]# ls -l /bin/cat
	-rwxr-xr-x. 1 root root 48008  6�� 14 2010 /bin/cat
	[root@lcfyl ~]# ls -l /etc/shadow
	----------. 1 root root 1260  3�� 10 16:52 /etc/shadow
	[root@lcfyl ~]# su mandriva
	[mandriva@lcfyl root]$ cat /etc/shadow
	cat: /etc/shadow: Ȩ�޲���
	[mandriva@lcfyl root]$ su
	���룺
	[root@lcfyl ~]# chmod u+s /bin/cat
	[root@lcfyl ~]# ls -l /bin/cat
	-rwsr-xr-x. 1 root root 48008  6�� 14 2010 /bin/cat
	[root@lcfyl ~]# su mandriva
	[mandriva@lcfyl root]$ cat /etc/shadow
	root:$6$XL7K9QOmIRLHlTzO$OVs2QPjZhgAcPMwHWuaUSvvqfOr5j0u9Bjxbvx4MXAFEOuDOxqXRrCHB63b0TC0Xc42gEbkL.8W32yMPvIyVO1:16822:0:99999:7:::
	bin:*:14790:0:99999:7:::
	daemon:*:14790:0:99999:7:::
	adm:*:14790:0:99999:7:::
	lp:*:14790:0:99999:7:::


SGID: ����ĳ����ʱ����Ӧ���̵������ǳ����ļ���������飬�����������������Ļ����飻
	chmod g+s FILE
	chmod g-s FILE
		�����Ա��hadoop, hbase, hive
		����Ŀ¼��/tmp/project/
		���ܣ������ڹ���Ŀ¼���ļ������໥֮������޸�ɾ��
		ʵ�֣�������Ա������develop��������Ŀ¼��ĳ�develop��дȨ�ޣ���ʱ���������洴��ɾ�������ļ��������໥
		      �޸�ɾ������ʱ����g+s�Ϳ�����
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
		*����Ȼ�����޸ı����ļ�����
		[hbase@mail project]$ ll
		total 0
		-rw-rw-r-- 1 hadoop hadoop 0 Jun 15 01:08 a.hadoop
		-rw-rw-r-- 1 hbase  hbase  0 Jun 15 01:11 a.hbase
		[root@mail project]# chmod g+s /tmp/project/
		[root@mail project]# ll -d
		drwxrwsr-x 2 root develop 4096 Jun 15 01:43 .
		[hadoop@mail project]$ touch b.hadoop
		[hbase@mail project]$ touch b.hbase
		*��ʱSGID��Ч�������޸ı��˵��ļ�
		[hbase@mail project]$ ll
		total 0
		-rw-rw-r-- 1 hadoop hadoop  0 Jun 15 01:08 a.hadoop
		-rw-rw-r-- 1 hbase  hbase   0 Jun 15 01:11 a.hbase
		-rw-rw-r-- 1 hadoop develop 0 Jun 15 01:56 b.hadoop
		-rw-rw-r-- 1 hbase  develop 0 Jun 15 01:56 b.hbase

*****���ڹ���Ŀ¼�Ĺ�������д��Ȩ�ޣ����Դ�Ŀ¼�µ��ļ������໥ɾ����Ϊ�˱���ɾ������Ŀ¼����Sticky
Sticky: ��һ������Ŀ¼��ÿ�������Դ����ļ���ɾ���Լ����ļ���������ɾ�����˵��ļ���
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


***SUID,SGID,Sticky������ϳ�һ������Ȩ����ϼӵ��ļ���Ȩ�����з�����λ
�ļ�����Ȩ��
	SUID: s
	SGID: s
	Sticky: t 

	chmod u+s
	      g+s
	      o+t
		  
chmod 5755 /backup/test
umask 0022 ���ǰ���һ��0��������Ȩ�޵����


��ϰ��дһ���ű�
дһ���ű�����ʾ��ǰϵͳ��shellΪ-sָ�����͵��û�����ͳ�����û�������-sѡ�������Ĳ���������/etc/shells�ļ��д��ڵ�shell���ͣ�
����ִ�д˽ű������⣬�˽ű������Խ���--helpѡ�����ʾ������Ϣ���ű�ִ�����磺
./showshells.sh -s bash
��ʾ������磺
BASH��3users��they are:
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

�ļ�ϵͳ�����б�
FACL��Filesystem Access Control List
�����ļ���չ�������ķ��ʿ���Ȩ��

jerry: rw-

setfacl���趨
	-m: �趨
		u:UID:perm
		g:GID:perm
			[mandriva@lcfyl facl]$ echo "456" >>inittab
			-bash: inittab: Ȩ�޲���
			[root@lcfyl ~]# setfacl -m u:mandriva:rw /tmp/facl/inittab 
			[root@lcfyl ~]# getfacl /tmp/facl/inittab 
			getfacl: Removing leading '/' from absolute path names
			# file: tmp/facl/inittab
			# owner: root
			# group: root
			user::rw-
			user:mandriva:rw-
			group::r--
			mask::rw-��***���mask����˼��ָ����Ȩ��һ�����ܳ������maskȨ�ޣ�����ص���
			other::r--
			[mandriva@lcfyl facl]$ echo "456" >> inittab
			[mandriva@lcfyl facl]$ tail -5 inittab
			#   6 - reboot (Do NOT set initdefault to this)
			# 
			id:3:initdefault:
			456

	-x��ȡ��
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
    -rw-r--r--+ 1 root root 892  3�� 12 18:56 /tmp/facl/inittab
***���Կ������Ȩ��λ����һ��+�ţ���������չȨ��setfacl��ͨ�����ƻ�鵵��������ʾ�������õ��������
getfacl:��ȡ��ʾ���ʿ���Ȩ���б�

EXAMPLES
       Granting an additional user read access
              setfacl -m u:lisa:r file

       Revoking  write  access  from  all  groups and all named
       users (using the effective rights mask)
              setfacl -m m::rx file

       Removing a named group entry from a file��s ACL
              setfacl -x g:staff file

       Copying the ACL of one file to another
              getfacl file1 | setfacl --set-file=- file2

       Copying the access ACL into the Default ACL
              getfacl --access dir | setfacl -d -M- dir

***�ں˶�ȡȨ�޵�˳��
һ�㣺owner-group-other
���⣺owner-(facl,user)-group-(facl,group)-other

�������
w��˭��½�ˣ����ڸ�ʲô����who����ϸ
[root@lcfyl ~]# w
 19:38:22 up  4:10,  4 users,  load average: 0.00, 0.00, 0.00
USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
root     tty1     -                19:29    8:30   0.04s  0.04s -bash
root     pts/0    192.168.3.28     15:28    0.00s  0.22s  0.07s w
mandriva pts/1    192.168.3.28     15:53   19:30   0.08s  0.08s -bash
hadoop   pts/2    192.168.3.28     15:53    3:31m  0.05s  0.05s -bash

who��˭��½��
[root@lcfyl ~]# who
root     pts/0        2016-03-12 15:28 (192.168.3.28)
mandriva pts/1        2016-03-12 15:53 (192.168.3.28)
hadoop   pts/2        2016-03-12 15:53 (192.168.3.28)
***����ϵͳ�ϵ��ն�
�ն����ͣ�
	console: ����̨
	pty: �����ն� (VGA)
	tty#: �����ն� (VGA)
	ttyS#: �����ն�
	pts/#: α�ն�
���м�������ѡ�
[root@lcfyl ~]# who -r
         ���м��� 3 2016-03-12 15:27
[root@lcfyl ~]# who -H
����   ��·       ʱ��           ��ע
root     tty1         2016-03-12 19:29
root     pts/0        2016-03-12 15:28 (192.168.3.28)
mandriva pts/1        2016-03-12 15:53 (192.168.3.28)
hadoop   pts/2        2016-03-12 15:53 (192.168.3.28)

last����ʾ/var/log/wtmp�ļ�����ʾ�û���¼��ʷ��ϵͳ������ʷ
	-n #: ��ʾ���#�ε������Ϣ
[root@lcfyl ~]# last -n 5
root     tty1                          Sat Mar 12 19:29   still logged in   
hadoop   pts/2        192.168.3.28     Sat Mar 12 15:53   still logged in   
mandriva pts/1        192.168.3.28     Sat Mar 12 15:53   still logged in   
hadoop   pts/2        192.168.3.28     Sat Mar 12 15:29 - 15:52  (00:23)    
mandriva pts/1        192.168.3.28     Sat Mar 12 15:29 - 15:52  (00:23)    
wtmp begins Sat Jan 23 00:17:21 2016



lastb��/var/log/btmp�ļ�����ʾ�û�����ĵ�¼����
	-n #: ��ʾ���#�ε������Ϣ
lastlog: ��ʾÿһ���û����һ�εĳɹ���¼��Ϣ��
	-u USERNAME: ��ʾ�ض��û�����ĵ�¼��Ϣ

basename��ȡһ���ļ��Ļ���
	$0: ִ�нű�ʱ�Ľű�·��ȫ�ƣ�����ű��������ű����ø�·����
	
mail��Ĭ��ϵͳװһ���ʼ������Զ����ϵͳ��Դ��������쳣�ͷ����û�

[root@lcfyl ~]# mail -s "How are you?" root < /etc/fstab

���ߣ�

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


hostname: ��ʾ������
�����ǰ����������������www.magedu.com���ͽ����Ϊwww.magedu.com

�����ǰ��������������localhost���ͽ����Ϊwww.magedu.com

�����ǰ������������Ϊ�գ�����Ϊ(none)������Ϊlocalhost���ͽ����Ϊwww.magedu.com
[ -z `hostname` ] || [ `hostname` == '(none)' -o `hostname` == 'localhost' ] && hostname www.magedu.com
[ root@lcfyl ~]# [ `hostname` = "" -o `hostname`="(none)" -o `hostname`="localhost" ] && hostname "www.lcfyl.com"
[ root@lcfyl ~]# hostname
www.lcfyl.com


���������
RANDOM: 0-32768

��������������س�
/dev/random:
/dev/urandom:

дһ���ű�������RANDOM����10������������ҳ����е����ֵ������Сֵ��
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

�������
	���ƽṹ
		˳��ṹ
		ѡ��ṹ
		ѭ���ṹ

ѡ��ṹ��
if: ����֧��˫��֧�����֧
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


case��䣺ѡ��ṹ

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

ֻ���ܲ���start,stop,restart,status����֮һ
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

��ϰ��дһ���ű�showlogged.sh�����÷���ʽΪ��
showlogged.sh -v -c -h|--help
���У�-hѡ��ֻ�ܵ���ʹ�ã�������ʾ������Ϣ��-cѡ��ʱ����ʾ��ǰϵͳ�ϵ�¼�������û��������ͬʱʹ����-vѡ������ʾͬʱ��¼���û���������ʾ��¼���û��������Ϣ����
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

	
shell: ����
ln [-s -v] SRC DEST
ln [ѡ��] Դ�ļ� �����ļ�
	-f ɾ���Ѵ��ڵ�Ŀ���ļ�
	-i ����������ظ����ֵ���ʾ��β���
	-v ��ʾ������Ϣ
	-s ������ѡ��
Ӳ����
[root@lcfyl backup]# cp /etc/rc.d/rc.sysinit ./abc
[root@lcfyl backup]# mkdir test
[root@lcfyl backup]# ln abc test/abc2
[root@lcfyl backup]# ls -i
784280 abc  784282 test
[root@lcfyl backup]# ls -li test/abc2 
784280 -rwxr-xr-x. 2 root root 19088  3�� 14 15:37 test/abc2


������
[root@lcfyl ~]# mkdir backup
[root@lcfyl ~]# cd backup/
[root@lcfyl backup]# cp /etc/rc.d/rc.sysinit abc1
[root@lcfyl backup]# mkdir test
[root@lcfyl backup]# ln -sv /root/backup/abc1 test/abc2
"test/abc2" -> "/root/backup/abc1"
[root@lcfyl backup]# ls -li test/
������ 0
784282 lrwxrwxrwx. 1 root root 12  3�� 15 12:20 abc2 -> /root/backup/abc1
[root@lcfyl backup]# rm -rf abc1 
[root@lcfyl backup]# cat test/abc2 
cat: test/abc2: û���Ǹ��ļ���Ŀ¼
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
������ 0
784282 lrwxrwxrwx. 1 root root 12  3�� 15 12:20 abc2 -> /root/backup/abc1

*** Ҳ����˵������ָ��ֻ��·�������㻻һ���ļ���inode�ű��ˣ�����·��û�䣬��Ȼ��Ч


Ӳ���ӣ�
	1��ֻ�ܶ��ļ�����������Ӧ����Ŀ¼��
	2�����ܿ��ļ�ϵͳ��
	3������Ӳ���ӻ������ļ������ӵĴ�����
	
�������ӣ�
	1����Ӧ����Ŀ¼��
	2�����Կ��ļ�ϵͳ��
	3���������ӱ������ļ������Ӵ�����
	4�����СΪָ����·�����������ַ�������

du ����ʾĿ¼��ÿ���ļ��Ĵ�С
	-s 
	-h
[root@lcfyl ~]# du -sh /etc/issue
4.0K	/etc/issue

	
df: ��ʾ�ļ�ϵͳ�������
	
����

�豸�ļ���
	b: ����Ϊ��λ��������ʵ��豸��
	c�����ַ�Ϊ��λ�������豸��
	
	b: Ӳ��
	c: ����
	
/dev
	���豸�� ��major number��
		��ʶ�豸����
	���豸�� ��minor number��
		��ʶͬһ�������в�ͬ�豸
�����豸�ļ�
mknod
mknod [OPTION]... NAME TYPE [MAJOR MINOR]
	-m MODE
	
Ӳ���豸���豸�ļ�����
IDE, ATA��hd
SATA��sd
SCSI: sd
USB: sd
	a,b,c,...������ͬһ�������µĲ�ͬ�豸
	
IDE: 
	��һ��IDE�ڣ�������
		/dev/hda, /dev/hdb
	�ڶ���IDE�ڣ�������
		/dev/hdc, /dev/hdd

sda, sdb, sdc, ...

hda: 
	hda1: ��һ��������
	hda2: 
	hda3:
	hda4:
	hda5: ��һ���߼�������ֻ�ܴ�5��ʼ���߼�������
	
�鿴��ǰϵͳʶ���˼���Ӳ�̣�
fdisk -l [/dev/to/some_device_file]

������̷�����
fdisk /dev/sda
	p: ��ʾ��ǰӲ���ķ���������û����ĸĶ�
	n: �����·���
		e: ��չ����
		p: ������
	d: ɾ��һ������
	w: �����˳�
	q: �������˳�
	t: �޸ķ�������
		L: 
	l: ��ʾ��֧�ֵ���������
	
partprobe��֪ͨ�ں��ض��������½���������������Ч��
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




��ϰ��дһ���ű�
ͨ�������д���һ���ļ�·���������ű���
	����������˻����ˣ�����
	�������ָ����·����Ӧ����Ŀ¼�������ļ�������
���󣬼��·��ָ�����ļ��Ƿ�Ϊ�ջ򲻴��ڣ�����ǣ����½����ļ��������ļ���������������
#!/bin/bash
# 
����ʹ��vim�༭���򿪴��ļ������ù�괦������ļ������һ�У�



д���ű��������·�ʽִ�У�
mkscript.sh -v|--version VERSION -a|--author AUTHOR -t|--time DATETIME -d|--description DESCRIPTION -f|--file /PATH/TO/FILE -h|--help 

1���˽ű��ܴ������-fѡ��ָ����ļ�/PATH/TO/FILE�������Ϊ���ļ������Զ�Ϊ�����ɵ�һ�У�����ļ����գ��ҵ�һ�в���#!/bin/bash������ֹ�˽ű���������The file is not a bash script."��������ֱ��ʹ��vim �򿪴��ļ���
��ʾ��/PATH/TO/FILE��Ҫ�ж���Ŀ¼�Ƿ���ڣ���������ڣ��򱨴�

2�����Ϊ���ļ����Զ����ɵĵ�һ������Ϊ��
#!/bin/bash
3�����Ϊ���ļ�����ʹ����-aѡ������ļ�����ӡ�# Author: -aѡ��Ĳ����������磺
# Author: Jerry
4�����Ϊ���ļ�����ʹ����-tѡ������ļ�����ӡ�# Date: �ű�ִ��-tѡ���ָ����ʱ�䡱�����磺
# Date: 2013-03-08 18:05
5�����Ϊ���ļ�����ʹ����-dѡ������ļ�����ӡ�# Description: -dѡ������ݡ������磺
# Description: Create a bash script file head.
6�����Ϊ���ļ�����ʹ����-vѡ������ļ���ӡ�# Version: -v����Ĳ�����������:
# Version: 0.1
6��-hѡ��ֻ�ܵ���ʹ�ã�������ʾʹ�ð�����
7������ѡ���ʾ������Ϣ��

˵����
����һ�����ڴ����ű��Ľű����������Զ���������һ��bash�ű����ļ�ͷ���������Ժ�ʹ�ô˽ű������������ű�����ñȽϸ�Ч�����磺
#!/bin/bash
# Author: Jerry(jerry@magedu.com)
# Date: 2013-03-08 18:05
# Description: Create a bash script file head.
# Version: 0.1
#


***�ű���������
*ϵͳ������������getopts, $OPTIND, $OPTARG
***getopts�÷���
�������$OPTARG�洢��Ӧѡ��Ĳ�������$OPTIND���Ǵ洢ԭʼ$*����һ��Ҫ�����Ԫ��λ�á�
while getopts ":a:bc" opt  #�ַ������ð�ű�ʾ��ѡ��������Լ��Ĳ��������û�в����ᱨ��������ǰ����һ�������Ǿͻ���Դ���
����ʵ��(getopts.sh)��
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
shift $(($OPTIND - 1))#ͨ��shift $(($OPTIND - 1))�Ĵ���$*�о�ֻ�����˳�ȥѡ�����ݵĲ�����������������������shell��̴����ˡ�
echo $0
echo $*
ִ�����./getopts.sh -a 11 -b -c
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
