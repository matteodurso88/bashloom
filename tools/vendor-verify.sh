#!/usr/bin/env bash

# Verify an existing Bashloom consumer bundle without network access.
#
# The verifier checks the bundle shape, requires a non-empty PIN and validates
# the recorded SHA-256 manifest for LICENSE plus the complete vendored src tree.

set -Eeuo pipefail

usage() {
  cat <<'EOF'
Usage: tools/vendor-verify.sh <vendor-directory>

Verify a vendored Bashloom bundle created by tools/vendor.sh.
EOF
}

(($# == 1)) || {
  usage >&2
  exit 2
}

vendor_dir=$1

command -v sha256sum >/dev/null 2>&1 || {
  printf 'Required command not found: sha256sum\n' >&2
  exit 1
}

[[ -d $vendor_dir ]] || {
  printf 'Vendor directory not found: %s\n' "$vendor_dir" >&2
  exit 1
}

for required in PIN LICENSE SHA256SUMS src/bashloom.sh src/bashloom-loader.sh; do
  [[ -f $vendor_dir/$required ]] || {
    printf 'Vendored Bashloom bundle is incomplete: missing %s\n' "$required" >&2
    exit 1
  }
done

IFS= read -r pin <"$vendor_dir/PIN" || true
[[ -n ${pin:-} ]] || {
  printf 'Vendored Bashloom PIN is empty.\n' >&2
  exit 1
}

(
  cd -- "$vendor_dir"
  sha256sum --check --strict SHA256SUMS
)

printf 'Bashloom vendor integrity PASS\n'
printf 'Pin: %s\n' "$pin"
