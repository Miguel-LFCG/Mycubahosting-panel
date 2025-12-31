#!/bin/bash
# Restart Heliactyl panel

cd "$(dirname "$0")"

echo "=== Restarting Heliactyl Panel ==="
echo ""

# First stop attempt
echo "First stop attempt..."
./stop.sh
echo ""

# Second stop attempt (to ensure cleanup)
echo "Second stop attempt..."
./stop.sh
echo ""

# Small delay to ensure ports are released
sleep 1

# Start the panel
echo "Starting panel..."
./start.sh
echo ""
echo "=== Restart complete ==="
