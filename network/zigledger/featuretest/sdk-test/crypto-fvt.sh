#!/usr/bin/env bash

echo
echo "ECDSA cryptograph"
echo

curl -s -X GET http://zigerface-fullserver.org1:8081/crypto/ecdsa

printf "\n\n"
echo "PKCS11 cryptograph"
echo

curl -s -X GET http://zigerface-fullserver.org1:8081/crypto/pcks11


printf "\n\n"
echo "Verify ECDSA cryptograph 8 times"
echo
for i in `seq 1 8`
do
    sleep 1
    data=$(cat /dev/urandom | tr -dc "[:alpha:]" | head -c $(expr $i \* 8))
    echo "The data is $data"
    curl -s -X POST http://zigerface-fullserver.org1:8081/crypto/ecdsa/verify \
      -H "content-type: application/json" \
      -d "{
    	\"data\":\"$data\"
    }"
    printf "\n\n"
done

printf "\n"
echo "Get the address and security code"
echo

result=$(curl -s -X GET http://zigerface-fullserver.org1:8081/crypto/address)
echo $result
address=$(echo $result | jq ".data.address")
securityCode=$(echo $result | jq ".data.securityCode")

printf "\n"
echo "recovery the private key"
echo

curl -s -X POST http://zigerface-fullserver.org1:8081/crypto/key-recovery \
  -H "content-type: application/json" \
  -d "{
	\"address\":$address,
	\"securityCode\":$securityCode
}"