# ---------------------------
# IAM ROLE FOR SSM ACCESS
# ---------------------------
resource "aws_iam_role" "ssm_role" {
  name = "EC2SSMRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": { "Service": "ec2.amazonaws.com" },
    "Action": "sts:AssumeRole"
  }]
}
EOF
}

# Attach SSM Managed Policy to Role
resource "aws_iam_role_policy_attachment" "ssm_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Create an Instance Profile
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "EC2SSMInstanceProfile"
  role = aws_iam_role.ssm_role.name
}

# ---------------------------
# CREATE FREE-TIER EC2 INSTANCE WITH STARTUP SCRIPT
# ---------------------------
resource "aws_instance" "ec2" {
  ami                  = data.aws_ssm_parameter.latest_ami.value # Latest Amazon Linux 2 AMI
  instance_type        = "t3.micro"
  subnet_id            = aws_subnet.private.id
  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name
  security_groups      = [aws_security_group.ec2_sg.id]

  # ✅ Attach existing SSH Key Pair
  key_name = var.ec2_key_pair

  user_data = <<-EOF
          #!/bin/bash
          set -e
          echo "🔹 Detecting OS and installing PostgreSQL Client (psql)..."

          # Detect OS using /etc/os-release
          if [ -f /etc/os-release ]; then
              . /etc/os-release
              OS_ID=$ID
              OS_VERSION=$VERSION_ID
          else
              echo "⚠️ Unable to detect OS. Exiting."
              exit 1
          fi

          echo "🔹 Detected OS: $OS_ID $OS_VERSION"

          case "$OS_ID" in
              "amzn")
                  echo "🔹 Installing PostgreSQL for Amazon Linux ($OS_VERSION)..."
                  if [[ "$OS_VERSION" == "2" ]]; then
                      sudo amazon-linux-extras enable postgresql14
                      sudo yum clean metadata
                      sudo yum install -y postgresql
                  else
                      sudo dnf install -y postgresql
                  fi
                  ;;
              "ubuntu" | "debian")
                  echo "🔹 Installing PostgreSQL for Ubuntu/Debian..."
                  sudo apt-get update -y
                  sudo apt-get install -y postgresql-client
                  ;;
              "rhel" | "centos")
                  echo "🔹 Installing PostgreSQL for RHEL/CentOS..."
                  sudo yum update -y
                  sudo yum install -y postgresql
                  ;;
              *)
                  echo "⚠️ Unsupported OS: $OS_ID. Please install PostgreSQL manually."
                  exit 1
                  ;;
          esac

          echo "✅ PostgreSQL Client (psql) installation complete."
  EOF

  tags = { Name = "EC2-SSM-PrivateInstance" }
}

# ---------------------------
# FETCH LATEST AMAZON LINUX 2 AMI
# ---------------------------
data "aws_ssm_parameter" "latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

