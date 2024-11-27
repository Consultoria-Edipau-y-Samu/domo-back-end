
from fastapi import FastAPI
from app.routes import user




app = FastAPI()


app.include_router(user.router)

@app.get("/")
async def root():
    return {"message": "Hello World from Lambda"}


