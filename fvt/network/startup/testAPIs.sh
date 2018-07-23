#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# Language defaults to "golang"

starttime=$(date +%s)

echo
echo "POST request Create channel  ..."
echo
curl -s -X POST \
  http://localhost:8081/create-channel \
  -H "content-type: application/json" \
  -d '{
	"channelName":"mychannel",
	"channelConfigPath":"../../../config/artifacts/channel/mychannel.tx"
}'
echo
echo
sleep 3

echo "POST request Join channel on Org1"
echo
curl -s -X POST \
  http://localhost:8081/join-channel \
  -H "content-type: application/json" \
  -d '{
	"channelName":"mychannel",
    "org":"org1",
	"peers":["peer1", "peer2"]
}'
echo
echo

echo "POST request Join channel on Org2"
echo
curl -s -X POST \
  http://localhost:8081/join-channel \
  -H "content-type: application/json" \
  -d '{
	"channelName":"mychannel",
    "org":"org2",
	"peers":["peer1","peer2"]
}'
echo
echo

echo "POST Install chaincode on Org1"
echo
curl -s -X POST \
  http://localhost:8081/install-cc \
  -H "content-type: application/json" \
  -d '{
  	"org":"org1",
	"peers":["peer1","peer2"],
	"chaincodeName":"token",
	"chaincodePath":"github.com/token",
	"chaincodeVersion":"1.0"
}'
echo
echo

echo "POST Install chaincode on Org2"
echo
curl -s -X POST \
  http://localhost:8081/install-cc \
  -H "content-type: application/json" \
  -d '{
  	"org":"org2",
	"peers":["peer1","peer2"],
	"chaincodeName":"token",
	"chaincodePath":"github.com/token",
	"chaincodeVersion":"1.0"
}'
echo
echo

echo "POST instantiate chaincode on endorse peers"
echo
curl -s -X POST \
  http://localhost:8081/instantiate-cc \
  -H "content-type: application/json" \
  -d '{
	"chaincodeName":"token",
	"chaincodeVersion":"1.0",
	"channelName":"mychannel",
	"fcn":"init",
	"args":[]
}'
echo
echo

parse_json(){
echo "${1//\"/}" | sed "s/.*$2:\([^,}]*\).*/\1/"
}

echo "start register issue token account..."
echo
echo "request Get User register token..."
result=$(curl -s -X POST \
  http://localhost:8081/user/register/token \
  -H "content-type: application/json" \
  -d '{
	"username":"issue"
}')
echo
echo $result
value=$(parse_json $result "data")
echo

echo "request User register..."
echo
curl -s -X POST \
  http://localhost:8081/user/register \
  -H "content-type: application/json" \
  -d '{
	"username":"issue",
	"token":"'$value'"
}'
echo
echo
sleep 3

echo "request Account register..."
echo
curl -s -X POST \
  http://localhost:8081/account/register \
  -H "content-type: application/json" \
  -d '{
	"username":"issue",
	"address":"i411b6f8f24f28caafe514c16e11800167f8ebd89"
}'
echo
echo

echo "POST issue token on peer1 of Org1"
echo
curl -s -X POST \
  http://localhost:8081/issue-token \
  -H "content-type: application/json" \
  -d '{
	"coin_name":"INK",
	"totalSupply":"10000000000000000000",
	"decimals":"9",
	"publish_address":"i411b6f8f24F28CaAFE514c16E11800167f8EBd89"
}'
echo
echo
sleep 3

echo "POST invoke transfer"
echo
curl -s -X POST \
  http://localhost:8081/transfer \
  -H "content-type: application/json" \
  -d '{
	"to_address":"iac0726c75c3a5a1879f53c9f1573d254fd9a4e60",
	"from_address":"i411b6f8f24f28caafe514c16e11800167f8ebd89",
	"coin_type":"INK",
	"amount":"100000000000",
	"message":"test",
	"fee_limit":"100000000000",
	"sig":"c9e9f1c099699d10868e0a9c7da65299152f6fac85be3b55a051abb3de958139527bc44e5ebdba31d8ad6e83da42e25b0d7efeb11a8ba2382dfbd3e68e5a005600"
}'
echo
echo
