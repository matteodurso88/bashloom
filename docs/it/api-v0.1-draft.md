# Specifica API v0.1 — Bozza

> Stato: **Bozza**. Queste API pubbliche sono implementate ma non sono ancora coperte da una garanzia stabile di compatibilità.

## Foundation e capability terminale

- `blm_has_command <name>`
- `blm_is_tty`
- `blm_color_enabled`
- `blm_info <message...>`
- `blm_success <message...>`
- `blm_warn <message...>`
- `blm_error <message...>`

## M1 — Command runtime

- `blm_run [--dry-run] [--] <command> [args...]`
- `blm_step <label> <command> [args...]`

`blm_run` preserva lo status del comando eseguito e supporta sia `--dry-run` locale sia `BLM_DRY_RUN=1` globale.

## M2 — Reliability

- `blm_retry [--attempts N] [--delay S] [--backoff N] [--] <command> [args...]`
- `blm_wait_for [--timeout S] [--interval S] [--] <command> [args...]`
- `blm_timeout [--timeout S] [--grace S] [--] <command> [args...]`
- `blm_cleanup_add <command> [args...]`
- `blm_cleanup_run`
- `blm_cleanup_clear`
- `blm_cleanup_enable_traps`
- `blm_cleanup_disable_traps`
- `blm_rollback_add <command> [args...]`
- `blm_rollback_run`
- `blm_rollback_clear`
- `blm_transaction_begin`
- `blm_transaction_commit`
- `blm_transaction_rollback`

Le operazioni con deadline usano status `124` allo scadere del timeout. Cleanup e rollback usano ordine LIFO.

## M3 — System safety

- `blm_require_command <name>`
- `blm_require_file <path>`
- `blm_require_dir <path>`
- `blm_require_env <name>`
- `blm_require_root`
- `blm_require_readable <path>`
- `blm_require_writable <path>`
- `blm_require_executable <path>`
- `blm_temp_file [directory]`
- `blm_temp_dir [directory]`
- `blm_ensure_dir [--mode MODE] <path>`
- `blm_ensure_symlink <target> <link>`
- `blm_atomic_write <path> <producer-command> [args...]`
- `blm_path_is_absolute <path>`
- `blm_path_dirname <path>`
- `blm_path_basename <path>`
- `blm_path_join <part>...`

## M4 — Runtime state

- `blm_output_mode`
- `blm_kv <key> <value>`
- `blm_log <debug|info|warn|error> <message...>`
- `blm_env_get <NAME> [fallback]`
- `blm_env_bool <NAME> [fallback]`
- `blm_config_validate <file>`
- `blm_config_get <file> <key> [fallback]`
- `blm_config_has <file> <key>`
- `blm_state_get <file> <key> [fallback]`
- `blm_state_set <file> <key> <value>`
- `blm_state_delete <file> <key>`

`BLM_OUTPUT_MODE` accetta `human`, `plain` o `json`. `BLM_LOG_LEVEL` controlla il filtro dei log e `BLM_LOG_FILE` permette opzionalmente di persistere i record accettati.

Configurazione e stato usano dati letterali `key=value`. Non vengono mai caricati tramite `source` o `eval`.

## M5 — Consumption

Facendo source direttamente di `src/bashloom-loader.sh` è disponibile:

- `blm_load <module> [module...]`

Gruppi supportati:

- `core`
- `status`
- `logging`
- `requirements`
- `runtime`
- `reliability`
- `system`
- `state`
- `git`
- `systemd`
- `docker`
- `network`
- `integrations`
- `all`

Il caricamento risolve le dipendenze ed è idempotente. Un modulo sconosciuto restituisce status `2`. I gruppi di integrazione caricano soltanto codice Bash: gli strumenti esterni restano dipendenze a call-time.

`src/bashloom.sh` resta l'interfaccia runtime completa e internamente carica `all`.

## M6A — Hardening Linux e idempotenza

- `blm_change_reset`
- `blm_last_changed`
- `blm_changed`
- `BLM_LAST_CHANGED`
- `BLM_CHANGED`
- `blm_ensure_mode <mode> <path>`
- `blm_ensure_line <path> <line>`

`blm_ensure_dir` e `blm_ensure_symlink` partecipano al change tracking. Questa milestone è Linux-first e l'ispezione mode usa `stat -c`.

## M6B — Modello output ed errori

- `blm_title <message...>`
- `blm_section <message...>`
- `blm_diagnostics`
- `blm_fail <status> <message...>`
- `blm_usage_error <message...>`

Gli helper rispettano human/plain/JSON. `blm_fail` e `blm_usage_error` non chiamano mai `exit`.

## M6C — Primitive system avanzate

Filesystem e integrità:

- `blm_backup <source> <backup>`
- `blm_safe_copy <source> <destination>`
- `blm_safe_move <source> <destination>`
- `blm_checksum_sha256 <file>`
- `blm_ensure_owner <user:group> <path>`

Locking:

- `blm_lock_acquire <lock-path>`
- `blm_lock_release <lock-path>`
- `blm_with_lock <lock-path> <command> [args...]`

XDG:

- `blm_xdg_config_home`
- `blm_xdg_data_home`
- `blm_xdg_cache_home`
- `blm_xdg_state_home`
- `blm_xdg_runtime_dir`

Gli helper safe copy/move/backup non sovrascrivono destinazioni esistenti. I lock usano `mkdir` atomico e non tentano recupero automatico degli stale lock. `XDG_RUNTIME_DIR` non riceve fallback inventati.

## M6D — Integrazioni

Git:

- `blm_git_root [path]`
- `blm_git_current_branch [path]`
- `blm_git_is_clean [path]`
- `blm_git_require_clean [path]`

systemd:

- `blm_systemd_is_active <unit>`
- `blm_systemd_wait_active [--timeout S] [--interval S] <unit>`
- `blm_systemd_restart <unit>`
- `blm_systemd_reload <unit>`

Docker Compose:

- `blm_docker_available`
- `blm_docker_compose_available`
- `blm_docker_compose <compose-args...>`
- `blm_docker_compose_up [service...]`
- `blm_docker_compose_down [compose-down-args...]`

Readiness di rete:

- `blm_dns_resolves <host>`
- `blm_http_check <url>`
- `blm_wait_http [--timeout S] [--interval S] <url>`

Gli adapter sono volutamente sottili: non aggiungono `sudo`, non ricostruiscono argv tramite `eval` e richiedono Git/systemctl/Docker/getent/curl soltanto quando viene invocata la relativa API. Gli helper di attesa riusano `blm_wait_for`, incluso status timeout `124`.

## Contratto documentazione in-source

Ogni funzione pubblica `blm_*` deve avere un docblock adiacente con marker machine-checkable `# Public API: blm_name`. La documentazione nel sorgente descrive scopo, uso, semantica status/output, side effect, dipendenze e vincoli/invarianti rilevanti. La CI applica il contratto tramite `tools/check-source-docs.sh`.

## Contratti dettagliati

Vedi:

- `docs/it/runtime-reliability.md`
- `docs/it/system-safety.md`
- `docs/it/runtime-state.md`
- `docs/it/consumption.md`
- `docs/it/compatibility.md`
- `docs/it/idempotency.md`
- `docs/it/output-error-model.md`
- `docs/it/advanced-system.md`
- `docs/it/integrations.md`
- `docs/it/source-documentation.md`
- `examples/README.md`

## Semantica degli exit code

Salvo quando una funzione trasforma esplicitamente un risultato, i wrapper Bashloom preservano o riportano fedelmente lo status dell'operazione. Lo status `2` indica in genere argomenti/config non validi; i timeout usano `124` dove documentato.

## Effetti collaterali

Il sourcing di `src/bashloom.sh` o `src/bashloom-loader.sh` non deve abilitare strict mode, sostituire trap, modificare `IFS`, produrre output, leggere config/stato, creare log, eseguire testo del caller o richiedere utility feature-specific.

Le utility esterne specifiche di una feature vengono richieste soltanto quando quella funzione viene invocata; il sourcing resta privo di dipendenze obbligatorie oltre a Bash.
