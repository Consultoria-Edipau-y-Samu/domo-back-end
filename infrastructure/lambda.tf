# infrastructure/lambda.tf

resource "aws_lambda_function" "api_lambda" {
  function_name = "lambda-api"

  s3_bucket = aws_s3_bucket.lambda_code.bucket
  s3_key    = aws_s3_object.lambda_code.key

  handler = "app.handler"  # Your Lambda handler function
  runtime = "python3.8"    # Use the appropriate runtime for your code

  role = aws_iam_role.lambda_role.arn  # IAM role for the Lambda function
}
