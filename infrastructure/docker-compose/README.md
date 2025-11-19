# Docker Compose Infrastructure

This directory contains Docker Compose configurations for both development and production environments.

## Files

- `docker-compose.yml` - Development environment configuration
- `docker-compose.prod.yml` - Production environment configuration
- `.env.example` - Example environment variables

## Development Environment

The development environment includes volume mounts for live code reloading and exposes all services on their respective ports:

```bash
# Start development environment
docker-compose up -d

# View logs
docker-compose logs -f
```

## Production Environment

The production environment includes health checks, security enhancements, and optimizations:

```bash
# Start production environment
docker-compose -f docker-compose.prod.yml up -d
```

## Services

1. **API Server** - Go application serving the REST API
2. **PostgreSQL** - Main database
3. **Redis** - Cache and session store
4. **ML Service** - Python machine learning microservice
5. **Marketplace Service** - Python service for marketplace integrations
6. **Nginx** (Production only) - Reverse proxy with SSL termination
7. **Client** (Development only) - Flutter web development server

## Environment Variables

Copy `.env.example` to `.env` for development or `.env.prod` for production and adjust values as needed.