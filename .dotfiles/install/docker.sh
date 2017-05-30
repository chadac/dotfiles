#!/bin/bash
## Docker CE and Docker Compose

echo "Installing Docker..."
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common

## Adding GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88

## Adding repository
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

## Installing Docker
sudo apt-get update
sudo apt-get install docker-ce


echo "Installing Docker Compose..."
sudo curl -L https://github.com/docker/compose/releases/download/1.13.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose


echo "Setting up current user as member of Docker group..."
sudo groupadd docker
sudo usermod -aG docker $USER


echo "Done! You must log out for changes to take effect."
