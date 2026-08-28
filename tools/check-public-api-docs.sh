#!/usr/bin/env bash

set -Eeuo pipefail

ROOT=${BASH_SOURCE[0]%/*}
[[ $ROOT == "${BASH_SOURCE[0]}" ]] && ROOT=.
ROOT="$(cd -- "$ROOT/.." && pwd)"

TMP=$(mktemp -d)
trap 'rm -rf -- "$TMP"' EXIT

SOURCE_FILES="$TMP/source-files"
DEFINITIONS="$TMP/definitions"
MARKERS="$TMP/markers"
EN_DOCS="$TMP/en-docs"
IT_DOCS="$TMP/it-docs"

find "$ROOT/src" -type f -name '*.sh' -print | sort >"$SOURCE_FILES"

while IFS= read -r file; do
  grep -E '^blm_[A-Za-z0-9_]+\(\)[[:space:]]*\{' "$file" || true
done <"$SOURCE_FILES" \
  | sed -E 's/^((blm_[A-Za-z0-9_]+))\(\).*/\2/' \
  | sort >"$DEFINITIONS"

while IFS= read -r file; do
  grep -E '^# Public API: blm_[A-Za-z0-9_]+' "$file" || true
done <"$SOURCE_FILES" \
  | sed -E 's/^# Public API: (blm_[A-Za-z0-9_]+).*/\1/' \
  | sort >"$MARKERS"

fail=0

if [[ -s $DEFINITIONS ]]; then
  duplicate_definitions=$(uniq -d "$DEFINITIONS" || true)
  if [[ -n $duplicate_definitions ]]; then
    printf 'Duplicate public function definitions:\n%s\n' "$duplicate_definitions" >&2
    fail=1
  fi
fi

if [[ -s $MARKERS ]]; then
  duplicate_markers=$(uniq -d "$MARKERS" || true)
  if [[ -n $duplicate_markers ]]; then
    printf 'Duplicate Public API markers:\n%s\n' "$duplicate_markers" >&2
    fail=1
  fi
fi

missing_markers=$(comm -23 "$DEFINITIONS" "$MARKERS" || true)
if [[ -n $missing_markers ]]; then
  printf 'Public blm_* functions missing exact source marker:\n%s\n' "$missing_markers" >&2
  fail=1
fi

orphan_markers=$(comm -13 "$DEFINITIONS" "$MARKERS" || true)
if [[ -n $orphan_markers ]]; then
  printf 'Public API markers without matching public function:\n%s\n' "$orphan_markers" >&2
  fail=1
fi

find "$ROOT/docs/en" -type f -name '*.md' -printf '%P\n' | sort >"$EN_DOCS"
find "$ROOT/docs/it" -type f -name '*.md' -printf '%P\n' | sort >"$IT_DOCS"

doc_structure_diff=$(comm -3 "$EN_DOCS" "$IT_DOCS" || true)
if [[ -n $doc_structure_diff ]]; then
  printf 'Canonical EN/IT documentation file parity mismatch:\n%s\n' "$doc_structure_diff" >&2
  fail=1
fi

while IFS= read -r api; do
  [[ -n $api ]] || continue
  if ! grep -R -F -q -- "\`$api\`" "$ROOT/docs/en"; then
    printf 'Public API missing from canonical English docs: %s\n' "$api" >&2
    fail=1
  fi
  if ! grep -R -F -q -- "\`$api\`" "$ROOT/docs/it"; then
    printf 'Public API missing from canonical Italian docs: %s\n' "$api" >&2
    fail=1
  fi
done <"$DEFINITIONS"

if ((fail != 0)); then
  exit 1
fi

printf 'Public API/documentation contract OK: %s APIs; EN/IT canonical parity verified.\n' "$(wc -l <"$DEFINITIONS")"
