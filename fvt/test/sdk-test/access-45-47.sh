#!/bin/bash
#
# Copyright Ziggurat Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# address: i8d49c182fce06146934e6a534c902ba3c5d9bde8
# private_key: 390fd29828e5e029a0c948e17c3a20d98b66ab771803b7ca5e89a3fcc65783d7

username=zhigui
function getTxSign () {
    result=$(curl -s -X POST \
      http://localhost:8081/transaction-sign \
      -H "content-type: application/json" \
      -d '{
    	"ccId":"token",
    	"fcn":"setAccessState",
    	"args":["zhigui","'$1'"],
    	"msg":"",
        "feeLimit":"100000000000",
    	"priKey":"bab0c1204b2e7f344f9d1fbe8ad978d5355e32b8fa45b10b600d64ca970e0dc9"
    }')
    echo $result
}

echo "=============== test 47 : set user access right ==================="
echo "0         none"
echo "1         only read"
echo "2         only write"
echo "3         read write"
echo
echo "first try Query Account ..."
curl -s -X GET http://localhost:8081/get-account/i8d49c182fce06146934e6a534c902ba3c5d9bde8?user=$username | jq '.'

echo
echo "=============== request Set User 'READ' right..."
result=$(getTxSign 1)
signature=$(echo $result | jq ".data.signature")
tx_id=$(echo $result | jq ".data.tx_id")

curl -s -X POST \
  http://localhost:8081/user/access?user=admin \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"$username\",
	\"state\":\"1\",
	\"tx_id\":$tx_id,
	\"sig\":$signature
}" | jq '.'

echo
echo "request Query User access right..."
curl -s -X GET http://localhost:8081/user/access/$username?user=admin | jq '.'

echo
echo "second try Query Account ..."
curl -s -X GET http://localhost:8081/get-account/i8d49c182fce06146934e6a534c902ba3c5d9bde8?user=$username  | jq '.'

echo
echo "=============== request Set User 'write' right...."
echo
echo "first try invoke transfer 'write' ..."

result=$(curl -s -X POST \
  http://localhost:8081/transaction-sign? \
  -H "content-type: application/json" \
  -d '{
	"ccId":"token",
	"fcn":"transfer",
	"args":["i411b6f8f24f28caafe514c16e11800167f8ebd89","INK","1000000"],
	"msg":"test",
    "feeLimit":"100000000000",
	"priKey":"390fd29828e5e029a0c948e17c3a20d98b66ab771803b7ca5e89a3fcc65783d7"
}')
signature=$(echo $result | jq ".data.signature")
tx_id=$(echo $result | jq ".data.tx_id")

curl -s -X POST \
  http://localhost:8081/transfer?user=$username \
  -H "content-type: application/json" \
  -d "{
    \"to_address\":\"i411b6f8f24f28caafe514c16e11800167f8ebd89\",
    \"from_address\":\"i8d49c182fce06146934e6a534c902ba3c5d9bde8\",
    \"coin_type\":\"INK\",
    \"amount\":\"1000000\",
    \"message\":\"test\",
    \"fee_limit\":\"100000000000\",
    \"tx_id\":$tx_id,
    \"sig\":$signature
}" | jq '.'

echo
echo "request Set User 'write' right...."
result=$(getTxSign 2)
signature=$(echo $result | jq ".data.signature")
tx_id=$(echo $result | jq ".data.tx_id")

curl -s -X POST \
  http://localhost:8081/user/access?user=admin \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"$username\",
	\"state\":\"2\",
	\"tx_id\":$tx_id,
	\"sig\":$signature
}" | jq '.'

echo
echo "request Query User access right..."
curl -s -X GET http://localhost:8081/user/access/$username?user=admin | jq '.'

echo
echo "second try invoke transfer 'write' ..."

result=$(curl -s -X POST \
  http://localhost:8081/transaction-sign \
  -H "content-type: application/json" \
  -d '{
	"ccId":"token",
	"fcn":"transfer",
	"args":["i411b6f8f24f28caafe514c16e11800167f8ebd89","INK","1000000"],
	"msg":"test",
    "feeLimit":"100000000000",
	"priKey":"390fd29828e5e029a0c948e17c3a20d98b66ab771803b7ca5e89a3fcc65783d7"
}')
signature=$(echo $result | jq ".data.signature")
tx_id=$(echo $result | jq ".data.tx_id")

curl -s -X POST \
  http://localhost:8081/transfer?user=$username \
  -H "content-type: application/json" \
  -d "{
    \"to_address\":\"i411b6f8f24f28caafe514c16e11800167f8ebd89\",
    \"from_address\":\"i8d49c182fce06146934e6a534c902ba3c5d9bde8\",
    \"coin_type\":\"INK\",
    \"amount\":\"1000000\",
    \"message\":\"test\",
    \"fee_limit\":\"100000000000\",
    \"tx_id\":$tx_id,
    \"sig\":$signature
}" | jq '.'
