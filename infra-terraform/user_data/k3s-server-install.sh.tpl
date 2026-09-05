#!/bin/bash
set -euo pipefail

exec > >(tee /var/log/k3s-install.log) 2>&1
echo "=== Starting K3s SERVER bootstrap: $(date) ==="

curl -sfL https://get.k3s.io | sh -s - server \
 --write-kubeconfig-mode 644 \
 --token "${k3s_token}" \
 --tls-san "${public_ip}"

until /usr/local/bin/k3s kubectl get nodes >/dev/null 2>&1; do
 echo "Waiting for K3s to be ready..."
 sleep 5
done
echo "=== K3s server is up ==="

export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
export PATH=$PATH:/usr/local/bin

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install ingress-nginx ingress-nginx/ingress-nginx \
 --namespace ingress-nginx \
 --create-namespace \
 --set controller.service.type=LoadBalancer

echo "=== Nginx Ingress installed ==="

k3s kubectl create namespace argocd
k3s kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "=== ArgoCD installed ==="
echo "Get ArgoCD initial admin password with:"
echo " k3s kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"

echo "=== Bootstrap complete: $(date) ==="
