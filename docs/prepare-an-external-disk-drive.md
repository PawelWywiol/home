# Prepare an external disk drive

1. Unmount the disk

```bash
umount /dev/sdXX
```

2. Wipe the disk (e.g. using proxmox > Disks > Wipe)
3. Create a new partition table

```bash
fdisk /dev/sdXX
```

4. Create a new partition

```bash
mkfs.ext4 /dev/sdXX
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