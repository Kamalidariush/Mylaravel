#!/bin/bash

set -Eeuo pipefail

CONTAINER="myproject-postgres-1"
BACKUP_DIR="/backup/base"
KEEP=3

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting base backup retention..."

# Check container
if ! docker inspect "$CONTAINER" >/dev/null 2>&1; then
    log "ERROR: PostgreSQL container not found."
    exit 1
fi

# Get backup directories
BACKUPS=$(
    docker exec "$CONTAINER" \
        find "$BACKUP_DIR" \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -name '20*' \
        -print |
    sed 's#.*/##' |
    sort -r
)

if [ -z "$BACKUPS" ]; then
    log "No timestamped base backups found."
    exit 0
fi

COUNT=0

while IFS= read -r BACKUP; do

    [ -z "$BACKUP" ] && continue

    COUNT=$((COUNT + 1))

    if [ "$COUNT" -le "$KEEP" ]; then

        log "Keeping: $BACKUP"

    else

        log "Deleting old backup: $BACKUP"

        docker exec "$CONTAINER" \
            rm -rf "$BACKUP_DIR/$BACKUP"

    fi

done <<< "$BACKUPS"

log "Remaining base backups:"

docker exec "$CONTAINER" \
    sh -c "ls -lah '$BACKUP_DIR'"

log "Base backup retention completed."
