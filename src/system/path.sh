#!/usr/bin/env bash

# Pure-Bash path helpers. These functions perform lexical path manipulation;
# they do not resolve symlinks or require the referenced paths to exist.

blm_path_is_absolute() {
  [[ ${1:-} == /* ]]
}

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
