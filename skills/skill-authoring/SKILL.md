---
name: skill-authoring
description: Create and improve Claude Code skills following Anthropic best practices. Use when creating new skills, updating existing skills, writing SKILL.md files, reviewing skill quality, or troubleshooting skill discovery. Covers structure, frontmatter, progressive disclosure, workflows, and validation.
---

# Skill Authoring

Create effective skills that Claude can discover and use. Based on official Anthropic guidelines.

## Quick Start Template

```markdown
---
name: lowercase-with-hyphens
description: What it does. When to use it. Key trigger words for discovery.
---

# Skill Name

Brief overview paragraph.

## Quick start

Essential example - get started in 30 seconds.

## Common workflows

### Workflow 1: [Name]
1. Step one
2. Step two
3. Step three

## Advanced features

**Feature A**: See [FEATURE_A.md](FEATURE_A.md)

## Utility scripts

**script.py**: Description
python scripts/script.py args

## Gotchas

- Common mistake and how to avoid
```

## Core Principles

### 1. Concise is Key

Context window is shared. Only add what Claude doesn't already know.

```markdown
# Good (~50 tokens)
## Extract PDF text
Use pdfplumber:
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()

# Bad (~150 tokens) - explains what Claude already knows
PDF files are a common format... there are many libraries...
```

**Rule:** "Does Claude really need this?"

### 2. Degrees of Freedom

Match specificity to task fragility:

| Freedom | When to Use | Example |
|---------|-------------|---------|
| **High** | Multiple valid approaches | "Analyze code and suggest improvements" |
| **Medium** | Preferred pattern with variation | Template with customizable parameters |
| **Low** | Fragile/critical operations | "Run exactly: `python migrate.py --verify`" |

### 3. Progressive Disclosure

SKILL.md is a table of contents. Load details only when needed.

```
skill/
├── SKILL.md          # Overview + links (<500 lines)
├── FORMS.md          # Detail (loaded when needed)
├── reference.md      # API docs (loaded when needed)
└── scripts/
    └── helper.py     # Executed, not loaded
```

## YAML Frontmatter

```yaml
---
name: my-skill-name      # lowercase, hyphens, max 64 chars
description: What it does. When to use it. Key trigger words.
---
```

**name rules:**
- Lowercase letters, numbers, hyphens only
- Max 64 characters
- Must match directory name

**description rules:**
- Max 1024 characters
- Include both WHAT and WHEN
- Use specific trigger words
- Third person ("Processes files" not "I process files")

**Good:**
```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Bad:**
```yaml
description: Helps with documents
```

**Optional fields:**
```yaml
allowed-tools: Read, Grep, Glob  # Restrict tool access
```

## Structure Patterns

### Pattern 1: High-Level Guide with References

```markdown
# PDF Processing

## Quick start
[Essential code example]

## Advanced features
**Form filling**: See [FORMS.md](FORMS.md)
**API reference**: See [REFERENCE.md](REFERENCE.md)
```

### Pattern 2: Domain Organization

```
bigquery-skill/
├── SKILL.md
└── reference/
    ├── finance.md
    ├── sales.md
    └── product.md
```

User asks about sales → Claude reads only `reference/sales.md`.

### Pattern 3: Conditional Details

```markdown
## Creating documents
Use docx-js. See [DOCX-JS.md](DOCX-JS.md).

## Editing documents
For simple edits, modify XML directly.
**For tracked changes**: See [REDLINING.md](REDLINING.md)
```

## Skill Directory Structure

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (required)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/          - Executable code
    ├── references/       - Documentation loaded as needed
    └── assets/           - Templates, images, fonts
```

**Do NOT create:** README.md, INSTALLATION_GUIDE.md, CHANGELOG.md

## Workflow Pattern

For complex multi-step tasks:

```markdown
## Form filling workflow

Copy this checklist:
- [ ] Step 1: Analyze form (run analyze_form.py)
- [ ] Step 2: Create mapping (edit fields.json)
- [ ] Step 3: Validate (run validate_fields.py)
- [ ] Step 4: Fill form (run fill_form.py)
- [ ] Step 5: Verify output

**Step 1: Analyze form**
Run: `python scripts/analyze_form.py input.pdf`
```

## Feedback Loop Pattern

Run validator → fix → repeat.

```markdown
## Document editing

1. Make edits to `document.xml`
2. **Validate immediately**: `python validate.py`
3. If fails: Review error → Fix → Validate again
4. **Only proceed when validation passes**
```

## Script Guidelines

### Solve, Don't Punt

```python
# Good - handles errors
def process_file(path):
    try:
        return open(path).read()
    except FileNotFoundError:
        print(f"Creating {path}")
        open(path, 'w').write('')
        return ''

# Bad - punts to Claude
def process_file(path):
    return open(path).read()  # Just fails
```

### Document Constants

```python
REQUEST_TIMEOUT = 30  # Typical HTTP request duration
MAX_RETRIES = 3       # Most failures resolve by retry 2
```

## Anti-Patterns

| Don't | Do Instead |
|-------|------------|
| Windows paths (`scripts\helper.py`) | Unix paths (`scripts/helper.py`) |
| Multiple options ("use X or Y or Z") | One default + escape hatch |
| Nested references (A→B→C) | One level deep from SKILL.md |
| Time-sensitive info | "Old patterns" collapsible section |
| Verbose explanations | Assume Claude knows basics |

## Quality Checklist

### Core Quality
- [ ] Description specific with trigger words
- [ ] Description includes WHAT and WHEN
- [ ] SKILL.md under 500 lines
- [ ] Large content in separate files
- [ ] Consistent terminology
- [ ] Concrete examples
- [ ] One-level-deep references

### Scripts (if applicable)
- [ ] Handle errors explicitly
- [ ] No magic constants
- [ ] Unix-style paths only
- [ ] Validation steps included

## Skill Creation Process

1. **Complete task without skill** - Note what info you provide
2. **Identify reusable pattern** - What helps similar tasks?
3. **Create skill directory** - `~/.claude/skills/skill-name/`
4. **Write SKILL.md** - Frontmatter + instructions
5. **Add resources** - scripts/, references/, assets/
6. **Test on real tasks** - Observe actual behavior
7. **Iterate** - Fix what doesn't work

## Skill Locations

**Personal Skills** (`~/.claude/skills/`):
- Individual workflows and preferences
- Experimental skills
- Personal productivity tools

**Project Skills** (`.claude/skills/`):
- Team workflows and conventions
- Project-specific expertise
- Shared utilities (committed to git)

## Troubleshooting

**Skill doesn't activate:**
- Make description more specific with trigger words
- Include file types and operations
- Add "Use when..." clause

**Multiple skills conflict:**
- Make descriptions more distinct
- Use different trigger words
- Narrow scope of each skill

**Skill has errors:**
- Check YAML syntax (no tabs, proper indentation)
- Verify file paths (use forward slashes)
- Ensure scripts have execute permissions
