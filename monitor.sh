#!/usr/bin/env bash
set -euo pipefail

# ---------------------------------------------------------------------------
# monitor.sh — poll a URL every 1 s and report availability
# Usage: ./monitor.sh http://<loadbalancer-ip>
# ---------------------------------------------------------------------------

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <base-url>"
  echo "Example: $0 http://192.168.1.100"
  exit 1
fi

BASE_URL="${1%/}"
ENDPOINT="${BASE_URL}/sample-app"

# Colours
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Colour

total=0
failures=0
in_downtime=false
downtime_start=""
downtime_windows=()

summary() {
  echo ""
  echo "========================================"
  echo " Summary"
  echo "========================================"
  echo " Total requests : ${total}"
  echo " Failures       : ${failures}"
  if [[ ${#downtime_windows[@]} -gt 0 ]]; then
    echo " Downtime windows:"
    for window in "${downtime_windows[@]}"; do
      echo "   ${window}"
    done
  else
    echo " Downtime windows: none"
  fi
  echo "========================================"
}

close_downtime() {
  local end_ts
  end_ts=$(date '+%Y-%m-%dT%H:%M:%S')
  local start_epoch end_epoch duration
  start_epoch=$(date -d "${downtime_start}" '+%s' 2>/dev/null || date -j -f '%Y-%m-%dT%H:%M:%S' "${downtime_start}" '+%s')
  end_epoch=$(date -d "${end_ts}" '+%s' 2>/dev/null || date -j -f '%Y-%m-%dT%H:%M:%S' "${end_ts}" '+%s')
  duration=$((end_epoch - start_epoch))
  downtime_windows+=("${downtime_start} -> ${end_ts}  (${duration}s)")
  in_downtime=false
}

trap 'if $in_downtime; then close_downtime; fi; summary; exit 0' INT TERM

echo "Monitoring ${ENDPOINT} (Ctrl+C to stop)"
echo "----------------------------------------"

while true; do
  ts=$(date '+%Y-%m-%dT%H:%M:%S')
  http_code=$(curl -s -o /dev/null -w '%{http_code}' \
    --connect-timeout 2 --max-time 5 "${ENDPOINT}" || true)
  total=$((total + 1))

  if [[ "${http_code}" == "200" ]]; then
    echo -e "${ts}  ${GREEN}OK   ${http_code}${NC}"
    if $in_downtime; then
      close_downtime
    fi
  else
    echo -e "${ts}  ${RED}FAIL ${http_code}${NC}"
    failures=$((failures + 1))
    if ! $in_downtime; then
      in_downtime=true
      downtime_start="${ts}"
    fi
  fi

  sleep 1
done
