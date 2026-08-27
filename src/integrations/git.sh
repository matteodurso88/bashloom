#!/usr/bin/env bash

# Git integration primitives.
#
# This module intentionally keeps Git visible to the caller. Bashloom adds
# validation, stable exit semantics and small reusable queries, but does not
# invent repository policy or perform implicit mutations.

# Public API: blm_git_root
# Purpose: Print the absolute root directory of a Git work tree.
# Usage: blm_git_root [path]
# Arguments:
#   path  Optional directory inside the repository. Defaults to the current
#         working directory.
# Output:
#   Writes the repository root to stdout on success.
# Returns:
#   0  The path belongs to a Git work tree.
#   1  Git is unavailable, the path is invalid, or Git rejects the query.
# Side effects: None.
# External dependencies: git, checked only when this function is called.
blm_git_root() {
  (($# <= 1)) || return 2
  local path=${1:-.}

  blm_require_command git || return 1
  command git -C "$path" rev-parse --show-toplevel
}

# Public API: blm_git_current_branch
# Purpose: Print the symbolic branch currently checked out in a repository.
# Usage: blm_git_current_branch [path]
# Arguments:
#   path  Optional repository path. Defaults to the current directory.
# Output:
#   Writes the short branch name to stdout.
# Returns:
#   0  A symbolic branch is checked out.
#   1  Git is unavailable, the path is not a repository, or HEAD is detached.
# Side effects: None.
# External dependencies: git.
blm_git_current_branch() {
  (($# <= 1)) || return 2
  local path=${1:-.}

  blm_require_command git || return 1
  command git -C "$path" symbolic-ref --quiet --short HEAD
}

# Public API: blm_git_is_clean
# Purpose: Test whether tracked and untracked work-tree state is clean.
# Usage: blm_git_is_clean [path]
# Returns:
#   0  `git status --porcelain` produces no records.
#   1  The repository is dirty or the Git query cannot be completed.
# Output: None on success or dirty state.
# Side effects: None.
# External dependencies: git.
# Notes:
#   Untracked files count as dirty. This deliberately matches deployment and
#   release workflows where any local divergence should be explicit.
blm_git_is_clean() {
  (($# <= 1)) || return 2
  local path=${1:-.}

  blm_require_command git || return 1

  local status
  status=$(command git -C "$path" status --porcelain --untracked-files=normal) || return $?
  [[ -z $status ]]
}

# Public API: blm_git_require_clean
# Purpose: Enforce a clean Git work tree without terminating the caller shell.
# Usage: blm_git_require_clean [path]
# Returns:
#   0  Repository is clean.
#   1  Repository is dirty or cannot be inspected.
# Output:
#   Emits a Bashloom error record to stderr when the repository is not clean.
# Side effects: None.
# External dependencies: git through blm_git_is_clean.
blm_git_require_clean() {
  (($# <= 1)) || return 2
  local path=${1:-.}

  if blm_git_is_clean "$path"; then
    return 0
  fi

  blm_error "Git work tree is not clean: $path"
  return 1
}
