#!/usr/bin/env bash

# Pure-Bash lexical path helpers.
#
# These functions manipulate strings only: they do not require paths to exist,
# resolve symlinks, normalize `..`, canonicalize mount points or access the
# filesystem. That distinction is important for config/deployment planning.

# Public API: blm_path_is_absolute
# Purpose: Test whether a path string begins at the POSIX filesystem root.
# Usage: blm_path_is_absolute <path>
# Returns: 0 when the supplied string starts with `/`, otherwise 1.
# Output: None.
# Side effects: None.
# Notes: This is lexical; `/a/../b` is still considered absolute as written.
blm_path_is_absolute() {
  [[ ${1:-} == /* ]]
}

# Public API: blm_path_dirname
# Purpose: Compute a lexical directory component without external `dirname`.
# Usage: blm_path_dirname <path>
# Returns: 0.
# Output: Directory component followed by newline.
# Side effects: None.
# Semantics:
#   empty or slash-free input -> `.`; root remains `/`; trailing slashes are
#   removed except when the entire path is root.
blm_path_dirname() {
  local path=${1:-}

  [[ -n $path ]] || {
    printf '.\n'
    return 0
  }

  # Remove trailing slashes except for the filesystem root.
  while [[ $path != / && $path == */ ]]; do
    path=${path%/}
  done

  if [[ $path != */* ]]; then
    printf '.\n'
    return 0
  fi

  path=${path%/*}
  [[ -n $path ]] || path=/

  while [[ $path != / && $path == */ ]]; do
    path=${path%/}
  done

  printf '%s\n' "$path"
}

# Public API: blm_path_basename
# Purpose: Compute a lexical final path component without external `basename`.
# Usage: blm_path_basename <path>
# Returns: 0.
# Output: Final component followed by newline; root produces `/`.
# Side effects: None.
# Notes: Trailing slashes are ignored except for the root path itself.
blm_path_basename() {
  local path=${1:-}

  while [[ $path != / && $path == */ ]]; do
    path=${path%/}
  done

  if [[ $path == / ]]; then
    printf '/\n'
  else
    printf '%s\n' "${path##*/}"
  fi
}

# Public API: blm_path_join
# Purpose: Join non-empty lexical path parts with one slash at each seam.
# Usage: blm_path_join <part>...
# Returns: 0.
# Output: Joined path, or `.` when every supplied part is empty/no parts exist.
# Side effects: None.
# Important: Only seam slashes are normalized. Internal duplicate slashes,
# `.` and `..` segments are intentionally preserved as caller data.
blm_path_join() {
  local result=""
  local part

  for part in "$@"; do
    [[ -n $part ]] || continue

    if [[ -z $result ]]; then
      result=$part
      continue
    fi

    result=${result%/}
    part=${part#/}
    result+="/$part"
  done

  [[ -n $result ]] || result=.
  printf '%s\n' "$result"
}
