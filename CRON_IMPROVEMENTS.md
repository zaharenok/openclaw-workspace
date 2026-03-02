# Cron Tasks Improvements - 2026-02-10

## Overview
All periodic tasks now use **smart change detection** - they only run when files have actually changed. This saves:
- CPU resources
- API calls (GitHub, Gmail, etc.)
- Disk I/O
- Log spam

## What Changed

### 1. backup-to-github.sh ✅ (UPDATED)
**Before:** Always ran pull/commit/push, even with no changes
**After:**
- Checks git state FIRST
- Exits immediately if no changes
- Shows what files changed before committing
- Counts changed files

### 2. check-secrets.sh ✅ (UPDATED)
**Before:** Scanned all files every time
**After:**
- Saves git state to `.secrets-check-state`
- Only scans if tracked files changed
- Re-checks if secrets were found (state not saved)

### 3. repo-maintenance.sh ✅ (NEW)
**Features:**
- Syncs all repos in `~/repos/`
- Only continues if ANY repo has changes
- Generates reports in `reports/` directory:
  - `repo-sync-YYYY-MM-DD.md` - changelog
  - `secrets-scan-YYYY-MM-DD.md` - security scan
- Updates `memory/GITHUB_REPOSITORIES.md`
- Runs trufflehog on all repos

### 4. smart-cron-runner.sh ✅ (NEW)
**Universal wrapper for any cron task:**
```bash
smart-cron-runner.sh <task-name> <script-path> [args...]
```

**How it works:**
1. Saves git state to `.cron-state/<task-name>-last-run`
2. Compares current state with previous
3. Runs script only if state changed
4. Saves state on success, retries on failure

## Usage Examples

### Direct Scripts (already smart)
```bash
# GitHub backup - only runs if changes
bin/backup-to-github.sh

# Secrets check - only runs if files changed
bin/check-secrets.sh

# Repo maintenance - only runs if repos updated
bin/repo-maintenance.sh
```

### Via Smart Cron Runner
```bash
# Wrap any script with change detection
bin/smart-cron-runner.sh my-task bin/my-script.sh

# With arguments
bin/smart-cron-runner.sh email-check bin/check-email.sh --verbose
```

## State Files Location

```
~/.openclaw/workspace/
├── .secrets-check-state              # Secrets check state
└── .cron-state/                       # Smart runner states
    ├── github-backup-last-run
    ├── secrets-check-last-run
    └── repo-maintenance-last-run
```

## Benefits

### Performance
- **Skips unnecessary work** - no changes = no execution
- **Saves API calls** - fewer GitHub/Gmail requests
- **Reduces noise** - logs only show real activity

### Reliability
- **Always checks** - runs when things actually change
- **Never skips** - doesn't rely on timestamps alone
- **Self-healing** - retries on failure (state not saved)

### Debugging
- **Clear reports** - shows exactly what changed
- **Traceable** - state files show last run
- **Testable** - can run manually anytime

## Cron Job Examples

### GitHub Backup (every hour)
```cron
0 * * * * /home/node/.openclaw/workspace/bin/backup-to-github.sh
```
**Behavior:** Only backs up if files changed since last run

### Secrets Check (daily at 3 AM)
```cron
0 3 * * * /home/node/.openclaw/workspace/bin/check-secrets.sh
```
**Behavior:** Only scans if workspace files changed

### Repo Maintenance (daily at 7 AM)
```cron
0 7 * * * /home/node/.openclaw/workspace/bin/repo-maintenance.sh
```
**Behavior:** Only syncs if any repo has changes

## Testing

You can test any script manually - they'll run regardless of state:

```bash
# Force run (ignores state)
bin/backup-to-github.sh
bin/check-secrets.sh
bin/repo-maintenance.sh
```

To see if a script would skip:
```bash
# Check state before running
cat .cron-state/github-backup-last-run
git status --porcelain | md5sum  # Current state
```

## Migration Guide

### Old Cron Jobs
```cron
# Run every hour (wasteful)
0 * * * * cd /workspace && git pull && ./backup.sh
```

### New Cron Jobs (Smart)
```cron
# Only run if changes
0 * * * * /workspace/bin/backup-to-github.sh
```

## Monitoring

All scripts return proper exit codes:
- **0** = Success (or skipped due to no changes)
- **1** = Failure (secrets found, sync error, etc.)

This means cron emails only on real problems.

---

**Created:** 2026-02-10 18:56 UTC
**Author:** Orchestrator (OpenClaw)
**Status:** ✅ Active
