#!/usr/bin/env bash
set -euo pipefail
THRESHOLD=${1:-90}

if [ ! -f coverage/lcov.info ]; then
  echo "coverage/lcov.info not found. Run: flutter test --coverage"
  exit 1
fi

TOTAL=$(grep -o 'LF:[0-9]*' coverage/lcov.info | awk -F: '{sum+=$2} END {print sum}')
HITS=$(grep -o 'LH:[0-9]*' coverage/lcov.info | awk -F: '{sum+=$2} END {print sum}')

if [ "$TOTAL" -eq 0 ]; then
  echo "No lines found in coverage."
  exit 1
fi

PCT=$(awk -v h="$HITS" -v t="$TOTAL" 'BEGIN { printf "%.2f", (h/t)*100 }')

echo "Coverage: $PCT% (Threshold: ${THRESHOLD}%)"
awk -v p="$PCT" -v th="$THRESHOLD" 'BEGIN { exit (p+0<th) ? 1 : 0 }' || {
  echo "❌ Coverage below threshold"
  exit 1
}

echo "✅ Coverage OK"
