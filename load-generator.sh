#!/bin/bash

# Simple load generator to create traffic for metrics visualization
# Usage: ./load-generator.sh

echo "Starting load generator..."
echo "Press Ctrl+C to stop"
echo ""

while true; do
  # Hit health endpoint
  curl -s http://localhost:8080/ > /dev/null

  # Hit data endpoint (generates metrics with some errors)
  curl -s http://localhost:8080/api/data > /dev/null

  # Random sleep between requests (0.1 to 1 second)
  sleep 0.$((RANDOM % 10))
done
