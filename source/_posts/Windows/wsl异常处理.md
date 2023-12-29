#### WSL2 占位程序接收到错误数据
Error code: Wsl/Service/0x800706f7
```bash
netsh winsock reset
```  
然后就可以正常启动 WSL2 了，不用重启电脑

