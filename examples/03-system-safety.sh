#!/usr/bin/env bash

# Bashloom example: system safety primitives (M3).
#
# All filesystem operations stay inside one temporary workspace.

set -Eeuo pipefail

EXAMPLE_DIR=${BASH_SOURCE[0]%/*}
[[ $EXAMPLE_DIR == "${BASH_SOURCE[0]}" ]] && EXAMPLE_DIR=.
REPO_ROOT="$(cd -- "$EXAMPLE_DIR/.." && pwd)"
source "$REPO_ROOT/src/bashloom.sh"

blm_require_command bash
blm_require_env HOME

if blm_require_root; then
  printf 'Running as root.\n'
else
  printf 'Running as a non-root user, as expected for this example.\n'
fi

workdir=$(blm_temp_dir)
cleanup_workspace() { rm -rf -- "$workdir"; }
blm_cleanup_add cleanup_workspace
blm_cleanup_enable_traps

file=$(blm_temp_file "$workdir")
blm_require_file "$file"
blm_require_dir "$workdir"
blm_require_readable "$file"
blm_require_writable "$file"
blm_require_executable "$workdir"

app_dir="$workdir/app/data"
blm_ensure_dir "$app_dir"
blm_ensure_dir "$app_dir"
blm_ensure_dir --mode 700 "$workdir/private"

real_file="$workdir/real.txt"
link_file="$workdir/link.txt"
printf 'real content\n' >"$real_file"
blm_ensure_symlink "$real_file" "$link_file"
blm_ensure_symlink "$real_file" "$link_file"

config="$workdir/config.ini"
printf 'version=old\n' >"$config"

generate_config() {
  printf 'version=new\n'
  printf 'enabled=true\n'
}

blm_atomic_write "$config" generate_config
[[ $(<"$config") == $'version=new\nenabled=true' ]]

printf 'dirname:  %s\n' "$(blm_path_dirname /var/lib/bashloom/config.ini)"
printf 'basename: %s\n' "$(blm_path_basename /var/lib/bashloom/config.ini)"
printf 'joined:   %s\n' "$(blm_path_join /var lib bashloom config.ini)"
blm_path_is_absolute /var/lib/bashloom

blm_cleanup_disable_traps
blm_cleanup_run
blm_success "M3 example completed"
