# Database Management for OutfitStyle

## Overview

This document describes the database management and optimization strategies for the OutfitStyle platform.

## Database Schema

### Core Tables

#### Users Table
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    google_id VARCHAR(255) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### User Preferences Table
```sql
CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    preferred_styles TEXT[],
    avoid_styles TEXT[],
    color_preferences TEXT[],
    avoid_colors TEXT[],
    preferred_categories TEXT[],
    temperature_sensitivity INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id)
);
```

#### Wardrobe Items Table
```sql
CREATE TABLE wardrobe_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    color VARCHAR(50) NOT NULL,
    warmth_level INTEGER NOT NULL CHECK (warmth_level >= 0 AND warmth_level <= 5),
    style VARCHAR(50),
    formality_level INTEGER DEFAULT 2 CHECK (formality_level >= 1 AND formality_level <= 5),
    image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Recommendations Table
```sql
CREATE TABLE recommendations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    items JSONB NOT NULL, -- Array of wardrobe item IDs
    score DECIMAL(3,2) NOT NULL,
    reason TEXT,
    occasion VARCHAR(50),
    weather_condition VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

#### Recommendation Feedback Table
```sql
CREATE TABLE recommendation_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    recommendation_id UUID REFERENCES recommendations(id) ON DELETE CASCADE,
    liked BOOLEAN NOT NULL,
    feedback_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, recommendation_id)
);
```

## Migration Strategy

### Migration Rules
```
┌─────────────────────────────────────────────────────────────────────┐
│                      MIGRATION RULES                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  1. Each migration — separate file with timestamp                 │
│     └── 20240115_120000_add_user_preferences.sql                   │
│                                                                     │
│  2. Migrations are idempotent (can be applied repeatedly)          │
│     └── CREATE TABLE IF NOT EXISTS                                 │
│                                                                     │
│  3. Always have down migration (rollback)                          │
│                                                                     │
│  4. Never delete/modify applied migrations                         │
│     └── Only new migrations for changes                            │
│                                                                     │
│  5. Test migrations on copy of production data                    │
│                                                                     │
│  6. Backward compatible changes:                                   │
│     ├── Adding nullable columns — OK                               │
│     ├── Removing columns — stop using first                        │
│     └── Renaming — via alias, then removal                         │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

### Migration Tools
- **Go**: `golang-migrate`, `goose`, `atlas`
- **Automatic execution**: On app startup (optional)
- **Lock mechanism**: Only one instance applies migrations

## Backup Strategy

### 3-2-1 Rule
- **3** copies of data
- **2** different types of storage
- **1** offsite (different region/cloud)

### Schedule
```
├── Full backup: daily at 3:00 UTC
├── Incremental: every 6 hours
├── Transaction logs: continuously (Point-in-Time Recovery)
└── Retention:
    ├── Daily: 7 days
    ├── Weekly: 4 weeks
    └── Monthly: 12 months
```

### Automation
```
1. pg_dump with compression → S3/GCS
2. Encryption of backup (GPG or cloud KMS)
3. Integrity check after upload
4. Alert if backup fails
5. Regular restoration testing (monthly)
```

## Performance Optimization

### Indexes
```sql
-- Frequent queries by user_id
CREATE INDEX idx_wardrobe_items_user_id ON wardrobe_items(user_id);
CREATE INDEX idx_recommendations_user_id ON recommendations(user_id);

-- Sorting by date
CREATE INDEX idx_recommendations_created_at ON recommendations(user_id, created_at DESC);

-- Filtering by category
CREATE INDEX idx_wardrobe_items_category ON wardrobe_items(user_id, category);

-- Full-text search (if needed)
CREATE INDEX idx_wardrobe_items_search ON wardrobe_items USING gin(to_tsvector('english', name));
```

### Connection Pooling
- **PgBouncer**: In front of PostgreSQL
- **Mode**: Transaction pooling
- **Max connections**: CPU cores * 2-4
- **Go**: Configure `MaxOpenConns`, `MaxIdleConns`, `ConnMaxLifetime`

### Query Optimization
```
Checklist for each query:
□ EXPLAIN ANALYZE shows Index Scan (not Seq Scan)
□ No N+1 problems (use JOIN or batch loading)
□ LIMIT on all list queries
□ Pagination via cursor, not OFFSET
□ Heavy queries in background jobs, not API handlers
```

## Monitoring & Maintenance

### Key Metrics
- **Connections**: Current vs max connections
- **Locks**: Blocking queries
- **Replication lag**: If using replicas
- **Disk space**: Available storage
- **Slow queries**: Queries > 100ms

### Maintenance Tasks
- **Index optimization**: Monthly review
- **Vacuum and analyze**: Regular maintenance
- **Statistics updates**: For query planner
- **Dead tuple cleanup**: Prevent bloat

### Alerting
- **Disk space**: < 20% free
- **Connection exhaustion**: > 90% of max
- **Slow queries**: > 1s consistently
- **Replication lag**: > 30s (if applicable)

## Security

### Access Control
- **Role-based access**: Different permissions for different services
- **Least privilege**: Minimal required permissions
- **Network security**: Restrict access to database subnet only
- **Encryption**: SSL/TLS for connections

### Data Protection
- **Encryption at rest**: Transparent data encryption
- **Column-level encryption**: For sensitive data
- **Audit logging**: Track all database access
- **PII protection**: Masking and anonymization

## Scaling Strategies

### Vertical Scaling
- **CPU/Memory**: Increase instance size
- **Storage**: Faster disks (SSD)
- **Network**: Higher bandwidth

### Horizontal Scaling
- **Read replicas**: Offload read queries
- **Partitioning**: Split large tables
- **Sharding**: Distribute data across instances
- **Caching**: Reduce database load

## Disaster Recovery

### Recovery Time Objective (RTO)
- **Target**: < 4 hours for full recovery
- **Process**: Automated restore from backups
- **Testing**: Quarterly disaster recovery drills

### Recovery Point Objective (RPO)
- **Target**: < 1 hour of data loss
- **Strategy**: Continuous backup and WAL shipping
- **Verification**: Regular backup integrity checks

## Best Practices

### Development
- **Local development**: Use Docker for consistent environment
- **Seed data**: For development and testing
- **Migration testing**: On copy of production data
- **Performance testing**: Before applying to production

### Production
- **Monitoring**: 24/7 database health monitoring
- **Alerting**: Immediate notification of issues
- **Documentation**: All schema changes documented
- **Rollback plans**: For every migration