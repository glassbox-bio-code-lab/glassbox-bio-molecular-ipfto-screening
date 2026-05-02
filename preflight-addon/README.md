# Glassbox IP/FTO Preflight Add-On

Nested Preflight integration package for the Glassbox Bio Molecular IPFTO Screening product.

This directory belongs to the same product package as the parent `glassbox-bio-molecular-ipfto-screening` bundle. It exists separately inside the repo because Marketplace validation needs a deployer/tester surface for the Preflight add-on resources, but it is not a separate product.

This bundle does not ship the Preflight UI itself. Instead, it provides:

- the Kubernetes resources that the generic Preflight add-on launcher expects
- a preflight values overlay that registers the `ipfto` add-on in the UI contract
- customer docs for the validated add-on execution path

Current supported in-cluster execution modes:

- `phase2a_only`
- `full`

See:

- `chart/ipfto-addon/` for the resource-only Helm chart
- `deployer/Dockerfile` for the Marketplace Helm deployer image
- `apptest/tester/Dockerfile` for the Marketplace verification tester image
- `apptest/deployer/` for the Marketplace verification overlay
- `examples/preflight-values.ipfto.yaml` for the Preflight registry overlay
- `docs/USER_GUIDE.md` for installation guidance

The verification tester checks Kubernetes add-on wiring only. It does not run IP/FTO analysis or create scientific inputs.
