

#!/usr/bin/env bash

export CHANNEL_NAME=mychannel
export ORDERER_CA=/opt/gopath/src/github.com/zhigui/zigledger/peer/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
echo "Checking service"

while true
do
    echo "Send a query transaction"
    docker exec mulhost-zig_cli_1 peer chaincode query -C mychannel -n token -c '{"Args":["getBalance","i4230a12f5b0693dd88bb35c79d7e56a68614b199","INK"]}'
    sleep 2
    echo "Send a transfer transaction"
    docker exec mulhost-zig_cli_1 peer chaincode invoke -o orderer.example.com:7050  --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA -C ${CHANNEL_NAME} -n token -c '{"Args":["transfer","i07caf88941eafcaaa3370657fccc261acb75dfba","INK","9999999999960"]}' -i "10000000" -z bc4bcb06a0793961aec4ee377796e050561b6a84852deccea5ad4583bb31eebe
    sleep 2
done

