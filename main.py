from mangum import Mangum

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers.view_review import router as view_review_router
from routers.user import router as user_router


app = FastAPI()

app.include_router(view_review_router, prefix="/view-review", tags=["view_review"])
app.include_router(user_router, prefix="/user", tags=["user"])


# CORS settings
origins = [
    "http://localhost:3000",  # Your frontend origin
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,  # Allows your specified origins
    allow_credentials=True,
    allow_methods=["*"],  # Allows all methods (GET, POST, etc.)
    allow_headers=["*"],  # Allows all headers
)


@app.get("/")
async def root():
    return {"message": "Hello World from Lambda"}


@app.get("/hello/{name}")
async def say_hello(name: str):
    return {"message": f"Hello {name}"}


# Create the Mangum handler
handler = Mangum(app)
