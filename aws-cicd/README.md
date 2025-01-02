# AWS CICD Todo List Application

This repository contains a simple Todo List application deployed using AWS CICD services (CodeBuild, CodePipeline, and CodeDeploy) with Docker containerization.

## Architecture Overview

The application uses a complete CI/CD pipeline with the following AWS services:
- AWS CodeBuild: For building and testing the application
- AWS CodePipeline: For managing the deployment pipeline
- AWS CodeDeploy: For deploying to EC2 instances
- Amazon EC2: For hosting the application
- AWS Systems Manager Parameter Store: For storing Docker credentials

## Prerequisites

- AWS Account with appropriate permissions
- GitHub repository
- Docker Hub account
- Python 3.11
- AWS CLI configured

## Project Structure

```
aws-projects/aws-cicd/
├── simple-python-app/
│   ├── todolist.py
│   ├── requirements.txt
│   ├── Dockerfile
│   ├── start.sh
│   └── stop.sh
├── buildspec.yml
└── appspec.yml
```

## Setup Instructions

### 1. CodeBuild Configuration

1. Create GitHub OAuth Connection:
   - Go to AWS CodeBuild Console
   - Create a connection to your GitHub repository
   - Complete the OAuth process

2. Create Build Project:
   - Provide repository details
   - Configure environment:
     - Operating System: Ubuntu
     - Runtime: Python 3.11
     - Image: aws/codebuild/amazonlinux2-x86_64-standard:3.0

3. Configure Docker Credentials:
   - Store the following in AWS Systems Manager Parameter Store:
     - `/myapp/docker-credentials/username`
     - `/myapp/docker-credentials/password`
     - `/myapp/docker-registry/url`

### 2. CodePipeline Setup

1. Create Pipeline:
   - Choose "New Pipeline"
   - Configure pipeline settings and role

2. Add Source Stage:
   - Source Provider: GitHub
   - Select repository and branch

3. Add Build Stage:
   - Build Provider: AWS CodeBuild
   - Select your build project

4. Add Deploy Stage:
   - Deploy Provider: AWS CodeDeploy
   - Configure application name and deployment group

### 3. CodeDeploy Configuration

1. Create Application:
   - Go to AWS CodeDeploy Console
   - Create new application
   - Platform: EC2/On-premises

2. Create Deployment Group:
   - Configure service role
   - Select EC2 instances using tags
   - Configure deployment settings

### 4. EC2 Instance Setup

1. Launch EC2 Instance:
   - Use Amazon Linux 2 AMI
   - Configure security groups

2. Modify IAM Role:
   - Attach AWSCodeDeployRole
   - Ensure proper permissions for Docker operations

3. Install Required Agents:
   - Install CodeDeploy Agent
   - Install Docker

## Deployment Files

### buildspec.yml
The buildspec.yml file contains the build specifications for CodeBuild:
```yaml
version: 0.2
env:
  parameter-store:
    DOCKER_REGISTRY_USERNAME: /myapp/docker-credentials/username
    DOCKER_REGISTRY_PASSWORD: /myapp/docker-credentials/password
    DOCKER_REGISTRY_URL: /myapp/docker-registry/url
phases:
  install:
    runtime-versions:
      python: 3.11
  pre_build:
    commands:
      - echo "Installing dependencies..."
      - pip install -r requirements.txt
  build:
    commands:
      - echo "Building Docker image..."
      - docker login -u "$DOCKER_REGISTRY_USERNAME" -p "$DOCKER_REGISTRY_PASSWORD" "$DOCKER_REGISTRY_URL"
      - docker build -t "$DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_USERNAME/simple-python-flask-app:latest" .
      - docker push "$DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_USERNAME/simple-python-flask-app:latest"
```

### appspec.yml
Create an appspec.yml file in your repository root:
```yaml
version: 0.0
os: linux
files:
  - source: /
    destination: /home/ec2-user/application
hooks:
  ApplicationStop:
    - location: stop.sh
      timeout: 300
      runas: root
  ApplicationStart:
    - location: start.sh
      timeout: 300
      runas: root
```

## Scripts

### start.sh
This script handles container startup:
```bash
#!/bin/bash
docker pull $DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_USERNAME/simple-python-flask-app:latest
docker run -d -p 5000:5000 $DOCKER_REGISTRY_URL/$DOCKER_REGISTRY_USERNAME/simple-python-flask-app:latest
```

### stop.sh
This script handles container cleanup:
```bash
#!/bin/bash
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
```

## Troubleshooting

1. If CodeBuild fails:
   - Check buildspec.yml syntax
   - Verify Docker credentials in Parameter Store
   - Check CodeBuild role permissions

2. If CodeDeploy fails:
   - Verify EC2 instance has CodeDeploy agent running
   - Check instance IAM role permissions
   - Review appspec.yml syntax

3. If Docker operations fail:
   - Verify Docker is installed on EC2
   - Check Docker credentials
   - Ensure proper network connectivity

## Security Considerations

- Use IAM roles with least privilege
- Store sensitive information in Parameter Store
- Regularly update security groups
- Keep Docker images updated

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.