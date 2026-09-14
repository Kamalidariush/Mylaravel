#!/usr/bin/env bash

set -Eeuo pipefail

PROJECT_DIR="/opt/myproject"
NETWORK_NAME="myproject_backend"
COMPOSE_PROJECT="myproject-monitoring"
COMPOSE_FILE="docker-compose.monitoring.yml"

cd "${PROJECT_DIR}"

echo "========================================"
echo "Starting Monitoring Deployment"
echo "========================================"

echo ""
echo "Project directory:"
echo "${PROJECT_DIR}"

echo ""
echo "Compose project:"
echo "${COMPOSE_PROJECT}"


# -------------------------------------------------
# Ensure Docker network
# -------------------------------------------------

echo ""
echo "Checking Docker network..."

if ! docker network inspect "${NETWORK_NAME}" >/dev/null 2>&1; then

    echo "Docker network does not exist."
    echo "Creating Docker network..."

    docker network create "${NETWORK_NAME}"

else

    echo "Docker network already exists."

fi


# -------------------------------------------------
# Validate Compose
# -------------------------------------------------

echo ""
echo "Validating Monitoring Compose..."

docker compose \
    -p "${COMPOSE_PROJECT}" \
    -f "${COMPOSE_FILE}" \
    config -q


# -------------------------------------------------
# Pull images
# -------------------------------------------------

echo ""
echo "Pulling Monitoring images..."

docker compose \
    -p "${COMPOSE_PROJECT}" \
    -f "${COMPOSE_FILE}" \
    pull


# -------------------------------------------------
# Start services
# -------------------------------------------------

echo ""
echo "Starting Monitoring services..."

docker compose \
    -p "${COMPOSE_PROJECT}" \
    -f "${COMPOSE_FILE}" \
    up -d --remove-orphans


# -------------------------------------------------
# Service status
# -------------------------------------------------

echo ""
echo "Monitoring service status..."

docker compose \
    -p "${COMPOSE_PROJECT}" \
    -f "${COMPOSE_FILE}" \
    ps


# -------------------------------------------------
# Prometheus health check
# -------------------------------------------------

echo ""
echo "Checking Prometheus..."

for i in $(seq 1 30); do

    if curl \
        --fail \
        --silent \
        --show-error \
        http://127.0.0.1:9090/-/healthy \
        >/dev/null; then

        echo "Prometheus is healthy."

        break

    fi


    if [ "${i}" -eq 30 ]; then

        echo "ERROR: Prometheus health check failed."

        echo ""
        echo "Prometheus logs:"

        docker compose \
            -p "${COMPOSE_PROJECT}" \
            -f "${COMPOSE_FILE}" \
            logs --tail=100 prometheus

        exit 1

    fi


    echo "Prometheus is not ready."
    echo "Retry ${i}/30..."

    sleep 5

done


# -------------------------------------------------
# Final status
# -------------------------------------------------

echo ""
echo "Final Monitoring service status:"

docker compose \
    -p "${COMPOSE_PROJECT}" \
    -f "${COMPOSE_FILE}" \
    ps


echo ""
echo "========================================"
echo "Monitoring Deployment Successful"
echo "========================================"
