# Glassbox IP/FTO Preflight Add-On User Guide

This nested bundle wires the same Glassbox Bio Molecular IPFTO Screening product into an existing Glassbox Preflight deployment.

It is intentionally not a duplicate of the full Preflight UI repository, and it is not a second IP/FTO product. The UI/runtime chart remains separate. This bundle handles the add-on resource contract that Preflight expects.

## What This Chart Installs

The chart installs:

- a dedicated `ServiceAccount` for the IP/FTO runner Job
- a `ConfigMap` that advertises the runner image and the validated mode contract

Those resources are designed to match the generic add-on resource pattern already used by the customer Preflight chart.

## Supported Modes

The validated customer add-on contract supports:

- `phase2a_only`
- `full`

Full mode requires a real LLM credential Secret and may only reason over deterministic patent evidence already retrieved by the runtime.

## Required Preflight Overlay

This chart only installs the add-on resources. To make the add-on visible and runnable in the UI, merge:

- `examples/preflight-values.ipfto.yaml`

into the values used for your Preflight deployment.

That overlay contributes:

- the `addons.registry` entry for `ipfto`
- the UI parameter schema
- the core-run prerequisite file list
- the install metadata that points Preflight at the `ServiceAccount` and `ConfigMap`

## Runtime Expectations

The add-on launch path assumes an existing core run with:

- `results/combined_unified_computational_outputs.json`
- `results/summary.json`

The shared storage contract must allow the add-on job to access:

- `inputRoot`
- `outputRoot`
- `projectsDir`

Set those via:

- `install.inputRoot`
- `install.outputRoot`
- `install.projectsDir`

The example Preflight overlay also mirrors those values into `configData` using the exact environment variable names consumed by `ipfto_module.addon_runner`.

## Optional Signing Inputs

If signing is enabled in your environment, set:

- `configData.GBX_ENTITLEMENT_URL`
- `configData.GBX_ENTITLEMENT_AUDIENCE`
- `configData.secretRefs`

The runtime will use real entitlement values when present and will otherwise skip signing explicitly rather than fabricating seal output.

## Marketplace Verification Images

This bundle includes a deployer image and a separate verification tester image, matching the Preflight UI Hub and Molecular Audit Core Marketplace packaging model.

For Google Cloud Marketplace validation of the root product, use the root deployer image path without a tag or digest:

```text
us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/deployer
```

Do not submit a digest-pinned deployer URL. If validation is pointed at an old immutable digest, it can continue to inspect that old manifest even after release tags have been moved to the corrected annotated deployer.

The tester validates only add-on resource wiring:

- runner ServiceAccount
- add-on ConfigMap
- runtime image reference
- supported `phase2a_only` and `full` modes

It does not execute IP/FTO scientific analysis and does not create substitute input data.
