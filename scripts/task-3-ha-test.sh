#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="greeter"
NODE="what3words-worker"
URL="http://localhost:30080/"

echo "Pods before drain"
kubectl get pods -n "$NAMESPACE" -o wide

echo "Start request loop"
(
    while true; do
        curl -s -o /dev/null -w "%{http_code}\n" "$URL"
        sleep 1
    done
) &
LOAD_PID=$!

trap 'kill "$LOAD_PID" 2>/dev/null || true' EXIT

sleep 3

echo "Drain $NODE"
kubectl drain "$NODE" \
    --ignore-daemonsets \
    --delete-emptydir-data

echo "Wait for replacement pod"
kubectl rollout status deployment/greeter \
    -n "$NAMESPACE" \
    --timeout=120s

echo "Pods after drain"
kubectl get pods -n "$NAMESPACE" -o wide

echo "Restore $NODE"
kubectl uncordon "$NODE"

echo "Wait for replicas to recover"
kubectl rollout status deployment/greeter \
    -n "$NAMESPACE" \
    --timeout=120s

echo "Final pods"
kubectl get pods -n "$NAMESPACE" -o wide