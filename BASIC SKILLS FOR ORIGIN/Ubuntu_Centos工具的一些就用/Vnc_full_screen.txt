
################ ubuntu 16.04 简单操作 ##############
1、安装gnome

apt-get install --no-install-recommends ubuntu-desktop gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal -y
2、安装dpi

sudo apt-get install xfonts-100dpi
sudo apt-get install xfonts-75dpi
2、修改vi /home/yp/.vnc/xstartup

#!/bin/sh
# Uncomment the following two lines for normal desktop:
export XKL_XMODMAP_DISABLE=1
unset SESSION_MANAGER
# exec /etc/X11/xinit/xinitrc
unset DBUS_SESSION_BUS_ADDRESS
gnome-panel &
gnmoe-settings-daemon &
metacity &
nautilus &
gnome-terminal &

################# ubuntu 18.04 复杂点 #################
一个Ubuntu 18.04服务器按照Ubuntu 18.04初始服务器设置指南设置 ，包括一个sudo非root用户和防火墙。
安装了VNC客户端的本地计算机，支持通过SSH隧道的VNC连接。
在Winows上，您可以使用TightVNC ， RealVNC或UltraVNC 。
在macOS上，您可以使用内置的屏幕共享程序，也可以使用RealVNC等跨平台应用程序。
在Linux上，您可以从许多选项中进行选择，包括vinagre ， krdc ， RealVNC或TightVNC 。
第1步 - 安装桌面环境和VNC服务器
默认情况下，Ubuntu 18.04服务器没有安装图形桌面环境或VNC服务器，所以我们首先安装它们。 具体来说，我们将为最新的Xfce桌面环境和官方Ubuntu存储库中提供的TightVNC软件包安装软件包。

在您的服务器上，更新您的包列表：

sudo apt update
现在在您的服务器上安装Xfce桌面环境：

sudo apt install xfce4 xfce4-goodies
安装完成后，安装TightVNC服务器：

sudo apt install tightvncserver
要在安装后完成VNC服务器的初始配置，请使用vncserver命令设置安全密码并创建初始配置文件：

vncserver
系统将提示您输入并验证密码以远程访问您的计算机：

You will require a password to access your desktops.

Password:
Verify:
密码长度必须介于六到八个字符之间。 超过8个字符的密码将自动截断。

验证密码后，您可以选择创建仅查看密码。 使用仅查看密码登录的用户将无法使用鼠标或键盘控制VNC实例。 如果您想使用VNC服务器向其他人演示内容，这是一个有用的选项，但这不是必需的。

然后，该过程为服务器创建必要的默认配置文件和连接信息：

Would you like to enter a view-only password (y/n)? n
xauth:  file /home/sammy/.Xauthority does not exist

New 'X' desktop is your_hostname:1

Creating default startup script /home/sammy/.vnc/xstartup
Starting applications specified in /home/sammy/.vnc/xstartup
Log file is /home/sammy/.vnc/your_hostname:1.log
现在让我们配置VNC服务器。

第2步 - 配置VNC服务器

 
VNC服务器需要知道启动时要执行的命令。 具体来说，VNC需要知道它应该连接到哪个图形桌面。

这些命令位于主目录下.vnc文件夹中名为xstartup的配置文件中。 在上一步中运行vncserver时创建了启动脚本，但我们将创建自己的启动脚本以启动Xfce桌面。

首次设置VNC时，它会在端口5901上启动默认服务器实例。 该端口称为显示端口 ，VNC称为:1 。 VNC可以在其他显示端口上启动多个实例，例如:2 ， :3等。

因为我们要更改VNC服务器的配置方式，所以首先使用以下命令停止在端口5901上运行的VNC服务器实例：

vncserver -kill :1
输出应该如下所示，尽管您会看到不同的PID：

Killing Xtightvnc process ID 17648
在修改xstartup文件之前，请备份原始文件：

mv ~/.vnc/xstartup ~/.vnc/xstartup.bak
现在创建一个新的xstartup文件并在文本编辑器中打开它：

nano ~/.vnc/xstartup
无论何时启动或重新启动VNC服务器，都会自动执行此文件中的命令。 如果尚未启动，我们需要VNC启动我们的桌面环境。 将这些命令添加到文件中：

#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
文件中的第一个命令xrdb $HOME/.Xresources告诉VNC的GUI框架读取服务器用户的.Xresources文件。 .Xresources是用户可以更改图形桌面的某些设置的地方，如终端颜色，光标主题和字体渲染。 第二个命令告诉服务器启动Xfce，在这里您可以找到舒适地管理服务器所需的所有图形软件。

为确保VNC服务器能够正确使用此新启动文件，我们需要使其可执行。

sudo chmod +x ~/.vnc/xstartup
现在，重新启动VNC服务器。

vncserver
您将看到类似于此的输出：

New 'X' desktop is your_hostname:1

Starting applications specified in /home/sammy/.vnc/xstartup
Log file is /home/sammy/.vnc/your_hostname:1.log
配置到位后，让我们从本地计算机连接到服务器。

第3步 - 安全地连接VNC桌面
连接时VNC本身不使用安全协议。 我们将使用SSH隧道安全地连接到我们的服务器，然后告诉我们的VNC客户端使用该隧道而不是直接连接。

在本地计算机上创建SSH连接，以便安全地转发到VNC的localhost连接。 您可以使用以下命令通过Linux或macOS上的终端执行此操作：

ssh -L 5901:127.0.0.1:5901 -C -N -l sammy your_server_ip
-L开关指定端口绑定。 在这种情况下，我们将远程连接的端口5901绑定到本地计算机上的端口5901 。 -C开关启用压缩，而-N开关告诉ssh我们不想执行远程命令。 -l开关指定远程登录名。

请记住使用sudo非root用户名和服务器的IP地址替换sammy和your_server_ip 。

如果您使用的是图形化SSH客户端（如PuTTY），请使用your_server_ip作为连接IP，并将localhost:5901设置为程序SSH隧道设置中的新转发端口。

隧道运行后，使用VNC客户端连接到localhost:5901 。 系统将提示您使用在第1步中设置的密码进行身份验证。

连接后，您将看到默认的Xfce桌面。 它应该看起来像这样：
####图略####

VNC连接到Ubuntu 18.04服务器

您可以使用文件管理器或命令行访问主目录中的文件，如下所示：
####图略####

文件通过VNC连接到Ubuntu 18.04

在终端中按CTRL+C以停止SSH隧道并返回到您的提示。 这也将断开您的VNC会话。

接下来让我们将VNC服务器设置为服务。

第4步 - 将VNC作为系统服务运行

 
接下来，我们将VNC服务器设置为systemd服务，以便我们可以根据需要启动，停止和重新启动它，就像任何其他服务一样。 这还将确保在服务器重新启动时VNC启动。

首先，使用您喜欢的文本编辑器创建一个名为/etc/systemd/system/vncserver@.service的新单元文件：

sudo nano /etc/systemd/system/vncserver@.service
名称末尾的@符号将让我们传入一个我们可以在服务配置中使用的参数。 我们将使用它来指定我们在管理服务时要使用的VNC显示端口。

将以下行添加到该文件中。 请务必更改用户 ， 组 ， WorkingDirectory的值以及PIDFILE值中的用户名以匹配您的用户名：

[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=sammy
Group=sammy
WorkingDirectory=/home/sammy

PIDFile=/home/sammy/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
ExecStartPre命令在VNC已经运行时停止。 ExecStart命令启动VNC并将颜色深度设置为24位颜色，分辨率为1280x800。 您也可以修改这些启动选项以满足您的需求。

保存并关闭文件。

接下来，让系统知道新的单元文件。

sudo systemctl daemon-reload
启用单元文件。

sudo systemctl enable vncserver@1.service
@符号后面的1表示服务应显示在哪个显示编号上，在这种情况下默认:1如第2步中所述。

如果VNC服务器仍然在运行，请停止它的当前实例。

vncserver -kill :1
然后启动它，就像启动任何其他systemd服务一样。

sudo systemctl start vncserver@1
您可以使用此命令验证它是否已启动：

sudo systemctl status vncserver@1
如果它正确启动，输出应如下所示：

● vncserver@1.service - Start TightVNC server at startup
   Loaded: loaded (/etc/systemd/system/vncserver@.service; indirect; vendor preset: enabled)
   Active: active (running) since Mon 2018-07-09 18:13:53 UTC; 2min 14s ago
  Process: 22322 ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 :1 (code=exited, status=0/SUCCESS)
  Process: 22316 ExecStartPre=/usr/bin/vncserver -kill :1 > /dev/null 2>&1 (code=exited, status=0/SUCCESS)
 Main PID: 22330 (Xtightvnc)

...
重新启动计算机后，您的VNC服务器现在可用。

再次启动SSH隧道：

ssh -L 5901:127.0.0.1:5901 -C -N -l sammy your_server_ip
然后使用您的VNC客户端软件与localhost:5901建立新连接以连接到您的计算机。

结论
您现在已在Ubuntu 18.04服务器上启动并运行安全的VNC服务器。 现在，您将能够使用易于使用且熟悉的图形界面管理文件，软件和设置，并且您将能够远程运行Web浏览器等图形软件