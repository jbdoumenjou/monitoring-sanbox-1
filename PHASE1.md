# Phase 1: Foundation - Simple Metrics

This phase introduces the basics of metrics collection, storage, and visualization.

## What We Built

### 1. Go Application (`main.go`)
A simple web server that exposes three types of Prometheus metrics:

**Counter** - `http_requests_total`
- Tracks total number of HTTP requests
- Labels: endpoint, method, status
- Use case: Counting events that only increase (requests, errors, messages)

**Gauge** - `sensor_temperature_celsius`
- Simulates a temperature sensor
- Value fluctuates between 18°C and 28°C
- Use case: Current values that can go up or down (temperature, memory usage, queue size)

**Histogram** - `http_request_duration_seconds`
- Measures request duration distribution
- Labels: endpoint
- Use case: Measuring distributions (latency, response size, query duration)

### 2. VictoriaMetrics
- Time-series database compatible with Prometheus
- Scrapes metrics from the Go app every 15 seconds
- Stores data for 12 months
- Exposed on port 8428

### 3. Grafana
- Visualization platform
- Pre-configured with VictoriaMetrics datasource
- Includes a demo dashboard showing all metric types
- Exposed on port 3000

## Architecture

```
┌─────────────────┐         ┌──────────────────┐         ┌─────────────┐
│   Go App        │         │  VictoriaMetrics │         │   Grafana   │
│                 │         │                  │         │             │
│  :8080/metrics ◄─────────┤  Scrapes every   ├────────►│  Visualizes │
│                 │         │  15 seconds      │         │  Dashboards │
└─────────────────┘         └──────────────────┘         └─────────────┘
```

## Getting Started

### 1. Start the Stack

```bash
docker-compose up -d
```

This will start all three services. Wait about 30 seconds for everything to initialize.

### 2. Verify Services

```bash
# Check all services are running
docker-compose ps

# Check Go app metrics endpoint
curl http://localhost:8080/metrics

# Check VictoriaMetrics is scraping
curl http://localhost:8428/api/v1/targets
```

### 3. Access Grafana

1. Open browser to http://localhost:3000
2. Login with:
   - Username: `admin`
   - Password: `admin`
3. Navigate to "Dashboards" → "Phase 1 - Metrics Demo"

### 4. Generate Traffic (Optional)

To see more interesting data in the dashboard:

```bash
# In a separate terminal
./load-generator.sh
```

This will continuously generate requests to see metrics change in real-time.

## Understanding the Dashboard

The dashboard includes 5 panels demonstrating different visualization techniques:

### Panel 1: HTTP Request Rate (Counter)
- **Query**: `rate(http_requests_total{job="metrics-app"}[1m])`
- **Explanation**: Shows requests per second by calculating the rate of increase
- **Learn**: Counters always increase, we use `rate()` to get the per-second rate

### Panel 2: Current Temperature (Gauge)
- **Query**: `sensor_temperature_celsius`
- **Explanation**: Shows the current temperature value
- **Learn**: Gauges show current values directly, with threshold coloring

### Panel 3: Average Request Duration (Histogram)
- **Query**: `rate(http_request_duration_seconds_sum[1m]) / rate(http_request_duration_seconds_count[1m])`
- **Explanation**: Calculates average duration by dividing sum by count
- **Learn**: Histograms provide both sum and count for calculating averages

### Panel 4: Request Status Distribution (Counter)
- **Query**: `sum by(status) (increase(http_requests_total{endpoint="/api/data"}[5m]))`
- **Explanation**: Shows proportion of success (200) vs error (500) responses
- **Learn**: Using `increase()` and aggregation to group data

### Panel 5: Request Duration Percentiles (Histogram)
- **Query**: `histogram_quantile(0.95, sum(rate(http_request_duration_seconds_bucket[1m])) by (le, endpoint))`
- **Explanation**: Shows p50, p95, p99 latency values
- **Learn**: Histograms enable percentile calculations without storing all data points

## Exploring Further

### Query VictoriaMetrics Directly

VictoriaMetrics exposes a Prometheus-compatible API:

```bash
# List all metrics
curl http://localhost:8428/api/v1/label/__name__/values

# Query a metric
curl 'http://localhost:8428/api/v1/query?query=http_requests_total'

# Query with time range
curl 'http://localhost:8428/api/v1/query_range?query=rate(http_requests_total[1m])&start=2024-01-01T00:00:00Z&end=2024-01-01T01:00:00Z&step=15s'
```

### Modify the Dashboard

In Grafana:
1. Click on the dashboard title → "Edit"
2. Click on any panel title → "Edit"
3. Modify queries, change visualization types, adjust colors
4. Save your changes

### Add New Metrics

Edit `main.go` to add new metrics:

```go
// Example: Add a new counter
newCounter := prometheus.NewCounter(
    prometheus.CounterOpts{
        Name: "my_custom_metric",
        Help: "Description of my metric",
    },
)
prometheus.MustRegister(newCounter)

// Increment it somewhere in your code
newCounter.Inc()
```

Then rebuild:
```bash
docker-compose up -d --build
```

## Stopping the Stack

```bash
# Stop all services
docker-compose down

# Stop and remove volumes (clears all data)
docker-compose down -v
```

## Key Concepts Learned

1. **Metric Types**:
   - Counters for cumulative values
   - Gauges for current values
   - Histograms for distributions

2. **Time Series Data**:
   - Metrics are stored as time-series (timestamp + value)
   - Labels add dimensions to metrics
   - Queries aggregate and transform time series

3. **Scraping Model**:
   - VictoriaMetrics pulls metrics from the app
   - App exposes metrics on `/metrics` endpoint
   - Scrape interval determines data granularity

4. **Visualization**:
   - Different panel types for different data
   - PromQL queries transform raw metrics
   - Dashboards organize related metrics

## Common Issues

**Dashboard shows "No Data"**:
- Wait 30-60 seconds after starting for metrics to appear
- Verify scrape targets: `curl http://localhost:8428/api/v1/targets`
- Check time range in Grafana (top right)

**Containers won't start**:
- Check ports aren't already in use: `lsof -i :8080,8428,3000`
- Check Docker logs: `docker-compose logs [service-name]`

**Metrics not updating**:
- Generate some traffic with load-generator.sh
- Refresh the dashboard
- Check scrape interval in victoriametrics/scrape.yml

## Next Steps

Ready for Phase 2? You'll learn about:
- Real-time data streaming with NATS
- Pub/Sub messaging patterns
- Decoupling data producers and consumers
- Building event-driven architectures

See the main README.md for the complete learning path.
