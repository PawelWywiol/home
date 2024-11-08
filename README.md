# Home

## Prepare an external disk

1. Unmount the disk

```bash
umount /dev/sdX
```

2. Wipe the disk (e.g. using proxmox > Disks > Wipe)
3. Create a new partition table

```bash
fdisk /dev/sdX
```

4. Create a new partition

```bash
mkfs.ext4 /dev/sdX1
```

5. Get partitions UUID

```bash
blkid -o list
```

6. Make directory for the disk

```bash
mkdir /home/backups
```

7. Add the disk to /etc/fstab

```bash
nano /etc/fstab
```

```
/dev/disk/by-uuid/XXX-UUID-HERE /home/backups ext4 defaults 0
```

8. Mount the disk

```bash
mount -a
systemctl daemon-reload
```

9. Check if the disk is mounted

```bash
df -h
```

10. Add proxmox directory

```
Datacenter > Storage > Add > Directory > /home/backups
```

11. Add backup job

```
Datacenter > Backup > Add > Backup > VM > Storage: /home/backups
```

## Mount points

### To VM

```bash
blkid -o list

qm set 109 -sata1 /dev/disk/by-uuid/XXX-UUID-HERE
```

### To LXC

```bash
nano /etc/pve/lxc/XXX.conf

mp0: /mnt/source/path,mp=/mnt/destination/path
```