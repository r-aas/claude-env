---
name: skill-evolution
description: Improve skills by identifying gaps and updating with new learnings. Use PROACTIVELY when struggling with a task, discovering better patterns, or when specialized knowledge is missing. Ensures we always have precise, accurate instructions.
---

# Skill Evolution

Meta-skill for continuous improvement. Every task is an opportunity to improve our skills.

## Core Principle

**If we struggle → create or improve a skill.**

## When to Trigger

### Reactive (Problem-Driven)
- Task took longer than expected
- Had to search for information that should be known
- Made mistakes a skill should have prevented
- Repeated similar work we've done before

### Proactive (Improvement-Driven)
- Discovered a new tool, library, or pattern
- Found a better way to do something
- Cloned a reference repo with good patterns
- Completed a complex task successfully

## Gap Analysis

```
What am I trying to do?
├── Do I have a skill for this? → Check ~/.claude/skills/
├── Is it complete? → Read SKILL.md
├── Does it cover this case? → Check instructions
└── What's missing? → Identify the gap
```

### Gap Types

| Gap Type | Example | Action |
|----------|---------|--------|
| Missing Skill | No skill for database migrations | Create new skill |
| Incomplete | TDD skill lacks property-based testing | Add section |
| Outdated | References old API version | Update content |
| Missing Workflow | No step-by-step for common task | Add workflow |

## Skill Quality Checklist

### Required
- [ ] Clear description with trigger words
- [ ] Step-by-step instructions
- [ ] Concrete examples (not abstract)
- [ ] Error handling / gotchas

### Recommended
- [ ] Links to official docs
- [ ] Reference implementations
- [ ] Decision trees for complex choices
- [ ] Under 500 lines (use linked files for more)

## Update Protocol

1. **Identify the skill** that should contain this knowledge
2. **Read current SKILL.md** to understand existing content
3. **Determine placement** - new section? Update existing? Add example?
4. **Make the edit** - be specific, concrete, actionable
5. **Verify format** - valid YAML frontmatter, proper markdown

## Creating New Skills

**Create NEW when:**
- Topic is distinct enough to stand alone
- Would make existing skill too long (>500 lines)
- Different trigger conditions needed

**Update EXISTING when:**
- Closely related to existing topic
- Adds depth, not breadth
- Same trigger conditions apply

### New Skill Template

```markdown
---
name: lowercase-with-hyphens
description: What it does. When to use it. Key trigger words.
---

# Skill Name

[One paragraph overview]

## Quick Start
[Essential example]

## Workflows

### Workflow 1
1. Step one
2. Step two

## Gotchas
- Common mistake to avoid
```

## Integration Points

### With github-research
When gap requires external knowledge:
1. Use github-research to find references
2. Clone repos to ~/code/references/
3. Extract patterns into skill updates

### With skill-authoring
When creating new skills:
1. Use skill-authoring for proper structure
2. Follow SKILL.md format
3. Test skill activation

## After Every Complex Task

Ask yourself:
1. What did I learn that should be documented?
2. What was harder than it should have been?
3. What will I need to remember next time?

## Meta-Rule

**If you're doing something and thinking "this should be easier" - stop and improve the skill first.**

5 minutes improving a skill saves hours across future tasks.
