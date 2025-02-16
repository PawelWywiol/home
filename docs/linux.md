# Linux (basics)

## File synchronization

```bash
rsync -avP --no-perms --no-owner --no-group "$SRC_PATH_WITH_SLASH" "$DEST_PATH_WITHOUT_SLASH"
```

## File synchronization (update only and -L for symlinks)

```bash
rsync -avPL --no-perms --no-owner --no-group "$SSH_HOST":~ "$DEST_PATH_WITHOUT_SLASH"
```

```bash
rsync -avPL --no-perms --no-owner --no-group --update -e ssh "$DOTFILES_DIR" "$SSH_HOST":~
```

## File permissions (recursively)

```bash
find "$SRC_PATH_WITHOUT_SLASH" -type f -exec chmod 644 {} \;
find "$SRC_PATH_WITHOUT_SLASH" -type d -exec chmod 755 {} \;
```

## Sorted file/directory sizes

```bash
du -sh "$SRC_PATH_WITHOUT_SLASH/*" | sort -rh
```
