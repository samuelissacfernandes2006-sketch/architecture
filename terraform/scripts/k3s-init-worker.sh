#!/usr/bin/env bash

set -euo pipefail

exec > >(tee /var/log/k3s-bootstrap.log) 2>&1

echo "[bootstrap] Starting node bootstrap at $(date -Is)"

echo "[bootstrap] Updating base packages"
apt-get update -y
apt-get install -y curl ca-certificates


echo "[bootstrap] Installing k3s (${k3s_version})"
export INSTALL_K3S_VERSION='${k3s_version}'

if [[ "${k3s_token}" != "null" && -n "${k3s_token}" ]]; then
  export K3S_TOKEN="${k3s_token}"
fi

curl -sfL https://get.k3s.io | sh -s - agent --server https://${master_nodes_dns}:6443

systemctl enable k3s-agent

ln -sf /usr/local/bin/kubectl /usr/bin/kubectl

echo "[bootstrap] k3s installation finished"

echo "[bootstrap] Finished at $(date -Is)"
