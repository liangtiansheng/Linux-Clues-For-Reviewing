# 概念
> 1. 云计算时代，libvirt成为横向扩展最重要的库之一   
> 2. libvirt 提供一种虚拟机监控程序不可知的 API 来安全管理运行于主机上的来宾操作系统   
> 3. libvirt 本身 不是一种工具， 它是一种可以建立工具来管理来宾操作系统的 API   
> 4. libvirt 本身构建于一种抽象的概念之上。它为受支持的虚拟机监控程序实现的常用功能提供通用的 API   
> 5. libvirt 起初是专门为 Xen 设计的一种管理 API，后来被扩展为可支持多个虚拟机监控程序
>> 1. KVM
>> 2. Xen
>> 3. VMware
>> 4. QEMU
>> 5. VirtualBox
>> 6. OTHERS

# 基本架构
> 1. 首先让我们从用例模型视角来展开对 libvirt 的讨论，然后深入探究其架构和用途。libvirt 以一组 API 的形式存在，旨在供管理应用程序使用(如下图1)。libvirt 通过一种特定于虚拟机监控程序的机制与每个有效虚拟机监控程序进行通信，以完成 API 请求。文章后面我将探讨如何通过 QEMU 来实现该功能。   
图 1. libvirt 比较和用例模型   
![libvirt 比较和用例模型](./images/libvirt比较和用例模型.png)
> 2. 图中还显示了 libvirt 所用术语对照。这些术语很重要，因为在对 API 命名时会用到它们。两个根本区别在于，libvirt 将物理主机称作节点，将来宾操作系统称作域。这里需要注意的是，libvirt（及其应用程序）在宿主 Linux 操作系统（域 0）中运行。   

## 控制方式
> 1. 使用 libvirt，我们有两种不同的控制方式。第一种如 图 1 所示，其中管理应用程序和域位于同一节点上。 在本例中，管理应用程序通过 libvirt 工作，以控制本地域。当管理应用程序和域位于不同节点上时，便产生了另一种控制方式。在本例中需要进行远程通信（参见 图 2）。   
> 2. 该模式使用一种运行于远程节点上、名为 libvirtd 的特殊守护进程。当在新节点上安装 libvirt 时该程序会自动启动，且可自动确定本地虚拟机监控程序并为其安装驱动程序（稍后讨论）。   
> 3. 该管理应用程序通过一种通用协议从本地 libvirt 连接到远程 libvirtd。对于 QEMU，协议在 QEMU 监视器处结束。QEMU 包含一个监测控制台，它允许检查运行中的来宾操作系统并控制虚拟机（VM）各部分。   
图 2. 使用 libvirtd 控制远程虚拟机监控程序    
![使用 libvirtd 控制远程虚拟机监控程序](./images/使用libvirtd控制远程虚拟机监控程序.png)

## 虚拟机监控程序支持
> 1. 为支持各种虚拟机监控程序的可扩展性，libvirt 实施一种基于驱动程序的架构，该架构允许一种通用的 API 以通用方式为大量潜在的虚拟机监控程序提供服务。这意味着，一些虚拟机监控程序的某些专业功能在 API 中不可见。   
> 2. 另外，有些虚拟机监控程序可能不能实施所有 API 功能，因而在特定驱动程序内被定义为不受支持。图 3 展示了 libvirt API 与相关驱动程序的层次结构。这里也需要注意，libvirtd 提供从远程应用程序访问本地域的方式。    
图 3. 基于驱动程序的 libvirt 架构     
![基于驱动程序的 libvirt 架构](./images/使用libvirtd控制远程虚拟机监控程序.png)
> 3. 在撰写此文时，libvirt 为表 1 所列的虚拟机监控程序实现了驱动程序。随着新的虚拟机监控程序在开源社区出现，其他驱动程序无疑也将可用。   

表 1. libvirt 支持的虚拟机监控程序   

虚拟机监控程序|	描述
-------------|---------
Xen|	面向 IA-32，IA-64 和 PowerPC 970 架构的虚拟机监控程序
QEMU|	面向各种架构的平台仿真器
Kernel-based Virtual Machine (KVM)|	Linux 平台仿真器
Linux Containers（LXC）|	用于操作系统虚拟化的 Linux（轻量级）容器
OpenVZ|	基于 Linux 内核的操作系统级虚拟化
VirtualBox|	x86 虚拟化虚拟机监控程序
User Mode Linux|	面向各种架构的 Linux 平台仿真器
Test|	面向伪虚拟机监控程序的测试驱动器
Storage|	存储池驱动器（本地磁盘，网络磁盘，iSCSI 卷）

# libvirt 和虚拟 shell
> 1. 上面已经介绍了 libvirt 的一些架构，接下来看一下如何使用 libvirt 虚拟化 API 的一些示例。首先介绍一种名为 virsh（虚拟 shell）的应用程序，它构建于 libvirt 之上。该 shell 允许以交互（基于 shell）方式使用多个 libvirt 功能。在本节中，我使用 virsh 演示了一些 VM 操作。   
> 2. 第一步是要定义域配置文件（如下面的 清单 1 所示）。该代码指定了定义域所需的所有选项 — 从虚拟机监控程序（仿真器）到域使用的资源以及外围配置（比如网络）。注意，这只是个简单的配置，libvirt 真正支持的属性更加多样化。例如，您可以指定 BIOS 和主机引导程序，域要使用的资源，以及要用到的设备 — 从软盘和 CD-ROM 到 USB 和 PCI 设备。   
> 3. 域配置文件定义该 QEMU 域要使用的一些基本元数据，包括域名、最大内存、初始可用内存（当前）以及该域可用的虚拟处理器数量。您不需要自己分配 Universally Unique Idenifier (UUID)，而是让 libvirt 分配。您需要为该平台定义要仿真的机器类型 — 在本例中是被完全虚拟化（hvm）的 686 处理器。您需要为域定义仿真器的位置（以备需要支持多个同类型仿真器时使用）和虚拟磁盘。这里注意要指明 VM，它是以 Virtual Machine Disk（VMDK）格式存在的 ReactOS 操作系统。最后，要指定默认网络设置，并使用面向图形的 Virtual Network Computing (VNC)。   

清单 1. 域配置文件   

```bash
<domain type='kvm'>
  <name>demo</name>
  <memory>524288</memory>
  <vcpu>1</vcpu>
  <os>
    <type arch='x86_64' machine='pc'>hvm</type>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <clock offset='localtime'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <devices>
    <emulator>/usr/bin/kvm</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/root/another/cirros-0.3.0-x86_64-disk.img'/>
      <target dev='hda' bus='ide'/>
    </disk>
    <graphics type="vnc" autoport="yes" keymap="en-us" listen="0.0.0.0"/>
  </devices>
</domain>
```
**亲测可以启动实例，这是一个非常简单的xml定义文件，没有console口，也没有网卡**

**改进,加入网卡,从console口可以登陆,注意嵌套的位置**

```bash
<domain type='kvm'>
  <name>demo</name>
  <memory>524288</memory>
  <vcpu>1</vcpu>
  <os>
    <type arch='x86_64' machine='pc'>hvm</type>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <clock offset='localtime'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <devices>
    <emulator>/usr/bin/kvm</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/root/another/cirros-0.3.0-x86_64-disk.img'/>
      <target dev='hda' bus='ide'/>
    </disk>
    <graphics type="vnc" autoport="yes" keymap="en-us" listen="0.0.0.0"/>
    <interface type='network'>
      <mac address='52:54:00:b5:24:00'/>
      <source network='default'/>
      <model type='rtl8139'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
  </devices>
</domain>
```

**另外，这里要提示一下，想用virsh console ID进入实例，必须要满足以下条件**

1. 添加ttyS0的安全许可，允许root登录：   
```bash
# echo "ttyS0" >> /etc/securetty
```
2. 给内核传递参数console=ttyS0,115200

根据你用的发行版本不同，添加方式不同，RHEL6以前的grub配置很简单，直接在/etc/grub.conf中找到kernel这行，在末尾加入上述参数即可

如果是RHEL7以后的版本，或者说用的是grub2版本，grub.conf是自动生成的，给内核传递参数最简单的方式是在/etc/default/grub中找到GRUB_CMDLINE_LINUX=""，将上述参数写在这个引号中即可，同时执行grub2-mkconfig -o /boot/grub2/grub.cfg或者update-grub2

3. 如果是RHEL7+到此为止，如果是RHEL6-则添加如下行

```bash
S0:12345:respawn:/sbin/agetty ttyS0 115200
```

**以下是完整版**

```bash
<!--
WARNING: THIS IS AN AUTO-GENERATED FILE. CHANGES TO IT ARE LIKELY TO BE
OVERWRITTEN AND LOST. Changes to this xml configuration should be made using:
  virsh edit generic
or other application using the libvirt API.
-->

<domain type='qemu'>
  <name>cirros</name>
  <uuid>613003c2-2930-4eba-8142-83a99a0b72a7</uuid>
  <memory unit='KiB'>3096576</memory>
  <currentMemory unit='KiB'>3096576</currentMemory>
  <vcpu placement='static'>2</vcpu>
  <os>
    <type arch='x86_64' machine='pc-i440fx-xenial'>hvm</type>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <cpu mode='custom' match='exact'>
    <model fallback='allow'>Nehalem</model>
  </cpu>
  <clock offset='utc'>
    <timer name='rtc' tickpolicy='catchup'/>
    <timer name='pit' tickpolicy='delay'/>
    <timer name='hpet' present='no'/>
  </clock>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <pm>
    <suspend-to-mem enabled='no'/>
    <suspend-to-disk enabled='no'/>
  </pm>
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='/root/cirros-0.3.6-x86_64-disk.img'/>
      <target dev='hda' bus='ide'/>
      <address type='drive' controller='0' bus='0' target='0' unit='0'/>
    </disk>
    <controller type='usb' index='0' model='ich9-ehci1'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x7'/>
    </controller>
    <controller type='usb' index='0' model='ich9-uhci1'>
      <master startport='0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0' multifunction='on'/>
    </controller>
    <controller type='usb' index='0' model='ich9-uhci2'>
      <master startport='2'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x1'/>
    </controller>
    <controller type='usb' index='0' model='ich9-uhci3'>
      <master startport='4'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x2'/>
    </controller>
    <controller type='pci' index='0' model='pci-root'/>
    <controller type='ide' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/>
    </controller>
    <controller type='virtio-serial' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </controller>
    <interface type='network'>
      <mac address='52:54:00:b5:24:58'/>
      <source network='default'/>
      <model type='rtl8139'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <channel type='spicevmc'>
      <target type='virtio' name='com.redhat.spice.0'/>
      <address type='virtio-serial' controller='0' bus='0' port='1'/>
    </channel>
    <input type='mouse' bus='ps2'/>
    <input type='keyboard' bus='ps2'/>
    <graphics type='spice' autoport='yes'>
      <image compression='off'/>
    </graphics>
    <sound model='ich6'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </sound>
    <video>
      <model type='qxl' ram='65536' vram='65536' vgamem='16384' heads='1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>
    <redirdev bus='usb' type='spicevmc'>
    </redirdev>
    <redirdev bus='usb' type='spicevmc'>
    </redirdev>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>
    </memballoon>
  </devices>
</domain>
```

> 4. 完成了域配置文件之后，现在开始使用 virsh 工具启动域。virsh 工具为要执行的特定动作采用命令参数。在启动新域时，使用 create 命令和域配置文件：   

清单 2. 启动新域    

```bash
root@ly-virtual-machine:~# virsh create instance.xml
Domain cirros created from instance.xml

root@ly-virtual-machine:~#

```
> 5. 这里要注意用于连接到域（qemu:///system）的 Universal Resource Indicator (URI)。该本地 URI 连接到本地 QEMU 驱动程序的系统模式守护进程上。要通过主机 shinchan 上的 Secure Shell (SSH) 协议连接到远程 QEMU 虚拟机监控程序，可以使用 URL qemu+ssh://shinchan/。   
> 6. 下一步，您可以使用 virsh 内的 list 命令列出给定主机上的活动域。这样做可以列出活动域，域 ID，以及它们的状态，如下所示：   

清单 3. 列出活动域   

```bash
root@ly-virtual-machine:~# virsh list
 Id    Name                           State
----------------------------------------------------
 5     generic                        running
 11    cirros                         running
 16    demo                           running

root@ly-virtual-machine:~#

```
> 7. 注意，这里定义的名称是在域配置文件元数据中定义过的名称。可以看到，该域的域名是 1 且正在运行中。   
> 8. 您也可以使用 suspend 命令中止域。该命令可停止处于调度中的域，不过该域仍存在于内存中，可快速恢复运行。下面的例子展示了如何中止域，执行列表查看状态，然后重新启动域：   

清单 4. 中止域，检查状态，并重新启动   

```bash
root@ly-virtual-machine:~# virsh list
 Id    Name                           State
----------------------------------------------------
 5     generic                        running
 11    cirros                         running
 16    demo                           running

root@ly-virtual-machine:~# virsh suspend 11
Domain 11 suspended

root@ly-virtual-machine:~# virsh list
 Id    Name                           State
----------------------------------------------------
 5     generic                        running
 11    cirros                         paused
 16    demo                           running

root@ly-virtual-machine:~# virsh resume 11
Domain 11 resumed

root@ly-virtual-machine:~# virsh list
 Id    Name                           State
----------------------------------------------------
 5     generic                        running
 11    cirros                         running
 16    demo                           running

root@ly-virtual-machine:~# 

```
> 9. virsh 工具也支持许多其他命令，比如保存域的命令（save），恢复已存域的命令（restore），重新启动域的命令（reboot），以及其他命令。您还可以从运行中的域（dumpxml）创建域配置文件。   
> 10. 到目前为止，我们已经启动并操作了域，但是如何连接域来查看当前活动域呢？这可以通过 VNC 实现。要创建表示特定域图形桌面的窗口，可以使用 VNC：   

清单 5. 连接到域   

```bash
root@ly-virtual-machine:~# virsh list
 Id    Name                           State
----------------------------------------------------
 3     generic                        running

root@ly-virtual-machine:~# xvnc4viewer :0

VNC Viewer Free Edition 4.1.1 for X - built Feb 25 2015 22:57:51
Copyright (C) 2002-2005 RealVNC Ltd.
See http://www.realvnc.com for information on VNC.

Sat Jan 19 15:33:44 2019
 CConn:       connected to host localhost port 5900
 CConnection: Server supports RFB protocol version 3.8
 CConnection: Using RFB protocol version 3.8
 TXImage:     Using default colormap and visual, TrueColor, depth 24.
 CConn:       Using pixel format depth 6 (8bpp) rgb222
 CConn:       Using ZRLE encoding

```

**注意：上面的xml文件中定义的图形界面是spice，这里用的是vnc所以要改成<graphics type='vnc' port='-1'/>**

**注意，以此处为界，上述都实验成功，以下由于版本原因加上不熟悉开发领域，未曾成功实验**

# libvirt 和 Python
> 1. 上一个例子说明了如何使用命令行工具 virsh 实现对域的控制。现在我们看一个使用 Python 来控制域的例子。Python 是受 libvirt 支持的脚本语言，它向 libvirt API 提供完全面向对象的接口。   
> 2. 在本例中，我研究了一些基本操作，与之前用 virsh 工具（list、suspend、resume 等）展示的操作类似。Python 示例脚本见 清单 6。在本例中，我们从导入 libvirt 模块开始。然后连接到本地 QEMU 虚拟机监控程序。从这里开始，重复可用的域 ID；对每个 ID 创建一个域对象，然后中止，继续，最后删除该域。   

清单 6. 用于控制域的示例 Python 脚本（libvtest.py）   

```bash
import libvirt
 
conn = libvirt.open('qemu:///system')
 
for id in conn.listDomainsID():
 
    dom = conn.lookupByID(id)
 
    print "Dom %s  State %s" % ( dom.name(), dom.info()[0] )
 
    dom.suspend()
    print "Dom %s  State %s (after suspend)" % ( dom.name(), dom.info()[0] )
 
    dom.resume()
    print "Dom %s  State %s (after resume)" % ( dom.name(), dom.info()[0] )
 
    dom.destroy()
```
> 3. 虽然这只是个简单示例，我们仍然可以看到 libvirt 通过 Python 提供的强大功能。通过一个简单的脚本就能够重复所有本地 QEMU 域，发行有关域的信息，然后控制域。该脚本的结果如 清单 7 所示。   

清单 7. 清单 6 中的 Python 脚本输出的结果   

```bash
mtj@mtj-desktop:~/libvtest$ python libvtest.py
Dom ReactOS-on-QEMU  State 1
Dom ReactOS-on-QEMU  State 3 (after suspend)
Dom ReactOS-on-QEMU  State 1 (after resume)
mtj@mtj-desktop:~/libvtest$
```

# API 概述
> 1. 高级 libvirt API 可划分为 5 个 API 部分：虚拟机监控程序连接 API、域 API、网络 API、存储卷 API 以及存储池 API。   
> 2. 为给定虚拟机监控程序创建连接后会产生所有 libvirt 通信（例如，清单 6 中所示的 open 调用）。该连接为所有其他要使用的 API 提供路径。在 C API 中，该行为通过 virConnectOpen 调用（以及其他进行认证的调用）提供。这些函数的返回值是一个 virConnectPtr 对象，它代表到虚拟机监控程序的一个连接。该对象作为所有其他管理功能的基础，是对给定虚拟机监控程序进行并发 API 调用所必需的语句。重要的并发调用是 virConnectGetCapabilities 和 virNodeGetInfo，前者返回虚拟机监控程序和驱动程序的功能，后者获取有关节点的信息。该信息以 XML 文档的形式返回，这样通过解析便可了解可能发生的行为。   
> 3. 进入虚拟机监控程序后，便可以使用一组 API 调用函数重复使用该虚拟机监控程序上的各种资源。virConnectListDomains API 调用函数返回一列域标识符，它们代表该虚拟机监控程序上的活动域。   
> 4. API 实现大量针对域的函数。要探究或管理域，首先需要一个 virDomainPtr 对象。您可通过多种方式获得该句柄（使用 ID、UUID 或域名）。继续来看重复域的例子，您可以使用该函数返回的索引表并调用 virDomainLookupByID 来获取域句柄。有了该域句柄，就可以执行很多操作，从探究域（virDomainGetUUID、virDomainGetInfo、virDomainGetXMLDesc、virDomainMemoryPeek）到控制域（virDomainCreate、virDomainSuspend、virDomainResume、virDomainDestroy 和 virDomainMigrate）。   
> 5. 您还可使用 API 管理并检查虚拟网络和存储资源。建立了 API 模型之后，需要一个 virNetworkPtr 对象来管理并检查虚拟网络，且需要一个 virStoragePoolPtr（存储池）或 virStorageVolPtr（卷）对象来管理这些资源。   
> 6. API 还支持一种事件机制，您可使用该机制注册为在特定事件（比如域的启动、中止、恢复或停止）发生时获得通知。

# 语言绑定
> libvirt 库用 C （支持 C++）实现，且包含对 Python 的直接支持。不过它还支持大量语言绑定。目前已经对 Ruby、Java™ 语言，Perl 和 OCaml 实施了绑定。在从 C# 调用 libvirt 方面我们已做了大量工作。libvirt 支持最流行的系统编程语言（C 和 C++）、多种脚本语言、甚至一种统一的函数型语言（Objective caml）。因此，不管您侧重何种语言，libvirt 都会提供一种路径来帮助您控制域。   

# 使用 libvirt 的应用程序
> 1. 仅从本文已经展示的一小部分功能上便可看出 libvirt 提供的强大功能。且如您所愿，有大量应用程序正成功构建于 libvirt 之上。其中一个有趣的应用程序就是 virsh（这里所示），它是一种虚拟 shell。还有一种名为 virt-install 的应用程序，它可用于从多个操作系统发行版供应新域。virt-clone 可用于从另一个 VM 复制 VM（既包括操作系统复制也包括磁盘复制）。一些高级应用程序包括多用途桌面管理工具 virt-manager 和安全连接到 VM 图形控制台的轻量级工具 virt-viewer。   
> 2. 构建于 libvirt 之上的一种最重要的工具名为 oVirt。oVirt VM 管理应用程序旨在管理单个节点上的单个 VM 或多个主机上的大量 VM。除了可以简化大量主机和 VM 的管理之外，它还可用于跨平台和架构自动化集群，负载平衡和工作。   

# 深入探究
> 从这篇简短的文章可以看出，libvirt 是一种用来构建应用程序的强大库，能够跨系统的大型网络在不同的虚拟机监控程序环境中管理域。鉴于云计算的日渐流行，libvirt 无疑也会随之发展，不断获得新的应用程序和用户。撰写本文时，libvirt 也仅有四年的发展史，因此在大规模可伸缩计算领域中相对较新。libvirt 将来肯定会有很大发展。










