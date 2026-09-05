#!/usr/bin/env bash
# Simple check for any Ubuntu client VM.
set -Eeuo pipefail

echo '=== Host ==='
hostnamectl --static
echo
echo '=== Addresses ==='
ip -br addr
echo
echo '=== Routes ==='
ip route
echo
echo '=== DNS ==='
resolvectl status 2>/dev/null || cat /etc/resolv.conf
