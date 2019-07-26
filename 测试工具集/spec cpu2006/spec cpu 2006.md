# spec cpu 2006

## 下载spec cpu 2006

```bash
# http://www.cse.iitd.ernet.in/~sbansal/software/tars/cpu2006.tar.bz2
```

## 准备安装

```bash
准备工作
# cd /root
# ls
cpu2006.tar.bz2
# mkdir spec_cpu_2006
# tar xf cpu2006.tar.bz2 -C spec_cpu_2006
# mkdir spec_cpu_2006/install_archives
# mv cpu2006.tar.bz2 spec_cpu_2006/install_archives

benchmark需要用到一套tools，有现成x86的tools，没有ARM64的，所以要自己编译
# bash spec_cpu_2006/tools/src/buildtools
# source spec_cpu_2006/shrc

测试是否编译成功
# runspec --test
```

SPEC CPU 2006是一个比较老的benchmark，所以在较新的Linux系统上编译会出现不兼容的问题。在编译过程中，需要对SPEC CPU 2006的源代码做几处修改来兼容新的Linux系统。本文以CentOS 7系统为例，介绍在Linux系统中SPEC CPU 2006的编译过程。

## Compile

首先，由于兼容性问题SPEC CPU 2006中自带的`install.sh`文件是运行不了的，我们需要重新编译源代码。进入`/tool/src`目录，运行`buildtools`文件：

```bash
./buildtools
```

## Debug

运行过程中，会出现几个错误。下面列出了这几个错误和相应的解决方法。

### error cannot guess build type

错误原因：cpu2006源码太旧，其中的config.guess和config.sub无法识别当前架构

解决方法：

```bash
# wget -O config.guess 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD'
# wget -O config.sub 'http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD'
# find . -name config.guess
./tools/src/tar-1.15.1/config/config.guess
./tools/src/expat-1.95.8/conftools/config.guess
./tools/src/make-3.81/config/config.guess
./tools/src/specinvoke/config.guess
# find . -name config.sub  
./tools/src/tar-1.15.1/config/config.sub
./tools/src/expat-1.95.8/conftools/config.sub
./tools/src/make-3.81/config/config.sub
./tools/src/specinvoke/config.sub

找到源码中的这些文件，全部替换掉

```

### error building specmd5sum

编译specmd5sum时，会出现如下错误：

```bash
        gcc -DHAVE_CONFIG_H    -I/home/gem5/cpu2006/tools/output/include   -I. -Ilib  -c -o md5sum.o md5sum.c
        In file included from md5sum.c:38:0:
        lib/getline.h:31:1: error: conflicting types for 'getline'
         getline PARAMS ((char **_lineptr, size_t *_n, FILE *_stream));
         ^
        In file included from md5sum.c:26:0:
        /usr/include/stdio.h:678:20: note: previous declaration of 'getline' was here
         extern _IO_ssize_t getline (char **__restrict __lineptr,
                    ^
        In file included from md5sum.c:38:0:
        lib/getline.h:34:1: error: conflicting types for 'getdelim'
         getdelim PARAMS ((char **_lineptr, size_t *_n, int _delimiter, FILE *_stream));
         ^
        In file included from md5sum.c:26:0:
        /usr/include/stdio.h:668:20: note: previous declaration of 'getdelim' was here
          extern _IO_ssize_t getdelim (char **__restrict __lineptr,
                             ^
        make: *** [md5sum.o] Error 1
        + testordie 'error building specmd5sum'
        + test 2 -ne 0
        + echo '!!! error building specmd5sum'
        !!! error building specmd5sum
        + kill -TERM 1299
        + exit 1
        !!!!! buildtools killed
```

错误原因主要是：函数冲突，stdio.h库已经定义getline和getdelim函数，而SPEC CPU 2006中的getline.h中也定义了这两个函数。

解决方法：打开`./tools/src/specmd5sum/md5sum.c`文件，注释掉`getline.h`头文件（第38行）

//#include "getline.h"

### error building Perl

编译Perl时，会出现如下两个错误。

```bash
ERROR 1:
        collect2: error: ld returned 1 exit status
        make: *** [miniperl] Error 1
        + testordie 'error building Perl'
        + test 2 -ne 0
        + echo '!!! error building Perl'
        !!! error building Perl
        + kill -TERM 15173
        + exit 1
        !!!!! buildtools killed

ERROR 2:
    t/op/sprintf..............................FAILED--no leader found
    t/op/sprintf2.............................FAILED--expected 263 tests, saw 3
```

错误原因：

1. 高版本的Linux内核中删除了`asm/page.h`头文件;
2. 配置perl时，需要用到数学库;

解决方法：

+ 打开`./tools/src/perl-5.8.8/ext/IPC/SysV/SysV.xs`文件，注释`asm/page.h`头文件（第7行）

```bash
//#   include <asm/page.h>
```

+ 打开`./tools/src/buildtools`文件，在编译perl的代码部分（第333行和334行）做如下修改。

```bash
    修改前：
        LD_LIBRARY_PATH=`pwd`
        DYLD_LIBRARY_PATH=`pwd`
        export LD_LIBRARY_PATH DYLD_LIBRARY_PATH
        ./Configure -dOes -Ud_flock $PERLFLAGS -Ddosuid=undef -Dprefix=$INSTALLDIR -Dd_bincompat3=undef -A ldflags=-L${INSTALLDIR}/lib -A ccflags=-I${INSTALLDIR}/include -Ui_db -Ui_gdbm -Ui_ndbm -Ui_dbm -Uuse5005threads ; testordie "error configuring perl"

    修改后：

        LD_LIBRARY_PATH=`pwd`
        DYLD_LIBRARY_PATH=`pwd`
        ./Configure -Dcc="gcc -lm" -Dlibpth='/usr/local/lib64 /lib64 /usr/lib64' -dOes -Ud_flock $PERLFLAGS -Ddosuid=undef -Dprefix=$INSTALLDIR -Dd_bincompat3=undef -A ldflags=-L${INSTALLDIR}/lib -A ccflags=-I${INSTALLDIR}/include -Ui_db -Ui_gdbm -Ui_ndbm -Ui_dbm -Uuse5005threads ; testordie "error configuring perl"
```
