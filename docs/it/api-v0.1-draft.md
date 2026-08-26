# Specifica API v0.1 — Bozza

> Stato: **Bozza**. Le funzioni elencate non sono ancora coperte da una garanzia stabile di compatibilità.

## API foundation attualmente presente

### `blm_has_command <name>`

Restituisce successo quando `<name>` viene risolto tramite `PATH`.

### `blm_is_tty`

Restituisce successo quando lo standard output è collegato a un terminale.

### `blm_color_enabled`

Restituisce successo quando Bashloom considera appropriato l'uso del colore ANSI. Le condizioni attuali disabilitano il colore quando `NO_COLOR` è non vuoto, `TERM=dumb` oppure stdout non è un TTY.

### `blm_info <message...>`

Stampa una riga informativa su stdout.

### `blm_success <message...>`

Stampa una riga di successo su stdout.

### `blm_warn <message...>`

Stampa un warning su stderr.

### `blm_error <message...>`

Stampa un errore su stderr.

### `blm_require_command <name>`

Restituisce fallimento e scrive una diagnostica su stderr quando un comando non può essere risolto tramite `PATH`.

### `blm_require_file <path>`

Restituisce fallimento quando `<path>` non è un file regolare.

### `blm_require_dir <path>`

Restituisce fallimento quando `<path>` non è una directory.

### `blm_require_env <name>`

Restituisce fallimento quando la variabile d'ambiente indicata non è impostata o è vuota.

## Candidate v0.1 non ancora implementate

Le seguenti sono capability pianificate e non contratti API attuali:

- `blm_run`
- `blm_step`
- `blm_retry`
- `blm_wait_until`
- primitive cleanup stack
- output title/section
- output key/value
- helper sicuri per risorse temporanee
- helper di scrittura atomica
- controllo permessi

Ogni candidata richiede specifica del comportamento, test e documentazione EN/IT prima di essere considerata parte dell'API pubblica v0.1.

## Semantica degli exit code

Salvo quando lo scopo di una funzione è esplicitamente trasformare un risultato, i wrapper Bashloom devono preservare o riportare fedelmente l'exit status dell'operazione avvolta. Il rendering di output successivo a un comando non deve sostituire accidentalmente lo status del comando.

## Effetti collaterali

Il sourcing di `src/bashloom.sh` non deve abilitare implicitamente lo strict mode, sostituire trap, modificare `IFS`, eseguire comandi esterni diversi dalle primitive necessarie a risolvere il path dei sorgenti Bashloom, né produrre output visibile all'utente.
