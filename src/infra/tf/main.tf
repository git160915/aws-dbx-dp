# ---------------------------
# CREATE VPC
# ---------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "MyVPC" }
}

# ---------------------------
# CREATE SUBNETS
# ---------------------------
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = { Name = "PublicSubnet" }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = { Name = "PrivateSubnet" }
}

resource "aws_subnet" "vector" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.vector_subnet_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = { Name = "VectorSubnet" }
}

# ---------------------------
# CREATE RDS SUBNET GROUP
# ---------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "rds-subnet-group"
  description = "Subnet group for PostgreSQL RDS"
  subnet_ids  = [aws_subnet.private.id, aws_subnet.vector.id]
  tags        = { Name = "RDSSubnetGroup" }
}

# ---------------------------
# SECURITY GROUPS
# ---------------------------
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "EC2SecurityGroup" }
}

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
  tags = { Name = "RDSSecurityGroup" }
}

# ---------------------------
# CREATE POSTGRESQL RDS INSTANCE
# ---------------------------
resource "aws_db_instance" "rds" {
  identifier             = "mypostgresdb"
  allocated_storage      = 20
  instance_class         = "db.t3.micro"
  engine                = "postgres"
  engine_version        = "17.4"
  username              = var.db_username
  password              = jsondecode(data.aws_secretsmanager_secret_version.db_password_latest.secret_string)["password"]
  db_subnet_group_name  = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible   = false
  backup_retention_period = 7
  skip_final_snapshot = true
  tags = { Name = "MyPostgresRDS" }
}
