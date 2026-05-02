#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-glassbox-ipfto}"
APP_NAME="${APP_NAME:-glassbox-ipfto}"
IMAGE_REPO="${IMAGE_REPO:-us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/glassbox-ipfto}"
IMAGE_TAG="${IMAGE_TAG:-1.0.0}"
EXECUTION_MODE="${EXECUTION_MODE:-standalone}"
PROJECT_ID="${PROJECT_ID:-ipfto_demo}"
RUN_ID="${RUN_ID:-}"
REQUEST_JSON_PATH="${REQUEST_JSON_PATH:-}"

HELM_ARGS=(
  --namespace "${NAMESPACE}"
  --create-namespace
  --set image.repository="${IMAGE_REPO}"
  --set image.tag="${IMAGE_TAG}"
  --set job.enabled=true
  --set config.executionMode="${EXECUTION_MODE}"
  --set config.projectId="${PROJECT_ID}"
)

if [[ -n "${RUN_ID}" ]]; then
  HELM_ARGS+=(--set config.runId="${RUN_ID}")
fi

if [[ "${EXECUTION_MODE}" == "standalone" ]]; then
  if [[ -z "${REQUEST_JSON_PATH}" ]]; then
    echo "REQUEST_JSON_PATH is required for standalone mode" >&2
    exit 1
  fi
  HELM_ARGS+=(--set-file standalone.requestJson="${REQUEST_JSON_PATH}")
fi

helm upgrade --install "${APP_NAME}" ./manifest/chart "${HELM_ARGS[@]}"
