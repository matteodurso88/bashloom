# Bashloom Consumer Contract

This document defines the recommended integration model for projects that consume Bashloom locally, in CI, and in deployment workflows.

The goals are reproducibility, explicit version pinning, offline runtime use, integrity verification, and one consistent integration pattern across repositories.

## Recommended repository layout

```text
my-project/
├── vendor/
│   └── bashloom/
│       ├── PIN
│       ├── LICENSE
│       ├── SHA256SUMS
│       └── src/
│           ├── bashloom.sh
│           ├── bashloom-loader.sh
│           ├── core/
│           ├── ops/
│           ├── system/
│           ├── integrations/
│           └── ui/
├── scripts/
│   ├── lib/
│   │   └── bashloom.sh
│   ├── ci/
│   │   ├── verify-bashloom-vendor.sh
│   │   └── validate.sh
│   └── ...
└── .github/
    └── workflows/
```

The Bashloom runtime is stored inside the consumer repository. Deployment and CI must not rely on cloning Bashloom or downloading shell code at execution time.

## 1. Vendor a pinned Bashloom copy

Run the vendor tool from a trusted Bashloom checkout:

```bash
bash /path/to/bashloom/tools/vendor.sh \
  --destination vendor/bashloom \
  --pin <COMMIT_OR_TAG>
```

Updating an existing copy is always explicit:

```bash
bash /path/to/bashloom/tools/vendor.sh \
  --destination vendor/bashloom \
  --pin <NEW_COMMIT_OR_TAG> \
  --force
```

The resulting bundle contains:

```text
vendor/bashloom/
├── PIN
├── LICENSE
├── SHA256SUMS
└── src/
```

The consumer must not patch `vendor/bashloom/src/` locally. Generic defects belong upstream in Bashloom.

## 2. Verify vendor integrity

The official verifier can validate the vendored tree offline:

```bash
bash /path/to/bashloom/tools/vendor-verify.sh vendor/bashloom
```

A consumer may wrap that command in a project-local CI script. For example:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
exec bash "$ROOT_DIR/tools/bashloom-vendor-verify.sh" "$ROOT_DIR/vendor/bashloom"
```

Projects that do not copy the verifier itself should run the equivalent SHA-256 check in CI against `vendor/bashloom/SHA256SUMS`.

The important contract is that the vendored runtime can be proven unchanged before use.

## 3. Use one project adapter

Do not source Bashloom independently from every script. Prefer one repository-local adapter, for example:

```text
scripts/lib/bashloom.sh
```

Example:

```bash
#!/usr/bin/env bash

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
BASHLOOM_ROOT="$PROJECT_ROOT/vendor/bashloom"

project_bashloom_init() {
  local loader="$BASHLOOM_ROOT/src/bashloom-loader.sh"

  if [[ ! -f $loader ]]; then
    printf 'ERROR: Bashloom loader not found: %s\n' "$loader" >&2
    return 1
  fi

  # shellcheck source=/dev/null
  source "$loader"
  blm_load runtime system reliability
}
```

Consumer scripts then source only the adapter:

```bash
source "$PROJECT_ROOT/scripts/lib/bashloom.sh"
project_bashloom_init
```

This keeps Bashloom loading policy centralized.

## 4. Prefer selective module loading

Production consumers should load only the groups they need.

Installer example:

```bash
blm_load runtime system
```

Deployment example:

```bash
blm_load runtime reliability docker network
```

Systemd-oriented example:

```bash
blm_load runtime reliability systemd
```

`blm_load all` is useful for complete tools and prototypes, but selective loading makes the dependency surface clearer.

## 5. Migration / validation mode

During adoption or pre-release validation, a consumer may keep a baseline path and make Bashloom opt-in:

```bash
PROJECT_BASHLOOM=${PROJECT_BASHLOOM:-0}
```

A project wrapper can then preserve baseline behavior:

```bash
project_run() {
  case "$PROJECT_BASHLOOM" in
    1|true)
      blm_run -- "$@"
      ;;
    *)
      "$@"
      ;;
  esac
}
```

This enables parity tests such as:

```bash
PROJECT_BASHLOOM=0 bash scripts/install.sh
PROJECT_BASHLOOM=1 bash scripts/install.sh
```

Once the integration is validated and the project decides Bashloom is a normal dependency, the fallback may be removed.

## 6. Local CI and GitHub Actions should run the same scripts

Prefer project-local CI entrypoints:

```text
scripts/ci/
├── verify-bashloom-vendor.sh
├── lint.sh
├── test.sh
└── validate.sh
```

Example `validate.sh`:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/verify-bashloom-vendor.sh"
bash "$SCRIPT_DIR/lint.sh"
bash "$SCRIPT_DIR/test.sh"
```

Local execution:

```bash
bash scripts/ci/validate.sh
```

GitHub Actions:

```yaml
- uses: actions/checkout@v4

- name: Validate
  run: bash scripts/ci/validate.sh
```

The CI workflow should remain thin. Operational logic belongs in versioned shell scripts that can also run locally.

## 7. Do not download-and-execute Bashloom in CI or deploy

Avoid patterns such as:

```bash
git clone ...bashloom...
```

or:

```bash
curl ... | bash
```

inside deployment or validation workflows.

The trusted Bashloom version should already be present in the consumer checkout.

## 8. Updating Bashloom is an explicit consumer change

Recommended update flow:

```text
approved Bashloom commit/tag
→ vendor --force
→ integrity verification
→ git diff review
→ consumer CI
→ real consumer test where required
→ merge
```

Example:

```bash
bash /path/to/bashloom/tools/vendor.sh \
  --destination vendor/bashloom \
  --pin <NEW_SHA> \
  --force

bash scripts/ci/verify-bashloom-vendor.sh
bash scripts/ci/validate.sh
```

Consumers must never silently track upstream `main`.

## 9. PIN semantics

`vendor/bashloom/PIN` is intentionally simple and should contain the exact approved commit or tag reference used to create the bundle.

Example:

```text
8489c1a14bca668febd977dfb826fb55d5bb27b1
```

Rich metadata, if added in the future, should live in a separate file rather than overloading `PIN`.

## 10. Upstream feedback policy

If a consumer discovers a generic Bashloom problem, report it upstream with:

- Bashloom PIN;
- consumer workflow;
- expected behavior;
- observed behavior;
- exit status;
- sanitized minimal reproduction where possible.

Do not carry hidden local fixes inside the vendored source tree.

After an upstream fix is merged, the consumer explicitly repins and reruns its own validation.

## Recommended contract summary

1. Vendor Bashloom in the consumer repository.
2. Pin an explicit commit or tag.
3. Keep `PIN`, `LICENSE`, `SHA256SUMS`, and complete `src/`.
4. Never patch vendored Bashloom sources locally.
5. Use one project-local Bashloom adapter.
6. Prefer selective `blm_load` groups.
7. Run the same CI scripts locally and on GitHub Actions.
8. Do not clone/curl Bashloom during deploy or CI.
9. Update Bashloom only through explicit repinning.
10. Run consumer CI after every repin.
11. Report generic defects and improvements upstream.

This model is the recommended Bashloom integration baseline for reusable applications, installers, infrastructure repositories, and CI/CD workflows.
