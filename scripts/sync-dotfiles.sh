#!/bin/bash

DOTFILES_PATH="$PWD/pve/dotfiles"
DOTFILES_ENVRC="$DOTFILES_PATH/.envrc"

if [ -f "$DOTFILES_ENVRC" ]; then
  source "$DOTFILES_ENVRC"
else
  echo "[ERROR]: $DOTFILES_ENVRC not found"
  exit 1
fi

if [ -z "${SYNC_FILES[*]}" ]; then
  echo "[ERROR]: SYNC_FILES is empty"
  exit 1
fi

for item in "${SYNC_FILES[@]}"; do
  file="$HOME/$item"
  if [ -e "$file" ]; then
    rsync -avPL --no-perms --no-owner --no-group "$file" "$DOTFILES_PATH"
  else
    echo "[ERROR]: $file not found"
  fi
done

