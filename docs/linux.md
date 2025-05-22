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

## Make file executable

```bash
chmod +x "$FILE"
```

only for the owner:

```bash
chmod u+x "$FILE"
```

## Make file non-executable

```bash
chmod -x "$FILE"
```

## SSH

### Remove IP from know_hosts

```bash
ssh-keygen -f "/root/.ssh/known_hosts" -R "XXX.XXX.XXX.XXX"
```

## Automatically restart system every day at 2:30 AM

```bash
sudo crontab -e
```

```bash
30 2 * * * /sbin/shutdown -r now
```

## Echo with multiple lines

```bash
echo -e "line1\nline2"
```

or

```bash
cat <<EOF
line1
line2 with $VARIABLE
EOF
```

or cat without variable substitution:

```bash
cat <<'EOF'
line1
line2 with $VARIABLE
EOF
```

## Resize partition without losing data

```bash
sudo vgdisplay
sudo lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
sudo resize2fs /dev/ubuntu-vg/ubuntu-lv
```
## Check disk space

```bash
df -h
```
