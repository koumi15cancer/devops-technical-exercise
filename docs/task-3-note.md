# Task 3 — Helm Deployment

## Prerequisites

Docker, kind, kubectl and Helm.

## 1. Start cluster

```bash
./scripts/cluster-up.sh
kubectl get nodes
```

Cluster: 1 control-plane + 3 workers.

## 2. Build and load image

```bash
docker build -t greeter:dev .
kind load docker-image greeter:dev --name what3words
```

## 3. Validate Helm

```bash
helm lint ./helm/greeter
helm template greeter ./helm/greeter -f ./helm/greeter/values-prod.yaml
```

## 4. Deploy

```bash
helm upgrade --install greeter ./helm/greeter \
  -n greeter --create-namespace \
  -f ./helm/greeter/values-prod.yaml

kubectl rollout status deployment/greeter -n greeter
kubectl get pods -n greeter -o wide
```

## 5. Test

External access:

```bash
curl http://localhost:30080/
curl http://localhost:30080/healthz
curl http://localhost:30080/readyz
curl http://localhost:30080/version
```

Change environment without rebuilding:

```bash
helm upgrade greeter ./helm/greeter \
  -n greeter \
  -f ./helm/greeter/values-dev.yaml

curl http://localhost:30080/
```

## 6. Test node availability

```bash
./scripts/task-3-ha-test.sh
```

The script continuously sends requests while draining one worker and verifies
that Kubernetes replaces the evicted replica.

## 7. Cleanup

```bash
./scripts/cluster-down.sh
```

## 8. Note for some choices
- NodePort 30080: simple external access from the local kind cluster.
- 3 workers + 3 replicas: allows one replica per worker with hard pod anti-affinity, so losing one worker  not take down the service.
- Node drain: when a worker is unavailable, pod is evicted and kubernetes recreates it on another available worker. During the drain, existing replicas continue serving traffic.