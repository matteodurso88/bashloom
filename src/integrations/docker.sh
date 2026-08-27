#!/usr/bin/env bash

# Docker and Docker Compose integration primitives.
#
# The adapter targets the modern `docker compose` plugin form. It deliberately
# does not fall back to the legacy `docker-compose` executable because silently
# switching implementations would weaken reproducibility between local and CI
# environments.

# Public API: blm_docker_available
# Purpose: Test whether the Docker CLI is available in PATH.
# Usage: blm_docker_available
# Returns: 0 when `docker` exists, 1 otherwise.
# Output: None.
# Side effects: None.
blm_docker_available() {
  blm_has_command docker
}

# Public API: blm_docker_compose_available
# Purpose: Test whether the current Docker CLI exposes the Compose plugin.
# Usage: blm_docker_compose_available
# Returns:
#   0  `docker compose version` succeeds.
#   1  Docker is unavailable or the Compose plugin cannot be invoked.
# Output: Suppressed; this is a capability predicate.
# Side effects: None beyond starting the Docker CLI.
# External dependencies: docker.
blm_docker_compose_available() {
  blm_docker_available || return 1
  command docker compose version >/dev/null 2>&1
}

# Public API: blm_docker_compose
# Purpose: Execute arbitrary Docker Compose arguments without shell re-parsing.
# Usage: blm_docker_compose <compose-args...>
# Returns:
#   Exact status from `docker compose`, or 1 when the capability is unavailable.
# Output: Native Docker Compose stdout/stderr are preserved.
# Side effects: Determined entirely by the caller-supplied Compose arguments.
# External dependencies: docker with the Compose plugin.
# Security:
#   Arguments are forwarded as the original argv. No eval, sudo, interpolation
#   or implicit project selection is performed by Bashloom.
blm_docker_compose() {
  (($# >= 1)) || return 2

  if ! blm_docker_compose_available; then
    blm_error "Docker Compose plugin is not available"
    return 1
  fi

  command docker compose "$@"
}

# Public API: blm_docker_compose_up
# Purpose: Converge a Compose project to the running state in detached mode.
# Usage: blm_docker_compose_up [service...]
# Returns: Exact status from `docker compose up -d`.
# Output: Native Docker Compose output is preserved.
# Side effects: May create/start/recreate containers according to Compose rules.
# External dependencies: docker with Compose plugin.
# Notes:
#   Project/file/global Compose options should be supplied through environment
#   or by using blm_docker_compose directly. This helper intentionally owns the
#   `up -d` subcommand and accepts only optional service names after it.
blm_docker_compose_up() {
  blm_docker_compose up -d "$@"
}

# Public API: blm_docker_compose_down
# Purpose: Stop and remove resources using Compose's normal `down` semantics.
# Usage: blm_docker_compose_down [compose-down-args...]
# Returns: Exact status from `docker compose down`.
# Output: Native Docker Compose output is preserved.
# Side effects: Removes Compose-managed containers/networks as requested.
# External dependencies: docker with Compose plugin.
blm_docker_compose_down() {
  blm_docker_compose down "$@"
}
