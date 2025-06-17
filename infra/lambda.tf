resource "aws_lambda_function" "api_handler" {
  function_name = "domo-ts-api-handler"
  handler       = "index.handler"
  runtime       = "nodejs18.x"
  role          = aws_iam_role.lambda_exec.arn

  filename         = "${path.module}/../lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/../lambda.zip")

  timeout = 10

  environment {
    variables = {
      AURORA_SECRET_ARN = aws_secretsmanager_secret.aurora_secret.arn
    }
  }

  vpc_config {
    subnet_ids         = [aws_subnet.private1.id, aws_subnet.private2.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }
}
