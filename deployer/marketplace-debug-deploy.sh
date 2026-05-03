#!/bin/bash
set -euo pipefail
set -x

LOG_FILE="${LOG_FILE:-/tmp/marketplace-debug.log}"
TERMINATION_LOG="${TERMINATION_LOG:-/dev/termination-log}"
DEPLOY_SCRIPT="${DEPLOY_SCRIPT:-/bin/deploy.sh}"

mkdir -p "$(dirname "$LOG_FILE")"
touch "$LOG_FILE"
exec > >(tee -a "$LOG_FILE") 2>&1

emit_failure_summary() {
  local status="${1:-1}"
  if [ "$status" -ne 0 ]; then
    {
      echo "marketplace-debug-deploy.sh failed with exit code $status"
      echo
      echo "Last 240 log lines:"
      tail -240 "$LOG_FILE" || true
    } > "$TERMINATION_LOG" || true
  fi
}

trap 'emit_failure_summary "$?"' EXIT

echo "=== marketplace debug: environment ==="
env | sort

echo "=== marketplace debug: data roots ==="
ls -la /data || true
ls -la /data/chart || true
ls -la /data-test || true
ls -la /data-test/chart || true

echo "=== marketplace debug: schemas ==="
cat /data/schema.yaml || true
cat /data-test/schema.yaml || true

echo "=== marketplace debug: schema overlay compatibility ==="
python3 - <<'PY' || true
from pathlib import Path
import sys

try:
    import yaml
except Exception as exc:
    print(f"Unable to import yaml for schema diagnostics: {exc}", file=sys.stderr)
    raise SystemExit(0)

base_path = Path("/data/schema.yaml")
test_path = Path("/data-test/schema.yaml")

def load_schema(path: Path) -> dict:
    with path.open("r", encoding="utf-8") as handle:
        data = yaml.safe_load(handle) or {}
    if not isinstance(data, dict):
        raise TypeError(f"{path} did not parse to a YAML mapping")
    return data

def marketplace_type(prop: dict) -> str:
    if not isinstance(prop, dict):
        return "<not-a-mapping>"
    return ((prop.get("x-google-marketplace") or {}).get("type")) or "<unset>"

try:
    base = load_schema(base_path)
    test = load_schema(test_path)
except Exception as exc:
    print(f"Schema diagnostic load error: {exc}", file=sys.stderr)
    raise SystemExit(0)

base_props = base.get("properties") or {}
test_props = test.get("properties") or {}
print(f"Base schema properties: {len(base_props)}")
print(f"Test overlay properties: {len(test_props)}")

mismatches = []
for name in sorted(set(base_props).intersection(test_props)):
    base_type = marketplace_type(base_props[name])
    test_type = marketplace_type(test_props[name])
    if base_type != test_type:
        mismatches.append((name, base_type, test_type))

if mismatches:
    print("SCHEMA OVERLAY MARKETPLACE TYPE MISMATCHES DETECTED")
    print("Marketplace overlay_test_schema.py rejects changing x-google-marketplace.type for an existing property.")
    for name, base_type, test_type in mismatches:
        print(f"- property={name} base_x_google_marketplace_type={base_type} test_x_google_marketplace_type={test_type}")
else:
    print("No x-google-marketplace.type mismatches between base schema and apptest overlay schema.")

base_only_images = sorted((base.get("x-google-marketplace") or {}).get("images") or {})
test_only_images = sorted((test.get("x-google-marketplace") or {}).get("images") or {})
print(f"Base schema image keys: {base_only_images}")
print(f"Test overlay schema image keys: {test_only_images}")
PY

echo "=== marketplace debug: chart bundle contents ==="
tar -tzf /data/chart/chart-bundle.tar.gz || true
tar -tzf /data-test/chart/chart-bundle.tar.gz || true

echo "=== marketplace debug: deploy.sh ==="
head -240 "$DEPLOY_SCRIPT" || true

/bin/bash -x "$DEPLOY_SCRIPT"
