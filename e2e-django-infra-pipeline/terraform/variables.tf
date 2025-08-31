# project name
variable "project_name" {
  default = "django-blog"
  type = string
}

# region
variable "region" {
  default = "us-east-1"
  type = string
}

# vpc 
variable "vpc_cidr" {
  default = "10.0.0.0/16"
  type = string
}

# public subnets
variable "public_subnet_cidrs" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  type = list(string)
}

# private subnets
variable "private_subnet_cidrs" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
  type = list(string)
}

# db instance class
variable "db_instance_class" {
  default = "db.t2.micro"
  type = string
}

# db username
variable "db_username" {
  default = "admin"
  type = string
}

# db password
variable "db_password" {
  default = "password"
  type = string
}

# db name
variable "db_name" {
  default = "django-blog"
  type = string
}

#djanko secret key
variable "djanko_secret_key" {
  type = string
  sensitive = true

}

#container image
variable "container_image" {
  default = "763104351884.dkr.ecr.us-east-1.amazonaws.com"
  type = string
} 

# nat gateway
variable "create_nat_gateway" {
  default = true
  type = bool
}

variable "docker_image" {
  description = "ECR image for the ECS task (with tag)"
  type        = string
}

