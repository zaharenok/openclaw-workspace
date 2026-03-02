# Content Calendar System

## Overview

The content calendar system enables:
- Plan posts in advance
- Get approval before publishing
- Auto-publish approved posts
- Track post history and analytics

## Data Format

```json
{
  "posts": {
    "post_1": {
      "id": "post_1",
      "text": "Post content here...",
      "image": "/path/to/image.png",
      "scheduled_at": "2025-02-15T10:00:00",
      "status": "pending",  // pending | approved | skipped | posted
      "created_at": "2025-02-11T09:00:00",
      "posted_at": null
    }
  }
}
```

## Webhook API

**Endpoint:** `POST http://localhost:8401/`

**Actions:**

1. **Approve post**
   ```json
   {
     "action": "approve",
     "post_id": "post_1"
   }
   ```

2. **Edit post** (simple)
   ```json
   {
     "action": "edit",
     "post_id": "post_1",
     "edit_text": "old text -> new text"
   }
   ```

3. **Skip post**
   ```json
   {
     "action": "skip",
     "post_id": "post_1"
   }
   ```

## Auto-Publishing

Cron job checks every 15 minutes for approved posts past their scheduled time:

```bash
# crontab -e
*/15 * * * * /path/to/auto-publish.sh
```

## Image Strategy

**Best practices:**
- Use real photos (not stock photos)
- Add AI-generated story overlays (text on images)
- Optimize for LinkedIn (1200x627px recommended)
- Include alt text for accessibility

## Workflow

1. **Agent** suggests post → saves to `cc-data.json` with status `pending`
2. **Frontend UI** shows pending posts for approval
3. **User** clicks approve/edit/skip → webhook updates status
4. **Cron** checks for approved posts → auto-publishes via LinkedIn CLI
5. **Agent** tracks posted content for analytics
