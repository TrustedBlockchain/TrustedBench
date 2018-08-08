#!/bin/bash
#
# Copyright Ziggurat Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

echo
echo "POST request Create tx sign and id"
curl -s -X POST \
  http://localhost:8081/transaction-sign \
  -H "content-type: application/json" \
  -d '{
	"ccId":"token",
	"fcn":"transfer",
	"args":["i8d49c182fce06146934e6a534c902ba3c5d9bde8","ZIG","100000000000"],
	"msg":"test",
    "feeLimit":"100000000000",
	"priKey":"bab0c1204b2e7f344f9d1fbe8ad978d5355e32b8fa45b10b600d64ca970e0dc9"
}' | jq '.'
echo
