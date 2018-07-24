#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# Parse commandline args
while getopts "h?m:c:t:d:f:s:l:" opt; do
  case "$opt" in
    h|\?)
      printHelp
      exit 0
    ;;
    m)  MODE=$OPTARG
    ;;
  esac
done

# Print the usage message
function printHelp () {
  echo "Usage: "
  echo "      runZigledger.sh -m up|down|restart"
  echo "      - 'up' - bring up the network with docker-compose up"
  echo "      - 'down' - clear the network with docker-compose down"
  echo "      - 'restart' - restart the network"
}


function dkcl(){
        CONTAINER_IDS=$(docker ps -aq)
	echo
        if [ -z "$CONTAINER_IDS" -o "$CONTAINER_IDS" = " " ]; then
                echo "========== No containers available for deletion =========="
        else
                docker rm -f $CONTAINER_IDS
        fi
	echo
}

function dkrm(){
        DOCKER_IMAGE_IDS=$(docker images | grep "dev\|none\|test-vp\|peer[0-9]-" | awk '{print $3}')
	echo
        if [ -z "$DOCKER_IMAGE_IDS" -o "$DOCKER_IMAGE_IDS" = " " ]; then
		echo "========== No images available for deletion ==========="
        else
                docker rmi -f $DOCKER_IMAGE_IDS
        fi
	echo
}

function networkUp() {
	echo

	echo Copy tendermint orderer config
	cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer0.example.com/tendermint/node_key.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer0.example.com/tendermint/testchainid/config;
    cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer0.example.com/tendermint/node_key.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer0.example.com/tendermint/mychannel/config;
    cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer0.example.com/tendermint/priv_validator.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer0.example.com/tendermint/testchainid/config;
    cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer0.example.com/tendermint/priv_validator.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer0.example.com/tendermint/mychannel/config;
    cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/tendermint/node_key.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/tendermint/testchainid/config;
    cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/tendermint/node_key.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/tendermint/mychannel/config;
    cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/tendermint/priv_validator.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/tendermint/testchainid/config;
    cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/tendermint/priv_validator.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/tendermint/mychannel/config;
    cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/node_key.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/testchainid/config;
    cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/node_key.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/mychannel/config;
    cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/priv_validator.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/testchainid/config;
    cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/priv_validator.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/mychannel/config;
    cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tendermint/node_key.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tendermint/testchainid/config;
    cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tendermint/node_key.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tendermint/mychannel/config;
    cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tendermint/priv_validator.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tendermint/testchainid/config;
    cp ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tendermint/priv_validator.json ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tendermint/mychannel/config;
	echo

	echo Start the network
	docker-compose -f docker-compose.yaml up -d
#	sleep 5
#	createChannel
#	joinChannel
#	sleep 5
#	docker-compose -f docker-compose-listener.yaml up -d
	echo
}

function networkDown() {
	echo
    echo teardown the network and clean the containers and intermediate images
	docker-compose -f docker-compose.yaml down
#	docker-compose -f docker-compose-listener.yaml down
	#dkcl
	#dkrm

    echo Cleanup the stores
    rm -rf /tmp/zigledger-client-kvs*
    rm -rf /tmp/data
    rm -rf ./zigledger-client-kvs_peerOrg1/*

    echo Clean tendermint config
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer0.example.com/tendermint/mychannel/config/*;
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer0.example.com/tendermint/testchainid/config/*;
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/tendermint/mychannel/config/*;
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/tendermint/testchainid/config/*;
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/mychannel/config/*;
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/testchainid/config/*;
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tendermint/mychannel/config/*;
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tendermint/testchainid/config/*;
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer0.example.com/tendermint/mychannel/data/*;
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer0.example.com/tendermint/testchainid/data/*;
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/tendermint/mychannel/data/*;
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer1.example.com/tendermint/testchainid/data/*;
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/mychannel/data/*;
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer2.example.com/tendermint/testchainid/data/*;
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tendermint/mychannel/data/*;
    rm -rf ./crypto-config/ordererOrganizations/example.com/orderers/orderer3.example.com/tendermint/testchainid/data/*;
}

function networkRestart() {
    networkDown
    networkUp
	echo
}

#Create the network using docker compose
if [ "${MODE}" == "up" ]; then
  networkUp
  elif [ "${MODE}" == "down" ]; then ## Clear the network
  networkDown
  elif [ "${MODE}" == "restart" ]; then ## Restart the network
  networkRestart
else
  printHelp
  exit 1
fi
