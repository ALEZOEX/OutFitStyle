# OutfitStyle Project Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Technology Stack](#technology-stack)
4. [Development Setup](#development-setup)
5. [Building and Running](#building-and-running)
6. [Testing](#testing)
7. [Development Conventions](#development-conventions)
8. [Project Structure](#project-structure)
9. [Configuration](#configuration)
10. [Monitoring and Observability](#monitoring-and-observability)
11. [Security](#security)
12. [Deployment](#deployment)

## Project Overview

OutfitStyle is an advanced fashion recommendation platform that suggests the perfect outfit based on weather conditions, personal style preferences, and occasion. The platform combines machine learning algorithms with current weather data to provide personalized outfit recommendations.

### Key Features
- **Weather-based recommendations**: Get outfit suggestions based on current weather
- **Personalized preferences**: Customize recommendations according to your style
- **Wardrobe management**: Add and manage your clothing items
- **AI-powered matching**: Machine learning algorithm for outfit matching
- **Offline support**: Works without internet connection
- **Cross-platform**: Available on iOS and Android
- **Feature flags**: A/B testing and gradual rollouts
- **Push notifications**: Weather and recommendation alerts
- **Analytics and crash reporting**: Firebase integration

## Architecture

### System Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Application  │    │    Go API       │    │  Python ML      │
│   Flutter      │    │                 │    │  Service        │
│  Presentation  │◄──►│  Business Logic │◄──►│                 │
│  Layer         │    │  Layer          │    │  ML Models      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │  Apache Kafka   │
                       │  Message Broker │
                       └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │  PostgreSQL     │
                       │  Database       │
                       └─────────────────┘
                              │
                              ▼
                       ┌─────────────────┐
                       │    Redis        │
                       │  Cache/Session  │
                       └─────────────────┘
```

### Technology Stack

#### Backend Services
- **Language**: Go 1.21+
- **Framework**: net/http + custom middleware
- **Database**: PostgreSQL
- **Caching**: Redis
- **ML Service**: Python (FastAPI, scikit-learn)
- **Metrics**: Prometheus
- **Logging**: Zap (structured logging)
- **Messaging**: Apache Kafka
- **Service Mesh**: Istio

#### Frontend Application
- **Framework**: Flutter
- **State Management**: Riverpod
- **Navigation**: Go Router
- **Database**: Drift (SQLite)
- **Networking**: Dio + Retrofit
- **Analytics**: Firebase Analytics
- **Crash Reporting**: Firebase Crashlytics

#### Infrastructure
- **Containerization**: Docker
- **Deployment**: Docker Compose / Kubernetes
- **Monitoring**: Prometheus + Grafana
- **Logging**: Zap (structured logging)
- **CI/CD**: GitHub Actions
- **Security**: HashiCorp Vault (recommended)

## Development Setup

### Prerequisites
- Go 1.21+ for backend development
- Flutter SDK 3.16+ for frontend development
- Python 3.11+ for ML service
- Docker & Docker Compose for containerization
- Git for version control

### Local Development Setup

1. **Clone the repository**
```bash
git clone https://github.com/your-org/outfitstyle.git
cd outfitstyle
```

2. **Set up environment variables**
```bash
cp .env.example .env
# Edit .env with your API keys and database credentials
```

3. **Run services with Docker Compose**
```bash
docker-compose up -d
```

4. **For frontend development**
```bash
cd client
flutter pub get
flutter run
```

5. **For backend development**
```bash
cd server
go run cmd/server/main.go
```

## Building and Running

### Production Deployment
```bash
# Build and deploy with Docker Compose
docker-compose -f docker-compose.prod.yml up -d
```

### Limited Resource Mode
For running the project with limited resource usage (to avoid overloading your PC):

1. Ensure Docker Desktop is running
2. Ensure you have at least 4 GB of free RAM
3. Run the `start-limited.bat` script as administrator OR:
```bash
docker-compose -f docker-compose.dev.yml up --build
```

### Service Addresses
- API: http://localhost:8080
- PostgreSQL: localhost:5432
- Redis: localhost:6379
- ML Service: http://localhost:5000

## Testing

### Backend Tests
```bash
cd server
go test -v ./...
```

### Frontend Tests
```bash
cd client
flutter test
```

### ML Service Tests
```bash
cd ml-service
python -m pytest tests/ -v
```

## Development Conventions

### Go Backend Standards
- Structure: cmd/, internal/, migrations/, api/ (if exists), pkg/ (only if needed)
- net/http + middleware; context required (context.Context) in all requests/calls
- Errors: wrap with fmt.Errorf("...: %w", err), unified error response format
- Logging Zap: structural fields (request_id, user_id, trace_id, component, latency_ms), no logging of secrets/PII
- PostgreSQL: parameterized queries, migrations with goose/migrate, explicit transactions
- Redis: clear keys with namespace, TTL considered, cache not source of truth
- API: OpenAPI/Swagger via swag, version routes (/v1/…), rate limit, CORS, security headers
- Observability: /healthz, /readyz, Prometheus metrics, OpenTelemetry traces

### Flutter Client Standards
- Architecture: layers data/domain/presentation (or adopted approach in repo), no "business logic" in widgets
- State management: Riverpod (typed providers)
- Navigation: GoRouter
- Networking: Dio + Retrofit, unified error handler, retries with backoff
- Offline-first: Drift (SQLite) with schemas, migrations, synchronization, conflict resolution
- Quality: null-safety everywhere, dartdoc for public classes/methods, unified formatting

### Python ML Service Standards
- FastAPI, Pydantic schemas for input/output
- Model: explicit model version (model_version), reproducibility (seed, dependencies)
- Inference: fast, non-blocking event loop, timeouts and input size limits
- Contracts: schemas agreed with Go (contract tests/fixtures)
- Tests: pytest, tests on schemas, edge cases, quality degradation checks

## Project Structure

```
outfitstyle/
├── .env.example              # Example environment variables
├── .env.limited              # Limited resource environment variables
├── docker-compose*.yml       # Docker Compose configurations
├── Makefile                  # Build automation
├── README.md                 # Main project documentation
├── RUN_LOCAL.md              # Local development guide
├── start-limited.bat         # Script for limited resource startup
├── basic_catalog.ndjson      # Sample catalog data
├── client/                   # Flutter mobile application
│   ├── lib/                  # Application source code
│   ├── test/                 # Unit and widget tests
│   ├── pubspec.yaml          # Dependencies and configuration
│   └── ...
├── server/                   # Go backend API
│   ├── cmd/                  # Main applications
│   ├── internal/             # Internal packages
│   ├── migrations/           # Database migration files
│   ├── go.mod                # Go module definition
│   └── ...
├── ml-service/               # Python ML service
│   ├── api/                  # API endpoints
│   ├── model/                # ML model implementation
│   ├── train/                # Training scripts
│   ├── requirements.txt      # Python dependencies
│   └── ...
├── contracts/                # API contracts
├── docs/                     # Documentation
├── event-driven/             # Event-driven architecture components
├── grafana/                  # Grafana dashboards
├── infrastructure/           # Infrastructure as code
├── istio/                    # Istio service mesh configuration
├── k8s/                      # Kubernetes manifests
├── models/                   # Data models
├── nginx/                    # Nginx configuration
├── prometheus/               # Prometheus configuration
├── scripts/                  # Utility scripts
└── tests/                    # Integration and end-to-end tests
```

## Configuration

### Environment Variables
Key environment variables defined in `.env.example`:
- Database configuration (DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_NAME)
- JWT configuration (JWT_SECRET)
- Weather API configuration (WEATHER_API_KEY, WEATHER_API_BASE_URL)
- ML Service configuration (ML_SERVICE_URL)
- Redis configuration (REDIS_URL)
- Google OAuth configuration (GOOGLE_CLIENT_ID)
- Admin API key (ADMIN_API_KEY)

### Feature Flags
- FEATURE_PARTNER_CATALOG: Enable partner catalog functionality
- FEATURE_AB_TESTING: Enable A/B testing capabilities
- FEATURE_ACHIEVEMENTS: Enable achievement system
- FEATURE_TRIPS: Enable trip planning features

## Monitoring and Observability

### Three Pillars
- **Metrics**: Prometheus for quantitative measurements
- **Logs**: Structured logging with Zap
- **Traces**: Distributed tracing with OpenTelemetry

### Key Metrics
- **System**: CPU, memory, disk, network
- **Application**: Response time, error rate, throughput
- **Service Mesh**: Inter-service requests, response time, error percentage
- **Messaging**: Processing lag, event count, processing errors
- **Business**: DAU, conversion rates, feature usage

## Security

### Authentication and Authorization
- JWT tokens with RS256 algorithm
- OAuth 2.0 with Google login
- Rate limiting per user/IP
- Input validation at all boundaries

### Service Mesh Security
- mTLS encryption between all services
- JWT token validation at sidecar level
- Service-to-service authorization policies

### Event Security
- Event signing for integrity verification
- Source validation of events
- Replay attack protection

### Data Security
- TLS 1.3 for all communications
- Encryption at rest for sensitive data
- Minimization and masking of personal data
- Secure session management

## Deployment

### Environments
- **Development**: Feature branch isolation
- **Staging**: Production-like environment for testing
- **Production**: Live environment with monitoring

### Deployment Strategy
- Blue-green deployment for zero-downtime deployments
- Automated testing before deployment
- Rollback procedures for failed deployments
- Gradual rollout of new features

### Production Checklist

#### Infrastructure
- [x] CI/CD pipeline for all services
- [x] Optimized and scanned Docker images
- [x] Staging environment deployed
- [x] Production environment deployed
- [x] Auto-scaling configured
- [x] SSL/TLS certificates configured
- [x] CDN for static assets (if needed)

#### Testing
- [x] Unit tests > 70% coverage
- [x] Integration tests for all services
- [x] Contract tests Go ↔ Python
- [x] E2E tests for critical user paths
- [x] Load testing performed
- [x] Security testing performed

#### Security
- [x] Secret management (not in git!)
- [x] Rate limiting implemented
- [x] Input validation at all boundaries
- [x] SQL injection prevention
- [x] JWT properly configured
- [x] CORS properly configured
- [x] Security headers added
- [x] Dependencies scanned for vulnerabilities

#### Observability
- [x] Metrics collection (Prometheus)
- [x] Dashboards (Grafana)
- [x] Centralized logging
- [x] Distributed tracing
- [x] Alert rules with runbooks
- [x] Health checks implemented
- [x] Liveness/readiness probes

## API Documentation

### Swagger UI
API documentation is available through Swagger UI when running the server:
1. Start the server: `cd server && go run cmd/server/main.go`
2. Open in browser: `http://localhost:8080/swagger/`

Swagger UI provides an interactive interface for testing API methods, viewing data schemas, and examples of requests/responses.

### Documentation Generation
Swagger documentation is generated automatically from code comments using the `swag` tool:
```bash
# Install swag tool
go install github.com/swaggo/swag/cmd/swag@latest

# Generate documentation
cd server
swag init --parseDependency --parseInternal
```

To add new endpoints to documentation, add appropriate Swagger-formatted comments to handlers:
```go
// @Summary Method description
// @Description Full method description
// @Tags tag-name
// @Accept json
// @Produce json
// @Param param_name body DataType true "Parameter description"
// @Success 200 {object} ResponseDataType
// @Failure 400 {object} ErrorResponseType
// @Router /endpoint [method]
```