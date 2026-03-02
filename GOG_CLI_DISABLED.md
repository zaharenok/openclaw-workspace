# gog CLI - DISABLED

**Status:** ❌ Disabled (OAuth client "disabled" in Google Cloud Console)
**Date:** 2026-02-10
**Reason:** gog CLI uses client_id 894034812238-80tvutgc7dhd6hf2gplf63pcra8p5k60 which is marked as "disabled_client"

## Alternative: Use Wrapper Script

**Working solution:** `/root/.openclaw/workspace/bin/check-gmail.sh`

This script:
- ✅ Uses OAuth2 refresh token directly
- ✅ Auto-updates access token
- ✅ Works with Gmail API
- ✅ No gog CLI dependency

## To Re-enable gog CLI

Fix in Google Cloud Console:
1. APIs & Services → OAuth consent screen
2. Set to "In Production" or add test users
3. APIs & Services → Credentials
4. Check OAuth client status

## Files Preserved
- `/root/.config/gogcli/` - configuration kept for future re-enable
- Refresh token still valid and working
