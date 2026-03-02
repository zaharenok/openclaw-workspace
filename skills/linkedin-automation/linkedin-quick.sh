#!/bin/bash
# LinkedIn Automation Quick Launch Script

BASE_DIR="/root/.openclaw/workspace/skills/linkedin-automation"
VENV_PYTHON="$BASE_DIR/venv/bin/python"
CLI="$BASE_DIR/scripts/linkedin.py"

# Activate virtual environment and run command
cd "$BASE_DIR" || exit 1
source venv/bin/activate

# Run the LinkedIn CLI with all arguments
"$VENV_PYTHON" "$CLI" "$@"
