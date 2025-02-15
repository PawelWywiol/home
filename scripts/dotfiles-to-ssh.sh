#!/bin/bash

# Dotfiles source directory
DOTFILES_DIR="./dotfiles/"

# ssh@host from first argument
SSH_HOST="$1"

# Check if $SSH_HOST is provided
if [ -z "$SSH_HOST" ]; then
  echo "usage: $PWD ssh@host"
  exit 1
fi

# rsync dotfiles to remote host
rsync -avPL --no-perms --no-owner --no-group --update -e ssh "$DOTFILES_DIR" "$SSH_HOST":~
