#!/bin/bash
#
# Copyright Ziggurat Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

#echo
#echo "POST request Create channel  ..."
#curl -s -X POST \
#  http://zigerface-fullserver.org1:8081/create-channel \
#  -H "content-type: application/json" \
#  -d '{
#	"channelName":"mychannel",
#	"channelConfigPath":"../../config/artifacts/channel/mychannel.tx"
#}' | jq '.'
#sleep 3
#
#echo
#echo "POST request Join channel on Org1"
#curl -s -X POST \
#  http://zigerface-fullserver.org1:8081/join-channel \
#  -H "content-type: application/json" \
#  -d '{
#	"channelName":"mychannel",
#   "org":"org1",
#	"peers":["peer1", "peer2"]
#}' | jq '.'
#
#echo
#echo "POST request Join channel on Org2"
#curl -s -X POST \
#  http://zigerface-fullserver.org1:8081/join-channel \
#  -H "content-type: application/json" \
#  -d '{
#	"channelName":"mychannel",
#   "org":"org2",
#	"peers":["peer1","peer2"]
#}' | jq '.'

echo
echo "POST request Install chaincode on Org1"
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/install-cc \
  -H "content-type: application/json" \
  -d '{
  	"org":"org1",
	"peers":["peer1","peer2"],
	"chaincodeName":"token",
	"chaincodePath":"github.com/token",
	"chaincodeVersion":"1.0"
}' | jq '.'

echo
echo "POST request Install chaincode on Org2"
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/install-cc \
  -H "content-type: application/json" \
  -d '{
  	"org":"org2",
	"peers":["peer1","peer2"],
	"chaincodeName":"token",
	"chaincodePath":"github.com/token",
	"chaincodeVersion":"1.0"
}' | jq '.'

echo
echo "POST request Instantiate chaincode on endorse peers"
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/instantiate-cc \
  -H "content-type: application/json" \
  -d '{
	"chaincodeName":"token",
	"chaincodeVersion":"1.0",
	"channelName":"mychannel",
	"fcn":"init",
	"args":[]
}' | jq '.'

echo
echo "POST request Issue token"
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/issue-token \
  -H "content-type: application/json" \
  -d '{
	"coin_name":"INK",
	"totalSupply":"10000000000000000000",
	"decimals":"9",
	"publish_address":"i411b6f8f24F28CaAFE514c16E11800167f8EBd89"
}' | jq '.'

##################################################################
parse_json(){
echo "${1//\"/}" | sed "s/.*$2:\([^,}]*\).*/\1/"
}

echo
echo "POST request Register issue token account"
token=$(curl -s -X POST \
  http://zigerface-fullserver.org1:8081/user/register/token \
  -H "content-type: application/json" \
  -d '{
	"username":"issue"
}' | jq '.data')

curl -s -X POST \
  http://zigerface-fullserver.org1:8081/user/register \
  -H "content-type: application/json" \
  -d '{
	"username":"issue",
	"token":'$token'
}' | jq '.'

echo
echo "POST request Register account"
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/account/register \
  -H "content-type: application/json" \
  -d '{
	"username":"issue",
	"address":"i411b6f8f24f28caafe514c16e11800167f8ebd89"
}' | jq '.'
echo
