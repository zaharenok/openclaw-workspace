# Gemini CLI Skill

**Description:** Google Gemini CLI tool for AI-powered code assistance, chat, and generation via terminal.

**Location:** `/root/.openclaw/workspace/skills/gemini-cli/`

**Installation:**
```bash
npm install -g @google/gemini-cli
```

**Usage:**

### Basic Chat
```bash
gemini "explain this code"
gemini "write a function that sorts an array"
```

### Code Generation
```bash
gemini "create a React component for a todo list"
gemini "write a Python script to scrape a website"
```

### Code Explanation
```bash
gemini "how does this work? <paste code>"
```

### Interactive Mode
```bash
gemini
# Then type your prompts interactively
```

**Features:**
- 💬 Natural language interface
- 💻 Code generation in multiple languages
- 📝 Code explanation and documentation
- 🔄 Conversational context
- 🎯 Direct terminal integration

**Common Use Cases:**
1. Quick code snippets
2. Algorithm explanations
3. Debugging help
4. Code refactoring suggestions
5. Documentation generation

**Environment Setup:**
Requires `GOOGLE_API_KEY` environment variable:
```bash
export GOOGLE_API_KEY="your-key-here"
```

**Integration with OpenClaw:**
- Use via `exec` tool for quick AI tasks
- Background processing for longer operations
- Can be combined with file reading/writing workflows
