#--------------------------------------------------
# REST API Definition
#--------------------------------------------------

# Creates a new REST API named "ts-rest-api"
resource "aws_api_gateway_rest_api" "rest_api" {
  name        = "ts-rest-api"
  description = "REST API for Lambda integration"
}

#--------------------------------------------------
# Resource Path (e.g., /v1)
#--------------------------------------------------

# Creates a new resource under the root path of the REST API
# In this case, it creates a "/v1" endpoint
resource "aws_api_gateway_resource" "root_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = "v1"
}

#--------------------------------------------------
# HTTP Method on the Resource
#--------------------------------------------------

# Defines a POST method on the "/v1" resource
# No authorization is required (authorization = "NONE")
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.root_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

#--------------------------------------------------
# Lambda Integration for the POST Method
#--------------------------------------------------

# Integrates the POST method on "/v1" with a Lambda function
# Uses AWS_PROXY to forward the full request to Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.root_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_handler.invoke_arn
}

#--------------------------------------------------
# Deployment and Stage
#--------------------------------------------------

# Deploys the REST API (required for the API to be accessible)
resource "aws_api_gateway_deployment" "rest_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  description = "Deploy REST API"
}

# Defines a stage (named "prod") where the deployed API is made available
resource "aws_api_gateway_stage" "rest_stage" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  deployment_id = aws_api_gateway_deployment.rest_deployment.id
  stage_name    = "prod"
}

#--------------------------------------------------
# Permissions
#--------------------------------------------------

# Grants API Gateway permission to invoke the Lambda function
# Allows any method (*) on any resource path (/*/*)
resource "aws_lambda_permission" "rest_api_permission" {
  statement_id  = "AllowRestApiInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.rest_api.execution_arn}/*/*"
}


resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.root_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.root_resource.id
  http_method             = aws_api_gateway_method.options_method.http_method
  integration_http_method = "POST" # still POST because it's proxy to Lambda
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_handler.invoke_arn
}
