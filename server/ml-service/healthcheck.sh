#!/bin/bash
# Health check script for ML service
# Returns 0 if healthy, 1 if unhealthy

# Check if the service is running
if ! curl -s http://localhost:5000/health | grep -q '"status": "healthy"'; then
    echo "Service health check failed"
    exit 1
fi

# Check if the model is loaded
if ! curl -s http://localhost:5000/health | grep -q '"model_loaded": true'; then
    echo "Model is not loaded"
    exit 1
fi

echo "Service is healthy"
exit 0