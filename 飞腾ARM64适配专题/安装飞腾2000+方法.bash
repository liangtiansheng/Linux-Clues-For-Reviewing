1 uncompress this CentOS75-1806-ft1500a.tar.gz under the root of USB disk with vfat filesystem
2 relabel the USB disk with "CENTOS75"
3 boot from UEFI, run fs0:\EFI\BOOT\grubaa64.efi
4 choose a grub configeration according to your hardware
5 execute the normal process of CentOS 7.x installation
6 if your UEFI does NOT provide DTB infomation through FDT, please install the dtb directory under the root of the USB disk to /boot partition, and modify /boot/efi/EFI/centos/grub.cfg, when all the intallation process finished, and then reboot the system
7 enjoy the CentOS 7.5 1806 aarch64 for FT1500a edition
8 any feedback, please sendto euroford@qq.com

用在ft2000+上，请阅读下文
注意：把 linux /images/pxeboot/vmlinuz console=ttyS1,115200 earlycon=uart8250,mmio32,0x70001000 inst.stage2=hd:LABEL=CENTOS75 ro inst.graphical video=efifb:off 换成 linux /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=CENTOS75 ro inst.graphical video=efifb:off
常识：内存映射输入输出（英语：Memory-mapped I/O, MMIO，简称为内存映射IO），以及端口映射输入输出（port-mapped I/O, PMIO，也叫作独立输入输出（isolated I/O），是PC机在中央处理器（CPU）和外部设备之间执行输入输出操作的两种方法，这两种方法互为补充。除此之外，执行输入输出操作也可以使用专用输入输出处理器（dedicated I/O processors）——这通常是指大型电脑上的通道输入输出（Channel I/O），这些专用处理器执行自有的指令集。
原因：ft1500a的内存地址映射人为设置偏移，所以要自己手动指定，ft2000plus用的是标准的，所以不用指定mmio，指定成ft1500a的反而启动不了内核

另外：1.ft2000上的 uefi bios 也不是标准的，安装完了系统，不能开机自己引导系统，好在可以手动进入 uefi 的 shell ，进入 EFI/BOOT/ 下，运行 "BOOTAA64.EFI(名字忘了)"，bios界面会自动生成引导索引，将开机引导顺序改成新生成的引导索引，可以开机自动启动系统
	  2. reboot不能成功，可以在grub.cfg中的内核参数中加上apci=off，可以poweroff关机。