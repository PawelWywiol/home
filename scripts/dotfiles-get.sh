#!/bin/bash

# List of dotfiles and folders to get from home directory
DOTFILES=(
  "$HOME/.p10k.zsh"
  "$HOME/.zshrc"
)

# Destination directory for dotfiles
DEST_DIR="./dotfiles/"

# Create destination directory
mkdir -p $DEST_DIR

# rsync dotfiles to destination directory
for dotfile in "${DOTFILES[@]}"; do
  if [ -e "$dotfile" ]; then
    rsync -avP --no-perms --no-owner --no-group "$dotfile" "$DEST_DIR"
  fi
done
