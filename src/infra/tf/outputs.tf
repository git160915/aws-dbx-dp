output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "private_subnet_id" {
  value       = aws_subnet.private.id
  description = "Private Subnet ID"
}

output "rds_endpoint" {
  value       = aws_db_instance.rds.endpoint
  description = "PostgreSQL RDS Endpoint"
}
