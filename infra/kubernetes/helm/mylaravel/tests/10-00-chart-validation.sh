#!/usr/bin/env bash
# 10-00-chart-validation.sh
# Path: infra/kubernetes/helm/mylaravel/tests/10-00-chart-validation.sh
# Purpose: Validate the Laravel Helm chart before deployment.

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> Running Helm lint"
helm lint "$CHART_DIR"

echo "==> Rendering Helm templates"
RENDERED="$(helm template mylaravel "$CHART_DIR" --namespace production)"

check_contains() {
    local expected="$1"

    if ! grep -Fq -- "$expected" <<< "$RENDERED"; then
        echo "FAIL: Expected rendered content not found: $expected" >&2
        exit 1
    fi

    echo "PASS: $expected"
}

echo "==> Checking required Kubernetes resources"
check_contains "kind: ConfigMap"
check_contains "kind: Service"
check_contains "kind: Deployment"
check_contains "name: mylaravel-config"
check_contains "name: mylaravel-app"
check_contains "name: mylaravel-nginx"
check_contains "name: mylaravel-queue"
check_contains "name: mylaravel-scheduler"

echo "==> Checking runtime Secret reference"
check_contains "mylaravel-runtime"

echo "PASS: Helm chart validation completed successfully."
