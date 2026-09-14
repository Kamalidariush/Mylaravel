#!/bin/bash

set -Eeuo pipefail

CONTAINER="myproject-postgres-1"

BASE_DIR="/backup/base"
CURRENT_BACKUP="$BASE_DIR/current"
NEW_BACKUP="$BASE_DIR/new"
OLD_BACKUP="$BASE_DIR/old"

WAL_DIR="/backup/wal"

LOCK_FILE="/tmp/myproject-wal-retention.lock"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# --------------------------------------------------
# Prevent concurrent executions
# --------------------------------------------------

exec 9>"$LOCK_FILE"

if ! flock -n 9; then
    log "Another WAL retention process is already running."
    exit 1
fi

log "========================================"
log "Starting WAL retention"
log "========================================"

# --------------------------------------------------
# Check PostgreSQL container
# --------------------------------------------------

if ! docker inspect "$CONTAINER" >/dev/null 2>&1; then
    log "ERROR: PostgreSQL container not found."
    exit 1
fi

# --------------------------------------------------
# Check base directory
# --------------------------------------------------

docker exec "$CONTAINER" mkdir -p "$BASE_DIR"

# --------------------------------------------------
# Function: validate backup
# --------------------------------------------------

validate_backup() {

    local BACKUP_PATH="$1"

    log "Validating backup: $BACKUP_PATH"

    if ! docker exec "$CONTAINER" test -s "$BACKUP_PATH/PG_VERSION"; then
        log "ERROR: PG_VERSION missing."
        return 1
    fi

    if ! docker exec "$CONTAINER" test -s "$BACKUP_PATH/backup_label"; then
        log "ERROR: backup_label missing."
        return 1
    fi

    if ! docker exec "$CONTAINER" test -s "$BACKUP_PATH/backup_manifest"; then
        log "ERROR: backup_manifest missing."
        return 1
    fi

    docker exec -u postgres "$CONTAINER" \
        pg_verifybackup "$BACKUP_PATH"

    log "Backup validation successful."

    return 0
}

# --------------------------------------------------
# Check current backup
# --------------------------------------------------

CURRENT_VALID=false

if docker exec "$CONTAINER" test -d "$CURRENT_BACKUP"; then

    log "Current base backup found."

    if validate_backup "$CURRENT_BACKUP"; then
        CURRENT_VALID=true
        log "Current base backup is healthy."
    else
        log "WARNING: Current base backup is NOT valid."
    fi

else
    log "WARNING: No current base backup found."
fi

# --------------------------------------------------
# If current backup is invalid, create a new one
# --------------------------------------------------

if [ "$CURRENT_VALID" = false ]; then

    log "Creating a new base backup..."

    # Remove incomplete previous temporary backup
    docker exec "$CONTAINER" rm -rf "$NEW_BACKUP"

    docker exec "$CONTAINER" mkdir -p "$NEW_BACKUP"

    docker exec "$CONTAINER" \
        chown postgres:postgres "$NEW_BACKUP"

    docker exec -u postgres "$CONTAINER" \
        pg_basebackup \
        -D "$NEW_BACKUP" \
        -Fp \
        -Xs \
        -P

    log "New base backup created."

    # Validate NEW backup before touching old backup
    if ! validate_backup "$NEW_BACKUP"; then
        log "ERROR: New base backup validation FAILED."
        log "NO WAL FILES WILL BE DELETED."

        docker exec "$CONTAINER" rm -rf "$NEW_BACKUP"

        exit 1
    fi

    log "New base backup is healthy."

    # --------------------------------------------------
    # Replace current backup safely
    # --------------------------------------------------

    docker exec "$CONTAINER" rm -rf "$OLD_BACKUP"

    if docker exec "$CONTAINER" test -d "$CURRENT_BACKUP"; then
        docker exec "$CONTAINER" \
            mv "$CURRENT_BACKUP" "$OLD_BACKUP"
    fi

    docker exec "$CONTAINER" \
        mv "$NEW_BACKUP" "$CURRENT_BACKUP"

    log "New base backup promoted to current."

    # Old backup is no longer needed
    docker exec "$CONTAINER" rm -rf "$OLD_BACKUP"

else

    log "Using existing healthy base backup."

fi

# --------------------------------------------------
# Read START WAL
# --------------------------------------------------

START_WAL=$(
    docker exec "$CONTAINER" \
    awk '/^START WAL LOCATION:/ {
        gsub(/[()]/, "", $6)
        print $6
    }' "$CURRENT_BACKUP/backup_label"
)

if [ -z "$START_WAL" ]; then
    log "ERROR: Could not determine START WAL."
    log "NO WAL FILES WILL BE DELETED."
    exit 1
fi

log "Base backup START WAL: $START_WAL"

# --------------------------------------------------
# Final safety validation before cleanup
# --------------------------------------------------

if ! validate_backup "$CURRENT_BACKUP"; then
    log "ERROR: Final backup validation FAILED."
    log "NO WAL FILES WILL BE DELETED."
    exit 1
fi

# --------------------------------------------------
# WAL cleanup
# --------------------------------------------------

log "Starting WAL cleanup..."

docker exec "$CONTAINER" \
    /usr/local/bin/pg_archivecleanup \
    "$WAL_DIR" \
    "$START_WAL"

log "WAL cleanup completed."

# --------------------------------------------------
# Report
# --------------------------------------------------

log "Current WAL size:"
docker exec "$CONTAINER" du -sh "$WAL_DIR"

log "Current base backup size:"
docker exec "$CONTAINER" du -sh "$CURRENT_BACKUP"

log "Current disk usage:"
df -h /

log "========================================"
log "WAL retention completed successfully."
log "========================================"
