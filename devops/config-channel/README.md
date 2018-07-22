修改配置
--------

All-in-one  操作步骤
--------

1. ./byfn.sh -m generate

2. ./byfn.sh -m up




分步操作解析
---------------

1. batch size(出块大小)

2. batch timeout(出块时间)


1. 获取初始的配置区块，并转换成json格式(只要data.data[0].payload.data.config部分)

2. 修改json文件，修改区块的交易比数，出块时间，和块的大小

3. 把修改好的json文件在转换成pb格式

4. 把修改好的pb更新到channel, 并得到另一个 config_update.pb 

5. 把config_update.pb 在转成json格式

6. 包装config_update.json 成 envelope.json

7. envelope.json 转换成 envelope.pb

8. 最后 把envelope.pb 更新到channel, peer channel update


apt-get update &&  apt-get install jq


## 动态修改每个区块的最大个数/出块时间

### 1. 获取初始的配置区块，并转换成json格式

```bash
docker exec -it cli bash

apt-get update &&  apt-get install jq

export ORDERER_CA=/opt/gopath/src/github.com/zhigui/zigledger/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem && export CHANNEL_NAME=mychannel

peer channel fetch config config_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json

```

### 2. 修改config.json 文件，修改区块交易比数、出块时间、块大小

```bash
jq ".channel_group.groups.Orderer.values.BatchSize.value.max_message_count = 20" config.json  > updated_config.json

jq ".channel_group.groups.Orderer.values.BatchTimeout.value.timeout=\"5s\"" config.json > updated_config.json

jq ".channel_group.groups.Orderer.values.BatchTimeout.value.absolute_max_bytes=10485760" config.json > updated_config.json

```

### 3. 把修改好的配置文件转换成pb格式

```bash

configtxlator proto_encode --input config.json --type common.Config --output config.pb
configtxlator proto_encode --input updated_config.json --type common.Config --output updated_config.pb

```

### 4. 计算两个pb文件的delta

```bash
configtxlator compute_update --channel_id $CHANNEL_NAME --original config.pb --updated updated_config.pb --output finally_update.pb
```

### 5. 把 finally_update.pb 转换成 json格式

```bash
configtxlator proto_decode --input finally_update.pb --type common.ConfigUpdate | jq . > finally_update.json
```

### 6. 包装 finally_update.json

```bash
echo '{"payload":{"header":{"channel_header":{"channel_id":"mychannel", "type":2}},"data":{"config_update":'$(cat finally_update.json)'}}}' | jq . > finally_update_in_envelope.json
```

### 7. 在把envelop格式的文件转换为pb格式

```bash
configtxlator proto_encode --input finally_update_in_envelope.json --type common.Envelope --output finally_update_in_envelope.pb
```

### 8. send them to the configtxlator service to compute the config update which transitions between the two.

```bash
peer channel signconfigtx -f finally_update_in_envelope.pb
```

### 9. Finally, submit the config update transaction to ordering to perform a config update.

```bash
CORE_PEER_LOCALMSPID=OrdererMSP
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/zhigui/zigledger/peer/crypto/ordererOrganizations/example.com/users/Admin@example.com/msp

peer channel update -o orderer.example.com:7050 -c mychannel -f finally_update_in_envelope.pb --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA


```

### 10. verify 

```bash
peer channel fetch config config_new_block.pb -o orderer.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

configtxlator proto_decode --input config_new_block.pb --type common.Block | jq .data.data[0].payload.data.config > config_new_block.json

export MAXBATCHSIZEPATH=".data.data[0].payload.data.config.channel_group.groups.Orderer.values.BatchSize.value.max_message_count"
export MAXTIMEOUT=".data.data[0].payload.data.config.channel_group.groups.Orderer.values.BatchTimeout.value.timeout"


export MAXBATCHSIZEPATH=".channel_group.groups.Orderer.values.BatchSize.value.max_message_count"
export MAXTIMEOUT=".channel_group.groups.Orderer.values.BatchTimeout.value.timeout"

jq $MAXBATCHSIZEPATH config_new_block.json
jq $MAXTIMEOUT config_new_block.json

```
