#!/bin/bash
#
# Copyright Ziggurat Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

address=i411b6f8f24f28caafe514c16e11800167f8ebd89
username=issue

echo
echo "POST request Query account history state"
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/query?user=$username \
  -H "content-type: application/json" \
  -d "{
	\"cc_id\":\"token\",
	\"fcn\":\"getAccountHistory\",
	\"args\":[\"$address\"]
}" | jq '.'

echo
echo "POST request Query account current state..."
curl -s -X GET http://zigerface-fullserver.org1:8081/get-account/$address?user=$username | jq '.'

echo
echo "POST request Query Account History By Time..."
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/query?user=$username \
  -H "content-type: application/json" \
  -d "{
	\"cc_id\":\"token\",
	\"fcn\":\"getStateByPartialCompositeKey\",
	\"args\":[\"1\",\"1532072744\",\"\"]
}" | jq '.'

echo
echo "POST request Query Account History By Number..."
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/query?user=$username \
  -H "content-type: application/json" \
  -d "{
	\"cc_id\":\"token\",
	\"fcn\":\"getStateByPartialCompositeKey\",
	\"args\":[\"2\",\"3\"]
}" | jq '.'

echo
echo "POST request Query Account History By Account  .."
curl -s -X POST \
  http://zigerface-fullserver.org1:8081/query?user=$username \
  -H "content-type: application/json" \
  -d "{
	\"cc_id\":\"token\",
	\"fcn\":\"getStateByPartialCompositeKey\",
	\"args\":[\"3\",\"$address\"]
}" | jq '.'
echo
