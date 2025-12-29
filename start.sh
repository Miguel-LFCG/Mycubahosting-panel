#!/bin/bash
# Start Heliactyl panel

cd "$(dirname "$0")"

# Check if already running
if [ -f ./storage/heliactyl.pid ] && kill -0 $(cat ./storage/heliactyl.pid) 2>/dev/null; then
    echo "Panel is already running (PID: $(cat ./storage/heliactyl.pid))"
    exit 1
fi

# Start the panel
nohup node --no-deprecation app.js > ./logs/heliactyl.log 2>&1 &
echo $! > ./storage/heliactyl.pid

echo "Panel started (PID: $(cat ./storage/heliactyl.pid))"
echo "Logs: ./logs/heliactyl.log"
