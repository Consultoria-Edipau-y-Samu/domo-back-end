import boto3

def get_dynamodb_client():
    # Create the DynamoDB resource
    return boto3.resource("dynamodb", region_name="us-east-1")

def get_table():
    # Access your specific table using the client
    dynamodb = get_dynamodb_client()
    return dynamodb.Table("domo")   