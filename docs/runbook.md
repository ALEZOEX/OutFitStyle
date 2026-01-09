# OutfitStyle Operations Runbook

## Overview

This runbook provides operational procedures for maintaining and troubleshooting the OutfitStyle platform.

## Contact Information

- **On-Call Engineer**: [Slack channel or phone number]
- **Support Team**: [Email address]
- **Emergency Contact**: [Phone number]

## Monitoring and Alerting

### Key Metrics to Monitor

#### System Health
- **API Response Time**: p95 < 200ms, p99 < 500ms
- **Error Rate**: < 1% for all endpoints
- **Availability**: > 99.9%
- **Database Connections**: < 80% of max connections
- **Disk Usage**: < 80% on all systems

#### Business Metrics
- **Recommendations Generated**: Baseline varies by season/day
- **Recommendation Acceptance Rate**: Target > 60%
- **Daily Active Users**: Baseline varies by season/day
- **App Crashes**: < 0.1%

### Alert Categories

#### Critical (Immediate Response Required)
- Service completely unavailable
- Database connection failures
- High error rates (> 10% for 5+ minutes)
- Security incidents
- Data loss

#### Warning (Address Within 1 Hour)
- Degraded performance
- Moderate error rates (1-10%)
- Resource utilization > 80%
- Failed background jobs

#### Info (Monitor and Investigate)
- Minor performance degradation
- Low error rates (< 1%)
- Resource utilization 60-80%

## Common Incidents and Solutions

### Incident: API Service Unavailable

**Symptoms**:
- All API requests return 5xx errors
- Health check fails
- Users cannot access the app

**Investigation Steps**:
1. Check health endpoint: `curl -v https://api.outfitstyle.app/health`
2. Check logs: `kubectl logs -l app=api --tail=100`
3. Check database connectivity: `kubectl exec -it <api-pod> -- psql <connection-string>`
4. Check resource usage: `kubectl top pods`

**Resolution Steps**:
1. If database issue: Check PostgreSQL status and restart if needed
2. If resource issue: Scale up deployment or increase resources
3. If code issue: Rollback to previous version
4. If network issue: Check load balancer and networking

### Incident: High Error Rate

**Symptoms**:
- Error rate > 5% for 5+ minutes
- Specific endpoints failing
- Users reporting issues

**Investigation Steps**:
1. Check Grafana dashboard for error patterns
2. Filter logs by error status codes
3. Identify affected endpoints/users
4. Check external service dependencies

**Resolution Steps**:
1. If external API issue: Implement circuit breaker or fallback
2. If database issue: Optimize queries or add indices
3. If code bug: Deploy hotfix or rollback
4. If rate limiting: Adjust limits or investigate abuse

### Incident: Slow Response Times

**Symptoms**:
- API response times > 1s consistently
- Users experiencing delays
- High p95/p99 latency

**Investigation Steps**:
1. Check Grafana latency dashboards
2. Identify slow endpoints
3. Check database query performance
4. Check external service response times

**Resolution Steps**:
1. Add database indices
2. Implement caching
3. Optimize slow queries
4. Scale services horizontally
5. Add CDN for static assets

### Incident: ML Service Unavailable

**Symptoms**:
- Recommendation generation fails
- ML service health check fails
- Users cannot get new recommendations

**Investigation Steps**:
1. Check ML service logs
2. Check model loading status
3. Check resource usage (memory/CPU)
4. Check model file integrity

**Resolution Steps**:
1. Restart ML service
2. Reload model if corrupted
3. Scale ML service if resource constrained
4. Rollback to previous model version if needed

## Maintenance Procedures

### Database Maintenance

#### Backup Verification (Weekly)
1. Download latest backup from storage
2. Restore to temporary database
3. Verify data integrity
4. Document results

#### Index Optimization (Monthly)
1. Run `EXPLAIN ANALYZE` on slow queries
2. Identify missing indices
3. Create new indices during maintenance window
4. Monitor performance improvement

### Security Maintenance

#### Certificate Renewal (Quarterly)
1. Check certificate expiration dates
2. Renew certificates before expiration
3. Update all services with new certificates
4. Test all HTTPS endpoints

#### Dependency Updates (Monthly)
1. Run security scans on all services
2. Update vulnerable dependencies
3. Test updates in staging environment
4. Deploy to production

## Deployment Procedures

### Standard Deployment

1. **Pre-deployment Checks**:
   - All tests passing in CI
   - Staging environment stable
   - No active incidents

2. **Deployment**:
   - Deploy to staging first
   - Manual testing on staging
   - Deploy to production using blue-green strategy
   - Monitor key metrics

3. **Post-deployment**:
   - Verify health checks pass
   - Monitor error rates and latency
   - Update documentation if needed

### Emergency Rollback

1. **Identify Issue**: Determine if rollback is needed
2. **Prepare Rollback**: Have previous version ready
3. **Execute Rollback**: Deploy previous version
4. **Verify**: Check health and metrics
5. **Communicate**: Inform team and stakeholders

## Troubleshooting Commands

### Kubernetes Commands
```bash
# Check pod status
kubectl get pods -n outfitstyle

# Check logs
kubectl logs -n outfitstyle <pod-name>

# Check resource usage
kubectl top pods -n outfitstyle

# Describe pod for detailed info
kubectl describe pod -n outfitstyle <pod-name>
```

### Database Commands
```bash
# Check database connections
SELECT count(*) FROM pg_stat_activity;

# Check slow queries
SELECT * FROM pg_stat_statements ORDER BY mean_time DESC LIMIT 10;

# Check table sizes
SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) 
FROM pg_tables 
WHERE schemaname = 'public';
```

### Monitoring Commands
```bash
# Check service status
curl -s https://api.outfitstyle.app/health | jq

# Check metrics endpoint
curl -s https://api.outfitstyle.app/metrics | grep http_requests_total
```

## Escalation Procedures

### Level 1: On-Call Engineer
- Initial incident response
- Basic troubleshooting
- Communication with users

### Level 2: Senior Engineer
- Complex technical issues
- Architecture decisions
- Coordination with other teams

### Level 3: Engineering Manager
- Critical incidents
- Customer communication
- Executive updates

## Useful Resources

- **Grafana Dashboard**: https://monitoring.outfitstyle.app
- **GitHub Repository**: https://github.com/your-org/outfitstyle
- **Slack Channel**: #outfitstyle-ops
- **Documentation**: https://docs.outfitstyle.app
- **Incident Report Template**: [Link to template]

## Revision History

- **v1.0** - Initial runbook (January 2024)
- **v1.1** - Added ML service procedures (February 2024)