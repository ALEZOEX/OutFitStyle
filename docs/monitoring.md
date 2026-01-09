# Monitoring and Observability for OutfitStyle

## Overview

This document describes the monitoring and observability setup for the OutfitStyle platform.

## Three Pillars of Observability

```
┌─────────────────────────────────────────────────────────────────────┐
│                     OBSERVABILITY PILLARS                           │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐             │
│  │   METRICS   │    │    LOGS     │    │   TRACES    │             │
│  ├─────────────┤    ├─────────────┤    ├─────────────┤             │
│  │ Prometheus  │    │ Loki / ELK  │    │   Jaeger    │             │
│  │ + Grafana   │    │             │    │   Tempo     │             │
│  ├─────────────┤    ├─────────────┤    ├─────────────┤             │
│  │ WHAT:       │    │ WHAT:       │    │ WHAT:       │             │
│  │ - RPS       │    │ - Errors    │    │ - Latency   │             │
│  │ - Latency   │    │ - Events    │    │ - Flow      │             │
│  │ - Errors %  │    │ - Debug     │    │ - Deps      │             │
│  └─────────────┘    └─────────────┘    └─────────────┘             │
│         │                  │                  │                     │
│         └──────────────────┼──────────────────┘                     │
│                            ▼                                        │
│                    ┌─────────────┐                                  │
│                    │  ALERTING   │                                  │
│                    │ PagerDuty / │                                  │
│                    │ Telegram    │                                  │
│                    └─────────────┘                                  │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Metrics Collection

### RED Metrics (for each service):
- **R**ate — number of requests per second
- **E**rrors — percentage of errors
- **D**uration — time to process requests (p50, p90, p99)

### USE Metrics (for infrastructure):
- **U**tilization — CPU, Memory, Disk usage
- **S**aturation — queues, pending connections
- **E**rrors — system errors

### Business Metrics:
```
OutfitStyle specific:
├── recommendations_generated_total — number of recommendations generated
├── recommendations_accepted_total — number of swipes right
├── recommendations_rejected_total — number of swipes left
├── wardrobe_items_added_total — items added
├── active_users_daily — DAU
├── ml_inference_duration_seconds — ML model execution time
└── weather_api_calls_total — external API calls
```

## Logging Strategy

### Log Levels:
```
ERROR — Error requiring attention
 ├── Failed to save to database
 ├── External API returned 500
 └── Authentication failed (for security audit)

WARN — Potential problems
 ├── Slow query (>1s)
 ├── Retry attempt
 └── Deprecated API usage

INFO — Significant events
 ├── Request completed (with latency)
 ├── User signed in
 └── Background job finished

DEBUG — Details for debugging (dev/staging only)
 ├── SQL queries
 ├── Request/response bodies
 └── Cache hits/misses
```

### Structured Logging (JSON):
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "INFO",
  "message": "Request completed",
  "request_id": "abc-123",
  "user_id": "user-456",
  "method": "POST",
  "path": "/api/recommendations",
  "status": 200,
  "latency_ms": 150,
  "service": "api"
}
```

## Distributed Tracing

### Purpose:
Request flows: Flutter → Nginx → Go API → Python ML → PostgreSQL
Need to understand where bottlenecks occur.

### How it works:
1. Each request gets a unique Trace ID
2. Each span (operation) has a Span ID
3. Spans are linked via parent-child relationships
4. Context is passed between services via headers

### What to trace:
```
Required:
├── HTTP handlers (automatically via middleware)
├── Database queries
├── External API calls
├── Message queue operations
└── ML inference

Optional:
├── Cache operations
├── File I/O
└── CPU-intensive computations
```

## Alerting Rules

### Critical (PagerDuty/phone call):
```
├── Service unavailable > 1 min
├── Error rate > 10% for 5 min
├── Latency p99 > 5s for 5 min
├── Database connection pool exhausted
└── Disk usage > 90%
```

### Important (Telegram/email):
```
├── Error rate > 5% for 15 min
├── Latency p99 > 2s for 15 min
├── Memory usage > 80%
├── Certificate expires in < 7 days
└── Failed deployments
```

### Informational (dashboard only):
```
├── Daily active users dropped > 20%
├── Recommendation acceptance rate dropped
└── Background jobs taking longer than usual
```

## Dashboards

### Required dashboards:
1. **Overview** — health of entire system on one screen
2. **API Performance** — RPS, latency, errors by endpoints
3. **Infrastructure** — CPU, memory, disk, network
4. **Business Metrics** — DAU, recommendations, conversions
5. **ML Service** — inference time, model accuracy metrics

## Monitoring Setup

### Prometheus Configuration:
- Scrapes metrics from all services every 15s
- Stores metrics for 15 days
- Configured via prometheus.yml
- Alerts defined in rules.yml

### Grafana Configuration:
- Multiple dashboards for different purposes
- Alerting rules linked to notification channels
- User access controls for different roles
- Dashboard sharing and collaboration

### Log Aggregation:
- Loki for structured logs
- Centralized storage and querying
- Log retention policies
- Integration with alerting

## Health Checks

### Liveness Probe:
- Checks if process is alive
- If failure — pod is restarted
- Endpoint: `GET /health` → 200 OK

### Readiness Probe:
- Checks if ready to serve traffic
- If failure — removed from load balancer
- Checks: DB connection, ML model loaded

```go
// /ready endpoint
{
  "status": "ready",
  "checks": {
    "database": "ok",
    "ml_service": "ok",
    "redis": "ok"
  }
}
```

## Performance Monitoring

### Baseline Metrics:
- API response time: p95 < 200ms, p99 < 500ms
- Error rate: < 1% for all endpoints
- Availability: > 99.9%
- Database connections: < 80% of max connections
- Disk usage: < 80% on all systems

### Performance Testing:
- Load testing with realistic user scenarios
- Stress testing to identify breaking points
- Soak testing for long-term stability
- Spike testing for sudden traffic increases