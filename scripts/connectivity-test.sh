#!/usr/bin/env bash
# Usage: ./connectivity-test.sh GATEWAY INTERNET_IP ALLOWED_IP BLOCKED_IP
set -Eeuo pipefail

if [[ $# -ne 4 ]]; then
  echo "Usage: $0 GATEWAY INTERNET_IP ALLOWED_IP BLOCKED_IP" >&2
  exit 2
fi

check_ping() {
  local label="$1" host="$2" expected="$3"
  if ping -c 2 -W 2 "$host" >/dev/null 2>&1; then
    result=OK
  else
    result=FAILED
  fi
  printf '%-18s %-16s result=%-6s expected=%s\n' "$label" "$host" "$result" "$expected"
}

check_ping gateway "$1" OK
check_ping internet "$2" OK
check_ping allowed-vlan "$3" OK
check_ping blocked-vlan "$4" BLOCKED
