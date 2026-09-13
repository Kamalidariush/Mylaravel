#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="/opt/myproject"

cd "${PROJECT_DIR}"


echo "========================================"
echo "Starting application deployment"
echo "========================================"


# -------------------------------------------------
# Required environment variables
# -------------------------------------------------

if [ -z "${APP_IMAGE:-}" ]; then

    echo "ERROR: APP_IMAGE is not set."

    exit 1

fi


if [ -z "${NGINX_IMAGE:-}" ]; then

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
# Prepare deployment environment
# -------------------------------------------------

echo ""
echo "Running deployment preparation..."

bash scripts/deploy/prepare.sh


# -------------------------------------------------
# Ensure Docker network
# -------------------------------------------------

echo ""
echo "Ensuring Docker network..."

bash scripts/deploy/network.sh


# -------------------------------------------------
# Compose
# -------------------------------------------------

COMPOSE="docker compose \
  --env-file ./.env \
  --env-file ./deploy.env \
  -f docker-compose.dev.yml"


# -------------------------------------------------
# Detect current deployment
# -------------------------------------------------

CURRENT_APP_IMAGE=""

CURRENT_NGINX_IMAGE=""


if docker ps -a \
    --format '{{.Names}}' \
    | grep -qx 'myproject-app-1'; then

    CURRENT_APP_IMAGE=$(docker inspect \
        --format='{{.Config.Image}}' \
        myproject-app-1 || true)

fi


if docker ps -a \
    --format '{{.Names}}' \
    | grep -qx 'myproject-nginx-1'; then

    CURRENT_NGINX_IMAGE=$(docker inspect \
        --format='{{.Config.Image}}' \
        myproject-nginx-1 || true)

fi


echo ""
echo "Current APP image:"
echo "${CURRENT_APP_IMAGE:-none}"


echo ""
echo "Current NGINX image:"
echo "${CURRENT_NGINX_IMAGE:-none}"


# -------------------------------------------------
# Save previous deployment
# -------------------------------------------------

if [ -n "${CURRENT_APP_IMAGE}" ] && \
   [ -n "${CURRENT_NGINX_IMAGE}" ]; then

    cat > .previous_deployment <<EOF
APP_IMAGE=${CURRENT_APP_IMAGE}
NGINX_IMAGE=${CURRENT_NGINX_IMAGE}
EOF

    chmod 600 .previous_deployment

    echo ""
    echo "Previous deployment saved."

else

    rm -f .previous_deployment

    echo ""
    echo "No previous deployment available."

fi


# -------------------------------------------------
# Pull new images
# -------------------------------------------------

echo ""
echo "Pulling new images..."

if ! ${COMPOSE} pull; then

    echo ""
    echo "Image pull failed."

    if [ -f .previous_deployment ]; then
        bash scripts/deploy/rollback.sh
    fi

    exit 1

fi


# -------------------------------------------------
# Start new containers
# -------------------------------------------------

echo ""
echo "Starting new deployment..."

if ! ${COMPOSE} up -d --remove-orphans; then

    echo ""
    echo "Compose startup failed."

    if [ -f .previous_deployment ]; then
        bash scripts/deploy/rollback.sh
    fi

    exit 1

fi


# -------------------------------------------------
# Database migration
# -------------------------------------------------

echo ""
echo "Running database migrations..."

if ! ${COMPOSE} run --rm app php artisan migrate --force; then

    echo ""
    echo "Migration failed."

    if [ -f .previous_deployment ]; then
        bash scripts/deploy/rollback.sh
    fi

    exit 1

fi


# -------------------------------------------------
# Laravel optimize
# -------------------------------------------------

echo ""
echo "Optimizing Laravel..."

if ! ${COMPOSE} run --rm app php artisan optimize; then

    echo ""
    echo "Laravel optimize failed."

    if [ -f .previous_deployment ]; then
        bash scripts/deploy/rollback.sh
    fi

    exit 1

fi


# -------------------------------------------------
# Health checks
# -------------------------------------------------

echo ""
echo "Running application health checks..."

if ! bash scripts/deploy/health-check.sh; then

    echo ""
    echo "Health check failed."

    if [ -f .previous_deployment ]; then
        bash scripts/deploy/rollback.sh
    fi

    exit 1

fi


# -------------------------------------------------
# Save current deployment
# -------------------------------------------------

cat > .current_deployment <<EOF
APP_IMAGE=${APP_IMAGE}
NGINX_IMAGE=${NGINX_IMAGE}
EOF

chmod 600 .current_deployment


# -------------------------------------------------
# Keep deploy.env synchronized
# -------------------------------------------------

cat > deploy.env <<EOF
APP_IMAGE=${APP_IMAGE}
NGINX_IMAGE=${NGINX_IMAGE}
EOF

chmod 600 deploy.env


# -------------------------------------------------
# Final status
# -------------------------------------------------

echo ""
echo "========================================"
echo "Deployment successful"
echo "========================================"


${COMPOSE} ps