#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# Language defaults to "golang"

starttime=$(date +%s)

echo
echo "request get tx sign..."
curl -s -X POST \
  http://localhost:8081/tx/sign \
  -H "content-type: application/json" \
  -d "{
	\"ccId\":\"token\",
	\"fcn\":\"transfer\",
	\"args\":[\"i4230a12f5b0693dd88bb35c79d7e56a68614b199\",\"INK\",\"9999999990000000000\"],
	\"msg\":\"test\",
    \"feeLimit\":\"100000000000\",
	\"priKey\":\"bab0c1204b2e7f344f9d1fbe8ad978d5355e32b8fa45b10b600d64ca970e0dc9\"
}"
echo
echo

