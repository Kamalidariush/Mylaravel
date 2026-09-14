#!/bin/bash

set -u

THRESHOLD=90
DISK="/"

USAGE=$(df -P "$DISK" | awk 'NR==2 {gsub("%","",$5); print $5}')

if [ "$USAGE" -ge "$THRESHOLD" ]; then
    echo "CRITICAL: Disk usage is ${USAGE}%"
    exit 2
fi

echo "OK: Disk usage is ${USAGE}%"
exit 0
