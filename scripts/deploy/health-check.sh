#!/usr/bin/env bash

set -Eeuo pipefail

LIVE_URL="http://127.0.0.1/health/live"
READY_URL="http://127.0.0.1/health/ready"

MAX_ATTEMPTS=30
SLEEP_SECONDS=5


echo "========================================"
echo "Running application health checks"
echo "========================================"


for i in $(seq 1 "${MAX_ATTEMPTS}"); do

    echo ""
    echo "Health check attempt ${i}/${MAX_ATTEMPTS}"


    # -------------------------------------------------
    # Liveness
    # -------------------------------------------------

    LIVE_STATUS=$(curl \
        -s \
        -o /dev/null \
        -w "%{http_code}" \
        "${LIVE_URL}" || true)


    # -------------------------------------------------
    # Readiness
    # -------------------------------------------------

    READY_STATUS=$(curl \
        -s \
        -o /dev/null \
        -w "%{http_code}" \
        "${READY_URL}" || true)


    echo "Liveness : ${LIVE_STATUS}"
    echo "Readiness: ${READY_STATUS}"


    # -------------------------------------------------
    # Success
    # -------------------------------------------------

    if [ "${LIVE_STATUS}" = "200" ] && \
       [ "${READY_STATUS}" = "200" ]; then

        echo ""
        echo "========================================"
        echo "Health checks passed"
        echo "========================================"

        exit 0

    fi


    # -------------------------------------------------
    # Retry
    # -------------------------------------------------

    if [ "${i}" -lt "${MAX_ATTEMPTS}" ]; then

        echo "Health checks failed. Retrying in ${SLEEP_SECONDS}s..."

        sleep "${SLEEP_SECONDS}"

    fi

done


echo ""
echo "========================================"
echo "Health checks FAILED"
echo "========================================"

exit 1