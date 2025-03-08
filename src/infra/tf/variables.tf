# ---------------------------
# AWS VARIABLES
# ---------------------------
variable "aws_region" { default = "us-east-1" }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "public_subnet_cidr" { default = "10.0.1.0/24" }
variable "private_subnet_cidr" { default = "10.0.2.0/24" }
variable "vector_subnet_cidr" { default = "10.0.3.0/24" }

# ---------------------------
# DATABASE VARIABLES
# ---------------------------
variable "db_username" { default = "admin" }
variable "db_password_secret_name" { default = "rds-db-password" }

# ---------------------------
# EC2 VARIABLES
# ---------------------------
variable "instance_type" { default = "t3.micro" }
variable "ami_id" { default = "" } # If empty, latest Amazon Linux 2 will be used
