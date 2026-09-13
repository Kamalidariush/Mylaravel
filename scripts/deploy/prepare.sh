#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="/opt/myproject"
DEPLOY_ENV="${PROJECT_DIR}/deploy.env"

echo "========================================"
echo "Preparing deployment environment"
echo "========================================"


# -------------------------------------------------
# Project directory
# -------------------------------------------------

if [ ! -d "${PROJECT_DIR}" ]; then

    echo "ERROR: Project directory not found:"
    echo "${PROJECT_DIR}"

    exit 1

fi

cd "${PROJECT_DIR}"

echo ""
echo "Project directory:"
pwd


# -------------------------------------------------
# Check .env
# -------------------------------------------------

if [ ! -f .env ]; then

    echo ""
    echo "ERROR: .env not found:"
    echo "${PROJECT_DIR}/.env"

    exit 1

fi

echo ""
echo ".env found."


# -------------------------------------------------
# Check Docker
# -------------------------------------------------

if ! command -v docker >/dev/null 2>&1; then

    echo ""
    echo "ERROR: Docker is not installed."

    exit 1

fi

echo ""
echo "Docker:"
docker --version


# -------------------------------------------------
# Check Docker Compose
# -------------------------------------------------

if ! docker compose version >/dev/null 2>&1; then

    echo ""
    echo "ERROR: Docker Compose is not available."

    exit 1

fi

echo ""
echo "Docker Compose:"
docker compose version


# -------------------------------------------------
# Check required environment variables
# -------------------------------------------------

if [ -z "${APP_IMAGE:-}" ]; then

    echo ""
    echo "ERROR: APP_IMAGE is not set."

    exit 1

fi


if [ -z "${NGINX_IMAGE:-}" ]; then

    echo ""
    echo "ERROR: NGINX_IMAGE is not set."

    exit 1

fi


echo ""
echo "APP_IMAGE:"
echo "${APP_IMAGE}"

echo ""
echo "NGINX_IMAGE:"
echo "${NGINX_IMAGE}"


# -------------------------------------------------
# Create deploy.env
# -------------------------------------------------

echo ""
echo "Creating deploy.env..."

cat > "${DEPLOY_ENV}" <<EOF
APP_IMAGE=${APP_IMAGE}
NGINX_IMAGE=${NGINX_IMAGE}
EOF

chmod 600 "${DEPLOY_ENV}"


# -------------------------------------------------
# Compose command
# -------------------------------------------------

COMPOSE="docker compose \
  --env-file ./.env \
  --env-file ./deploy.env \
  -f docker-compose.dev.yml"


# -------------------------------------------------
# Validate Compose
# -------------------------------------------------

echo ""
echo "Validating Docker Compose..."

${COMPOSE} config -q

echo ""
echo "Docker Compose configuration is valid."


echo ""
echo "========================================"
echo "Preparation completed successfully"
echo "========================================"