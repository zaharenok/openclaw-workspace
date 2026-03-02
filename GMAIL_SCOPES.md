# Gmail Scopes Configuration

## Current Scopes (Read-Only)
```
https://www.googleapis.com/auth/gmail.readonly
```

## Required Scopes for Deletion

### Option 1: Move to Trash (Recommended)
```
https://www.googleapis.com/auth/gmail.modify
```
- Can move messages to trash
- Can mark as read/unread
- Can add/remove labels
- Safer (can recover from trash)

### Option 2: Permanent Delete
```
https://www.googleapis.com/auth/gmail.delete
```
- Can permanently delete messages
- Cannot recover
- Use with caution

## How to Add Scopes

### Step 1: Go to Google Admin Console
1. Visit: https://admin.google.com/
2. Navigate to: **Security** → **API controls** → **Domain-wide delegation**

### Step 2: Edit Service Account
1. Find Client ID: `109684975311567650811`
2. Click **Edit**
3. Add the following scopes (one per line):

```
https://www.googleapis.com/auth/gmail.readonly
https://www.googleapis.com/auth/gmail.modify
https://www.googleapis.com/auth/calendar
https://www.googleapis.com/auth/drive.readonly
https://www.googleapis.com/auth/spreadsheets.readonly
https://www.googleapis.com/auth/documents.readonly
https://www.googleapis.com/auth/contacts.readonly
https://www.googleapis.com/auth/userinfo.email
```

### Step 3: Authorize
1. Click **Authorize**
2. Wait a few minutes for propagation

## Verify Scopes

After updating, run this to verify:

```bash
# Check current access token info
curl -s "https://www.googleapis.com/oauth2/v3/tokeninfo?access_token=$(jq -r '.access_token' /root/.config/gogcli/keyring/botforoleg.json)" | jq '.scope'
```

Should show:
```
https://www.googleapis.com/auth/gmail.modify
https://www.googleapis.com/auth/gmail.readonly
...
```

## Testing Deletion

After scopes are updated, test with:

```bash
# Move message to trash
MESSAGE_ID="message-id"
curl -X POST "https://www.googleapis.com/gmail/v1/users/me/messages/$MESSAGE_ID/trash" \
  -H "Authorization: Bearer $(jq -r '.access_token' /root/.config/gogcli/keyring/botforoleg.json)"
```

## Safety Notes

- ✅ **Recommended:** Use `gmail.modify` (moves to trash, recoverable)
- ⚠️ **Dangerous:** Use `gmail.delete` (permanent, cannot recover)
- 🔒 **Principle of least privilege:** Only grant necessary permissions

## Service Account Details

- **Client ID:** 109684975311567650811
- **Client Email:** bot-openclaw@bot-project-486819.iam.gserviceaccount.com
- **Project:** bot-project-486819
- **Impersonating:** olegzakharchenko@gmail.com

---

**Created:** 2026-02-10 19:08 UTC
**Status:** ⏳ Awaiting user action in Google Admin Console
