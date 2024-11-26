# VPN Tunnel for Proxmox LXC Containers

## Sources

https://www.youtube.com/watch?v=vBCrWs5bFsA&t=355s
https://drive.google.com/file/d/1C1o0Ob0QbFCFmcdD5OckuniCRt6wem9d/view

## Instructions

### PVE

VPN Gateway w/ Kill Switch. Instructions for Ubuntu 20.04 Server

IN the shell of the proxmox host got to

```bash
nano /etc/pve/lxc/110.conf
```

EDIT THE XXX.conf files and add line the following line at the end

#### Proxmox 7+

```
lxc.cgroup.devices.allow: c 10:200 rwm
lxc.mount.entry: /dev/net dev/net none bind,create=dir
```

Control x to save

run this command

```bash
chown 100000:100000 /dev/net/tun
```

check that it worked

```bash
ls -l /dev/net/tun
```

output should be something like this

```bash
crw-rw-rw- 1 100000 100000 10, 200 Dec 22 13:26 /dev/net/tun
```

reboot the container

### Container

#### Install Programs

```bash
apt-get update

apt install curl wireguard openresolv -y
apt install iptables iptables-persistent -y

apt-get upgrade -y
apt-get autoremove -y
```

####  Wireguard

```bash
wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey
```

#### Update config

```bash
nano /etc/wireguard/wg0.conf
```

replace `ens3` with the name of your network interface

```bash
ip -o -4 route show to default | awk '{print $5}'
```

```bash
[Interface]
Address = 10.0.0.1/24
SaveConfig = true
ListenPort = 51820
PrivateKey = SERVER_PRIVATE_KEY

# PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ens3 -j MASQUERADE
# PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ens3 -j MASQUERADE

# PostUp  =  iptables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -I OUTPUT ! -o %i -m mark ! --mark $(wg show %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
# PreDown = iptables -D OUTPUT ! -o %i -m mark ! --mark $(wg show  %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT && ip6tables -D OUTPUT ! -o %i -m mark ! --mark $(wg show  %i fwmark) -m addrtype ! --dst-type LOCAL -j REJECT
```

#### Make config files readable only by root

```bash
chmod 600 /etc/wireguard/{privatekey,wg0.conf}
```

#### Start Wireguard

```bash
wg-quick up wg0
```

#### Check Wireguard

```bash
curl ipinfo.io/ip
```

```bash
wg show wg0
```

```bash
ip a show wg0
```

#### Make Wireguard start on boot

```bash
systemctl enable wg-quick@wg0
```

#### Allow IPforwarding

```bash
nano /etc/sysctl.conf
```

Change

```bash
# Uncomment the next line to enable packet forwarding for IPv4

net.ipv4.ip_forward=1
```

```bash
sysctl -p
```

#### Create the iptables script

```bash
nano /etc/wireguard/iptables.sh
```

```bash
#!/bin/bash
# Flush
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X

# Block All
iptables -P OUTPUT DROP
iptables -P INPUT DROP
iptables -P FORWARD DROP

# allow Localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Make sure you can communicate with any DHCP server
iptables -A OUTPUT -d 255.255.255.255 -j ACCEPT
iptables -A INPUT -s 255.255.255.255 -j ACCEPT

# Make sure that you can communicate within your own network
# Replace 192.168.0. with your IP range
iptables -A INPUT -s 192.168.0.0/24 -d 192.168.0.0/24 -j ACCEPT
iptables -A OUTPUT -s 192.168.0.0/24 -d 192.168.0.0/24 -j ACCEPT

# Allow established sessions to receive traffic:
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow TUN
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A FORWARD -i tun+ -j ACCEPT
iptables -A FORWARD -o tun+ -j ACCEPT
iptables -t nat -A POSTROUTING -o tun+ -j MASQUERADE
iptables -A OUTPUT -o tun+ -j ACCEPT

# allow VPN connection to server (change port and protocol if needed)
iptables -I OUTPUT 1 -p udp --destination-port 51820 -m comment --comment "Allow VPN connection" -j ACCEPT

# Block All
iptables -A OUTPUT -j DROP
iptables -A INPUT -j DROP
iptables -A FORWARD -j DROP

# Log all dropped packages, debug only.

iptables -N logging
iptables -A INPUT -j logging
iptables -A OUTPUT -j logging
iptables -A logging -m limit --limit 2/min -j LOG --log-prefix "IPTables general: " --log-level 7
iptables -A logging -j DROP

echo "saving"
iptables-save > /etc/iptables.rules
echo "done"

# optional: watch iptables in realtime
#echo 'wireguard - Rules successfully applied, we start "watch" to verify IPtables in realtime (you can cancel it as usual CTRL + c)'
#sleep 3
#watch -n 0 "sudo iptables -nvL"
```

#### Create the start up script

```bash
nano /usr/local/sbin/startup.sh
```

```bash
#!/bin/sh

bash /etc/wireguard/iptables.sh &
sleep 5
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"
bash /etc/wireguard/connect.sh
```

Make script executable

```bash
chmod +x /usr/local/sbin/startup.sh
```

#### Create systemd unit file

```bash
nano /etc/systemd/system/startup.service
```

```bash
[Unit]
Description=Startup

[Service]
ExecStart=/usr/local/sbin/startup.sh

[Install]
WantedBy=default.target
```

Enable service

```bash
systemctl enable startup.service
```

check that it has been enabled

```bash
systemctl status startup.service
```

Disable service

```bash
systemctl disable startup.service
```

## Optional speed test

https://www.speedtest.net/apps/cli

```bash
sudo apt-get install curl
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest
speedtest
```