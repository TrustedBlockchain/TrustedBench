#!/bin/bash

echo
echo " ____    _____      _      ____    _____ "
echo "/ ___|  |_   _|    / \    |  _ \  |_   _|"
echo "\___ \    | |     / _ \   | |_) |   | |  "
echo " ___) |   | |    / ___ \  |  _ <    | |  "
echo "|____/    |_|   /_/   \_\ |_| \_\   |_|  "
echo
echo "Config network"
echo
CHANNEL_NAME="$1"
DELAY="$2"
LANGUAGE="$3"
TIMEOUT="$4"
: ${CHANNEL_NAME:="mychannel"}
: ${DELAY:="3"}
: ${LANGUAGE:="golang"}
: ${TIMEOUT:="10"}
LANGUAGE=`echo "$LANGUAGE" | tr [:upper:] [:lower:]`
COUNTER=1
MAX_RETRY=5
ORDERER_CA=/etc/zhigui/msp/crypto/ordererOrganizations/example.com/orderers/orderer0.example.com/msp/tlscacerts/tlsca.example.com-cert.pem

CC_SRC_PATH="github.com/chaincode/chaincode_example02/go/"
if [ "$LANGUAGE" = "node" ]; then
	CC_SRC_PATH="/opt/gopath/src/github.com/chaincode/chaincode_example02/node/"
fi

echo "Channel name : "$CHANNEL_NAME

# import utils
. config-scripts/utils.sh
. config-scripts/colour.sh

createChannel() {
	setGlobals 0 1

	if [ -z "$CORE_PEER_TLS_ENABLED" -o "$CORE_PEER_TLS_ENABLED" = "false" ]; then
                set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/mychannel.tx >&log.txt
		res=$?
                set +x
	else
				set -x
		peer channel create -o orderer.example.com:7050 -c $CHANNEL_NAME -f ./channel-artifacts/mychannel.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA >&log.txt
		res=$?
				set +x
	fi
	cat log.txt
	verifyResult $res "Channel creation failed"
	echo "===================== Channel \"$CHANNEL_NAME\" is created successfully ===================== "
	echo
}

joinChannel () {
	for org in 1 2; do
	    for peer in 0 1; do
		joinChannelWithRetry $peer $org
		echo "===================== peer${peer}.org${org} joined on the channel \"$CHANNEL_NAME\" ===================== "
		sleep $DELAY
		echo
	    done
	done
}

## Create channel
#echo "Creating channel..."
#createChannel

## Join all the peers to the channel
#echo "Having all peers join the channel..."
#joinChannel

## Set the anchor peers for each org in the channel
#echo "Updating anchor peers for org1..."
#updateAnchorPeers 0 1
#echo "Updating anchor peers for org2..."
#updateAnchorPeers 0 2

## Install chaincode on peer0.org1 and peer0.org2
#echo "Installing chaincode on peer0.org1..."
#installChaincode 0 1
#echo "Install chaincode on peer0.org2..."
#installChaincode 0 2

# Instantiate chaincode on peer0.org2
#echo "Instantiating chaincode on peer0.org2..."
#instantiateChaincode 0 2

# Query chaincode on peer0.org1
#echo "Querying chaincode on peer0.org1..."
#chaincodeQuery 0 1 100

#
#echo "send system invoke transaction on peer0.org1"
#systemChaincodeInvoke 0 1

#sleep 3

# Invoke chaincode on peer0.org1
#echo "Sending invoke transaction on peer0.org1..."
#chaincodeInvoke 0 1

## Install chaincode on peer1.org2
#echo "Installing chaincode on peer1.org2..."
#installChaincode 1 2

# Query on chaincode on peer1.org2, check if the result is 90
#echo "Querying chaincode on peer1.org2..."
#chaincodeQuery 1 2 100

echo_b "========= Configing network  =========== "

sleep 5

#echo "Installing jq"
apt-get -y update && apt-get -y install jq

# Fetch the config for the channel, writing it to config.json
fetchChannelConfig ${CHANNEL_NAME} config.json


echo "Before configuration check block's tx number, and the number is"

export MAXBATCHSIZEPATH=".channel_group.groups.Orderer.values.BatchSize.value.max_message_count"
export MAXTIMEOUT=".channel_group.groups.Orderer.values.BatchTimeout.value.timeout"
export MAXBATCHSIZE=".channel_group.groups.Orderer.values.BatchSize.value.max_message_count"

jq $MAXTIMEOUT config.json >&log.txt

echo_b `cat log.txt`

sleep 5

# Modify the configuration to append the new org
set -x

#echo "Config each block's TX"
#jq ".channel_group.groups.Orderer.values.BatchSize.value.max_message_count = 20" config.json  > modified_config.json

echo "Config generate blok's time"
jq ".channel_group.groups.Orderer.values.BatchTimeout.value.timeout=\"3s\"" config.json > modified_config.json

#echo "config block's size"
#jq ".channel_group.groups.Orderer.values.BatchTimeout.value.absolute_max_bytes=10485760" config.json > modified_config.json

set +x

# Compute a config update, based on the differences between config.json and modified_config.json, write it as a transaction to org3_update_in_envelope.pb
createConfigUpdate ${CHANNEL_NAME} config.json modified_config.json finally_update_in_envelope.pb

echo
echo "========= Config transaction to config channel created ===== "
echo

echo "Signing config transaction"
echo
signConfigtxAsPeerOrg 1 finally_update_in_envelope.pb

echo
echo "========= Submitting transaction from a different peer (peer0.org2) which also signs it ========= "
echo
setGlobals 0 2
set -x
peer channel update -f finally_update_in_envelope.pb -c ${CHANNEL_NAME} -o orderer0.example.com:7050 --tls --cafile ${ORDERER_CA}
set +x

echo "Verify================= "

sleep 10

peer channel fetch config config_new_block.pb -o orderer0.example.com:7050 -c $CHANNEL_NAME --tls --cafile $ORDERER_CA

configtxlator proto_decode --input config_new_block.pb --type common.Block | jq .data.data[0].payload.data.config > config_new_block.json

export MAXBATCHSIZEPATH=".channel_group.groups.Orderer.values.BatchSize.value.max_message_count"
export MAXTIMEOUT=".channel_group.groups.Orderer.values.BatchTimeout.value.timeout"
export MAXBATCHSIZE=".channel_group.groups.Orderer.values.BatchSize.value.max_message_count"

jq $MAXTIMEOUT config_new_block.json >&log.txt

echo "After change configuration, check block's tx count"
echo_b `cat log.txt`

echo
echo "========= New channel configuration to network submitted! =========== "
echo

echo
echo " _____   _   _   ____   "
echo "| ____| | \ | | |  _ \  "
echo "|  _|   |  \| | | | | | "
echo "| |___  | |\  | | |_| | "
echo "|_____| |_| \_| |____/  "

exit 0
