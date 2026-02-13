#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Step 02: Install Traefik"

helm repo add traefik https://traefik.github.io/charts 2>/dev/null || true
helm repo update traefik

helm upgrade --install traefik traefik/traefik \
  --namespace traefik --create-namespace \
  --version 39.0.0 \
  --values "${SCRIPT_DIR}/traefik-values.yaml" \
  --wait --timeout 300s

echo ""
echo "==> Waiting for Traefik LoadBalancer IP..."
kubectl wait --namespace traefik \
  --for=jsonpath='{.status.loadBalancer.ingress[0]}' \
  service/traefik \
  --timeout=120s 2>/dev/null || true

TRAEFIK_IP=$(kubectl get svc traefik \
  -n traefik \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo ""
echo "==> Traefik LoadBalancer IP: ${TRAEFIK_IP:-<pending>}"
