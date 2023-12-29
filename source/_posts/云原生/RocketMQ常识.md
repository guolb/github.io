---
title: RocketMQ消息队列
date: 2023-12-29 13:15:56
tags:
  - 技术笔记
---

#### 系统配置建议
1. 中间件系统肯定要开启大量的线程（跟vm.max_map_count有关）
2. 而且要进行大量的网络通信和磁盘IO（跟ulimit有关）
3. 然后大量的使用内存（跟vm.swappiness和vm.overcommit_memory有关）

#### JVM参数
```
就是默认的堆大小是8g内存，新生代是4g内存.
-Xms8g -Xmx8g -Xmn4g

选用了G1垃圾回收器来做分代回收，对新生代和老年代都是用G1来回收
-XX:+UseG1GC -XX:G1HeapRegionSize=16m

在G1管理的老年代里预留25%的空闲内存. 默认值是10%
-XX:G1ReservePercent=25

堆内存的使用率达到30%之后就会自动启动G1的并发垃圾回收。默认值是45%，这里调低了一些，也就是提高了GC的频率，
但是避免了垃圾对象过多，一次垃圾回收耗时过长的问题
-XX:InitiatingHeapOccupancyPercent=30

JVM会抛弃一些异常堆栈信息
-XX:-OmitStackTraceInFastThrow

是强制让JVM启动的时候直接分配我们指定的内存，不要等到使用内存的时候再分配
-XX:+AlwaysPreTouch

RocketMQ里大量用了NIO中的direct buffer，这里限定了direct buffer最多申请多少
-XX:MaxDirectMemorySize=15g

是禁用大内存页和偏向锁
XX:-UseLargePages -XX:-UseBiasedLocking：
```


#### 压力测试过程
1. 压测目的
应该在TPS和机器的cpu负载、内存使用率、jvm gc频率、磁盘io负载、网络流量负载之间取得一个平衡，尽量让TPS尽可能的提高，同时让机器的各项资源负载不要太高。

2. 压测过程：
采用几台机器开启大量线程并发读写消息。然后观察TPS、cpu load (top)、内存使用率(free), jvm gc频率（jstat), 磁盘io负载（top-wa字段）、网卡流量负载（使用sar命令），不断增加机器和线程，让TPS不断提升上去，同时观察各项资源负载是否过高。

#### RocketMQ发送消息
1. 同步发送消息
2. 异步发送消息
3. 单向发送消息
#### RocketMQ消费模式
1. PUSH消费模式
2. PULL消费模式

#### Topic、MessageQueue、Broker

```bash
$HOME/store/consumequeue/{topic}/{queueId}/{fileName}
```