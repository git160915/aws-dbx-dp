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

output "ec2_instance_id" {
  value       = aws_instance.ec2.id
  description = "EC2 Instance ID"
}

output "ec2_ssm_connect_command" {
  value       = "aws ssm start-session --target ${aws_instance.ec2.id}"
  description = "Command to connect to EC2 instance via AWS SSM"
}
