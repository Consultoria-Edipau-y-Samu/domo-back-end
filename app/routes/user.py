from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from app.db import get_table


# Define the schema for the item
class User(BaseModel):
    user_id: str
    user_name:str


router = APIRouter()

    

@router.get("/user")
async def read_items(table=Depends(get_table)):
    # Scan the DynamoDB table and return the items
    response = table.scan()
    return response["Items"]



@router.post("/user")
async def add_item(item: User, table=Depends(get_table)):
    # Convert the item data to a dictionary
    item_data = item.model_dump()
    
    # Put the item into the DynamoDB table
    table.put_item(Item=item_data)
    
    return {"message": "Item added successfully", "item": item_data}



@router.get("/user/{user_id}")
async def get_user(user_id: str, table=Depends(get_table)):
    # Query DynamoDB for the item with the specified user_id
    response = table.get_item(Key={"user_id": user_id})
    
    # Check if the item exists
    if 'Item' not in response:
        raise HTTPException(status_code=404, detail="User not found")

    return response["Item"]



@router.delete("/user/{user_id}")
async def delete_user(user_id: str, table=Depends(get_table)):
    # Attempt to delete the item with the specified user_id
    response = table.delete_item(
        Key={"user_id": user_id},
        ReturnValues="ALL_OLD"  # Returns the deleted item if it existed
    )
    
    # Check if the item was actually deleted
    if 'Attributes' not in response:
        raise HTTPException(status_code=404, detail="User not found")

    return {"message": "User deleted successfully", "deleted_item": response["Attributes"]}







@router.put("/user/{user_id}")
async def update_user(user_id: str, updates: User, table=Depends(get_table)):
    # Prepare the update expression and attribute values
    update_expression = "SET " + ", ".join(f"{k} = :{k}" for k in updates.dict() if updates.dict()[k] is not None)
    expression_attribute_values = {f":{k}": v for k, v in updates.dict().items() if v is not None}

    # Perform the update
    response = table.update_item(
        Key={"user_id": user_id},
        UpdateExpression=update_expression,
        ExpressionAttributeValues=expression_attribute_values,
        ReturnValues="ALL_NEW"  # Returns the updated item
    )

    # Check if the update was successful
    if 'Attributes' not in response:
        raise HTTPException(status_code=404, detail="User not found")

    return {"message": "User updated successfully", "updated_item": response["Attributes"]}
