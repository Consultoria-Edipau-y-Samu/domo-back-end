from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from app.db import get_table

#Define the schema for the item
class House(BaseModel):
    house_id: str
    house_address:str



router = APIRputer()

@router.get("/house")
async def read_items(table=Depends(get_table)):
    response = table.scan()
    return response["Items"]

