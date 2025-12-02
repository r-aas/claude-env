#!/bin/bash
# Claude Env - Update Script
# Usage: ~/.claude/update.sh [--upstream]
#
# By default, pulls from your fork (origin).
# Use --upstream to pull latest from r-aas/claude-env.

set -e

INSTALL_DIR="$HOME/.claude"

if [ ! -d "$INSTALL_DIR/.git" ]; then
    echo "Error: Not a git repository. Run install.sh first."
    exit 1
fi

cd "$INSTALL_DIR"

# Stash any local changes
git stash -q 2>/dev/null || true

if [ "$1" = "--upstream" ]; then
    echo "Pulling latest from upstream (r-aas/claude-env)..."

    # Ensure upstream remote exists
    if ! git remote get-url upstream &> /dev/null; then
        git remote add upstream "https://github.com/r-aas/claude-env.git"
    fi

    git fetch upstream
    git rebase upstream/main

    echo ""
    echo "Merged upstream changes. Push to your fork with:"
    echo "  cd ~/.claude && git push origin main"
else
    echo "Pulling latest from your fork..."
    git pull --rebase origin main
fi

# Pop stash if there was one
git stash pop -q 2>/dev/null || true

echo ""
echo "Done! Skills updated."
