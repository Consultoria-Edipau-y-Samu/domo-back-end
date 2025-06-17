# Aurora subnet group (required)
resource "aws_db_subnet_group" "aurora_subnet_group" {
  name       = "aurora-subnet-group"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]

  tags = {
    Name = "Aurora Subnet Group"
  }
}

# SG for Lambda — allow outbound internet access
resource "aws_security_group" "lambda_sg" {
  name   = "lambda-sg"
  vpc_id = aws_vpc.main.id

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

# SG for Aurora — allow MySQL from Lambda SG
resource "aws_security_group" "aurora_sg" {
  name        = "aurora-sg"
  description = "Allow MySQL from Lambda"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow MySQL from Lambda"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.lambda_sg.id]
  }

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

# Aurora MySQL Serverless v2 Cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier      = "aurora-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.04.0"
  master_username         = "admin"
  master_password         = "SuperSecret123!"
  database_name           = "domosqldb"
  db_subnet_group_name    = aws_db_subnet_group.aurora_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.aurora_sg.id]
  backup_retention_period = 7
  preferred_backup_window = "03:00-05:00"

  # 👇 This block is REQUIRED to enable Serverless v2
  serverlessv2_scaling_configuration {
    min_capacity = 0.5
    max_capacity = 2
  }

  tags = {
    Name = "Aurora Serverless Cluster"
  }
}

# Aurora Serverless v2 Instance
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

# Optional output
output "aurora_endpoint" {
  value       = aws_rds_cluster.aurora.endpoint
  description = "Aurora writer endpoint for Lambda to connect to"
}
