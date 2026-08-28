#!/usr/bin/env bash

# APT integration primitives for Debian-family systems.
#
# This module is source-safe on every platform. It does not inspect the host or
# invoke package-manager commands until a public APT API is called. Mutating
# operations use apt-get because it is the scripting-oriented frontend. Query
# operations use dpkg-query and apt-cache. Bashloom never invokes sudo.

_blm_apt_require_available() {
  if ! blm_apt_available; then
    blm_error "APT integration is unavailable: apt-get, dpkg-query and apt-cache are required"
    return 1
  fi
}

_blm_apt_validate_package() {
  (($# == 1)) || return 2
  [[ -n $1 ]] || return 2
  [[ $1 != -* ]] || return 2
  [[ $1 != *$'\n'* && $1 != *$'\r'* ]] || return 2
  [[ $1 =~ ^[A-Za-z0-9][A-Za-z0-9.+:_~-]*([=][A-Za-z0-9.+:~_-]+)?$ ]]
}

_blm_apt_validate_packages() {
  (($# >= 1)) || return 2
  local package
  for package in "$@"; do
    _blm_apt_validate_package "$package" || {
      blm_error "Invalid APT package argument: $package"
      return 2
    }
  done
}

# Public API: blm_apt_available
# Purpose: Test whether the supported Debian-family package-management commands
#          are available to the current process.
# Usage: blm_apt_available
# Returns: 0 when apt-get, dpkg-query and apt-cache exist; 1 otherwise; 2 on args.
# Output: None.
# Side effects: None.
blm_apt_available() {
  (($# == 0)) || return 2
  blm_has_command apt-get && blm_has_command dpkg-query && blm_has_command apt-cache
}

# Public API: blm_apt_is_installed
# Purpose: Test whether one Debian package is installed in an installable state.
# Usage: blm_apt_is_installed <package>
# Returns: 0 when installed, 1 when absent/unavailable, 2 for invalid arguments.
# Output: None; dpkg-query output is suppressed.
# Side effects: Starts dpkg-query only.
# External dependencies: dpkg-query.
blm_apt_is_installed() {
  (($# == 1)) || return 2
  _blm_apt_validate_package "$1" || return 2
  _blm_apt_require_available || return 1
  [[ $(command dpkg-query -W -f='${db:Status-Status}' -- "$1" 2>/dev/null) == "installed ok installed" ]]
}

# Public API: blm_apt_installed_version
# Purpose: Print the installed version of one Debian package.
# Usage: blm_apt_installed_version <package>
# Returns: Exact dpkg-query status, 1 when APT integration is unavailable, 2 for
#          invalid arguments.
# Output: Installed version on stdout when available.
# Side effects: Starts dpkg-query only.
# External dependencies: dpkg-query.
blm_apt_installed_version() {
  (($# == 1)) || return 2
  _blm_apt_validate_package "$1" || return 2
  _blm_apt_require_available || return 1
  command dpkg-query -W -f='${Version}\n' -- "$1"
}

# Public API: blm_apt_candidate_version
# Purpose: Print the current APT candidate version for one package.
# Usage: blm_apt_candidate_version <package>
# Returns: 0 when a candidate is found, 1 when unavailable/absent, 2 on args.
# Output: Candidate version only.
# Side effects: Starts apt-cache only; package lists are never updated implicitly.
# External dependencies: apt-cache.
blm_apt_candidate_version() {
  (($# == 1)) || return 2
  _blm_apt_validate_package "$1" || return 2
  _blm_apt_require_available || return 1
  local candidate
  candidate=$(command apt-cache policy -- "$1" 2>/dev/null | awk '/^[[:space:]]*Candidate:/ { print $2; exit }') || return $?
  [[ -n $candidate && $candidate != '(none)' ]] || return 1
  printf '%s\n' "$candidate"
}

# Public API: blm_apt_update
# Purpose: Refresh APT package indexes using the scripting-oriented apt-get CLI.
# Usage: blm_apt_update
# Returns: Exact apt-get/blm_run status, 1 when unavailable, 2 on arguments.
# Output: Native apt-get/blm_run output.
# Side effects: May update system APT index state when the caller has permission.
# External dependencies: apt-get.
# Security: No sudo or privilege escalation is attempted. Global BLM_DRY_RUN is
#           honored through blm_run.
blm_apt_update() {
  (($# == 0)) || return 2
  _blm_apt_require_available || return 1
  blm_run -- apt-get update
}

# Public API: blm_apt_install
# Purpose: Install or converge one or more explicitly named Debian packages.
# Usage: blm_apt_install <package> [package...]
# Returns: Exact apt-get/blm_run status, 1 when unavailable, 2 on invalid args.
# Output: Native apt-get/blm_run output.
# Side effects: May install/upgrade packages according to apt-get semantics.
# External dependencies: apt-get.
# Security: Package operands are validated, argv is preserved, `--` separates
#           operands, and Bashloom never invokes sudo. BLM_DRY_RUN is honored.
blm_apt_install() {
  (($# >= 1)) || return 2
  _blm_apt_validate_packages "$@" || return $?
  _blm_apt_require_available || return 1
  blm_run -- apt-get install -y -- "$@"
}

# Public API: blm_apt_remove
# Purpose: Remove one or more explicitly named Debian packages.
# Usage: blm_apt_remove <package> [package...]
# Returns: Exact apt-get/blm_run status, 1 when unavailable, 2 on invalid args.
# Output: Native apt-get/blm_run output.
# Side effects: May remove packages according to apt-get semantics.
# External dependencies: apt-get.
# Security: No sudo; package operands are validated and argv-safe. BLM_DRY_RUN
#           is honored through blm_run.
blm_apt_remove() {
  (($# >= 1)) || return 2
  _blm_apt_validate_packages "$@" || return $?
  _blm_apt_require_available || return 1
  blm_run -- apt-get remove -y -- "$@"
}
