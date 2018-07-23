#! /bin/bash
#
# Copyright INKCHAIN Corp. All Rights Reserved.
# SPDX-License-Identifier: Apache-2.0
#

# now config for ubuntu 16-04

#####################################
# Install and setup Docker services #
#####################################

echo "Install docker"

sudo apt-get update

sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common

curl -fsSL http://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get -y update

sudo apt-get -y install docker-ce

# config docker

sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["http://2743e10c.m.daocloud.io"]
}
EOF

sudo systemctl daemon-reload

sudo systemctl restart docker

################################################
# Install  docker-compose #
################################################

echo "Install docker-compose"
sudo apt-get -y install python-pip
export LC_ALL=C
sudo pip install --upgrade pip
sudo pip install docker-compose


################################################
# Install  node #
################################################

#Install nodejs
echo "Install nodejs begin"

NODE_VER=8.11.1
NODE_URL=https://nodejs.org/dist/v$NODE_VER/node-v$NODE_VER-linux-x64.tar.gz

curl -sL $NODE_URL | (cd /usr/local && tar --strip-components 1 -xz )


