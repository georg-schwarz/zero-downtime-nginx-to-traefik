#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Step 03: Dual ingress - add Traefik Ingress alongside nginx"

kubectl apply -f "${SCRIPT_DIR}/sample-app/"

TRAEFIK_IP=$(kubectl get svc traefik \
  -n traefik \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "<pending>")

echo ""
echo "==> Traefik Ingress created. Both controllers now serve /sample-app."
echo "    Test via Traefik: curl http://${TRAEFIK_IP}/sample-app"
