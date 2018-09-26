#!/usr/bin/env bash
$GOPATH/src/github.com/zhigui/zigledger/build/bin/cryptogen generate --config=./crypto-config.yaml
$GOPATH/src/github.com/zhigui/zigledger/build/bin/configtxgen -profile FourOrgsOrdererGenesis -outputBlock fourorgs.genesis.block
$GOPATH/src/github.com/zhigui/zigledger/build/bin/configtxgen -profile FourOrgsChannel -outputCreateChannelTx mychannel.tx -channelID mychannel