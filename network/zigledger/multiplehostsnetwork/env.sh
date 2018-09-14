#!/usr/bin/env bash

echo start setup docker
echo
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install docker-ce
echo end setup docker
echo

echo start docker speed
echo
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["http://2743e10c.m.daocloud.io"]
}
EOF

sudo systemctl daemon-reload

sudo systemctl restart docker
echo end docker speed
echo

echo start setup docker-compose
echo
sudo apt-get -y install python-pip
export LC_ALL=C
sudo pip install --upgrade pip
sudo pip install docker-compose
echo end setup docker-compose
echo

echo start update hosts
echo
cat <<EOT >> /etc/hosts
192.168.0.213    zookeeper0 kafka0 orderer0.example.com
192.168.0.214    zookeeper1 kafka1 orderer1.example.com
192.168.0.215   zookeeper2 kafka2 peer1.org2.example.com
192.168.0.216    kafka3 peer1.org1.example.com
192.168.0.217    ca0 peer0.org1.example.com zigerface-fullserver.org1
192.168.0.218   peer0.org2.example.com ca1
EOT
echo end update hosts
echo

echo start pull images
echo
docker pull zhigui/zigledger-kafka:x86_64-0.4.6
docker pull zhigui/zigledger-zookeeper:x86_64-0.4.6
docker pull zhigui/zigledger-orderer:x86_64-1.2.12
docker pull zhigui/zigledger-peer:x86_64-1.2.12
docker pull zhigui/zigledger-ccenv:x86_64-1.2.12
#docker pull zhigui/zigledger-tools:x86_64-1.2.12
docker pull zhigui/zigledger-ca:x86_64-1.1.1
docker pull zhigui/zigerface-fullserver:x86_64-0.1.10
docker pull zhigui/zigerface-mysql:x86_64-0.1.0
docker pull zhigui/zigerface-listener:x86_64-0.1.2
echo end pull images
echo

echo start setup jq
echo
apt install jq
echo end setup jq
echo