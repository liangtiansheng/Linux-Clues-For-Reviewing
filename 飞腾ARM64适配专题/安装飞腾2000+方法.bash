1 uncompress this CentOS75-1806-ft1500a.tar.gz under the root of USB disk with vfat filesystem
2 relabel the USB disk with "CENTOS75"
3 boot from UEFI, run fs0:\EFI\BOOT\grubaa64.efi
4 choose a grub configeration according to your hardware
5 execute the normal process of CentOS 7.x installation
6 if your UEFI does NOT provide DTB infomation through FDT, please install the dtb directory under the root of the USB disk to /boot partition, and modify /boot/efi/EFI/centos/grub.cfg, when all the intallation process finished, and then reboot the system
7 enjoy the CentOS 7.5 1806 aarch64 for FT1500a edition
8 any feedback, please sendto euroford@qq.com

用在ft2000+上，请阅读下文
注意1：把 linux /images/pxeboot/vmlinuz console=ttyS1,115200 earlycon=uart8250,mmio32,0x70001000 inst.stage2=hd:LABEL=CENTOS75 ro inst.graphical video=efifb:off 换成 linux /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=CENTOS75 ro inst.graphical video=efifb:off
常识：内存映射输入输出（英语：Memory-mapped I/O, MMIO，简称为内存映射IO），以及端口映射输入输出（port-mapped I/O, PMIO，也叫作独立输入输出（isolated I/O），是PC机在中央处理器（CPU）和外部设备之间执行输入输出操作的两种方法，这两种方法互为补充。除此之外，执行输入输出操作也可以使用专用输入输出处理器（dedicated I/O processors）——这通常是指大型电脑上的通道输入输出（Channel I/O），这些专用处理器执行自有的指令集。
原因：ft1500a的内存地址映射人为设置偏移，所以要自己手动指定，ft2000plus用的是标准的，所以不用指定mmio，指定成ft1500a的反而启动不了内核

注意2：ft2000上的 uefi bios 也不是标准的，安装完了系统，不能开机自己引导系统，好在可以手动进入 uefi 的 shell ，进入 EFI/BOOT/ 下，运行 "fbaa64.efi"，bios界面会自动生成引导索引，将开机引导顺序改成新生成的引导索引，可以开机自动启动系统
原因：如下文3个人的对话(https://bugzilla.redhat.com/show_bug.cgi?id=1527283)

注意3：reboot不能成功，在grub.cfg中的内核参数中加上noefi，通过noefi启动的系统可以重启
原因：uefi启动系统后，系统会保护uefi runtime service那段内存空间代码（其他uefi代码退出释放空间），这段空间中有关于reboot的代码，ft2000 中的uefi代码不标准，无法实现代码调用进行reboot，所以用noefi关闭efi功能，实现原始reboot方法。


<<< vanlos wang 2017-12-19 08:57:05 UTC >>>
It seems like a bug for CentOS altarch aarch64 iso or AAVMF. In the UEFI SHELL, I execute FS0:\EFI\BOOT\BOOTAA64.EFI, it return error to me.
Shell> FS0:\EFI\BOOT\BOOTAA64.EFI
dppath: \EFI\BOOT\BOOTAA64.EFI
path:   FS0:\EFI\BOOT\BOOTAA64.EFI
Section 0 has negative size
Failed to load image: Unsupported
start_image() returned Unsupported
Error: Image at 000B8467000 start failed: Unsupported
Unloading driver at 0x000B8467000
But when I change to execute FS0:\EFI\BOOT\fbaa64.efi in the UEFI SHELL, it will boot OK. So the defaut boot option in AAVMF for CentOS should be fbaa64.efi?
Shell> FS0:\EFI\BOOT\fbaa64.efi


<<< jia he 2018-08-17 01:56:59 UTC >>>
(In reply to Maran Wilson from comment #4)
> I have root caused this bug to a problem in the UEFI shim loader code. I\'ve
> tested the fix and posted the patch as a pull request to
> https://github.com/rhboot/shim
> 
> Hopefully someone with familiarity with that code base can take a look at
> the patch I posted and provide some code review feedback to help move things
> along.
Thanks, Maran
I haven\'t tested your patch, but from the commit log, the patch seems to resolve the issue "failing to load the fbaa64.efi image". But I thought the original bug (this one) is failing to load "FS0:\EFI\BOOT\BOOTAA64.EFI". But when vanlos use the fbaa64.efi, it can be boot successfully without any bugs.
@vanlos, do you agree with my description above?
Cheers,
Jia

<<< Maran Wilson 2018-08-17 18:17:49 UTC >>>
(In reply to jia he from comment #6)
> (In reply to Maran Wilson from comment #4)
> > I have root caused this bug to a problem in the UEFI shim loader code. I've
> > tested the fix and posted the patch as a pull request to
> > https://github.com/rhboot/shim
> > 
> > Hopefully someone with familiarity with that code base can take a look at
> > the patch I posted and provide some code review feedback to help move things
> > along.
> Thanks, Maran
> I haven't tested your patch, but from the commit log, the patch seems to
> resolve the issue "failing to load the fbaa64.efi image". But I thought the
> original bug (this one) is failing to load "FS0:\EFI\BOOT\BOOTAA64.EFI". But
> when vanlos use the fbaa64.efi, it can be boot successfully without any bugs.
> 
> @vanlos, do you agree with my description above?
> 
> Cheers,
> Jia
It all makes sense because there are two ways to load a EFI program. One way is to invoke it directly on the EFI shell prompt (as @vanlos reported above). In that case, the EFI shell is the SW component that is loading the fbaa64.efi program into memory and executing it. That comes from the EDK2 source code and works just fine.
However, the second way to load a EFI program is to use the EFI shell (or it can happen automatically when you boot clean VM with an imported disk image) to launch the shim EFI program (BOOTAA64.EFI) which then, in turn, does the work itself to load the fbaa64.efi. That is where the bug is located -- in the shim code used to compile BOOTAA64.EFI. So in both failing experiments above, BOOTAA64.EFI has already loaded and begun its own execution and then prints out the error message about "Section 0 has negative size" when it tries to load and execute fbaa64.efi itself.


