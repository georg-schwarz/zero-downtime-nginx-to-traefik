#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Step 05: Remove nginx Ingress resource"

kubectl delete -f "${SCRIPT_DIR}/sample-app/" --ignore-not-found

echo ""
echo "==> nginx Ingress deleted. Traefik is now the sole ingress controller."
