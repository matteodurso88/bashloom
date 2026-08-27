# Idempotenza e change tracking

Bashloom fornisce un change tracking esplicito per automazioni orientate alla convergenza. L'obiettivo è permettere a uno script di rispondere a due domande distinte:

1. l'ultima operazione tracciata ha modificato il sistema?
2. almeno una delle operazioni tracciate ha modificato il sistema durante questo run?

## Stato delle modifiche

Due variabili pubbliche espongono questo stato:

- `BLM_LAST_CHANGED` — vale `1` quando l'ultima operazione tracciata ha prodotto una modifica, altrimenti `0`;
- `BLM_CHANGED` — flag aggregato che resta a `1` dopo qualsiasi modifica tracciata finché non viene azzerato esplicitamente.

Uso:

```bash
blm_change_reset

blm_ensure_dir --mode 700 /var/lib/myapp
if blm_last_changed; then
  printf 'directory modificata\n'
fi

blm_ensure_line /etc/myapp.conf 'enabled=true'

if blm_changed; then
  printf 'il run ha modificato il sistema\n'
fi
```

`blm_change_reset` azzera entrambi i flag a `0`.

`blm_last_changed` e `blm_changed` restituiscono successo shell quando il relativo flag è impostato.

## Primitive filesystem idempotenti

### `blm_ensure_dir [--mode MODE] <path>`

Crea l'albero di directory quando manca. Se viene fornito `--mode`, il mode esistente viene verificato e corretto solo quando necessario.

Semantica delle modifiche:

- directory mancante creata: changed;
- directory esistente già corretta: nessuna modifica;
- mode della directory corretto: changed.

L'ispezione del mode usa attualmente `stat -c`, quindi questa parte è Linux-first.

### `blm_ensure_symlink <target> <link>`

Crea il symlink quando manca e segnala nessuna modifica quando è già presente esattamente lo stesso target. Un symlink conflittuale o un path esistente non symlink viene rifiutato invece di essere sostituito silenziosamente.

### `blm_ensure_mode <mode> <path>`

Garantisce che un oggetto filesystem abbia il mode richiesto. `chmod` viene eseguito solo quando il mode corrente è diverso.

### `blm_ensure_line <path> <line>`

Garantisce che una riga letterale esatta sia presente in un file regolare.

- file mancante: viene creato con la riga richiesta;
- file esistente senza la riga esatta: la riga viene aggiunta;
- riga esatta già presente: nessuna modifica;
- la directory parent deve già esistere;
- eventuali espressioni shell presenti nella riga sono trattate come dati letterali.

Questo helper usa intenzionalmente un confronto sull'intera riga. Non è un editor a espressioni regolari né un motore di sostituzione key/value.

## Pattern di convergenza aggregata

Un pattern tipico è:

```bash
blm_change_reset

blm_ensure_dir --mode 700 "$app_dir"
blm_ensure_line "$config" 'enabled=true'
blm_ensure_mode 600 "$config"
blm_ensure_symlink "$config" "$current_link"

if blm_changed; then
  blm_info "configurazione convergente con modifiche"
else
  blm_info "sistema già nello stato desiderato"
fi
```

Lo stesso blocco può essere eseguito ripetutamente. Una volta raggiunto lo stato desiderato, il run successivo deve diventare un no-op.

## Scope e portabilità

Questa milestone è Linux-first. Le matrici cross-distribution, macOS e WSL sono volutamente rimandate finché quegli ambienti non potranno essere validati direttamente.

L'implementazione corrente rafforza inoltre le primitive filesystem esistenti verificando esplicitamente `readlink` e `rm` quando servono, invece di presupporne la disponibilità.
