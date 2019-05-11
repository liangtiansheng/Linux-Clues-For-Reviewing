awk [options] PARAMETERS 'PATTERN { action }' file1 file2, ...

grep: 文本过滤器
	grep option 'pattern' input_file ...
sed：流编辑器
awk: 报告生成器
	格式化以后，显示
AWK a.k.a. Aho, Kernighan and Weinberger
new awk: nawk
	solaris
gawk
	gnu
	现在用的awk链接到gawk
[root@RHEL5 ~]# vim test.txt
this is a test.
[root@RHEL5 ~]# awk '{print $1,$2}' test.txt 
this is
[root@RHEL5 ~]# awk 'BEGIN{OFS=":"}{print $1,$2,$3,$4}' test.txt 
this:is:a:test.
[root@RHEL5 ~]# awk 'BEGIN{OFS=":"}{print $1,$2,"Hello",$3,$4}' test.txt 
this:is:Hello:a:test.

awk的输出：

一、print
print的使用格式：
	print item1, item2, ...
要点：
1、各项目之间使用逗号隔开，而输出时则以空白字符分隔；
2、输出的item可以为字符串或数值、当前记录的字段(如$1)、变量或awk的表达式；数值会先转换为字符串，而后再输出；
3、print命令后面的item可以省略，此时其功能相当于print $0, 也就是$0相当于整行，因此，如果想输出空白行，则需要使用print ""；

例子：
# awk 'BEGIN { print "line one\nline two\nline three" }'
awk -F: '{ print $1, $3 }' /etc/passwd


二、awk变量

2.1 awk内置变量之记录变量：
FS: field separator，读取文件本时，所使用字段分隔符；
RS: Record separator，输入文本信息所使用的换行符；
OFS: Output Filed Separator: 输出时字段分隔符：
ORS：Output Row Separator：输出时行分隔符：

awk -F:		输入分隔符
OFS="#"		输出分隔符
FS=":"		输入分隔符


2.2 awk内置变量之数据变量：
NR: The number of input records，包括正在处理的这一行所有文件已经处理了多少行
FNR: 包括正在处理的这一行当前文件共处理了多少行
NF：Number of Field，当前记录的field个数($NF指的就是最后一个字段)
ARGV: 数组，保存命令行本身这个字符串，如awk '{print $0}' a.txt b.txt这个命令中，ARGV[0]保存awk，ARGV[1]保存a.txt；
ARGC: awk命令的参数的个数；
FILENAME: awk命令所处理的文件的名称；
ENVIRON：当前shell环境变量及其值的关联数组；



2.3 用户自定义变量

gawk允许用户自定义自己的变量以便在程序代码中使用，变量名命名规则与大多数编程语言相同，只能使用字母、数字和下划线，且不能以数字开头。gawk变量名称区分字符大小写。
[root@RHEL5 ~]# awk -v test="hello awk" 'BEGIN{print test}'
hello awk
[root@RHEL5 ~]# 

2.3.1 在脚本中赋值变量

在gawk中给变量赋值使用赋值语句进行，例如：
awk 'BEGIN{var="variable testing";print var}'

2.3.2 在命令行中使用赋值变量

gawk命令也可以在“脚本”外为变量赋值，并在脚本中进行引用。例如，上述的例子还可以改写为：
awk -v var="variable testing" 'BEGIN{print var}'

三、printf
printf命令的使用格式：
printf format, item1, item2, ...

要点：
1、其与print命令的最大不同是，printf需要指定format；
2、format用于指定后面的每个item的输出格式；
3、printf语句不会自动打印换行符；\n

format格式的指示符都以%开头，后跟一个字符；如下：
%c: 显示字符的ASCII码；
	[root@ly_lab ~]# awk 'BEGIN{printf "%c\n","a"}'
	a
	[root@ly_lab ~]#
%d, %i：十进制整数；
%e, %E：科学计数法显示数值；
%f: 显示浮点数；
%g, %G: 以科学计数法的格式或浮点数的格式显示数值；
%s: 显示字符串(注意几个%号几个字符段)
	[root@ly_lab ~]# awk -F: '{printf "%-20s%s\n",$1,$3,$7}' /etc/passwd
	root                0
	bin                 1
	daemon              2
%u: 无符号整数；
%%: 显示%自身；

修饰符：
N: 显示宽度；
-: 左对齐；
+：显示数值符号；

例子：%号跟后面的字符段一一对应
# awk -F: '{printf "%-15s %i\n",$1,$3}' /etc/passwd

四、输出重定向

print items > output-file
print items >> output-file
print items | command

特殊文件描述符：
/dev/stdin：标准输入
/dev/stdout: 标准输出
/dev/stderr: 错误输出
/dev/fd/N: 某特定文件描述符，如/dev/stdin就相当于/dev/fd/0；

例子：
# awk -F: '{printf "%-15s %i\n",$1,$3 > "/dev/stderr" }' /etc/passwd


六、awk的操作符：

6.1 算术操作符：

-x: 负值
+x: 转换为数值；
x^y: 
x**y: 次方
x*y: 乘法
x/y：除法
x+y:
x-y:
x%y:

6.2 字符串操作符：
只有一个，而且不用写出来，用于实现字符串连接；

6.3 赋值操作符：
=
+=
-=
*=
/=
%=
^=
**=

++
--

需要注意的是，如果某模式为=号，此时使用/=/可能会有语法错误，应以/[=]/替代；

6.4 布尔值

awk中，任何非0值或非空字符串都为真，反之就为假；

6.5 比较操作符：
x < y	True if x is less than y. 
x <= y	True if x is less than or equal to y. 
x > y	True if x is greater than y. 
x >= y	True if x is greater than or equal to y. 
x == y	True if x is equal to y. 
x != y	True if x is not equal to y. 
x ~ y	True if the string x matches the regexp denoted by y. 
x !~ y	True if the string x does not match the regexp denoted by y. 
subscript in array	  True if the array array has an element with the subscript subscript.

6.7 表达式间的逻辑关系符：
&&
||

6.8 条件表达式：
selector?if-true-exp:if-false-exp

相当于if这种表达
if selector; then
  if-true-exp
else
  if-false-exp
fi

如：
a=3
b=4
a>b?a is max:b ia max

6.9 函数调用：
function_name (para1,para2)




七 awk的模式：

awk 'program' input-file1 input-file2 ...
其中的program为:
pattern { action }
pattern { action }
...

7.1 常见的模式类型：
1、Regexp: 正则表达式，格式为/regular expression/
2、expresssion： 表达式，其值非0或为非空字符时满足条件，如：$1 ~ /foo/ 或 $1 == "magedu"，用运算符~(匹配)和!~(不匹配)。
	[root@RHEL5 ~]# awk -F: '$7~"bash$"{print $1,$7}' /etc/passwd
	root /bin/bash
	mysql /bin/bash
	[root@RHEL5 ~]# 
3、Ranges： 指定的匹配范围，格式为pat1,pat2
	[root@RHEL5 ~]# awk -F: '/^r/,/^m/{print $1,$7}' /etc/passwd
4、BEGIN/END：特殊模式，仅在awk命令执行前运行一次或结束前运行一次
	#awk 'BEGIN{print ENVIRON["PATH"]}'
		在处理文件之前采取行动，没有BEGIN就会死循环
5、Empty(空模式)：匹配任意输入行；

7.2 常见的Action
1、Expressions:
2、Control statements (if,case,for....)
3、Compound statements
4、Input statements
5、Output statements


/正则表达式/：使用通配符的扩展集。

关系表达式：可以用下面运算符表中的关系运算符进行操作，可以是字符串或数字的比较，如$2>%1选择第二个字段比第一个字段长的行。

模式匹配表达式：

模式，模式：指定一个行的范围。该语法不能包括BEGIN和END模式。

BEGIN：让用户指定在第一条输入记录被处理之前所发生的动作，通常可在这里设置全局变量。

END：让用户在最后一条输入记录被读取之后发生的动作。





八 控制语句：
8.1 if-else
语法：if (condition) {statement}或者if (condition) statement;else statement
例子：
awk -F: '{if ($1=="root") print $1, "Admin"; else print $1, "Common User"}' /etc/passwd
awk -F: '{if ($1=="root") printf "%-15s: %s\n", $1,"Admin"; else printf "%-15s: %s\n", $1, "Common User"}' /etc/passwd
awk -F: -v sum=0 '{if ($3>=500) sum++}END{print sum}' /etc/passwd

8.2 while
语法： while (condition){statement1; statment2; ...}
awk -F: '{i=1;while (i<=3) {print $i;i++}}' /etc/passwd
awk -F: '{i=1;while (i<=NF) { if (length($i)>=4) {print $i}; i++ }}' /etc/passwd

8.3 do-while
语法： do {statement1, statement2, ...} while (condition)
awk -F: '{i=1;do {print $i;i++}while(i<=3)}' /etc/passwd

8.4 for
语法： for ( variable assignment; condition; iteration process) { statement1, statement2, ...}
awk -F: '{for(i=1;i<=3;i++) print $i}' /etc/passwd
awk -F: '{for(i=1;i<=NF;i++) { if (length($i)>=4) {print $i}}}' /etc/passwd

for循环还可以用来遍历数组元素：
语法： for (i in array) {statement1, statement2, ...}
awk -F: '$NF!~/^$/{BASH[$NF]++}END{for(A in BASH){printf "%15s:%i\n",A,BASH[A]}}' /etc/passwd

8.5 case
语法：switch (expression) { case VALUE or /REGEXP/: statement1, statement2,... default: statement1, ...}

8.6 break 和 continue
常用于循环或case语句中

8.7 next
提前结束对本行文本的处理，并接着处理下一行；例如，下面的命令将显示其ID号为奇数的用户：
# awk -F: '{if($3%2==0) next;print $1,$3}' /etc/passwd


九 awk中使用数组

9.1 数组

array[index-expression]

index-expression可以使用任意字符串；需要注意的是，如果某数据组元素事先不存在，那么在引用其时，awk会自动创建此元素并初始化为空串；因此，要判断某数据组中是否存在某元素，需要使用index in array的方式。

要遍历数组中的每一个元素，需要使用如下的特殊结构：
for (var in array) { statement1, ... }
其中，var用于引用数组下标，而不是元素值；
awk -F: '{shell[$NF]++}END{for (A in shell) {print A,shell[A]}}' /etc/passwd
例子：
netstat -ant | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
每出现一被/^tcp/模式匹配到的行，数组S[$NF]就加1，$NF为当前匹配到的行的最后一个字段，此处用其值做为数组S的元素索引；

awk '{counts[$1]++}; END {for(url in counts) print counts[url], url}' /var/log/httpd/access_log
用法与上一个例子相同，用于统计某日志文件中IP地的访问量

9.2 删除数组变量

从关系数组中删除数组索引需要使用delete命令。使用格式为：

delete  array[index]



十、awk的内置函数

split(string, array [, fieldsep [, seps ] ])
功能：将string表示的字符串以fieldsep为分隔符进行分隔，并将分隔后的结果保存至array为名的数组中；数组下标为从0开始的序列；

netstat -ant | awk '/:80\>/{split($5,clients,":");IP[clients[1]]++}END{for(i in IP){print IP[i],i}}' | sort -rn | head -50

length([string])
功能：返回string字符串中字符的个数；


substr(string, start [, length])
功能：取string字符串中的子串，从start开始，取length个；start从1开始计数；

system(command)
功能：执行系统command并将结果返回至awk命令

systime()
功能：取系统当前时间

tolower(s)
功能：将s中的所有字母转为小写

toupper(s)
功能：将s中的所有字母转为大写

十一、用户自定义函数

自定义函数使用function关键字。格式如下：

function F_NAME([variable])
{
	statements
}

函数还可以使用return语句返回值，格式为“return value”。


############################# awk 实战 ################################################

Linux Web服务器网站故障分析常用的命令

系统连接状态篇：
1.查看TCP连接状态
netstat -nat |awk ‘{print $6}’|sort|uniq -c|sort -rn

netstat -n | awk ‘/^tcp/ {++S[$NF]};END {for(a in S) print a, S[a]}’ 或
netstat -n | awk ‘/^tcp/ {++state[$NF]}; END {for(key in state) print key,"\t",state[key]}’
netstat -n | awk ‘/^tcp/ {++arr[$NF]};END {for(k in arr) print k,"t",arr[k]}’

netstat -n |awk ‘/^tcp/ {print $NF}’|sort|uniq -c|sort -rn

netstat -ant | awk ‘{print $NF}’ | grep -v ‘[a-z]‘ | sort | uniq -c

 

2.查找请求数请20个IP（常用于查找攻来源）：

netstat -anlp|grep 80|grep tcp|awk ‘{print $5}’|awk -F: ‘{print $1}’|sort|uniq -c|sort -nr|head -n20

netstat -ant |awk ‘/:80/{split($5,ip,":");++A[ip[1]]}END{for(i in A) print A[i],i}’ |sort -rn|head -n20

3.用tcpdump嗅探80端口的访问看看谁最高

tcpdump -i eth0 -tnn dst port 80 -c 1000 | awk -F"." ‘{print $1"."$2"."$3"."$4}’ | sort | uniq -c | sort -nr |head -20

4.查找较多time_wait连接

netstat -n|grep TIME_WAIT|awk ‘{print $5}’|sort|uniq -c|sort -rn|head -n20

5.找查较多的SYN连接

netstat -an | grep SYN | awk ‘{print $5}’ | awk -F: ‘{print $1}’ | sort | uniq -c | sort -nr | more

6.根据端口列进程

netstat -ntlp | grep 80 | awk ‘{print $7}’ | cut -d/ -f1

 

网站日志分析篇1（Apache）：

1.获得访问前10位的ip地址

cat access.log|awk ‘{print $1}’|sort|uniq -c|sort -nr|head -10
cat access.log|awk ‘{counts[$(11)]+=1}; END {for(url in counts) print counts[url], url}’

2.访问次数最多的文件或页面,取前20

cat access.log|awk ‘{print $11}’|sort|uniq -c|sort -nr|head -20

3.列出传输最大的几个exe文件（分析下载站的时候常用）

cat access.log |awk ‘($7~/.exe/){print $10 " " $1 " " $4 " " $7}’|sort -nr|head -20

4.列出输出大于200000byte(约200kb)的exe文件以及对应文件发生次数

cat access.log |awk ‘($10 > 200000 && $7~/.exe/){print $7}’|sort -n|uniq -c|sort -nr|head -100

5.如果日志最后一列记录的是页面文件传输时间，则有列出到客户端最耗时的页面

cat access.log |awk ‘($7~/.php/){print $NF " " $1 " " $4 " " $7}’|sort -nr|head -100

6.列出最最耗时的页面(超过60秒的)的以及对应页面发生次数

cat access.log |awk ‘($NF > 60 && $7~/.php/){print $7}’|sort -n|uniq -c|sort -nr|head -100

7.列出传输时间超过 30 秒的文件

cat access.log |awk ‘($NF > 30){print $7}’|sort -n|uniq -c|sort -nr|head -20

8.统计网站流量（G)

cat access.log |awk ‘{sum+=$10} END {print sum/1024/1024/1024}’

9.统计404的连接

awk ‘($9 ~/404/)’ access.log | awk ‘{print $9,$7}’ | sort

10. 统计http status

cat access.log |awk ‘{counts[$(9)]+=1}; END {for(code in counts) print code, counts[code]}'
cat access.log |awk '{print $9}'|sort|uniq -c|sort -rn

10.蜘蛛分析，查看是哪些蜘蛛在抓取内容。

/usr/sbin/tcpdump -i eth0 -l -s 0 -w - dst port 80 | strings | grep -i user-agent | grep -i -E 'bot|crawler|slurp|spider'

网站日分析2(Squid篇）按域统计流量

zcat squid_access.log.tar.gz| awk '{print $10,$7}' |awk 'BEGIN{FS="[ /]"}{trfc[$4]+=$1}END{for(domain in trfc){printf "%st%dn",domain,trfc[domain]}}'

数据库篇
1.查看数据库执行的sql

/usr/sbin/tcpdump -i eth0 -s 0 -l -w - dst port 3306 | strings | egrep -i 'SELECT|UPDATE|DELETE|INSERT|SET|COMMIT|ROLLBACK|CREATE|DROP|ALTER|CALL'

系统Debug分析篇
1.调试命令
strace -p pid
2.跟踪指定进程的PID
gdb -p pid

log format combind
192.168.154.1 - - [11/Dec/2017:19:46:12 +0800] "GET /noindex/css/fonts/ExtraBold/OpenSans-ExtraBold.ttf HTTP/1.1" 404 248 "http://192.168.154.137/" "Mozilla/5.0 (Windows NT 10.0; WOW64; Trident/7.0; rv:11.0) like Gecko"

