# Main VPC for our infrastructure
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true    # 👈 necesario
  enable_dns_hostnames = true    # 👈 necesario

  tags = {
    Name = "main-vpc"
  }
}


# First private subnet (AZ us-east-1a)
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1"
  }
}

# Second private subnet (AZ us-east-1b)
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-2"
  }
}


# VPC Endpoint for Secrets Manager
resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids        = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]
  security_group_ids = [
    aws_security_group.lambda_sg.id
  ]

  private_dns_enabled = true

  tags = {
    Name = "secretsmanager-endpoint"
  }
}

# Allow Lambda to reach Secrets Manager VPC Endpoint over HTTPS
resource "aws_security_group_rule" "allow_lambda_to_secretsmanager" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id
}


