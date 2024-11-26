#!/bin/bash

# Load variables from .env file
source /root/tunnel.env

# Default values in case variables are missing in .env
WG_INTERFACE="${WG_INTERFACE:-wg0}"                  # WireGuard interface
VM_INTERFACE="${VM_INTERFACE:-eth1}"                # Network interface for VPN sharing
VPN_DNS="${VPN_DNS:-162.252.172.57,149.154.159.92}" # DNS servers from VPN provider
DHCP_RANGE="${DHCP_RANGE:-192.168.10.100,192.168.10.200}" # DHCP range
VM_IP="${VM_IP:-192.168.10.1}"                      # IP address for VM_INTERFACE
VM_NETMASK="${VM_NETMASK:-255.255.255.0}"           # Netmask for VM_INTERFACE
WG_ADDRESS="${WG_ADDRESS:-10.14.0.2/16}"           # WireGuard interface IP
WG_PRIVATE_KEY="${WG_PRIVATE_KEY:-}"               # WireGuard private key
WG_PEER_PUBLIC_KEY="${WG_PEER_PUBLIC_KEY:-}"       # WireGuard peer public key
WG_PEER_ENDPOINT="${WG_PEER_ENDPOINT:-}"           # WireGuard peer endpoint
WG_PEER_ALLOWED_IPS="${WG_PEER_ALLOWED_IPS:-0.0.0.0/0}" # WireGuard peer allowed IPs

# Update system and install necessary packages
apt update && apt upgrade -y
apt install -y curl wireguard iptables-persistent dnsmasq resolvconf

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" > /etc/sysctl.d/99-ip-forward.conf
sysctl --system

# Prepare DNS settings for dnsmasq
DNS_LINES=""
IFS=',' read -ra DNS_ARRAY <<< "$VPN_DNS"
for DNS in "${DNS_ARRAY[@]}"; do
    DNS_LINES+="server=$DNS"$'\n'
done

# Configure dnsmasq
cat > /etc/dnsmasq.conf <<EOF
interface=$VM_INTERFACE
dhcp-range=$DHCP_RANGE,$VM_NETMASK,24h
$DNS_LINES
EOF

# Configure network interface
cat > /etc/network/interfaces.d/$VM_INTERFACE <<EOF
auto $VM_INTERFACE
iface $VM_INTERFACE inet static
    address $VM_IP
    netmask $VM_NETMASK
EOF

# Configure WireGuard
cat > /etc/wireguard/$WG_INTERFACE.conf <<EOF
[Interface]
PrivateKey = $WG_PRIVATE_KEY
Address = $WG_ADDRESS
PostUp = iptables -t nat -A POSTROUTING -o $WG_INTERFACE -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -o $WG_INTERFACE -j MASQUERADE

[Peer]
PublicKey = $WG_PEER_PUBLIC_KEY
Endpoint = $WG_PEER_ENDPOINT
AllowedIPs = $WG_PEER_ALLOWED_IPS
EOF

chmod 600 /etc/wireguard/$WG_INTERFACE.conf

# Restart dnsmasq service
systemctl restart dnsmasq || {
    echo "Failed to restart dnsmasq. Check /etc/dnsmasq.conf for errors."
    exit 1
}

# Add NAT rules for iptables
iptables -t nat -A POSTROUTING -o $WG_INTERFACE -j MASQUERADE
iptables -A FORWARD -i $VM_INTERFACE -o $WG_INTERFACE -j ACCEPT
iptables -A FORWARD -i $WG_INTERFACE -o $VM_INTERFACE -j ACCEPT

# Enable and start WireGuard service
systemctl enable wg-quick@$WG_INTERFACE
systemctl start wg-quick@$WG_INTERFACE || {
    echo "Failed to start WireGuard. Check /etc/wireguard/$WG_INTERFACE.conf for errors."
    exit 1
}

# Set up vpn-watchdog script
cat > /usr/local/bin/vpn-watchdog.sh <<EOF
#!/bin/bash

# Check WireGuard status
if ! wg show $WG_INTERFACE > /dev/null 2>&1; then
    echo "WireGuard disconnected. Restarting container."
    systemctl restart wg-quick@$WG_INTERFACE
    if ! wg show $WG_INTERFACE > /dev/null 2>&1; then
        echo "WireGuard failed to reconnect. Restarting container."
        reboot
    fi
fi
EOF

chmod +x /usr/local/bin/vpn-watchdog.sh

# Add vpn-watchdog to cron for periodic checks
cat > /etc/cron.d/vpn-watchdog <<EOF
* * * * * root /usr/local/bin/vpn-watchdog.sh
EOF

# Post-installation tests
# echo "=== Testing configuration ==="
# systemctl status wg-quick@$WG_INTERFACE
# systemctl status dnsmasq

ip route add default via $WG_GATEWAY dev $VM_INTERFACE

# wg show $WG_INTERFACE

echo "Configuration complete!"
