# Stage 1: Build
FROM python:3.9-slim as builder

RUN apt-get update && apt-get install -y gcc && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --retries 5 --timeout 30 --no-cache-dir -r requirements.txt

COPY . .

# Stage 2: Production
FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    libpq5 \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Python packages from builder
COPY --from=builder /usr/local /usr/local

# Application code — ALL needed directories
COPY --from=builder /app/api ./api
COPY --from=builder /app/app ./app
COPY --from=builder /app/contracts ./contracts
COPY --from=builder /app/model ./model
COPY --from=builder /app/models ./models
COPY --from=builder /app/services ./services

# Non-root user
RUN groupadd -g 1000 mluser && \
    useradd -u 1000 -g mluser -d /app mluser && \
    chown -R mluser:mluser /app

USER mluser

ENV PYTHONUNBUFFERED=1 \
    PYTHONPATH=/app \
    MODEL_PATH=/app/models/model.pkl

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["python", "api/main.py"]
