# Skill Creator - Technical Guide

## Overview

The Skill Creator is a meta-skill for designing and building new Agent Skills. It provides templates, patterns, and best practices for creating reusable capabilities.

## Prerequisites

- Workspace: `/home/node/.openclaw/workspace`
- File system access (read/write)
- Git (for version control)
- Bash/shell scripting knowledge

## Skill Structure

```
skills/[skill-name]/
├── SOUL.md              # Persona/guidelines (for agent personas)
├── SKILL.md             # Technical instructions (for technical skills)
├── README.md            # User documentation (optional but recommended)
├── scripts/             # Executable scripts
│   ├── setup.sh        # Installation
│   └── *.sh            # Utilities
├── assets/              # Static files (optional)
├── templates/           # Code/file templates (optional)
└── examples/            # Usage examples (optional)
```

## Creating a New Skill

### 1. Plan the Skill

**Questions to answer:**
- What problem does it solve?
- Is it a **persona** (SOUL.md) or **technical skill** (SKILL.md)?
- What tools/APIs does it need?
- Who will use it?

### 2. Choose File Type

**Create SOUL.md for:**
- Agent personas (Health Coach, Business Advisor)
- Skills with "personality" or "thinking style"
- Guidelines and principles

**Create SKILL.md for:**
- Technical capabilities (OpenCode, Weather)
- Tool wrappers and APIs
- Scripts and utilities

**Create BOTH for:**
- Technical skills with persona elements
- Complex tools needing both approaches

### 3. Create the Skill

```bash
# Create skill directory
mkdir -p /home/node/.openclaw/workspace/skills/your-skill

# Create core files
touch skills/your-skill/SOUL.md          # or SKILL.md
touch skills/your-skill/README.md        # optional

# Create scripts directory
mkdir -p skills/your-skill/scripts
chmod +x skills/your-skill/scripts/*.sh  # make executable
```

### 4. Update Orchestrator

**If creating a persona, add to SOUL.md:**

```markdown
**Activation:**
- `[your-skill]` — Switch to Your Skill persona (what it does)
```

```markdown
**Persona Signatures:**
- Your Skill → `🎯 Your Skill ready! [Signature phrase]`
```

**If technical skill, document available tools.**

### 5. Commit and Push

```bash
git add skills/your-skill/
git commit -m "Add [skill-name] skill"
git push origin master
```

## File Templates

### SOUL.md Template (Personas)

```markdown
# [Skill Name] - Your SOUL

*[One-line description]*

## When You Activate

**Start with:** `[Signature phrase]`

Then dive into the task.

## Who You Are

You're the **[Skill Name]** — [role description].

**Your expertise:** [Domain knowledge]
**Your approach:** [How you think/work]

## How You Communicate

**Tone:** [Voice and style]
**Style:**
- [Communication pattern 1]
- [Communication pattern 2]

**What you do:**
- [Task 1]
- [Task 2]

## Your Principles

1. **Principle 1** — [Explanation]
2. **Principle 2** — [Explanation]

## When to Ask Questions

Before [task type], you need to know:
- [Context needed 1]
- [Context needed 2]

## Your Boundaries

- [Limitation 1]
- [Limitation 2]

## Sample Interactions

**User:** [Example input]
**You:** [Example response]

---

*[Closing thought]*
```

### SKILL.md Template (Technical)

```markdown
# [Skill Name] - Technical Guide

## Overview

[Brief description of what this skill does]

## Prerequisites

- Required tool: `[tool-name]`
- Config: `path/to/config`
- API key: `VAR_NAME`
- Other dependencies

## Setup

```bash
# Installation steps
```

## Usage

```bash
# Basic usage
skill-command [options]
```

### Options

- `--option1` - Description
- `--option2` - Description

## Outputs

- Format: [text/json/structured]
- Destination: [stdout/file/API]
- Schema: [if applicable]

## Troubleshooting

**Error:** Description
**Solution:** Fix

## Examples

### Example 1: [Use case]

```bash
# Command
skill-command --example

# Output
result
```
```

### Script Template

```bash
#!/bin/bash
# [Script Description]
# Usage: script-name [args]

set -e  # Exit on error

# Variables
WORKSPACE="/home/node/.openclaw/workspace"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Functions
function log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

function main() {
    log "Starting..."
    
    # Your code here
    
    log "Complete"
}

# Run
main "$@"
```

## Common Patterns

### 1. Wrapper Skills

Wrap external tools/APIs:

```bash
# Example: Weather skill
curl -s "https://api.weather.com/data?city=$CITY"
```

**Files:**
- SKILL.md (API docs)
- scripts/fetch.sh (wrapper)
- examples/ (usage)

### 2. Persona Skills

Agent personalities:

**Files:**
- SOUL.md (persona definition)
- Principles and frameworks
- No scripts needed (just guidelines)

### 3. Utility Skills

Helper functions:

**Files:**
- SKILL.md (usage)
- scripts/utility.sh (functionality)
- cron/ (scheduled execution)

### 4. Integration Skills

External services:

**Files:**
- SKILL.md (API docs)
- scripts/auth.sh (credentials)
- scripts/poll.sh (integration)
- scripts/webhook.sh (events)

## Best Practices

### 1. Keep It Focused
- One skill = one clear purpose
- Avoid feature creep
- Document limitations

### 2. Document Everything
- README.md for users
- SOUL.md/SKILL.md for implementation
- Comments in code

### 3. Handle Errors
```bash
set -e  # Exit on errors
# or
if ! command -v tool &> /dev/null; then
    echo "Error: tool not found"
    exit 1
fi
```

### 4. Make Scripts Executable
```bash
chmod +x skills/your-skill/scripts/*.sh
```

### 5. Use Absolute Paths
```bash
WORKSPACE="/home/node/.openclaw/workspace"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
```

### 6. Version Control
```bash
git add skills/your-skill/
git commit -m "Add your-skill: description"
git push origin master
```

## Testing Your Skill

### 1. Manual Testing

```bash
# Test scripts
bash skills/your-skill/scripts/test.sh

# Verify outputs
ls -la skills/your-skill/
```

### 2. Integration Testing

```bash
# Test with OpenClaw
# Activate persona if needed
[skill-name]

# Run command
your-skill-command
```

### 3. Document Examples

```bash
# Save example output
your-skill-command > skills/your-skill/examples/output.txt
```

## Updating Skills

### 1. Modify Files
```bash
# Edit skill files
vim skills/your-skill/SOUL.md
vim skills/your-skill/scripts/script.sh
```

### 2. Test Changes
```bash
# Test scripts
bash skills/your-skill/scripts/script.sh

# Verify behavior
```

### 3. Commit Updates
```bash
git add skills/your-skill/
git commit -m "Update skill-name: what changed"
git push origin master
```

## Removing Skills

### 1. Deactivate (if persona)
Remove from SOUL.md activation list and signatures.

### 2. Delete Files
```bash
rm -rf skills/your-skill/
```

### 3. Commit Removal
```bash
git add -A
git commit -m "Remove skill-name"
git push origin master
```

## Troubleshooting

**Problem:** Skill not activating
**Solution:** Check SOUL.md activation list and signatures

**Problem:** Script not executable
**Solution:** `chmod +x skills/your-skill/scripts/*.sh`

**Problem:** Git conflicts
**Solution:** Pull before push, or use `--force` if safe

**Problem:** Dependencies missing
**Solution:** Document in SKILL.md prerequisites

## Examples

See existing skills:
- `skills/business-advisor/SOUL.md` — Persona example
- `skills/opencode/SKILL.md` — Technical skill example
- `skills/voice-processor/SKILL.md` — Utility skill example

---

*For persona design guidance, see SOUL.md in this skill.*
