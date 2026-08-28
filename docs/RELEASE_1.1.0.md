# Release 1.1.0 image manifest

Status: the corrected workflow runtime and UBB-buffering deployer are published to `glassbox-bio-public`. The exact r28 deployer passed the official Marketplace verifier and Artifact Analysis completed with zero fixable package issues on 2026-08-28. Marketplace Full Preview and observed Service Control acceptance with a freshly generated reporting Secret remain release gates.

Use this direct deployer tag for the Google Cloud Marketplace release:

```text
us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/deployer:1.0
```

Producer Portal continues to use the `1.0` display track. On 2026-08-28, the direct runtime and deployer `:1.0` aliases were refreshed to the corrected exact digests listed below for `:1.1.0`; unchanged helper and add-on images retain their previously verified digests. `latest` was not changed. The `:1.1.0` tags and exact digests remain the release source of truth.

The `1.1.0` direct and Preflight add-on images are immutable at these digests:

| Role | Production image | Digest |
| --- | --- | --- |
| Runtime | `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/glassbox-ipfto:1.1.0` | `sha256:85210fb384fc1c4c1a48f2a9a7f1b1ad29f416963ac17c7b8dd64ef91a427e3d` |
| Direct deployer | `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/deployer:1.1.0` | `sha256:997a5172cda7710b57f469f6b8aecf3a798b87679623f33a7546446ea9ad6d15` |
| Direct tester | `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/glassbox-ipfto/tester:1.1.0` | `sha256:a8b40e2f13a2a9b66a8853d3f6dbd3855bb0b14b4fe57a334d9e00fe41d3b733` |
| UBB agent | `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/glassbox-ipfto/ubbagent:1.1.0` | `sha256:b6ffe7f4c1b234859f84b4e2212a19379fa9820501294a01079d80c49d3f7202` |
| Preflight add-on deployer | `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/glassbox-ipfto/deployer:1.1.0` | `sha256:686078fb8c2b5ecdb0e6695713b545cdd722b7df15c5bf71eeab2e21a0241609` |
| Preflight add-on tester | `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/glassbox-ipfto/preflight-addon-tester:1.1.0` | `sha256:9e0164b8c58f3b394c9130cc0970390b4b2b4938ede8774397b3c4a9c799a974` |

The compatibility alias `glassbox-ipfto/preflight-addon-deployer:1.1.0` resolves to the same add-on deployer digest. For runtime launches, use the bare digest in `image.digest`; do not substitute a mutable tag.

The r28 runtime produced both independently verified Carahsoft proof runs. Test-project annotation build `0bb55a3f-91a3-4119-a3f2-407ac3d6cfab` produced the corrected deployer. Production promotion builds `1e39f062-a2e9-4998-80ab-2f4ed14ffca5` and `94cc667e-54a2-4f3c-a502-1f16798b7425` copied only the exact tested digests and refused unexpected destination state. A fresh official verification against the public deployer path passed with the public runtime and tester, then deleted temporary namespace `apptest-1nuvcqgg` cleanly.
