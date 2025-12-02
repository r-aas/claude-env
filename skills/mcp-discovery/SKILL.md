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

**IMPORTANT: Before asking the user for credentials, search for existing ones!**

#### Step 1: Check Current Environment

```bash
# Check if var is already set
echo $JIRA_API_TOKEN
echo $ATLASSIAN_API_TOKEN
echo $SLACK_BOT_TOKEN
echo $GITHUB_TOKEN
```

#### Step 2: Search Shell Config Files

```bash
# Search common shell configs for existing API keys/tokens
grep -h "API_TOKEN\|API_KEY\|_TOKEN\|_SECRET" \
  ~/.bashrc ~/.bash_profile ~/.zshrc ~/.zshenv ~/.profile 2>/dev/null | \
  grep -v "^#" | head -20

# Search for specific service
grep -ri "JIRA\|ATLASSIAN" ~/.bashrc ~/.bash_profile ~/.zshrc ~/.zshenv 2>/dev/null
grep -ri "SLACK" ~/.bashrc ~/.bash_profile ~/.zshrc ~/.zshenv 2>/dev/null
grep -ri "GITHUB" ~/.bashrc ~/.bash_profile ~/.zshrc ~/.zshenv 2>/dev/null
```

#### Step 3: Search .env Files

```bash
# Find .env files in common locations
find ~/code ~/work ~/projects ~ -maxdepth 3 -name ".env*" -type f 2>/dev/null | head -20

# Search inside found .env files for specific keys
find ~/code ~/work ~ -maxdepth 3 -name ".env*" -type f -exec grep -l "JIRA\|ATLASSIAN" {} \; 2>/dev/null
find ~/code ~/work ~ -maxdepth 3 -name ".env*" -type f -exec grep -l "SLACK" {} \; 2>/dev/null

# Read specific .env file (be careful not to expose in output)
grep "ATLASSIAN" ~/code/myproject/.env 2>/dev/null
```

#### Step 4: Check Common Credential Locations

```bash
# macOS Keychain (list, don't show values)
security find-generic-password -s "jira" 2>/dev/null && echo "Found Jira in Keychain"
security find-generic-password -s "atlassian" 2>/dev/null && echo "Found Atlassian in Keychain"

# 1Password CLI (if installed)
op item list --categories "API Credential" 2>/dev/null | grep -i jira

# Check for credential files
ls -la ~/.config/*/credentials* 2>/dev/null
ls -la ~/.aws/credentials 2>/dev/null
```

#### Step 5: If Credentials Not Found - Guide User

If no existing credentials found, tell the user exactly how to get them:

**Atlassian (Jira/Confluence):**
```
I couldn't find Atlassian credentials. Here's how to get them:

1. Go to: https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Give it a label like "Claude MCP"
4. Copy the token

Then give me:
- Your Atlassian email
- Your domain (e.g., yourcompany.atlassian.net)
- The API token you just created

I'll add these to your ~/.zshrc (or ~/.bashrc) so they persist.
```

**Slack:**
```
I couldn't find a Slack bot token. Here's how to create one:

1. Go to: https://api.slack.com/apps
2. Click "Create New App" → "From scratch"
3. Name it "Claude MCP" and select your workspace
4. Go to "OAuth & Permissions"
5. Add these Bot Token Scopes:
   - channels:history
   - channels:read
   - chat:write
   - users:read
6. Click "Install to Workspace"
7. Copy the "Bot User OAuth Token" (starts with xoxb-)

Give me the token and I'll add it to your shell config.
```

**GitHub:**
```
I couldn't find a GitHub token. Here's how to create one:

1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Give it a note like "Claude MCP"
4. Select scopes: repo, read:org, read:user
5. Generate and copy the token

Give me the token and I'll add it to your shell config.
```

#### Step 6: Add Credentials to Shell Config

Once user provides credentials:

```bash
# Detect user's shell
SHELL_CONFIG="$HOME/.zshrc"
[ -f "$HOME/.bashrc" ] && [ ! -f "$HOME/.zshrc" ] && SHELL_CONFIG="$HOME/.bashrc"

# Add credentials (append to file)
cat >> "$SHELL_CONFIG" << 'EOF'

# MCP Server Credentials (added by Claude)
export ATLASSIAN_API_TOKEN="<token>"
export ATLASSIAN_EMAIL="<email>"
export ATLASSIAN_DOMAIN="<domain>"
EOF

echo "Added to $SHELL_CONFIG - run 'source $SHELL_CONFIG' or restart terminal"
```

**Priority order for storing credentials:**
1. Environment variables in shell config (best - persists, works everywhere)
2. `.env` file in project (if project-specific)
3. Direct in MCP config (least preferred - visible in config file)

**Reference in MCP config:**
```json
{
  "env": {
    "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
  }
}
```

## Testing MCP Servers

### Important: Restart Required (But You Can Resume!)

**Claude Code must be restarted to load new MCP servers.** The config is read at startup.

**Good news:** Use `--continue` to pick up where you left off after restart:

```bash
# After adding MCP config, restart and continue conversation
claude --continue
# Or resume a specific session (interactive picker)
claude --resume
```

**Pro tip:** Install [claude-continue](https://github.com/dammyaro/claude-continue) slash commands for even smoother resumption:
- `/continue` - Analyzes git status, recent commits, TODOs to suggest next steps
- `/continue-pr` - Focuses on PR progress, feedback, CI/CD issues
- `/morning` - Daily catch-up routine with prioritized task list

**To minimize restarts:**
1. Check if server is already configured before adding
2. Batch multiple MCP server installs in one session
3. Add all servers, THEN restart once with `--continue`

```bash
# Check if server already configured (no restart needed if present)
cat ~/.claude/claude_desktop_config.json 2>/dev/null | jq -e '.mcpServers["atlassian"]' && echo "Already configured!"
```

**Alternative: Use `claude mcp` commands:**
```bash
# Add MCP server via CLI (still requires restart)
claude mcp add atlassian -- npx -y @anthropic/mcp-server-atlassian

# List configured servers
claude mcp list

# Remove a server
claude mcp remove atlassian
```

### 1. Pre-flight: Test Server Before Adding to Config

Test the server works BEFORE adding to config (avoids restart cycles):

```bash
# Test npx server directly with credentials
ATLASSIAN_API_TOKEN="xxx" ATLASSIAN_EMAIL="you@co.com" ATLASSIAN_DOMAIN="co.atlassian.net" \
  npx -y @anthropic/mcp-server-atlassian

# Test uvx server
GITHUB_TOKEN="ghp_xxx" uvx mcp-server-github
```

If it starts without errors, it's safe to add to config.

### 2. Test in Claude Code

After adding to config:
1. **Restart Claude Code** (required - no way around this currently)
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

**First, search for existing credentials:**
```bash
grep -ri "ATLASSIAN" ~/.bashrc ~/.zshrc ~/.zshenv 2>/dev/null
find ~/code ~/work -maxdepth 3 -name ".env*" -exec grep -l "ATLASSIAN" {} \; 2>/dev/null
```

**If not found, get new token:** https://id.atlassian.com/manage-profile/security/api-tokens

```bash
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

**First, search for existing credentials:**
```bash
grep -ri "SLACK" ~/.bashrc ~/.zshrc ~/.zshenv 2>/dev/null
find ~/code ~/work -maxdepth 3 -name ".env*" -exec grep -l "SLACK" {} \; 2>/dev/null
```

**If not found, create Slack app:** https://api.slack.com/apps
- Add Bot Token Scopes: channels:history, channels:read, chat:write, users:read

```bash
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

**First, search for existing credentials:**
```bash
grep -ri "GITHUB_TOKEN\|GH_TOKEN" ~/.bashrc ~/.zshrc ~/.zshenv 2>/dev/null
gh auth token 2>/dev/null  # If gh CLI is authenticated
```

**If not found, create token:** https://github.com/settings/tokens

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

## Advanced: mcp-use Framework

For power users who want programmatic MCP access outside Claude Code, [mcp-use](https://github.com/mcp-use/mcp-use) provides a full-stack MCP framework:

```python
# pip install mcp-use langchain-openai
from langchain_openai import ChatOpenAI
from mcp_use import MCPAgent, MCPClient

config = {
    "mcpServers": {
        "filesystem": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-filesystem", "/tmp"]
        }
    }
}

client = MCPClient.from_dict(config)
llm = ChatOpenAI(model="gpt-4o")
agent = MCPAgent(llm=llm, client=client)

result = await agent.run("List all files in the directory")
```

**Features:**
- 🤖 Build custom AI agents with MCP tool access
- 🔌 Connect any LLM to any MCP server
- 🛠️ Create your own MCP servers
- 🔍 Built-in web inspector for debugging
- 📡 Streaming responses, multi-server support

**Use cases:**
- Custom automation scripts that need MCP tools
- Building your own AI assistant with specific MCP servers
- Testing MCP servers before adding to Claude Code

## Security Checklist

Before installing any MCP server:
- [ ] Review the source code (at least README and main files)
- [ ] Check it doesn't send data to unexpected endpoints
- [ ] Use minimal required permissions/scopes
- [ ] Store credentials in environment variables, not config files
- [ ] Don't commit credentials to git
