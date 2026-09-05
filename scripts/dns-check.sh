#!/usr/bin/env bash
# Usage: ./dns-check.sh [DNS_SERVER] [DOMAIN]
set -Eeuo pipefail

DNS_SERVER="${1:-$(awk '/^nameserver/ {print $2; exit}' /etc/resolv.conf)}"
DOMAIN="${2:-deb.debian.org}"

command -v dig >/dev/null || {
  echo 'Install dnsutils first: sudo apt install dnsutils' >&2
  exit 1
}

echo "Query: $DOMAIN via $DNS_SERVER"
dig +short "@$DNS_SERVER" "$DOMAIN"
