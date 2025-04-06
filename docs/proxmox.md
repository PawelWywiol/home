# Proxmox

## Add mount points

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

or

```bash
pct set 110 -mp0 volume=/mnt/source/path,mp=/mnt/destination/path
```

## Fix corrupted file system

e.g. after power failure

```bash
-????????? ? ? ? ?  ? 19.bak
```

```bash
unmount /dev/sdXY
fsck.ext4 -y /dev/sdXY
mount /dev/sdXY
```

or

```bash
pct stop 110
pct fsck 110
pct start 110
```

## Prepare an external disk drive

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

## Create debian cloud-init template

```bash
wget https://cdimage.debian.org/images/cloud/bullseye/latest/debian-11-generic-amd64.raw
qm create 5001 --name debian-cloud --net0 virtio,bridge=vmbr0 --scsihw virtio-scsi-pci --machine q35
qm set 5001 --scsi0 local-zfs:0,discard=on,ssd=1,format=raw,import-from=/root/debian-11-generic-amd64.raw
qm disk resize 5001 scsi0 8G
qm set 5001 --boot order=scsi0
qm set 5001 --cpu host --cores 2 --memory 4096
qm set 5001 --bios ovmf --efidisk0 local-zfs:1,format=raw,efitype=4m,pre-enrolled-keys=1
qm set 5001 --ide2 local-zfs:cloudinit
qm set 5001 --agent enabled=1

# custimiz cloud-init settings

qm template 5001
```

```bash
# make a full clone

sudo apt update
sudo apt install -y qemu-guest-agent
sudo reboot
```
