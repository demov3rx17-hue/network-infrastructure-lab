#!/usr/bin/env bash
# Run on switch01 as root after checking interface names with: ip link
set -Eeuo pipefail

TRUNK_IF="${TRUNK_IF:-ens33}"
OFFICE_IF="${OFFICE_IF:-ens34}"
SERVER_IF="${SERVER_IF:-ens35}"
GUEST_IF="${GUEST_IF:-ens36}"
MGMT_IF="${MGMT_IF:-ens37}"
BRIDGE="${BRIDGE:-br0}"
MGMT_PORT="${MGMT_PORT:-mgmt0}"
MGMT_ADDRESS="${MGMT_ADDRESS:-192.168.40.2/24}"
MGMT_GATEWAY="${MGMT_GATEWAY:-192.168.40.1}"

for interface in "$TRUNK_IF" "$OFFICE_IF" "$SERVER_IF" "$GUEST_IF" "$MGMT_IF"; do
  ip link show "$interface" >/dev/null || {
    echo "ERROR: interface not found: $interface" >&2
    exit 1
  }
done

systemctl enable --now openvswitch-switch
ovs-vsctl --may-exist add-br "$BRIDGE"

# The trunk carries all four VLANs to router01.
ovs-vsctl --may-exist add-port "$BRIDGE" "$TRUNK_IF"
ovs-vsctl set port "$TRUNK_IF" trunks=10,20,30,40

# Each client interface is an untagged access port in one VLAN.
ovs-vsctl --may-exist add-port "$BRIDGE" "$OFFICE_IF"
ovs-vsctl set port "$OFFICE_IF" tag=10
ovs-vsctl --may-exist add-port "$BRIDGE" "$SERVER_IF"
ovs-vsctl set port "$SERVER_IF" tag=20
ovs-vsctl --may-exist add-port "$BRIDGE" "$GUEST_IF"
ovs-vsctl set port "$GUEST_IF" tag=30
ovs-vsctl --may-exist add-port "$BRIDGE" "$MGMT_IF"
ovs-vsctl set port "$MGMT_IF" tag=40

# The switch itself is managed from VLAN 40.  An internal OVS port is used
# instead of putting an IP address on the physical trunk interface.
ovs-vsctl --may-exist add-port "$BRIDGE" "$MGMT_PORT" \
  -- set Interface "$MGMT_PORT" type=internal
ovs-vsctl set port "$MGMT_PORT" tag=40

ip link set "$BRIDGE" up
ip link set "$MGMT_PORT" up
ip address flush dev "$MGMT_PORT"
ip address add "$MGMT_ADDRESS" dev "$MGMT_PORT"
ip route replace default via "$MGMT_GATEWAY" dev "$MGMT_PORT"

# ens33 initially had the temporary 192.168.100.2 address used during setup.
# The permanent management address is 192.168.40.2 on mgmt0.
ip address flush dev "$TRUNK_IF"

printf '%s\n' 'Open vSwitch is configured.'
ovs-vsctl show
