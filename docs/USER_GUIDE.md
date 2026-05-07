# Glassbox Bio Molecular IPFTO Screening User Guide

This repo exposes the customer runtime contract for the Glassbox Bio Molecular IPFTO Screening product.

It does not build images, publish images, or manage Artifact Registry. Those concerns stay in the internal delivery pipeline.

## Deployment Routes

The package contains two deployment surfaces for the same product:

- `manifest/chart/`: direct GKE runtime install for standalone or existing-core-run execution.
- `preflight-addon/`: nested Preflight integration package for making IP/FTO visible and runnable from an existing Preflight UI deployment.

### Standalone

Use standalone mode when you want to run IP/FTO screening from a real request payload without a prior core run.

Required value:

- `standalone.requestJson`

The payload must match the real standalone request contract implemented by:

- `ipfto_module/gbx_ipfto/ipfto_only_input.py`

A contract-valid example payload is included at:

- `examples/standalone-request.json`

The chart materializes that JSON into the runtime container and executes:

```bash
python -m ipfto_module --pretty ipfto-only --input-json /config/request.json
```

Outputs are written under:

```text
<projectsRoot>/<derived_project_id>/
```

with the canonical report package under:

```text
<projectsRoot>/<derived_project_id>/results/combined_unified_ipfto_outputs.json
<projectsRoot>/<derived_project_id>/results/ipfto_report.html
<projectsRoot>/<derived_project_id>/results/ipfto_manifest.json
```

### Add-on

Use add-on mode when a customer already has a core Glassbox run and wants to attach IP/FTO screening to that run.

Required values:

- `config.executionMode=addon`
- `config.projectId`
- `config.runId`

The add-on path executes:

```bash
python -m ipfto_module.addon_runner --project-id <projectId> --run-id <runId> --output-root <outputRoot> --mode <phase2a_only|full>
```

Current in-cluster support includes:

- `config.ipftoMode=phase2a_only`
- `config.ipftoMode=full`

Full mode requires a real configured LLM credential Secret. It may only reason over deterministic patent evidence already retrieved by the runtime.

The referenced core run must already contain:

- `results/combined_unified_computational_outputs.json`
- `results/summary.json`

Add-on outputs are written under:

```text
<outputRoot>/<runId>/raw/ipfto/
<outputRoot>/<runId>/reports/
```

## Storage

Supported backends:

- `storage.type=pvc`
- `storage.type=gcs`

For GCS mounts, set:

- `storage.gcs.bucket`

For PVC mode, set:

- `storage.pvc.size`
- `storage.pvc.storageClassName`

## Optional Entitlement Wiring

If you want signing against the entitlement service, provide:

- `config.entitlementUrl`
- `config.entitlementAudience`
- `entitlement.existingSecret`

The referenced Secret must contain the bearer token key configured by:

- `entitlement.bearerTokenKey`

If entitlement values are omitted, the runtime remains fail-closed and simply skips signing rather than fabricating seal state.

## Important Constraints

- Do not pass synthetic or placeholder request payloads.
- Do not point add-on mode at a run that lacks the required core outputs.
- Do not use `full` without a real LLM credential Secret and deterministic evidence source configuration.
- Missing real prerequisites should surface as `SKIPPED` or `FAILED`, not as inferred success.

## Marketplace Verification Images

The direct GKE bundle includes the same Marketplace image split used by the Preflight UI Hub and Molecular Audit Core bundles:

- Runtime image: `image.repository:image.tag`
- Deployer image: `deployer/Dockerfile`
- Verification tester image: `apptest.image.repository:apptest.image.tag`

The direct verification overlay is intentionally wiring-only: it keeps the runtime Job disabled and does not create the customer data PVC. The tester checks application metadata, ConfigMap, ServiceAccount/RBAC, and image wiring. It does not execute a scientific IP/FTO run and does not create fabricated inputs.

For Google Cloud Marketplace validation, use the root deployer image path without a tag or digest:

```text
us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/deployer
```

Do not use a digest-pinned deployer URL in the Marketplace submission field. If validation is pointed at an old immutable digest, it can continue to inspect that old manifest even after `1.0.0`, `1.0`, and `latest` have been moved to the corrected annotated deployer.

The nested `preflight-addon/` package has its own deployer and verification tester because Marketplace validation needs to install that integration surface independently, but it is still part of the same IP/FTO product.
