#!/bin/bash
#
# Copyright Ziggurat Corp. 2017 All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

export VERSION=1.1.2
export BASEIMAGE_RELEASE=0.4.6

#Set MARCH variable i.e x86_64
MARCH=`uname -m`

ZigledgerDockerPull() {
  local ZIGLEDGER_TAG=$1
  for IMAGES in peer tools ccenv javaenv; do
      echo "==> ZIGLEDGER IMAGE: $IMAGES"
      echo
      docker pull zhigui/zigledger-$IMAGES:$ZIGLEDGER_TAG
      docker tag zhigui/zigledger-$IMAGES:$ZIGLEDGER_TAG zhigui/zigledger-$IMAGES
  done
  docker pull zhigui/zigledger-orderer:x86_64-1.1.7
  docker pull zhigui/zigerface-fullserver:x86_64-0.1.2
}

CaDockerPull() {
      local CA_TAG=$1
      echo "==> ZIGLEDGER CA IMAGE"
      echo
      docker pull zhigui/zigledger-ca:x86_64-1.1.1
      docker tag zhigui/zigledger-ca:x86_64-1.1.1 zhigui/zigledger-ca
}

BaseImagesPull() {
      docker pull zhigui/zigledger-baseimage:$MARCH-$BASEIMAGE_RELEASE
      docker pull zhigui/zigledger-baseos:$MARCH-$BASEIMAGE_RELEASE
      docker pull zhigui/zigledger-couchdb:$MARCH-$BASEIMAGE_RELEASE
      docker pull zhigui/zigledger-kafka:$MARCH-$BASEIMAGE_RELEASE
      docker pull zhigui/zigledger-zookeeper:$MARCH-$BASEIMAGE_RELEASE
}

: ${CA_TAG:="$MARCH-$VERSION"}
: ${ZIGLEDGER_TAG:="$MARCH-$VERSION"}

echo "===> Pulling Base Images"
BaseImagesPull

echo "===> Pulling zigledger Images"
ZigledgerDockerPull ${ZIGLEDGER_TAG}

echo "===> Pulling zigledger ca Image"
CaDockerPull ${CA_TAG}
echo
echo "===> List out zigledger docker images"
docker images | grep zhigui*
