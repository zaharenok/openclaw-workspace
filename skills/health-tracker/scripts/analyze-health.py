#!/usr/bin/env python3
"""
Health data analyzer for weight, sleep, and activity
Usage: ./analyze-health.py [weight|sleep|correlation]
"""

import sys
import json
import os
from datetime import datetime, timedelta
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
DATA_DIR = SCRIPT_DIR / '../data'

def parse_weight_csv():
    """Parse weight data from CSV"""
    csv_file = DATA_DIR / 'weight-raw.json'
    
    if not csv_file.exists():
        print("❌ Weight data not found. Run withings-fetch.sh first")
        return []
    
    with open(csv_file) as f:
        data = json.load(f)
    
    if data.get('status') != 0:
        return []
    
    measures = data.get('body', {}).get('measuregrps', [])
    weights = []
    
    for m in measures:
        timestamp = m.get('date', 0)
        date = datetime.fromtimestamp(timestamp)
        
        weight_kg = None
        fat_pct = None
        
        for measure in m['measures']:
            if measure['type'] == 1:  # Weight in kg
                weight_kg = round(measure['value'] * 10**measure['unit'], 2)
            elif measure['type'] == 8:  # Fat percent
                fat_pct = round(measure['value'] * 10**measure['unit'], 2)
        
        if weight_kg:
            weights.append({
                'date': date,
                'weight': weight_kg,
                'fat': fat_pct
            })
    
    return sorted(weights, key=lambda x: x['date'])

def analyze_weight():
    """Analyze weight trends"""
    weights = parse_weight_csv()
    
    if not weights or len(weights) < 2:
        print("❌ Not enough weight data")
        return
    
    # Latest vs earliest
    latest = weights[-1]
    earliest = weights[0]
    
    weight_change = latest['weight'] - earliest['weight']
    days = (latest['date'] - earliest['date']).days
    rate_per_week = (weight_change / days) * 7 if days > 0 else 0
    
    # Statistics
    all_weights = [w['weight'] for w in weights]
    avg_weight = sum(all_weights) / len(all_weights)
    min_weight = min(all_weights)
    max_weight = max(all_weights)
    
    # Last 7 days
    week_ago = datetime.now() - timedelta(days=7)
    recent = [w for w in weights if w['date'] >= week_ago]
    recent_avg = sum([w['weight'] for w in recent]) / len(recent) if recent else avg_weight
    
    # Display
    print("📊 Weight Analysis")
    print("=" * 50)
    print(f"📅 Period: {earliest['date'].strftime('%Y-%m-%d')} → {latest['date'].strftime('%Y-%m-%d')} ({days} days)")
    print()
    print(f"Current Weight: {latest['weight']:.1f} kg")
    print(f"7-Day Average: {recent_avg:.1f} kg")
    print(f"Overall Average: {avg_weight:.1f} kg")
    print(f"Range: {min_weight:.1f} - {max_weight:.1f} kg")
    print()
    print(f"📈 Total Change: {weight_change:+.1f} kg ({days} days)")
    print(f"📊 Rate: {rate_per_week:+.2f} kg/week")
    print()
    
    # Trend
    if rate_per_week > 0.1:
        print("🔴 Trend: Gaining weight (+{:.2f} kg/week)".format(abs(rate_per_week)))
    elif rate_per_week < -0.1:
        print("🟢 Trend: Losing weight (-{:.2f} kg/week)".format(abs(rate_per_week)))
    else:
        print("⚪ Trend: Stable")
    
    print()
    print("Recent Measurements:")
    for w in weights[-5:]:
        print(f"  {w['date'].strftime('%Y-%m-%d')}: {w['weight']:.1f} kg" + 
              (f" (Body fat: {w['fat']}%)" if w.get('fat') else ""))

def analyze_sleep():
    """Analyze sleep patterns"""
    sleep_file = DATA_DIR / 'sleep-raw.json'
    
    if not sleep_file.exists():
        print("❌ Sleep data not found. Run withings-fetch.sh first")
        return
    
    with open(sleep_file) as f:
        data = json.load(f)
    
    if data.get('status') != 0:
        print("❌ No sleep data available")
        return
    
    series = data.get('body', {}).get('series', [])
    
    if not series:
        print("❌ No sleep records found")
        return
    
    print("😴 Sleep Analysis")
    print("=" * 50)
    
    total_sessions = len(series)
    total_sleep = sum([s.get('duration', 0) for s in series]) / 3600
    avg_duration = total_sleep / total_sessions
    
    # Sleep stages
    total_deep = sum([s.get('data', {}).get('deep_sleep_duration', 0) for s in series]) / 3600
    total_light = sum([s.get('data', {}).get('light_sleep_duration', 0) for s in series]) / 3600
    total_rem = sum([s.get('data', {}).get('rem_sleep_duration', 0) for s in series]) / 3600
    
    avg_deep = (total_deep / total_sessions * 60) / avg_duration * 60  # percentage
    avg_light = (total_light / total_sessions * 60) / avg_duration * 60
    avg_rem = (total_rem / total_sessions * 60) / avg_duration * 60
    
    print(f"📅 Sessions: {total_sessions} nights")
    print(f"⏱️  Average Duration: {avg_duration:.1f} hours")
    print()
    print("Sleep Stages (Average):")
    print(f"  🌑 Deep Sleep: {avg_deep:.1f}% (target: 15-20%)")
    print(f"  🌕 Light Sleep: {avg_light:.1f}%")
    print(f"  🌙 REM Sleep: {avg_rem:.1f}% (target: 20-25%)")
    print()
    
    # Last 7 nights
    print("Recent Nights:")
    for s in series[-7:]:
        date = datetime.fromtimestamp(s.get('startdate', 0))
        duration = s.get('duration', 0) / 3600
        efficiency = s.get('data', {}).get('sleep_efficiency', 0)
        deep = s.get('data', {}).get('deep_sleep_duration', 0) / 3600
        
        quality = "😴" if efficiency > 85 else "😊" if efficiency > 75 else "😐"
        
        print(f"  {date.strftime('%a %m/%d')}: {duration:.1f}h " +
              f"Deep: {deep:.1f}h Eff: {efficiency:.0f}% {quality}")

def correlation_analysis():
    """Correlate weight with sleep"""
    print("🔗 Correlation Analysis")
    print("=" * 50)
    print("⚠️ Requires more data points")
    print("   Run withings-fetch.sh daily for 2+ weeks")

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: analyze-health.py [weight|sleep|correlation]")
        sys.exit(1)
    
    cmd = sys.argv[1]
    
    if cmd == 'weight':
        analyze_weight()
    elif cmd == 'sleep':
        analyze_sleep()
    elif cmd == 'correlation':
        correlation_analysis()
    else:
        print("❌ Unknown command: {}".format(cmd))
