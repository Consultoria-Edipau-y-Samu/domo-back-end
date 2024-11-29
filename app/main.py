
from fastapi import FastAPI
from app.routes import user, house, review

app = FastAPI()


app.include_router(user.router)
app.include_router(house.router)
app.include_router(review.router)

@app.get("/")
async def root():
    return {"message": "Hello World from Lambda"}


