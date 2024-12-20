FROM python:3.12
RUN pip install fastapi uvicorn prometheus-client
COPY a.py .
EXPOSE 8000
CMD ["python", "server.py"]