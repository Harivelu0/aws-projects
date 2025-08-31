# define aws terraform prvider

terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~>5.0"
            }
    }
    required_version = ">=1.6.0"
}

provider "aws" {
  region = var.region
}

# define VPC in aws

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  instance_tenancy = "default"
  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# define Public subnet in aws

resource "aws_subnet" "public" {
  cidr_block = "10.0.1.0/24"
  vpc_id = aws_vpc.main.id
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = {
    Name = "${var.project_name}-public-subnet"
  }
}

# define Private subnet in aws

resource "aws_subnet" "private"{
  cidr_block = "10.0.2.0/24"
  vpc_id = aws_vpc.main.id
  map_public_ip_on_launch = false
  availability_zone = "us-east-1a"
  tags = {
    Name = "${var.project_name}-private-subnet"
}

}
# define internet gateway in aws

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-internet-gateway"
  }
}


# define public route tabele
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id  
  route{
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.project_name}-public-route-table"
  }
}

# define public route table association

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# security group  for app

resource "aws_security_group" "app" {
  name = "${var.project_name}-app-sg"
  description = "allow http,https traffic"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  }

# DB Subnet Group (Private Subnets)
  resource "aws_db_subnet_group" "db_subnet_group" {
    name = "${var.project_name}-db-subnet-group"
    subnet_ids = [aws_subnet.private.id]
    tags = {
      Name = "${var.project_name}-db-subnet-group"
    }
  }

#db instance creation

resource "aws_db_instance" "mysql_db" {
 identifier = "${var.project_name}-db"
 engine = "mysql"
 engine_version = "5.7"
 instance_class = var.db_instance_class
 allocated_storage = 20
 username = var.db_username
 password = var.db_password
 db_name = var.db_name
 vpc_security_group_ids = [aws_security_group.app.id]
 db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
 tags = {
   Name = "${var.project_name}-db"
 }
 skip_final_snapshot = true
 publicly_accessible = false 
 multi_az = false 
 storage_encrypted = true 
 backup_retention_period = 7
}

