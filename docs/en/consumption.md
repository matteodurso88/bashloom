# Consumption model

Bashloom can be consumed in three supported ways during the pre-v0.1 phase:

1. source the full runtime from a checkout or vendored copy;
2. source the selective loader and request only the module groups needed;
3. install the runtime under an explicit prefix and source it from there.

No supported flow downloads and executes remote shell code implicitly, and no installer attempts privilege escalation.

## Full runtime

The simplest model is:

```bash
source /path/to/bashloom/src/bashloom.sh
```

This loads every public primitive currently shipped by Bashloom.

## Selective module loading

Consumers that want a smaller runtime surface can source the loader:

```bash
source /path/to/bashloom/src/bashloom-loader.sh
blm_load runtime system
```

`blm_load` is idempotent and resolves declared dependencies automatically.

Supported module groups include `core`, `status`, `terminal`, `logging`, `requirements`, `runtime`, `reliability`, `system`, `state`, `git`, `systemd`, `docker`, `network`, `integrations` and `all`. Unknown module names return status `2`.

## Prefix installation

From a checked-out Bashloom repository:

```bash
bash tools/install.sh
```

The default destination is:

```text
$HOME/.local/lib/bashloom
```

Then:

```bash
source "$HOME/.local/lib/bashloom/bashloom.sh"
```

An alternate prefix can be selected explicitly:

```bash
bash tools/install.sh --prefix /opt/example
```

Existing installations are never replaced unless `--force` is provided. Bashloom never invokes `sudo`; privilege elevation remains application/operator policy.

## Pinned vendoring

For applications that carry Bashloom inside their own repository, pinned vendoring is the recommended pre-v1.0 model.

From an approved Bashloom checkout/tag/commit:

```bash
bash tools/vendor.sh \
  --destination /path/to/consumer/vendor/bashloom \
  --pin b6a096ba1feb31f41a639856b29ae07e25ba3676
```

When `--pin` is omitted, the helper resolves the current Bashloom Git `HEAD`. If Git metadata is unavailable, callers must provide `--pin` explicitly.

The resulting bundle is:

```text
vendor/bashloom/
├── PIN
├── LICENSE
├── SHA256SUMS
└── src/
    ├── bashloom.sh
    ├── bashloom-loader.sh
    └── ...
```

Consumers source from the vendored `src/` tree:

```bash
source "$PROJECT_ROOT/vendor/bashloom/src/bashloom.sh"
```

or:

```bash
source "$PROJECT_ROOT/vendor/bashloom/src/bashloom-loader.sh"
blm_load runtime reliability
```

The vendor bundle is intended to remain byte-identical to the approved upstream material. Consumer-specific changes belong outside `vendor/bashloom/src/`.

### Integrity verification

Consumer CI can verify the vendored bundle without network access:

```bash
bash /path/to/bashloom/tools/vendor-verify.sh \
  "$PROJECT_ROOT/vendor/bashloom"
```

The verifier requires a non-empty `PIN`, validates the expected bundle shape and checks `LICENSE` plus every file under `src/` against `SHA256SUMS`. A modified or missing runtime file fails verification.

The intended lifecycle is:

```text
approved upstream commit/tag
→ explicit vendor update
→ PIN + SHA256SUMS committed with consumer
→ consumer CI integrity verification
→ deploy uses only the local vendored copy
```

There is no automatic tracking of upstream `main`, no runtime clone/download and no automatic repin. Rollback is a normal consumer revert or explicit repin to a previously approved Bashloom version.

Existing vendor destinations are never replaced unless `--force` is supplied.

## Release workflow

Bashloom release tags use the `vMAJOR.MINOR.PATCH` convention. Before a tagged release can be published, `tools/release-check.sh` verifies that the requested tag version exactly matches `BLM_VERSION` in `src/core/version.sh`.

A `v*` tag triggers the release workflow, which reruns syntax, ShellCheck, shfmt, Bats, maintained examples and release metadata gates before publishing the release archive and SHA-256 checksum.

No `v0.1.0` tag should be created until the production-validation milestone is complete.

## Versioning policy before v1.0

Bashloom follows Semantic Versioning for public releases, but pre-1.0 APIs may still change while the project learns from real deployments.

`BLM_VERSION` is public diagnostic metadata. Before v1.0, consumers should pin a known release or vendored commit rather than infer API compatibility by parsing the version string.
