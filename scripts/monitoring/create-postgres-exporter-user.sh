#!/usr/bin/env bash

set -euo pipefail

POSTGRES_CONTAINER="${POSTGRES_CONTAINER:-myproject-dev-postgres-1}"
POSTGRES_DB="${POSTGRES_DB:-myproject}"
POSTGRES_USER="${POSTGRES_USER:-postgres}"
EXPORTER_USER="${EXPORTER_USER:-postgres_exporter}"

if [[ -z "${POSTGRES_EXPORTER_PASSWORD:-}" ]]; then
    echo "ERROR: POSTGRES_EXPORTER_PASSWORD is not set."
    exit 1
fi

echo "Creating/updating PostgreSQL monitoring user: ${EXPORTER_USER}"

docker exec \
    -i \
    -e EXPORTER_USER="${EXPORTER_USER}" \
    -e EXPORTER_PASSWORD="${POSTGRES_EXPORTER_PASSWORD}" \
    -e POSTGRES_DB="${POSTGRES_DB}" \
    "${POSTGRES_CONTAINER}" \
    psql \
    -U "${POSTGRES_USER}" \
    -d postgres \
    -v ON_ERROR_STOP=1 <<'SQL'

\getenv exporter_user EXPORTER_USER
\getenv exporter_password EXPORTER_PASSWORD
\getenv postgres_db POSTGRES_DB

SELECT format(
    'CREATE ROLE %I LOGIN PASSWORD %L',
    :'exporter_user',
    :'exporter_password'
)
WHERE NOT EXISTS (
    SELECT 1
    FROM pg_roles
    WHERE rolname = :'exporter_user'
)
\gexec

SELECT format(
    'ALTER ROLE %I LOGIN PASSWORD %L',
    :'exporter_user',
    :'exporter_password'
)
\gexec

SELECT format(
    'GRANT CONNECT ON DATABASE %I TO %I',
    :'postgres_db',
    :'exporter_user'
)
\gexec

SELECT format(
    'GRANT pg_monitor TO %I',
    :'exporter_user'
)
\gexec

SQL

echo
echo "PostgreSQL exporter user is ready."
echo "User: ${EXPORTER_USER}"
echo "Database: ${POSTGRES_DB}"
