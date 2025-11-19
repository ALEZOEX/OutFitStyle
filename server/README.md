# OutfitStyle Server

This is the backend server for the OutfitStyle application, written in Go. It provides REST API endpoints for weather-based outfit recommendations powered by machine learning.

## Features

- RESTful API for outfit recommendations
- Integration with weather services
- Machine learning model integration
- User management and authentication
- Recommendation history tracking
- Achievement system
- Comprehensive logging and monitoring
- Docker support for easy deployment

## Architecture

The server follows a clean architecture pattern with the following layers:

```
cmd/
  └── server/           # Application entry point
internal/
  ├── api/              # HTTP layer (middleware, routes, handlers)
  ├── core/             # Business logic (domain, application)
  ├── infrastructure/   # External services (database, HTTP clients)
  └── pkg/              # Shared utilities
```

### API Layer

- **Middleware**: Authentication, logging, rate limiting, recovery
- **Routes**: URL routing for different resources
- **Handlers**: HTTP request/response handling

### Core Layer

- **Domain**: Core business entities
- **Application**: Business logic and use cases

### Infrastructure Layer

- **Config**: Configuration management
- **Persistence**: Database repositories
- **External**: External service clients (weather, ML)
- **Delivery**: HTTP server implementation

### Package Layer

- **Errors**: Custom error types
- **HTTP**: HTTP utilities
- **Security**: Authentication and security utilities
- **Utils**: General purpose utilities

## Prerequisites

- Go 1.21 or higher
- PostgreSQL 13 or higher
- Redis 6 or higher
- Docker (optional, for containerization)

## Configuration

Copy the example environment file and adjust the values:

```bash
cp .env.example .env
```

## Installation

1. Install dependencies:
   ```bash
   make deps
   ```

2. Build the application:
   ```bash
   make build
   ```

3. Run the application:
   ```bash
   make run
   ```

## Database Migrations

Run migrations:
```bash
make migrate-up
```

Create new migration:
```bash
make migrate-create name=migration_name
```

## Testing

Run tests:
```bash
make test
```

Run tests with coverage:
```bash
make test-cover
```

## Docker

Build Docker image:
```bash
make docker-build
```

Run Docker container:
```bash
make docker-run
```

## API Documentation

The API is documented using Swagger/OpenAPI. Documentation is available at `/api/docs` when the server is running.

Generate documentation:
```bash
make docs
```

## Monitoring

The server exposes Prometheus metrics at `/metrics` endpoint for monitoring and alerting.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.