#!/usr/bin/env bash

export CHANNEL_NAME=mychannel
export ORDERER_CA=/opt/gopath/src/github.com/zhigui/zigledger/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
echo "Checking service"

while true
do
    echo "Send a query transaction"
    docker exec cli peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
    sleep 2
    echo "Send a transfer transaction"
    docker exec cli peer chaincode invoke -o orderer.example.com:7050  --tls --cafile $ORDERER_CA -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","1"]}' -i "1000000000" -z bc4bcb06a0793961aec4ee377796e050561b6a84852deccea5ad4583bb31eebe
    sleep 2
done