# Fix file system corruption

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