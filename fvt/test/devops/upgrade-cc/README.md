
all-in-one
---------------


./byfn.sh -m generate

./byfn.sh -m up

分步操作
------------------

```bash
docker exec -it cli bash


export ORDERER_CA=/opt/gopath/src/github.com/zhigui/zigledger/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

export CC_SRC_PATH="github.com/chaincode/chaincode_example02/go/"

export VERSION=2.0

export CHANNEL_NAME=mychannel

export ORDERER_CA=/opt/gopath/src/github.com/zhigui/zigledger/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

peer chaincode install -n mycc -v 2.0 -l golang -p ${CC_SRC_PATH}

peer chaincode upgrade -o orderer.example.com:7050 --tls true --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -v 2.0 -c '{"Args":["init","a","90","b","210"]}' -P "OR ('Org1MSP.peer','Org2MSP.peer')"

peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'

```