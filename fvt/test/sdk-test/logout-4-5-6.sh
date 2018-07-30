#!/bin/bash
#
# Copyright Ziggurat Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# address: i8d49c182fce06146934e6a534c902ba3c5d9bde8
# private_key: 390fd29828e5e029a0c948e17c3a20d98b66ab771803b7ca5e89a3fcc65783d7
username=zhigui
account=i8d49c182fce06146934e6a534c902ba3c5d9bde8

function transfer () {
    result=$(curl -s -X POST \
      http://localhost:8081/transaction-sign \
      -H "content-type: application/json" \
      -d '{
    	"ccId":"token",
    	"fcn":"transfer",
    	"args":["i411b6f8f24f28caafe514c16e11800167f8ebd89","INK","100"],
    	"msg":"test",
        "feeLimit":"100000000000",
    	"priKey":"390fd29828e5e029a0c948e17c3a20d98b66ab771803b7ca5e89a3fcc65783d7"
    }')
    signature=$(echo $result | jq ".data.signature")
    tx_id=$(echo $result | jq ".data.tx_id")

    echo
    echo "Post request Send transfer tx"
    curl -s -X POST \
      http://localhost:8081/transfer?user=$username \
      -H "content-type: application/json" \
      -d "{
        \"to_address\":\"i411b6f8f24f28caafe514c16e11800167f8ebd89\",
        \"from_address\":\"i8d49c182fce06146934e6a534c902ba3c5d9bde8\",
        \"coin_type\":\"INK\",
        \"amount\":\"100\",
        \"message\":\"test\",
        \"fee_limit\":\"100000000000\",
        \"tx_id\":$tx_id,
        \"sig\":$signature
    }" | jq '.'
    echo
}


echo "=============== test 6: account freeze and unfreeze ==================="
echo
echo "GET request Check account exist"
curl -s -X GET http://localhost:8081/account/info/$account | jq '.'

echo
echo "POST request Freeze account"
curl -s -X POST \
  http://localhost:8081/account/freeze \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"$username\",
    \"address\":\"$account\"
}" | jq '.'

transfer

echo
echo "POST request Unfreeze account"
curl -s -X POST \
  http://localhost:8081/account/unfreeze \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"$username\",
    \"address\":\"$account\"
}" | jq '.'

transfer

echo "=============== test 5: account logoff ==================="
echo
echo "POST request Logoff account"
curl -s -X POST \
  http://localhost:8081/account/logoff \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"$username\",
    \"address\":\"$account\"
}" | jq '.'

echo
echo "GET request Query account state"
curl -s -X GET http://localhost:8081/account/info/$account | jq '.'

transfer

echo "=============== test 4: user logout ==================="
echo
echo "POST request User logout"
curl -s -X POST \
  http://localhost:8081/user/logout \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"zhigui\"
}" | jq '.'

echo
echo "GET request Query User info"
curl -s -X GET http://localhost:8081/user/info/zhigui | jq '.'

transfer