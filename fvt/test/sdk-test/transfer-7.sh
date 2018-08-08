#!/bin/bash
#
# Copyright Ziggurat Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

result=$(curl -s -X POST \
  http://localhost:8081/transaction-sign?user=admin \
  -H "content-type: application/json" \
  -d '{
	"ccId":"token",
	"fcn":"transfer",
	"args":["i92711c76760d94e2a6d60ea84884902ccc23dea4","ZIG","100000000000"],
	"msg":"test",
    "feeLimit":"100000000000",
	"priKey":"bc342a2da376b191db101b19c987d2c43badc5bc149df9bf2559c57463eccf49"
}')
signature=$(echo $result | jq ".data.signature")
tx_id=$(echo $result | jq ".data.tx_id")

echo
echo "=============== Transfer to a nonexistent account ==============="
echo "Post request Send transfer tx amount '100000000000 ZIG' fee '4000000 ZIG'"
curl -s -X POST \
  http://localhost:8081/transfer?user=admin \
  -H "content-type: application/json" \
  -d "{
    \"to_address\":\"i92711c76760d94e2a6d60ea84884902ccc23dea4\",
    \"from_address\":\"i411b6f8f24f28caafe514c16e11800167f8ebd89\",
    \"coin_type\":\"ZIG\",
    \"amount\":\"100000000000\",
    \"message\":\"test\",
    \"fee_limit\":\"100000000000\",
    \"tx_id\":$tx_id,
    \"sig\":$signature
}" | jq '.'

echo
echo "=============== Transfer to an existing account ==============="
echo "Get request Query sender account balance"
curl -s -X GET http://localhost:8081/get-account/i411b6f8f24f28caafe514c16e11800167f8ebd89?user=admin | jq '.'

echo
echo "Get request Query receiver account balance"
curl -s -X GET http://localhost:8081/get-account/i8d49c182fce06146934e6a534c902ba3c5d9bde8?user=admin | jq '.'

result=$(curl -s -X POST \
  http://localhost:8081/transaction-sign?user=admin \
  -H "content-type: application/json" \
  -d '{
	"ccId":"token",
	"fcn":"transfer",
	"args":["i8d49c182fce06146934e6a534c902ba3c5d9bde8","ZIG","10000000000000000000"],
	"msg":"test",
    "feeLimit":"100000000000",
	"priKey":"bab0c1204b2e7f344f9d1fbe8ad978d5355e32b8fa45b10b600d64ca970e0dc9"
}')
#echo $result | jq '.'
signature=$(echo $result | jq ".data.signature")
tx_id=$(echo $result | jq ".data.tx_id")

echo
echo "Post request Send transfer tx max limit amount '10000000000000000000 ZIG'"
curl -s -X POST \
  http://localhost:8081/transfer?user=admin \
  -H "content-type: application/json" \
  -d "{
    \"to_address\":\"i8d49c182fce06146934e6a534c902ba3c5d9bde8\",
    \"from_address\":\"i411b6f8f24f28caafe514c16e11800167f8ebd89\",
    \"coin_type\":\"ZIG\",
    \"amount\":\"10000000000000000000\",
    \"message\":\"test\",
    \"fee_limit\":\"100000000000\",
    \"tx_id\":$tx_id,
    \"sig\":$signature
}" | jq '.'

#echo
#echo "POST request Create tx sign and id"
result=$(curl -s -X POST \
  http://localhost:8081/transaction-sign?user=admin \
  -H "content-type: application/json" \
  -d '{
	"ccId":"token",
	"fcn":"transfer",
	"args":["i8d49c182fce06146934e6a534c902ba3c5d9bde8","ZIG","1"],
	"msg":"test",
    "feeLimit":"100000000000",
	"priKey":"bab0c1204b2e7f344f9d1fbe8ad978d5355e32b8fa45b10b600d64ca970e0dc9"
}')
#echo $result | jq '.'
signature=$(echo $result | jq ".data.signature")
tx_id=$(echo $result | jq ".data.tx_id")

echo
echo "Post request Send transfer tx min amount '1 ZIG' fee '4000000 ZIG'"
curl -s -X POST \
  http://localhost:8081/transfer?user=admin \
  -H "content-type: application/json" \
  -d "{
    \"to_address\":\"i8d49c182fce06146934e6a534c902ba3c5d9bde8\",
    \"from_address\":\"i411b6f8f24f28caafe514c16e11800167f8ebd89\",
    \"coin_type\":\"ZIG\",
    \"amount\":\"1\",
    \"message\":\"test\",
    \"fee_limit\":\"100000000000\",
    \"tx_id\":$tx_id,
    \"sig\":$signature
}" | jq '.'

echo
echo "Get request Query sender account balance"
curl -s -X GET http://localhost:8081/get-account/i411b6f8f24f28caafe514c16e11800167f8ebd89?user=admin | jq '.'

echo
echo "Get request Query receiver account balance"
curl -s -X GET http://localhost:8081/get-account/i8d49c182fce06146934e6a534c902ba3c5d9bde8?user=admin | jq '.'
echo

result=$(curl -s -X POST \
  http://localhost:8081/transaction-sign?user=admin \
  -H "content-type: application/json" \
  -d '{
	"ccId":"token",
	"fcn":"transfer",
	"args":["i8d49c182fce06146934e6a534c902ba3c5d9bde8","ZIG","100000000000"],
	"msg":"test",
    "feeLimit":"100000000000",
	"priKey":"bab0c1204b2e7f344f9d1fbe8ad978d5355e32b8fa45b10b600d64ca970e0dc9"
}')
signature=$(echo $result | jq ".data.signature")
tx_id=$(echo $result | jq ".data.tx_id")

echo
echo "Post request Send transfer tx amount '100000000000 ZIG' fee '4000000 ZIG'"
curl -s -X POST \
  http://localhost:8081/transfer?user=admin \
  -H "content-type: application/json" \
  -d "{
    \"to_address\":\"i8d49c182fce06146934e6a534c902ba3c5d9bde8\",
    \"from_address\":\"i411b6f8f24f28caafe514c16e11800167f8ebd89\",
    \"coin_type\":\"ZIG\",
    \"amount\":\"100000000000\",
    \"message\":\"test\",
    \"fee_limit\":\"100000000000\",
    \"tx_id\":$tx_id,
    \"sig\":$signature
}" | jq '.'