
#### 设置docker日志大小
```bash
# vim /etc/docker/daemon.json
{
  "registry-mirrors": ["http://f613ce8f.m.daocloud.io"],
  "log-driver":"json-file",
  "log-opts": {"max-size":"500m", "max-file":"3"}
}
```

#### 清理日志
```bash
#!/bin/bash

logs=$(find /var/lib/docker/containers/ -name *-json.log)  
for log in $logs  
do  
  echo "clean logs : $log"  
  cat /dev/null > $log  
done  
```

#### 清理镜像
```bash
docker rmi $(docker images -q -f dangling=true)
```
