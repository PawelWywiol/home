# Add mount points

## To VM

```bash
blkid -o list

qm set 109 -sata1 /dev/disk/by-uuid/XXX-UUID-HERE
```

## To LXC

```bash
nano /etc/pve/lxc/XXX.conf

mp0: /mnt/source/path,mp=/mnt/destination/path
```

or

```bash
pct set 110 -mp0 volume=/mnt/source/path,mp=/mnt/destination/path
```