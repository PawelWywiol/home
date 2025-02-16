#!/bin/bash

set -e

remove_last_slash() {
  local path="$1"
  [[ "$path" == */ ]] && echo "${path%/}" || echo "$path"
}

SRC=$1
DEST=$2

if [ -z "$SRC" ] || [ -z "$DEST" ]; then
  echo "Użycie: $0 src_path dest_path"
  exit 1
fi

SRC=$(remove_last_slash "$SRC")
DEST=$(remove_last_slash "$DEST")

SRC_IS_REMOTE=false
DEST_IS_REMOTE=false

[[ "$SRC" == *"@"* ]] && SRC_IS_REMOTE=true
[[ "$DEST" == *"@"* ]] && DEST_IS_REMOTE=true

if [ "$SRC_IS_REMOTE" = false ] && [ -f "$SRC/.envrc" ]; then
  source "$SRC/.envrc"
  echo ".envrc loaded from $SRC"
elif [ "$DEST_IS_REMOTE" = false ] && [ -f "$DEST/.envrc" ]; then
  source "$DEST/.envrc"
  echo ".envrc loaded from $DEST"
else
  echo "[ERROR]: .envrc not found in $SRC or $DEST"
  exit 1
fi

if [ -z "${SYNC_FILES[*]}" ]; then
  echo "[ERROR]: SYNC_FILES is empty"
  exit 1
fi

for item in "${SYNC_FILES[@]}"; do
  src_file="$SRC/$item"
  dest_file="$DEST/"

  if [ "$SRC_IS_REMOTE" = true ]; then
    rsync -avPL --no-perms --no-owner --no-group --update "$SRC:$item" "$DEST/"
  elif [ "$DEST_IS_REMOTE" = true ]; then
    rsync -avPL --no-perms --no-owner --no-group --update "$src_file" "$DEST:"
  else
    rsync -avPL --no-perms --no-owner --no-group --update "$src_file" "$dest_file"
  fi

  echo "✅ synchronized $src_file to $dest_file"
done

echo "✅ done"
