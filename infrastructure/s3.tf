# Provision Bucket
resource "aws_s3_bucket" "lambda_code" {
  bucket = "my-lambda-code-bucket"
  acl    = "private"
}

# Upload the Lambda code (ZIP file) to the S3 bucket
resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_code.bucket
  key    = "lambda-function.zip"  # The object key in S3
  source = "path/to/lambda-function.zip"  # Local path to the Lambda ZIP file
  acl    = "private"
}