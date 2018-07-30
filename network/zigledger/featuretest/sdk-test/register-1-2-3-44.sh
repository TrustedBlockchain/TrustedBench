#!/bin/bash
#
# Copyright Ziggurat Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
address=i8d49c182fce06146934e6a534c902ba3c5d9bde8
private=390fd29828e5e029a0c948e17c3a20d98b66ab771803b7ca5e89a3fcc65783d7
username=zhigui

echo "=============== test 2 and 44: register user and verify identity ==================="
echo
echo "request Query User exist..."
curl -s -X GET http://zigerface-fullserver.org1:8081/user/info/$username | jq '.'
echo

echo
echo "request get user register token..."
value=$(curl -s -X POST \
  http://zigerface-fullserver.org1:8081/user/register/token \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"$username\"
}" | jq '.data')
echo $value | jq '.'
echo


echo "input wrong authentication information..."
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/user/register \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"$username\",
	\"token\":\"123456\"
}" | jq '.'
echo

echo
echo "input right authentication information..."
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/user/register \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"$username\",
	\"token\":$value
}" | jq '.'
echo

echo
echo "request Query User info..."
curl -s -X GET http://zigerface-fullserver.org1:8081/user/info/$username?user=admin | jq '.'
echo

echo
echo "repeat request User register..."
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/user/register \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"$username\",
	\"token\":$value
}" | jq '.'
echo

echo
echo "=============== test 1 : create account ==================="
echo
echo "request query account exist..."
curl -s -X GET http://zigerface-fullserver.org1:8081/account/info/$address | jq '.'
echo

echo
echo "request account register..."
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/account/register \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"$username\",
	\"address\":\"$address\"
}" | jq '.'
echo
sleep 3

echo
echo "request query account state..."
curl -s -X GET http://zigerface-fullserver.org1:8081/account/info/$address | jq '.'
echo

echo
echo "repeat request Account register..."
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/account/register \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"$username\",
	\"address\":\"$address\"
}" | jq '.'
echo

echo
echo "=============== test 3 : modify user info ==================="
echo
echo "request Query User info..."
curl -s -X GET http://zigerface-fullserver.org1:8081/user/info/$username | jq '.'
echo

echo
echo "request user modify info..."
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/user/modify \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"$username\",
    \"newname\":\"ziggurat\"
}" | jq '.'
echo

echo
echo "request query User info..."
curl -s -X GET http://zigerface-fullserver.org1:8081/user/info/$username | jq '.'
echo
echo
