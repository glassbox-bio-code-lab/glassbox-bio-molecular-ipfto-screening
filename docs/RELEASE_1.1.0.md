# Release 1.1.0 image manifest

Status: published immutably to `glassbox-bio-public` and independently verified by digest on 2026-08-26.

Use this direct deployer tag for the Google Cloud Marketplace release:

```text
us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/deployer:1.1.0
```

The `1.1.0` direct and Preflight add-on images are immutable at these digests:

| Role | Production image | Digest |
| --- | --- | --- |
| Runtime | `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/glassbox-ipfto:1.1.0` | `sha256:5860d955609d6d8f715a4c0603b41402d8465e237424da1d5938450ac4c92d31` |
| Direct deployer | `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/deployer:1.1.0` | `sha256:bccf48933d5a18719f752891e7e1a084ce6ba41fadd1180fd152f7e97477963c` |
| Direct tester | `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/glassbox-ipfto/tester:1.1.0` | `sha256:a8b40e2f13a2a9b66a8853d3f6dbd3855bb0b14b4fe57a334d9e00fe41d3b733` |
| UBB agent | `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/glassbox-ipfto/ubbagent:1.1.0` | `sha256:b6ffe7f4c1b234859f84b4e2212a19379fa9820501294a01079d80c49d3f7202` |
| Preflight add-on deployer | `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/glassbox-ipfto/deployer:1.1.0` | `sha256:686078fb8c2b5ecdb0e6695713b545cdd722b7df15c5bf71eeab2e21a0241609` |
| Preflight add-on tester | `us-docker.pkg.dev/glassbox-bio-public/glassbox-bio-molecular-ip-fto-screening/glassbox-ipfto/preflight-addon-tester:1.1.0` | `sha256:9e0164b8c58f3b394c9130cc0970390b4b2b4938ede8774397b3c4a9c799a974` |

The compatibility alias `glassbox-ipfto/preflight-addon-deployer:1.1.0` resolves to the same add-on deployer digest. For runtime launches, use the bare digest in `image.digest`; do not substitute a mutable tag.
