#!/bin/bash

echo "stop a peer service"
docker stop `docker ps |grep 10053 |awk '{print $1}'`