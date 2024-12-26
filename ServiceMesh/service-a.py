from fastapi import FastAPI
import httpx
import uvicorn

app = FastAPI()

@app.get("/")
async def home():
    return {"message": "Service A is running"}

@app.get("/call-service-b")
async def call_service_b():
    service_b_url = "http://service-b"
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(service_b_url)
            return {"message": f"Response from Service B", "data": response.text}
    except Exception as e:
        return {"error": "Failed to connect to Service B", "details": str(e)}

if __name__ == '__main__':
    uvicorn.run(app, host="0.0.0.0", port=8000)