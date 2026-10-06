Sure — here's the complete `docs/observability.md` content, ready to paste.

```md
# Observability

This adds a minimal Prometheus deployment for the Greeter service.

The setup uses a small Helm chart under `helm/prometheus/`.

## Prerequisites

The kind cluster must be running and the Greeter service must already be deployed.

Check:

```bash
kubectl get nodes
kubectl get pods -n greeter
kubectl get svc -n greeter
```

The Greeter service is exposed locally through:

```text
http://localhost:30080
```

## Deploy Prometheus

Install the Prometheus Helm chart:

```bash
helm upgrade --install prometheus ./helm/prometheus \
  --namespace observability \
  --create-namespace
```

Check the deployment:

```bash
kubectl get pods -n observability
kubectl get svc -n observability
helm list -n observability
```

Expected:

```text
prometheus-...   1/1   Running
```

## Verify Prometheus

Forward the Prometheus service to the local machine:

```bash
kubectl port-forward svc/prometheus \
  -n observability \
  9090:9090
```

In another terminal:

```bash
curl http://localhost:9090/-/ready
```

Expected:

```text
Prometheus Server is Ready.
```

## Verify Greeter is being scraped

Query Prometheus:

```bash
curl -s \
  'http://localhost:9090/api/v1/query?query=up'
```

The result should contain the Greeter target:

```json
"job":"greeter"
```

with:

```json
"1"
```

The `1` means the Greeter scrape target is up.

## Verify application metrics

Query the request counter:

```bash
curl -s \
  'http://localhost:9090/api/v1/query?query=greeter_http_requests_total'
```

The result should contain metrics such as:

```text
greeter_http_requests_total
```

including request paths and HTTP status codes.

For example, after calling `/boom`, you should see:

```text
path="/boom"
status="500"
```

## Test the alert

The Greeter application provides `/boom`, which always returns HTTP 500.

Generate enough errors to exceed the alert threshold:

```bash
for i in {1..200}; do
  curl -s -o /dev/null http://localhost:30080/boom
done
```

The alert is configured with:

- 5% HTTP 5xx error-rate threshold
- 30 second `for` period

Check the alert state:

```bash
curl -s http://localhost:9090/api/v1/alerts
```

The alert should first appear as:

```text
"state":"pending"
```

and then transition to:

```text
"state":"firing"
```

The alert name is:

```text
GreeterHighErrorRate
```

You can also query the alert directly:

```bash
curl -s \
  'http://localhost:9090/api/v1/query?query=ALERTS%7Balertname%3D%22GreeterHighErrorRate%22%7D'
```

## Verify the error metric

To inspect the underlying 500 responses:

```bash
curl -s \
  'http://localhost:9090/api/v1/query?query=greeter_http_requests_total'
```

Look for:

```text
path="/boom"
status="500"
```

## Stop port forwarding

When finished, press:

```text
Ctrl-C
```

in the terminal running `kubectl port-forward`.

The Prometheus deployment remains in the cluster.

## Remove Prometheus

To remove the observability extension:

```bash
helm uninstall prometheus -n observability
kubectl delete namespace observability
```

The Greeter application is unaffected.
```

I would keep this file **procedural** like above, and keep the reasoning/trade-offs in `DECISIONS.md`, so the two documents don't duplicate each other.