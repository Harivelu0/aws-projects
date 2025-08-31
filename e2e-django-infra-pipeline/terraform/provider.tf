terraform {
  required_version = ">= 1.3.0"

  backend "s3" {
    bucket         = "my-terraform-backend-bucket"   # Replace with your S3 bucket
    key            = "ecs-app/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"              # DynamoDB for state locking
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}
