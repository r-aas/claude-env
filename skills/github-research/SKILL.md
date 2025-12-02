---
name: github-research
description: Research GitHub for existing implementations, best practices, and reference code. Use when asked to find how others solved a problem, search for libraries/frameworks, clone repos to references folder, study implementation patterns, or when told to "research first" or "find existing solutions". Clones to ~/code/references/.
---

# GitHub Research Skill

Research-first approach to software development. Find existing solutions before building from scratch.

## When to Use This Skill

- User asks "how do others implement X?"
- User wants to find best practices for a technology
- User needs reference implementations before coding
- User says "research first", "find existing", "what's out there"
- Before building anything significant - check if it exists

## Research Workflow

### 1. Search Strategy

**GitHub CLI Search (gh):**
```bash
# Find well-maintained repos by topic
gh search repos "fastapi oauth" --sort=stars --limit=20
gh search repos "topic:python topic:fastapi" --sort=stars

# Find by language
gh search repos "mcp server" --language=python --sort=stars

# Find code patterns
gh search code "pattern" --language=python --limit=20

# Find by filename
gh search code "filename:CLAUDE.md" --limit=50
gh search code "filename:.cursorrules" --limit=50
gh search code "filename:pyproject.toml" --language=python

# Search issues/PRs for patterns
gh search issues "bug authentication" --repo=owner/repo
gh search prs "feat:" --state=merged --limit=20

# View repo details before cloning
gh repo view owner/repo
gh repo view owner/repo --json description,stargazerCount,updatedAt
```

**Quality Indicators (prioritize repos with):**
- Stars > 500 (battle-tested)
- Recent commits (< 6 months)
- Multiple contributors
- examples/ directory
- CHANGELOG.md (active maintenance)
- CI/CD badges passing
- Semantic versioning tags

### 2. Clone to References

Always clone interesting repos to `~/code/references/`:

```bash
# Clone with gh (preferred)
gh repo clone owner/repo ~/code/references/repo-name

# Or with git
git clone https://github.com/owner/repo ~/code/references/repo-name

# Sparse checkout for large repos
git clone --filter=blob:none --sparse https://github.com/owner/repo ~/code/references/repo-name
cd ~/code/references/repo-name
git sparse-checkout set src/ examples/ docs/

# Fork first if you might contribute
gh repo fork owner/repo --clone=true
```

### 3. Study Implementation

**Key files to examine:**
- `README.md` - Overview and usage
- `examples/` - Real usage patterns
- `src/` or `lib/` - Core implementation
- `CLAUDE.md` or `.cursorrules` - AI coding instructions (gold!)
- `pyproject.toml` / `package.json` - Dependencies and structure
- `.github/workflows/` - CI/CD patterns
- `Dockerfile` / `docker-compose.yml` - Deployment patterns
- `Makefile` / `Taskfile.yml` - Build automation

**Analysis approach:**
1. Read README for high-level understanding
2. Check examples/ for usage patterns
3. Trace entry points (main.py, index.ts, cmd/)
4. Note dependencies and why they're used
5. Look for patterns we can adopt

### 4. Document Findings

After researching, summarize:
- What repos were found and why they're relevant
- Key patterns/approaches discovered
- Dependencies worth adopting
- Code snippets to reference
- What to build vs. what to reuse

## Search Categories

### Terraform Modules
```bash
gh search repos "terraform-aws-" org:terraform-aws-modules --sort=stars
gh search repos "terraform-" org:cloudposse --sort=stars
```
Check: registry.terraform.io first

### Helm Charts
```bash
gh search repos "charts" org:bitnami --sort=stars
gh search repos "helm-charts" org:prometheus-community
```
Check: artifacthub.io first

### Python Libraries
```bash
gh search repos "topic:python topic:fastapi" --sort=stars
gh search repos "topic:python topic:async" --sort=stars
```

### MCP Servers
```bash
gh search repos "mcp-server" --sort=stars
gh search repos "model-context-protocol" --sort=stars
gh search code "filename:mcp.json" --limit=20
```

### Claude/AI Coding Patterns
```bash
gh search code "filename:CLAUDE.md" --limit=50
gh search code "filename:.cursorrules" --limit=50
gh search repos "claude-code" --sort=stars
gh search repos "anthropic-skills" --sort=stars
```

### Agent Frameworks
```bash
gh search repos "topic:ai-agents" --sort=stars
gh search repos "topic:langchain topic:agents" --sort=stars
gh search repos "a2a-protocol OR agent-to-agent" --sort=stars
```

## Reference Folder Structure

```
~/code/references/
├── terraform-modules/      # Terraform reference implementations
├── helm-charts/           # Helm chart patterns
├── mcp-servers/           # MCP server examples
├── agent-frameworks/      # Agent implementation patterns
├── claude-configs/        # CLAUDE.md and .cursorrules examples
└── {repo-name}/          # Individual repo clones
```

## Example Research Session

**User request:** "I need to implement OAuth2 with FastAPI"

**Research steps:**
1. Search: `gh search repos "fastapi oauth2" --sort=stars --limit=10`
2. Check top results for quality indicators
3. Clone best candidate: `git clone ... ~/code/references/fastapi-oauth2-example`
4. Study: Read examples/, check dependencies (authlib? python-jose?)
5. Report findings with specific code references

## Tips

- **Star repos you find useful** - `gh repo star owner/repo`
- **Check issues** - `gh issue list -R owner/repo --state=all`
- **Read PRs** - `gh pr list -R owner/repo --state=merged`
- **Fork before modifying** - `gh repo fork owner/repo`
- **Update periodically** - `git -C ~/code/references/repo pull`
- **Watch for updates** - `gh repo watch owner/repo`

## gh CLI Quick Reference

```bash
# Authentication
gh auth login
gh auth status

# Search
gh search repos "query" --sort=stars
gh search code "pattern" --language=python

# Repos
gh repo clone owner/repo
gh repo view owner/repo
gh repo fork owner/repo

# Issues/PRs
gh issue list -R owner/repo
gh pr list -R owner/repo --state=merged
```
