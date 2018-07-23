#!/bin/bash
#
# Copyright  Zhigui.com. All Rights Reserved.
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
	\"to_address\":\"iac0726c75c3a5a1879f53c9f1573d254fd9a4e60\",
	\"from_address\":\"i411b6f8f24f28caafe514c16e11800167f8ebd89\",
	\"coin_type\":\"INK\",
	\"amount\":\"100000000000\",
	\"message\":\"test\",
	\"fee_limit\":\"100000000000\",
	\"sig\":\"c9e9f1c099699d10868e0a9c7da65299152f6fac85be3b55a051abb3de958139527bc44e5ebdba31d8ad6e83da42e25b0d7efeb11a8ba2382dfbd3e68e5a005600\"
}"
echo
echo
