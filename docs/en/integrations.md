# Integrations

Bashloom integrations are thin adapters around external system tools. They add predictable argument handling, dependency checks and Bashloom-compatible status semantics without hiding the underlying tool or inventing operational policy.

## Design rules

- dependencies are checked only when the relevant integration function is called;
- sourcing Bashloom remains free of Git, systemd, Docker, curl or getent requirements;
- no adapter performs implicit `sudo` or privilege escalation;
- command arguments are forwarded as argv, never reconstructed through `eval`;
- native command status and diagnostics are preserved unless the Bashloom API explicitly defines a transformed status such as timeout `124`;
- destructive policy remains explicit at the application layer.

## Git

```bash
blm_git_root [path]
blm_git_current_branch [path]
blm_git_is_clean [path]
blm_git_require_clean [path]
```

`blm_git_is_clean` treats untracked files as dirty. `blm_git_current_branch` returns non-zero for detached HEAD, which is expected in many CI checkouts.

## systemd

```bash
blm_systemd_is_active <unit>
blm_systemd_wait_active [--timeout S] [--interval S] <unit>
blm_systemd_restart <unit>
blm_systemd_reload <unit>
```

The helpers invoke `systemctl` as the current user. Bashloom never adds `sudo`. Waiting delegates to `blm_wait_for`, so deadline expiry returns status `124`.

## Docker Compose

```bash
blm_docker_available
blm_docker_compose_available
blm_docker_compose <compose-args...>
blm_docker_compose_up [service...]
blm_docker_compose_down [compose-down-args...]
```

The adapter targets the modern `docker compose` plugin and deliberately does not switch silently to legacy `docker-compose`. `blm_docker_compose` is the general argv-safe escape hatch; `up` and `down` are convenience wrappers.

## Network readiness

```bash
blm_dns_resolves <host>
blm_http_check <url>
blm_wait_http [--timeout S] [--interval S] <url>
```

DNS resolution uses `getent` and therefore follows the host system's NSS configuration. HTTP readiness uses `curl --fail` and follows redirects; HTTP 4xx/5xx and transport/TLS errors are failures. More specialized HTTP authentication, headers or response predicates should call curl explicitly through `blm_run` rather than expanding this primitive into a hidden HTTP client.

## Selective loading

The loader exposes individual integration groups:

```bash
source /path/to/bashloom-loader.sh
blm_load git
blm_load systemd
blm_load docker
blm_load network
```

or the aggregate group:

```bash
blm_load integrations
```

`blm_load all` includes all currently shipped integrations.

## Source documentation

M6D also introduces the repository-wide source documentation contract. Public APIs are documented close to their implementation with machine-checkable `# Public API: blm_name` markers and deeper prose covering status semantics, output, side effects, dependencies and non-obvious invariants. CI rejects undocumented public functions.
