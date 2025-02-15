# Linux (basics)

## File synchronization

```bash
rsync -avP --no-perms --no-owner --no-group "$SRC_PATH_WITH_SLASH" "$DEST_PATH_WITHOUT_SLASH"
```

```bash
rsync -avP --no-perms --no-owner --no-group "$SSH_HOST":~ "$DEST_PATH_WITHOUT_SLASH"
```

```bash
rsync -avPL --no-perms --no-owner --no-group --update -e ssh "$DOTFILES_DIR" "$SSH_HOST":~
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
