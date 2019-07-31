ubuntu上编译：
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

centos7上编译：
    编译qemu:
        # yum install zlib-devel.i686 glib2-devel pixman-devel gcc -y
        # wget https://download.qemu.org/qemu-2.11.0.tar.xz
        # tar xf qemu-2.11.0.tar.xz
        # cd qemu-2.11.0/
        # ./configure --help 可以查看编译的格式，支持的功能等，其中的--target-list=LIST是指定编译后支持的模拟架构默认支持所有，编译时间长
        # ./configure --target-list=aarch64-softmmu
        # make
        # make install
    编译完成后，要模似aarch64是必须要有UEFI支持的
    方法1：直接用命令行启动
        # wget http://releases.linaro.org/components/kernel/uefi-linaro/16.02/release/qemu64/QEMU_EFI.fd
        # qemu-system-aarch64 -m 2048 -cpu cortex-a57 -smp 2 -M virt -bios QEMU_EFI.fd -nographic -drive if=none,file=ubuntu-16.04.3-server-arm64.iso,id=cdrom,media=cdrom -device virtio-scsi-device -device scsi-cd,drive=cdrom -drive if=none,file=ubuntu16.04-arm64.img,id=hd0 -device virtio-blk-device,drive=hd0
	
	方法2：用virt-manager实现，可以参考fedora官方的文档https://fedoraproject.org/wiki/Using_UEFI_with_QEMU
        # wget https://www.kraxel.org/repos/jenkins/edk2/edk2.git-aarch64-0-20190704.1169.gb3d00df69c.noarch.rpm

        或者：
        # 进入 https://www.kraxel.org/repos/ 可以发现有针对aarch64和x86架构的UEFI固件，针对性的下载
        # cd /etc/yum.repo.d/
        # wget https://www.kraxel.org/repos/firmware.repo
        # yum install edk2.git-aarch64
        # ls /usr/share/edk2.git/aarch64/
          QEMU_EFI.fd  QEMU_EFI-pflash.raw  QEMU_VARS.fd  vars-template-pflash.raw
        # 安装edk2.git-aarch64生成这四个关键文件
        # 在 /etc/libvirt/qemu.conf 中通过下面字段指出UEFI固件的位置
            nvram = [
            "/usr/share/edk2.git/aarch64/QEMU_EFI-pflash.raw:/usr/share/edk2.git/aarch64/vars-template-pflash.raw"
            ]
        # systemctl restart libvirtd
        # virt-manager启动图形界面直接操作
    
    ***使用virt-manager 选择aarch64出现的问题
    问题1：
        qemu-system-aarch64: -sandbox on,obsolete=deny,elevateprivileges=deny,spawn=deny,resourcecontrol=deny: seccomp support is disabled
    分析1：
        有用的信息是seccomp support is disabled， 根据这个可以推测qemu在编译时是不是没有启用某个功能，configure源码分析
        其中有一段说明如下，意思是默认情况下，所有的功能参数都会被赋予一个默认值，默认值有no（不编译，除非enable指定）,""（为空，搜索有没有编译环境，有就编译，没有就不编译）,yes（默认编译，搜索编译环境，没有就报错）
        # Default value for a variable defining feature "foo".
        #  * foo="no"  feature will only be used if --enable-foo arg is given
        #  * foo=""    feature will be searched for, and if found, will be used
        #              unless --disable-foo is given
        #  * foo="yes" this value will only be set by --enable-foo flag.
        #              feature will searched for,
        #              if not found, configure exits with error
        #
        # Always add --enable-foo and --disable-foo command line args.
        # Distributions want to ensure that several features are compiled in, and it
        # is impossible without a --enable-foo that exits if a feature is not found.
        而seccomp的默认设置是seccomp=""，很显然会搜索编译环境，也就是有没有安装libseccomp和libxeccomp-devel，有就编译，没有就不编译，很显然系统没有安装，也就不编译，出现上述问题
    解决：
        # 安装 libseccomp 和 libseccomp-devel
        # 编译 qemu 显式指定--enable-seccomp
        # 可以重编译覆盖

    问题2：
        qemu-system-aarch64: Initialization of device cfi.pflash01 failed: failed to read the initial flash content
    分析2：
        不好定位问题，经过多次尝试，发现是低级错误，在 /var/lib/libvirt/images/ 下的镜像不能重名，否则就会报以上错误
    解决：
        用virt-manager创建虚拟机时，要记得更改镜像名字












