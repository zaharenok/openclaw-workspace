#!/usr/bin/env python3
"""
🇦🇹 Austria News Collector (RSS version)
Собирает новости через RSS feeds и сохраняет в JSON для отправки email
"""

import feedparser
import requests
from datetime import datetime, timedelta
import json
import sys

# Webhook URL
WEBHOOK_URL = "https://n8n.aaagency.at/webhook/bd80e8cd-1a64-46ee-98ac-1f4299b9e963"

# RSS Feeds
RSS_FEEDS = [
    {"name": "ORF", "url": "https://orf.at/rss", "lang": "de"},
    {"name": "Kurier", "url": "https://kurier.at/rss", "lang": "de"},
    {"name": "Heute", "url": "https://heute.at/rss", "lang": "de"},
    {"name": "DiePresse", "url": "https://diepresse.com/rss", "lang": "de"},
    {"name": "KleineZeitung", "url": "https://kleinezeitung.at/rss", "lang": "de"},
    {"name": "Nachrichten", "url": "https://nachrichten.at/rss", "lang": "de"},
    {"name": "OE24", "url": "https://oe24.at/rss", "lang": "de"}
]

def fetch_rss_articles(feed):
    """Парсит статьи из RSS feed"""
    try:
        rss = feedparser.parse(feed["url"])
        articles = []
        for entry in rss.entries[:15]:
            title = entry.get('title', '')
            link = entry.get('link', '')
            image = None
            if 'enclosures' in entry and len(entry['enclosures']) > 0:
                image = entry['enclosures'][0].get('href')
            elif 'media_content' in entry and len(entry['media_content']) > 0:
                image = entry['media_content'][0].get('url')
            
            if any(keyword in title.lower() for keyword in [
                'wirtschaft', 'politik', 'soziales', 'bildung', 'gesundheit',
                'verkehr', 'klima', 'finanz', 'arbeitsmarkt', 'energie'
            ]):
                articles.append({
                    "title": title, "url": link, "image": image,
                    "source": feed["name"], "language": feed["lang"],
                    "published_at": entry.get('published', datetime.now().isoformat()),
                    "summary": entry.get('summary', '')[:200],
                    "category": categorize_article(title)
                })
        return articles
    except Exception as e:
        print(f"❌ Error fetching {feed['name']}: {e}", file=sys.stderr)
        return []

def categorize_article(title):
    """Определяет категорию статьи"""
    title_lower = title.lower()
    if any(kw in title_lower for kw in ['wirtschaft', 'börse', 'aktien']):
        return 'wirtschaft'
    elif any(kw in title_lower for kw in ['politik', 'regierung', 'wahl']):
        return 'politik'
    elif any(kw in title_lower for kw in ['unfall', 'mord', 'diebstahl']):
        return 'kriminal'
    else:
        return 'gesellschaft'

def main():
    print("🇦🇹 Collecting Austria news via RSS feeds...")
    
    all_articles = []
    for feed in RSS_FEEDS:
        print(f"📰 Fetching RSS from {feed['name']}...")
        articles = fetch_rss_articles(feed)
        all_articles.extend(articles)
    
    # Remove duplicates by URL
    seen_urls = set()
    unique_articles = []
    for article in all_articles:
        if article['url'] not in seen_urls:
            seen_urls.add(article['url'])
            unique_articles.append(article)
    
    print(f"📊 Total unique articles: {len(unique_articles)}")
    
    # Save to JSON file
    output_file = '/tmp/news-articles.json'
    payload = {
        "articles": unique_articles,
        "total": len(unique_articles),
        "sources": len(RSS_FEEDS),
        "collected_at": datetime.now().isoformat()
    }
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
    
    print(f"💾 Saved {len(unique_articles)} articles to {output_file}")
    
    # Send to webhook
    print(f"📤 Sending to n8n webhook...")
    try:
        response = requests.post(WEBHOOK_URL, json=payload, timeout=30)
        response.raise_for_status()
        print(f"✅ Success! Webhook responded: {response.status_code}")
        print(f"📊 Sent {len(unique_articles)} articles from {len(RSS_FEEDS)} sources")
    except Exception as e:
        print(f"❌ Error: {e}", file=sys.stderr)
        print(f"💾 Articles saved to {output_file} - can be sent manually")

if __name__ == "__main__":
    main()
