FROM python:3.12
RUN pip install --no-cache-dir fastapi uvicorn
COPY server.py .
EXPOSE 8000
CMD ["python", "server.py"]