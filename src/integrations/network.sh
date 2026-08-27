#!/usr/bin/env bash

# Network readiness primitives.
#
# Network checks use explicit feature-specific utilities instead of hidden shell
# behavior. Dependencies are validated only when the corresponding public API
# is called, preserving Bashloom's dependency-free sourcing contract.

# Public API: blm_dns_resolves
# Purpose: Test whether the system resolver can resolve a host name/address.
# Usage: blm_dns_resolves <host>
# Returns:
#   0  getent returns at least one address record.
#   1  Resolution fails or getent is unavailable.
#   2  Invalid Bashloom arguments.
# Output: Resolver output is suppressed; status is the public result.
# Side effects: Performs a normal resolver lookup according to system NSS rules.
# External dependencies: getent.
blm_dns_resolves() {
  (($# == 1)) || return 2
  local host=$1
  [[ -n $host ]] || return 2

  blm_require_command getent || return 1
  command getent ahosts "$host" >/dev/null 2>&1
}

# Public API: blm_http_check
# Purpose: Perform one HTTP(S) readiness request and require a successful code.
# Usage: blm_http_check <url>
# Returns:
#   0  curl completes successfully and the server returns HTTP 2xx/3xx.
#   non-zero  curl dependency, transport, TLS or HTTP failure.
# Output: Response body is discarded; curl diagnostics remain on stderr.
# Side effects: Performs one GET request.
# External dependencies: curl.
# Notes:
#   Redirects are followed. Authentication, custom headers and application-
#   specific success predicates should use blm_run with curl directly.
blm_http_check() {
  (($# == 1)) || return 2
  local url=$1
  [[ -n $url ]] || return 2

  blm_require_command curl || return 1
  command curl --fail --silent --show-error --location --output /dev/null -- "$url"
}

# Public API: blm_wait_http
# Purpose: Poll an HTTP(S) endpoint until it is ready or a deadline expires.
# Usage: blm_wait_http [--timeout S] [--interval S] <url>
# Returns:
#   0    Endpoint became ready before the deadline.
#   124  Deadline expired, matching blm_wait_for semantics.
#   2    Invalid Bashloom arguments.
#   other  Dependency or runtime polling failure.
# Output: Polling and timeout messages follow the Bashloom runtime contract.
# Side effects: Performs repeated HTTP GET requests until success/deadline.
# External dependencies: curl plus blm_wait_for runtime dependencies.
blm_wait_http() {
  local timeout=30
  local interval=1

  while (($#)); do
    case $1 in
      --timeout)
        (($# >= 2)) || return 2
        timeout=$2
        shift 2
        ;;
      --interval)
        (($# >= 2)) || return 2
        interval=$2
        shift 2
        ;;
      --)
        shift
        break
        ;;
      -*)
        return 2
        ;;
      *)
        break
        ;;
    esac
  done

  (($# == 1)) || return 2
  local url=$1
  [[ -n $url ]] || return 2

  blm_require_command curl || return 1
  blm_wait_for --timeout "$timeout" --interval "$interval" -- blm_http_check "$url"
}
