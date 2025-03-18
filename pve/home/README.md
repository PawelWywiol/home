# Pihole

## Troubleshooting

### Port 53 conflict

```bash
sudo lsof -i :53
```

```bash
sudo nano /etc/systemd/resolved.conf
```

```
DNSStubListener=no
```

```bash
sudo systemctl restart systemd-resolved
```
