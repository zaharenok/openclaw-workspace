# OpenClaw VPS Security: Common Mistakes & Best Practices

## 🔒 Critical Security Issues When Self-Hosting OpenClaw

Running OpenClaw on a public VPS exposes you to significant security risks. This document outlines the most common mistakes people make and how to avoid them.

---

## 🚨 Top 10 Security Mistakes

### 1. **Exposed Gateway to Public Internet** ⚠️ CRITICAL

**The Mistake:**
Binding OpenClaw Gateway to `0.0.0.0` (all interfaces) or exposing the control port (default: 18789) to the internet.

**Why It's Dangerous:**
- Anyone on the internet can access your Gateway control panel
- Unauthorized actors can send messages to your bot
- Can execute shell commands through your agent
- Access your filesystem, browser, and tools

**How to Check:**
```bash
# Check if Gateway is exposed
netstat -tuln | grep 18789
ss -tuln | grep 18789

# If shows 0.0.0.0, you're exposed!
```

**Fix:**
```json
// ~/.openclaw/openclaw.json
{
  "gateway": {
    "bind": "127.0.0.1",  // Only localhost
    "port": 18789,
    "auth": {
      "mode": "token",
      "token": "your-random-token-here"
    }
  }
}
```

**Better:** Use **Tailscale Serve** instead of exposing ports directly.

---

### 2. **Weak or Missing Authentication** ⚠️ CRITICAL

**The Mistake:**
- Running Gateway with `auth.mode: "disabled"`
- Using default/weak passwords
- No token configured at all

**Why It's Dangerous:**
- Anyone who finds your Gateway can control your bot
- Can send messages, execute commands, access files
- No audit trail of who accessed it

**Fix:**
```bash
# Generate secure token
openclaw doctor --generate-gateway-token

# Or set password via env
export OPENCLAW_GATEWAY_PASSWORD="$(openssl rand -hex 32)"

# Then in config:
{
  "gateway": {
    "auth": {
      "mode": "token",  // Prefer token over password
      "token": "your-token"
    }
  }
}
```

---

### 3. **Open DM Policy (groupPolicy="open" or dmPolicy="open")** ⚠️ HIGH

**The Mistake:**
Allowing anyone to DM your bot without authentication.

**Why It's Dangerous:**
- Anyone who finds your bot can trigger it
- Prompt injection attacks become trivial
- Data exfiltration risk

**Fix:**
```json
{
  "channels": {
    "telegram": {
      "dmPolicy": "pairing"  // Requires pairing code
      // OR use allowlist:
      "allowFrom": ["+15555550123"]  // Only your numbers
    },
    "whatsapp": {
      "dmPolicy": "disabled"  // If you don't need DMs
    }
  }
}
```

**Recommended:** Use **pairing mode** - strangers get a pairing code, must approve before bot responds.

---

### 4. **Open Group Policy (no mention requirement)** ⚠️ HIGH

**The Mistake:**
Bot responds to everyone in groups without `@mention`.

**Why It's Dangerous:**
- Anyone in group can trigger your bot
- Spam messages waste API credits
- Can't track who triggered commands

**Fix:**
```json
{
  "channels": {
    "telegram": {
      "groups": {
        "*": {
          "requireMention": true  // Must @mention bot
        }
      }
    }
  }
}
```

**Better:** Use `dmPolicy: "pairing"` for open access, then `groupPolicy: "allowlist"` for groups.

---

### 5. **Exposed Filesystem Permissions** ⚠️ HIGH

**The Mistake:**
```bash
# Wrong! Anyone can read your OpenClaw data
chmod 755 ~/.openclaw  # World-readable
```

**Why It's Dangerous:**
- Anyone with shell access can read your config
- Session transcripts contain private conversations
- API keys and credentials in plaintext

**Fix:**
```bash
# Correct permissions
chmod 700 ~/.openclaw           # Directory: owner only
chmod 600 ~/.openclaw/*.{json,key}  # Files: owner only

# Verify
ls -la ~/.openclaw/
```

**Required Permissions:**
- `~/.openclaw/` → **700** (owner only)
- `~/.openclaw/*.json` → **600** (owner read/write)
- `~/.openclaw/credentials/` → **700** or **600**
- `~/.openclaw/agents/*/sessions/` → **700**

---

### 6. **API Keys and Secrets in Config Files** ⚠️ HIGH

**The Mistake:**
```json
{
  "models": {
    "zai": {
      "apiKey": "sk-1234567890abcdef"  // Wrong!
    }
  }
}
```

**Why It's Dangerous:**
- Git history contains API keys
- Any process can read config
- Keys leak to logs, backups, repositories

**Fix:**
Use environment variables instead:
```bash
# Store in separate file (NOT in git)
echo "export ZAI_API_KEY='sk-...'" > ~/.openclaw/.env
chmod 600 ~/.openclaw/.env

# Source in shell profile
echo "source ~/.openclaw/.env" >> ~/.bashrc

# Reference in config (no secrets!)
{
  "models": {
    "zai": {
      "apiKey": "${ZAI_API_KEY}"  // References env var
    }
  }
}
```

**Add to `.gitignore`:**
```gitignore
.env
*.key
*.pem
credentials/
*.token
```

---

### 7. **Logging Sensitive Data** ⚠️ MEDIUM

**The Mistake:**
```json
{
  "logging": {
    "redactSensitive": "off"  // Logs everything!
  }
}
```

**Why It's Risky:**
- API keys in logs
- Private conversations in plaintext
- File paths, hostnames exposed

**Fix:**
```json
{
  "logging": {
    "redactSensitive": "tools",  // Redact tool calls
    "redactPatterns": [
      "sk-.*",           // API keys
      "Bearer .*",        // Tokens
      "password.*",       // Passwords
      "~/.openclaw"      // File paths
    ]
  }
}
```

---

### 8. **Docker Running as Root** ⚠️ HIGH

**The Mistake:**
```bash
# Wrong!
docker run --privileged -v /root:/data openclaw/openclaw
```

**Why It's Dangerous:**
- Container escape becomes trivial
- Host filesystem fully exposed to container
- Breaks all permission boundaries

**Fix:**
```bash
# Correct - official image runs as non-root
docker run --read-only \
  -v openclaw-data:/app/data \
  --cap-drop=ALL \
  openclaw/openclaw:latest
```

**Even Better:** Use the official Docker image which already:
- Runs as `node` user (not root)
- Has `--read-only` flag configured
- Drops all capabilities with `--cap-drop=ALL`

---

### 9. **Unrestricted Tool Access** ⚠️ HIGH

**The Mistake:**
```json
{
  "tools": {
    "elevated": {
      "allowFrom": "*"  // Anyone can use exec!
    }
  }
}
```

**Why It's Dangerous:**
- Anyone who messages bot can run shell commands
- No approval required for dangerous operations
- LLM can be tricked into running malicious commands

**Fix:**
```json
{
  "tools": {
    "elevated": {
      "allowFrom": ["127.0.0.1", "::1"],  // Localhost only
      "approval": {                             // Require approval
        "mode": "ask",
        "allowFrom": ["owner", "admin"]
      }
    }
  }
}
```

**Recommended Agents:**
- Personal: Full access (you trust yourself)
- Family: Read-only tools only
- Public: No filesystem/shell tools

---

### 10. **Public Browser Control Exposure** ⚠️ CRITICAL

**The Mistake:**
Enabling browser control and exposing the CDP port to the internet.

**Why It's Dangerous:**
- Anyone on internet can control your browser
- Can access your logged-in sessions
- Can steal cookies, passwords, 2FA codes
- Can access any website you're logged into

**Fix:**
```bash
# 1. Keep Gateway on localhost/tailscale only
{
  "gateway": {
    "bind": "127.0.0.1",
    "port": 18789
  }
}

# 2. Use Tailscale Serve for remote access (no exposed ports)
tailscale serve | sudo openclaw

# 3. If exposing CDP, limit to localhost
{
  "gateway": {
    "nodes": {
      "allowFrom": ["127.0.0.1", "::1"]
    }
  }
}

# 4. NEVER port-forward CDP to internet
# Avoid: ssh -R 9222:localhost:9222
```

---

## 🛡️ Additional Best Practices

### mDNS Information Disclosure

**The Mistake:**
```json
{
  "discovery": {
    "mdns": { "mode": "full" }  // Exposes cliPath, sshPort
  }
}
```

**Fix:**
```json
{
  "discovery": {
    "mdns": { "mode": "minimal" }  // Hide sensitive info
  }
}
```

### Weak Models for Tool-Enabled Agents

**The Risk:**
Older models (like Haiku, Sonnet) are more susceptible to:
- Prompt injection
- Tool misuse
- Instruction hijacking

**Recommendation:**
```json
{
  "agents": {
    "defaults": {
      "model": "claude-opus-4-20250514"  // Use latest Opus
    }
  }
}
```

---

## 🔍 How to Audit Your Setup

Run OpenClaw's built-in security audit:

```bash
# Quick check
openclaw security audit

# Deep scan with live probe
openclaw security audit --deep

# Auto-fix common issues
openclaw security audit --fix
```

**What It Checks:**
- ✅ Inbound access policies (DMs, groups)
- ✅ Tool blast radius (elevated tools)
- ✅ Network exposure (bind addresses, ports)
- ✅ Browser control exposure
- ✅ Local disk permissions
- ✅ Plugins and extensions
- ✅ Model hygiene (legacy vs modern)

---

## 📋 Security Checklist for New Deployments

Before exposing OpenClaw to the internet:

- [ ] Gateway bound to `127.0.0.1` only (not `0.0.0.0`)
- [ ] Strong authentication (token, not default password)
- [ ] DM policy set to `pairing` or `allowlist` (not `open`)
- [ ] Group policy requires `@mention` (unless using allowlist)
- [ ] Filesystem permissions: `700` for dirs, `600` for files
- [ ] API keys in environment variables, not config files
- [ ] Logging redaction enabled for sensitive data
- [ ] Docker running as non-root user
- [ ] Elevated tools restricted to trusted senders
- [ ] Browser control NOT exposed to internet
- [ ] Using modern, instruction-hardened model
- [ ] Tailscale Serve used instead of port forwarding
- [ ] `.gitignore` excludes sensitive files

---

## 🆘 If You Think You're Compromised

1. **Stop the blast radius:**
   - Disable elevated tools
   - Set DMs to `disabled` or remove open allowlists
   - Switch Gateway to loopback-only

2. **Lock down access:**
   - Change all passwords/tokens
   - Review session logs for unexpected tool calls

3. **Audit:**
   ```bash
   openclaw security audit --deep
   ```

4. **Check for persistence:**
   ```bash
   # Check for suspicious cron jobs
   crontab -l
   
   # Check for unknown system users
   cat /etc/passwd
   ```

5. **Report:**
   - Email: security@openclaw.ai
   - Don't post publicly until fixed

---

## 📚 Learn More

- **Full Security Docs:** https://docs.openclaw.ai/gateway/security
- **Security Policy:** https://github.com/openclaw/openclaw/blob/main/SECURITY.md
- **Trust Center:** https://trust.openclaw.ai
- **Report Issues:** security@openclaw.ai

---

**Remember:** Security is a process, not a product. Start strict, widen as you gain trust. 🦅
