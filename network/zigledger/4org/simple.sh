#!/bin/bash
#
# Copyright Ziggurat Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

echo
echo "POST request Install chaincode on Org1"
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/install-cc \
  -H "content-type: application/json" \
  -d '{
  	"org":"org1",
	"peers":["peer1","peer2"],
	"chaincodeName":"simple",
	"chaincodePath":"github.com/simple",
	"chaincodeVersion":"v0"
}' | jq '.'

echo
echo "POST request Install chaincode on Org2"
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/install-cc \
  -H "content-type: application/json" \
  -d '{
  	"org":"org2",
	"peers":["peer1","peer2"],
	"chaincodeName":"simple",
	"chaincodePath":"github.com/simple",
	"chaincodeVersion":"v0"
}' | jq '.'

echo
echo "POST request Instantiate chaincode on endorse peers"
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/instantiate-cc \
  -H "content-type: application/json" \
  -d '{
	"chaincodeName":"simple",
	"chaincodeVersion":"v0",
	"channelName":"mychannel",
	"fcn":"init",
	"args":[]
}' | jq '.'
