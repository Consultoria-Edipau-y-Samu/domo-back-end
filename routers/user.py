from fastapi import APIRouter
from pydantic import BaseModel
from uuid import uuid4




router = APIRouter()

class UserInfoResponse(BaseModel):
    id:str
    fistName:str
    lastName:str
    hasContributed:bool


@router.get("/info/{user_id}", response_model=UserInfoResponse)
async def get_user_info(user_id: str):
    return UserInfoResponse(
        id=str(uuid4()),
        fistName="Fulanito",
        lastName="Menganito",
        hasContributed=True,
    )

