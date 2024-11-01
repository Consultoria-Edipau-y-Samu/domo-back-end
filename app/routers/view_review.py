from pydantic import BaseModel
from typing import List
from uuid import uuid4
from fastapi import APIRouter


class Address(BaseModel):
    street: str
    neighborhood: str
    zipCode: str
    city: str
    state: str


class Review(BaseModel):
    id: str
    date: str
    description: str
    emotion: str
    price: str


class AddressReviewResponse(BaseModel):
    address: Address
    reviews: List[Review]


router = APIRouter()


@router.get("/review/{review_id}", response_model=AddressReviewResponse)
async def view_review(review_id: str):
    return AddressReviewResponse(
        address=Address(
            street="Nantes 2839",
            neighborhood="Jardines de Altavista",
            zipCode="54876",
            city="Monterrey",
            state="NL",
        ),
        reviews=[
            Review(
                id=str(uuid4()),
                date="Hace 3 días",
                description="En mi depa habían muchas cucarachas y no tiene clima, ni agua caliente",
                emotion="frown",
                price="$15,000",
            ),
            Review(
                id=str(uuid4()),
                date="Hace 4 días",
                description="Me gustaba porque me daban de comer gratis",
                emotion="laugh",
                price="$13,000",
            ),
            Review(
                id=str(uuid4()),
                date="Hace 5 días",
                description="Se escucha todo, no dejaban coger a gusto",
                emotion="angry",
                price="$11,000",
            ),
            Review(
                id=str(uuid4()),
                date="Hace 12 días",
                description="Esta bien, recomiendo",
                emotion="meh",
                price="$10,000",
            ),
            Review(
                id=str(uuid4()),
                date="Hace 1 mes",
                description="Esta muy chido, la neta",
                emotion="smile",
                price="$30,000",
            ),
            Review(
                id=str(uuid4()),
                date="Hace 4 anios",
                description="Esta muy chido, la neta",
                emotion="smile",
                price="$30,000",
            ),
            Review(
                id=str(uuid4()),
                date="Hace mil meses",
                description="Esta muy chido, la neta",
                emotion="smile",
                price="$30,000",
            ),
        ],
    )
