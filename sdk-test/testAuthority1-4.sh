#!/bin/bash
#
# Copyright Ziggurat Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#
# address: iac0726c75c3a5a1879f539f1573d254fd9a4e60
# private_key: 390a71a68aa1d617825fc065f58e91d813fcd64e5880205d456d66f6e955a031

parse_json(){
echo "${1//\"/}" | sed "s/.*$2:\([^,}]*\).*/\1/"
}

echo "test 1 and 44"
echo "request Get User register token..."
result=$(curl -s -X POST \
  http://localhost:8081/user/register/token \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"zhigui\"
}")
echo $result
value=$(parse_json $result "data")
echo

echo "request User register..."
curl -s -X POST \
  http://localhost:8081/user/register \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"zhigui\",
	\"token\":\"$value\"
}"
echo
sleep 3

echo
echo "request Query User info..."
curl -s -X GET http://localhost:8081/user/info/zhigui
echo

echo
echo "repeat request User register..."
curl -s -X POST \
  http://localhost:8081/user/register \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"zhigui\",
	\"token\":\"$value\"
}"
echo

echo
echo "test 2"
echo "request Account register..."
curl -s -X POST \
  http://localhost:8081/account/register \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"zhigui\",
	\"address\":\"iac0726c75c3a5a1879f53c9f1573d254fd9a4e60\"
}"
echo
sleep 3

echo
echo "repeat request Account register..."
curl -s -X POST \
  http://localhost:8081/account/register \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"zhigui\",
	\"address\":\"iac0726c75c3a5a1879f53c9f1573d254fd9a4e60\"
}"
echo

echo
echo "test 3"
echo "request User modify info..."
curl -s -X POST \
  http://localhost:8081/user/modify \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"zhigui\",
    \"newname\":\"ziggurat\"
}"
echo

echo
echo "request Query User info..."
curl -s -X GET http://localhost:8081/user/info/zhigui
echo

echo
echo "test 47"
echo "request Set User access right..."
sign=$(curl -s -X POST \
  http://localhost:8081/tx/sign \
  -H "content-type: application/json" \
  -d "{
  	\"ccId\":\"token\",
  	\"fcn\":\"setAccessState\",
  	\"args\":[\"zhigui\",\"1\"],
  	\"msg\":\"\",
    \"feeLimit\":\"100000000000\",
  	\"priKey\":\"390a71a68aa1d617825fc065f58e91d813fcd64e5880205d456d66f6e955a031\"
}")
echo $sign
sig=$(parse_json $sign "data")
echo

curl -s -X POST \
  http://localhost:8081/user/access \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"zhigui\",
	\"state\":\"1\",
	\"sig\":\"$sig\"
}"
echo
sleep 3

echo "request Query User access right..."
curl -s -X GET http://localhost:8081/user/access/zhigui
echo

echo
echo "test 4"
echo "request User logout..."
curl -s -X POST \
  http://localhost:8081/user/logout \
  -H "content-type: application/json" \
  -d "{
	\"username\":\"zhigui\"
}"
echo

echo
echo "request Query User info..."
curl -s -X GET http://localhost:8081/user/info/zhigui
echo
