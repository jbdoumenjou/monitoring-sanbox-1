# Phase 1 Cheat Sheet

## Quick Commands

```bash
make help       # Show all commands
make up         # Start everything
make status     # Check health
make query      # View metrics
make targets    # Show scrape targets
make load-test  # Generate traffic
make down       # Stop everything
```

## PromQL Query Examples

### Counters
```promql
# Total requests
http_requests_total

# Requests to specific endpoint
http_requests_total{endpoint="/api/data"}

# Only errors
http_requests_total{status="500"}

# Rate (per second)
rate(http_requests_total[1m])

# Total increase over 5 minutes
increase(http_requests_total[5m])
```

### Gauges
```promql
# Current value
sensor_temperature_celsius

# Average over time
avg_over_time(sensor_temperature_celsius[5m])

# Max over time
max_over_time(sensor_temperature_celsius[10m])

# Min over time
min_over_time(sensor_temperature_celsius[10m])
```

### Histograms
```promql
# Average duration
rate(http_request_duration_seconds_sum[1m]) /
rate(http_request_duration_seconds_count[1m])

# p50 (median)
histogram_quantile(0.50,
  rate(http_request_duration_seconds_bucket[1m]))

# p95
histogram_quantile(0.95,
  rate(http_request_duration_seconds_bucket[1m]))

# p99
histogram_quantile(0.99,
  rate(http_request_duration_seconds_bucket[1m]))

# Total requests (from histogram)
rate(http_request_duration_seconds_count[1m])
```

## Aggregation Functions

```promql
# Sum across all labels
sum(http_requests_total)

# Sum grouped by status
sum by(status) (http_requests_total)

# Average grouped by endpoint
avg by(endpoint) (http_request_duration_seconds_sum)

# Max temperature
max(sensor_temperature_celsius)

# Count number of series
count(http_requests_total)
```

## curl Commands

### Query Metrics
```bash
# Query current value
curl -s 'http://localhost:8428/api/v1/query?query=METRIC_NAME'

# Query with time range
curl -s 'http://localhost:8428/api/v1/query_range?query=METRIC_NAME&start=2024-01-01T00:00:00Z&end=2024-01-01T01:00:00Z&step=15s'

# List all metrics
curl -s http://localhost:8428/api/v1/label/__name__/values

# List all label values
curl -s http://localhost:8428/api/v1/label/LABEL_NAME/values
```

### Check Status
```bash
# Scrape targets
curl -s http://localhost:8428/api/v1/targets

# VictoriaMetrics health
curl -s http://localhost:8428/health

# Grafana health
curl -s http://localhost:3000/api/health

# Raw Prometheus metrics
curl -s http://localhost:8080/metrics
```

## Grafana Tips

### Creating Panels
1. Click "Add" → "Visualization"
2. Select data source: VictoriaMetrics
3. Enter PromQL query
4. Choose visualization type
5. Configure display options
6. Save panel

### Useful Panel Settings
- **Time range:** Top right corner
- **Refresh rate:** Auto-refresh dropdown
- **Variables:** Dashboard settings → Variables
- **Threshold:** Panel edit → Thresholds

### Common Visualizations
- **Time series:** Line/area graphs for trends
- **Gauge:** Single current value with thresholds
- **Stat:** Large number display
- **Pie chart:** Distribution/proportions
- **Table:** Raw data display

## File Locations

```
docker-compose.yml              # Service definitions
Makefile                        # All commands
main.go                         # Go app with metrics

victoriametrics/
  scrape.yml                    # What to scrape & how often

grafana/provisioning/
  datasources/
    victoriametrics.yml         # VictoriaMetrics connection
  dashboards/
    default.yml                 # Dashboard provider config
    metrics-demo.json           # Pre-built dashboard
```

## Metric Types Explained

### Counter
- **What:** Cumulative count (only increases)
- **Examples:** Requests, errors, bytes sent
- **Usage:** Use `rate()` or `increase()`
- **In Code:** `prometheus.NewCounter()`

### Gauge
- **What:** Current value (can go up/down)
- **Examples:** Temperature, memory usage, queue size
- **Usage:** Use directly or with `avg_over_time()`
- **In Code:** `prometheus.NewGauge()`

### Histogram
- **What:** Distribution of values in buckets
- **Examples:** Latency, response size, duration
- **Usage:** Use `histogram_quantile()` for percentiles
- **In Code:** `prometheus.NewHistogram()`

## Common Patterns

### Error Rate
```promql
# Percentage of errors
sum(rate(http_requests_total{status="500"}[5m])) /
sum(rate(http_requests_total[5m])) * 100
```

### Saturation
```promql
# Requests per second
sum(rate(http_requests_total[1m]))
```

### Latency (SLI)
```promql
# 95th percentile under 100ms
histogram_quantile(0.95,
  rate(http_request_duration_seconds_bucket[5m])) < 0.1
```

### Availability
```promql
# Success rate
sum(rate(http_requests_total{status="200"}[5m])) /
sum(rate(http_requests_total[5m])) * 100
```

## Troubleshooting

### No Data in Grafana
```bash
# 1. Check targets are up
make targets

# 2. Generate traffic
make load-test

# 3. Wait 15-30 seconds

# 4. Check time range in Grafana (top right)
```

### Container Won't Start
```bash
# Check logs
make logs

# Check ports
sudo lsof -i :8080,8428,3000

# Restart
make restart
```

### Permission Errors (Podman)
```bash
chmod -R 755 grafana/provisioning
make restart
```

## Learning Resources

- **Prometheus Docs:** https://prometheus.io/docs/
- **VictoriaMetrics:** https://docs.victoriametrics.com/
- **Grafana Docs:** https://grafana.com/docs/
- **PromQL Tutorial:** https://prometheus.io/docs/prometheus/latest/querying/basics/

## Keyboard Shortcuts

### Grafana
- `g + h` - Go to home
- `g + e` - Explore
- `d` - Toggle dark mode
- `?` - Show help
- `Ctrl/Cmd + S` - Save dashboard
- `Ctrl/Cmd + K` - Search

### Make
- `Ctrl + C` - Stop load-test
- `Tab` - Auto-complete make targets
