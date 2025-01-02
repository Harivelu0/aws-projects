#!/bin/bash
set -e

# Check if Docker is installed and running
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
fi

echo "Pulling Docker image..."
/usr/bin/docker pull harivp1234/simple-python-flask-app

echo "Running Docker container..."
/usr/bin/docker run -d -p 5000:5000 harivp1234/simple-python-flask-app

echo "Container started successfully"