#!/bin/bash

# Update package lists
sudo apt-get update

# Install required packages
sudo apt-get install docker.io ca-certificates curl gnupg -y

# Set up Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists again
sudo apt-get update

# Install Docker Compose plugin
sudo apt-get install docker-compose-plugin -y

# Set up Docker Compose symlink
sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose
sudo ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/bin/docker-compose

# Verify installations
docker-compose version
docker version
