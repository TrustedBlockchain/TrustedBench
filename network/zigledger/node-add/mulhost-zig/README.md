
### 配置 /etc/hosts

```bash
192.168.0.40 kafka0 orderer.example.com zookeeper0
192.168.0.36 kafka1 zookeeper1 peer0.org2.example.com
192.168.0.37 peer1.org2.example.com  kafka2 zookeeper2
192.168.0.41 peer1.org1.example.com kafka3
192.168.0.39 peer0.org1.example.com ca0 
192.168.0.38 peer0.org2.example.com ca1

```

执行步骤：
-----------

### 在 host5（peer0org1 所在节点）直接根据现有的网络配置，去执行基本的环境初始化操作

```bash
./byfn.sh up 
```

### 在 host5 中操作生成 Org3 所需要的：

1. 证书
2. 配置文件
3. 更新 Org3 的配置区块并通过 peer0org1 更新到 orderer 里

```bash
./eyfn.sh up
```

### （新增节点）操作

host2 是需要新增的节点，在这个节点里的主要操作是:

1. 使用 docker-compose-org3.yaml 启动 peer0org3 节点，启动的时候需要把之前在 host5 上生成的 /org3-artifacts/crypto-config 
移到 host2 相应位置

```bash
cd ~/official/zig-test/network/zigledger/node-add/mulhost-zig/org3-artifacts/
scp -r root@192.168.0.39:/root/zig-test/network/zigledger/node-add/mulhost-zig/org3-artifacts/crypto-config .
```

2. 使 peer0org3 节点加入到 mychannel 中，并验证

```bash
./org3-eyfn.sh up
```

### 在 host5（peer0org1 所在节点）升级 chaincode

```bash
docker exec mulhost-zig_cli_1 ./scripts/step3org3.sh
```

### 测试此节点是否有效（需要在peer0org1里执行完chaincode升级之后操作）， 在host2中执行

```bash
docker exec mulhost-zig_Org3cli_1 ./scripts/testorg3.sh
```

### 加入过程中持续发送交易，查看结果
