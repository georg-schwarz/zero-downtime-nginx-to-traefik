#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Step 01: Baseline - install ingress-nginx and sample app"

# --- ingress-nginx --------------------------------------------------------
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 2>/dev/null || true
helm repo update ingress-nginx

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --version 4.14.3 \
  --values "${SCRIPT_DIR}/nginx-ingress-values.yaml" \
  --wait --timeout 300s

# --- sample app -----------------------------------------------------------
kubectl create namespace sample-app 2>/dev/null || true
kubectl apply -f "${SCRIPT_DIR}/sample-app/"

echo ""
echo "==> Waiting for ingress-nginx LoadBalancer IP..."
kubectl wait --namespace ingress-nginx \
  --for=jsonpath='{.status.loadBalancer.ingress[0]}' \
  service/ingress-nginx-controller \
  --timeout=120s 2>/dev/null || true

NGINX_IP=$(kubectl get svc ingress-nginx-controller \
  -n ingress-nginx \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo ""
echo "==> ingress-nginx LoadBalancer IP: ${NGINX_IP:-<pending>}"
echo "    Test: curl http://${NGINX_IP:-<pending>}/sample-app"
