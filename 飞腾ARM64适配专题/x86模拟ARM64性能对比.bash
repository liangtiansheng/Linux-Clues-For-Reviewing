硬件：
    Dell 720 服务器：
        CPU：Inter(R) Xeon(R) E5-2670 v2 2.5GHz 40core
        内存：160G
        SSD盘：479G 两块固态 RAID0

        KVM 用 vt-x 加速 x86 虚拟机：
            vCPU：4core
            内存：8G
            硬盘：40G
            安装操作系统用时 5分17秒
            无障碍编译 qemu 用时 5分19秒
        KVM 用 qemu-system-aarch64 模拟 ARM64 虚拟机：
            vCPU: 40core
            内存： 8G
            硬盘：40G
            安装操作系统用时53分48秒
            无障碍编译 qemu 用时 148分53秒









