#!/usr/bin/env bash

set -euo pipefail

exec > >(tee /var/log/k3s-bootstrap.log) 2>&1

echo "[bootstrap] Starting node bootstrap at $(date -Is)"

echo "[bootstrap] Updating base packages"
apt-get update -y
apt-get install -y curl ca-certificates

if ${enable_k3s}; then
  echo "[bootstrap] Installing k3s (${k3s_version})"
  export INSTALL_K3S_VERSION='${k3s_version}'

%{ if k3s_token != null ~}
  export K3S_TOKEN='${k3s_token}'
%{ endif ~}

  # --write-kubeconfig-mode allows non-root read after explicit permission steps.
  curl -sfL https://get.k3s.io | sh -s - server \
    --write-kubeconfig-mode 0644 \
    --tls-san ${cluster_name}

  systemctl enable k3s

  ln -sf /usr/local/bin/kubectl /usr/bin/kubectl

  # Store kubeconfig in ubuntu home for easier retrieval.
  mkdir -p /home/ubuntu/.kube
  cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
  chown -R ubuntu:ubuntu /home/ubuntu/.kube

  echo "[bootstrap] k3s installation finished"
else
  echo "[bootstrap] k3s installation disabled by variable"
fi

echo "[bootstrap] Finished at $(date -Is)"
