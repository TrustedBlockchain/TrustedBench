
1.需要把现有的 crypto-config/ordererOrganizations 移到此目录的 crypto-config
2.辅助的 bin 文件 copy 到目标路径 

## cli1里操作：
./node-add.sh up


把新生成的node-add/org3-artifacts/crypto-config/peerOrganizations/org3.example.com 拷贝到总的 crypto-config/peerOrganizations
这样 cli1 有了全量的 MSP

```bash
cd /root/zig-test/network/zigledger/featuretestbft
cp -r peer-manage/node-add/org3-artifacts/crypto-config/peerOrganizations/org3.example.com  crypto-config/peerOrganizations/
```

## 在被增加 node 里操作

copy 在第一步里生成的证书密钥

```bash
cd /root/official/zig-test/network/zigledger/featuretestbft/peer-manage/node-add/org3-artifacts

#scp -r root@47.106.221.204:/root/zig-test/network/zigledger/featuretestbft/peer-manage/node-add/org3-artifacts/crypto-config .

scp -r root@47.106.221.204:/root/zig-test/network/zigledger/featuretestbft/crypto-config .

(cli3 里也有了全量的MSP，方便多方运维)

```

./org3-up.sh up

## 在cli1里操作：
docker exec featuretestbft_cli.org1.example.com_1 ./add-scripts/step3org3.sh

## 在被增加节点里操作
docker exec node-add_cli.org3.example.com_1 ./add-scripts/testorg3.sh
