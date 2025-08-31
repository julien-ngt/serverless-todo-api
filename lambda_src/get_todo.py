import json
import boto3
import os

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ.get("TABLE_NAME", "todos"))

def lambda_handler(event, context):
    todo_id = event.get("pathParameters", {}).get("id")

    if not todo_id:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "ID is required"})
        }

    response = table.get_item(Key={"id": todo_id})
    item = response.get("Item")

    if not item:
        return {
            "statusCode": 404,
            "body": json.dumps({"error": "Todo not found"})
        }

    return {
        "statusCode": 200,
        "body": json.dumps(item)
    }