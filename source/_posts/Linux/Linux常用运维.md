---
title: Linux常用运维
date: 2023-12-29 13:15:56
tags:
  - 技术笔记
  - Linux
---

### 磁盘管理

#### 磁盘分区

通用分区使用fdisk，如果需要分配超过1T的分区，使用parted。 
##### fidsk分区
```bash
# 操作磁盘
$ fdisk /dev/sdc
Welcome to fdisk (util-linux 2.30.1).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

# 新建分区
Command (m for help): n
Partition type
   p   primary (0 primary, 0 extended, 4 free)
   e   extended (container for logical partitions)

# 分区类型：p 主分区；e 扩展分区
Select (default p): Enter
Using default response p.
Partition number (1-4, default 1): Enter
First sector (2048-20971519, default 2048): Enter

# 分区大小
Last sector, +sectors or +size{K,M,G,T,P} (2048-20971519, default 20971519): +1G
Created a new partition 1 of type 'Linux' and of size 1 GiB.

Command (m for help): p
Disk /dev/sdc: 10 GiB, 10737418240 bytes, 20971520 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x8cc8f9e5
Device     Boot Start     End Sectors Size Id Type
/dev/sdc1        2048 2099199 2097152   1G 83 Linux

# 保存分区表
Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.
```

##### parted分区
超过1T的大空间分区，操作如下
```
$ parted /dev/sdb
# 对/dev/sdb进行分区或管理操作
 
GNU Parted 3.1
使用 /dev/sdb
Welcome to GNU Parted! Type 'help' to view a list of commands.
 
(parted) mklabel gpt
# 定义分区表格式（常用的有msdos和gpt分区表格式，msdos不支持2TB以上容量的磁盘，所以大于2TB的磁盘选gpt分区表格式）
 
警告: The existing disk label on /dev/sdb will be destroyed and all data on this disk will be lost. Do you want to continue?
# /dev/sdb上现有的磁盘标签将被销毁，该磁盘上的所有数据将丢失。你想要继续
是/Yes/否/No? yes                                                         
 
(parted) mkpart p1
# 创建第一个分区，名称为p1（p1只是第一个分区的名称，用别的名称也可以，如part1）
 
文件系统类型？  [ext2]? xfs        
# 定义分区格式（不支持ext4，想分ext4格式的分区，可以通过mkfs.ext4格式化成ext4格式）
                                       
起始点？ 1       
# 定义分区的起始位置（单位支持K,M,G,T）
                                                         
结束点？ 100%   
# 定义分区的结束位置（单位支持K,M,G,T）    
                                                      
(parted) print   # 查看当前分区情况
Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 
 
Number  Start   End    Size   File system  Name  标志
 1      1049kB  107GB  107GB  xfs          p1
```

parted删除分析
```
$ parted /dev/sdb
# 对/dev/sdb进行分区或管理操作
 
(parted) rm                
# rm删除命令（删除之前必须确保分区没有被挂载）
                                               
分区编号？ 1          
# 删除第一个分区
                                                    
(parted) print   # 打印当前分区情况                                                         
Model: VMware, VMware Virtual S (scsi)
Disk /dev/sdb: 107GB
Sector size (logical/physical): 512B/512B
Partition Table: gpt
Disk Flags: 
 
Number  Start  End  Size  File system  Name  标志
```
#### 磁盘格式化
```
$ sudo mkfs.ext4 /dev/sdc1
或
$ sudo mkfs -t ext4 /dev/sdc1
或
$ sudo mke2fs /dev/sdc1
mke2fs 1.43.5 (04-Aug-2017)
Creating filesystem with 262144 4k blocks and 65536 inodes
Filesystem UUID: c0a99b51-2b61-4f6a-b960-eb60915faab0
Superblock backups stored on blocks:
    32768, 98304, 163840, 229376
Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```

- Filesystem UUID: UUID 代表了通用且独一无二的识别符，UUID 在 Linux 中通常用来识别设备。它 128 位长的数字代表了 32 个十六进制数。
- Superblock: 超级块储存了文件系统的元数据。如果某个文件系统的超级块被破坏，我们就无法挂载它了（也就是说无法访问其中的文件了）。
- Inode: Inode 是类 Unix 系统中文件系统的数据结构，它储存了所有除名称以外的文件信息和数据。
- Journal: 日志式文件系统包含了用来修复电脑意外关机产生下错误信息的日志。

#### 挂载分区
在创建完分区和文件系统之后，我们需要挂载它们以便使用。我们需要创建一个挂载点来挂载分区，使用 mkdir 来创建一个挂载点。
```bash
# 创建挂载点
sudo mkdir -p /mnt/2g-new
```

进行临时挂载，请使用下面的命令。在计算机重启之后，你会丢失这个挂载点。
```bash
sudo mount /dev/sdc1 /mnt/2g-new
```

如果你希望永久挂载某个分区，请将分区详情加入 fstab 文件。我们既可以输入设备名称，也可以输入 UUID。 推荐使用设备名称挂载。
```bash
# vi /etc/fstab
/dev/sdc1 /mnt/2g-new ext4 defaults 0 0
```

也可以使用 UUID 来进行永久挂载（请使用 blkid 来获取 UUID）：
```bash
$ sudo blkid
/dev/sdc1: UUID="d17e3c31-e2c9-4f11-809c-94a549bc43b7" TYPE="ext2" PARTUUID="8cc8f9e5-01"
/dev/sda1: UUID="d92fa769-e00f-4fd7-b6ed-ecf7224af7fa" TYPE="ext4" PARTUUID="eab59449-01"
/dev/sdc3: UUID="ca307aa4-0866-49b1-8184-004025789e63" TYPE="ext4" PARTUUID="8cc8f9e5-03"
/dev/sdc5: PARTUUID="8cc8f9e5-05"
# vi /etc/fstab
UUID=d17e3c31-e2c9-4f11-809c-94a549bc43b7 /mnt/2g-new ext4 defaults 0 0
```
#### 校验修改是否正常
mount -a 命令无报错
```bash
mount -a
```
#### 查看分区空间
df 命令用于查看磁盘分区的空间及使用和剩余的空间信息。

```bash
# 默认显示所有挂载的磁盘，默认以 KB 为单位。
[Linux]$  df
文件系统          1K-块     已用     可用 已用% 挂载点
udev            3975328        0  3975328    0% /dev
tmpfs            799028     9516   789512    2% /run
/dev/mmcblk0p3 21977248 12651688  8186104   61% /
tmpfs           3995128   120492  3874636    4% /dev/shm
tmpfs              5120        4     5116    1% /run/lock
tmpfs           3995128        0  3995128    0% /sys/fs/cgroup
/dev/mmcblk0p4 95569324 10825896 79845740   12% /home/xiao/Videos/vlc
/dev/mmcblk0p1    94759     5199    89560    6% /boot/efi
tmpfs            799024       20   799004    1% /run/user/1000

# 以更可读的方式显示
[Linux]$  df -h
文件系统        容量  已用  可用 已用% 挂载点
udev            3.8G     0  3.8G    0% /dev
tmpfs           781M  9.3M  772M    2% /run
/dev/mmcblk0p3   21G   13G  7.9G   61% /
tmpfs           3.9G  118M  3.7G    4% /dev/shm
tmpfs           5.0M  4.0K  5.0M    1% /run/lock
tmpfs           3.9G     0  3.9G    0% /sys/fs/cgroup
/dev/mmcblk0p4   92G   11G   77G   12% /home/xiao/Videos/vlc
/dev/mmcblk0p1   93M  5.1M   88M    6% /boot/efi
tmpfs           781M   20K  781M    1% /run/user/1000
```

### 用户管理
#### 用户分组

在ubuntu系统创建新用户群组ai-study。
```bash
$ groupadd ai-study
```

#### 创建用户并加入分组
```bash
#参数-m 自动创建用户的home目录
$ useradd -m user05  

# 创建用户user05,账号家目录为/home/user05, 附加组为ai-study
$ useradd -d /home/user05 -G ai-study user05

#为用户user05设置密码
$ passwd user05 

#添加普通用户user05到附加组ai-study
$ sudo usermod -a -G ai-study user01  

# 查看用户分组信息
$ id user05
```

#### 查看分组下的用户
```bash
### 查看ai-study用户组下的所有用户
grep 'ai-study' /etc/group

# 查看root用户组下的所有用户
grep 'root' /etc/group
```

#### 分组内共享文件
```bash
# 创建共享文件夹work-share
$ mkdir /data/work-share   

# 将work-share文件夹共享给ai-study 用户组
$ chgrp ai-study /data/work-share/
```

#### 批量创建用户
下列操作见目录《批量生成账号并修改目录》
user.txt
```bash
user01
user02
user03
```

passwd.txt
```bash
user01:123456
user02:123456
user03:123456
```

执行脚本:
```bash
#!/bin/bash
for user in `cat user.txt`; do
  ## 创建用户，并指定用户所在目录
  useradd -d /home/$user -G ai-study $user
  echo "123456" | passwd --stdin $user
  echo "密码写入成功"
done

### 修改密码
chpasswd < passwd.txt
pwconv
cat passwd.txt
```
### 远程登录
#### 通过ssh登录主机
```bash
ssh user01@192.168.22.31
```

#### scp拷贝文件
```bash
## 将本机的text.zip文件，拷贝到远程主机的/home/user01/目录。
scp text.zip user01@192.168.22.31:/home/user01/

## 将远程主机的/home/user01/test.zip文件，拷贝到本机的当前目录
scp user01@192.168.22.31:/home/user01/test.zip .
```

#### 查看当前登录主机的用户
```bash
# 列出本机所有的 session
# 不带参数执行 loginctl 和执行 loginctl list-sessions 效果一样
[Linux]$ loginctl
SESSION  UID USER SEAT TTY
  1 1000 xiao      pts/0
  5 1000 xiao      pts/1

2 sessions listed.


# 查看 session 的详细信息
[Linux]$ loginctl show-session 5
EnableWallMessages=no
NAutoVTs=6
KillUserProcesses=no
RebootToFirmwareSetup=no
IdleSinceHint=1627474393034083
UserStopDelayUSec=10s
HandlePowerKey=poweroff
IdleAction=ignore
PreparingForShutdown=no
Docked=no
NCurrentSessions=2
...


# 杀死 session
[Linux]$ loginctl kill-session 976


# 查看登录用户的详细信息
[Linux]$ loginctl show-user 1000
UID=1000
GID=1000
Name=xiao
Timestamp=Wed 2021-07-28 18:53:32 CST
RuntimePath=/run/user/1000
Slice=user-1000.slice
...


# 查看登录用户的状态
[Linux]$ loginctl user-status xiao
xiao (1000)
           Since: Wed 2021-07-28 18:53:32 CST; 1h 25min ago
           State: active
        Sessions: 5 *1
          Linger: no
            Unit: user-1000.slice
                  ├─session-1.scope
                  │ ├─730 sshd: xiao [priv]
                  │ ├─747 sshd: xiao@pts/0
                  │ ├─748 -bash
                  │ └─851 vim 00_loginctl.rst
                  ├─session-5.scope
                  │ ├─852 sshd: xiao [priv]
                  │ ├─858 sshd: xiao@pts/1
                  │ ├─859 -bash
                  │ ├─862 su
                  │ ├─863 bash
                  │ ├─934 loginctl user-status xiao
                  │ └─935 pager
                  └─user@1000.service
                    └─init.scope
                      ├─733 /lib/systemd/systemd --user
                      └─734 (sd-pam)

Jul 28 18:53:33 debian systemd[733]: Listening on GnuPG cryptographic agent and passphrase
Jul 28 18:53:33 debian systemd[733]: Listening on GnuPG cryptographic agent (ssh-agent emu
```

### 网络管理
#### Linux设置固定IP
1. 进入到/etc/sysconfig/network-scripts 
2. 编辑对应iface的文件，将BOOTPROTO=dhcp的值改为static，并在最后面加上IP信息。
```
#BOOTPROTO=dhcp
BOOTPROTO=static 

IPADDR=192.168.8.101
NETMASK=255.255.255.0 
GATEWAY=192.168.8.1
DNS1=114.114.114.114
```

#### 网络连接分析
查看当前系统TCP连接状态
```bash
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
```

- netstat -n，这个命令负责查看主机上的所有 TCP、UDP 连接信息，i
- awk 命令则负责对这些信息进行进一步的处理，awk 后有一个用两个 "斜杠" 括起来的正则表达式，主要用来匹配以 tcp 开头的每一行信息，所以这里的正则表达式起到了一个过滤的作用（只分析tcp的连接），后面则是对信息过滤后进行具体的统计和输出

#### 查看IP
```bash
ip a | grep global | awk '{print $2}' | awk -F/ '{print $1}'
```

#### netcat连通性测试
```bash
## TCP
nc -z -v 192.168.1.60 19000-19100 2>&1 | grep succeeded

## UDP
nc -z -v -u 192.168.1.60 19000-19100 2>&1 | grep succeeded
```


### 修改swap交换分区
Linux中Swap（即：交换分区），类似于Windows的虚拟内存，就是当内存不足的时候，把一部分硬盘空间虚拟成内存使用,从而解决内存容量不足的情况。Android是基于Linux的操作系统，所以也可以使用Swap分区来提升系统运行效率。

#### 查看swap状态
```bash
free -h
swapon -s
```

```bash
### 生成文件
mkdir /usr/swap
dd if=/dev/zero of=/usr/swap/swapfile1 bs=1M count=2048

## 目标文件表示为swap分区文件
mkswap /usr/swap/swapfile1
chmod 600 /usr/swap/swapfile1

## 激活swap文件
swapon /usr/swap/swapfile1

## 自动挂载
vim /etc/fstab
##添加
/usr/swap/swapfile1 swap swap defaults 0 0
```

#### 修改swapiness设置swap使用时机
```bash
cat /proc/sys/vm/swappiness

## 临时修改
sysctl vm.swappiness=60

## sysctl.conf 持久化
vm.swappiness=60
```
- 0意味着“在任何情况下都不要发生交换”。
- swappiness＝100的时候表示积极的使用swap分区，并且把内存上的数据及时的搬运到swap空间里面。

#### 关闭swap
```bash
## 临时修改
swapoff

# 删除/etc/fsta添加的内容
```nux中Swap（即：交换分区），类似于Windows的虚拟内存，就是当内存不足的时候，把一部分硬盘空间虚拟成内存使用,从而解决内存容量不足的情况。Android是基于Linux的操作系统，所以也可以使用Swap分区来提升系统运行效率。

### 查看swap状态
```bash
free -h

swapon -s
```

```bash
### 生成文件
mkdir /usr/swap
dd if=/dev/zero of=/usr/swap/swapfile1 bs=1M count=2048

## 目标文件表示为swap分区文件
mkswap /usr/swap/swapfile1
chmod 600 /usr/swap/swapfile1

## 激活swap文件
swapon /usr/swap/swapfile1

## 自动挂载
vim /etc/fstab
##添加
/usr/swap/swapfile1 swap swap defaults 0 0
```

#### 修改swapiness设置swap使用时机
```bash
cat /proc/sys/vm/swappiness

## 临时修改
sysctl vm.swappiness=60

## sysctl.conf 持久化
vm.swappiness=60
```
- 0意味着“在任何情况下都不要发生交换”。
- swappiness＝100的时候表示积极的使用swap分区，并且把内存上的数据及时的搬运到swap空间里面。

#### 关闭swap
```bash
## 临时修改
swapoff

# 删除/etc/fsta添加的内容
```


### 常用脚本
#### 操作快捷键
- Ctrl + r：可以快速查找历史命令；
- Ctrl + l：可以清理控制台屏幕；
- Ctrl + a \ Ctrl + e：移动光标到命令行首\行尾；
- Ctrl + w \ Ctrl + k：删除光标之前\之后的内容。
- Ctrl + c：强制终止程序的执行；
- Ctrl + z：挂起一个进程；
- Ctrl + d：终端中输入 exit 后回车。

#### 磁盘空间分析

##### 查看系统最大文件
当磁盘空间不足，需要快速定位或者对文件使用率进行排序，需要查看哪一些文件目录或者文件占用的空间比较多，就需要如下组合命令。

```bash
du -x --max-depth=1 / | sort -k1 -nr
```

du命令
-  -x 参数表示跳过其他文件系统，也就是只分析本文件系统里的文件，它可以帮助我们排除一些非本文件系统的统计信息，这样执行速度会更快也不容易出现一些额外的干扰项。
- --max-depth 参数设置为 1，这样就可以统计出根目录下第一级目录中的所有文件的大小。

sort命令
- -k 参数指明具体按照哪一列进行排序
- -n 参数表示只对数值进行排序，
- -r 参数表示反向排序

##### 查找目录下文件数量
适用于系统上产生很多碎片文件时，随之产生大量的 Inode ， Inode 用于存放着文件系统中文件的源数据，Inode过渡的使用会导致系统 Inode 资源不足。这种情况是不正常的，这个时候分析如果通过du 命令指能具体展示出磁盘空间的使用情况，但并不能分析出具体目录下产生了多少碎片文件，我们就需要如下的命令组合来对文件进行统计分析。

```bash
find . -type f | awk -F / -v OFS=/ '{$NF="";dir[$0]++}END{for(i in dir)print dir[i]" "i}' | sort -k1 -nr | head
```

find命令
- -type f 查找指定文件类型

awk命令
- -F / 指定处理文件时字符串之间以/分割
- -v OFS=/ 显示结果时以/分割展示
- awk的{} END {}格式， 前面{}表示行处理操作，END{}表示行处理后需要进行增提输出。
- $NF设置为空，表示将每一行的文件名信息去除，从而保留文件路径
- dir 是一个自增数组，用于统计结果

#### 批量文件修改

#### 批量文件改名
```bash
rename .yml _pre.yml *
```
#### awk 文档处理
```bash
# 排序
cat fund_cust.txt | sort > fund_cust_sort.txt

## 取奇数行
cat fund_cust_sort.txt | awk '{if (NR%2==1) print $0}' > fund_cust_sort_1.txt

### 取偶数行
cat fund_cust_sort.txt | awk '{if (NR%2==0) print $0}' > fund_cust_sort_2.txt

### 合并
# NR：awk 处理的当前的行数，从1开始，直到所有文件处理完
# FNR：awk 处理的当前行在当前文件中所在的行数，从1开始，直到当前这个文件处理完，且在下一个文件会重新计数
# NR==FNR：表示当在处理第一个文件时
# a[NR]=$0：表示建立一个数组a，每行的行号和改行的内容形成一一对应的关系
# nr=NR：这里用nr这个变量记录第一个文件的行数；每处理一行nr被刷新一次，直到第一个文件结尾，最后nr就是第一个文件的行数！
# NR>FNR：表示处理第二个文件时
# a[NR-nr]：表示第一个文件的内容
# $0：表示第二个文件的每行的所有内容
awk 'NR==FNR{a[NR]=$1","$2","$3;nr=NR;} NR>FNR{print a[NR-nr]","$3","$1}' fund_cust_sort_1.txt fund_cust_sort_2.txt > fund_cust.csv

##gbk 转化为utf8
iconv -f gbk -t utf-8 2023-01-09.log > 2023-01-09_1.log

## 分隔符使用[]处理为 '[][]'
tail -65000 2023-01-09_1.log |  awk -F'[][]' '/请求功能号为/{print $18" "$12" " $1}' | sort -n 

## 搜索过滤
cat last05.log | awk -F'[: ]' '/结束,共花费时间/{print $8" "$13$14}'
```

##### 批量替换文件中内容
```bash
find ./-type f -name application.yml -exec sed -i"s/aaaaaa/bbbbbb/g"{}\; 

ls | xargs sed -i"2s/aa/bb/g";
```

find 命令, 
- -name 参数指定查找的文件名
- -exec 参数将查找到的内容传递给下一个命令去继续执行相关逻辑
 
sed 命令
主要对文件内容进行替换，这里会将 application.yml 文件中的 aaaaaa 替换成 bbbbbb

### 文件打包
查找所有的txt文件，打包并拷贝
```bash
(find . -name "*.txt" | xargs tar -cvf test.tar) && cp -f test.tar ~
```