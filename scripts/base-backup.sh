#!/bin/bash

set -Eeuo pipefail

CONTAINER="myproject-postgres-1"

BASE_DIR="/backup/base"
NEW_BACKUP="$BASE_DIR/new"
CURRENT_BACKUP="$BASE_DIR/current"
OLD_BACKUP="$BASE_DIR/old"

LOCK_FILE="/tmp/myproject-base-backup.lock"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

exec 9>"$LOCK_FILE"

if ! flock -n 9; then
    log "Another base backup process is already running."
    exit 1
fi

log "========================================"
log "Starting PostgreSQL base backup"
log "========================================"

# Check PostgreSQL container
if ! docker inspect "$CONTAINER" >/dev/null 2>&1; then
    log "ERROR: PostgreSQL container not found."
    exit 1
fi

# Check container is running
if ! docker inspect -f '{{.State.Running}}' "$CONTAINER" | grep -q true; then
    log "ERROR: PostgreSQL container is not running."
    exit 1
fi

# Prepare directories
docker exec "$CONTAINER" mkdir -p "$BASE_DIR"

docker exec "$CONTAINER" rm -rf "$NEW_BACKUP"
docker exec "$CONTAINER" rm -rf "$OLD_BACKUP"

docker exec "$CONTAINER" mkdir -p "$NEW_BACKUP"
docker exec "$CONTAINER" chown postgres:postgres "$NEW_BACKUP"

log "Creating new base backup..."

docker exec -u postgres "$CONTAINER" \
    pg_basebackup \
    -D "$NEW_BACKUP" \
    -Fp \
    -Xs \
    -P

log "Base backup creation completed."

# Validate backup
log "Validating new base backup..."

docker exec -u postgres "$CONTAINER" \
    pg_verifybackup "$NEW_BACKUP"

log "Base backup validation successful."

# Make sure important files exist
docker exec "$CONTAINER" test -s "$NEW_BACKUP/PG_VERSION"
docker exec "$CONTAINER" test -s "$NEW_BACKUP/backup_label"
docker exec "$CONTAINER" test -s "$NEW_BACKUP/backup_manifest"

log "Backup files verified."

# Replace current only AFTER successful validation
if docker exec "$CONTAINER" test -d "$CURRENT_BACKUP"; then
    docker exec "$CONTAINER" mv "$CURRENT_BACKUP" "$OLD_BACKUP"
fi

docker exec "$CONTAINER" mv "$NEW_BACKUP" "$CURRENT_BACKUP"

log "New backup promoted to current."

# Remove old backup
docker exec "$CONTAINER" rm -rf "$OLD_BACKUP"

log "Old backup removed."

log "Current base backup size:"
docker exec "$CONTAINER" du -sh "$CURRENT_BACKUP"

log "Disk usage:"
df -h /

log "========================================"
log "Base backup completed successfully."
log "========================================"
