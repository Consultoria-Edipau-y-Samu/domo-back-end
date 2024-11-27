from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from app.db import get_table

# Define el esquema del usuario
class User(BaseModel):
    user_id: str
    user_name: str

router = APIRouter()

@router.get("/user")
async def read_items(table=Depends(get_table("domo-users"))):
    # Escanear la tabla y devolver los ítems
    response = table.scan()
    return response.get("Items", [])

@router.post("/user")
async def add_item(item: User, table=Depends(get_table("domo-users"))):
    # Insertar un ítem en la tabla
    table.put_item(Item=item.dict())
    return {"message": "Item added successfully", "item": item.dict()}

@router.get("/user/{user_id}")
async def get_user(user_id: str, table=Depends(get_table("domo-users"))):
    # Obtener un usuario por ID
    response = table.get_item(Key={"user_id": user_id})
    if "Item" not in response:
        raise HTTPException(status_code=404, detail="User not found")
    return response["Item"]

@router.delete("/user/{user_id}")
async def delete_user(user_id: str, table=Depends(get_table("domo-users"))):
    # Eliminar un usuario por ID
    response = table.delete_item(Key={"user_id": user_id}, ReturnValues="ALL_OLD")
    if "Attributes" not in response:
        raise HTTPException(status_code=404, detail="User not found")
    return {"message": "User deleted successfully", "deleted_item": response["Attributes"]}

@router.put("/user/{user_id}")
async def update_user(user_id: str, updates: User, table=Depends(get_table("domo-users"))):
    # Preparar la expresión de actualización y los valores de atributos
    update_expression = "SET " + ", ".join(f"{k} = :{k}" for k in updates.dict() if updates.dict()[k] is not None)
    expression_attribute_values = {f":{k}": v for k, v in updates.dict().items() if v is not None}

    # Realizar la actualización
    response = table.update_item(
        Key={"user_id": user_id},
        UpdateExpression=update_expression,
        ExpressionAttributeValues=expression_attribute_values,
        ReturnValues="ALL_NEW"  # Devuelve el ítem actualizado
    )
    if "Attributes" not in response:
        raise HTTPException(status_code=404, detail="User not found")
    return {"message": "User updated successfully", "updated_item": response["Attributes"]}
