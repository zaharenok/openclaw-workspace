---
name: health-tracker
description: "Health data analysis from Apple Health exports and Withings API. Use when analyzing weight trends, sleep patterns, step counts, heart rate data, or correlating health metrics. Supports XML parsing from Apple Health exports and OAuth integration with Withings/Nokia Health devices."
---

# Health Tracker

Parse and analyze health data from multiple sources: Apple Health exports, Withings API, and other fitness platforms.

## Quick Start

### Apple Health Export (Fastest)

```bash
# Export from Health App: Profile → Export Health Data
# Upload the ZIP file

analyze_health_data() {
  - Weight: trends, averages, goals
  - Sleep: duration, quality, phases
  - Steps: daily/weekly patterns
  - Correlations: weight vs sleep vs activity
}
```

### Withings API (OAuth 2.0)

```bash
# Step 1: Register app at https://account.withings.com/partner/add
# Step 2: Get OAuth credentials
# Step 3: Authorize and get access token

./scripts/withings-auth.sh
./scripts/withings-fetch.sh weight
./scripts/withings-fetch.sh sleep
```

## Data Sources

### 1. Apple Health Export
**File format:** XML (export.xml)
**Data types:**
- Record type: HKQuantityTypeIdentifierBodyMass
- Record type: HKCategoryTypeIdentifierSleepAnalysis
- Record type: HKQuantityTypeIdentifierStepCount

### 2. Withings API
**Endpoints:**
- GET /measure?action=getmeas - Weight, heart rate, etc.
- GET /v2/sleep - Sleep summary and sessions
- GET /v2/activity - Steps, calories, distance

**Authentication:** OAuth 2.0
**Token lifespan:** Access token (3 hours), Refresh token (ongoing)

## Analysis Features

### Weight Analysis
```python
# 7-day trend
- Average weight
- Min/max
- Trend direction (losing/gaining)
- Rate of change (kg/week)
- Goal progress
```

### Sleep Analysis
```python
# Nightly breakdown
- Total sleep time
- Deep sleep % (target: 15-20%)
- Light sleep %
- REM sleep % (target: 20-25%)
- Awake time %
- Sleep quality score (0-100)
- Bedtime/wake time patterns
```

### Correlations
```python
# Cross-metric analysis
- Sleep duration vs weight change
- Activity level vs sleep quality
- Day of week patterns
- Monthly trends
```

## Resources

### scripts/
- `parse-apple-health.py` - Parse Apple Health export.xml
- `withings-auth.sh` - OAuth authorization flow
- `withings-fetch.sh` - Fetch data from Withings API
- `analyze-health.py` - Statistical analysis and visualization

### references/
- `withings-api.md` - Complete API documentation
- `apple-health-schema.md` - HealthKit XML schema
- `health-benchmarks.md` - Recommended ranges for metrics

## Troubleshooting

**Apple Health export is huge (>100MB):**
- Use `xmllint --stream` for parsing
- Filter by record type during parsing
- Process in chunks

**Withings access token expired:**
- Refresh token is used automatically
- If refresh fails, re-run `withings-auth.sh`

**No sleep data from Withings:**
- Sleep data requires compatible device (Withings Sleep Analyzer, ScanWatch)
- Check if sleep tracking is enabled in Health Mate app

## Privacy & Security

- ✅ Credentials stored locally (encrypted with chmod 600)
- ✅ No data sent to external services
- ✅ OAuth tokens rotated automatically
- ✅ Health data stays on your machine
