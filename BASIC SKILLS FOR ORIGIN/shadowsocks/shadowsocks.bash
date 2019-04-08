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



