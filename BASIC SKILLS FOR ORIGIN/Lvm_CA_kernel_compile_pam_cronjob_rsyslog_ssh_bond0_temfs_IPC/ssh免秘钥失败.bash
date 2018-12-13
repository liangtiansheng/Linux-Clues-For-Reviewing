ssh 免密码设置失败原因总结
先复习一下设置ssh免密码操作的步骤：

进入主目录
cd
生成公钥
ssh-keygen -t rsa -P '' (注：最后是二个单引号，表示不设置密码)
然后分发公钥到目标机器
ssh-copy-id -i ~/.ssh/id_rsa.pub 用户名@对方机器IP (注意不要忘记了参数-i)
注：ssh-copy-id -i 是最简单的办法，如果不用这个，就得分二个步骤:
a) 先scp 将本机的id_rsa.pub复制到对方机器的.ssh目录下
b) 在对方机器上执行 cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys 导入公钥
上面的操作完成后，就可以用 ssh 对方机器IP 来测试了，顺利的话，应该不会提示输入密码。
如果失败，有可能是以下原因：

1、权限问题
.ssh目录，以及/home/当前用户 需要700权限，参考以下操作调整
sudo chmod 700 ~/.ssh
sudo chmod 700 /home/当前用户
.ssh目录下的authorized_keys文件需要600或644权限，参考以下操作调整
sudo chmod 600 ~/.ssh/authorized_keys

2、StrictModes问题
编辑
sudo vi /etc/ssh/sshd_config
找到
#StrictModes yes
改成
StrictModes no

StrictModes no #修改为no,默认为yes.如果不修改用key登陆是出现server refused our key(如果StrictModes为yes必需保证存放公钥的文件夹的拥有与登陆用户名是相同的.“StrictModes”设置ssh在接收登录请求之前是否检查用户家目录和rhosts文件的权限和所有权。这通常是必要的，因为新手经常会把自己的目录和文件设成任何人都有写权限。)
 

