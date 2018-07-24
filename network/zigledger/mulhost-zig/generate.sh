#!/usr/bin/env bash
export ZIGLEDGER_CFG_PATH=${PWD}
#~/go/src/github.com/zhigui/zigledger/build/bin/cryptogen generate --config=./crypto-config.yaml
#~/go/src/github.com/zhigui/zigledger/build/bin/configtxgen -profile TwoOrgsOrdererGenesis -outputBlock twoorgs.genesis.block
#~/go/src/github.com/zhigui/zigledger/build/bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx mychannel.tx -channelID mychannel

../../../fvt/test/devops/bin/cryptogen generate --config=./crypto-config.yaml
../../../fvt/test/devops/bin/configtxgen -profile TwoOrgsOrdererGenesis -outputBlock twoorgs.genesis.block
../../../fvt/test/devops/bin/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx mychannel.tx -channelID mychannel
