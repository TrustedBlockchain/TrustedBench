
### 配置 /etc/hosts

```bash


zig-host1: 39.108.92.116/192.168.0.40
zig-host2: 120.77.37.204/192.168.0.36
zig-host3: 120.79.132.6/192.168.0.37
zig-host4: 112.74.191.73/192.168.0.41
zig-host5: 39.108.169.0/192.168.0.39
zig-host6: 120.79.191.199/192.168.0.38


192.168.0.40 kafka0 orderer.example.com zookeeper0
192.168.0.36 kafka1 zookeeper1 
192.168.0.37 peer1.org2.example.com  kafka2 zookeeper2
192.168.0.41 peer1.org1.example.com kafka3
192.168.0.39 peer0.org1.example.com ca0 
192.168.0.38 peer0.org2.example.com ca1

```

需要开放 7050 7051 7053 7054