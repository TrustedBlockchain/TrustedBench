
all-in-one
---------------


./byfn.sh -m generate

./byfn.sh -m up

./eyfn.sh up

注：如果要保证查询结果的连贯性，要注视掉step3org3.sh 中的 upgrade，因为这个操作会重置 a/b的值。

分步操作
------------------


1. 创建新节点 org3/peer0 所需要的 configtx.yaml 和 org3-crypto.yaml 


2. 生成 org3 所需要的 crypto 文件

```bash
cd org3-artifacts

../../bin/cryptogen generate --config=./org3-crypto.yaml

```

3. 生成 org3 相关的配置文件

```bash
cd org3-artifacts
export ZIGLEDGER_CFG_PATH=$PWD && ../../bin/configtxgen -printOrg Org3MSP > ../channel-artifacts/org3.json

```
会在 channel-artifacts 目录 生成 org3.json 文件

4. 把 orderer's TLS root cert 放到 刚才生成的 org3-artifacts 文件夹

```bash
cd ../ && cp -r crypto-config/ordererOrganizations org3-artifacts/crypto-config/
```

5. 准备 CLI 环境

```bash
docker exec -it cli bash

apt update && apt install -y jq

export ORDERER_CA=/opt/gopath/src/github.com/zhigui/zigledger/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem  && export CHANNEL_NAME=mychannel

echo $ORDERER_CA && echo $CHANNEL_NAME
```

6. 获取配置内容

```bash

peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

```

7. 转换配置文件的格式并裁剪，第一次转换完叫 config.json

```bash
configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

```

8. 添加 org3 加密部分

```bash
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' config.json ./channel-artifacts/org3.json > modified_config.json
```

9. 把 config.json 转换成 config.pb 

```bash
configtxlator proto_encode --input config.json --type common.Config --output config.pb
```

10. 把 modified_config.json 转换成 modified_config.pb

```bash
configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
```

11. 计算config.pb 和 modified_config.pb 的增量，输出 org3_update.pb

```bash
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated modified_config.pb --output org3_update.pb
```

12. 把 org3_update.pb 转换成 org3_update.json

```bash
configtxlator proto_decode --input org3_update.pb --type common.ConfigUpdate | jq . > org3_update.json
```

13. 重新包装 org3_update.json 并得到 org3_update_in_envelope.json

```bash
echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat org3_update.json)'}}}' | jq . > org3_update_in_envelope.json
```


14. 把org3_update_in_envelope.json 转换成 org3_update_in_envelope.pb

```bash
configtxlator proto_encode --input org3_update_in_envelope.json --type common.Envelope --output org3_update_in_envelope.pb

```

15. 签名并提交配置更新

```bash
peer channel signconfigtx -f org3_update_in_envelope.pb
```

16. 把 cli 容器的身份改成 org2 admin user的

```bash
export CORE_PEER_LOCALMSPID="Org2MSP"

export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/zhigui/zigledger/peer/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt

export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/zhigui/zigledger/peer/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp

export CORE_PEER_ADDRESS=peer0.org2.example.com:7051
```

17. update

```bash
peer channel update -f org3_update_in_envelope.pb -c $CHANNEL_NAME -o orderer.example.com:7050 --tls --cafile $ORDERER_CA
```

*18. 配置 leader 选举

配置peer 为组织leader

```bash
CORE_PEER_GOSSIP_USELEADERELECTION=false
CORE_PEER_GOSSIP_ORGLEADER=true
```

```bash
CORE_PEER_GOSSIP_USELEADERELECTION=true
CORE_PEER_GOSSIP_ORGLEADER=flase

```

19. org3 加入 channel

因为用的同一个网络，所以新启的这个三个容器可以和之前的融合。
```bash
docker-compose -f docker-compose-org3.yaml up -d

docker exec -it Org3cli bash

export ORDERER_CA=/opt/gopath/src/github.com/zhigui/zigledger/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem && export CHANNEL_NAME=mychannel

echo $ORDERER_CA && echo $CHANNEL_NAME
```


20. 获取初始区块，并重命名为 mychannel.block

```bash
peer channel fetch 0 mychannel.block -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA
```

21. join peer0org3 到 channel

```bash
peer channel join -b mychannel.block
```

* 22. join peer1org3 到 channel

```bash
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/zhigui/zigledger/peer/crypto/peerOrganizations/org3.example.com/peers/peer1.org3.example.com/tls/ca.crt && export CORE_PEER_ADDRESS=peer1.org3.example.com:7051

peer channel join -b mychannel.block
```

23. upgrade 和 invoke chaincode

```bash
in Org3 cli:

peer chaincode install -n mycc -v 2.0 -p github.com/chaincode/chaincode_example02/go/
```

在最开始的cli容器，不过在之前这个cli被改成了 peer0org2的身份

```bash
peer chaincode install -n mycc -v 2.0 -p github.com/chaincode/chaincode_example02/go/
```

跳转到 peer0org1 的身份，并执行 install

```bash

export CORE_PEER_LOCALMSPID="Org1MSP"

export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/zhigui/zigledger/peer/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt

export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/zhigui/zigledger/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp

export CORE_PEER_ADDRESS=peer0.org1.example.com:7051

peer chaincode install -n mycc -v 2.0 -p github.com/chaincode/chaincode_example02/go/

```


*24. 修改背书策略，使用 mycc的 2.0 版本。

```bash
peer chaincode upgrade -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -v 2.0 -c '{"Args":["init","a","90","b","210"]}' -P "OR ('Org1MSP.peer','Org2MSP.peer','Org3MSP.peer')"
```

25. 验证

在 peer0org3-cli

```bash
peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

peer chaincode invoke -o orderer.example.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}'
peer chaincode invoke -o orderer.example.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}' -i "1000000000" -z bc4bcb06a0793961aec4ee377796e050561b6a84852deccea5ad4583bb31eebe

peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

```





配置文件的变迁：

最新的链配置文件 config_block.pb

对 config_block.pb 进行裁剪，得到 config.json

对 config.json 进行org3部分添加 得到 modified_config.json

把 config.json 转换成 config.pb 

把 modified_config.json 转换成 modified_config.pb

使用 configtxlator 计算 config.pb 和 modified_config.pb 差异, 得到 org3_update.pb

把 org3_update.pb 转换成 org3_update.json

重新包装 org3_update.json 并得到 org3_update_in_envelope.json

把org3_update_in_envelope.json 转换成 org3_update_in_envelope.pb


