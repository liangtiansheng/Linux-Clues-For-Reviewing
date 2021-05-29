# Linux 基础命令

在 ARM64 架构下，几乎所有的 Linux 基础命令跟 x86 都是一样的。值得强调的是，在刚接触 ARM64 架构的操作系统时，很多用户把 x86 上编译好的应用程序直接拿到 ARM64 架构下运行，这是行不通的，因为 x86 的指令集跟 ARM64 指令集是不一样的。如果想在 ARM64 架构的操作系统上运行应用程序，需要通过 ARM64 架构的 CPU 指令集进行编译。

## Linux 文件类基础命令

Linux 的主流发行版操作系统像RHEL，Centos，Ubuntu等，现在都同时发布 ARM64 架构。所以在 Linux 的基础应用层面，跟 x86 的习惯是一样的。Linux 的哲学思想是一切皆文件，所以掌握 Linux 的文件操作是至关重要的一步。

### 关于路径和通配符

Linux中分绝对路径和相对路径，绝对路径一定是从 / 开始写的，相对路径是以当前位置为基准向下级查找，还可能使用路径符号。

路径展开符号：

```bash
.  ：(一个点)表示当前目录
.. ：(两个点)表示上一层目录
-  ：(一个短横线)表示上一次使用的目录，例如从/tmp直接切换到/etc下，"-"就表示/tmp
~  ：(波浪符号)表示用户的家目录，例如"~account"表示account用户的家目录
/dir/和/dir：一般都表示dir目录和dir目录中的文件。但在有些地方会严格区分是否加尾
              随斜线，此时对于加了尾随斜线的表示此目录中的文件，不加尾随斜线的表示
              该目录本身和此目录中的文件
```

#### cd 命令

切换目录

#### pwd 命令

查看当前目录

```bash
[root@arm64v8 tmp]# pwd
/tmp
[root@arm64v8 tmp]# cd /etc/
[root@arm64v8 etc]# pwd
/etc
[root@arm64v8 etc]#
```

#### basename 命令

获取文件名

#### dirname 命令

获取文件所在目录

```bash
[root@arm64v8 ~]# basename /etc/sysconfig/network-scripts/ifcfg-eth0 
ifcfg-eth0
[root@arm64v8 ~]# dirname /etc/sysconfig/network-scripts/ifcfg-eth0
/etc/sysconfig/network-scripts
[root@arm64v8 ~]#
```

*注意：这两个命令其实不太完善，它不会检查文件或目录是否存在，只要写出来了就会去获取。*

#### bash shell 通配符

\* 代表任意字符(0到多个)
? 代表一个字符
[] 中间为字符组合，仅匹配其中任一 一个字符

```bash
# 列出 /etc 下所有以 a 开头的文件和以 a 开头的目录及其下面的文件
[root@arm64v8 ~]# ls /etc/a*
/etc/adjtime  /etc/aliases  /etc/aliases.db  /etc/anacrontab  /etc/asound.conf

/etc/alternatives:
ld             mta             mta-mailq     mta-newaliases     mta-pam    mta-sendmail
libnssckbi.so  mta-aliasesman  mta-mailqman  mta-newaliasesman  mta-rmail  mta-sendmailman

/etc/audisp:
audispd.conf  plugins.d

/etc/audit:
auditd.conf  audit.rules  audit-stop.rules  rules.d
[root@arm64v8 ~]#
```

### 查看目录内容

ls 命令列出目录中的内容，和 dir 命令完全等价。tree 命令按树状结构递归列出目录和子目录中的内容，而 ls 使用 -R 选项时才会递归列出。

#### ls 命令

```bash
# 以下是使用 ls -l 显示文件长格式的属性
[root@arm64v8 ~]# ls -l /var/log/dmesg
-rw-r--r-- 1 root root 34087 Apr 23 13:08 /var/log/dmesg
[root@arm64v8 ~]#
```

ls -l 所列 7 项属性含义如下图

![ls -l](./images/ls -l.png)

```bash
# ls 常用选项
-l：(long)长格式显示，即显示属性等信息(包括mtime)
-c：列出ctime
-u：列出atime
-d：(direcorty)查看目录本身属性信息，不查看目录里面的东西。不加-d会查看里面文件的信息
-a：会显示所有文件，包括两个相对路径的文件"."和".."以及以点开头的隐藏文件
-A：会列出绝大多数文件，即忽略两个相对路径的文件"."和".."
-h：(human)人类可读的格式，将字节换成k,将K换成M，将M换成G
-i：(inode)权限属性的前面加上一堆数字
-p：对目录加上/标识符以作区分
-F：对不同类型的文件加上不同标识符以作区分，对目录加的文件也是/
-t：按修改时间排序内容。不加任何改变顺序的选项时，ls默认按照字母顺序排序
-r：反转排序
-R：递归显示
-S：按文件大小排序，默认降序排序
--color：显示颜色
-m：使用逗号分隔各文件，当然，只适用于未使用长格式(ls -l)的情况
-1：(数值一)，以换行符分隔文件，当然，和-m或-l(小写字母)是冲突的
-I pattern：忽略被pattern匹配到的文件
```

*注意：ls 以 -h 显示文件大小时，一般显示的都是不带 B 的单位，如K/M/G，它们的转换比例是 1024，如果显示的都是带了 B 的，如 KB/MB/GB，则它们的转换比例为 1000 而非 1024，一般很少显示带 B 的大小。*

#### tree 命令

有可能 tree 命令不存在，需要安装 tree 包才有(Centos：yum -y install tree)。

```bash
# 匹配选项
-L：用于指定递归显示的深度，指定的深度必须是大于0的整数。
-P：用于显示通配符匹配模式的目录和文件，但是不管是否匹配，目录一定显示。
-I：用于显示除被通配符匹配外的所有目录和文件。
# 显示选项
-a：用于显示隐藏文件，默认不显示。
-d：指定只显示目录。
-f：指定显示全路径。
-i：不缩进显示。和-f一起使用很有用。
-p：用于显示权限位信息。
-h：用于显示大小。
-u：显示username或UID(当没有username时只能显示UID了)。
-g：显示groupname或GID。
-D：显示文件的最后一次Mtime。
--inodes：显示inode号。
--device：显示文件或目录所属的设备号。
-C：显示颜色。
# 输出选项
-o filename：指定将tree的结果输出到filename文件中。
```

```bash
[root@arm64v8 ~]# tree -C -h /tmp/
/tmp/
├── [  34]  aarch64
│   ├── [  19]  aarch64
│   │   └── [ 10M]  test1
│   └── [  19]  arm64
│       └── [ 10M]  test1
└── [  34]  arm64
    ├── [  19]  aarch64
    │   └── [ 10M]  test1
    └── [  19]  arm64
        └── [ 10M]  test1

6 directories, 4 files
[root@arm64v8 ~]#
```

### 文件的时间戳

文件的时间属性有三种：atime/ctime/mtime。

1. atime：是 access time，即上一次的访问时间。
2. mtime：是 modify time，是文件的修改时间。
3. ctime：是 change time，也是文件的修改时间，只不过这个修改时间计算的inode修改时间，也就是元数据修改时间。

mtime 只有修改文件内容才会改变，更准确的说是修改了它的 data block 部分；

ctime 是修改文件属性时改变的，确切的说是修改了它的元数据部分，例如重命名文件，修改文件所有者，移动文件(移动文件没有改变 datablock，只是改变了其inode指针，或文件名)等；

当然，修改文件内容也一定会改变 ctime (修改文件内容至少已经修改了 inode 记录上的 mtime，这也是元数据)，也就是说 mtime 的改变一定会引起 ctime 的改变。

#### 关于 relatime

atime/ctime/mtime 是 Posix 标准要求操作系统维护的时间戳信息。但是每次将 atime、ctime 和 mtime 写入到硬盘中(这些不会写入缓存，只要修改就是写入磁盘，即使从缓存读取文件内容也如此)效率很低。有多低？下面标注写 ctime 消耗的时间，几乎总要花费零点几秒。

```bash
[root@arm64v8 ~]# touch test
[root@arm64v8 ~]# stat test 
  File: ‘test’
  Size: 0         	Blocks: 0          IO Block: 65536  regular empty file
Device: fd04h/64772d	Inode: 537275277   Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2021-05-18 15:27:42.000000000 +0800
Modify: 2021-05-18 15:27:42.000000000 +0800
Change: 2021-05-18 15:27:42.000000000 +0800
 Birth: -
[root@arm64v8 ~]# echo "arm64v8" > test 
[root@arm64v8 ~]# stat test 
  File: ‘test’
  Size: 8         	Blocks: 8          IO Block: 65536  regular file
Device: fd04h/64772d	Inode: 537275277   Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2021-05-18 15:27:42.000000000 +0800
Modify: 2021-05-18 15:28:06.840000000 +0800 # 写 mtime 消耗0.84s
Change: 2021-05-18 15:28:06.840000000 +0800 # 写 ctime 消耗0.84s
 Birth: -
[root@arm64v8 ~]# 
```

mtime 要被修改，必然是修改了文件内容，这时候将 mtime 写入到硬盘中是应该的。但是 atime 和 ctime 呢？很多情况下根本用不到 atime 和 ctime，在频繁访问文件的时候，都要修改 atime 和 ctime，这样效率会降低很多很多，所以 mount 有个 noatime 选项来避免这种负面影响。

CentOS6 引入了一个新的 atime 维护机制 relatime：除非两次修改atime的时间超过 1 天(默认设置 86400 秒)，或者修改了 mtime，否则访问文件的 inode 不会引起 atime 的改变。换句话说，当 cat 一个文件的时候，它的  atime 可能会改变，但是你稍后再 cat，它不会再改变。

由于 cat 文件的时候 atime 可能不会改变，所以可能也就不会引起 ctime 的改变。

### 文件/目录的创建和删除

#### mkdir 命令

```bash
mkdir [-mpv] 目录名

-m：表示创建目录时直接设置权限
-p：表示递归创建多层目录，即上层目录不存在时也会直接将其创建出来(parent)
-v: 表示输出创建的详细过程
```

```bash
# 在tmp目录中创建一个test1目录
[root@arm64v8 ~]# mkdir /tmp/test1

# 直接创建test2时就赋予权限744
[root@arm64v8 ~]# mkdir /tmp/test2 -m 744

# 创建test5，此时会将不存在的test3和test4目录也创建好，并输出创建过程
[root@arm64v8 ~]# mkdir /tmp/test3/test4/test5 -pv
mkdir: created directory ‘/tmp/test3’
mkdir: created directory ‘/tmp/test3/test4’
mkdir: created directory ‘/tmp/test3/test4/test5’
[root@arm64v8 ~]# 
```

#### touch 命令

```bash
touch [-camtd] 文件名

-c：强制不创建文件
-a：修改文件access time(atime)
-m：修改文件modification time(mtime)
-t：使用"[[CC]YY]MMDDhhmm[.ss]"格式的时间替代当前时间
-d：使用字符串描述的时间格式替代当前时间
```

```bash
# 在tmp目录下创建 test1.txt 文件
[root@arm64v8 ~]# touch /tmp/test1.txt

# 在tmp目录下创建 1.txt 2.txt 到 10.txt 文件
[root@arm64v8 ~]# touch /tmp/{1..10}.txt
[root@arm64v8 ~]# ls /tmp/
10.txt  1.txt  2.txt  3.txt  4.txt  5.txt  6.txt  7.txt  8.txt  9.txt  test1.txt
[root@arm64v8 ~]#
```

多个 {} 还可以交换扩展，类似 (a+b)(c+d)=ac+ad+bc+bd

```bash
[root@arm64v8 ~]# touch {a,b}_{c,d}
[root@arm64v8 ~]# ls
a_c  a_d  b_c  b_d
[root@arm64v8 ~]# 
```

touch 主要是修改文件的时间戳信息，当 touch 的文件不存在时就自动创建该文件。可以使用 touch –c 来取消创建动作。

touch 可以更改最近一次访问时间(atime)，最近一次修改时间(mtime)，文件属性修改时间(ctime)，这些时间可以通过命令 stat file 来查看。其中 ctime 是文件属性上的更改，即元数据的更改，比如修改权限。

touch -a 修改 atime，-m 修改 mtime，没有修改 ctime 的选项。因为使用 touch 改变 atime 或 mtime，同时也都会改变 ctime，虽说 atime 并不总是会影响 ctime(如cat文件时)。

#### rm 命令

```bash
rm [-rfi] 文件名

-r：表示递归删除，删除目录时需要加此参数
-i：询问是否删除(yes/no)
-f：强制删除，不进行询问
```

```bash
# 递归删除tmp下的所有目录和文件，不包括删除tmp目录
[root@arm64v8 ~]# rm -rf /tmp/*

# 递归删除tmp下的所有目录和文件，包括删除tmp目录
[root@arm64v8 ~]# rm -rf /tmp/
```

*注意：rm -rf / 这个命令是江湖上有名的自杀命令，会删除操作系统及一切数据*

### 查看文件类型

#### file 命令

这是一个简单查看文件类型的命令，查看文件是属于二进制文件还是数据文件还是ASCII文件。

```bash
# 显示可执行二进制文件
[root@arm64v8 ~]# file /bin/ls
/bin/ls: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 3.7.0, BuildID[sha1]=1d7c447166e0b6dfaa87dd7d9998794e84b8de58, stripped

# 显示ASCII文件
[root@arm64v8 ~]# file /etc/passwd
/etc/passwd: ASCII text

# 显示数据文件
[root@arm64v8 ~]# file /etc/aliases.db 
/etc/aliases.db: Berkeley DB (Hash, version 9, native byte-order)
[root@arm64v8 ~]#
```

file还有一个"-s"选项，可以查看设备的文件系统类型。

```bash
[root@arm64v8 ~]# file -s /dev/vda1
/dev/vda1: x86 boot sector, mkdosfs boot message display, code offset 0x3c, OEM-ID "mkfs.fat", sectors/cluster 8, root entries 512, Media descriptor 0xf8, sectors/FAT 200, heads 16, sectors 409600 (volumes > 32 MB) , reserved 0x1, serial number 0xe32081f3, label: "           ", FAT (16 bit)
[root@arm64v8 ~]# 
[root@arm64v8 ~]# file -s /dev/vda2
/dev/vda2: SGI XFS filesystem data (blksz 4096, inosz 512, v2 dirs)
[root@arm64v8 ~]# 
```

### 文件/目录复制和移动

#### cp 命令

```bash
cp [-apdriulfs] src dest # 复制单文件或单目录
cp [-apdriuslf] src1 src2 src3......dest_dir # 复制多文件、目录到一个目录下

# 选项说明
-p： 文件的属性(权限、属组、时间戳)也复制过去。如果不指定p选项，谁执行复制动作，文件所有者和组就是谁。
-r或-R：递归复制，常用于复制非空目录。
-d：复制的源文件如果是链接文件，则复制链接文件而不是指向的文件本身。即保持链接属性，复制快捷方式本身。如果不指定-d，则复制的是链接所指向的文件。
-a：a=pdr三个选项。归档拷贝，常用于备份。
-i：复制时如果目标文件已经存在，询问是否替换。
-u：(update)若目标文件和源文件同名，但属性不一样(如修改时间，大小等)，则覆盖目标文件。
-f：强制复制，如果目标存在，不会进行-i选项的询问和-u选项的考虑，直接覆盖。
-l：在目标位置建立硬链接，而不是复制文件本身。
-s：在目标位置建立软链接，而不是复制文件本身(软链接或符号链接相当于windows的快捷方式)。
```

```bash
# 查看当前目录下的文件结构
[root@arm64v8 ~]# tree .
.
├── a
│   ├── a
│   │   └── test
│   └── b
│       └── test
├── b
│   ├── a
│   │   └── test
│   └── b
│       └── test
└── test

6 directories, 5 files
# 将当前目录下的所有文件，在保留原文件属性保持软连接情况下，拷贝至tmp下
[root@arm64v8 ~]# cp -a a b test /tmp/
# 验证结果
[root@arm64v8 ~]# tree /tmp/
/tmp/
├── a
│   ├── a
│   │   └── test
│   └── b
│       └── test
├── b
│   ├── a
│   │   └── test
│   └── b
│       └── test
└── test

6 directories, 5 files
[root@arm64v8 ~]# 
```

#### scp 命令

scp 是基于 ssh 的安全拷贝命令(security copy)，它是从古老的远程复制命令 rcp 改变而来，实现的是在 host 与host 之间的拷贝，可以是本地到远程的、本地到本地的，甚至可以远程到远程复制。注意，scp 可能会询问密码。

如果 scp 拷贝的源文件在目标位置上已经存在时(文件同名)，scp 会替换已存在目标文件中的内容，但保持其inode 号。

如果 scp 拷贝的源文件在目标位置上不存在，则会在目标位置上创建一个空文件，然后将源文件中的内容填充进去。

之所以解释上面的两句，是为了理解 scp 的机制，scp 拷贝本质只是填充内容的过程，它不会去修改目标文件的很多属性，对于从远程复制到另一远程时，其机制见后文。

```bash
scp [-12BCpqrv] [-l limit] [-o ssh_option] [-P port] [[user@]host1:]file1 ... [[user@]host2:]file2

# 选项说明
-1：使用ssh v1版本，这是默认使用协议版本
-2：使用ssh v2版本
-C：拷贝时先压缩，节省带宽
-l limit：限制拷贝速度，Kbit/s.
-o ssh_option：指定ssh连接时的特殊选项，一般用不上。偶尔在连接过程中等待提示输入密码较慢时，可以设置GSSAPIAuthentication为no
-P port：指定目标主机上ssh端口，大写的字母P，默认是22端口
-p：拷贝时保持源文件的mtime,atime,owner,group,privileges
-r：递归拷贝，用于拷贝目录。注意，scp拷贝遇到链接文件时，会拷贝链接的源文件内容填充到目标文件中(scp的本质就是填充而非拷贝)
-v：输出详细信息，可以用来调试或查看scp的详细过程，分析scp的机制
```

```bash
# 把本地文件/home/a.tar.tz拷贝到远程服务器192.168.0.2上的/home/tmp，连接时使用远程的root用户
[root@arm64v8 ~]# scp /home/a.tar.tz root@192.168.0.2:/home/tmp/

# 目标主机不写路径时，表示拷贝到对方的家目录下
[root@arm64v8 ~]# scp /home/a.tar.tz root@192.168.0.2

# 把远程文件/home/a.tar.gz拷贝到本机
[root@arm64v8 ~]# scp root@192.168.0.2:/home/a.tar.tz  # 不接本地目录表示拷贝到当前目录
[root@arm64v8 ~]# scp root@192.168.0.2:/home/a.tar.tz /tmp # 拷贝到本地/tmp目录下

# 从远程主机192.168.100.60拷贝目录及文件到另一台远程主机192.168.100.62上
[root@arm64v8 ~]# scp -r root@192.168.100.60:/tmp/ root@192.168.100.62:/tmp
```

#### mv 命令

mv 命令移动文件和目录，还可以用于重命名文件或目录。

```bash
mv [-iuf] src dest # 移动单个文件或目录
mv [-iuf] src1 src2 src3 dest_dir # 移动多个文件或目录

# 选项说明
--backup[=CONTROL]：如果目标文件已存在，则对该文件做一个备份，默认备份文件是在文件名后加上波浪线，如/b.txt~
-b：类似于--backup，但不接受参数, 默认备份文件是在文件名后加上波浪线，如/b.txt~
-f：如果目标文件已存在，则强制覆盖文件
-i：如果目标文件已存在，则提示是否要覆盖，这是alias mv的默认选项
-n：如果目标文件已存在，则不覆盖已存在的文件，如果同时指定了-f/-i/-n，则后指定的生效
-u：(update)如果源文件和目标文件不同，则移动，否则不移动
```

```bash
# 将当前目录下的test移动到tmp目录下
[root@arm64v8 ~]# mv test /tmp/

# 将当前目录下的test移动到tmp目录下，并命名为test1
[root@arm64v8 ~]# mv test /tmp/test1
```

*注意：mv默认已经是递归移动,不需要-r参数。*

### 查看文件内容

#### cat 命令

输出一个或多个文件的内容。

```bash
cat [OPTION]... [FILE]...

# 选项说明
-n：显示所有行的行号
-b：显示非空行的行号
-E：在每行行尾加上$符号
-T：将TAB符号输出为"^I"
-s：压缩连续空行为单个空行
```

cat还有一个重要功能，允许将分行键入的内容输入到一个文件中去。

```bash
# 将键入的内容追加到标准输入stdin中(不是从标准输入中读取)，EOF必须两个作为起始和结束，EOF可以随便使用其他符号代替，注意是 "<<" 符号
[root@arm64v8 ~]# cat << EOF
> hello there
> EOF
hello there
[root@arm64v8 ~]# 

# 如果是 "<" 符号呢
[root@arm64v8 ~]# cat < EOF
-bash: EOF: No such file or directory
[root@arm64v8 ~]#

# 根据报错说明 "<" 符号应该接文件，把文件内容当作输入，比如下面就是正确的
[root@arm64v8 ~]# cat < /tmp/test1 
aarch64
[root@arm64v8 ~]#
```

再进一步测试<<EOF的功能，将键入的内容重定向到文件而非标准输入中。

```bash
# 第一种，>>filename<<EOF 或 >filename<<EOF，">>"是追加，">"是覆盖
[root@arm64v8 ~]# cat >> test << EOF
> I am arm64v8
> EOF
[root@arm64v8 ~]# cat test
I am arm64v8
[root@arm64v8 ~]# cat > test << EOF
> I am aarch64
> EOF
[root@arm64v8 ~]# cat test 
I am aarch64
[root@arm64v8 ~]# 

# 第二种，<<eof>filename或<<eof>>filename
[root@arm64v8 ~]# cat <<EOF>>test1
> I am kylinv10
> EOF
[root@arm64v8 ~]# cat test1
I am kylinv10
[root@arm64v8 ~]# cat <<EOF>test1
> I am UOS
> EOF
[root@arm64v8 ~]# cat test1
I am UOS
[root@arm64v8 ~]#
```

#### tac 命令

tac 和 cat 字母正好是相反的，其作用也是和 cat 相反的，它会反向输出行，将最后一行放在第一行的位置输出，依此类推。但是，tac 没有显示行号的参数。

```bash
[root@arm64v8 ~]# echo -e '1\n2\n3\n4\n5' | tac
5
4
3
2
1
[root@arm64v8 ~]#
```

#### head 命令

head打印前面的几行

```bash
head [-n num] | [-num] [-v] filename

# 选项说明
-n：显示前num行；如果num是负数，则显示除了最后|num|(绝对值)行的其余所有行，即显示前"总行数 - |num|"
-v：会显示出文件名
```

通过对比一目了然

```bash
# 不指定 -n 默认取前 10 行，但是 test 文件只有 6 行
[root@arm64v8 ~]# head test -v
==> test <==
1
2
3
4
5
6

# 取前 5 行
[root@arm64v8 ~]# head -n 5 test -v
==> test <==
1
2
3
4
5

# 取除去倒数 5 行的其它所有行
[root@arm64v8 ~]# head -n -5 test -v
==> test <==
1

# 取前 5 行
[root@arm64v8 ~]# head -5 test -v
==> test <==
1
2
3
4
5
[root@arm64v8 ~]#
```

#### tail 命令

tail 和 head 相反，是显示后面的行，默认是后10行。

```bash
tail [OPTION]... [FILE]...

选项说明：
-n：输出最后num行，如果使用-n +num则表示输出从第num行开始的所有行
-f：监控文件变化
--pid=PID：和-f一起使用，在给定PID的进程死亡后，终止文件监控
-v：显示文件名
```

```bash
# 不指定 -n 默认取后 10 行，但是 test 文件只有 6 行
[root@arm64v8 ~]# tail test 
1
2
3
4
5
6

# 取后 5 行
[root@arm64v8 ~]# tail -n 5 test 
2
3
4
5
6

# 取后 5 行
[root@arm64v8 ~]# tail -n -5 test 
2
3
4
5
6

# 取后 5 行
[root@arm64v8 ~]# tail -5 test 
2
3
4
5
6
[root@arm64v8 ~]#
```

tail 还有一个重要的参数 -f，监控文件的内容变化。当一个用户不断修改某个文件的尾部，另一个用户就可以通过这个命令来刷新并显示这些修改后的内容。

#### nl 命令

以行号的方式查看内容。常用 "-b a"，表示不论是否空行都显示行号，等价于 cat -n；不写选项时，默认 "-b t"，表示空行不显示行号，等价于 cat -b。

```bash
# 默认空行不显示行号
[root@arm64v8 ~]# nl test 
     1	a
     2	b
       
     3	c
# 不论是否空行都显示行号
[root@arm64v8 ~]# nl -b a test 
     1	a
     2	b
     3	
     4	c
[root@arm64v8 ~]#
```

#### more or less 命令

按页显示文件内容。使用 more 时，使用 / 搜索字符串，按下 n 或 N 键表示向下或向上继续搜索。使用 less 时，还多了一个搜索功能，使用 ? 搜索字符串，同样，使用 n 或 N 键可以向上或向下继续搜索。

### 编辑文件内容

#### vim 命令

vim 是一个功能强大的编辑器，一般操作系统自带的编辑器是 vi，而 vim 是 vi 的加强版，需要手动安装。

打开文件

```bash
# 打开文件，并定位在第首行首个字符
[root@arm64v8 ~]# vim /path/to/somefile

# 打开文件，并定位于第 # 行 
[root@arm64v8 ~]# vim +# /path/to/somefile

# 打开文件，定位至最后一行
[root@arm64v8 ~]# vim + /path/to/somefile

# 打开文件，定位至第一次被PATTERN匹配到的行的行首
[root@arm64v8 ~]# vim +/PATTERN /path/to/somefile
```

*注意：打开文件，默认处于编辑模式*

模式转换

```bash
# 编辑-->输入
i: 在当前光标所在字符的前面，转为输入模式；
I：在当前光标所在行的行首，转换为输入模式
a: 在当前光标所在字符的后面，转为输入模式；
A：在当前光标所在行的行尾，转换为输入模式
o: 在当前光标所在行的下方，新建一行，并转为输入模式；
O：在当前光标所在行的上方，新建一行，并转为输入模式；

# 输入-->编辑
按键盘键 ESC 进入编辑模式

# 编辑-->末行
输入 : 进入末行模式

# 末行-->编辑
按键盘键 ESC 进入编辑模式
```

关闭文件

```bash
# 末行模式关闭文件
:q  退出
:wq 保存并退出
:q! 不保存并退出
:w 保存
:w! 强行保存
:wq 可以同 :x

# 编辑模式下退出
ZZ: 保存并退出
```

移动光标(编辑模式)

```bash
# 逐字符移动，数字[num]可以带可以不带，带上就是光标移动多少个字符，不带就是一个个字符移动
[num] h: 左
[num] l: 右
[num] j: 下
[num] k: 上
J：当前行与下一行合并

# 以单词为单位移动
w: 移至下一个单词的词首
e: 跳至当前或下一个单词的词尾
b: 跳至当前或前一个单词的词首
[num] web: 同理

# 行内跳转
0: 绝对行首
^: 行首的第一个非空白字符
$: 绝对行尾

# 行间跳转
[num] G：跳转至第 num 行；
G：最后一行
gg:第一行
g~:将当前行大小写转换
: 末行模式下，直接给出行号即可
```

翻屏

```bash
Ctrl+f: 向下翻一屏
Ctrl+b: 向上翻一屏
Ctrl+d: 向下翻半屏
Ctrl+u: 向上翻半屏
```

删除单个字符

```bash
x: 删除光标所在处的单个字符
[num] x: 删除光标所在处及向后的共 num 个字符
```

删除命令 d

```bash
# d 命令跟跳转命令组合使用
[num]dw, [num]de, [num]db

# dd 命令以行为单位删除
dd: 删除当前光标所在行
[num] dd: 删除包括当前光标所在行在内的 num 行；

# 末行模式下
StartADD,EndADDd
	.: 表示当前行
	$: 最后一行
	+[num]: 向下的 num 行
```

粘贴命令 p

```bash
p: 如果删除或复制为整行内容，则粘贴至光标所在行的下方，如果复制或删除的内容为非整行，则粘贴至光标所在字符的后面；
P: 如果删除或复制为整行内容，则粘贴至光标所在行的上方，如果复制或删除的内容为非整行，则粘贴至光标所在字符的前面；
```

复制命令 y

```bash
用法同 d 命令
```

修改 c

```bash
# 先删除内容，再转换为输入模式
用法同d命令
```

替换

```bash
r: 单个字符替换
R: 进入替换模式
```

撤消编辑操作

```bash
u：撤消前一次的编辑操作
	连续u命令可撤消此前的n次编辑操作
[num] u: 直接撤消最近 num 次编辑操作
撤消最近一次撤消操作：Ctrl+r
```

重复前一次编辑操作

```bash
.
```

可视化模式

```bash
v: 按字符选取
V：按矩形选取
```

查找

```bash
/PATTERN：模式匹配
?PATTERN：模式匹配
n：下切换
N：上切换
```

查找并替换

```bash
# 在末行模式下使用 s 命令
ADDR1,ADDR2s@PATTERN@string@gi
%：表示全文
```

使用vim编辑多个文件

```bash
# vim FILE1 FILE2 FILE3
:next 切换至下一个文件
:prev 切换至前一个文件
:last 切换至最后一个文件
:first 切换至第一个文件

# 退出
:qa 全部退出
```

分屏显示一个文件

```bash
Ctrl+w, s: 水平拆分窗口
Ctrl+w, v: 垂直拆分窗口

# 在窗口间切换光标
Ctrl+w+w

:qa 关闭所有窗口
```

分窗口编辑多个文件

```bash
vim -o : 水平分割显示
vim -O : 垂直分割显示
```

将当前文件中部分内容另存为另外一个文件

```bash
# 末行模式下使用 w 命令
:w
:ADDR1,ADDR2w /path/to/somewhere
```

将另外一个文件的内容填充在当前文件中

```bash
:r /path/to/somefile
```

跟 shell 交互

```bash
:! COMMAND（不用退出当前文件就直接相当于在shell下用命令，用完再Enter回来）
```

高级话题

```bash
# 显示或取消显示行号
:set number
:set nu
:set nonu

# 显示忽略或区分字符大小写
:set ignorecase
:set ic
:set noic

# 设定自动缩进
:set autoindent
:set ai
:set noai

# 查找到的文本高亮显示或取消
:set hlsearch
:set nohlsearch

# 语法高亮
:syntax on
:syntax off
```

配置文件

```bash
/etc/vimrc
~/.vimrc
```

*注意：当在使 vim 编辑的时候如果非法退出，则会在编辑的文件所在目录下生成一个与文件同名后缀为 .swp 的文件，每次再编辑这个文件的时候，就会出现提醒，而且.swp文件不会消失，这时可以手动删除 rm -f .inittab.swp*

### 文件查找命令

#### which 命令

显示命令或脚本的全路径，默认也会将命令的别名显示出来。

```bash
[root@arm64v8 ~]# which ls
alias ls='ls --color=auto'
	/usr/bin/ls
[root@arm64v8 ~]# 
```

#### whereis 命令

找出二进制文件、源文件和 man 文档文件。

```bash
[root@arm64v8 ~]# whereis ls
ls: /usr/bin/ls /usr/share/man/man1/ls.1.gz
[root@arm64v8 ~]# 
```

#### whatis 命令

列出给定命令(并非一定是命令)的 man 文档信息。

```bash
[root@arm64v8 ~]# whatis passwd
sslpasswd (1ssl)     - compute password hashes
passwd (1)           - update user's authentication tokens
[root@arm64v8 ~]# 
```

根据上面的结果，执行：

```bash
man 1 passwd # 获取passwd命令的man文档
man 5 passwd # 获取password文件的man文档，文件类的man文档说明的是该文件中各配置项意义
man sslpasswd # 获取sslpasswd命令的man文档，实际上是openssl passwd的man文档
```

#### locate 命令

非实时，模糊匹配，查找是根据全系统文件数据库进行的；updatedb 手动生成文件数据库(刚安装的系统没有数据库，locate用不了，必须updatedb生成，但是要花很长时间）。

```bash
# locate 关键字
[root@arm64v8 ~]# locate -i inittab  # -i 不区分大小写
/etc/inittab
/usr/share/vim/vim74/syntax/inittab.vim
[root@arm64v8 ~]# 
[root@arm64v8 ~]# locate -r conf$ | grep nss # -r 支持正则表达式
/etc/nsswitch.conf
/etc/prelink.conf.d/nss-softokn-prelink.conf
/usr/lib/dracut/dracut.conf.d/50-nss-softokn.conf
[root@arm64v8 ~]# 

# 数据库生成: updatedb
# 数据库目录: /var/lib/mlocate/mlocate.db
1.updatedb -U <path> 对指定的path制作数据库
2.updatedb -e <path> 除指定的path以外目录都建立数据库
3.updatedb -o file 指定生成的数据库文件
```

#### find 命令

实时，精确匹配，支持很多查找标准，往往需要遍历指定目录中的所有文件完成查找，所以速度慢。

语法：find DIRICTORY Cretiria ACTION ( find 查找路径 查找标准 查找到以后的处理运作 )

**DIRICTORY** 默认为当前目录

**Cretiria** 默认为指定路径下的所有文件，实际上 Cretiria 可以很复杂，也是整个表达式的灵魂，下面详解常用的标准

```bash
-name 'FILENAME'：对文件名作精确匹配，FILENAME 可以使用 "* ? []" 通配符
-iname 'FILENAME': 文件名匹配时不区分大小写

[root@arm64v8 ~]# find /etc/ -name "passwd"
/etc/passwd
/etc/pam.d/passwd
[root@arm64v8 ~]# find /etc/ -name "passw?"
/etc/passwd
/etc/pam.d/passwd
[root@arm64v8 ~]# find /etc/ -iname "PasSW[abcd]"
/etc/passwd
/etc/pam.d/passwd
[root@arm64v8 ~]# 
```

```bash
-regex PATTERN：基于正则表达式进行文件名匹配（正则匹配会匹配整个路径，不能只截取某个文件）
-iregex pattern：不区分大小写的"-regex"

[root@arm64v8 ~]# find /etc/ -regex ".*ifcfg.*"
/etc/sysconfig/network-scripts/ifcfg-lo
/etc/sysconfig/network-scripts/ifcfg-eth0
[root@arm64v8 ~]# 
[root@arm64v8 ~]# find /etc/ -regex "ifcfg.*" # 这种就不是全路径，什么也找不到
[root@arm64v8 ~]#
```

```bash
-user USERNAME: 根据属主查找
-group GROUPNAME: 根据属组查找
-uid [+/-]UID: 根据UID查找，有的时候用户删了，其属主属组丢失变成其ID号
-gid [+/-]GID: 根据GID查找，有的时候用户删了，其属主属组丢失变成其ID号
-nouser：查找没有属主的文件
-nogroup: 查找没有属组的文件

# [+/-]表示大于小于的意思
[root@arm64v8 ~]# find /home/ -user python
/home/python
/home/python/.bash_logout
/home/python/.bash_profile
/home/python/.bashrc
/home/python/.bash_history
[root@arm64v8 ~]# find /home/ -group python
/home/python
/home/python/.bash_logout
/home/python/.bash_profile
/home/python/.bashrc
/home/python/.bash_history
[root@arm64v8 ~]# find /home/ -uid +500
/home/python
/home/python/.bash_logout
/home/python/.bash_profile
/home/python/.bashrc
/home/python/.bash_history
[root@arm64v8 ~]# find /home/ -gid +500
/home/python
/home/python/.bash_logout
/home/python/.bash_profile
/home/python/.bashrc
/home/python/.bash_history
[root@arm64v8 ~]#
```

```bash
-fstype <文件系统类型>：在指定的文件系统类型上查找文件
-samefile name：找出指定文件同indoe的文件，即其硬链接文件
-inum  n：inode号为n的文件，可用来找出硬链接文件。但使用"-samefile"比此方式更方便
-links n：有n个软链接的文件

[root@arm64v8 ~]# find /home/python/ -fstype xfs
/home/python/
/home/python/.bash_logout
/home/python/.bash_profile
/home/python/.bashrc
/home/python/.bash_history
[root@arm64v8 ~]# 
```

```bash
-empty：查找空文件/目录
-size n[cwbkMG]：根据文件大小来搜索，可以是(+ -)n，单位可以是：
	· b：512字节的(默认单位)
	· c：1字节的
	· w：2字节
	· k：1024字节
	· M：1024k
	· G：1024M

# [+/-]表示大于小于的意思            
[root@arm64v8 ~]# find /etc/ -size -1M -ls | head -4
268435523    0 -rw-------   1 root     root            0 Apr 23 11:25 /etc/crypttab
805308124    0 -rw-------   1 root     root            0 Apr 11  2018 /etc/security/opasswd
268439305    0 -rw-r--r--   1 root     root            0 Apr 11  2018 /etc/environment
268439306    0 -rw-r--r--   1 root     root            0 Jun  7  2013 /etc/exports
[root@arm64v8 ~]#
```

```bash
-type X：根据文件类型来搜索 
	· b：块设备文件
    · c：字符设备文件
    · d：目录
    · p：命名管道文件(FIFO文件)
    · f：普通文件
    · l：符号链接文件，即软链接文件
    · s：套接字文件(socket)
    
[root@arm64v8 ~]# find /dev/ -type b
/dev/sr0
/dev/vda4
/dev/vda3
/dev/vda2
/dev/vda1
/dev/vda
[root@arm64v8 ~]#
```

```bash
# [acm]time 默认是天，转换成24小时表达，[acm]min 默认是分，[+/-]永远是大于/小于，但是表述时，词能达意就行
-anewer file：atime比mtime更接近现在的文件。也就是说，文件修改过之后被访问过
-cnewer file：ctime比mtime更接近现在的文件
-newer  file：比给定文件的mtime更接近现在的文件。
-newer[acm]t TIME：atime/ctime/mtime比时间戳TIME更新的文件
-amin  n：文件的atime在范围n分钟内改变过。注意，n可以是(+ -)n，例如-amin +3表示在3分钟以前
-cmin  n：文件的ctime在范围n分钟内改变过
-mmin  n：文件的mtime在范围n分钟内改变过
-atime n：文件的atime在范围24*n小时内改变过
-ctime n：文件的ctime在范围24*n小时内改变过
-mtime n：文件的mtime在范围24*n小时内改变过
-used  n：最近一次ctime改变n天范围内，atime改变过的文件，即atime比ctime晚n天的文件，可以是(+ -)n

[root@arm64v8 ~]# find /etc/ -atime +5 | wc -l 至少有5天没有访问过了（如果没有+、-代表正好是那个时间点）
1528
[root@arm64v8 ~]#
```

```bash
-perm mode 精确匹配给定权限的文件。"-perm g=w"将只匹配权限为0020的文件。当然，也可以写成三位数字的权限模式
-perm -mode 匹配完全包含给定权限的文件，这是最可能用上的权限匹配方式。例如给定的权限"-0766"，则只能匹配"N767"、"N777"和"N776"这几种权限的文件，如果使用字符模式的权限，则必须指定u/g/o/a，例如"-perm -u+x,a+r"表示至少所有人都有读权限，且所有者有执行权限的文件
-perm /mode 匹配任意给定权限位的权限，例如"-perm /640"可以匹配出600，040,700,740等等，只要文件权限的任意位能包含给定权限的任意一位就满足
-perm +mode 由于某些原因，此匹配模式被替换为"-perm /mode"，所以此模式已经废弃
-executable 具有可执行权限的文件。它会考虑acl等的特殊权限，只要是可执行就满足。它会忽略掉-perm的测试
-readable 具有可读权限的文件。它会考虑acl等的特殊权限，只要是可读就满足。它会忽略掉-perm的测试
-writable 具有可写权限的文件。它会考虑acl等的特殊权限，只要是可写就满足。它会忽略掉-perm的测试(不是writeable)

# 先看一下/tmp下有哪些文件，当前是什么权限，好为下面对比理解做准备
[root@arm64v8 ~]# ls -l -a /tmp/
总用量 832
drwxrwxrwt   7 root root    340  5月 28 20:35 .
dr-xr-xr-x. 20 root root    283  4月 23 14:39 ..
-rw-------   1 root root   5048  5月 28 20:26 access.log
-rw-------   1 root root 124515  5月 28 20:27 boot.log
-rw-------   1 root root  49584  5月 28 20:27 dnf.librepo.log
-rw-------   1 root root 137109  5月 28 20:27 dnf.log
-rw-------   1 root root  49236  5月 28 20:27 dnf.rpm.log
-rw-------   1 root root  44453  5月 28 20:27 dracut.log
-rw-------   1 root root   4239  5月 28 20:26 error.log
drwxrwxrwt   2 root root     40  5月 21 15:15 .font-unix
-rw-------   1 root root   2340  5月 28 20:27 hawkey.log
drwxrwxrwt   2 root root     40  5月 21 15:15 .ICE-unix
-rw-------   1 root root  11364  5月 28 20:27 kylin-security.log
-rw-------   1 root root   1673  5月 28 20:27 systemtap.log
drwxrwxrwt   2 root root     40  5月 21 15:15 .Test-unix
drwxrwxrwt   2 root root     40  5月 21 15:15 .X11-unix
drwxrwxrwt   2 root root     40  5月 21 15:15 .XIM-unix
[root@arm64v8 ~]# 

# 对比权限表达方式
[root@arm64v8 ~]# find /tmp/ -perm 744 # 为空
[root@arm64v8 ~]# find /tmp/ -perm -744 # 完全包含给定权限的文件
/tmp/
/tmp/.Test-unix
/tmp/.font-unix
/tmp/.XIM-unix
/tmp/.ICE-unix
/tmp/.X11-unix
[root@arm64v8 ~]# find /tmp/ -perm /744 # 匹配任意给定权限位的权限
/tmp/
/tmp/systemtap.log
/tmp/kylin-security.log
/tmp/hawkey.log
/tmp/dracut.log
/tmp/dnf.rpm.log
/tmp/dnf.log
/tmp/dnf.librepo.log
/tmp/boot.log
/tmp/error.log
/tmp/access.log
/tmp/.Test-unix
/tmp/.font-unix
/tmp/.XIM-unix
/tmp/.ICE-unix
/tmp/.X11-unix
[root@arm64v8 ~]#
```

```bash
# 组合条件
-a 与
-or 或
-not 非

# 简单应用
[root@arm64v8 ~]# find /tmp -nouser -a -type f -ls 
  2494026      0 -rw-------   1 1000     1001            0 5月 28 20:44 /tmp/python
  2494017      0 -rw-------   1 1000     1001            0 5月 28 20:44 /tmp/am
  2495255      0 -rw-------   1 1000     1001            0 5月 28 20:44 /tmp/I
[root@arm64v8 ~]#
[root@arm64v8 ~]# find /tmp \( -nouser -o -type f \) -ls
  2494026      0 -rw-------   1 1000     1001            0 5月 28 20:44 /tmp/python
  2494017      0 -rw-------   1 1000     1001            0 5月 28 20:44 /tmp/am
  2495255      0 -rw-------   1 1000     1001            0 5月 28 20:44 /tmp/I
  2493694     64 -rw-------   1 root      root         1673 5月 28 20:27 /tmp/systemtap.log
  2493693     64 -rw-------   1 root      root        11364 5月 28 20:27 /tmp/kylin-security.log
  2493692     64 -rw-------   1 root      root         2340 5月 28 20:27 /tmp/hawkey.log
  2493691     64 -rw-------   1 root      root        44453 5月 28 20:27 /tmp/dracut.log
  2493690     64 -rw-------   1 root      root        49236 5月 28 20:27 /tmp/dnf.rpm.log
  2493689    192 -rw-------   1 root      root       137109 5月 28 20:27 /tmp/dnf.log
  2493688     64 -rw-------   1 root      root        49584 5月 28 20:27 /tmp/dnf.librepo.log
  2493687    128 -rw-------   1 root      root       124515 5月 28 20:27 /tmp/boot.log
  2495536     64 -rw-------   1 root      root         4239 5月 28 20:26 /tmp/error.log
  2495535     64 -rw-------   1 root      root         5048 5月 28 20:26 /tmp/access.log
[root@arm64v8 ~]# 
[root@arm64v8 ~]# find /tmp -not -type f -ls
     7277      0 drwxrwxrwt   7 root     root          400 5月 28 20:45 /tmp
    19728      0 drwxrwxrwt   2 root     root           40 5月 21 15:15 /tmp/.Test-unix
    19727      0 drwxrwxrwt   2 root     root           40 5月 21 15:15 /tmp/.font-unix
    19726      0 drwxrwxrwt   2 root     root           40 5月 21 15:15 /tmp/.XIM-unix
    19725      0 drwxrwxrwt   2 root     root           40 5月 21 15:15 /tmp/.ICE-unix
    19724      0 drwxrwxrwt   2 root     root           40 5月 21 15:15 /tmp/.X11-unix
[root@arm64v8 ~]#

# 复杂应用，摩根定律，下面两种表达方式是一样的，与或非的转换
[dirctory@arm64v8 ~]$ find /tmp -not -type f -a -not -user root -ls
  2504232      0 drwx------   2 dirctory dirctory       40 5月 28 21:12 /tmp/I
  2506622      0 drwx------   2 dirctory dirctory       40 5月 28 21:12 /tmp/am
  2502056      0 drwx------   2 dirctory dirctory       40 5月 28 21:12 /tmp/dirctory
[dirctory@arm64v8 ~]$
[dirctory@arm64v8 ~]$ find /tmp/ -not \( -type f -o -user root \) -ls
  2504232      0 drwx------   2 dirctory dirctory       40 5月 28 21:12 /tmp/I
  2506622      0 drwx------   2 dirctory dirctory       40 5月 28 21:12 /tmp/am
  2502056      0 drwx------   2 dirctory dirctory       40 5月 28 21:12 /tmp/dirctory
[dirctory@arm64v8 ~]$
```

**ACTION** 一般都是执行某些命令，或实现某些功能

```bash
-delete 删除文件，如果删除成功则返回true，如果删除失败，将给出错误信息。
-exec COMMAND ; 注意有个分号";"结尾，该action是用于执行给定的命令。如果命令的返回状态码为0则该action返回true。command后面的所有内容都被当作command的参数，直到分号";"为止，其中参数部分使用字符串"{}"时，它表示find找到的文件名，即在执行命令时，"{}"会被逐一替换为find到的文件名，"{}"可以出现在参数中的任何位置，只要出现，它都会被文件名替换。注意，分号";"需要转义，即"\;"，如有需要，可以将"{}"用引号包围起来。
-ok command ; 类似于-exec，但在执行命令前会交互式进行询问，如果不同意，则不执行命令并返回false，如果同意，则执行命令，但执行的命令是从/dev/null读取输入的。
-print 总是返回true。这是默认的action，输出搜索到文件的全路径名，并尾随换行符"\n"。由于在使用"-print"时所有的结果都有换行符，如果直接将结果通过管道传递给管道右边的程序，应该要考虑到这一点：文件名中有空白字符(换行符、制表符、空格)将会被右边程序误分解，如文件"ab c.txt"将被认为是ab和c.txt两个文件，如不想被此分解影响，可考虑使用"-print0"替代"-print"将所有换行符替换为"\0"
-print0 总是返回true。输出搜索到文件的全路径名，并尾随空字符"\0"。由于尾随的是空字符，所以管道传递给右边的程序，然后只需对这个空字符进行识别分隔就能保证文件名不会因为其中的空白字符被误分解
-prune 不进入目录，所以可用于忽略目录，但不会忽略普通文件。没有给定-depth时，总是返回true，如果给定-depth，则直接返回false，所以-delete(隐含了-depth)是不能和-prune一起使用的
-ls 总是返回true。将找到的文件以"ls -dils"的格式打印出来，其中文件的size部分以KB为单位
xargs 完成了两个行为：处理管道传输过来的stdin；将处理后的传递到正确的位置上。

[root@arm64v8 ~]# find /tmp -user dirctory -ok chmod o+x {} \; # 需要确认
< chmod ... /tmp/I > ? y
< chmod ... /tmp/am > ? y
< chmod ... /tmp/dirctory > ? y
[root@arm64v8 ~]# find /tmp/ -type d -a -user dirctory -ls
  2504232      0 drwx-----x   2 dirctory dirctory       40 5月 28 21:12 /tmp/I
  2506622      0 drwx-----x   2 dirctory dirctory       40 5月 28 21:12 /tmp/am
  2502056      0 drwx-----x   2 dirctory dirctory       40 5月 28 21:12 /tmp/dirctory
[root@arm64v8 ~]# find /tmp -user dirctory -exec chmod o-x {} \; # 不需要确认
[root@arm64v8 ~]# find /tmp/ -type d -a -user dirctory -ls
  2504232      0 drwx------   2 dirctory dirctory       40 5月 28 21:12 /tmp/I
  2506622      0 drwx------   2 dirctory dirctory       40 5月 28 21:12 /tmp/am
  2502056      0 drwx------   2 dirctory dirctory       40 5月 28 21:12 /tmp/dirctory
[root@arm64v8 ~]#
[root@arm64v8 ~]# find /tmp/ -type d -a -user dirctory | xargs chmod o+x # xargs看起来用着更爽，是的，不过xargs是个独立命令，功能丰富
[root@arm64v8 ~]# find /tmp/ -type d -a -user dirctory -ls
  2504232      0 drwx-----x   2 dirctory dirctory       40 5月 28 21:12 /tmp/I
  2506622      0 drwx-----x   2 dirctory dirctory       40 5月 28 21:12 /tmp/am
  2502056      0 drwx-----x   2 dirctory dirctory       40 5月 28 21:12 /tmp/dirctory
[root@arm64v8 ~]#

```

*注意：action 是可以写在 cretiria 表达式前面的，它并不一定是在 cretiria 表达式之后执行。*

