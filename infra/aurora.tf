#--------------------------------------------------
# SECURITY GROUPS
#--------------------------------------------------

# SG for Lambda — allow outbound internet access
resource "aws_security_group" "lambda_sg" {
  name   = "lambda-sg"
  vpc_id = aws_vpc.main.id

  # Allow all outbound traffic (egress) so Lambda can access the internet or VPC endpoints
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Lambda SG"
  }
}

# SG for Aurora — allows MySQL traffic only from Lambda SG
resource "aws_security_group" "aurora_sg" {
  name        = "aurora-sg"
  description = "Allow MySQL from Lambda"
  vpc_id      = aws_vpc.main.id

  # Allow inbound MySQL (port 3306) only from Lambda SG
  ingress {
    description     = "Allow MySQL from Lambda"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

  # Allow all outbound traffic from Aurora (e.g., to AWS services)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Aurora SG"
  }
}

#--------------------------------------------------
# SUBNET GROUP (Required for Aurora)
#--------------------------------------------------

# DB Subnet Group for Aurora — uses private subnets
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [
    aws_subnet.private1.id,
    aws_subnet.private2.id
  ]

  tags = {
    Name = "Aurora Subnet Group"
  }
}

#--------------------------------------------------
# AURORA CLUSTER AND INSTANCE
#--------------------------------------------------

# Aurora MySQL Serverless v2 Cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.04.0"
  master_username         = var.db_username
  master_password         = var.db_password
  database_name           = var.db_name
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]
  backup_retention_period = 7
  preferred_backup_window = "03:00-05:00"

  # Serverless v2 configuration
  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 2
  }

  tags = {
    Name = "Aurora Serverless Cluster"
  }
}

# Instance associated with the Aurora Cluster
resource "aws_rds_cluster_instance" "aurora_instance" {
  identifier          = "aurora-serverless-instance"
  cluster_identifier  = aws_rds_cluster.aurora.id
  instance_class      = "db.serverless"
  engine              = "aurora-mysql"
  publicly_accessible = false

  tags = {
    Name = "Aurora Serverless Writer"
  }
}

#--------------------------------------------------
# OUTPUTS
#--------------------------------------------------

# Outputs the Aurora writer endpoint (to be used by Lambda)
output "aurora_endpoint" {
  value       = aws_rds_cluster.aurora.endpoint
  description = "Aurora writer endpoint for Lambda to connect to"
}
