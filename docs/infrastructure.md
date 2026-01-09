# Infrastructure for OutfitStyle

## Overview

This document describes the infrastructure setup and deployment strategies for the OutfitStyle platform.

## Architecture

### High-Level Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Flutter App   │    │    Go API       │    │  Python ML      │
│                 │    │                 │    │  Service        │
│  Presentation   │◄──►│  Business Logic │◄──►│                 │
│  Layer          │    │  Layer          │    │  ML Models      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
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

## Environment Setup

### Development Environment
- **Docker Compose**: For local development
- **Hot reloading**: For rapid development
- **Seed data**: For consistent development environment
- **Local databases**: Isolated from other environments

### Staging Environment
- **Production-like setup**: Mirror of production
- **Automated deployment**: From develop branch
- **Test data**: Not production data
- **QA access**: For testing new features

### Production Environment
- **Manual approval**: For deployments
- **Blue-green deployment**: Zero-downtime deployments
- **Auto-scaling**: Based on load
- **Full monitoring**: Complete observability

## Containerization

### Docker Best Practices
```
1. Multi-stage builds (builder → runtime)
2. Minimal base images (alpine, distroless)
3. Non-root user in containers
4. .dockerignore for excluding unnecessary files
5. Specific versions (not :latest)
6. Health checks in Dockerfile
7. Labels for metadata
```

### Docker Compose for Local Development
```
Services:
├── api (Go backend)
├── ml (Python ML service)
├── db (PostgreSQL)
├── redis (cache and rate limiting)
├── nginx (reverse proxy)
├── prometheus (metrics)
├── grafana (dashboards)
└── jaeger (tracing)

Volumes:
├── postgres_data (persist DB)
├── ml_models (persist trained models)
└── grafana_data (persist dashboards)
```

## Kubernetes (Production)

### Minimal Configuration
```
Deployments:
├── api (2-10 replicas, HPA by CPU)
├── ml (2-4 replicas, HPA by CPU)
└── nginx (2 replicas)

StatefulSets:
└── postgresql (1 primary + 1 replica)

Services:
├── api-service (ClusterIP)
├── ml-service (ClusterIP)
└── nginx-service (LoadBalancer)

ConfigMaps:
├── api-config
├── ml-config
└── nginx-config

Secrets:
├── database-credentials
├── jwt-keys
└── api-keys
```

### Important Settings
```
Pod Disruption Budget:
└── minAvailable: 1 (always minimum 1 pod running)

Resource Limits:
├── API: 256Mi-512Mi RAM, 250m-500m CPU
├── ML: 512Mi-1Gi RAM, 500m-1000m CPU
└── PostgreSQL: 1Gi-2Gi RAM

Probes:
├── livenessProbe: /health (restart if fails)
├── readinessProbe: /ready (remove from LB if fails)
└── startupProbe: /health (for slow startup ML)
```

## Deployment Strategies

### Rolling Update (Default)
```
├── Gradual replacement of old pods with new ones
├── maxSurge: 25% (how many extra pods)
├── maxUnavailable: 0 (always full availability)
└── Rollback via: kubectl rollout undo
```

### Blue-Green
```
├── Two identical environments
├── Switch DNS/Load Balancer
├── Instant rollback
└── More expensive (2x resources)
```

### Canary
```
├── 5% traffic to new version
├── Monitor error rate
├── Gradually increase to 100%
└── Rollback on issues
```

## Load Balancing & Reverse Proxy

### NGINX Configuration
- **SSL Termination**: HTTPS to HTTP for internal services
- **Rate Limiting**: Per IP and per user
- **Caching**: Static assets and API responses
- **Compression**: Gzip for responses
- **Security Headers**: HSTS, CSP, etc.

### Health Checks
- **Liveness Probe**: Check if process is alive
- **Readiness Probe**: Check if ready to serve traffic
- **Startup Probe**: For slow-starting services

## Monitoring & Observability

### Infrastructure Monitoring
- **Prometheus**: Metrics collection
- **Grafana**: Visualization and dashboards
- **AlertManager**: Alerting and notification
- **Loki**: Log aggregation
- **Jaeger**: Distributed tracing

### Key Metrics
- **System**: CPU, memory, disk, network
- **Application**: Response time, error rate, throughput
- **Business**: DAU, conversion rates, feature usage
- **Database**: Connections, queries, locks, replication lag

## Security

### Network Security
- **Firewall**: Restrict access to necessary ports
- **VPC/Subnets**: Isolate services
- **VPN**: For administrative access
- **DDoS Protection**: Cloudflare or similar

### Container Security
- **Image scanning**: Vulnerability detection
- **Non-root users**: Run containers as non-root
- **Resource limits**: Prevent resource exhaustion
- **Immutable containers**: Prevent runtime changes

## Backup & Disaster Recovery

### Backup Strategy
- **Database**: Regular dumps with point-in-time recovery
- **Configuration**: Version-controlled infrastructure
- **Certificates**: Automated renewal and backup
- **Application data**: Regular snapshots

### Recovery Plans
- **RTO (Recovery Time Objective)**: Target < 4 hours
- **RPO (Recovery Point Objective)**: Target < 1 hour data loss
- **Failover procedures**: Automated where possible
- **Testing**: Regular disaster recovery drills

## Scaling

### Horizontal Scaling
- **Auto-scaling**: Based on CPU, memory, or custom metrics
- **Load balancing**: Distribute traffic across instances
- **Database read replicas**: Offload read queries
- **Caching**: Reduce database load

### Vertical Scaling
- **Instance sizing**: Choose appropriate instance types
- **Resource allocation**: Optimize CPU and memory
- **Storage**: Use SSDs for better performance
- **Network**: Higher bandwidth for data transfer

## Cost Optimization

### Resource Management
- **Right-sizing**: Match resources to actual usage
- **Reserved instances**: Commit to longer-term usage
- **Spot instances**: For non-critical workloads
- **Auto-scaling**: Scale down during low usage

### Monitoring Costs
- **Cost tracking**: Monitor spending by service
- **Resource tagging**: Track costs by team/project
- **Optimization alerts**: Notify of cost anomalies
- **Regular reviews**: Optimize based on usage patterns

## Documentation & Runbooks

### Infrastructure Documentation
- **Architecture diagrams**: Current state and changes
- **Runbooks**: Step-by-step operational procedures
- **Incident response**: Playbooks for common issues
- **Change management**: Process for infrastructure changes

### Operational Procedures
- **Deployment procedures**: Step-by-step deployment guides
- **Monitoring procedures**: How to interpret metrics
- **Troubleshooting**: Common issues and solutions
- **Security procedures**: Incident response and forensics