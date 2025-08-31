import json
import boto3
import os

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ.get("TABLE_NAME", "todos"))

def lambda_handler(event, context):
    todo_id = event.get("pathParameters", {}).get("id")
    body = json.loads(event.get("body", "{}"))
    done = body.get("done")

    if not todo_id or done is None:
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "ID and 'done' field required"})
        }

    response = table.update_item(
        Key={"id": todo_id},
        UpdateExpression="SET done = :done",
        ExpressionAttributeValues={":done": done},
        ReturnValues="ALL_NEW"
    )

    return {
        "statusCode": 200,
        "body": json.dumps(response["Attributes"])
    }