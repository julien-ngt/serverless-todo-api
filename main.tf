provider "aws" {
  region = "us-east-1"
}

#####################
# IAM Role for Lambdas
#####################
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

#####################
# DynamoDB Table
#####################
module "dynamodb" {
  source     = "./modules/dynamodb"
  table_name = "todos"
  hash_key   = "id"
}

#####################
# Lambda Functions
#####################
module "lambda_create" {
  source        = "./modules/lambda"
  function_name = "create_todo"
  handler       = "create_todo.lambda_handler"
  role_arn      = aws_iam_role.lambda_role.arn
  source_path   = "${path.module}/lambda_src/create_todo.zip"
}

module "lambda_get" {
  source        = "./modules/lambda"
  function_name = "get_todo"
  handler       = "get_todo.lambda_handler"
  role_arn      = aws_iam_role.lambda_role.arn
  source_path   = "${path.module}/lambda_src/get_todo.zip"
}

#####################
# Single API Gateway
#####################
resource "aws_apigatewayv2_api" "main_api" {
  name          = "todos_api"
  protocol_type = "HTTP"
}

#####################
# Routes for Lambdas
#####################
module "api_post" {
  source              = "./modules/api_gateway"
  api_id              = aws_apigatewayv2_api.main_api.id
  lambda_invoke_arn   = module.lambda_create.invoke_arn
  lambda_function_name = module.lambda_create.function_name
  route_key           = "POST /todos"
}

module "api_get" {
  source              = "./modules/api_gateway"
  api_id              = aws_apigatewayv2_api.main_api.id
  lambda_invoke_arn   = module.lambda_get.invoke_arn
  lambda_function_name = module.lambda_get.function_name
  route_key           = "GET /todos/{id}"
}

#####################
# Output API Endpoint
#####################
output "api_endpoint" {
  value = aws_apigatewayv2_api.main_api.api_endpoint
}

resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.main_api.id
  name   = "$default"
  auto_deploy = true
}

module "lambda_update" {
  source        = "./modules/lambda"
  function_name = "update_todo"
  handler       = "update_todo.lambda_handler"
  role_arn      = aws_iam_role.lambda_role.arn
  source_path   = "./lambda_src/update_todo.zip"

   environment = {
    TABLE_NAME = module.dynamodb.table_name
  }
}

module "lambda_delete" {
  source        = "./modules/lambda"
  function_name = "delete_todo"
  handler       = "delete_todo.lambda_handler"
  role_arn      = aws_iam_role.lambda_role.arn
  source_path   = "./lambda_src/delete_todo.zip"

   environment = {
    TABLE_NAME = module.dynamodb.table_name
  }
}

module "api_update" {
  source              = "./modules/api_gateway"
  api_id              = aws_apigatewayv2_api.main_api.id
  lambda_invoke_arn   = module.lambda_update.invoke_arn
  lambda_function_name = module.lambda_update.function_name
  route_key           = "PUT /todos/{id}"
}

module "api_delete" {
  source              = "./modules/api_gateway"
  api_id              = aws_apigatewayv2_api.main_api.id
  lambda_invoke_arn   = module.lambda_delete.invoke_arn
  lambda_function_name = module.lambda_delete.function_name
  route_key           = "DELETE /todos/{id}"
}