修改配置
--------

All-in-one  操作步骤
--------

```bash
./orderer-config.sh -m up
```

1.需要在cli里映射 config-channel/config-scripts 到cli的工作目录

- ./peer-manage/config-channel/config-scripts:/opt/gopath/src/github.com/zhigui/zigledger/config-scripts/


2.bin 文件copy 过来

crypto-config 映射到cli的工作目录
- ./crypto-config:/opt/gopath/src/github.com/zhigui/zigledger/peer/crypto/

- ./crypto-config:/etc/zhigui/msp/crypto/

chaincode也需要映射
- ./chaincode/:/opt/gopath/src/github.com/chaincode


