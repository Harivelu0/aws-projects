# Deploying a Django Blog on AWS: Terraform Infrastructure as Code Best Practices

A complete end-to-end solution for deploying a production-ready Django 5 blog application on AWS, leveraging Terraform for infrastructure automation, GitHub Actions for CI/CD pipelines, and AWS services for scalable, secure cloud-native deployment.  
This repository demonstrates best practices in Infrastructure as Code, security, and pipeline automation ideal


---

## Project Overview

The goal is to build a secure, scalable, and fully automated Django blog deployment on AWS, featuring:

- Automated infrastructure provisioning (Terraform)
- Secure networking architecture (VPC, subnets, security groups)
- CI/CD pipeline for continuous deployment (GitHub Actions)
- Container-based application deployment (Docker, ECS, ECR)
- Secrets management (AWS Secrets Manager)
- Parameter Store integration for configuration

---

## Architecture & Security

![Untitled Diagram](https://github.com/user-attachments/assets/55dff9d1-13fd-452c-999d-95f5fea449b7)

**AWS Architecture:**

- **VPC** with public/private subnets across multiple AZs
- **Public Subnets:** Load Balancer (ALB), NAT Gateway
- **Private Subnets:** ECS containers (Fargate), RDS (MySQL)
- **Security:** IAM roles, security groups, and secrets management
- **Ingress:** Only ALB is publicly accessible; all other resources are private

**Security by Design:**

- **Network Segmentation:** Databases and app containers in private subnets
- **Least Privilege:** Specific IAM roles/policies for ECS execution and task roles
- **Secrets Management:** All sensitive credentials (DB, Django secrets) in AWS Secrets Manager with random suffixes and JSON structure
- **Security Groups:** Precise inbound/outbound rules using security group references, "deny by default" approach

---

## Repository Structure

```
.
|__ /github/workflow          # infra, app, destroy pipleine
├── django5-blog-tutorial/    # Django 5 app, Dockerfile, entrypoint script
├── terraform/                # Infrastructure as Code: AWS resources, variables, outputs
```

---

## CI/CD Pipelines

### Infrastructure Pipeline

**Purpose:** Provisions AWS resources using Terraform.

**Workflow:**
- Initializes Terraform
- Plans and applies infrastructure changes
- Stores outputs (ALB DNS, RDS endpoint, Secrets ARN, etc.) in AWS Parameter Store

**Best Practices:**
- Remote state in S3, state locking with DynamoDB, encryption enabled
- Logical resource separation: networking, security, DB, containers
- Descriptive, documented variables with `sensitive` flag for credentials
- Explicit and implicit resource dependencies
- Consistent resource naming and tagging

### Application Pipeline

**Purpose:** Builds, packages, and deploys the Django application.

**Workflow:**
- Builds Docker image with Django code
- Pushes image to ECR
- Updates ECS task definition with new image reference
- Deploys to ECS Fargate

**Best Practices:**
- Entrypoint script runs DB migrations and creates superuser inside the container, ensuring secure DB access from private subnets
- ECS secrets integration injects DB and app credentials at runtime

### Destroy Pipeline

**Purpose:** Safely tears down all AWS resources.

**Workflow:**
- select the destroy pipeline from workflow and click run workflow to remove everything (VPC, ECS, RDS, ECR, ALB, secrets, etc.)

---

## Django Application

**Location:** `django5-blog-tutorial/`

- **Django 5 Blog App:**  
  Configured for MySQL, secrets injected from ECS/Secrets Manager

- **Dockerfile:**  
  - Python 3.11, MySQL client  
  - Installs dependencies  
  - Entrypoint script for migrations & superuser creation  
  - Exposes port 8000

- **Entrypoint Script:**  
  ```bash
  #!/bin/bash
  python manage.py migrate
  python manage.py createsuperuser --noinput || echo "Admin already exists"
  gunicorn myapp.wsgi:application --bind 0.0.0.0:8000
  ```

- **Secrets Handling:**  
  All sensitive configs (DB, Django secret key, admin password) injected via ECS secrets referencing AWS Secrets Manager

---

## Getting Started

### Prerequisites

- AWS CLI configured
- Terraform >= 1.3
- Docker

### Steps for local implementation

1. **Clone the repository:**
    ```bash
    git clone https://github.com/Harivelu0/e2e-django-infra-pipeline.git
    ```

2. **Provision infrastructure:**
    ```bash
    cd terraform/
    terraform init
    terraform apply
    ```

3. **Build and push the Django app Docker image:**
    ```bash
    cd ../django5-blog-tutorial/
    docker build -t <your_ecr_repo_url>:latest .
    docker push <your_ecr_repo_url>:latest
    ```

4. **Access your application:**
    - Get the ALB DNS name from Terraform output or Parameter Store, open in your browser.

5. **To destroy everything:**
    ```bash
    cd ../terraform/
    terraform destroy
    ```
---

### Steps in github actions
1.  Assign this value 
   go to repo settings -> secrets and variables -> actions add this values
   ```bash
   ADMIN_PASSWORD  # random value
   AWS_ACCESS_KEY_ID # your aws access key
   AWS_ACCOUNT_ID   # aws account id 
   AWS_SECRET_ACCESS_KEY # secret access key
   DJANGO_SECRET_KEY  # random value
   DJANGO_SUPERUSER_PASSWORD  # random value
   ```

## Outputs

- **ALB DNS:** Public endpoint for the Django blog
- **RDS Endpoint:** For DB connections
- **ECR Repo URL:** For Docker images
- **Secrets ARN:** For app secrets
- **Parameter Store:** For sharing outputs with downstream pipelines

---

## License & Author

MIT License  
Author: [Harivelu0](https://github.com/Harivelu0)

---

## Additional Resources

- [Project source code](https://github.com/Harivelu0/e2e-django-infra-pipeline)
- [Blog post explaining this architecture](https://dev.to/techwithhari/deploying-a-django-blog-on-aws-terraform-infrastructure-as-code-best-practices-4e33)
