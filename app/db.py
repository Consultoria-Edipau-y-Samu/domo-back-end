import boto3

def get_dynamodb_client():
    # Create the DynamoDB resource
    return boto3.resource("dynamodb", region_name="us-east-1")

def get_table(table_name: str):
    def table_dependency():
        dynamodb = get_dynamodb_client()
        return dynamodb.Table(table_name)
    return table_dependency