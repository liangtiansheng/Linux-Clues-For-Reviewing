声明一个数组：
declare -a AA

赋值方法1：
AA[0]=jerry
AA[1]=tom
AA[2]=wendy
AA[6]=natasha //345没定义则为空

赋值方法2：
AA=(jerry tom wendy)
AA=([0]=jerry [1]=tom [2]=wendy [6]=natasha)

***怎么知道一个数组中有多少个元素
*指定元素有几个字符：变量默认是第一个元素
${#AA} = ${#AA[0]}
*数组共有几个元素：
${#AA[*]} = ${#AA[@]}

#!/bin/bash
#
AA=([0]=jerry [1]=tom [6]=nikita)
echo  ${AA[0]}
echo  ${AA[6]}
echo  ${AA[2]}

***生成10个随机数，找出最大值
#!/bin/bash
#
for I in {0..9}; do
        ARRAY[$I]=$RANDOM
        echo -n "${ARRAY[$I]} "
        sleep 1
done

echo

declare -i MAX=${ARRAY[0]}
INDEX=${#ARRAY[*]}
for I in `seq 1  $INDEX`; do
        if [ $MAX -lt ${ARRAY[$I-1]} ]; then
                MAX=${ARRAY[$I-1]}
        fi
done
echo $MAX


***生成一个数组：
1、数组的元素个数为1-39
2、数组元素不能相同
3、显示此数组各元素的值
#!/bin/bash
#
read -p "The element number[1-39]:" ELENUM
declare -a ARRAY

function COMELE {
        for J in `seq 0 $[${#ARRAY[*]}-1]`;do
                if [ $1 -eq ${ARRAY[$J]} ];then
                        return 1
                fi
        done
        return 0
}

for I in `seq 0 $[$ELENUM-1]`;do
        while true; do
                ELEMENT=$[$RANDOM%40]
                COMELE $ELEMENT
                if [ $? -eq 0 ]; then
                        break
                fi
        done
                ARRAY[$I]=$ELEMENT
                echo  "${ARRAY[$I]} "

done

***trap：在脚本中捕捉信号，并且可以特定处理
1：SIGHUP
2: SIGINT
9: SIGKILL
15: SIGTERM
18: SIGCONT
19: SIGSTOP
#!/bin/bash
#
trap 'rm -rf /var/tmp/test;echo"cleaned yet";exit 5' INT
mkdir -p /var/tmp/test
while true;do
	touch /var/tmp/test/file-`date +%F-%H-%M-%S`
	sleep 2
done


***脚本生成器：
*系统内置命令或变量getopts, $OPTIND, $OPTARG
#!/bin/bash
# Name: mkscript
# Description: Create script
# Author: Magedu
# Version: 0.0.1
# Datatime: 20/5/16 15:50
# Usage: mkscript FILENAME
while getopts ":d:" SWITCH; do //这里的d是表示此脚本接受一个d选项（赋值给后面的变量），冒号表示选项后面要接一个参数（系统默认将参数给变量$OPTARG）
	case $SWITCH in
	  d)
		DESC=$OPTARG;;
	  \?)
		echo "Usage: mkscript [-d DESCRIPTION] FILENAME" ;;
	esac
done
shift $[$OPTIND-1]


if ! grep "[^[:space:]]" $1 &> /dev/null; then
cat > $1 << EOF
#!/bin/bash
# Name: `basename $1`
# Description: $DESC
# Author: Magedu
# Version: 0.0.1
# Datatime: `date +"%F %T"`
# Usage: `basename $1`
EOF
fi

vim + $1

until bash -n $1 &> /dev/null; do
	read -p "Syntax error, q|Q for quiting, others for editing:" OPT
	case $OPT in
	q|Q)
		echo "Quit."
		exit 8 
		;;
	*)	
		vim + $1
		;;
	esac
done

chmod +x $1


写一个脚本getinterface.sh, 脚本可以接受选项（i, I, a），完成以下任务：
（1）使用以下形式： getinterface.sh [-i interface|-I IP|-a]
（2）当用户使用-i选项时，显示其指定网卡的IP地址
（3）当用户使用-I选项时，显示其后面的IP地址所属的网络接口
（4）当用户单独使用-a选项时，显示所有网络接口及其IP地址（lo除外）

SHOWIP() {
	if ! ifconfig | grep -o "^[^[:space:]]\{1,\}" | grep $1 &> /dev/null; then
		return 13
	fi

	echo -n "${1}:"
	ifconfig $1 | grep -o "inet addr:[0-9\.]\{1,\}" | cut -d: -f2
	echo 
}

SHOWETHER() {
	if ! ifconfig | grep -o "inet addr:[0-9\.]\{1,\}" | cut -d: -f2 | grep $1 &> /dev/null; then
		return 14
	fi

	echo -n "${1}:"
	ifconfig | grep -B 1 "$1" | grep -o "^[^[:space:]]\{1,\}"
	echo 
}

USAGE() {
	echo "getinterface.sh <-i interface|-I IP>"
}

while getopts ":i:I:" SWITCH; do
	case $SWITCH in
	i)
		SHOWIP $OPTARG
		[ $? -eq 13 ] && echo "Wrong ethercard."
		;;
	I)
		SHOWETHER $OPTARG
		[ $? -eq 14 ] && echo "Wrong IP"
	*)
		USAGE;;
	esac
done


***vnc-server
*密码有独立的管理目录，当然远程连接是明文，不太安全
[root@RHEL5 ~]# vncpasswd 
Password:
Verify:
[root@RHEL5 ~]# vncserver &
[1] 5050
[root@RHEL5 ~]# xauth: (stdin):1:  bad display name "RHEL5.8:1" in "add
" command
New 'RHEL5.8:1 (root)' desktop is RHEL5.8:1

Creating default startup script /root/.vnc/xstartup
Starting applications specified in /root/.vnc/xstartup
Log file is /root/.vnc/RHEL5.8:1.log

[root@RHEL5 ~]# 
[1]+  Done                    vncserver
*上面的配置还不是桌面而是命令行，所以改成下面的桌面
[root@RHEL5 ~]# ls -a | grep "vnc"
.vnc
[root@RHEL5 ~]# cd .vnc/
[root@RHEL5 .vnc]# ls
passwd  RHEL5.8:1.log  RHEL5.8:1.pid  xstartup
[root@RHEL5 .vnc]# vim xstartup
#!/bin/sh

# Uncomment the following two lines for normal desktop:
unset SESSION_MANAGER
exec /etc/X11/xinit/xinitrc

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
vncconfig -iconic &
xterm -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
gnome-session &
*刚才开启的进程要杀掉
[root@RHEL5 .vnc]# vncserver -kill :1
Killing Xvnc process ID 5058
[root@RHEL5 .vnc]#
[root@RHEL5 .vnc]# service vncserver start
Starting VNC server: no displays configured                [  OK  ]
*没有改主配置文件才会出现错误，或者还是用vncserver &来启用
[root@RHEL5 .vnc]# vim /etc/sysconfig/vncservers 
SERVERS="1:root"
VNCSERVERARGS[2]="-geometry 1280x800 -nolisten tcp -nohttpd -localhost"
















