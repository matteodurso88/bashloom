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

Facendo source direttamente di `src/bashloom-loader.sh` è disponibile la seguente API pubblica del loader:

- `blm_load <module> [module...]`

Gruppi di moduli supportati:

- `core`
- `status`
- `logging`
- `requirements`
- `runtime`
- `reliability`
- `system`
- `state`
- `all`

Il caricamento dei moduli risolve le dipendenze ed è idempotente. Un nome modulo sconosciuto restituisce status `2`.

Il normale entrypoint `src/bashloom.sh` resta l'interfaccia per il runtime completo e internamente carica `all`.

I comandi di installazione, vendoring e release sotto `tools/` sono tooling di progetto e non API runtime pubbliche da importare tramite source.

## M6A — Hardening Linux e idempotenza

Change tracking:

- `blm_change_reset`
- `blm_last_changed`
- `blm_changed`
- `BLM_LAST_CHANGED`
- `BLM_CHANGED`

Primitive filesystem idempotenti aggiuntive:

- `blm_ensure_mode <mode> <path>`
- `blm_ensure_line <path> <line>`

`blm_ensure_dir` e `blm_ensure_symlink` partecipano al change tracking. Le operazioni tracciate impostano `BLM_LAST_CHANGED=1` solo quando modificano realmente il sistema. `BLM_CHANGED` è uno stato aggregato e resta impostato finché non viene chiamato `blm_change_reset`.

Questa milestone è Linux-first. L'ispezione dei mode usa attualmente la semantica `stat -c` compatibile GNU/Linux.

## M6B — Modello output ed errori

Presentazione e diagnostica:

- `blm_title <messaggio...>`
- `blm_section <messaggio...>`
- `blm_diagnostics`

Segnalazione esplicita dei failure:

- `blm_fail <status> <messaggio...>`
- `blm_usage_error <messaggio...>`

`blm_title` e `blm_section` rispettano `BLM_OUTPUT_MODE` e producono record deterministici human/plain/JSON. `blm_diagnostics` espone versione Bashloom, versione Bash, modalità output, capability TTY/colore e stato CI tramite il contratto key/value esistente.

`blm_fail` restituisce uno status esplicito da 1 a 255 dopo aver renderizzato l'errore. `blm_usage_error` restituisce status `2`. Nessuno dei due helper chiama `exit`; il caller resta responsabile di terminazione del processo, rollback o recovery.

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

Path XDG:

- `blm_xdg_config_home`
- `blm_xdg_data_home`
- `blm_xdg_cache_home`
- `blm_xdg_state_home`
- `blm_xdg_runtime_dir`

Gli helper safe copy/move/backup rifiutano di sovrascrivere destinazioni esistenti. `blm_backup`, `blm_safe_copy`, `blm_safe_move` e `blm_ensure_owner` partecipano al change tracking quando eseguono una modifica con successo.

I lock usano acquisizione atomica tramite `mkdir` e sono non bloccanti. `blm_with_lock` preserva lo status del comando eseguito e tenta il rilascio del lock prima di restituire. Il recupero di stale lock resta una policy del caller.

Gli helper XDG rispettano le variabili environment esplicite e usano i default standard basati su HOME dove definiti. `blm_xdg_runtime_dir` richiede `XDG_RUNTIME_DIR` e non inventa fallback.

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
- `examples/README.md`

## Semantica degli exit code

Salvo quando una funzione trasforma esplicitamente un risultato, i wrapper Bashloom preservano o riportano fedelmente lo status dell'operazione eseguita. Il rendering non deve sostituire accidentalmente un errore del comando.

Lo status `2` viene generalmente usato per argomenti Bashloom o valori di configurazione non validi. Le operazioni di timeout usano `124` dove documentato.

## Effetti collaterali

Il sourcing di `src/bashloom.sh` o `src/bashloom-loader.sh` non deve abilitare implicitamente lo strict mode, sostituire trap del caller, modificare `IFS`, produrre output visibile, leggere configurazione/stato, creare file di log o eseguire testo fornito dal caller.

Le utility esterne specifiche di una feature possono essere richieste soltanto quando quella funzione viene invocata; il sourcing del runtime o del loader resta senza dipendenze obbligatorie oltre a Bash.
