
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

CHANNEL_NAME=mychannel
ORDERER_CA=/opt/gopath/src/github.com/zhigui/zigledger/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
CC_SRC_PATH="github.com/chaincode/token/go/"

CC_SRC_PATH="github.com/chaincode/chaincode_example02/go/"

peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/mychannel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

peer channel join -b $CHANNEL_NAME.block

peer channel update -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA

peer chaincode install -n token -v 1.0 -l golang -p ${CC_SRC_PATH}

peer chaincode install -n mycc -v 1.0 -l golang -p ${CC_SRC_PATH}

peer chaincode instantiate -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -l golang -v 1.0 -c '{"Args":["init","a","100","b","200"]}' -P "OR  ('Org1MSP.peer' ,'Org2MSP.peer')"

peer chaincode instantiate -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n token -l golang -v 1.0 -c '{"Args":["init"]}' -P "OR ('Org1MSP.peer','Org2MSP.peer')"

peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

peer chaincode invoke -o orderer.example.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n ascc -c '{"Args":["registerAndIssueToken","INK","1000000000000000000","18","i4230a12f5b0693dd88bb35c79d7e56a68614b199"]}'

peer chaincode invoke -o orderer.example.com:7050  --tls true --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}' -i "100000000000" -z bc4bcb06a0793961aec4ee377796e050561b6a84852deccea5ad4583bb31eebe

peer chaincode invoke -o orderer.example.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C ${CHANNEL_NAME} -n token -c '{"Args":["transfer","i07caf88941eafcaaa3370657fccc261acb75dfba","INK","9999999999960"]}' -i "10000000" -z bc4bcb06a0793961aec4ee377796e050561b6a84852deccea5ad4583bb31eebe

peer chaincode upgrade -o orderer.example.com:7050 --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -v 2.0 -c '{"Args":["init","a","90","b","210"]}'

peer chaincode query -C mychannel -n token -c '{"Args":["getBalance","i07caf88941eafcaaa3370657fccc261acb75dfba","INK"]}'

peer chaincode query -C mychannel -n token -c '{"Args":["getBalance","i4230a12f5b0693dd88bb35c79d7e56a68614b199","INK"]}'



