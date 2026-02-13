#!/usr/bin/env bash
set -euo pipefail

echo "==> Step 06: Uninstall ingress-nginx"

helm uninstall ingress-nginx --namespace ingress-nginx 2>/dev/null || true
kubectl delete namespace ingress-nginx --ignore-not-found

echo ""
echo "==> ingress-nginx fully removed."
