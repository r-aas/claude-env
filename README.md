# Claude Env

Portable skills and configuration for Claude Code.

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/claude-env/main/install.sh | bash
```

Or clone and install manually:

```bash
git clone https://github.com/YOUR_USERNAME/claude-env.git /tmp/claude-env
/tmp/claude-env/install.sh
```

## Update

```bash
~/.claude/update.sh
```

## Structure

```
~/.claude/
├── CLAUDE.md              # Global instructions
├── skills/                # Skill library
│   ├── private-*/         # Personal skills (gitignored)
│   └── */                 # Public skills (synced)
└── update.sh              # Pull latest + refresh
```

## Adding Private Skills

Prefix with `private-` to keep them local:

```bash
mkdir ~/.claude/skills/private-myskill
```

These are gitignored and won't sync between machines.

## License

MIT
