
### 配置 /etc/hosts

```bash


zig-host1: 39.108.92.116
zig-host2: 120.77.37.204
zig-host3: 120.79.132.6
zig-host4: 112.74.191.73
zig-host5: 39.108.169.0
zig-host6: 120.79.191.199


39.108.92.116 kafka0 orderer.example.com zookeeper0
120.77.37.204 kafka1 zookeeper1 
120.79.132.6  peer1.org2.example.com  kafka2 zookeeper2
112.74.191.73 peer1.org1.example.com kafka3
39.108.169.0  peer0.org1.example.com ca0 
120.79.191.199 peer0.org2.example.com ca1

```