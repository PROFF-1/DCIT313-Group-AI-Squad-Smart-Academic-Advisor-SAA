#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
PORT="${1:-8080}"

echo "Starting Smart Academic Advisor web GUI on http://localhost:${PORT}"
echo "Press Ctrl+C in Prolog to stop the server."

# Open browser on macOS (non-fatal if it fails)
swipl -s saa_web.pl -g "start_server(${PORT}), thread_get_message(_)."
