#!/bin/bash
set -eox pipefail

LOG_FILE="${LOG_FILE:-/tmp/marketplace-deploy-with-tests.log}"
TERMINATION_LOG="${TERMINATION_LOG:-/dev/termination-log}"

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

write_termination_log() {
  local status="${1:-1}"
  {
    echo "deploy_with_tests.sh exited with status ${status}"
    echo
    echo "Last 240 log lines:"
    tail -240 "$LOG_FILE" || true
  } > "$TERMINATION_LOG" || true
}

handle_failure() {
  local status=$?
  if [[ -z "$NAME" ]] || [[ -z "$NAMESPACE" ]]; then
    NAME="$(/bin/print_config.py --xtype NAME --values_mode raw || true)"
    NAMESPACE="$(/bin/print_config.py --xtype NAMESPACE --values_mode raw || true)"
    export NAME
    export NAMESPACE
  fi
  if [[ -n "$NAME" ]] && [[ -n "$NAMESPACE" ]]; then
    patch_assembly_phase.sh --status="Failed" || true
  fi
  write_termination_log "$status"
  exit "$status"
}
trap "handle_failure" EXIT

test_schema="/data-test/schema.yaml"
overlay_test_schema.py \
  --test_schema "$test_schema" \
  --original_schema "/data/schema.yaml" \
  --output "/data/schema.yaml" \
  | awk '{print "SMOKE_TEST "$0}'

NAME="$(/bin/print_config.py --xtype NAME --values_mode raw)"
NAMESPACE="$(/bin/print_config.py --xtype NAMESPACE --values_mode raw)"
export NAME
export NAMESPACE

echo "Deploying application \"$NAME\" in in-process test mode"

app_uid="$(kubectl get "applications.app.k8s.io/$NAME" \
  --namespace="$NAMESPACE" \
  --output=jsonpath='{.metadata.uid}')"
app_api_version="$(kubectl get "applications.app.k8s.io/$NAME" \
  --namespace="$NAMESPACE" \
  --output=jsonpath='{.apiVersion}')"
namespace_uid="$(kubectl get "namespaces/$NAMESPACE" \
  --output=jsonpath='{.metadata.uid}')"

/bin/expand_config.py --values_mode raw --app_uid "$app_uid"

create_manifests.sh --mode="test"

/bin/set_ownership.py \
  --app_name "$NAME" \
  --app_uid "$app_uid" \
  --app_api_version "$app_api_version" \
  --namespace "$NAMESPACE" \
  --namespace_uid "$namespace_uid" \
  --manifests "/data/manifest-expanded" \
  --dest "/data/resources.yaml"

validate_app_resource.py --manifests "/data/resources.yaml"

kubectl apply --namespace="$NAMESPACE" --filename="/data/resources.yaml"

patch_assembly_phase.sh --status="Success"

wait_for_ready.py \
  --name "$NAME" \
  --namespace "$NAMESPACE" \
  --timeout "${WAIT_FOR_READY_TIMEOUT:-300}"

service_account="${NAME}-sa"
config_map="${NAME}-config"

kubectl -n "$NAMESPACE" get serviceaccount "$service_account" >/dev/null
echo "SMOKE_TEST COMPLETE[1]: ServiceAccount exists"

config_json="$(kubectl -n "$NAMESPACE" get configmap "$config_map" -o json)"
printf '%s' "$config_json" | jq -e '.data.PROJECT_ID == "verification_project"' >/dev/null
printf '%s' "$config_json" | jq -e '.data.EXECUTION_MODE == "standalone"' >/dev/null
printf '%s' "$config_json" | jq -e '.data.GBX_IPFTO_MODE == "phase2a_only"' >/dev/null
printf '%s' "$config_json" | jq -e '.data.FAIL_CLOSED == "true"' >/dev/null
printf '%s' "$config_json" | jq -e '.data.UBBAGENT_ENABLED == "false"' >/dev/null
echo "SMOKE_TEST COMPLETE[2]: ConfigMap exposes IPFTO runtime contract"

if kubectl -n "$NAMESPACE" get job "$NAME" >/dev/null 2>&1; then
  echo "Verification install must not launch the IP/FTO runtime job without real inputs." >&2
  exit 1
fi
echo "SMOKE_TEST COMPLETE[3]: Runtime Job is disabled for verification install"

app_json="$(kubectl -n "$NAMESPACE" get "applications.app.k8s.io/$NAME" -o json)"
printf '%s' "$app_json" | jq -e '
  [.spec.componentKinds[].kind] as $kinds
  | ($kinds | index("ConfigMap")) != null
  and ($kinds | index("ServiceAccount")) != null
  and ($kinds | index("Job")) == null
  and ($kinds | index("PersistentVolumeClaim")) == null
  and ($kinds | index("Role")) == null
  and ($kinds | index("RoleBinding")) == null
' >/dev/null
echo "SMOKE_TEST COMPLETE[4]: Application component contract is wiring-only"

clean_iam_resources.sh

trap - EXIT
