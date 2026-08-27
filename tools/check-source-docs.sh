#!/usr/bin/env bash

# Enforce Bashloom's source-documentation contract.
#
# Every public `blm_*` function must have a nearby `# Public API: <name>` marker.
# The marker is intentionally machine-checkable while the remaining block stays
# prose-oriented, so maintainers can document purpose, arguments, returns,
# output, side effects, dependencies and non-obvious invariants naturally.

set -Eeuo pipefail

ROOT=${BASH_SOURCE[0]%/*}
[[ $ROOT == "${BASH_SOURCE[0]}" ]] && ROOT=.
ROOT="$(cd -- "$ROOT/.." && pwd)"

status=0

while IFS= read -r -d '' file; do
  if ! awk '
    {
      previous[NR] = $0
    }
    /^blm_[A-Za-z0-9_]+\(\)[[:space:]]*\{/ {
      function_line = $0
      sub(/\(\).*/, "", function_line)
      marker = "# Public API: " function_line
      found = 0
      lower = NR - 24
      if (lower < 1) lower = 1
      for (line = NR - 1; line >= lower; line--) {
        if (previous[line] == marker) {
          found = 1
          break
        }
      }
      if (!found) {
        printf "%s:%d: missing source documentation marker for %s\n", FILENAME, NR, function_line > "/dev/stderr"
        failed = 1
      }
    }
    END {
      exit failed ? 1 : 0
    }
  ' "$file"; then
    status=1
  fi
done < <(find "$ROOT/src" -type f -name '*.sh' -print0)

exit "$status"
