# Health Tracker

**Analyzing health data from Withings scales and Apple Health**

## 🎯 What It Does

- **Weight tracking** from Withings smart scales
- **Sleep analysis** from Withings/Nokia devices
- **Activity data** from step counts and movement
- **Trends and correlations** between metrics

## 🚀 Quick Start (Withings)

### 1. Register Withings App

Go to: https://account.withings.com/partner/add

- Fill in app details
- Callback URL: `http://localhost:8080/withings/callback`
- Copy Client ID and Consumer Secret

### 2. Authorize

```bash
cd /root/.openclaw/workspace/skills/health-tracker/scripts
./withings-auth.sh
```

Follow the prompts to authorize the app.

### 3. Fetch Data

```bash
# Get all data
./withings-fetch.sh all

# Or specific types
./withings-fetch.sh weight
./withings-fetch.sh sleep
./withings-fetch.sh activity
```

### 4. Analyze

```bash
# Weight trends
./analyze-health.py weight

# Sleep patterns
./analyze-health.py sleep

# Correlations (coming soon)
./analyze-health.py correlation
```

## 📊 Example Output

```
📊 Weight Analysis
==================================================
📅 Period: 2026-01-15 → 2026-02-10 (26 days)

Current Weight: 82.5 kg
7-Day Average: 83.1 kg
Overall Average: 84.2 kg
Range: 81.0 - 86.5 kg

📈 Total Change: -3.5 kg (26 days)
📊 Rate: -0.94 kg/week

🟢 Trend: Losing weight (-0.94 kg/week)

Recent Measurements:
  2026-02-08: 82.3 kg (Body fat: 18.5%)
  2026-02-09: 82.5 kg (Body fat: 18.2%)
  2026-02-10: 82.5 kg (Body fat: 18.3%)
```

## 📁 File Structure

```
health-tracker/
├── SKILL.md              # Documentation
├── README.md             # This file
├── withings-creds.sh     # OAuth credentials (auto-generated)
├── scripts/
│   ├── withings-auth.sh  # OAuth authorization
│   ├── withings-fetch.sh # Fetch data from API
│   ├── analyze-health.py # Statistical analysis
│   └── data/
│       ├── weight-raw.json
│       ├── sleep-raw.json
│       └── activity-raw.json
```

## 🔐 Security

- Credentials stored locally (`chmod 600`)
- No data sent to external services
- OAuth tokens auto-refreshed
- Data stays on your machine

## 📱 Supported Devices

- ✅ Withings Body (+) / Smart scales
- ✅ Withings ScanWatch
- ✅ Withings Sleep Analyzer
- ✅ Nokia Health devices
- ⏳ Apple Health export (coming soon)

## 🔄 Automation

Set up automatic data fetching with cron:

```bash
# Fetch data every day at 8 AM
0 8 * * * /root/.openclaw/workspace/skills/health-tracker/scripts/withings-fetch.sh all
```

## 📈 Next Steps

1. Connect your Withings account
2. Fetch first batch of data
3. Review weight trends
4. Set up daily automation

## 🆘 Troubleshooting

**"Access token expired":**
```bash
# Token auto-refreshes, but if it fails:
./withings-auth.sh
```

**"No sleep data":**
- Sleep data requires compatible device
- Check Health Mate app settings
- Ensure sleep tracking is enabled

**"OAuth error":**
- Verify Client ID and Secret
- Check Callback URL matches
- Re-run `withings-auth.sh`

---

**Made with ❤️ for health tracking enthusiasts**

Questions? Check `/root/.openclaw/workspace/skills/health-tracker/SKILL.md`
