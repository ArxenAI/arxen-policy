# arxen-policy — Claude Code Guide

> 📋 **Cross-repo context:** Read ../ARXEN_CONTEXT.md for full project state, architecture decisions, and repo map.

## Purpose

> 📋 **Cross-repo context:** Read ../ARXEN_CONTEXT.md for full project state, architecture decisions, and repo map.

Cluster-level security guardrails: Kyverno admission policies and OPA/Rego rules for IaC. Enforces SOC2, HIPAA, and GDPR controls across all Arxen-managed Kubernetes clusters.

## Architecture

> 📋 **Cross-repo context:** Read ../ARXEN_CONTEXT.md for full project state, architecture decisions, and repo map.

```
kyverno/
  <tier>/
    <policy-name>/
      policy.yaml           # The ClusterPolicy definition

> 📋 **Cross-repo context:** Read ../ARXEN_CONTEXT.md for full project state, architecture decisions, and repo map.
      kyverno-test.yaml     # Required unit test (pass + fail cases)

> 📋 **Cross-repo context:** Read ../ARXEN_CONTEXT.md for full project state, architecture decisions, and repo map.
iac/
  azure/
    <rule-name>.rego        # OPA/Rego rule for Azure IaC validation

> 📋 **Cross-repo context:** Read ../ARXEN_CONTEXT.md for full project state, architecture decisions, and repo map.
    <rule-name>_test.rego   # Required tests

> 📋 **Cross-repo context:** Read ../ARXEN_CONTEXT.md for full project state, architecture decisions, and repo map.
  common/
    <rule-name>.rego        # Cloud-agnostic OPA/Rego rules

> 📋 **Cross-repo context:** Read ../ARXEN_CONTEXT.md for full project state, architecture decisions, and repo map.
    <rule-name>_test.rego   # Required tests

> 📋 **Cross-repo context:** Read ../ARXEN_CONTEXT.md for full project state, architecture decisions, and repo map.
```

## Kyverno Policy Standards

> 📋 **Cross-repo context:** Read ../ARXEN_CONTEXT.md for full project state, architecture decisions, and repo map.

**Every policy MUST have:**
- `kind: ClusterPolicy` (not namespace-scoped `Policy`) unless explicitly required
- `validationFailureAction: Enforce` (default) or `Audit` — always explicit
- `background: true` to scan existing resources
- Descriptive `message` explaining the failure, why it failed, and how to fix it
- `exclude` block for system namespaces: `kube-system`, `kyverno`, `argo-system`, `cert-manager`, `external-secrets`
- Compliance mapping in annotations (e.g., `policies.kyverno.io/controls: "SOC2 CC6.1"`)

**Policy metadata annotation pattern:**
```yaml
annotations:
  policies.kyverno.io/title: "Block Latest Image Tag"
  policies.kyverno.io/category: "Image Security"
  policies.kyverno.io/controls: "SOC2 CC6.1"
  policies.kyverno.io/description: >-
    Container images must use pinned semantic versions, not 'latest'.
```

## Testing

> 📋 **Cross-repo context:** Read ../ARXEN_CONTEXT.md for full project state, architecture decisions, and repo map.

Every `policy.yaml` requires a sibling `kyverno-test.yaml` with both `pass` and `fail` test cases.

Run tests locally:
```powershell
kyverno test kyverno/baseline/ --detailed-results
kyverno test kyverno/regulated/ --detailed-results
kyverno test kyverno/tenant-isolation/ --detailed-results
```

## Constraints

> 📋 **Cross-repo context:** Read ../ARXEN_CONTEXT.md for full project state, architecture decisions, and repo map.

- Never match `*` (all resource kinds) — scope `match.any[].resources.kinds` to specific kinds
- Never omit the test file — policies without tests will not be merged
- Never write `mutate` rules that could silently change user-submitted resources without an audit trail
