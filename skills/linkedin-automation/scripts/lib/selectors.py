#!/usr/bin/env python3
"""LinkedIn DOM selectors for automation."""

# Feed and navigation
SELECTORS = {
    # Feed
    "feed_post": "div.feed-shared-update-v2",
    "post_author": ".update-components-actor__name",
    "post_text": ".feed-shared-text",
    "post_link": "a[href*='/posts/']",
    
    # Create post
    "post_button": "button[data-control-name='nav.post']",
    "post_textarea": "div.ql-editor",
    "post_submit": "button.share-actions__primary-action",
    "post_image_button": "button[aria-label='Add a photo']",
    "post_image_input": "input[type='file'][accept*='image']",
    
    # Image editor modal
    "image_editor_modal": "div.artdeco-modal",
    "image_editor_done": "button.artdeco-button--primary",
    "image_alt_text": "input[placeholder*='alt text']",
    
    # Comments
    "comment_button": "button[data-control-name='comment']",
    "comment_input": "div.ql-editor[contenteditable='true']",
    "comment_submit": "button.comments-comment-box__submit-button",
    "comment_item": "article.comments-comment-item",
    "comment_text": ".comments-comment-item__main-content",
    "comment_menu": "button[aria-label*='Options']",
    "comment_edit": "span[aria-label='Edit']",
    "comment_delete": "span[aria-label='Delete']",
    
    # @Mentions
    "mention_dropdown": "div.typeahead-result",
    "mention_item": "div.typeahead-result-item",
    "mention_name": "span.actor-name",
    
    # Repost
    "repost_button": "button[data-control-name='share']",
    "repost_with_thoughts": "button[aria-label='Repost with your thoughts']",
    "repost_textarea": "div.ql-editor",
    "repost_submit": "button.share-actions__primary-action",
    
    # Analytics
    "analytics_views": "span[data-control-name='views']",
    "analytics_likes": "button[data-control-name='likes']",
    "analytics_comments": "button[data-control-name='comments']",
    "analytics_reposts": "button[data-control-name='reposts']",
    
    # Profile
    "profile_nav": "a[data-control-name='view_profile']",
    "profile_followers": "span[data-control-name='follower_count']",
    "profile_views": "a[href*='/detail/recent-activity/shares/']",
    
    # Login detection
    "login_page": "input#username",
    "logged_in": "a[data-control-name='view_profile']",
    
    # Activity
    "activity_post": "div.profile-creator-shared-feed-update",
    "activity_load_more": "button.scaffold-finite-scroll__load-button",
}

# LinkedIn URLs
URLS = {
    "base": "https://www.linkedin.com",
    "feed": "https://www.linkedin.com/feed",
    "profile": "https://www.linkedin.com/in/me",
    "mynetwork": "https://www.linkedin.com/mynetwork",
    "notifications": "https://www.linkedin.com/notifications",
}
