#!/usr/bin/env bash

set -euo pipefail

exec > >(tee /var/log/argocd-install.log) 2>&1

export KUBECONFIG="/etc/rancher/k3s/k3s.yaml"

if ! command -v helm >/dev/null 2>&1; then
    echo "ERROR: helm command not found in PATH=$PATH"
    ls -l /usr/bin/helm /usr/local/bin/helm 2>/dev/null || true
    exit 1
fi

if [[ ! -f "$KUBECONFIG" ]]; then
    echo "ERROR: $KUBECONFIG not found"
    exit 1
fi

echo "Waiting for Kubernetes API via $KUBECONFIG"
for _ in $(seq 1 30); do
    if kubectl --kubeconfig "$KUBECONFIG" version --short >/dev/null 2>&1; then
        break
    fi
    sleep 2
done

if ! kubectl --kubeconfig "$KUBECONFIG" version --short >/dev/null 2>&1; then
    echo "ERROR: Kubernetes API not ready or deprecated"
    exit 1
fi

helm repo add argo https://argoproj.github.io/argo-helm

helm --kubeconfig "$KUBECONFIG" install argocd argo/argo-cd --version ${argocd_version} -n ${argocd_namespace} --create-namespace

echo "Argocd installed by helm"

echo "Testing kubectl"

if ! kubectl --kubeconfig "$KUBECONFIG" get pods -n argocd >/dev/null 2>&1; then
    echo "Namespace argocd or pods didnt created successfully "
    exit 1
else
    echo "Namespace argocd created successfully"
fi

echo "Argocd is ready"

