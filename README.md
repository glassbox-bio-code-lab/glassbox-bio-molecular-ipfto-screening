# Glassbox Bio Molecular IP/FTO Screening

Evidence-linked molecular IP and freedom-to-operate screening for customer-hosted Google Kubernetes Engine environments.

Glassbox Bio Molecular IP/FTO Screening helps small-molecule biotech and pharmaceutical teams review target- and chemistry-specific patent evidence, identify potentially relevant patent families, and surface freedom-to-operate considerations for internal scientific, strategic, and diligence review. It is designed for screening and decision support only. It is not a substitute for formal legal advice, legal opinion, or counsel review.

This repository is the customer-facing GKE and Marketplace deployment package. It does not build internal source images or publish to Artifact Registry; those steps are handled by the internal release pipeline. The package deploys the published runtime image and the Marketplace deployer, tester, add-on, and usage-reporting surfaces needed in customer environments.

## Deployment Surfaces

The product uses one IP/FTO runtime image and two deployment surfaces:

- `manifest/chart/`: direct GKE runtime chart for standalone IP/FTO execution or attachment to an existing Glassbox core run.
- `preflight-addon/`: nested Preflight integration package that installs the add-on resources and values overlay needed for a Preflight UI deployment to launch the same IP/FTO runtime image.

The direct GKE package includes:

- `schema.yaml`: Marketplace schema for the direct GKE deployment surface.
- `deployer/Dockerfile`: Marketplace deployer image definition.
- `apptest/tester/Dockerfile`: Marketplace verification tester image definition.
- `apptest/deployer/`: Marketplace verification overlay.
- `docs/USER_GUIDE.md`: detailed install and runtime guidance.
- `examples/cli-install.sh`: basic Helm install entrypoint.

The nested Preflight add-on package includes its own deployer and tester because Marketplace validation installs that integration surface independently. It is still part of the same Glassbox Bio Molecular IP/FTO Screening product.

## Usage Paths

### IP/FTO Add-on Run

Use add-on mode when IP/FTO screening is performed after a prior Glassbox molecular audit. The screening attaches to an existing core run and uses the existing run context and output storage.

Required values:

- `config.executionMode=addon`
- `config.projectId`
- `config.runId`

Add-on outputs are written under:

```text
<outputRoot>/<runId>/raw/ipfto/
<outputRoot>/<runId>/reports/
```

The add-on path supports:

- `config.ipftoMode=phase2a_only`
- `config.ipftoMode=full`

`full` mode requires a real configured LLM credential Secret. It may only reason over deterministic patent evidence retrieved by the runtime. If required credentials or evidence are unavailable, the runtime should return an explicit machine-readable blocked state rather than fabricating output.

### IP/FTO Standalone Run

Use standalone mode when IP/FTO screening is initiated without a prior Glassbox molecular audit. Standalone mode requires a real request payload supplied through:

- `standalone.requestJson`

The request payload must match the runtime contract implemented by:

- `ipfto_module/gbx_ipfto/ipfto_only_input.py`

An example payload is provided at:

- `examples/standalone-request.json`

Standalone outputs are written under:

```text
<projectsRoot>/<derived_project_id>/
```

with canonical report artifacts under:

```text
<projectsRoot>/<derived_project_id>/results/combined_unified_ipfto_outputs.json
<projectsRoot>/<derived_project_id>/results/ipfto_report.html
<projectsRoot>/<derived_project_id>/results/ipfto_manifest.json
```

## Outputs

Each completed run is expected to produce structured machine-readable outputs and review-ready report artifacts. Depending on route and mode, the output bundle can include:

- patent evidence and prior-art result files
- claim and family aggregation artifacts
- IP/FTO report HTML
- IP/FTO manifest JSON
- verification summary JSON
- provenance and run metadata
- raw intermediate output files for downstream review

Outputs must be traceable to real provided inputs and retrieved evidence. This package must not create synthetic scientific inputs, placeholder assay values, fabricated patent evidence, or proxy scientific metrics.

## Verification and Sealing

The runtime can generate preseal metadata and request a signed Glassbox seal when entitlement/seal service configuration is present.

When configured, the runtime uses the entitlement lifecycle endpoints for usage authorization and run sealing, then writes returned seal artifacts such as:

- `seal/preseal.json`
- `seal/seal.json`
- `seal/seal.sig`
- `seal/public_key.pem`, when the public key endpoint is reachable
- verification support files, when available

Signing is configuration-dependent. If entitlement or seal service values are not provided, the runtime records that signing is disabled or unavailable and does not fabricate seal artifacts. A missing seal does not imply that scientific output was fabricated; it means the configured signing workflow did not complete for that run.

## Billing and Usage Reporting

The Preflight UI package is free to deploy. IP/FTO usage is metered by the paid IP/FTO product when billing is enabled in the customer deployment.

The IP/FTO chart includes a UBB agent sidecar configuration for Marketplace usage reporting. The current usage metric names are:

- `ipfto_integrated_run`: IP/FTO add-on run attached to an existing Glassbox core run.
- `ipfto_standalone_run`: standalone IP/FTO run.

The published IP/FTO UBB agent image is configured in:

- `manifest/chart/values.yaml`

Billing requires the customer deployment to provide the Marketplace reporting Secret expected by the chart. The repository stores deployment configuration and metric names; pricing is controlled by the Marketplace Producer Portal plan.

## Runtime Images

Current production defaults use published Artifact Registry images:

- Runtime: `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/glassbox-ipfto:1.0.0`
- UBB agent: `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/glassbox-ipfto/ubbagent:1.0.0`
- Deployer: `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/deployer:1.0.0`
- Tester: `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/tester:1.0.0`

Current pinned digests in the chart values are:

- Runtime: `sha256:47151fff378c4bc7108477a4838a069820a6ae84415999a8d34c9304da626435`
- UBB agent: `sha256:83f36b805b6b0b140dc443c5e41214192a0c77dd1e7f7cf62893d92467904293`
- Deployer: `sha256:4b5fd83b16c4dbada575395a20476c422b1f7491693f015782e62fa01e9ddaf0`
- Tester: `sha256:3064125bbdd670a9cbe907dc3e01343cc72c9ff1a2eed130ee3213f9fd2395d1`
- Preflight add-on tester: `sha256:65673015fe43806dea41ef12eb8fd8ea3c95cbda1692fcc827492abc32078594`

For Marketplace submission, use this deployer image URL without a tag or digest:

```text
us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/deployer
```

The direct deployer and nested Preflight add-on deployer/tester images are built and published by the release pipeline using the Dockerfiles in this package.

## Marketplace Image Build Helpers

These helpers are for release maintainers, not customer scientific execution:

```bash
make -C glassbox-bio-molecular-ipfto-screening build-marketplace-images
make -C glassbox-bio-molecular-ipfto-screening push-marketplace-images
make -C glassbox-bio-molecular-ipfto-screening preflight-build-marketplace-images
make -C glassbox-bio-molecular-ipfto-screening preflight-push-marketplace-images
```

The verification tester validates Kubernetes install wiring only. It does not run IP/FTO scientific analysis and does not create placeholder scientific inputs.

## Operational Constraints

- Use real customer-provided request payloads for standalone runs.
- Use add-on mode only against a real Glassbox core run that has the required core output artifacts.
- Configure a real LLM credential Secret before using `full` mode.
- Configure entitlement and Marketplace reporting values before expecting usage reporting or signed seal artifacts.
- Do not treat this screening output as legal advice or a legal opinion.
