---
title: Python3离线升级
date: 2023-12-29 13:15:56
tags:
  - 技术笔记
  - Linux
---
1. 安装依赖
```bash
yum install gcc libffi-devel zlib* openssl-devel libffi-devel zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make
```

2. 下载安装包
```bash
wget https://www.python.org/ftp/python/3.10.6/Python-3.10.6.tgz
```

3. 编译安装
```bash
tar -xvJf Python-3.10.6.tar.xz
cd Python-3.10.6

# 3.编译安装
./configure prefix=/usr/local/python3 --with-openssl=/usr/
make && make install
```

4. 环境替换
```bash
ln -s /usr/local/python3/bin/python3 /usr/bin/python3
ln -s /usr/local/python3/bin/pip3 /usr/bin/pip3
```

5. 替换默认python
```bash
ln -s /usr/bin/python3 /usr/bin/python

## 替换后 yum不可用
vim /usr/bin/yum  
vim /usr/libexec/urlgrabber-ext-down

#!/usr/bin/python -> #!/usr/bin/python2
```
#### 【选做】问题openssl兼容

 1. 升级openssl
```bash
wget https://www.openssl.org/source/openssl-1.1.1a.tar.gz
tar -zxvf openssl-1.1.1a.tar.gz
cd openssl-1.1.1a

./config --prefix=/usr/local/openssl no-zlib #不需要zlib
make
make install
```

2. 备份替换openssl
```bash
## 备份
mv /usr/bin/openssl /usr/bin/openssl.bak
mv /usr/include/openssl/ /usr/include/openssl.bak

#替换
ln -s /usr/local/openssl/include/openssl /usr/include/openssl
ln -s /usr/local/openssl/lib/libssl.so.1.1 /usr/local/lib64/libssl.so
ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl

ln -s /usr/local/openssl/lib/libssl.so.1.1 /usr/lib64/libssl.so.1.1
ln -s /usr/local/openssl/lib/libcrypto.so.1.1 /usr/lib64/libcrypto.so.1.1

## 动态库搜索路径
echo "/usr/local/openssl/lib" >> /etc/ld.so.conf
ldconfig -v

## 查看版本 
openssl version

```

3. 重新安装python
```bash
./configure --prefix=/usr/local/python3 --with-openssl=/usr/local/openssl
make
make install
```

