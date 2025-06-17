#--------------------------------------------------
# LAMBDA FUNCTION: API HANDLER
#--------------------------------------------------

resource "aws_lambda_function" "api_handler" {
  function_name = "domo-ts-api-handler"  # Name of the Lambda function in AWS
  handler       = "index.handler"        # Entry point: index.js → exports.handler
  runtime       = "nodejs18.x"           # Node.js runtime version
  role          = aws_iam_role.lambda_exec.arn  # IAM role with execution permissions

  # Path to the Lambda deployment package (ZIP file)
  filename         = "${path.module}/../lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda.zip")  # Ensures updates trigger redeploy

  # Timeout after 10 seconds (useful for database/API calls that may take time)
  timeout = 10

  #--------------------------------------------------
  # ENVIRONMENT VARIABLES
  #--------------------------------------------------
  environment {
    variables = {
      # Pass the Secrets Manager ARN as an env variable (optional but convenient)
      AURORA_SECRET_ARN = aws_secretsmanager_secret.aurora_secret.arn
    }
  }

  #--------------------------------------------------
  # VPC CONFIGURATION
  #--------------------------------------------------
  vpc_config {
    # Attach Lambda to private subnets in your VPC to access Aurora and VPC endpoints
    subnet_ids         = [aws_subnet.private1.id, aws_subnet.private2.id]

    # Apply the security group that allows egress to Secrets Manager and database
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}
