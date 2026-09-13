#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="/opt/myproject"
PREVIOUS_DEPLOYMENT="${PROJECT_DIR}/.previous_deployment"


echo "========================================"
echo "ROLLBACK STARTED"
echo "========================================"


# -------------------------------------------------
# Project directory
# -------------------------------------------------

cd "${PROJECT_DIR}"


# -------------------------------------------------
# Check previous deployment
# -------------------------------------------------

if [ ! -f "${PREVIOUS_DEPLOYMENT}" ]; then

    echo ""
    echo "ERROR: No previous deployment found."

    exit 1

fi


# -------------------------------------------------
# Load previous images
# -------------------------------------------------

source "${PREVIOUS_DEPLOYMENT}"


if [ -z "${APP_IMAGE:-}" ]; then

    echo ""
    echo "ERROR: Previous APP_IMAGE is missing."

    exit 1

fi


if [ -z "${NGINX_IMAGE:-}" ]; then

    echo ""
    echo "ERROR: Previous NGINX_IMAGE is missing."

    exit 1

fi


echo ""
echo "Rollback APP image:"
echo "${APP_IMAGE}"


echo ""
echo "Rollback NGINX image:"
echo "${NGINX_IMAGE}"


# -------------------------------------------------
# Write deploy.env
# -------------------------------------------------

cat > deploy.env <<EOF
APP_IMAGE=${APP_IMAGE}
NGINX_IMAGE=${NGINX_IMAGE}
EOF

chmod 600 deploy.env


# -------------------------------------------------
# Compose
# -------------------------------------------------

COMPOSE="docker compose \
  --env-file ./.env \
  --env-file ./deploy.env \
  -f docker-compose.dev.yml"


# -------------------------------------------------
# Pull previous images
# -------------------------------------------------

echo ""
echo "Pulling previous images..."

if ! ${COMPOSE} pull; then

    echo ""
    echo "ERROR: Failed to pull previous images."

    exit 1

fi


# -------------------------------------------------
# Start previous deployment
# -------------------------------------------------

echo ""
echo "Starting previous deployment..."

if ! ${COMPOSE} up -d --remove-orphans; then

    echo ""
    echo "ERROR: Failed to start previous deployment."

    exit 1

fi


# -------------------------------------------------
# Health check
# -------------------------------------------------

echo ""
echo "Checking rollback health..."

if bash scripts/deploy/health-check.sh; then

    echo ""
    echo "========================================"
    echo "ROLLBACK SUCCESSFUL"
    echo "========================================"

    exit 1

else

    echo ""
    echo "========================================"
    echo "ROLLBACK FAILED"
    echo "========================================"

    exit 1

fi