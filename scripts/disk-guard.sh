#!/bin/bash

set -u

THRESHOLD=85
LOG_FILE="/var/log/myproject-disk-guard.log"

USAGE=$(df -P / | awk 'NR==2 {gsub("%","",$5); print $5}')

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

if [ "$USAGE" -ge "$THRESHOLD" ]; then
    log "WARNING: Root filesystem usage is ${USAGE}%"

    log "Docker disk usage:"
    docker system df >> "$LOG_FILE" 2>&1

    log "Postgres WAL size:"
    docker exec myproject-postgres-1 du -sh /backup/wal >> "$LOG_FILE" 2>&1

    log "Disk usage:"
    df -h / >> "$LOG_FILE" 2>&1
else
    log "OK: Root filesystem usage is ${USAGE}%"
fi
