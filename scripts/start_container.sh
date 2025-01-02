#!/bin/bash
set -e

# Install Docker if not installed
if ! command -v docker &> /dev/null; then
    apt-get update
    apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
fi

# Start Docker service if not running
systemctl start docker
systemctl enable docker

# Pull the Docker image from Docker Hub
docker pull harivp1234/simple-python-flask-app

# Run the Docker image as a container
docker run -d -p 5000:5000 harivp1234/simple-python-flask-app