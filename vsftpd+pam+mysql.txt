官方文档：

安装vsftpd、mysql和phpmyadmin
Vsftp没有内置的MySQL支持，所以我们必须使用PAM来认证：
sudo apt-get install vsftpd libpam-mysql mysql-server mysql-client phpmyadmin
随后会询问下列问题：
New password for the MySQL "root" user: <-- yourrootsqlpassword
Repeat password for the MySQL "root" user: <-- yourrootsqlpassword
Web server to reconfigure automatically: <-- apache2
创建MySQL数据库
现在我们创建名为vsftpd的数据库和名为vsftpd的MySQL账户（用于vsftpd进程连接vsftpd数据库）：
mysql -u root -p
CREATE DATABASE vsftpd;
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP ON vsftpd.* TO 'vsftpd'@'localhost' IDENTIFIED BY 'ftpdpass';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP ON vsftpd.* TO 'vsftpd'@'localhost.localdomain' IDENTIFIED BY 'ftpdpass';
FLUSH PRIVILEGES;
ftpdpass换成你想要的密码，然后创建表：
USE vsftpd;
CREATE TABLE `accounts` (
`id` INT NOT NULL AUTO_INCREMENT PRIMARY KEY ,
`username` VARCHAR( 30 ) NOT NULL ,
`pass` VARCHAR( 50 ) NOT NULL ,
UNIQUE (
`username`
)
) ENGINE = MYISAM ;
quit;

配置vsftpd
首先创建一个vsftpd的用户（/home/vsftpd），属于nogroup。vsftpd进程运行在该用户下，虚拟用户的FTP目录会放置在/home/vsftpd下（如/home/vsftpd/user1, /home/vsftpd/user2）
useradd --home /home/vsftpd --gid nogroup -m --shell /bin/false vsftpd
备份初始的/etc/vsftpd.conf文件，创建新的：
cp /etc/vsftpd.conf /etc/vsftpd.conf_orig
cat /dev/null > /etc/vsftpd.conf

vi /etc/vsftpd.conf
内容如下：
listen=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
xferlog_enable=YES
connect_from_port_20=YES
nopriv_user=vsftpd
chroot_local_user=YES
secure_chroot_dir=/var/run/vsftpd
pam_service_name=vsftpd
rsa_cert_file=/etc/ssl/certs/vsftpd.pem
guest_enable=YES
guest_username=vsftpd
local_root=/home/vsftpd/$USER
user_sub_token=$USER
virtual_use_local_privs=YES
user_config_dir=/etc/vsftpd_user_conf
allow_writeable_chroot=YES
	RHLE7以后权限加强了，必须有这一句 

mkdir /etc/vsftpd_user_conf
cp /etc/pam.d/vsftpd /etc/pam.d/vsftpd_orig
cat /dev/null > /etc/pam.d/vsftpd
vi /etc/pam.d/vsftpd
auth required pam_mysql.so user=vsftpd passwd=ftpdpass host=localhost db=vsftpd table=accounts usercolumn=username passwdcolumn=pass crypt=2
account required pam_mysql.so user=vsftpd passwd=ftpdpass host=localhost db=vsftpd table=accounts usercolumn=username passwdcolumn=pass crypt=2

最后，我们重启vsftpd：
sudo service vsftpd restart

创建虚拟用户
mysql -u root -p
USE vsftpd;
创建名为testuser，密码为secret（会用MySQL的password函数加密）：
INSERT INTO accounts (username, pass) VALUES('testuser', PASSWORD('secret'));
quit;

testuser的根目录应该是 /home/vsftpd/testuser，但麻烦的是vsftpd不会自动创建该目录的，所以我们得自个手动创建，同时确保它的属于vsftpd用户和nogroup用户组。
mkdir /home/vsftpd/testuser
chown vsftpd:nogroup /home/vsftpd/testuser

最后试下能否正常登录
ftp localhost
数据库管理
用phpmyadmin管理mysql数据库最方便了。只要注意在设定密码时选择PASSWORD函数j就行。还有就是新增虚拟用户时别忘了手动新建虚拟用户的根目录。