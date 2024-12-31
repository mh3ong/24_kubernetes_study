from fastapi import FastAPI
import uvicorn

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "This is CICD Application V1"}

if __name__ == '__main__':
    uvicorn.run(app, host="0.0.0.0", port=8000)