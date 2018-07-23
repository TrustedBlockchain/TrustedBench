#!/bin/bash
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# Language defaults to "golang"

starttime=$(date +%s)

echo "POST invoke transfer"
echo
curl -s -X POST \
  http://localhost:8081/transfer \
  -H "content-type: application/json" \
  -d "{
	\"to_address\":\"i4230a12f5b0693dd88bb35c79d7e56a68614b199\",
	\"from_address\":\"i411b6f8f24f28caafe514c16e11800167f8ebd89\",
	\"coin_type\":\"INK\",
	\"amount\":\"100000000000\",
	\"message\":\"test\",
	\"fee_limit\":\"100000000000\",
	\"sig\":\"0d3eb9bb1e18ae340201924b35f832470534dcaa412daffac7cdb9fe4edbf6d4037fc559b5f78682fc9b9bc893ebd6c6308584e2d15499af230d302ecb4e5f9500\"
}"
echo
echo
