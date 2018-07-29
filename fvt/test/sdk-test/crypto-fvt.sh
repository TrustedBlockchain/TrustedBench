#!/usr/bin/env bash

echo
echo "ECDSA cryptograph"
echo

curl -s -X GET http://localhost:8081/crypto/ecdsa

echo
echo "PKCS11 cryptograph"
echo

curl -s -X GET http://localhost:8081/crypto/pcks11


echo
echo "Verify ECDSA cryptograph"
echo

curl -s -X GET http://localhost:8081/crypto/ecdsa/verify

echo
echo "Get the address and security code"
echo

result=$(curl -s -X GET http://localhost:8081/crypto/address)
echo $result
address=$(echo $result | jq ".data.address")
securityCode=$(echo $result | jq ".data.securityCode")

echo
echo "recovery the private key"
echo

curl -s -X POST http://localhost:8081/crypto/key-recovery \
  -H "content-type: application/json" \
  -d "{
	\"address\":$address,
	\"securityCode\":$securityCode
}"