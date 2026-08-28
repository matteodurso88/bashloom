# APT integration

Bashloom provides an optional Debian-family package-management module for operational scripts and provisioning workflows.

The module is **source-safe on every platform**. Loading `apt` or `integrations` does not execute APT, inspect package state or require a Debian host. Availability is checked only when an APT public API is called.

## Public API

```bash
blm_apt_available
blm_apt_is_installed <package>
blm_apt_installed_version <package>
blm_apt_candidate_version <package>
blm_apt_update
blm_apt_install <package> [package...]
blm_apt_remove <package> [package...]
```

Selective loading:

```bash
source /path/to/bashloom/src/bashloom-loader.sh
blm_load apt
```

The complete `integrations` and `all` groups also include APT.

## Command policy

Bashloom deliberately uses:

- `apt-get` for update/install/remove operations;
- `dpkg-query` for installed-state/version queries;
- `apt-cache` for candidate-version queries.

The interactive `apt` frontend is not used for scripted mutation.

`blm_apt_available` requires all three supported commands. On a non-Debian system it normally returns `1`; sourcing Bashloom remains successful.

## Privileges

Bashloom never invokes `sudo` and never attempts privilege escalation.

The caller chooses the privilege boundary. For example, a system provisioning script can itself be run as root or use an external operator-controlled privilege mechanism before calling Bashloom.

## Package operands

Install/remove package operands are validated before execution. Empty operands, option-like names and newline/control-line injection are rejected with status `2`.

Typical package names, architecture-qualified names and explicit version operands are accepted, for example:

```text
curl
libssl3:amd64
package-name=1.2.3-1
```

Operands are passed as argv after `--`; Bashloom does not use `eval` or reparse shell syntax.

## Dry-run

Mutating APT helpers execute through `blm_run`, so the standard Bashloom dry-run contract applies:

```bash
BLM_DRY_RUN=1 blm_apt_install curl ca-certificates
```

This renders the command but does not invoke `apt-get`.

Dry-run does not bypass capability validation: the APT toolchain must still be available. This catches platform/configuration mistakes before a real provisioning run.

## Query semantics

`blm_apt_is_installed` is a predicate: `0` means installed, `1` means absent/unavailable.

`blm_apt_installed_version` prints the installed version and preserves `dpkg-query` status.

`blm_apt_candidate_version` parses the current `apt-cache policy` candidate without implicitly refreshing package indexes. If no candidate exists it returns `1`.

## Reproducibility

Bashloom does not silently run `apt-get update` before install/remove operations. Index refresh is an explicit operation:

```bash
blm_apt_update
blm_apt_install curl
```

This keeps provisioning order visible to the caller and avoids hidden network/system mutations.
