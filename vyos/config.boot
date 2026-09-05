/*
 * Shortened, anonymised copy of the working configuration on router01.
 * VyOS 2026.09 rolling uses a global forward filter, not per-interface
 * firewall attachments. Hardware MAC addresses and login settings are omitted.
 */

firewall {
    global-options {
        state-policy {
            established { action accept }
            invalid { action drop }
            related { action accept }
        }
    }
    ipv4 {
        forward {
            filter {
                default-action drop
                rule 10 {
                    action accept
                    description "Office to Servers"
                    inbound-interface { name eth1.10 }
                    outbound-interface { name eth1.20 }
                }
                rule 20 {
                    action accept
                    description "Office to Internet"
                    inbound-interface { name eth1.10 }
                    outbound-interface { name eth0 }
                }
                rule 30 {
                    action accept
                    description "Servers to Management"
                    inbound-interface { name eth1.20 }
                    outbound-interface { name eth1.40 }
                }
                rule 40 {
                    action accept
                    description "Servers to Internet"
                    inbound-interface { name eth1.20 }
                    outbound-interface { name eth0 }
                }
                rule 50 {
                    action accept
                    description "Guest to Internet"
                    inbound-interface { name eth1.30 }
                    outbound-interface { name eth0 }
                }
                rule 60 {
                    action accept
                    description "Management to Servers"
                    inbound-interface { name eth1.40 }
                    outbound-interface { name eth1.20 }
                }
                rule 70 {
                    action accept
                    description "Management to Internet"
                    inbound-interface { name eth1.40 }
                    outbound-interface { name eth0 }
                }
            }
        }
    }
}

interfaces {
    ethernet eth0 {
        address dhcp
        description WAN-VMnet8
    }
    ethernet eth1 {
        /* Kept only as a temporary staging address during installation. */
        address 192.168.100.1/24
        description TRUNK-to-switch01
        vif 10 {
            address 192.168.10.1/24
            description Office
        }
        vif 20 {
            address 192.168.20.1/24
            description Servers
        }
        vif 30 {
            address 192.168.30.1/24
            description Guest
        }
        vif 40 {
            address 192.168.40.1/24
            description Management
        }
    }
    loopback lo
}

nat {
    source {
        rule 10 {
            outbound-interface { name eth0 }
            source { address 192.168.0.0/16 }
            translation { address masquerade }
        }
    }
}

service {
    dhcp-server {
        shared-network-name OFFICE {
            subnet 192.168.10.0/24 {
                option {
                    default-router 192.168.10.1
                    name-server 192.168.10.1
                }
                range clients {
                    start 192.168.10.100
                    stop 192.168.10.200
                }
                subnet-id 10
            }
        }
        shared-network-name GUEST {
            subnet 192.168.30.0/24 {
                option {
                    default-router 192.168.30.1
                    name-server 192.168.30.1
                }
                range clients {
                    start 192.168.30.100
                    stop 192.168.30.200
                }
                subnet-id 30
            }
        }
        shared-network-name MANAGEMENT {
            subnet 192.168.40.0/24 {
                option {
                    default-router 192.168.40.1
                    name-server 192.168.40.1
                }
                range clients {
                    start 192.168.40.100
                    stop 192.168.40.150
                }
                subnet-id 40
            }
        }
    }
    dns {
        forwarding {
            allow-from 192.168.10.0/24
            allow-from 192.168.20.0/24
            allow-from 192.168.30.0/24
            allow-from 192.168.40.0/24
            listen-address 192.168.10.1
            listen-address 192.168.20.1
            listen-address 192.168.30.1
            listen-address 192.168.40.1
            system
        }
    }
}

system { host-name router01 }
