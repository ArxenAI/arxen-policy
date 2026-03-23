# arxen-policy

Policy-as-code enforcement layer for Arxen: Kubernetes admission policies
(Kyverno) and IaC validation rules (OPA/Conftest).

## Scope

- Kubernetes admission policies via Kyverno ClusterPolicies
- IaC policy checks via OPA/Rego rules validated with Conftest
- Baseline controls applied to all Arxen-managed namespaces
- Regulated controls for SOC2, HIPAA, and GDPR workloads
- Tenant isolation boundaries enforced at the Kubernetes API level

## Goals

- Prevent insecure configurations from reaching production
- Provide clear, explainable policy failures with fix instructions
- Keep policy definitions versioned, tested, and reviewable
- Map every rule to a specific compliance control ID

## Structure

```
kyverno/
  baseline/          # Applied to all arxen.io/managed namespaces
  regulated/         # Applied to soc2/hipaa/gdpr compliance-tier namespaces
  tenant-isolation/  # Tenant boundary enforcement
iac/
  azure/             # Azure-specific OpenTofu plan validation (MVP)
  common/            # Cloud-agnostic IaC rules
docs/
  compliance-mapping.md  # Control ID → policy file index
```

## Requirements

- [Kyverno CLI](https://kyverno.io/docs/kyverno-cli/) v1.12+
- [OPA](https://www.openpolicyagent.org/docs/latest/) v0.68+
- [Conftest](https://www.conftest.dev/) v0.50+

Install all tools (Windows):

```powershell
winget install kyverno.kyverno
winget install open-policy-agent.opa
# Conftest — download from https://github.com/open-policy-agent/conftest/releases
```

Install all tools (macOS):

```bash
brew install kyverno opa conftest
```

Install all tools (Linux):

```bash
curl -sSL https://github.com/kyverno/kyverno/releases/download/v1.12.5/kyverno_linux_amd64.tar.gz | tar -xz -C /usr/local/bin kyverno
curl -sSL https://github.com/open-policy-agent/opa/releases/download/v0.68.0/opa_linux_amd64_static -o /usr/local/bin/opa && chmod +x /usr/local/bin/opa
curl -sSL https://github.com/open-policy-agent/conftest/releases/download/v0.50.0/conftest_0.50.0_Linux_x86_64.tar.gz | tar -xz -C /usr/local/bin conftest
```

## Running Tests

Kyverno policy tests:

```powershell
kyverno test kyverno/baseline/ --detailed-results
kyverno test kyverno/regulated/ --detailed-results
kyverno test kyverno/tenant-isolation/ --detailed-results
```

OPA/Rego unit tests:

```powershell
opa test iac/azure/ --verbose
opa test iac/common/ --verbose
```

Validate a real OpenTofu plan against Azure rules:

```powershell
conftest test plan.json --policy iac/azure/ --policy iac/common/
```

## Compliance Mapping

See [docs/compliance-mapping.md](docs/compliance-mapping.md) for the
full index of policies to SOC2, HIPAA, and GDPR control IDs.

## Contributing

Every policy file must have a sibling test file with at least one `pass`
and one `fail` case. PRs without tests will not be merged. See
[CLAUDE.md](CLAUDE.md) for full authoring standards.

## License

Apache-2.0
