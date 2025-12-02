# Claude Env

Portable skills and configuration for Claude Code.

## Prerequisites

- `git` - Version control
- `gh` - GitHub CLI (authenticated via `gh auth login`)

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/r-aas/claude-env/main/install.sh | bash
```

This will:
1. Fork `r-aas/claude-env` to your GitHub account (if not already forked)
2. Clone your fork to `~/.claude`
3. Preserve any existing `private-*` skills

## Update

Pull from your fork:
```bash
~/.claude/update.sh
```

Pull latest from upstream (r-aas/claude-env):
```bash
~/.claude/update.sh --upstream
```

## Structure

```
~/.claude/
├── CLAUDE.md              # Global instructions
├── skills/                # Skill library
│   ├── private-*/         # Personal skills (gitignored)
│   └── */                 # Public skills (synced)
├── install.sh             # First-time setup
└── update.sh              # Pull latest
```

## Adding Private Skills

Prefix with `private-` to keep them local:

```bash
mkdir ~/.claude/skills/private-myskill
```

These are gitignored and won't sync between machines.

## Contributing

1. Make changes in your fork
2. Push to your fork: `cd ~/.claude && git push`
3. Open a PR to `r-aas/claude-env`

## License

MIT
