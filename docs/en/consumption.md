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

Supported module groups:

| Module | Purpose |
| --- | --- |
| `core` | version, capabilities, validation, output and environment helpers |
| `status` | core plus status rendering |
| `logging` | status plus logging |
| `requirements` | status plus requirement checks |
| `runtime` | requirements plus command execution and steps |
| `reliability` | runtime plus retry, wait, timeout, cleanup and rollback |
| `system` | requirements plus path, temporary-resource and filesystem helpers |
| `state` | system plus safe configuration and persistent state |
| `all` | complete public runtime |

Unknown module names return status `2`.

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

Existing installations are never replaced unless `--force` is provided.

For a system-wide install, privilege elevation is deliberately outside Bashloom:

```bash
sudo bash tools/install.sh --prefix /usr/local
```

Bashloom itself never invokes `sudo`.

## Vendoring

For applications that should carry a pinned Bashloom copy in their own repository:

```bash
bash /path/to/bashloom/tools/vendor.sh \
  --destination vendor/bashloom
```

The resulting project can use:

```bash
source "$PROJECT_ROOT/vendor/bashloom/bashloom.sh"
```

or selective loading:

```bash
source "$PROJECT_ROOT/vendor/bashloom/bashloom-loader.sh"
blm_load runtime reliability
```

Vendoring copies the complete `src/` runtime so that dependency resolution remains self-contained. Existing vendored copies require explicit `--force` replacement.

## Release workflow

Bashloom release tags use the `vMAJOR.MINOR.PATCH` convention.

Before a tagged release can be published, `tools/release-check.sh` verifies that the requested tag version exactly matches `BLM_VERSION` in `src/core/version.sh`.

A `v*` tag triggers the release workflow, which runs:

- Bash syntax checks;
- ShellCheck;
- shfmt verification;
- Bats tests;
- the maintained full feature tour;
- release metadata validation;
- archive creation and SHA-256 checksum generation;
- GitHub Release publication.

The release archive contains `src/`, `examples/`, `docs/`, `README.md`, `LICENSE` and `CHANGELOG.md`.

No `v0.1.0` tag should be created until the production-validation milestone is complete.

## Versioning policy before v1.0

Bashloom follows Semantic Versioning for public releases, but pre-1.0 APIs may still change while the project learns from real deployments.

`BLM_VERSION` is public diagnostic metadata. Before v1.0, consumers should pin a known release or vendored commit rather than infer API compatibility by parsing the version string.
