#--------------------------------------------------
# MAIN VPC CONFIGURATION
#--------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"  # Private IP range for the VPC

  # Enable DNS features required for interface endpoints like Secrets Manager
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

#--------------------------------------------------
# PRIVATE SUBNETS (for Lambda and Aurora)
#--------------------------------------------------

# Private Subnet in Availability Zone us-east-1a
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "private-subnet-1"
  }
}

# Private Subnet in Availability Zone us-east-1b
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "private-subnet-2"
  }
}

#--------------------------------------------------
# VPC ENDPOINT FOR SECRETS MANAGER
#--------------------------------------------------

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.us-east-1.secretsmanager"  # AWS service endpoint
  vpc_endpoint_type = "Interface"  # Required for Secrets Manager

  # Attach endpoint to both private subnets
  subnet_ids = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]

  # Allow access from Lambda's security group
  security_group_ids = [
    aws_security_group.lambda_sg.id
  ]

  # Required to resolve *.secretsmanager.amazonaws.com to the VPC endpoint
  private_dns_enabled = true

  tags = {
    Name = "secretsmanager-endpoint"
  }
}

#--------------------------------------------------
# SG RULE: ALLOW HTTPS TO SECRETS MANAGER FROM LAMBDA SG
#--------------------------------------------------

resource "aws_security_group_rule" "allow_lambda_to_secretsmanager" {
  type                     = "ingress"
  from_port                = 443     # HTTPS port
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lambda_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id  # Self-allow within Lambda SG
}
