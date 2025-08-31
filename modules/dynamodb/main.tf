variable "table_name" {}
variable "hash_key" {}

resource "aws_dynamodb_table" "this" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key

  attribute {
    name = var.hash_key
    type = "S"
  }
}

output "table_name" {
  value = aws_dynamodb_table.this.name
}