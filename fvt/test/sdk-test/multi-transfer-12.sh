#!/bin/bash
#
# Copyright Ziggurat Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
username=admin

echo
echo "need register two account"
curl -s -X POST \
  http://localhost:8081/account/register \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"zhigui\",
	\"address\":\"i3c97f146e8de9807ef723538521fcecd5f64c79a\"
}" | jq '.'
echo

echo
echo "Get request Query sender account balance"
curl -s -X GET http://localhost:8081/get-account/i411b6f8f24f28caafe514c16e11800167f8ebd89?user=$username | jq '.'

echo
echo "POST request Create tx sign and id"
result=$(curl -s -X POST \
  http://localhost:8081/transaction-sign?user=$username \
  -H "content-type: application/json" \
  -d '{
	"ccId":"token",
	"fcn":"multiTransfer",
	"args":["i8d49c182fce06146934e6a534c902ba3c5d9bde8:100000000:ZIG","i3c97f146e8de9807ef723538521fcecd5f64c79a:100000000:ZIG"],
	"msg":"test",
    "feeLimit":"100000000000",
	"priKey":"bab0c1204b2e7f344f9d1fbe8ad978d5355e32b8fa45b10b600d64ca970e0dc9"
}')
echo $result | jq '.'
signature=$(echo $result | jq ".data.signature")
tx_id=$(echo $result | jq ".data.tx_id")

echo
echo "Post request Send transfer tx"
curl -s -X POST \
  http://localhost:8081/multiTransfer?user=$username \
  -H "content-type: application/json" \
  -d "{
        \"cc_id\": \"token\",
        \"fcn\": \"multiTransfer\",
        \"sender\": \"i411b6f8f24f28caafe514c16e11800167f8ebd89\",
        \"args\": [\"i8d49c182fce06146934e6a534c902ba3c5d9bde8:100000000:ZIG\",\"i3c97f146e8de9807ef723538521fcecd5f64c79a:100000000:ZIG\"],
        \"message\": \"test\",
        \"fee_limit\": \"100000000000\",
        \"tx_id\":$tx_id,
        \"sig\":$signature
}" | jq '.'

echo
echo "Get request Query sender account balance"
curl -s -X GET http://localhost:8081/get-account/i411b6f8f24f28caafe514c16e11800167f8ebd89?user=$username | jq '.'

echo
echo "Get request Query receiver 1 account balance"
curl -s -X GET http://localhost:8081/get-account/i8d49c182fce06146934e6a534c902ba3c5d9bde8?user=$username | jq '.'

echo
echo "Get request Query receiver 2 account balance"
curl -s -X GET http://localhost:8081/get-account/i3c97f146e8de9807ef723538521fcecd5f64c79a?user=$username | jq '.'
