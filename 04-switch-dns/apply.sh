#!/usr/bin/env bash
set -euo pipefail

echo "==> Step 04: Switch DNS from nginx to Traefik"
echo ""

NGINX_IP=$(kubectl get svc ingress-nginx-controller \
  -n ingress-nginx \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "<pending>")

TRAEFIK_IP=$(kubectl get svc traefik \
  -n traefik \
  -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "<pending>")

echo "    Current IPs:"
echo "      nginx   : ${NGINX_IP}"
echo "      Traefik : ${TRAEFIK_IP}"
echo ""
echo "    Action required - update your DNS A record:"
echo "      Old: your.domain.example  ->  ${NGINX_IP}"
echo "      New: your.domain.example  ->  ${TRAEFIK_IP}"
echo ""
echo "    Recommendations:"
echo "      1. Lower DNS TTL to 60 s before switching (if not already done)."
echo "      2. Update the A record to point to the Traefik IP."
echo "      3. Keep ingress-nginx running for 24-48 h to serve clients"
echo "         with stale DNS caches."
echo "      4. Monitor traffic on both controllers during the transition."
echo ""
echo "    This step is documentation only - no cluster changes were made."
