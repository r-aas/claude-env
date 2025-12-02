#!/bin/bash
# Claude Code Skills - Update Script
# Usage: ~/.claude/update.sh

set -e

INSTALL_DIR="$HOME/.claude"

if [ ! -d "$INSTALL_DIR/.git" ]; then
    echo "Error: Not a git repository. Run install.sh first."
    exit 1
fi

cd "$INSTALL_DIR"

# Stash any local changes (shouldn't be any in public skills)
git stash -q 2>/dev/null || true

# Pull latest
echo "Pulling latest skills..."
git pull --rebase origin main

# Pop stash if there was one
git stash pop -q 2>/dev/null || true

echo "Done! Skills updated."
