#!/bin/bash
# Stop Heliactyl panel

cd "$(dirname "$0")"

# Check if PID file exists
if [ ! -f ./storage/heliactyl.pid ]; then
    echo "PID file not found. Panel may not be running."
    # Try to kill by port as fallback
    fuser -k -n tcp 3000 2>/dev/null && echo "Killed process on port 3000"
    exit 0
fi

# Read PID and stop
PID=$(cat ./storage/heliactyl.pid)

if kill -0 $PID 2>/dev/null; then
    kill -TERM $PID
    echo "Panel stopped (PID: $PID)"
    rm -f ./storage/heliactyl.pid
else
    echo "Process not running (stale PID file)"
    rm -f ./storage/heliactyl.pid
fi
