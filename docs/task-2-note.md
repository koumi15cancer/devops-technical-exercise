# Local Kubernetes Cluster

This project uses [kind](https://kind.sigs.k8s.io/) to run a reproducible multi-node Kubernetes cluster locally.

## Prerequisites

- Docker
- kind
- kubectl

If not having pkg local, can install through brew/choco/... based on OS preference
##


## Create the cluster

From the repository root:

```bash
./scripts/cluster-up.sh
```

This creates:

- 1 control-plane node
- 2 worker nodes

Verify:

```bash
kubectl get nodes
```

All three nodes should report `Ready`.

## Delete the cluster

```bash
./scripts/cluster-down.sh
```

## Recreate from scratch

```bash
./scripts/cluster-down.sh
./scripts/cluster-up.sh
kubectl get nodes
```

The cluster topology is defined in [`cluster/kind.yaml`](./kind.yaml), and the setup/teardown scripts make the environment reproducible.