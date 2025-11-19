# Production Deployment Guide for OutfitStyle

This guide provides step-by-step instructions for deploying the OutfitStyle application to a production environment.

## Architecture Overview

OutfitStyle uses a microservices architecture with the following components:

1. **Go API Server** - Main backend service
2. **ML Service** - Python-based machine learning service
3. **PostgreSQL** - Primary database
4. **Redis** - Caching and session storage
5. **Nginx** - Reverse proxy and SSL termination

## Prerequisites

Before deployment, ensure you have:

- Docker and Docker Compose installed
- A domain name configured for SSL
- Environment variables properly configured
- SSL certificates (if using HTTPS)

## Deployment Steps

### 1. Prepare Environment Variables

Create a production environment file:

```bash
cp infrastructure/docker-compose/.env.example infrastructure/docker-compose/.env.prod
```

Edit `.env.prod` with your production values:

```env
# Database configuration
DB_USER=your_db_user
DB_PASSWORD=your_secure_password
DB_NAME=your_db_name

# JWT configuration
JWT_SECRET=your_secure_jwt_secret

# Weather API
WEATHER_API_KEY=your_openweathermap_api_key

# CORS configuration
CORS_ALLOWED_ORIGINS=https://yourdomain.com

# Server configuration
ENVIRONMENT=production
```

### 2. Build Docker Images

Build the production Docker images:

```bash
# Build Go API
cd server
docker build -t outfitstyle/api:latest -f Dockerfile.prod .

# Build ML Service
cd ml-service
docker build -t outfitstyle/ml-service:latest -f Dockerfile.prod .
```

### 3. Deploy Services

Deploy the services using Docker Compose:

```bash
cd infrastructure/docker-compose
docker-compose -f docker-compose.prod.yml up -d
```

### 4. Verify Deployment

Check that all services are running:

```bash
docker-compose -f docker-compose.prod.yml ps
```

Verify health checks:

```bash
curl http://localhost/health
curl http://localhost:5000/health
```

### 5. Monitor Services

Check logs for any issues:

```bash
docker-compose -f docker-compose.prod.yml logs -f
```

## Production Readiness Checklist

✅ **ML Service**:
- [x] Health checks implemented
- [x] Metrics and monitoring with Prometheus
- [x] Circuit breaker for resilience
- [x] Production Dockerfile

✅ **Go API**:
- [x] Proper error handling
- [x] Graceful shutdown
- [x] Rate limiting
- [x] Security headers

✅ **Frontend (Flutter)**:
- [x] Production build configuration
- [x] Error boundaries
- [x] Offline support
- [x] Performance optimization

✅ **Infrastructure**:
- [x] Docker Compose for production
- [x] Nginx reverse proxy with SSL
- [x] Health checks for all services
- [x] Monitoring and alerting ready

## Monitoring and Maintenance

### Health Checks

All services expose health check endpoints:
- API: `GET /health`
- ML Service: `GET /health`

### Metrics

Prometheus metrics are available:
- API: `GET /metrics`
- ML Service: Port 9090

### Logs

Logs are available through Docker:
```bash
docker-compose -f docker-compose.prod.yml logs -f <service_name>
```

## Troubleshooting

### Service Won't Start

1. Check logs: `docker-compose -f docker-compose.prod.yml logs -f`
2. Verify environment variables
3. Check database connectivity
4. Ensure dependencies are healthy

### Performance Issues

1. Monitor resource usage: `docker stats`
2. Check application logs for errors
3. Review Prometheus metrics
4. Scale services if needed

### Database Issues

1. Verify database connection settings
2. Check PostgreSQL logs
3. Ensure migrations have been applied

## Security Considerations

- All services run with non-root users
- Secrets are managed through environment variables
- API keys and passwords are not hardcoded
- Services communicate over internal Docker network
- Nginx provides SSL termination

## Backup and Recovery

Regular backups should be implemented for:
- PostgreSQL database
- ML model files
- Application logs

Example backup command:
```bash
docker-compose -f docker-compose.prod.yml exec postgres pg_dump -U outfitstyle outfitstyle > backup.sql
```

## Scaling

To scale services, modify the Docker Compose file:

```yaml
services:
  api:
    deploy:
      replicas: 3
```

Or use Docker Swarm or Kubernetes for orchestration.

## Conclusion

The OutfitStyle application is now ready for production use. All services are properly configured with health checks, monitoring, and security measures. Regular maintenance and monitoring will ensure continued reliability and performance.