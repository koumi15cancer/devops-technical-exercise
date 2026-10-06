#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="greeter"
RELEASE="greeter"
CHART="./helm/greeter"
PORT="30080"

echo "Checking Helm chart"
helm lint "$CHART"

echo "Checking cluster"
kubectl get nodes

echo "Deploying prod"
helm upgrade --install "$RELEASE" "$CHART" \
  --namespace "$NAMESPACE" \
  --create-namespace \
  -f "$CHART/values-prod.yaml"

echo "Waiting for deployment"
kubectl rollout status \
  "deployment/$RELEASE" \
  --namespace "$NAMESPACE" \
  --timeout=120s

echo "Checking pods"
kubectl get pods \
  --namespace "$NAMESPACE" \
  -o wide

echo "Checking service"
kubectl get svc \
  "$RELEASE" \
  --namespace "$NAMESPACE"

echo "Testing external endpoint"
response="$(curl --fail --silent \
  "http://localhost:${PORT}/")"

echo "Response: $response"

if [[ "$response" != *"Production"* ]]; then
    echo "ERROR: expected Production greeting"
    exit 1
fi

echo "Testing liveness"
curl --fail --silent \
  "http://localhost:${PORT}/healthz" >/dev/null

echo "    /healthz OK"

echo "Testing readiness"
curl --fail --silent \
  "http://localhost:${PORT}/readyz" >/dev/null

echo "    /readyz OK"

echo "Testing version"
version="$(curl --fail --silent \
  "http://localhost:${PORT}/version")"

echo "    version: $version"

if [[ "$version" != "prod" ]]; then
    echo "ERROR: expected version 'prod'"
    exit 1
fi

echo
echo "Task 3 smoke test passed."