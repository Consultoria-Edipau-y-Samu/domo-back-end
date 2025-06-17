#--------------------------------------------------
# IAM ROLE FOR LAMBDA EXECUTION
#--------------------------------------------------

# IAM role assumed by Lambda to execute code
resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  # Trust policy allowing Lambda service to assume this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"  # Lambda is the trusted service
      },
      Action = "sts:AssumeRole"
    }]
  })
}

#--------------------------------------------------
# POLICY ATTACHMENTS AND INLINE POLICIES
#--------------------------------------------------

# Attach the AWS-managed basic Lambda execution policy
# This allows logging to CloudWatch, among other basic actions
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Inline policy: Allow Lambda to manage network interfaces
# Required when the Lambda is deployed inside a VPC
resource "aws_iam_role_policy" "lambda_vpc_permissions" {
  name = "lambda-vpc-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",   # Needed to attach to VPC subnets
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface"
        ],
        Resource = "*"  # Typically limited further in production
      }
    ]
  })
}

# Inline policy: Allow Lambda to fetch credentials from Secrets Manager
# Needed for retrieving the DB credentials stored securely
resource "aws_iam_role_policy" "lambda_secrets_access" {
  name = "lambda-secrets-access"
  role = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = aws_secretsmanager_secret.aurora_secret.arn  # Scoped to your Aurora secret
      }
    ]
  })
}
