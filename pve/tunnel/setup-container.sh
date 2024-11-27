#!/bin/bash

# Setup lxc container for VPN sharing
# Edit container config file:
# ```bash
# nano /etc/pve/lxc/110.conf
# ```
# Add the following lines:
# ```bash
# lxc.cgroup.devices.allow: c 10:200 rwm
# lxc.mount.entry: /dev/net dev/net none bind,create=dir
# ```
# Change /dev/net ownership:
# ```bash
# chown 100000:100000 /dev/net/tun
# ```
# Then restart the container:
# ```bash
# PCT start 110
# ```

# Load variables from .env file
source /root/.env

DEFAULT_INTERFACE=$(ip route | grep default | awk '{print $5}')

# Default values in case variables are missing in .env
VM_INTERFACE="${VM_INTERFACE:-$DEFAULT_INTERFACE}"         # Network interface for VPN sharing
VM_BASE_NETWORK_IP="${VM_BASE_NETWORK_IP:-192.168.0.0/24}" # Network IP address
WG_DNS="${WG_DNS:-162.252.172.57,149.154.159.92}"          # DNS servers from VPN provider
WG_INTERFACE="${WG_INTERFACE:-wg0}"                        # WireGuard interface
WG_ADDRESS="${WG_ADDRESS:-10.14.0.2/16}"                   # WireGuard interface IP
WG_PRIVATE_KEY="${WG_PRIVATE_KEY:-}"                       # WireGuard private key
WG_PEER_PUBLIC_KEY="${WG_PEER_PUBLIC_KEY:-}"               # WireGuard peer public key
WG_PEER_ENDPOINT="${WG_PEER_ENDPOINT:-}"                   # WireGuard peer endpoint
WG_PEER_ENDPOINT_PORT="${WG_PEER_ENDPOINT_PORT:-51820}"    # WireGuard peer endpoint port
WG_PEER_ALLOWED_IPS="${WG_PEER_ALLOWED_IPS:-0.0.0.0/0}"    # WireGuard peer allowed IPs

# Update system and install necessary packages
apt update && apt upgrade -y
apt install -y curl wireguard iptables iptables-persistent

apt install -y resolvconf

echo nameserver 1.1.1.1 > /etc/resolv.conf
# Prepare DNS settings for resolvconf
# dpkg-reconfigure resolvconf

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >/etc/sysctl.d/99-ip-forward.conf
sysctl -p /etc/sysctl.d/99-ip-forward.conf

# Configure WireGuard
cat > /etc/wireguard/$WG_INTERFACE.conf <<EOF
[Interface]
PrivateKey = $WG_PRIVATE_KEY
Address = $WG_ADDRESS
DNS = $WG_DNS
PostUp = iptables -t nat -A POSTROUTING -o $WG_INTERFACE -j MASQUERADE
PostDown = iptables -t nat -D POSTROUTING -o $WG_INTERFACE -j MASQUERADE

[Peer]
PublicKey = $WG_PEER_PUBLIC_KEY
Endpoint = $WG_PEER_ENDPOINT
AllowedIPs = $WG_PEER_ALLOWED_IPS
PersistentKeepalive = 25
EOF

chmod 600 /etc/wireguard/$WG_INTERFACE.conf

# Add NAT rules for iptables
iptables -t nat -A POSTROUTING -o $WG_INTERFACE -j MASQUERADE
iptables -A FORWARD -i $VM_INTERFACE -o $WG_INTERFACE -j ACCEPT
iptables -A FORWARD -i $WG_INTERFACE -o $VM_INTERFACE -j ACCEPT

# Save iptables rules
iptables-save >/etc/iptables/rules.v4

# Enable and start WireGuard service
systemctl enable wg-quick@$WG_INTERFACE
systemctl start wg-quick@$WG_INTERFACE || {
    echo "Failed to start WireGuard. Check /etc/wireguard/$WG_INTERFACE.conf for errors."
    exit 1
}

# Set up vpn-watchdog script
cat > /etc/wireguard/vpn-watchdog.sh <<EOF
#!/bin/bash

# Check WireGuard status
if ! wg show $WG_INTERFACE > /dev/null 2>&1; then
    echo "WireGuard disconnected. Restarting wg."
    systemctl restart wg-quick@$WG_INTERFACE
    if ! wg show $WG_INTERFACE > /dev/null 2>&1; then
        echo "WireGuard failed to reconnect. Restarting container."
        reboot
    fi
fi
EOF

chmod +x /etc/wireguard/vpn-watchdog.sh

# Add vpn-watchdog to cron for periodic checks
cat > /etc/cron.d/vpn-watchdog <<EOF
* * * * * root /etc/wireguard/vpn-watchdog.sh
EOF

echo "Configuration complete!"
