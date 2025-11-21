# Quick Start Guide - Phase 1

## TL;DR

```bash
make up      # Start everything
make status  # Check health
make query   # See metrics
```

Open http://localhost:3000 (admin/admin) to view Grafana dashboard.

---

## Essential Commands

### Starting & Stopping

| Command | Description |
|---------|-------------|
| `make up` | Start all services |
| `make down` | Stop all services |
| `make restart` | Restart all services |
| `make status` | Check service health |

### Monitoring & Debugging

| Command | Description |
|---------|-------------|
| `make ps` | Show running containers |
| `make logs` | Follow all logs |
| `make logs-app` | Follow Go app logs only |
| `make logs-vm` | Follow VictoriaMetrics logs only |
| `make logs-grafana` | Follow Grafana logs only |

### Testing & Queries

| Command | Description |
|---------|-------------|
| `make metrics` | View raw Prometheus metrics |
| `make query` | Run sample PromQL queries |
| `make targets` | Show scrape target status |
| `make load-test` | Generate continuous traffic (Ctrl+C to stop) |

### Cleanup

| Command | Description |
|---------|-------------|
| `make clean` | Stop and remove containers |
| `make clean-all` | Stop, remove containers AND delete all data |

---

## Understanding the Metrics

### 1. Counter: `http_requests_total`
Tracks cumulative number of HTTP requests.

**Sample Query:**
```bash
curl 'http://localhost:8428/api/v1/query?query=http_requests_total'
```

**What to look for:**
- Total requests per endpoint
- Success vs error ratio (status label)
- Always increasing number

### 2. Gauge: `sensor_temperature_celsius`
Shows current temperature value (simulated sensor).

**Sample Query:**
```bash
curl 'http://localhost:8428/api/v1/query?query=sensor_temperature_celsius'
```

**What to look for:**
- Current value (fluctuates between 18-28°C)
- Can go up or down

### 3. Histogram: `http_request_duration_seconds`
Measures distribution of request latencies.

**Sample Query:**
```bash
curl 'http://localhost:8428/api/v1/query?query=rate(http_request_duration_seconds_sum[1m])/rate(http_request_duration_seconds_count[1m])'
```

**What to look for:**
- Average duration
- Percentiles (p50, p95, p99)
- Request distribution across buckets

---

## Access Points

| Service | URL | Credentials |
|---------|-----|-------------|
| **Grafana** | http://localhost:3000 | admin / admin |
| **VictoriaMetrics** | http://localhost:8428 | None |
| **Go App Metrics** | http://localhost:8080/metrics | None |
| **Go App Health** | http://localhost:8080/ | None |

---

## Typical Workflow

### First Time Setup
```bash
# 1. Start the stack
make up

# 2. Check everything is healthy
make status

# 3. Generate some traffic
make load-test
# (Let it run for 30 seconds, then Ctrl+C)

# 4. Check the metrics
make query

# 5. Open Grafana and explore the dashboard
# http://localhost:3000 → Dashboards → Phase 1 - Metrics Demo
```

### Daily Use
```bash
# Start
make up

# Do your experiments...

# Stop
make down
```

### Troubleshooting
```bash
# Check what's running
make ps

# Check health
make status

# View logs
make logs

# Restart everything
make restart

# Nuclear option: clean everything and start fresh
make clean-all
make up
```

---

## Understanding the Dashboard

When you open Grafana (http://localhost:3000), navigate to:
**Dashboards → Phase 1 - Metrics Demo**

### Panel 1: HTTP Request Rate
- **Type:** Time series graph
- **Shows:** Requests per second
- **Query:** `rate(http_requests_total[1m])`
- **Learn:** How to calculate rates from counters

### Panel 2: Current Temperature
- **Type:** Gauge
- **Shows:** Current temperature value with color thresholds
- **Query:** `sensor_temperature_celsius`
- **Learn:** Displaying current values with visual alerts

### Panel 3: Average Request Duration
- **Type:** Time series graph
- **Shows:** Average latency over time
- **Query:** `rate(http_request_duration_seconds_sum[1m]) / rate(http_request_duration_seconds_count[1m])`
- **Learn:** Calculating averages from histogram metrics

### Panel 4: Request Status Distribution
- **Type:** Pie chart
- **Shows:** Proportion of successful vs failed requests
- **Query:** `sum by(status) (increase(http_requests_total{endpoint="/api/data"}[5m]))`
- **Learn:** Aggregating data and grouping by labels

### Panel 5: Request Duration Percentiles
- **Type:** Time series graph
- **Shows:** p50, p95, p99 latencies
- **Query:** `histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[1m])) by (le, endpoint))`
- **Learn:** Using histograms to calculate percentiles

---

## Next Steps

Once you're comfortable with Phase 1:

1. **Experiment:**
   - Modify `main.go` to add your own metrics
   - Create new Grafana panels
   - Write custom PromQL queries

2. **Learn More:**
   - Read `PHASE1.md` for detailed explanations
   - Check VictoriaMetrics docs: https://docs.victoriametrics.com/
   - Explore PromQL: https://prometheus.io/docs/prometheus/latest/querying/basics/

3. **Move to Phase 2:**
   - Add NATS for real-time message streaming
   - Decouple data producers and consumers
   - Build event-driven architectures

---

## Common Issues

### "Services won't start"
```bash
# Check if ports are already in use
sudo lsof -i :8080,8428,3000

# View detailed logs
make logs
```

### "No metrics showing in Grafana"
```bash
# Check scrape targets are healthy
make targets

# Generate some traffic
make load-test

# Wait 15-30 seconds for data to appear
```

### "Permission denied" errors with Podman
```bash
# Fix Grafana provisioning permissions
chmod -R 755 grafana/provisioning

# Restart Grafana
make restart
```

### "Can't connect to services"
```bash
# Verify all services are up
make status

# If any are down, check logs
make logs-[service-name]
```

---

## Tips & Tricks

**Generate realistic traffic patterns:**
```bash
# In one terminal
make load-test

# Let it run while you explore Grafana
```

**Quick metric check:**
```bash
# See all custom metrics
curl -s http://localhost:8080/metrics | grep -E '^(http_|sensor_)'
```

**Query VictoriaMetrics directly:**
```bash
# List all available metrics
curl -s http://localhost:8428/api/v1/label/__name__/values

# Query any metric
curl -s 'http://localhost:8428/api/v1/query?query=YOUR_METRIC_NAME'
```

**Clean slate for testing:**
```bash
make clean-all  # Removes all data
make up         # Fresh start
```

---

## Getting Help

- `make help` - Show all available commands
- `make docs` - Show documentation links
- Check `PHASE1.md` for detailed explanations
- View logs: `make logs`
