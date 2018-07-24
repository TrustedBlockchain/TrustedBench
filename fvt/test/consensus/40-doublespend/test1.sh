#!/bin/bash
#
# Copyright  Zhigui.com. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

# Language defaults to "golang"

starttime=$(date +%s)

echo "POST two invoke transfer"
echo
curl -s -X POST \
  http://localhost:8081/transfer \
  -H "content-type: application/json" \
  -d '{
	"to_address":"i4230a12f5b0693dd88bb35c79d7e56a68614b199",
	"from_address":"i411b6f8f24f28caafe514c16e11800167f8ebd89",
	"coin_type":"INK",
	"amount":"9999999990000000000",
	"message":"test",
	"fee_limit":"100000000000",
	"sig":"96ea7fc0cac77eefaedbe66abea5ef7f552699712767fec3097a9ddff1ff4e2753325f80fc7dab3967b578ba94b8dec40474f0d6a8273282791e6ead392ee71301"
}'
echo
echo
