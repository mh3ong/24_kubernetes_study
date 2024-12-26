FROM python:3.12
RUN pip install fastapi uvicorn
COPY server.py .
EXPOSE 8000
CMD ["python", "server.py"]