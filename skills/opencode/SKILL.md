# OpenCode Manager - SKILL.md

**Description:** Manage and control OpenCode AI coding agent (CLI tool, desktop app, IDE extension).

**Location:** `/app/skills/opencode/SOUL.md`

**Documentation:** https://opencode.ai/docs/

## Usage

Activate with `[opencode]` tag:

```
[opencode] инициализируй opencode в проекте
[opencode] запусти opencode в /path/to/project
[opencode] покажи как добавить новую фичу
```

## What is OpenCode

OpenCode is an open-source AI coding agent that:
- Works in terminal (CLI), desktop app, or IDE extension
- Analyzes and modifies codebases
- Supports Plan mode (review suggestions) and Build mode (make changes)
- Works with any LLM provider (OpenCode Zen, OpenAI, Anthropic, etc.)

**GitHub:** https://github.com/anomalyco/opencode

## Key Commands

### Project Operations
```
[opencode] перейди в проект и запусти opencode
[opencode] инициализируй проект (создай AGENTS.md)
[opencode] покажи статус opencode
```

### Session Management
```
[opencode] начни новую сессию opencode
[opencode] отмени последние изменения (/undo)
[opencode] поделись сессией с командой (/share)
```

### Development Workflow
```
[opencode] объясни как работает @src/auth.ts
[opencode] добавь аутентификацию в роут /settings
[opencode] создай план для новой фичи (Plan mode)
```

## Installation

```bash
# Install script (recommended)
curl -fsSL https://opencode.ai/install | bash

# npm
npm install -g opencode-ai

# Homebrew
brew install anomalyco/tap/opencode
```

## Configuration

```bash
# Start opencode and connect provider
opencode
/connect
# Select: opencode, openai, anthropic, etc.
```

## Plan vs Build Mode

**Plan mode (Tab key):**
- No actual changes
- Shows suggestions first
- Review before implementing
- Safe for exploration

**Build mode (Tab key):**
- Makes actual changes
- Implements features
- Modifies files
- Use after reviewing plan

## AGENTS.md

OpenCode creates `AGENTS.md` during `/init`:
- Describes project structure
- Documents coding patterns
- Helps OpenCode understand codebase
- Commit to git for team collaboration

## Best Practices

1. **Always initialize** projects with `/init` before asking questions
2. **Use Plan mode** for complex features to review first
3. **Reference files** with `@path/to/file.ts` syntax
4. **Be specific** in your requests
5. **Review changes** before accepting

## Sample Workflows

### Explain Code
```
[opencode] запусти opencode и спроси: "How is authentication handled in @src/api/index.ts?"
```

### Add Feature (with Plan)
```
[opencode] включи Plan mode и запроси: "When a user deletes a note, flag it as deleted. Create a screen for recently deleted notes with undelete option."
```

### Make Changes
```
[opencode] запроси: "Add authentication to /settings route. Use the same logic as /notes in @src/notes.ts"
```

## Integration

Works with:
- **Code Expert (`[code]`)** — For code review and architectural advice
- **Business Advisor (`[business]`)** — For project planning and decisions
- **Voice Processor** — For voice commands to OpenCode

## Troubleshooting

**OpenCode not found:**
```bash
which opencode
npm install -g opencode-ai
```

**API key issues:**
```bash
opencode
/connect
# Re-enter API key
```

**Not understanding project:**
```bash
cd /path/to/project
opencode
/init
```

## Files

- Config: `~/.config/opencode/config.json`
- Project context: `<project>/AGENTS.md`
- Logs: Check terminal output

## Notes

- OpenCode is **not** VS Code — it's an AI coding agent
- Works best when initialized properly with `/init`
- Plan mode is your friend for complex changes
- AGENTS.md is crucial for project understanding
