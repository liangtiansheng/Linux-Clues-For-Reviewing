1. expect命令

expect 语法：
expect [选项] [ -c cmds ] [ [ -[f|b] ] cmdfile ] [ args ]
选项
    -c：从命令行执行expect脚本，默认expect是交互地执行的
        示例：expect -c 'expect "\n" {send "pressed enter\n"} '

        [root@localhost ~]# expect -c 'expect "\n" {send "pressed enter\n"}' 
        
        pressed enter
    -d：可以输出输出调试信息
         示例：expect -d ssh.exp

expect中相关命令
    spawn：启动新的进程
    send：用于向进程发送字符串
    expect：从进程接收字符串
    interact：允许用户交互
    exp_continue 匹配多个字符串在执行动作后加此命令

2. expect语法

expect最常用的语法(tcl语言:模式-动作)
单一分支模式语法：
    expect "hi"  {send "You said hi\n"}

    匹配到hi后，会输出“you said hi”，并换行 
    [root@localhost ~]# expect -c 'expect "hi" {send "You said hi\n"}'
    hi
    You said hi
    [root@localhost html]# expect 
    expect1.1> expect "hi"  {send "You said hi\n"}
    hi
    You said hi
多分支模式语法：
    expect "hi" { send "You said hi\n" }  "hehe" { send "Hehe yourself\n" }  "bye" { send "Good bye\n" }
    [root@localhost html]# expect 
    expect1.1> expect "hi" { send "You said hi\n" } "hehe" { send "Hehe yourself\n" } "bye" { send "Good bye\n" } 
    hi
    You said hi
    expect1.2> expect "hi" { send "You said hi\n" } "hehe" { send "Hehe yourself\n" } "bye" { send "Good bye\n" } 
    hehe
    Hehe yourself
    expect1.3> expect "hi" { send "You said hi\n" } "hehe" { send "Hehe yourself\n" } "bye" { send "Good bye\n" } 
    bye
    Good bye

3. 实例

自动拷贝scp
    #!/usr/bin/expect
    spawn scp /etc/fstab wht@172.20.110.199:/home/wht/ 
    expect {
        "yes/no" { send "yes\n";exp_continue }
        "password" { send "123456wht\n" }
    }
    expect eof

自动登录ssh
    #!/usr/bin/expect 
    spawn ssh 172.20.110.199
    expect { 
        "password" { send "123456wht\n" } 
    }
    interact      #登录成功后，会保持登录的状态不会主动退出
    #expect eof #用这个会自动退出

变量
    #!/usr/bin/expect
    set ip 172.20.110.199
    set user root
    set password 123456wht 
    set timeout 10 
    spawn ssh $ip
    expect { 
        "password" { send "$password\n" } 
    }
    interact
    #expect eof

位置参数
    #!/usr/bin/expect 
    set ip [lindex $argv 0] 
    set user [lindex $argv 1] 
    set password [lindex $argv 2] 
    spawn ssh $user@$ip 
    expect { 
    "yes/no" { send "yes\n";exp_continue } 
    "password" { send "$password\n" } 
    } 
    interact 
    #./ssh3.exp 192.168.8.100 root magedu

执行多个命令
    #!/usr/bin/expect 
    set ip [lindex $argv 0] 
    set user [lindex $argv 1] 
    set password [lindex $argv 2] 
    set timeout 10 
    spawn ssh $user@$ip 
    expect { 
    "yes/no" { send "yes\n";exp_continue } 
    "password" { send "$password\n" } 
    } 
    expect "]#" { send "useradd test\n" } 
    expect "]#" { send "echo magedu |passwd --stdin test\n" } 
    send "exit\n" 
    expect eof 
    #./ssh4.exp 172.20.110.199 root 123456wht

shell脚本调用expect
自动在多台主机创建用户test，并设置初始口令
expect 自动在多台主机创建用户test，并设置初始口令
    #!/bin/bash
    #expect 自动在多台主机创建用户test，并设置初始口令(读取文件)
    ssdzd(){
    expect <<-EOF # 如果重定向的操作符是<<-，那么分界符（EOF）所在行的开头部分的制表符（Tab）都将被去除。
    set timeout 10 
    spawn ssh $user@$ip 
    expect { 
    "yes/no" { send "yes\n";exp_continue } 
    "password" { send "$password\n" } 
    } 
    expect "]#" { send "useradd test\n" } 
    expect "]#" { send "echo 123456thw |passwd --stdin test\n" } 
    expect "]#" { send "exit\n" } 
    expect eof 
    EOF
    }
    a=`cat /root/passwd|wc -l`
    echo $a
    for i in `seq $a` ; do
    echo $i
    ip=`cat /root/passwd|head -n $i|tail -n 1|cut -d : -f 1`
    user=`cat /root/passwd|head -n $i|tail -n 1|cut -d : -f 2`
    password=`cat /root/passwd|head -n $i|tail -n 1|cut -d : -f 3` 
    ssdzd
    done

expect 自动在多台主机创建用户test，并设置初始口令
    #!/bin/bash
    #自动在多台主机创建用户test，并设置初始口令(脚本文件写入user，ip，password)
    ssdzd(){
    expect <<-EOF 
    set timeout 10 
    spawn ssh $user@$ip 
    expect { 
    "yes/no" { send "yes\n";exp_continue } 
    "password" { send "$password\n" } 
    } 
    expect "]#" { send "useradd test1\n" } 
    expect "]#" { send "echo 123456thw |passwd --stdin test1\n" } 
    expect "]#" { send "exit\n" } 
    expect eof 
    EOF
    }
    cat >> /root/passwd.txt << EOF
    172.20.110.199:root:123456wht
    172.20.108.143:root:123456wht
    EOF
    DIR=/root/passwd.txt
    a=`cat $DIR|wc -l`
    for i in `seq $a` ; do
    ip=`cat $DIR|head -n $i|tail -n 1|cut -d : -f 1`
    user=`cat $DIR|head -n $i|tail -n 1|cut -d : -f 2`
    password=`cat $DIR|head -n $i|tail -n 1|cut -d : -f 3` 
    ssdzd
    done
    >$DIR

