variable "function_name" {}
variable "handler" {}
variable "role_arn" {}
variable "source_path" {}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = var.role_arn
  handler       = var.handler
  runtime       = "python3.9"

  filename         = var.source_path
  source_code_hash = filebase64sha256(var.source_path)

  environment {
  variables = var.environment
}
}

output "function_name" {
  value = aws_lambda_function.this.function_name
}

output "invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}

variable "environment" {
  type    = map(string)
  default = {}
}