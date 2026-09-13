#!/usr/bin/env bash

set -Eeuo pipefail

NETWORK_NAME="myproject_backend"

echo "========================================"
echo "Checking Docker network"
echo "========================================"

echo ""
echo "Network: ${NETWORK_NAME}"


if docker network inspect "${NETWORK_NAME}" >/dev/null 2>&1; then

    echo ""
    echo "Docker network already exists:"
    echo "${NETWORK_NAME}"

else

    echo ""
    echo "Docker network does not exist."
    echo "Creating network..."

    docker network create "${NETWORK_NAME}"

    echo ""
    echo "Docker network created successfully."

fi


echo ""
echo "Verifying Docker network..."

docker network inspect "${NETWORK_NAME}" >/dev/null

echo ""
echo "Docker network is ready:"
echo "${NETWORK_NAME}"