# 注意这个配置文件既可以作为ssserver启动服务端的配置文件，也可以作为sslocal启动客户端的配置文件
# 其中server指的就是服务端的地址和端口，local指的就是客户端的地址和端口
[root@yidam ~]# cat /etc/shadowsocks/shadowsocks.json 
{
    "server":"103.214.68.158",  
    "server_port":13203,  
    "local_address": "127.0.0.1", 
    "local_port":1080,  
    "password":"yl109713", 
    "timeout":300,  
    "method":"rc4-md5",  
    "fast_open": false,  
    "workers": 1  
}
[root@yidam ~]# cat /etc/systemd/system/shadowsocks.service 
[Unit]
Description=Shadowsocks
[Service]
TimeoutStartSec=0
ExecStart=/usr/local/bin/sslocal -c /etc/shadowsocks/shadowsocks.json
[Install]
WantedBy=multi-user.target
[root@yidam ~]# 


[root@yidam ~]# cat /etc/privoxy/config | grep -v ^#
confdir /etc/privoxy
logdir /var/log/privoxy
actionsfile match-all.action # Actions that are applied to all sites and maybe overruled later on.
actionsfile default.action   # Main actions file
actionsfile user.action      # User customizations
filterfile default.filter
filterfile user.filter      # User customizations
logfile logfile
listen-address  10.0.0.88:8118
toggle  1
enable-remote-toggle  0
enable-remote-http-toggle  0
enable-edit-actions 0
enforce-blocks 0
buffer-limit 4096
enable-proxy-authentication-forwarding 0
forward-socks5t   /               127.0.0.1:1080 .
forwarded-connect-retries  0
accept-intercepted-requests 0
allow-cgi-request-crunching 0
split-large-forms 0
keep-alive-timeout 5
tolerate-pipelining 1
socket-timeout 300
[root@yidam ~]#



