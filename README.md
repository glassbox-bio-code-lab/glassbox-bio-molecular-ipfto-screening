# Glassbox Bio Molecular IP / Freedom-to-Operate Screening
## Evidence-linked molecular IP/Freedom-to-Operate screening with signed, cryptographically verifiable outputs


## Description
Glassbox Bio Molecular IP / Freedom-to-Operate Screening is a Kubernetes-native analysis product for small-molecule biotech and pharmaceutical workflows running inside the customer’s Google Cloud environment.

It screens target- and chemistry-specific patent landscapes, identifies potentially relevant patent families, highlights potential freedom-to-operate risks, and generates evidence-linked outputs for internal scientific, strategic, and diligence review.

Each run produces both structured raw outputs and polished review artifacts. Deliverables include the underlying machine-readable output files, a rendered screening report, evidence-linked findings, and associated run metadata for traceability and downstream review. The sample report you attached is explicitly framed as a decision-grade IP/FTO screening packet with evidence-linked conclusions and exportable tables, which supports describing the deliverable as both raw analytical output and a review-ready report.

Outputs are cryptographically sealed using Glassbox Bio verification artifacts. The bundle includes signed seal materials such as seal.json, seal.sig, and verification support files, allowing recipients to validate signature integrity and confirm that recorded hashes match the bundle contents. Your uploaded verification files explicitly state that the bundle includes a signed Glassbox seal and can be manually verified using the public key and the referenced files.

The attached preseal and seal records also show that the output package carries run-level provenance fields such as input hashes, manifest hashes, verification summary hashes, provenance hashes, module versioning, and signing-key fingerprint information. That supports strong language around integrity, provenance, and verifiable output packaging.

The product deploys with the Glassbox Bio Preflight control interface when needed, giving customers a unified operational surface for execution and output review. Customers who already have a Glassbox environment can attach the module to their existing workflow, while standalone deployments can start directly from the same interface.

This product is designed for internal screening and decision support. It helps teams prioritize risk, identify potential blockers, support design-around thinking, and decide when deeper counsel review is warranted. It is not a substitute for formal legal advice or legal opinion.

The product is offered through two usage paths depending on how the IP/FTO screening is being run within the Glassbox workflow.


## Mode Types
IP/FTO Add-On Run
This usage path applies when IP/FTO screening is performed after a prior Glassbox molecular audit has already been run. In this case, the screening operates within the existing Glassbox workflow and builds on the prior audit context and environment already in place.

IP/FTO Standalone Run
This usage path applies when IP/FTO screening is initiated without a prior Glassbox molecular audit. In standalone use, the deployment includes the Glassbox Preflight control interface when needed so the customer can operate the screening workflow directly from the same unified environment.

Disclaimer
For internal screening and decision support only. Not a substitute for formal legal advice or legal opinion.



## Example Input: Standalone Run

```json

  {
    "project_name": "BCR-ABL1 inhibitor FTO screen",
    "invention_description": "Novel ABL1 inhibitor for Philadelphia chromosome-positive CML",
    "primary_target": "ABL1",
    "indication": "Chronic myeloid leukemia, Philadelphia chromosome-positive",
    "modality": "small_molecule",
    "jurisdiction_scope": ["US", "EP", "WO"],
    "applicant_or_company_name": "Example Therapeutics",
    "target_synonyms": ["Tyrosine-protein kinase ABL1", "BCR-ABL1", "P00519"],
    "invention_synonyms": ["ABL1 inhibitor", "BCR-ABL inhibitor"],
    "must_include_terms": [],
    "must_exclude_terms": [],
    "known_compounds_or_assets": [],
    "claims_focus": ["composition_of_matter", "method_of_use"],
    "additional_instructions": ""
  }
```
