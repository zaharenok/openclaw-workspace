#!/bin/bash
# Security Scan Script (Fast version)
# Запускается каждые 3 часа для выявления угроз

set -e

THREATS_FOUND=0
echo "=== Security Scan $(date -u +"%Y-%m-%d %H:%M:%S UTC") ==="

# 1. Проверка на известные майнеры
echo "[1] Checking for crypto miners..."
MINER_COUNT=$(ps aux | grep -E "(Sofia|xmrig|minerd|cgminer)" | grep -v grep | wc -l)
if [ "$MINER_COUNT" -gt 0 ]; then
    echo "⚠️  MINER PROCESS DETECTED!"
    ps aux | grep -E "(Sofia|xmrig|minerd|cgminer)" | grep -v grep
    THREATS_FOUND=1
else
    echo "✅ No miner processes"
fi

# 2. Проверка CPU steal time
echo "[2] Checking CPU steal time..."
STEAL=$(top -b -n1 | grep "%Cpu" | awk '{print $8}' | cut -d'%' -f1)
STEAL_INT=${STEAL%.*}
if [ "$STEAL_INT" -gt 50 ]; then
    echo "⚠️  HIGH CPU STEAL: ${STEAL}%"
    THREATS_FOUND=1
else
    echo "✅ CPU steal normal: ${STEAL}%"
fi

# 3. Проверка load average
echo "[3] Checking system load..."
LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | cut -d',' -f1)
LOAD_INT=${LOAD%.*}
if [ "$LOAD_INT" -gt 10 ]; then
    echo "⚠️  HIGH LOAD: $LOAD"
    THREATS_FOUND=1
else
    echo "✅ Load normal: $LOAD"
fi

# 4. Проверка неудачных SSH попыток
echo "[4] Checking SSH brute force..."
FAILED_LAST_HOUR=$(grep "Failed password" /var/log/auth.log 2>/dev/null | grep "$(date +'%Y-%m-%d %H')" | wc -l)
if [ "$FAILED_LAST_HOUR" -gt 50 ]; then
    echo "⚠️  HIGH BRUTE FORCE: $FAILED_LAST_HOUR attempts"
    THREATS_FOUND=1
else
    echo "✅ SSH brute force normal: $FAILED_LAST_HOUR"
fi

# Результат
if [ "$THREATS_FOUND" -eq 1 ]; then
    echo "🚨 SECURITY THREATS DETECTED!"
    exit 1
else
    echo "✅ Security scan passed - no threats"
    exit 0
fi
