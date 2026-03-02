# LinkedIn DOM Patterns

**Note:** LinkedIn updates their UI frequently. This document tracks known patterns and how to handle breaking changes.

## Post Selector Evolution

**2024-2025:**
```
div.feed-shared-update-v2
```

**2023 and earlier:**
```
div.feed-shared-update
```

**Strategy:** Use multiple selectors with fallbacks:
```python
selectors = [
    "div.feed-shared-update-v2",
    "div.feed-shared-update",
    "div[data-id*='urn:li:activity:']"
]
```

## Comment Selectors

**Current:**
```
article.comments-comment-item
```

**Evolution:**
- 2024: `article.comments-comment-item`
- 2023: `div.comments-comment-item`
- 2022: `div.comment-item`

## @Mention Dropdown

**Pattern:**
```
div.typeahead-result → div.typeahead-result-item → span.actor-name
```

**Timing:** Dropdown appears after typing `@` + first letter
**Wait:** `wait_for_selector("div.typeahead-result", timeout=3000)`

## Modal Selectors

**Image editor modal:**
```
div.artdeco-modal
```

**Note:** LinkedIn uses `artdeco-modal` for many modals. Always check modal content before interacting.

## Debugging Strategy

When selectors break:
1. Enable debug mode: `LINKEDIN_DEBUG=1`
2. Run command that fails
3. Check screenshots in `/tmp/linkedin_debug_*.png`
4. Use browser DevTools to find updated selectors
5. Update `scripts/lib/selectors.py`

## Rate Limit Detection

LinkedIn shows rate limit warnings:
```
div.artdeco-banner--error:has-text("You've reached the limit")
```

**Action:** When detected, stop all actions for 24h.

## Login Detection

**Logged in:**
```
a[data-control-name='view_profile']
```

**Not logged in:**
```
input#username
```

**Strategy:** Always check for login page before automation:
```python
if page.query_selector("input#username"):
    raise Exception("Session expired - manual login required")
```

## Known Breaking Changes

**2024-12:** Comment submit button changed class
**2024-09:** Image editor modal added new step
**2024-06:** Post editor switched to Quill-based editor
**2024-03:** Feed post structure updated

**Update frequency:** Every 3-6 months

## Maintenance Checklist

- [ ] Test all commands monthly
- [ ] Update selectors when LinkedIn updates UI
- [ ] Keep screenshots of working state for comparison
- [ ] Document breaking changes in this file
