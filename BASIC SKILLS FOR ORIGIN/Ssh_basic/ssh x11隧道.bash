# centos安装
yum install xorg-x11-xauth

# ubuntu安装
apt install xauth

问题：有时安装了但是还是不能进行x11隧道转移
分析：在家目录下找.Xauthority，如果没有手动创建即可