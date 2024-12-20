from fastapi import FastAPI, Request, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
import time
import random
import uvicorn

app = FastAPI()

# Prometheus 메트릭 정의
REQUEST_COUNT = Counter('http_requests_total', 'Total HTTP requests', ['method', 'endpoint'])
REQUEST_LATENCY = Histogram('http_request_latency_seconds', 'Latency of HTTP requests', ['method', 'endpoint'])

@app.middleware("http")
async def prometheus_middleware(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time

    # 메트릭 데이터 업데이트
    REQUEST_COUNT.labels(method=request.method, endpoint=request.url.path).inc()
    REQUEST_LATENCY.labels(method=request.method, endpoint=request.url.path).observe(process_time)

    return response

@app.get("/")
def read_root():
    delay = random.uniform(0, 3)
    time.sleep(delay)
    return {"message": f"Hello, World. response delayed by {delay} seconds"}

@app.get("/metrics")
def get_metrics():
    # Prometheus 메트릭 노출
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)

if __name__ == '__main__':
    uvicorn.run(app, host="0.0.0.0", port=8000)