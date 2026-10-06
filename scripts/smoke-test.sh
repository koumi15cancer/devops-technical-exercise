#!/usr/bin/env bash

set -euo pipefail

CONTAINER_NAME="greeter-smoke-test"
IMAGE="greeter:dev"
PORT="8080"

cleanup() {
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
}

trap cleanup EXIT

echo "Starting container"

docker run -d \
    --name "$CONTAINER_NAME" \
    -p "$PORT:8080" \
    -e GREETING_NAME="Smoke Test" \
    -e WARMUP_SECONDS=2 \
    "$IMAGE"

echo "Waiting for application"

for i in {1..10}; do
    if curl -sf "http://localhost:$PORT/healthz" >/dev/null; then
        break
    fi

    sleep 1
done

echo "Checking health"

curl -sf "http://localhost:$PORT/healthz" >/dev/null

echo "PASS: /healthz"

echo "Checking readiness"

for i in {1..10}; do
    if curl -sf "http://localhost:$PORT/readyz" >/dev/null; then
        break
    fi

    sleep 1
done

curl -sf "http://localhost:$PORT/readyz" >/dev/null

echo "PASS: /readyz"

echo "Checking greeting"

curl -sf "http://localhost:$PORT/" | grep -q "Smoke Test"

echo "PASS: /"

echo "Checking version"

curl -sf "http://localhost:$PORT/version" >/dev/null

echo "PASS: /version"

echo
echo "Smoke test passed."