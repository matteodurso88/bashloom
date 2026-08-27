# Primitive system avanzate

Bashloom M6C aggiunge helper Linux-first per modifiche filesystem più sicure, locking, convergenza ownership, checksum e path XDG.

## Operazioni filesystem sicure

```bash
blm_backup <source> <backup>
blm_safe_copy <source> <destination>
blm_safe_move <source> <destination>
```

Questi helper rifiutano di sovrascrivere una destinazione già esistente. Preservano i metadata supportati da `cp -a` e partecipano al change tracking di Bashloom dopo una modifica completata con successo.

`blm_backup` è volutamente esplicito: il caller sceglie il path di backup. Bashloom non genera timestamp né ruota backup implicitamente.

## SHA-256

```bash
blm_checksum_sha256 <file>
```

L'helper stampa soltanto il digest esadecimale. `sha256sum` viene richiesto solo quando la funzione viene invocata.

## Lock su directory

```bash
blm_lock_acquire <lock-path>
blm_lock_release <lock-path>
blm_with_lock <lock-path> <command> [args...]
```

I lock sono rappresentati da directory e acquisiti tramite `mkdir` atomico. Questo mantiene la primitiva con poche dipendenze e rende lo stato del lock visibile sul filesystem.

L'acquisizione è non bloccante: un lock già esistente restituisce status `1`. `blm_with_lock` preserva lo status del comando eseguito e poi tenta di rilasciare il lock.

Queste primitive non costituiscono un sistema di lease e non recuperano automaticamente lock obsoleti dopo crash o spegnimenti. La policy per gli stale lock resta responsabilità del caller.

## Convergenza ownership

```bash
blm_ensure_owner <user:group> <path>
```

L'helper confronta owner e group correnti tramite `stat -c` GNU/Linux. Invoca `chown` solo quando l'ownership richiesta differisce e partecipa al change tracking.

Non esiste escalation implicita dei privilegi. Se la modifica dell'ownership richiede privilegi elevati, il caller deve essere già eseguito con permessi sufficienti.

## Path XDG

```bash
blm_xdg_config_home
blm_xdg_data_home
blm_xdg_cache_home
blm_xdg_state_home
blm_xdg_runtime_dir
```

I primi quattro helper rispettano la relativa variabile XDG e altrimenti usano i default standard basati su HOME:

- config: `$HOME/.config`
- data: `$HOME/.local/share`
- cache: `$HOME/.cache`
- state: `$HOME/.local/state`

`blm_xdg_runtime_dir` richiede esplicitamente `XDG_RUNTIME_DIR`. Bashloom non inventa un fallback perché ridurrebbe le garanzie di ownership e ciclo di vita previste per le directory runtime.

## Scope

Questa milestone è Linux-first. La validazione cross-distribution, macOS e WSL resta rimandata finché quegli ambienti non potranno essere testati direttamente.
