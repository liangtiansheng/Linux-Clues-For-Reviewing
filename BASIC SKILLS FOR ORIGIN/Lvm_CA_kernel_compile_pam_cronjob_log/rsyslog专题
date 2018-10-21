日志管理Rsyslog

背景
有一个4台机器的分布式服务，不多不少，上每台机器上查看日志比较麻烦，用Flume，Logstash、ElasticSearch、Kibana等分布式日志管理系统又显得大材小用，所以想到了centos自带的rsyslog。

简介
Rsyslog可以简单的理解为syslog的超集，在老版本的Linux系统中，Red Hat Enterprise Linux 3/4/5默认是使用的syslog作为系统的日志工具，从RHEL 6 开始系统默认使用了Rsyslog。

Rsyslog 是负责收集 syslog 的程序，可以用来取代 syslogd 或 syslog-ng。 在这些 syslog 处理程序中，个人认为 rsyslog 是功能最为强大的。 其特性包括：

支持输出日志到各种数据库，如 MySQL，PostgreSQL，MongoDB，ElasticSearch，等等；
通过 RELP + TCP 实现数据的可靠传输（基于此结合丰富的过滤条件可以建立一种 可靠的数据传输通道供其他应用来使用）；
精细的输出格式控制以及对消息的强大 过滤能力；
高精度时间戳；队列操作（内存，磁盘以及混合模式等）； 支持数据的加密和压缩传输等。
版本查看
$rsyslogd -version
rsyslogd 3.22.1, compiled with:
    FEATURE_REGEXP:             Yes
    FEATURE_LARGEFILE:          Yes
    FEATURE_NETZIP (message compression):   Yes
    GSSAPI Kerberos 5 support:      Yes
    FEATURE_DEBUG (debug build, slow code): No
    Atomic operations supported:        Yes
    Runtime Instrumentation (slow code):    No

See http://www.rsyslog.com for more information.
安装
yum -y rsyslog
#查看是否安装了rsyslog
rpm -qa | grep rsyslog
#如果还需要别的组件(mysql模块,日志轮转)
yum -y rsyslog-mysql  
yum -y logrotate
启动/停止
/etc/init.d/rsyslog start
/etc/init.d/rsyslog stop
/etc/init.d/rsyslog restart

//帮助文档 man rsyslogd, 或者输入一个错误的命令
$rsyslogd --help
rsyslogd: invalid option -- '-'
usage: rsyslogd [-c<version>] [-46AdnqQvwx] [-l<hostlist>] [-s<domainlist>]
                [-f<conffile>] [-i<pidfile>] [-N<level>] [-M<module load path>]
                [-u<number>]
To run rsyslogd in native mode, use "rsyslogd -c3 <other options>"

For further information see http://www.rsyslog.com/doc
配置
rsyslog的配置文件有多种书写方法：

sysklogd（一些结构不兼容新特性），
legacy rsyslog（以“$”开头的写法，如：$ModLoad imtcp.so），
RainerScript（一种新的格式，是最推荐使用的一种，尤其是需要做复杂的配置时）。
在本文中的配置都比较简单，就采用了legacy rsyslog的配置书写方法。更多详情参考：http://www.rsyslog.com/doc/master/configuration/basic_structure.html#statement-types

配置文件简单实例
下面是一个例子：

$less /etc/rsyslog.conf 
#rsyslog v3 config file

# if you experience problems, check
# http://www.rsyslog.com/troubleshoot for assistance

#### MODULES ####

$ModLoad imuxsock.so    # provides support for local system logging (e.g. via logger command)
$ModLoad imklog.so      # provides kernel logging support (previously done by rklogd)
#$ModLoad immark.so     # provides --MARK-- message capability

# Provides UDP syslog reception
#$ModLoad imudp.so
#$UDPServerRun 514

# Provides TCP syslog reception
#$ModLoad imtcp.so  
#$InputTCPServerRun 514


#### GLOBAL DIRECTIVES ####

# Use default timestamp format
$ActionFileDefaultTemplate RSYSLOG_TraditionalFileFormat

# File syncing capability is disabled by default. This feature is usually not required, 
# not useful and an extreme performance hit
#$ActionFileEnableSync on


#### RULES ####

# Log all kernel messages to the console.
# Logging much else clutters up the screen.
#kern.*                                                 /dev/console

# Log anything (except mail) of level info or higher.
# Don't log private authentication messages!
*.info;mail.none;authpriv.none;cron.none                /var/log/messages

# The authpriv file has restricted access.
authpriv.*                                              /var/log/secure

# Log all the mail messages in one place.
mail.*                                                  -/var/log/maillog


# Log cron stuff
cron.*                                                  /var/log/cron

# Everybody gets emergency messages
*.emerg                                                 *

# Save news errors of level crit and higher in a special file.
uucp,news.crit                                          /var/log/spooler

# Save boot messages also to boot.log
local7.*                                                /var/log/boot.log
配置文件模块
配置文件查看less /etc/rsyslog.conf。Rsyslog的配置主要有以下模块:

modules，模块，配置加载的模块，如：ModLoad imudp.so配置加载UDP传输模块
global directives，全局配置，配置ryslog守护进程的全局属性，比如主信息队列大小（MainMessageQueueSize）
rules，规则（选择器+动作），每个规则行由两部分组成，selector部分和action部分，这两部分由一个或多个空格或tab分隔，selector部分指定源和日志等级，action部分指定对应的操作
模板（templates）
输出（outputs）
常用的modules
imudp，传统方式的UDP传输，有损耗
imtcp，基于TCP明文的传输，只在特定情况下丢失信息，并被广泛使用
imrelp，RELP传输，不会丢失信息，但只在rsyslogd 3.15.0及以上版本中可用
更多参考
规则（rules）
规则的选择器（selectors）
selector也由两部分组成，设施和优先级，由点号.分隔。第一部分为消息源或称为日志设施，第二部分为日志级别。多个选择器用;分隔，如：*.info;mail.none。

日志设施有：

auth(security), authpriv: 授权和安全相关的消息
kern: 来自Linux内核的消息
mail: 由mail子系统产生的消息
cron: cron守护进程相关的信息
daemon: 守护进程产生的信息
news: 网络消息子系统
lpr: 打印相关的日志信息
user: 用户进程相关的信息
local0 to local7: 保留，本地使用
日志级别有(升序)：

debug：包含详细的开发情报的信息，通常只在调试一个程序时使用。
info：情报信息，正常的系统消息，比如骚扰报告，带宽数据等，不需要处理。
notice： 不是错误情况，也不需要立即处理。
warning： 警告信息，不是错误，比如系统磁盘使用了85%等。
err：错误，不是非常紧急，在一定时间内修复即可。
crit：重要情况，如硬盘错误，备用连接丢失。
alert：应该被立即改正的问题，如系统数据库被破坏，ISP连接丢失。
emerg：紧急情况，需要立即通知技术人员。
日志设施的配置：

. 代表比后面还要高的消息等级都会记录下来
.= 代表只有后面的这个消息等级会被记录下来
.! 代表除了后面的这个消息等级,其他的都会被记录下来，我在rsyslogd 4.6.2中失败了不知道为啥。。
对于多个选择器可以用;分隔。

local0.=debug                /home/admin/applogs/app-name/debug.log
local0.err;local0.warning;local0.info                /home/admin/applogs/app-name/info.log
local0.err                /home/admin/applogs/app-name/error.log
动作 （action）
action是规则描述的一部分，位于选择器的后面，规则用于处理消息。总的来说，消息内容被写到一种日志文件上，但也可以执行其他动作，比如写到数据库表中或转发到其他主机。

在前面的实例中的是写到本地文件中的：

# The authpriv file has restricted access.
authpriv.*                                              /var/log/secure
也可以写到mysql数据库中，

# modules, 要将日志写到mysql中需要加载ommysql模块
$ModLoad ommysql 
# rule, send to mysql
#*.*       :ommysql:database-server,database-name,database-userid,database-password
*.*       :ommysql:127.0.0.1,Syslog,syslogwriter,topsecret
关于配置发送消息到数据库的更多类容可以参考：http://www.rsyslog.com/doc/master/tutorials/database.html

action的配置：

保存到文件，cron.* -/var/log/cron.log如果路径前有-则表示每次输出日志时不同步（fsync）指定日志文件。 文件路径既可以是静态文件也可以是动态文件。动态文件由模板前加 ? 定义。

通过网络发送日志 格式如下： @[()]:[] @ 表示使用 UDP 协议。@@ 表示使用 TCP 协议。 可以为： z 表示使用 zlib 压缩，NUMBER 表示压缩级别。多个选项 使用 , 分隔。 例如： . @192.168.0.1 # 使用 UDP 发送日志到 192.168.0.1 .@@example.com:18 # 使用 TCP 发送到 "example.com" 的 18 端口 . @(z9)[2001::1] # 使用 UDP 发送消息到 2001::1，启用 zlib 9 级压缩

cron.* ~ 丢弃所有信息，即该配置之后的动作不会看到该日志。 随 rsyslog 版本不同，如果有如下警告信息，则将 ~ 修改为 stop。

​

模板（templates）
模板允许你指定日志信息的格式，也可用于生成动态文件名，或在规则中使用。其定义如下所示，其中TEMPLATE_NAME是模板的名字,PROPERTY是rsyslog本身支持的一些属性参数。

$template TEMPLATE_NAME,"text %PROPERTY% more text", [OPTION]
使用例子：

$template DynamicFile,"/var/log/test_logs/%timegenerated%-test.log"
$template DailyPerHostLogs,"/var/log/syslog/%$YEAR%/%$MONTH%/%$DAY%/%HOSTNAME%/messages.log"

*.info ?DailyPerHostLogs
*.* ?DynamicFile
在模板中我们用到的properties可以参考官方文档说明，例子中用到的timegenerated是指接收到消息时的时间戳。

输出（outputs）
输出频道为用户可能想要的输出类型提供了保护，在规则中使用前要先定义.其定义如下所示，其中NAME指定输出频道的名称，FILE_NAME指定输出文件，MAX_SIZE指定日志文件的大小，单位是bytes, ACTION指定日志文件到达MAX_SIZE时的操作。

$outchannel NAME, FILE_NAME, MAX_SIZE, ACTION
在规则中使用输出频道按照如下的格式：

selectors :omfile:$NAME
例子：

$outchannel log_rotation, /var/log/test_log.log, 104857600, /home/joe/log_rotation_script

*.* :omfile:$log_rotation
配置的验证
通过下面命令可以校验配置文件是否配置正确：

sudo rsyslogd -f /etc/rsyslog.conf -N4
其中 -N后面的数值代表rsyslog启动时-c 后指定的版本。

通过下面命令可以手动发送日志信息：

logger -p local0.info "hello world"
日志文件Rotating
随着日志文件越来越大，这不仅会带来性能问题，同时对日志的管理也非常棘手。 当一个日志文件被rotated，会创建一个新的日志文件，同时旧的日志文件会被重命名。这些文件在一段时间内被保留，一旦产生一定数量的旧的日志，系统就会删除一部分旧的日志。

logrotate配置文件实例
logrotate是通过cron任务调用的，在安装的时候就自动创建了，所以通过ps命令看不到logrotate，可查看定时任务调用：cat /etc/cron.daily/logrotate：

#!/bin/sh

/usr/sbin/logrotate /etc/logrotate.conf >/dev/null 2>&1
EXITVALUE=$?
if [ $EXITVALUE != 0 ]; then
    /usr/bin/logger -t logrotate "ALERT exited abnormally with [$EXITVALUE]"
fi
exit 0
cron.daily下的文件执行都是通过/etc/crontab配置的：

$cat /etc/crontab
SHELL=/bin/bash
PATH=/sbin:/bin:/usr/sbin:/usr/bin
MAILTO=root
HOME=/

# For details see man 4 crontabs

# Example of job definition:
# .---------------- minute (0 - 59)
# |  .------------- hour (0 - 23)
# |  |  .---------- day of month (1 - 31)
# |  |  |  .------- month (1 - 12) OR jan,feb,mar,apr ...
# |  |  |  |  .---- day of week (0 - 6) (Sunday=0 or 7) OR sun,mon,tue,wed,thu,fri,sat
# |  |  |  |  |
# *  *  *  *  * user-name command to be executed

0 0 * * * root run-parts /etc/cron.daily #定时执行cron.daily

logrotate的配置文件为/etc/logrotate.conf，下面给一个例子：

# see "man logrotate" for details
# rotate log files weekly
weekly

# keep 4 weeks worth of backlogs
rotate 4

# create new (empty) log files after rotating old ones
create

# uncomment this if you want your log files compressed
#compress

# packages drop log rotation information into this directory
include /etc/logrotate.d

# no packages own wtmp, or btmp -- we'll rotate them here
/var/log/syslog
{
    rotate 7
    daily
    missingok
    notifempty
    delaycompress
    compress
    postrotate
        invoke-rc.d rsyslog reload > /dev/null
    endscript
}
/var/log/cron.log
/var/log/debug
/var/log/messages
{
    rotate 4
    weekly
    missingok
    notifempty
    compress
    delaycompress
    sharedscripts
    postrotate
        invoke-rc.d rsyslog reload > /dev/null
    endscript
}
# system-specific logs may be configured here
syslog的日志文件每天被rotated，保留7份旧的日志。其他的日志文件每周进行一次rotate，并保留4份旧的日志。

logrotate配置项
我们可以通过man logrotate来获取所有的参数和详细描述。这里列出一部分:

daily 指定转储周期为每天
weekly 指定转储周期为每周
monthly 指定转储周期为每月
compress 通过gzip 压缩转储以后的日志
nocompress 不需要压缩时，用这个参数
copytruncate 用于还在打开中的日志文件，把当前日志备份并截断
nocopytruncate 备份日志文件但是不截断
missingok 如果文件不存在，继续下一个文件，不报异常
nomissingok 如果文件不存在，报异常（默认配置）
create mode(文件权限) owner(拥有者) group(组) 转储文件，使用指定的文件模式创建新的日志文件
nocreate 不建立新的日志文件
delaycompress 和 compress 一起使用时，转储的日志文件到下一次转储时才压缩
nodelaycompress 覆盖 delaycompress 选项，转储同时压缩。
errors address 转储时的错误信息发送到指定的Email 地址
ifempty 即使是空文件也转储，(logrotate 的缺省选项)
notifempty 如果是空文件的话，不转储
mail address 把转储的日志文件发送到指定的E-mail 地址
nomail 转储时不发送日志文件
olddir directory 转储后的日志文件放入指定的目录，必须和当前日志文件在同一个文件系统
noolddir 转储后的日志文件和当前日志文件放在同一个目录下
prerotate/endscript 在转储以前需要执行的命令可以放入这个对，这两个关键字必须单独成行
postrotate/endscript 在转储以后需要执行的命令可以放入这个对，这两个关键字必须单独成行
rotate count 指定日志文件删除之前转储的次数，0 指没有备份，5 指保留5 个备份
tabootext [+] LIST 让logrotate 不转储指定扩展名的文件，缺省的扩展名是：.rpm-orig, .rpmsave, v, 和 ~
size SIZE 当日志文件到达指定的大小时才转储，Size 可以指定 bytes (缺省)以及KB (sizek)或者MB (sizem)
实例
sudo vim /etc/rsyslog.conf

# Provides UDP syslog reception
$ModLoad imudp.so
$UDPServerRun 514

$template ipAndMsg,"[%fromhost-ip%]  %$now%%msg%\n"

local0.=debug                /home/admin/applogs/app-name/debug.log;ipAndMsg
local0.err;local0.warning;local0.info                /home/admin/applogs/app-name/info.log;ipAndMsg
local0.err                /home/admin/applogs/app-name/error.log;ipAndMsg
sudo service rsyslog restart

sudo service syslog/syslog-ng stop

sudo vim /etc/logrotate.conf

/home/admin/applogs/app-name/debug.log
/home/admin/applogs/app-name/info.log
/home/admin/applogs/app-name/error.log{
    daily
    create 0664 root root
    rotate 30
    missingok
    nocompress
    notifempty
    dateext
    postrotate
        /etc/init.d/rsyslog restart > /dev/null 2>&1
    endscript
}
注意，最后必须加上：

postrotate
        /etc/init.d/rsyslog restart > /dev/null 2>&1
endscript
因为logrotate之后，即使已经移走了，但是rsyslog还是持有这个文件操作句柄，会继续往原文件（被rotate的文件）中写，即使已经被重命名了，所以需要 restart rsyslog 来 reopen 下 logrotate新创建的同名文件。

另外有一个可以不用重启的办法，但是会丢失部分数据，logrotate 提供了 copytruncate。默认的指令 create 做法，是 移动旧文件，创建新文件，然后用脚本reopen新文件；而 copytruncate 是采用的先拷贝再清空， 先复制一份旧的日志，然后请客原文件，整个过程原来的文件句柄，并没有变化，所以不需要reopen，服务可以不中断，但是这个过程会导致部分数据丢失


