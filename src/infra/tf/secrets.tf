# ---------------------------
# RETRIEVE DB PASSWORD FROM AWS SECRETS MANAGER
# ---------------------------

# Reference the secret by name
data "aws_secretsmanager_secret" "db_password" {
  name = "rds-db-password"
}

# Get the latest version of the secret
data "aws_secretsmanager_secret_version" "db_password_latest" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}

# Use the password inside Terraform
# password = jsondecode(data.aws_secretsmanager_secret_version.db_password_latest.secret_string)["password"]