---
title: WSL异常处理
tags:
  - 技术笔记
date: 2023-12-29 13:15:56
---

#### WSL2 占位程序接收到错误数据
Error code: Wsl/Service/0x800706f7
```bash
netsh winsock reset
```  
然后就可以正常启动 WSL2 了，不用重启电脑

