#!/usr/bin/env bash

set -euo pipefail

CLUSTER_NAME="what3words"

if kind get clusters | grep -qx "$CLUSTER_NAME"; then
    echo "Cluster '$CLUSTER_NAME' already exists"
    exit 0
fi

kind create cluster \
    --name "$CLUSTER_NAME" \
    --config cluster/kind.yaml