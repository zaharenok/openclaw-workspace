#!/usr/bin/env python3
"""
📧 Send Austria News Digest via Email
Отправляет новости с botforoleg@gmail.com на olegzakharchenko@gmail.com

Использует Gmail REST API с OAuth2
"""

import requests
import base64
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import json
import sys
from datetime import datetime

# Config
CONFIG_FILE = "/root/.config/gogcli/keyring/botforoleg.json"
CREDENTIALS_FILE = "/root/.config/gogcli/credentials.json"

def get_access_token():
    """Получает access токен из config"""
    try:
        # Read refresh token
        with open(CONFIG_FILE) as f:
            config = json.load(f)
            refresh_token = config.get('refresh_token')
        
        # Read credentials
        with open(CREDENTIALS_FILE) as f:
            credentials = json.load(f)
            client_id = credentials.get('client_id')
            client_secret = credentials.get('client_secret')
        
        # Refresh access token
        response = requests.post(
            'https://oauth2.googleapis.com/token',
            data={
                'client_id': client_id,
                'client_secret': client_secret,
                'refresh_token': refresh_token,
                'grant_type': 'refresh_token'
            }
        )
        
        if response.status_code != 200:
            print(f"❌ Failed to get access token: {response.text}", file=sys.stderr)
            sys.exit(1)
        
        access_token = response.json().get('access_token')
        
        # Update config with new access token
        expires_in = response.json().get('expires_in', 3600)
        import time
        expires_at = int(time.time()) + expires_in
        
        config['access_token'] = access_token
        config['expires_at'] = expires_at
        
        with open(CONFIG_FILE, 'w') as f:
            json.dump(config, f, indent=2)
        
        print(f"✅ Got access token, expires at {expires_at}")
        return access_token
        
    except Exception as e:
        print(f"❌ Error getting access token: {e}", file=sys.stderr)
        sys.exit(1)

def send_email(to_email, subject, html_body):
    """Отправляет email через Gmail API"""
    access_token = get_access_token()
    
    # Create message
    message = MIMEMultipart('alternative')
    message['Subject'] = subject
    message['To'] = to_email
    message['From'] = 'botforoleg@gmail.com'
    
    # Attach HTML body
    html_part = MIMEText(html_body, 'html', 'utf-8')
    message.attach(html_part)
    
    # Encode message
    raw = base64.urlsafe_b64encode(message.as_bytes()).decode()
    
    # Send via Gmail API
    response = requests.post(
        'https://www.googleapis.com/gmail/v1/users/me/messages/send',
        headers={'Authorization': f'Bearer {access_token}'},
        json={'raw': raw}
    )
    
    if response.status_code == 200:
        print(f"✅ Email sent to {to_email}")
        return True
    else:
        print(f"❌ Failed to send email: {response.text}", file=sys.stderr)
        return False

def create_html_digest(articles):
    """Создаёт HTML дайджест из статей"""
    
    # Group by source
    by_source = {}
    for article in articles:
        source = article['source']
        if source not in by_source:
            by_source[source] = []
        by_source[source].append(article)
    
    html = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body {{ font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }}
        h1 {{ color: #c4061b; }}
        h2 {{ color: #333; border-bottom: 2px solid #c4061b; padding-bottom: 10px; }}
        .source {{ background: #f0f0f0; padding: 15px; margin: 20px 0; border-radius: 8px; }}
        .article {{ margin: 15px 0; padding: 10px; border-left: 3px solid #e0e0e0; }}
        .article:hover {{ background: #fafafa; }}
        .meta {{ color: #666; font-size: 12px; }}
        a {{ color: #0066cc; text-decoration: none; }}
        a:hover {{ text-decoration: underline; }}
        .stats {{ background: #e8f4f8; padding: 15px; border-radius: 8px; margin: 20px 0; }}
    </style>
</head>
<body>
    <h1>🇦🇹 Австрийские новости</h1>
    <p><strong>📊 {len(articles)} статей собрано</strong></p>
    
    <div class="stats">
        Источников: {len(by_source)}<br>
        Категорий: {', '.join(set(a['category'] for a in articles))}
    </div>
"""
    
    # Add articles by source
    for source, articles_list in by_source.items():
        html += f"<h2>📰 {source}</h2>\n"
        for article in articles_list:
            html += f"""
    <div class="article">
        <a href="{article['url']}" target="_blank">
            <strong>{article['title']}</strong>
        </a><br>
        <span class="meta">
            🏷️ {article['category'].upper()} |
            📅 {article.get('published_at', '')[:10]}
        </span>
    </div>
"""
    
    html += """
</body>
</html>
"""
    
    return html

def main():
    """Главная функция"""
    import feedparser
    
    # Fetch news via RSS
    print("📰 Fetching news...")
    
    # Simple fetch - reuse existing code or just fetch from known sources
    articles = []
    
    # For demo, create sample articles (would normally use collect-austria-news.py output)
    # In production, this would import the RSS fetching logic
    
    # Create HTML digest
    html_body = create_html_digest(articles)
    
    # Send email
    to_email = "olegzakharchenko@gmail.com"
    subject = f"🇦🇹 Австрийские новости - {datetime.now().strftime('%d.%m.%Y')}"
    
    print(f"📧 Sending email to {to_email}...")
    
    if send_email(to_email, subject, html_body):
        print("✅ Success! Check your inbox.")
    else:
        print("❌ Failed to send email")
        sys.exit(1)

if __name__ == "__main__":
    main()
