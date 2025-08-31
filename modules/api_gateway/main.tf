variable "api_id" {}
variable "lambda_invoke_arn" {}
variable "lambda_function_name" {}
variable "route_key" {}

# Integration
resource "aws_apigatewayv2_integration" "this" {
  api_id           = var.api_id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_invoke_arn
}

# Route
resource "aws_apigatewayv2_route" "this" {
  api_id    = var.api_id
  route_key = var.route_key
  target    = "integrations/${aws_apigatewayv2_integration.this.id}"
}

# Lambda permission (allow API Gateway to call Lambda)
resource "aws_lambda_permission" "this" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.api_id}/*/*"
}

# Data sources for region & account

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

