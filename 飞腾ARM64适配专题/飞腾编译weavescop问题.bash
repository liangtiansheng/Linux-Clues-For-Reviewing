前述：weavescope为容器而生,所以编译成功后其功能模块都被打包成了镜像,并且自动docker save成了一个scope.tar包,导入对应的架构下即可使用,源码中有一个scope文件,它
      并非是二进制文件,而是启动scope镜像功能模块

1、编译过程的第一个问题：go install: -race and -msan are only supported on linux/amd64, freebsd/amd64, darwin/amd64 and windows/amd64
	解决办法用grep -rE "go install -race -tags netgo std" scope/* 找到有这个语句的文件，显示的是两个Dockfile,将-race去掉
	root@node4:~/scope# grep -rE "go install -race -tags netgo std" *
	backend/Dockerfile:	go install -race -tags netgo std
	tools/build/golang/Dockerfile:	go install -race -tags netgo std

2、在这上面两个Dockerfile里面要把amd64的"RUN curl -fsSL -o shfmt https://github.com/mvdan/sh/releases/download/v1.3.0/shfmt_v1.3.0_linux_amd64"两个软件换成arm架构
   这个地址下就有对应arm架构的shfmt_v1.3.0_linux_arm,经测试可以使用
   
3、scope/client/Dockfile第一行是FROM node:8.4.0,默认情况下它是会下载amd64的镜像,如此会报exec format错误,所以换成了FROM arm64v8/node:8.11.4,版本高一点,经测试有效
   还有一个是docker/Dockerfile.cloud-agent下也要将镜像改成arm64v8/alpine:3.5,不然会报错找不到arm架构下的镜像
	root@node4:/opt/go/src/scope# grep -Er arm64v8 *
	client/Dockerfile:FROM arm64v8/node:8.11.4
	docker/Dockerfile.cloud-agent:FROM arm64v8/alpine:3.5
	
4、错误信息是：
   probe/endpoint/connection_tracker.go:25:16: undefined: DNSSnooper
   Makefile:114: recipe for target 'render/detailed/detailed.codecgen.go' failed
   make: *** [render/detailed/detailed.codecgen.go] Error 2
   解决办法：将源码scope/probe/endpoint/dns_snooper_others.go中的编译器开关// +build darwin arm改成// +build !amd64
5、有一个文件中的tag在编译时没有权限访问，给个777权限
    root@compute2:/opt/go/src/github.com/scope# chmod 777 tools/image-tag