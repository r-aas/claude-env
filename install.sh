#!/bin/bash
# Claude Env - Install Script
# Usage: curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-env/main/install.sh | bash

set -e

REPO_URL="${CLAUDE_ENV_REPO:-https://github.com/YOUR_USERNAME/claude-env.git}"
INSTALL_DIR="$HOME/.claude"
BACKUP_DIR="$HOME/.claude-backup-$(date +%Y%m%d-%H%M%S)"

echo "Installing Claude Env..."

# Backup existing private skills if they exist
if [ -d "$INSTALL_DIR/skills" ]; then
    PRIVATE_SKILLS=$(find "$INSTALL_DIR/skills" -maxdepth 1 -type d -name "private-*" 2>/dev/null || true)
    if [ -n "$PRIVATE_SKILLS" ]; then
        echo "Backing up private skills..."
        mkdir -p "$BACKUP_DIR/skills"
        for skill in $PRIVATE_SKILLS; do
            cp -r "$skill" "$BACKUP_DIR/skills/"
        done
    fi
fi

# Clone or update repo
if [ -d "$INSTALL_DIR/.git" ]; then
    echo "Updating existing installation..."
    cd "$INSTALL_DIR"
    git pull --rebase origin main
else
    echo "Fresh install..."
    if [ -d "$INSTALL_DIR" ]; then
        # Move existing files to backup
        mkdir -p "$BACKUP_DIR"
        mv "$INSTALL_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true
        mv "$INSTALL_DIR"/.[!.]* "$BACKUP_DIR/" 2>/dev/null || true
    fi
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

# Restore private skills from backup
if [ -d "$BACKUP_DIR/skills" ]; then
    echo "Restoring private skills..."
    for skill in "$BACKUP_DIR/skills"/private-*; do
        if [ -d "$skill" ]; then
            skill_name=$(basename "$skill")
            if [ ! -d "$INSTALL_DIR/skills/$skill_name" ]; then
                cp -r "$skill" "$INSTALL_DIR/skills/"
                echo "  Restored: $skill_name"
            fi
        fi
    done
fi

# Make scripts executable
chmod +x "$INSTALL_DIR/install.sh" 2>/dev/null || true
chmod +x "$INSTALL_DIR/update.sh" 2>/dev/null || true

echo ""
echo "Done! Claude Env installed to $INSTALL_DIR"
echo ""
echo "To update later, run:"
echo "  ~/.claude/update.sh"
