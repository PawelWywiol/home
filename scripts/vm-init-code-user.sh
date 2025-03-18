#!/bin/bash

USERNAME="code"

# Update system
sudo apt-get update
sudo apt-upgrade -y

# Install dependencies
sudo apt-get install ca-certificates curl sudo zsh build-essential rsync -y

# Install Docker
sudo curl -sSL https://get.docker.com/ | sh

# Update system
sudo apt-get upgrade -y
sudo apt-get autoremove -y

# Add user to docker group
sudo groupadd docker
sudo usermod -aG docker $USERNAME
