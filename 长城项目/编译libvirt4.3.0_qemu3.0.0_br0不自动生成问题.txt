编译libvirt
  162  2018-09-04 22:29:58  root apt install pkg-config
  164  2018-09-04 22:30:18  root apt install pkg-dev
  167  2018-09-04 22:32:04  root apt install libnl-3-dev ###注意，如果pkg-config不安装则这个包的头文件是没有办法找到的
  168  2018-09-04 22:32:25  root apt install libnl-route-3-dev -y
  170  2018-09-04 22:32:56  root apt install libdevmapper-dev
  175  2018-09-04 22:38:41  root apt-cache rdepends libselinux1-dev
  179  2018-09-04 22:42:40  root apt search libxml2
  180  2018-09-04 22:43:45  root apt install libxml2-dev
  185  2018-09-04 22:46:05  root apt install libyajl-dev
  186  2018-09-04 22:46:34  root apt remove libyajl2
  187  2018-09-04 22:46:44  root apt install libyajl-dev
  189  2018-09-04 22:48:43  root apt search xmllint
  190  2018-09-04 22:48:59  root apt install libxml2-utils
  192  2018-09-04 22:51:42  root apt search xsltproc
  193  2018-09-04 22:52:00  root apt install xsltproc
  197  2018-09-04 22:56:09  root apt-cache rdepends libselinux1-dev
  198  2018-09-04 22:56:19  root apt remove libselinux1-dev
  201  2018-09-04 23:06:24  root apt-get install libpciaccess-dev
  202  2018-09-04 23:06:46  root apt-cache rdepends libpciaccess0
  203  2018-09-04 23:07:08  root apt remove libpciaccess0
  204  2018-09-04 23:07:17  root apt-get install libpciaccess-dev
  205  2018-09-04 23:07:27  root ./configure 

编译qemu
    4  ./configure --enable-kvm --disable-xen --disable-xen-pci-passthrough
    5  apt install python2-pip
    6  apt install pip
    7  aptitude search pip
    8  aptitude install python3-pip
    9  ./configure --enable-kvm --disable-xen --disable-xen-pci-passthrough
   10  apt search Python
   11  aptitude install python
   12  ./configure --enable-kvm --disable-xen --disable-xen-pci-passthrough
   13  apt install zlib
   14  apt search zlib
   15  aptitude install zlib1g-dev
   16  ./configure --enable-kvm --disable-xen --disable-xen-pci-passthrough
   17  apt search glib
   18  aptitude install libnglib-dev
   19  history 
   20  ./configure --enable-kvm --disable-xen --disable-xen-pci-passthrough
   21  apt search glib
   22  apt search glib | grep glib
   23  apt install libglibmm-2.4-dev
   24  ./configure --enable-kvm --disable-xen --disable-xen-pci-passthrough
   25  apt search pixman
   26  apt install libpixman-1-dev
   27  ./configure --enable-kvm --disable-xen --disable-xen-pci-passthrough
   
启动Libvirtd时不自动生成default网桥virtbr0
	手动生成virtbr0，找到libvirt安装时的default.xml
	1、virsh net-define /usr/local/etc/libvirt/qemu/network/default.xml
	2、virsh net-start default
		报错：
			error: Failed to start domain kvm1
			error: Network not found: no network with matching name 'default'
	3、安装一些依赖组件
		apt install firewalld ebtables iptables
		systemctl restart libvirtd
	4、virsh net-start default
	5、virsh net-autostart default
	
	
	