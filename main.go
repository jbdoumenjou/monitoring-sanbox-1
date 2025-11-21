package main

import (
	"log"
	"math/rand"
	"net/http"
	"time"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
	// Counter: Tracks total number of requests
	requestsTotal = prometheus.NewCounterVec(
		prometheus.CounterOpts{
			Name: "http_requests_total",
			Help: "Total number of HTTP requests",
		},
		[]string{"endpoint", "method", "status"},
	)

	// Gauge: Tracks current value (simulating temperature sensor)
	currentTemperature = prometheus.NewGauge(
		prometheus.GaugeOpts{
			Name: "sensor_temperature_celsius",
			Help: "Current temperature in Celsius",
		},
	)

	// Histogram: Measures distribution of request durations
	requestDuration = prometheus.NewHistogramVec(
		prometheus.HistogramOpts{
			Name:    "http_request_duration_seconds",
			Help:    "HTTP request duration in seconds",
			Buckets: prometheus.DefBuckets, // Default buckets: .005, .01, .025, .05, .1, .25, .5, 1, 2.5, 5, 10
		},
		[]string{"endpoint"},
	)
)

func init() {
	// Register metrics with Prometheus
	prometheus.MustRegister(requestsTotal)
	prometheus.MustRegister(currentTemperature)
	prometheus.MustRegister(requestDuration)
}

func main() {
	// Start background goroutine to simulate sensor data
	go simulateSensorData()

	// Setup HTTP handlers
	http.HandleFunc("/", healthHandler)
	http.HandleFunc("/api/data", dataHandler)
	http.Handle("/metrics", promhttp.Handler())

	log.Println("Starting server on :8080")
	log.Println("Metrics available at http://localhost:8080/metrics")
	log.Fatal(http.ListenAndServe(":8080", nil))
}

// healthHandler is a simple health check endpoint
func healthHandler(w http.ResponseWriter, r *http.Request) {
	start := time.Now()

	// Record metrics
	requestsTotal.WithLabelValues("/", r.Method, "200").Inc()

	w.WriteHeader(http.StatusOK)
	w.Write([]byte("OK"))

	// Record request duration
	duration := time.Since(start).Seconds()
	requestDuration.WithLabelValues("/").Observe(duration)
}

// dataHandler simulates an API endpoint that processes data
func dataHandler(w http.ResponseWriter, r *http.Request) {
	start := time.Now()

	// Simulate some processing time
	processingTime := time.Duration(rand.Intn(100)) * time.Millisecond
	time.Sleep(processingTime)

	// Simulate occasional errors
	status := "200"
	statusCode := http.StatusOK
	if rand.Float32() < 0.1 { // 10% error rate
		status = "500"
		statusCode = http.StatusInternalServerError
	}

	// Record metrics
	requestsTotal.WithLabelValues("/api/data", r.Method, status).Inc()

	w.WriteHeader(statusCode)
	w.Write([]byte(`{"status": "processed"}`))

	// Record request duration
	duration := time.Since(start).Seconds()
	requestDuration.WithLabelValues("/api/data").Observe(duration)
}

// simulateSensorData continuously updates the temperature gauge
func simulateSensorData() {
	baseTemp := 20.0 // Base temperature in Celsius

	for {
		// Simulate temperature fluctuation between 18°C and 28°C
		variation := (rand.Float64() - 0.5) * 10 // -5 to +5 variation
		temperature := baseTemp + variation

		currentTemperature.Set(temperature)

		// Update every 5 seconds
		time.Sleep(5 * time.Second)
	}
}
