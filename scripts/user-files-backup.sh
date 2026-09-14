#!/bin/bash

set -Eeuo pipefail

CONTAINER="myproject-app-1"
SOURCE="/var/www/html/storage/app/private"
BACKUP_DIR="/backup/user-files"
KEEP=3

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

TIMESTAMP="$(date '+%Y%m%d-%H%M%S')"
NEW_BACKUP="$BACKUP_DIR/$TIMESTAMP"

log "Starting user files backup..."

# Create backup directory
docker exec "$CONTAINER" mkdir -p "$BACKUP_DIR"

# Create new backup directory
docker exec "$CONTAINER" mkdir -p "$NEW_BACKUP"

cleanup_failed_backup() {
    log "Backup failed. Removing incomplete backup: $NEW_BACKUP"
    docker exec "$CONTAINER" rm -rf "$NEW_BACKUP" || true
}

trap cleanup_failed_backup ERR

# Copy user files
docker exec "$CONTAINER" sh -c \
    "cp -a '$SOURCE/.' '$NEW_BACKUP/'"

# Verify backup directory exists
docker exec "$CONTAINER" test -d "$NEW_BACKUP"

# Verify size
SIZE=$(docker exec "$CONTAINER" du -sh "$NEW_BACKUP" | awk '{print $1}')

log "New backup created:"
log "$NEW_BACKUP"
log "Backup size: $SIZE"

# Backup succeeded
trap - ERR

log "Backup completed successfully."

# Keep only newest 3 backups
BACKUPS=$(
    docker exec "$CONTAINER" sh -c \
        "find '$BACKUP_DIR' \
        -mindepth 1 \
        -maxdepth 1 \
        -type d \
        -name '20*' \
        -print" |
    sed 's#.*/##' |
    sort -r
)

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

log "Remaining backups:"
docker exec "$CONTAINER" sh -c \
    "ls -lah '$BACKUP_DIR'"

log "User files backup completed."
