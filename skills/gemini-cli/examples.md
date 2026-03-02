# Gemini CLI Examples

## Quick Examples

### 1. Simple Question
```bash
gemini "What is React?"
```

### 2. Code Generation
```bash
gemini "Write a TypeScript function to validate email addresses"
```

### 3. Code Explanation
```bash
cat mycode.js | gemini "Explain what this code does"
```

### 4. Refactoring
```bash
gemini "How can I improve this code? <paste code>"
```

## OpenClaw Integration

### Basic Usage
```javascript
// Via exec tool
await exec({
  command: 'gemini "Explain async/await in JavaScript"'
})
```

### With File Context
```javascript
// Read file, then analyze
const code = await read({ path: 'src/app.js' })
await exec({
  command: `gemini "Review this code:\n${code}"`
})
```

### Interactive Session
```bash
# Start background session
gemini
# Send prompts via process tool
```

## Tips

- Use for quick AI tasks without full coding agent
- Good for explanations and suggestions
- Requires GOOGLE_API_KEY environment variable
- Can handle multi-line prompts with quotes
