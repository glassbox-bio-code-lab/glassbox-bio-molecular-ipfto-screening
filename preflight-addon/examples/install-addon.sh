#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="${NAMESPACE:-glassbox-preflight}"
APP_NAME="${APP_NAME:-glassbox-ipfto-addon}"
IMAGE_REPO="${IMAGE_REPO:-us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/glassbox-ipfto}"
IMAGE_TAG="${IMAGE_TAG:-1.0.0}"

helm upgrade --install "${APP_NAME}" ./chart/ipfto-addon \
  --namespace "${NAMESPACE}" --create-namespace \
  --set image.repository="${IMAGE_REPO}" \
  --set image.tag="${IMAGE_TAG}"
