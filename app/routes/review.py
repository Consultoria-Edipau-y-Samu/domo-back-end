from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from app.db import get_table

class Review(BaseModel):
    review_id: str  
    user_id: str  
    house_id: str 
    review: str
    rating: int 
    price: int
    timestamp: str


router = APIRouter()

# Tablas de DynamoDB
houses_table = get_table("domo-houses")
reviews_table = get_table("domo-reviews")

# Rutas para gestionar reseñas
@router.get("/reviews")
async def get_reviews(table=Depends(reviews_table)):
    try:
        response = table.scan()
        return response.get("Items", [])
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error retrieving reviews: {str(e)}")

@router.post("/reviews")
async def create_review(review: Review, table=Depends(reviews_table), house_table=Depends(houses_table)):
    # Verificar si la casa existe antes de crear la reseña
    house_response = house_table.get_item(Key={"house_id": review.house_id})
    if "Item" not in house_response:
        raise HTTPException(status_code=404, detail="House not found")
    table.put_item(Item=review.dict())
    return {"message": "Review added successfully", "review": review.dict()}

@router.get("/reviews/{review_id}")
async def get_review(review_id: str, table=Depends(reviews_table)):
    response = table.get_item(Key={"review_id": review_id})
    if "Item" not in response:
        raise HTTPException(status_code=404, detail="Review not found")
    return response["Item"]

@router.delete("/reviews/{review_id}")
async def delete_review(review_id: str, table=Depends(reviews_table)):
    response = table.delete_item(Key={"review_id": review_id}, ReturnValues="ALL_OLD")
    if "Attributes" not in response:
        raise HTTPException(status_code=404, detail="Review not found")
    return {"message": "Review deleted successfully", "deleted_review": response["Attributes"]}

@router.put("/reviews/{review_id}")
async def update_review(review_id: str, updates: Review, table=Depends(reviews_table)):
    update_expression = "SET " + ", ".join(f"{k} = :{k}" for k in updates.dict() if updates.dict()[k] is not None)
    expression_attribute_values = {f":{k}": v for k, v in updates.dict().items() if v is not None}

    response = table.update_item(
        Key={"review_id": review_id},
        UpdateExpression=update_expression,
        ExpressionAttributeValues=expression_attribute_values,
        ReturnValues="ALL_NEW"
    )
    if "Attributes" not in response:
        raise HTTPException(status_code=404, detail="Review not found")
    return {"message": "Review updated successfully", "updated_review": response["Attributes"]}

@router.get("/reviews/house/{house_id}")
async def get_reviews_by_house(house_id: str, table=Depends(reviews_table)):
    response = table.scan(FilterExpression="house_id = :house_id", ExpressionAttributeValues={":house_id": house_id})
    return response.get("Items", [])