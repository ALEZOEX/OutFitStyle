# CI/CD Pipeline for OutfitStyle

## Overview

The OutfitStyle project uses GitHub Actions for continuous integration and deployment across all services.

## Pipeline Structure

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CI/CD STAGES                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌─────────┐   ┌───────┐ │
│  │  Lint   │ → │  Test   │ → │  Build  │ → │  Push   │ → │Deploy │ │
│  └─────────┘   └─────────┘   └─────────┘   └─────────┘   └───────┘ │
│       ↓             ↓             ↓             ↓            ↓      │
│  - Go: golangci   - Unit      - Docker     - GHCR       - Staging  │
│  - Python: ruff   - Integration- Binary    - DockerHub  - Prod     │
│  - Flutter:       - Contract   - APK/IPA                           │
│    analyze        - E2E                                             │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Service Pipelines

### Go Backend Pipeline

#### Linting
- Uses `golangci-lint` (meta-linter with 50+ checks)
- Includes: `errcheck`, `gosec`, `govet`, `staticcheck`, `unused`
- Configured in `.golangci.yml`

#### Testing
- Runs with `-race` (race detector) and `-cover` (coverage)
- PostgreSQL in Docker for integration tests
- Uses build tags to separate unit/integration tests
- Minimum 70% coverage for business logic

#### Building
- Builds with `CGO_ENABLED=0` for static linking
- Adds version and commit hash via `-ldflags`
- Uses multi-stage Docker build for minimal image

#### Security Scanning
- `gosec` for code vulnerability scanning
- `trivy` for Docker image CVE scanning
- `govulncheck` for dependency vulnerability checking

### Python ML Service Pipeline

#### Linting & Typing
- `ruff` for fast linting (replaces flake8, isort, etc.)
- `mypy` for static type checking
- `black` for code formatting
- Configured in `pyproject.toml`

#### Testing
- `pytest` with plugins: `pytest-asyncio`, `pytest-cov`, `pytest-mock`
- Fixtures for ML model test data
- Performance tests for ML inference

#### Dependencies
- Uses `pip-compile` or `poetry` for lock files
- Separates `requirements.txt` and `requirements-dev.txt`
- Scans dependencies with `safety` or `pip-audit`

### Flutter Pipeline

#### Code Analysis
- `flutter analyze` with `--fatal-infos` (any warning = error)
- Configured in `analysis_options.yaml`
- Includes: `avoid_print`, `prefer_const_constructors`, etc.

#### Testing
- Unit tests for providers/controllers
- Widget tests for UI components
- Integration tests for full scenarios
- Golden tests for visual regression

#### Building
- Different flavors: dev, staging, production
- Different bundle IDs per environment
- Signing through GitHub Secrets

## Git Flow Strategy

```
┌─────────────────────────────────────────────────────────────────────┐
│                      GIT FLOW STRATEGY                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  Feature Branch    →    PR to develop    →    Tests + Review        │
│        ↓                                                            │
│  develop           →    Nightly builds   →    Auto-deploy Staging   │
│        ↓                                                            │
│  release/x.x.x     →    RC testing       →    Manual QA             │
│        ↓                                                            │
│  main              →    Tag + Release    →    Auto-deploy Prod      │
│                                                                     │
├─────────────────────────────────────────────────────────────────────┤
│  TRIGGERS:                                                          │
│  • PR opened/updated → Run all tests                                │
│  • Push to develop → Build + Deploy Staging                         │
│  • Push to main → Build + Deploy Production                         │
│  • Tag v*.*.* → Create GitHub Release + Store Upload                │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Deployment Strategy

### Environments
- **Development**: Feature branches, auto-deploy on push
- **Staging**: Develop branch, nightly builds
- **Production**: Main branch, manual approval required

### Deployment Types
- **Blue-Green**: Full environment swap for zero downtime
- **Canary**: Gradual rollout to subset of users
- **Rolling**: Gradual replacement of instances

## Security in CI/CD

### Secrets Management
- GitHub Secrets for all sensitive data
- Encrypted environment variables
- No hardcoded credentials in code
- Regular rotation of deployment tokens

### Security Scanning
- Static code analysis on every PR
- Dependency vulnerability scanning
- Container image security scanning
- Infrastructure as code validation

## Monitoring & Alerting

### Pipeline Monitoring
- GitHub Actions workflow status
- Build time tracking
- Deployment success/failure rates
- Test coverage trends

### Alerting
- Failed builds/deployments
- Significant performance regressions
- Security scan failures
- Test coverage drops below threshold