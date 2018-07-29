#!/bin/bash
#
# Copyright Ziggurat Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

echo
echo "Get request Query sender account balance"
curl -s -X GET http://zigerface-fullserver.org1:8081/get-account/i411b6f8f24f28caafe514c16e11800167f8ebd89?user=admin | jq '.'

echo
echo "POST request Create tx sign and id"
result=$(curl -s -X POST \
  http://zigerface-fullserver.org1:8081/transaction-sign?user=admin \
  -H "content-type: application/json" \
  -d '{
	"ccId":"token",
	"fcn":"transfer",
	"args":["i8d49c182fce06146934e6a534c902ba3c5d9bde8","INK","100000000000"],
	"msg":"test",
    "feeLimit":"100000000000",
	"priKey":"bab0c1204b2e7f344f9d1fbe8ad978d5355e32b8fa45b10b600d64ca970e0dc9"
}')
echo $result | jq '.'
signature=$(echo $result | jq ".data.signature")
tx_id=$(echo $result | jq ".data.tx_id")

echo
echo "Post request Send transfer tx amount '100000000000 INK' fee '4000000 INK'"
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/transfer?user=admin \
  -H "content-type: application/json" \
  -d "{
    \"to_address\":\"i8d49c182fce06146934e6a534c902ba3c5d9bde8\",
    \"from_address\":\"i411b6f8f24f28caafe514c16e11800167f8ebd89\",
    \"coin_type\":\"INK\",
    \"amount\":\"100000000000\",
    \"message\":\"test\",
    \"fee_limit\":\"100000000000\",
    \"tx_id\":$tx_id,
    \"sig\":$signature
}" | jq '.'

echo
echo "Get request Query sender account balance"
curl -s -X GET http://zigerface-fullserver.org1:8081/get-account/i411b6f8f24f28caafe514c16e11800167f8ebd89?user=admin | jq '.'

echo
echo "Get request Query receiver account balance"
curl -s -X GET http://zigerface-fullserver.org1:8081/get-account/i8d49c182fce06146934e6a534c902ba3c5d9bde8?user=admin | jq '.'
echo