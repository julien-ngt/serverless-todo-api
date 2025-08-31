
import json
import uuid
import boto3
import os

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ.get("TABLE_NAME", "todos"))

def lambda_handler(event, context):
    body = json.loads(event.get("body", "{}"))
    task = body.get("task")

    if not task:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Task is required"})
        }

    todo_id = str(uuid.uuid4())
    item = {
        "id": todo_id,
        "task": task,
        "done": False
    }
    table.put_item(Item=item)

    return {
        "statusCode": 200,
        "body": json.dumps(item)
    }