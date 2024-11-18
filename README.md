docker network create custom_network
docker compose up -d
docker run --rm --network custom_network -v ./tests/load:/app -i grafana/k6 run /app/main.js --out web-dashboard=export=/app/reports/test-report.html

