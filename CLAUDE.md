# Claude Code Global Instructions

## Who I'm Working With

R - Engineer focused on AI/ML platform engineering
- AuDHD (Autism + ADHD), INTJ-A
- Strengths: Deep focus, pattern recognition, rapid prototyping, systems thinking
- Kryptonite: Context switching, communication overhead, organization, remembering things
- Preference: Modular, adaptable, reconfigurable systems

## Design Philosophy

### Unified Abstractions
R consistently chooses tools that provide **one interface with swappable implementations**:

| Layer | Tool | Why |
|-------|------|-----|
| Python | uv/uvx | One tool replaces pip, venv, pyenv. No fragmentation. |
| Node | npx | Run without installing. Ephemeral, no global pollution. |
| LLMs | anyllm | Swap providers without code changes |
| Agents | anyagent | Framework-agnostic |
| Infra | Terraform + modules | Existing modules over raw manifests |
| Routing | k8s ingress | One routing layer, swap implementations |
| Agents | A2A protocol | Standard agent-to-agent interface |
| MCPs | fastmcp | Simple MCP server creation |
| APIs | FastAPI | Async Python APIs |
| Validation | Pydantic | Type-safe models, settings, serialization |
| Observability | OpenTelemetry | Unified tracing/metrics |

**The pattern:** Abstract the decision. Write once. Swap later. Never be locked in.

### Cloud Strategy

| Context | Preference |
|---------|------------|
| **Personal/Homelab** | Local-first (k3d, Terraform) |
| **Professional/Client** | AWS → Azure → GCP → Oracle Cloud |

**Local-first means:** Develop locally, k3d mirrors production k8s, only go to cloud when needed.

### Mental Models
- **Layers** - Stack abstractions; each layer hides complexity below
- **Lego bricks** - Small, composable pieces that snap together
- **Pattern library** - No duplication; pathfind across known patterns

### How R Thinks
1. "What layer is this?" - Find where it fits
2. "What's the abstraction?" - Find the interface
3. "Who's already solved this?" - Check ~/code, then GitHub, then build
4. "Can I swap this out later?" - If no, find something flexible
5. "Does this plug into what we have?" - Integrate, not standalone
6. "What's the minimal path?" - Reduce cognitive overhead

### Development Approach
- **TDD** - Tests first, then implementation
- **Requirements tracing** - Link tests/code back to requirements
- **Self-documenting** - Code that explains itself
- **Anti-sprawl** - Consolidate, dedupe, prune
- **curl-testable** - Everything verifiable via curl
- **Taskfile > Makefile** - Prefer Taskfile.yml

---

## How Claude Should Adapt

### Reduce Friction
- **Be the memory** - Store decisions, context, patterns
- **Evolve knowledge** - Update skills with new learnings
- **Minimize back-and-forth** - Make reasonable assumptions, act, explain after
- **Protect flow state** - Batch questions, don't interrupt with minor decisions
- **Adapt and anticipate** - Learn R's patterns; predict what he'll want next

### Support Focus
- **One thing at a time** - Clear current task, what's next, what's deferred
- **Visual structure** - Headers, bullets, tables over prose
- **No fluff** - Direct, concrete, skip social niceties
- **Explicit transitions** - Clear signal when switching topics

### Self-Improvement Protocol
**After every session, Claude MUST:**
1. **Capture gotchas** - Errors that took >1 attempt → update relevant skill
2. **Update workflows** - New commands, patterns → update relevant skill
3. **Record decisions** - Architecture choices → update relevant skill
4. **Flag technical debt** - TODOs, disabled features → note in skill or project docs

**When building anything:**
1. Check if it duplicates existing functionality
2. Check if there's an existing library
3. Check if it survives restart
4. Check if it's reproducible

### Research-First Workflow
- **Never start from scratch** - Find references first
- **Check ~/code first** - Build on existing work
- **Then GitHub** - Only look externally if needed
- **Clone to ~/code/references/** - Study and borrow

---

## Quick Reference

### Paths
| Tool | Path |
|------|------|
| uv/uvx | `~/.local/bin/uv`, `~/.local/bin/uvx` |
| node/npx | `/opt/homebrew/bin/node`, `/opt/homebrew/bin/npx` |
| Projects | `~/code` |
| References | `~/code/references/` |
| Skills | `~/.claude/skills/` |

---

## Core Tools

### Python (uv only)
```bash
uv init myproject        # New project → Python 3.12
uv add <pkg>             # Add dependency
uv run <script>          # Execute
uvx <tool>               # One-off tools (ruff, black)
```
**NO pip. Ever.**

### Taskfile
```yaml
task up/down/restart     # Lifecycle
task status/test         # Verify
task build/deploy        # Containers
task logs/shell          # Debug
```
Design: idempotent, composable, clear feedback.

### MCP Memory
```
retrieve_memory  - Semantic search
store_memory     - Save decisions + tags
recall_memory    - Time queries
search_by_tag    - Find by tag
```
**Rule:** Store WHY, not just WHAT.

---

## Rules

### Core
1. **No mocking** - Integrate directly
2. **No temp files left behind** - Clean up or integrate
3. **Timeouts:** 60s max
4. **Test:** curl before browser
5. **GitHub-first:** Search before building
6. **uv only** - Never run Python outside of uv
7. **FOSS preferred** - No proprietary dependencies
8. **Reproducible** - Everything rebuildable from scratch

### Quality Checks
- Survives restart?
- Works from scratch?
- No hardcoded values?
- Secrets externalized?
- Single source of truth?
- Cleanup path exists?

### Principles
- **Kaizen** - Continuous small improvements
- **80/20** - Focus on the 20% that delivers 80%
- **YAGNI** - Don't build what you don't need yet
- **DRY** - Dedupe ruthlessly
- **KISS** - Complexity is debt
- **Fail fast** - Surface errors early
- **Skeptical until proven** - Verify before handoff

---

## Installed Skills

Skills are in `~/.claude/skills/`. They provide specialized knowledge that Claude loads on-demand.

### Meta Skills
| Skill | Purpose |
|-------|---------|
| `skill-authoring` | Create and improve skills (Anthropic best practices) |
| `skill-evolution` | Find gaps, update skills with new learnings |
| `github-research` | Find references, clone to ~/code/references |

### Development
| Skill | Purpose |
|-------|---------|
| `code-review-excellence` | Code review best practices |
| `debugging-strategies` | Systematic debugging |
| `tdd-orchestrator` | Test-driven development with pytest/Jest |
| `error-handling-patterns` | Error handling patterns |
| `architecture-patterns` | System architecture |
| `microservices-patterns` | Distributed systems |

### Python
| Skill | Purpose |
|-------|---------|
| `fastapi-templates` | FastAPI project patterns (uv-based) |
| `python-packaging` | Package structure with uv/pyproject.toml |
| `rag-implementation` | RAG system patterns |

### Infrastructure
| Skill | Purpose |
|-------|---------|
| `taskfile-patterns` | Build automation with Taskfile.yml |
| `k8s-troubleshooting` | Debug pods, services, ingress |
| `k8s-security-policies` | Security best practices |
| `terraform-module-library` | Terraform patterns |
| `github-actions-templates` | CI/CD workflows |
| `mcp-development` | Build MCP servers (FastMCP + TypeScript) |

### Platform-Specific
| Skill | Purpose |
|-------|---------|
| `apple-silicon-dev` | ARM64/Mac development gotchas |

### Documents
| Skill | Purpose |
|-------|---------|
| `pdf`, `xlsx`, `docx` | Document processing |

### Testing
| Skill | Purpose |
|-------|---------|
| `e2e-testing-patterns` | End-to-end testing (Playwright/Cypress) |

### Other
| Skill | Purpose |
|-------|---------|
| `frontend-design` | Frontend patterns |
| `git-advanced-workflows` | Advanced git |
| `sql-optimization-patterns` | SQL optimization |
| `auth-implementation-patterns` | Authentication patterns |
| `database-migration` | Database migrations |

**Usage:** Skills activate automatically based on context. Just ask about the topic.

---

## Changelog
- 2025-12-01: Initial public release with 28 skills.
