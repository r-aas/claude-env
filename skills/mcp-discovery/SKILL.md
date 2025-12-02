---
name: mcp-discovery
description: Find, evaluate, and install MCP servers for Claude Code integration. Use when interacting with external systems (Jira, Confluence, Slack, databases, etc.) more than 2-3 times, or when user asks about MCP servers for a specific tool.
triggers:
  - "mcp server for"
  - "integrate with"
  - "connect to jira"
  - "connect to confluence"
  - "connect to slack"
  - "access * from claude"
  - "is there an mcp for"
---

# MCP Discovery & Setup

Find the best MCP servers on GitHub and configure them for Claude Code.

## When to Trigger This Skill

Proactively suggest MCP integration when:
- User interacts with same external system 3+ times in a session
- User asks about connecting Claude to external tools
- User manually copies data from external systems
- User asks "is there an MCP for X?"

## Discovery Workflow

### 1. Search GitHub for MCP Servers

```bash
# Search for MCP servers for a specific tool
gh search repos "mcp server <tool>" --sort=stars --limit=20

# Check the awesome-mcp-servers list
gh api repos/punkpeye/awesome-mcp-servers/contents/README.md | jq -r '.content' | base64 -d

# Search with specific patterns
gh search repos "mcp-server-<tool>" --sort=stars
gh search repos "<tool> mcp" --sort=stars
```

### 2. Evaluate MCP Servers

**Quality Criteria (in order of importance):**

| Criteria | Check |
|----------|-------|
| Stars | >100 preferred, >500 excellent |
| Recent activity | Commits in last 3 months |
| Maintenance | Issues responded to, PRs merged |
| Documentation | Clear README with setup instructions |
| Auth method | OAuth preferred over API keys |
| TypeScript/Python | Matches user's stack |

**Red Flags:**
- No commits in 6+ months
- No documentation
- Hardcoded credentials in examples
- No error handling
- Missing license

### 3. Top MCP Server Sources

**Curated Lists:**
- [awesome-mcp-servers](https://github.com/punkpeye/awesome-mcp-servers) - Community curated
- [modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers) - Official examples

**Common Integrations:**

| Tool | Recommended Server | Notes |
|------|-------------------|-------|
| Jira | `mcp-server-atlassian` | Covers Jira + Confluence |
| Confluence | `mcp-server-atlassian` | Same as Jira |
| Slack | `mcp-server-slack` | Official |
| GitHub | `mcp-server-github` | Official |
| PostgreSQL | `mcp-server-postgres` | Official |
| Filesystem | `mcp-server-filesystem` | Official |
| Git | `mcp-server-git` | Official |
| Google Drive | `mcp-server-gdrive` | OAuth setup required |
| Linear | `mcp-server-linear` | Issue tracking |
| Notion | `mcp-server-notion` | Note-taking |

## Installation Workflow

### 1. Choose Install Method

**NPX (recommended for Node servers):**
```json
{
  "mcpServers": {
    "<name>": {
      "command": "npx",
      "args": ["-y", "<package-name>"],
      "env": {
        "API_KEY": "${<NAME>_API_KEY}"
      }
    }
  }
}
```

**UVX (for Python servers):**
```json
{
  "mcpServers": {
    "<name>": {
      "command": "uvx",
      "args": ["<package-name>"],
      "env": {
        "API_KEY": "${<NAME>_API_KEY}"
      }
    }
  }
}
```

**Docker (for complex dependencies):**
```json
{
  "mcpServers": {
    "<name>": {
      "command": "docker",
      "args": ["run", "-i", "--rm", "<image>"],
      "env": {}
    }
  }
}
```

### 2. Configure Claude Code

**Config file location:** `~/.claude/claude_desktop_config.json`

```bash
# Check if config exists
cat ~/.claude/claude_desktop_config.json 2>/dev/null || echo "{}"

# Edit config
code ~/.claude/claude_desktop_config.json
```

**Config structure:**
```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "package-name"],
      "env": {
        "API_KEY": "your-key-here"
      }
    }
  }
}
```

### 3. Handle Credentials

**Priority order:**
1. Environment variables (best)
2. Credential manager / keychain
3. `.env` file (gitignored)
4. Config file (least preferred)

**Environment variable pattern:**
```bash
# Add to ~/.zshrc or ~/.bashrc
export JIRA_API_TOKEN="your-token"
export CONFLUENCE_API_TOKEN="your-token"
export SLACK_BOT_TOKEN="xoxb-..."
```

**Reference in config:**
```json
{
  "env": {
    "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
  }
}
```

## Testing MCP Servers

### 1. Verify Server Starts

```bash
# Test npx server directly
npx -y <package-name> --help

# Test uvx server
uvx <package-name> --help
```

### 2. Test in Claude Code

After adding to config:
1. Restart Claude Code
2. Ask: "What MCP tools do you have access to?"
3. Try a simple operation: "List my Jira projects"

### 3. Debug Connection Issues

```bash
# Check if server is in config
cat ~/.claude/claude_desktop_config.json | jq '.mcpServers'

# Test environment variables
echo $JIRA_API_TOKEN

# Run server manually to see errors
npx -y <package-name> 2>&1
```

## Common Setup Examples

### Jira/Confluence (Atlassian)

```bash
# Get API token: https://id.atlassian.com/manage-profile/security/api-tokens
export ATLASSIAN_API_TOKEN="your-token"
export ATLASSIAN_EMAIL="your-email@company.com"
export ATLASSIAN_DOMAIN="yourcompany.atlassian.net"
```

```json
{
  "mcpServers": {
    "atlassian": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-atlassian"],
      "env": {
        "ATLASSIAN_API_TOKEN": "${ATLASSIAN_API_TOKEN}",
        "ATLASSIAN_EMAIL": "${ATLASSIAN_EMAIL}",
        "ATLASSIAN_DOMAIN": "${ATLASSIAN_DOMAIN}"
      }
    }
  }
}
```

### Slack

```bash
# Create Slack app: https://api.slack.com/apps
# Add Bot Token Scopes: channels:history, channels:read, chat:write, users:read
export SLACK_BOT_TOKEN="xoxb-..."
```

```json
{
  "mcpServers": {
    "slack": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-slack"],
      "env": {
        "SLACK_BOT_TOKEN": "${SLACK_BOT_TOKEN}"
      }
    }
  }
}
```

### PostgreSQL

```json
{
  "mcpServers": {
    "postgres": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-postgres", "postgresql://user:pass@localhost:5432/db"]
    }
  }
}
```

### GitHub

```bash
export GITHUB_TOKEN="ghp_..."
```

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

## Proactive Suggestions

When you notice the user doing these things repeatedly, suggest MCP:

| User Action | Suggest |
|-------------|---------|
| Pasting Jira ticket content | "I can connect directly to Jira with an MCP server" |
| Copying Confluence docs | "Want me to set up Confluence MCP access?" |
| Describing Slack messages | "I could read Slack directly with MCP" |
| Running SQL queries manually | "I can query the database directly with postgres MCP" |
| Fetching GitHub issues/PRs | "GitHub MCP would let me access this directly" |

## Updating MCP Servers

```bash
# NPX always fetches latest
# For pinned versions, update the package name:
"args": ["-y", "package-name@latest"]

# Or specific version:
"args": ["-y", "package-name@1.2.3"]
```

## Security Checklist

Before installing any MCP server:
- [ ] Review the source code (at least README and main files)
- [ ] Check it doesn't send data to unexpected endpoints
- [ ] Use minimal required permissions/scopes
- [ ] Store credentials in environment variables, not config files
- [ ] Don't commit credentials to git
