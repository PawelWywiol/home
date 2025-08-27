# Homelab

## Sync files from/to the server to/from the local machine

Edit `pve/xXXX/.envrc` file. Add required file paths to the `SYNC_FILES` array.

```env
SYNC_FILES=(
  ".env"
  "docker/config"
  "Makefile"
)
```

Sync files from the server to the local machine:

```bash
./scripts/sync-files.sh user@host ./pve/PATH_TO_DIR
```

Sync files from the local machine to the server:

```bash
./scripts/sync-files.sh ./pve/PATH_TO_DIR user@host
```
