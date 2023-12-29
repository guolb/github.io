---
title: Sysetemd监控和启动应用程序
date: 2023-12-29 13:15:56
tags:
  - 技术笔记
---

#### 创建测试程序
```bash
#!/bin/bash

# file systemd_test.sh
while :; do
    echo `date` >> /tmp/systemd_test.log
    sleep 1
done
```

#### 设置全局可访问
```bash
$ chmod +x systemd_test.sh
$ ln -sf systemd_test.sh /usr/sbin/sysd-test
```

#### 创建 systemd 配置文件
sysd-test.service
```conf
[Unit]
Description=sysd server daemon
Documentation=no
After=no
Wants=no

[Service]
EnvironmentFile=no
ExecStart=/usr/sbin/sysd-test
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=1s

[Install]
WantedBy=multi-user.target graphic.target      #相当于runlevel：2345
```

#### 启用
```bash
$ systemctl enable sysd-test.service
```


#### 查看程序日志
```bash
journalctl -f

journalctl -u frpc.service
```