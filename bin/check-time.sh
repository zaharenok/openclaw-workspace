#!/bin/bash
# Quick timezone check for Vienna vs UTC
echo "🕐 Time Check"
echo "============="
echo "UTC:     $(date -u '+%Y-%m-%d %H:%M:%S %Z')"
echo "Vienna:  $(TZ='Europe/Vienna' date '+%Y-%m-%d %H:%M:%S %Z (%z)')"
echo ""
echo "Difference: Vienna is UTC+1 (winter) or UTC+2 (summer)"
