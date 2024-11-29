from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from app.db import get_table

class House(BaseModel):
    house_id: str 
    ext_number: str
    int_number: str
    street: str
    zip_code: str
    city: str
    state: str
    country: str

router = APIRouter()

# Tabla de DynamoDB para las casas
houses_table = get_table("domo-houses")

# Rutas para gestionar casas
@router.get("/houses")
async def get_houses(table=Depends(houses_table)):
    response = table.scan()
    return response.get("Items", [])

@router.post("/houses")
async def create_house(house: House, table=Depends(houses_table)):
    table.put_item(Item=house.dict())
    return {"message": "House added successfully", "house": house.dict()}

@router.get("/houses/{house_id}")
async def get_house(house_id: str, table=Depends(houses_table)):
    response = table.get_item(Key={"house_id": house_id})
    if "Item" not in response:
        raise HTTPException(status_code=404, detail="House not found")
    return response["Item"]

@router.delete("/houses/{house_id}")
async def delete_house(house_id: str, table=Depends(houses_table)):
    response = table.delete_item(Key={"house_id": house_id}, ReturnValues="ALL_OLD")
    if "Attributes" not in response:
        raise HTTPException(status_code=404, detail="House not found")
    return {"message": "House deleted successfully", "deleted_house": response["Attributes"]}

@router.put("/houses/{house_id}")
async def update_house(house_id: str, updates: House, table=Depends(houses_table)):
    update_expression = "SET " + ", ".join(f"{k} = :{k}" for k in updates.dict() if updates.dict()[k] is not None)
    expression_attribute_values = {f":{k}": v for k, v in updates.dict().items() if v is not None}

    response = table.update_item(
        Key={"house_id": house_id},
        UpdateExpression=update_expression,
        ExpressionAttributeValues=expression_attribute_values,
        ReturnValues="ALL_NEW"
    )
    if "Attributes" not in response:
        raise HTTPException(status_code=404, detail="House not found")
    return {"message": "House updated successfully", "updated_house": response["Attributes"]}
