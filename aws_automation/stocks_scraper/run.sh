#!/bin/bash

# Navigate to the project directory
cd "$(dirname "$0")"

# Activate virtual environment if it exists
if [ -d "venv" ]; then
    source venv/bin/activate
elif [ -d "../venv" ]; then
    source ../venv/bin/activate
fi

echo "🚀 Starting EGX Centralized Market Engine..."

# Run the centralized engine
# We use python3 -u for unbuffered output to ensure logs are visible immediately
python3 -u centralized_engine.py

echo "🛑 Engine stopped."
