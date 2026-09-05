#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/k3s-agent-install.log) 2>&1
echo "=== Starting K3s AGENT bootstrap: $(date) ==="

# Joins the existing server over its PRIVATE IP (both nodes are in the same
# VPC, so this traffic never leaves AWS's internal network).
curl -sfL https://get.k3s.io | \
  K3S_URL="https://${server_private_ip}:6443" \
  K3S_TOKEN="${k3s_token}" \
  sh -

echo "=== K3s agent bootstrap complete: $(date) ==="
echo "Verify from the SERVER node with: k3s kubectl get nodes"
echo ""
echo "Next steps for this node (done separately via kubectl/ArgoCD, not by this script):"
echo "  - Part B: Postgres/Redis/app pods deploy here via Helm"
echo "  - Jenkins runs here too, as a pod (see project README for setup)"
