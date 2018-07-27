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
sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo end setup docker-compose
echo

echo start update hosts
echo
cat <<EOT >> /etc/hosts
192.168.0.43    zookeeper0 kafka0 orderer.example.com
192.168.0.44    zookeeper1 kafka1
192.168.0.45    zookeeper2 kafka2 peer1.org2.example.com
192.168.0.46    kafka3 peer1.org1.example.com
192.168.0.47    ca0 peer0.org1.example.com
192.168.0.48    peer0.org2.example.com ca1
EOT
echo end update hosts
echo

echo start pull images
echo
docker pull zhigui/zigledger-zookeeper:x86_64-0.4.6
docker pull zhigui/zigledger-kafka:x86_64-0.4.6
docker pull zhigui/zigledger-orderer:x86_64-1.1.2
docker pull zhigui/zigledger-peer:x86_64-1.1.3
docker pull zhigui/zigledger-ccenv:x86_64-1.1.3
docker pull zhigui/zigledger-tools:x86_64-1.1.3
docker pull zhigui/zigledger-ca:x86_64-1.1.1
echo end pull images
echo