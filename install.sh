#!/bin/bash
# Claude Env - Install Script
# Usage: curl -fsSL https://raw.githubusercontent.com/r-aas/claude-env/main/install.sh | bash

set -e

UPSTREAM_REPO="r-aas/claude-env"
INSTALL_DIR="$HOME/.claude"
BACKUP_DIR="$HOME/.claude-backup-$(date +%Y%m%d-%H%M%S)"

# ─────────────────────────────────────────────────────────────────────────────
# Dependency checks
# ─────────────────────────────────────────────────────────────────────────────

check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Error: $1 is required but not installed."
        echo ""
        case "$1" in
            git)
                echo "Install git:"
                echo "  macOS:  brew install git"
                echo "  Ubuntu: sudo apt install git"
                echo "  Windows: https://git-scm.com/downloads"
                ;;
            gh)
                echo "Install GitHub CLI:"
                echo "  macOS:  brew install gh"
                echo "  Ubuntu: https://github.com/cli/cli/blob/trunk/docs/install_linux.md"
                echo "  Windows: winget install GitHub.cli"
                echo ""
                echo "Then authenticate: gh auth login"
                ;;
        esac
        exit 1
    fi
}

check_gh_auth() {
    if ! gh auth status &> /dev/null; then
        echo "Error: GitHub CLI not authenticated."
        echo ""
        echo "Run: gh auth login"
        exit 1
    fi
}

echo "Checking dependencies..."
check_command git
check_command gh
check_gh_auth
echo "Dependencies OK."
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# Get user's fork URL (fork if needed)
# ─────────────────────────────────────────────────────────────────────────────

get_fork_url() {
    local username
    username=$(gh api user --jq '.login')

    # Check if user already has a fork
    if gh repo view "$username/claude-env" &> /dev/null; then
        echo "https://github.com/$username/claude-env.git"
    else
        echo "Forking $UPSTREAM_REPO to your account..."
        gh repo fork "$UPSTREAM_REPO" --clone=false
        echo "https://github.com/$username/claude-env.git"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Install
# ─────────────────────────────────────────────────────────────────────────────

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

    # Get fork URL (creates fork if needed)
    REPO_URL=$(get_fork_url)
    echo "Using repo: $REPO_URL"

    if [ -d "$INSTALL_DIR" ]; then
        # Move existing files to backup
        mkdir -p "$BACKUP_DIR"
        mv "$INSTALL_DIR"/* "$BACKUP_DIR/" 2>/dev/null || true
        mv "$INSTALL_DIR"/.[!.]* "$BACKUP_DIR/" 2>/dev/null || true
    fi

    git clone "$REPO_URL" "$INSTALL_DIR"

    # Add upstream remote for pulling updates
    cd "$INSTALL_DIR"
    git remote add upstream "https://github.com/$UPSTREAM_REPO.git" 2>/dev/null || true
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
