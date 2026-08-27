#!/usr/bin/env bash

# systemd integration primitives.
#
# Bashloom never escalates privileges implicitly. These helpers call systemctl
# exactly as the current user and preserve command failures so callers can
# decide whether sudo, rollback, retry or termination is appropriate.

# Public API: blm_systemd_is_active
# Purpose: Test whether a systemd unit is currently active.
# Usage: blm_systemd_is_active <unit>
# Returns:
#   0  systemctl reports the unit active.
#   non-zero  systemctl is unavailable or reports a non-active state.
# Output: None from systemctl because --quiet is used.
# Side effects: None.
# External dependencies: systemctl.
blm_systemd_is_active() {
  (($# == 1)) || return 2
  local unit=$1

  blm_require_command systemctl || return 1
  command systemctl is-active --quiet -- "$unit"
}

# Public API: blm_systemd_wait_active
# Purpose: Poll a systemd unit until it becomes active or a deadline expires.
# Usage: blm_systemd_wait_active [--timeout S] [--interval S] <unit>
# Returns:
#   0    Unit became active before the deadline.
#   124  Deadline expired, matching blm_wait_for timeout semantics.
#   2    Invalid Bashloom arguments.
#   other  Dependency or sleep/polling failure propagated by the runtime.
# Output:
#   Retry/timeout messages follow the normal Bashloom output contract.
# Side effects: Repeated read-only systemctl queries.
# External dependencies: systemctl and the dependencies of blm_wait_for.
blm_systemd_wait_active() {
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
  local unit=$1

  blm_require_command systemctl || return 1
  blm_wait_for --timeout "$timeout" --interval "$interval" -- blm_systemd_is_active "$unit"
}

# Public API: blm_systemd_restart
# Purpose: Restart one unit using the caller's existing systemd privileges.
# Usage: blm_systemd_restart <unit>
# Returns: Exact status returned by systemctl, or 1 when systemctl is missing.
# Output: Native systemctl output is preserved.
# Side effects: Requests a unit restart.
# External dependencies: systemctl.
# Security: No sudo or other privilege escalation is attempted.
blm_systemd_restart() {
  (($# == 1)) || return 2
  local unit=$1

  blm_require_command systemctl || return 1
  command systemctl restart -- "$unit"
}

# Public API: blm_systemd_reload
# Purpose: Ask systemd to reload one unit without hiding the native result.
# Usage: blm_systemd_reload <unit>
# Returns: Exact status returned by systemctl, or 1 when systemctl is missing.
# Output: Native systemctl output is preserved.
# Side effects: Requests a unit reload.
# External dependencies: systemctl.
# Security: No implicit privilege escalation.
blm_systemd_reload() {
  (($# == 1)) || return 2
  local unit=$1

  blm_require_command systemctl || return 1
  command systemctl reload -- "$unit"
}
