#!/bin/bash
#
# Copyright Ziggurat Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

echo
echo "POST request Query Account history state..."
echo
curl -s -X POST \
  http://localhost:8081/query \
  -H "content-type: application/json" \
  -d "{
	\"cc_id\":\"token\",
	\"fcn\":\"getAccountHistory\",
	\"args\":[\"i411b6f8f24f28caafe514c16e11800167f8ebd89\"]
}"
echo
echo
sleep 3

echo
echo "POST request Query Account current state..."
echo
curl -s -X POST \
  http://localhost:8081/query \
  -H "content-type: application/json" \
  -d "{
	\"cc_id\":\"token\",
	\"fcn\":\"getAccount\",
	\"args\":[\"i411b6f8f24f28caafe514c16e11800167f8ebd89\"]
}"
echo
echo

echo
echo "request Query Account State By PartialCompositeKey Time..."
echo
curl -s -X POST \
  http://localhost:8081/query \
  -H "content-type: application/json" \
  -d "{
	\"cc_id\":\"token\",
	\"fcn\":\"getStateByPartialCompositeKey\",
	\"args\":[\"1\",\"1532072744\",\"\"]
}"
echo
echo

echo
echo "request Query Account State By PartialCompositeKey Number..."
echo
curl -s -X POST \
  http://localhost:8081/query \
  -H "content-type: application/json" \
  -d "{
	\"cc_id\":\"token\",
	\"fcn\":\"getStateByPartialCompositeKey\",
	\"args\":[\"2\",\"1\"]
}"
echo
echo

echo
echo "request Query Account State By PartialCompositeKey .."
echo
curl -s -X POST \
  http://localhost:8081/query \
  -H "content-type: application/json" \
  -d "{
	\"cc_id\":\"token\",
	\"fcn\":\"getStateByPartialCompositeKey\",
	\"args\":[\"3\",\"i411b6f8f24f28caafe514c16e11800167f8ebd89\"]
}"
echo
echo
