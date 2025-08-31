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
            "body": json.dumps({"error": "ID required"})
        }

    table.delete_item(Key={"id": todo_id})

    return {
        "statusCode": 200,
        "body": json.dumps({"message": f"Todo {todo_id} deleted"})
    }