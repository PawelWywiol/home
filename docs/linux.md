# Linux (basics)

## File synchronization

```bash
rsync -avP --no-perms --no-owner --no-group /src-path-with-slash/ /dst-path-without-slash
```

## chmod for files and directories

```bash
find /mnt/retro/library/roms -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;
```

## Folder size

```bash
du -sh /src-path/* | sort -rh
```