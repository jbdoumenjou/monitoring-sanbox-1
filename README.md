# Monitoring Sandbox - Learning Journey

A step-by-step project to learn time-series data management, real-time streaming, and observability using modern tools.

## Project Goals

Learn how to manage and visualize different types of time-based data:
- Application metrics
- Sensor data
- Infrastructure monitoring
- Real-time data streaming

## Technology Stack

- **Go** - Application and metric generation
- **VictoriaMetrics** - Time-series database
- **NATS** - Message streaming
- **Grafana** - Visualization and dashboards
- **Docker Compose** - Local development environment

## Learning Path

### Phase 1: Foundation - Simple Metrics ⬅️ **START HERE**

**Goal**: Understand basic metrics collection and visualization

**Components**:
- Simple Go application generating metrics (counters, gauges, histograms)
- VictoriaMetrics for time-series storage
- Grafana for visualization
- Docker Compose setup

**What you'll learn**:
- Metric types and when to use them
- Prometheus metric format
- Basic Grafana dashboards
- VictoriaMetrics basics

---

### Phase 2: Real-time Streaming

**Goal**: Introduce message-based architecture

**Components**:
- NATS message broker
- Go app publishing metrics to NATS topics
- Consumer service reading from NATS and writing to VictoriaMetrics
- Grafana displaying "live" data

**What you'll learn**:
- Pub/Sub patterns
- Decoupling data producers and consumers
- NATS streaming concepts
- Real-time data visualization

---

### Phase 3: Multiple Data Types

**Goal**: Handle diverse data sources

**Components**:
- Simulated sensor data (temperature, humidity, pressure, etc.)
- Infrastructure monitoring (node-exporter, cAdvisor)
- Multiple NATS subjects for different data types
- Multiple Grafana dashboards

**What you'll learn**:
- Data modeling for different sources
- Topic organization in NATS
- Dashboard organization
- Query optimization

---

### Phase 4: Observability Stack (Optional)

**Goal**: Complete observability with logs and traces

**Components**:
- Grafana Loki for logs
- Grafana Tempo for traces
- OpenTelemetry instrumentation
- Correlation between metrics, logs, and traces
- Alerting rules

**What you'll learn**:
- The three pillars of observability
- Distributed tracing
- Log aggregation
- Alert management

---

### Phase 5: K3s Migration (Optional)

**Goal**: Learn Kubernetes deployment patterns

**Components**:
- K3s local cluster
- Kubernetes manifests or Helm charts
- Persistent volumes
- Service mesh (optional)

**What you'll learn**:
- Kubernetes concepts (pods, services, deployments)
- StatefulSets for databases
- ConfigMaps and Secrets
- Kubernetes networking

---

## Docker Compose vs K3s

**Starting with Docker Compose**:
- ✅ Faster learning iteration
- ✅ Simpler debugging
- ✅ Lower resource overhead
- ✅ Direct component understanding
- ✅ Easy to migrate to K3s later

**Moving to K3s (when ready)**:
- Production-like deployment patterns
- Kubernetes experience
- Advanced networking and scaling
- Industry-standard tooling

---

## Current Status

**Current Phase**: Phase 1 - Foundation

**Completed**:
- Project initialization
- Learning path planning

**Next Steps**:
- Initialize Go module
- Create basic Go app with metrics
- Set up Docker Compose
- Configure VictoriaMetrics
- Create first Grafana dashboard

---

## Quick Start

### Using Make (Recommended)

```bash
# Show all available commands
make help

# Start the stack
make up

# Check status and health
make status

# Run sample queries
make query

# View scrape targets
make targets

# Generate traffic for testing
make load-test

# Stop the stack
make down
```

### Manual Commands

```bash
# Start with Podman
podman-compose up -d --build

# Or with Docker
docker compose up -d --build

# Stop
podman-compose down
```

### Access Points
- **Grafana**: http://localhost:3000 (admin/admin)
- **Go App Metrics**: http://localhost:8080/metrics
- **VictoriaMetrics**: http://localhost:8428

## Project Structure

```
monitoring-sanbox-1/
├── main.go                        # Go app with metrics
├── Dockerfile                     # Go app container image
├── docker-compose.yml             # Services orchestration
├── Makefile                       # Easy commands for managing the stack
├── load-generator.sh              # Traffic generation script
├── victoriametrics/
│   └── scrape.yml                 # VictoriaMetrics scrape config
├── grafana/
│   └── provisioning/
│       ├── datasources/           # Grafana datasource config
│       └── dashboards/            # Pre-built dashboards
├── README.md                      # Main documentation
├── PHASE1.md                      # Phase 1 detailed guide
└── CLAUDE.md                      # Project context for Claude Code
```

---

## Resources & Documentation

- [VictoriaMetrics Docs](https://docs.victoriametrics.com/)
- [NATS Documentation](https://docs.nats.io/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Prometheus Metric Types](https://prometheus.io/docs/concepts/metric_types/)

---

## License

This is a learning project. Feel free to use and modify as needed.
