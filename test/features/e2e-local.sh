#!/usr/bin/env bash
docker-compose -f ../../network/zigledger/simplenetwork/docker-compose.yaml down
docker rm $(docker ps -aq)
docker images | grep simple | awk '{print $3}' | xargs docker rmi
docker-compose -f ../../network/zigledger/simplenetwork/docker-compose.yaml up -d

sleep 10s

node data-safety.js

sleep 60s

docker-compose -f ../../network/zigledger/simplenetwork/docker-compose.yaml down
docker rm $(docker ps -aq)
docker images | grep simple | awk '{print $3}' | xargs docker rmi