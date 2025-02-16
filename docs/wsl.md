# WSL

## Install WSL

[https://learn.microsoft.com/en-us/windows/wsl/install](https://learn.microsoft.com/en-us/windows/wsl/install)

## Install Ubuntu

[https://docs.docker.com/desktop/setup/install/windows-install/](https://docs.docker.com/desktop/setup/install/windows-install/)

## Add user to docker group

```bash
sudo usermod -aG docker $USER
```

## Enable ssh on WSL

### Install ssh

```bash
sudo apt update && sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh
```

### Check ssh status

```bash
sudo systemctl status ssh
```

### Get WSL IP address

```bash
ip addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'
```

### Get Windows IP address

```PowerShell
Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "vEthernet (WSL)"
```

or

```PowerShell
ipconfig
```

or

```PowerShell
netsh interface ipv4 show addresses
```

### Open ssh port on Windows

```PowerShell
netsh interface portproxy add v4tov4 listenaddress=192.XXX.XXX.XXX listenport=22 connectaddress=172.XXX.XXX.XXX connectport=22
```

```PowerShell
New-NetFirewallRule -DisplayName "WSL SSH" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 22
```
