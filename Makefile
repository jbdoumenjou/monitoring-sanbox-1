.PHONY: help up down restart logs ps status clean clean-all metrics query load-test grafana docs

# Default target - show help
help:
	@echo "======================================"
	@echo "Monitoring Sandbox - Phase 1"
	@echo "======================================"
	@echo ""
	@echo "Stack Management:"
	@echo "  make up           - Start all services (build if needed)"
	@echo "  make down         - Stop all services"
	@echo "  make restart      - Restart all services"
	@echo "  make clean        - Stop services and remove containers"
	@echo "  make clean-all    - Stop services, remove containers and volumes (deletes all data)"
	@echo ""
	@echo "Monitoring & Logs:"
	@echo "  make ps           - Show running containers"
	@echo "  make status       - Show detailed service status"
	@echo "  make logs         - Follow all logs"
	@echo "  make logs-app     - Follow Go app logs"
	@echo "  make logs-vm      - Follow VictoriaMetrics logs"
	@echo "  make logs-grafana - Follow Grafana logs"
	@echo ""
	@echo "Testing & Queries:"
	@echo "  make metrics      - View raw metrics from Go app"
	@echo "  make query        - Run sample queries against VictoriaMetrics"
	@echo "  make targets      - Show VictoriaMetrics scrape targets"
	@echo "  make temp-history - Show temperature history (last 15 min)"
	@echo "  make load-test    - Generate continuous traffic (Ctrl+C to stop)"
	@echo ""
	@echo "Access Points:"
	@echo "  make grafana      - Open Grafana in browser"
	@echo "  make vmui         - Open VictoriaMetrics UI in browser"
	@echo "  make docs         - Show documentation links"
	@echo ""
	@echo "======================================"
	@echo "URLs:"
	@echo "  Grafana:          http://localhost:3000 (admin/admin)"
	@echo "  VictoriaMetrics:  http://localhost:8428/vmui"
	@echo "  Go App Metrics:   http://localhost:8080/metrics"
	@echo "======================================"

# Start the stack
up:
	@echo "🚀 Starting monitoring stack..."
	@chmod -R 755 grafana/provisioning 2>/dev/null || true
	podman-compose up -d --build
	@echo ""
	@echo "⏳ Waiting for services to be ready..."
	@sleep 10
	@echo ""
	@make status

# Stop the stack
down:
	@echo "🛑 Stopping monitoring stack..."
	podman-compose down
	@echo "✅ Stack stopped"

# Restart all services
restart:
	@echo "🔄 Restarting monitoring stack..."
	podman-compose restart
	@echo "⏳ Waiting for services to be ready..."
	@sleep 5
	@make status

# Stop and remove containers
clean:
	@echo "🧹 Cleaning up containers..."
	podman-compose down
	@echo "✅ Containers removed"

# Stop, remove containers and volumes (deletes all data)
clean-all:
	@echo "⚠️  Warning: This will delete all stored metrics data!"
	@echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
	@sleep 5
	@echo "🧹 Cleaning up containers and volumes..."
	podman-compose down -v
	@echo "✅ Containers and volumes removed"

# Show running containers
ps:
	@podman-compose ps

# Show detailed service status
status:
	@echo "======================================"
	@echo "Service Status"
	@echo "======================================"
	@podman-compose ps
	@echo ""
	@echo "======================================"
	@echo "Health Checks"
	@echo "======================================"
	@echo -n "Go App:           "
	@curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/metrics && echo " ✅ Healthy" || echo " ❌ Down"
	@echo -n "VictoriaMetrics:  "
	@curl -s -o /dev/null -w "%{http_code}" http://localhost:8428/health && echo " ✅ Healthy" || echo " ❌ Down"
	@echo -n "Grafana:          "
	@curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health && echo " ✅ Healthy" || echo " ❌ Down"
	@echo ""

# Follow all logs
logs:
	podman-compose logs -f

# Follow Go app logs
logs-app:
	podman-compose logs -f metrics-app

# Follow VictoriaMetrics logs
logs-vm:
	podman-compose logs -f victoriametrics

# Follow Grafana logs
logs-grafana:
	podman-compose logs -f grafana

# View raw metrics from Go app
metrics:
	@echo "======================================"
	@echo "Go Application Metrics"
	@echo "======================================"
	@curl -s http://localhost:8080/metrics | grep -E '^(http_requests_total|sensor_temperature_celsius|http_request_duration)' || echo "No metrics available yet. Is the service running?"
	@echo ""

# Show VictoriaMetrics scrape targets
targets:
	@echo "======================================"
	@echo "VictoriaMetrics Scrape Targets"
	@echo "======================================"
	@curl -s http://localhost:8428/api/v1/targets | python3 -c "import sys, json; data=json.load(sys.stdin); [print(f\"Job: {t['labels']['job']}, Instance: {t['labels']['instance']}, Health: {t['health']}, Last Scrape: {t['lastScrapeDuration']}s\") for t in data['data']['activeTargets']]" 2>/dev/null || echo "VictoriaMetrics not ready yet"
	@echo ""

# Show temperature history
temp-history:
	@echo "======================================"
	@echo "Temperature History (Last 15 Minutes)"
	@echo "======================================"
	@python3 -c '\
import requests; \
import time; \
from datetime import datetime; \
end = int(time.time()); \
start = end - 900; \
url = f"http://localhost:8428/api/v1/query_range?query=sensor_temperature_celsius&start={start}&end={end}&step=15s"; \
try: \
    data = requests.get(url).json(); \
    if data["data"]["result"]: \
        values = data["data"]["result"][0]["values"]; \
        print(f"Total data points: {len(values)}\n"); \
        print("Time                Temperature"); \
        print("-" * 40); \
        for ts, temp in values[-20:]: \
            dt = datetime.fromtimestamp(int(ts)); \
            print(f"{dt.strftime(\"%H:%M:%S\")}            {float(temp):.2f}°C"); \
        print(f"\nMin: {min(float(v[1]) for v in values):.2f}°C"); \
        print(f"Max: {max(float(v[1]) for v in values):.2f}°C"); \
        print(f"Avg: {sum(float(v[1]) for v in values)/len(values):.2f}°C"); \
    else: \
        print("No data available yet"); \
except Exception as e: \
    print(f"Error: {e}"); \
'
	@echo ""

# Run sample queries against VictoriaMetrics
query:
	@echo "======================================"
	@echo "Sample VictoriaMetrics Queries"
	@echo "======================================"
	@echo ""
	@echo "1️⃣  Total HTTP Requests:"
	@curl -s 'http://localhost:8428/api/v1/query?query=http_requests_total' | python3 -c "import sys, json; data=json.load(sys.stdin); [print(f\"  {r['metric']['endpoint']} [{r['metric']['status']}]: {r['value'][1]} requests\") for r in data['data']['result']]" 2>/dev/null || echo "  No data yet"
	@echo ""
	@echo "2️⃣  Current Temperature:"
	@curl -s 'http://localhost:8428/api/v1/query?query=sensor_temperature_celsius' | python3 -c "import sys, json; data=json.load(sys.stdin); result=data['data']['result']; print(f\"  {result[0]['value'][1]}°C\") if result else print('  No data yet')" 2>/dev/null || echo "  No data yet"
	@echo ""
	@echo "3️⃣  Request Rate (per second):"
	@curl -s 'http://localhost:8428/api/v1/query?query=rate(http_requests_total[1m])' | python3 -c "import sys, json; data=json.load(sys.stdin); [print(f\"  {r['metric']['endpoint']}: {float(r['value'][1]):.3f} req/s\") for r in data['data']['result']]" 2>/dev/null || echo "  No data yet"
	@echo ""
	@echo "4️⃣  Average Request Duration:"
	@curl -s 'http://localhost:8428/api/v1/query?query=rate(http_request_duration_seconds_sum[1m])/rate(http_request_duration_seconds_count[1m])' | python3 -c "import sys, json; data=json.load(sys.stdin); [print(f\"  {r['metric']['endpoint']}: {float(r['value'][1])*1000:.2f}ms\") for r in data['data']['result']]" 2>/dev/null || echo "  No data yet"
	@echo ""

# Generate continuous traffic for testing
load-test:
	@echo "🔥 Generating continuous traffic..."
	@echo "Press Ctrl+C to stop"
	@echo ""
	@bash -c 'trap exit INT; while true; do curl -s http://localhost:8080/ > /dev/null; curl -s http://localhost:8080/api/data > /dev/null; sleep 0.5; done'

# Open Grafana in browser
grafana:
	@echo "🌐 Opening Grafana in browser..."
	@echo "   URL: http://localhost:3000"
	@echo "   Username: admin"
	@echo "   Password: admin"
	@which xdg-open > /dev/null && xdg-open http://localhost:3000 || echo "   (Please open manually)"

# Open VictoriaMetrics UI in browser
vmui:
	@echo "🌐 Opening VictoriaMetrics UI in browser..."
	@echo "   URL: http://localhost:8428/vmui"
	@echo ""
	@echo "💡 Try these queries:"
	@echo "   - sensor_temperature_celsius"
	@echo "   - http_requests_total"
	@echo "   - rate(http_requests_total[1m])"
	@which xdg-open > /dev/null && xdg-open http://localhost:8428/vmui || echo "   (Please open manually)"

# Show documentation
docs:
	@echo "======================================"
	@echo "Documentation"
	@echo "======================================"
	@echo ""
	@echo "📖 Project Documentation:"
	@echo "   README.md  - Complete learning path"
	@echo "   PHASE1.md  - Phase 1 detailed guide"
	@echo ""
	@echo "🔗 External Resources:"
	@echo "   VictoriaMetrics: https://docs.victoriametrics.com/"
	@echo "   Grafana:         https://grafana.com/docs/"
	@echo "   Prometheus:      https://prometheus.io/docs/concepts/metric_types/"
	@echo ""

# Quick start with traffic generation
demo: up
	@echo ""
	@echo "======================================"
	@echo "🎬 Demo Mode"
	@echo "======================================"
	@echo ""
	@echo "Generating some initial traffic..."
	@for i in {1..20}; do curl -s http://localhost:8080/ > /dev/null; curl -s http://localhost:8080/api/data > /dev/null; done
	@echo "✅ Traffic generated!"
	@echo ""
	@sleep 2
	@make query
	@echo ""
	@echo "🌐 Open Grafana to see the dashboard:"
	@echo "   http://localhost:3000 (admin/admin)"
	@echo ""
	@echo "💡 Tip: Run 'make load-test' in another terminal for continuous traffic"
