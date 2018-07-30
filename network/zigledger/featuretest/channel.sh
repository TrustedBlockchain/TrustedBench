#!/bin/bash
#
# Copyright Ziggurat Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

function networkUp() {
	echo create channel and join channel
	createChannel
	joinChannel 1
	joinChannel 2
	echo
	echo Waiting 10s for db initialization
	echo
    sleep 10
}

function createChannel () {
    echo
    echo "POST request Create channel"
    curl -s -X POST \
      http://zigerface-fullserver.org1:8081/create-channel \
      -H "content-type: application/json" \
      -d "{
    	\"channelName\":\"mychannel\",
    	\"channelConfigPath\":\"../../config/artifacts/channel/mychannel.tx\"
    }"
    echo
    sleep 6
}

function joinChannel () {
    org=$1
    echo
    echo "POST request Join channel on Org1"
    curl -s -X POST \
      http://zigerface-fullserver.org1:8081/join-channel \
      -H "content-type: application/json" \
      -d "{
    	\"channelName\":\"mychannel\",
    	\"org\":\"org$org\",
    	\"peers\":[\"peer1\",\"peer2\"]
    }"
    echo
    sleep 6
}

networkUp
