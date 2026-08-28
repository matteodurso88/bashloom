# Public API index

This page is the explicit v0.1 RC coverage index for Bashloom's public surface. Detailed semantics, examples, failure modes and portability notes remain in the topic-specific canonical documentation. The purpose of this index is to make the supported `blm_*` names unambiguous and machine-auditable before API freeze.

## Package management

- `blm_apt_update`
- `blm_apt_install`
- `blm_apt_remove`

## Filesystem and system helpers

- `blm_checksum_sha256`
- `blm_ensure_owner`
- `blm_safe_copy`
- `blm_safe_move`
- `blm_temp_file`
- `blm_temp_dir`
- `blm_path_is_absolute`
- `blm_path_dirname`
- `blm_path_basename`
- `blm_path_join`
- `blm_lock_acquire`
- `blm_lock_release`

## Runtime, requirements and reliability

- `blm_has_command`
- `blm_require_command`
- `blm_require_file`
- `blm_require_dir`
- `blm_require_env`
- `blm_require_readable`
- `blm_require_writable`
- `blm_require_executable`
- `blm_retry`
- `blm_cleanup_add`
- `blm_rollback_add`

## Environment, config, state and logging

- `blm_env_get`
- `blm_env_bool`
- `blm_config_validate`
- `blm_config_get`
- `blm_config_has`
- `blm_state_get`
- `blm_state_set`
- `blm_state_delete`
- `blm_log`

## Git, systemd, Docker and network

- `blm_git_root`
- `blm_git_require_clean`
- `blm_systemd_is_active`
- `blm_systemd_wait_active`
- `blm_systemd_restart`
- `blm_systemd_reload`
- `blm_docker_compose_up`
- `blm_docker_compose_down`
- `blm_dns_resolves`
- `blm_http_check`
- `blm_wait_http`

## Terminal presentation and input

- `blm_title`
- `blm_section`
- `blm_panel`
- `blm_table`
- `blm_progress`
- `blm_prompt`
- `blm_confirm`
- `blm_select`
- `blm_display_width`
- `blm_ui_style`
- `blm_tui_move`

The CI public-API documentation contract also scans all other public functions already named in the canonical topic documentation. Adding a new public `blm_*` function therefore requires both an exact source marker and canonical EN/IT documentation coverage before merge.
