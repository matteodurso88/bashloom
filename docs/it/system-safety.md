# API di sicurezza di sistema

Questo documento descrive le primitive Bashloom M3 per filesystem e permessi.

> Stato: pre-v0.1. Le API pubbliche possono ancora cambiare prima della prima release utilizzabile con tag.

## Requisiti

### `blm_require_root`
Restituisce successo solo quando `EUID == 0`.

### `blm_require_readable <path>`
Richiede che il processo corrente abbia accesso in lettura.

### `blm_require_writable <path>`
Richiede che il processo corrente abbia accesso in scrittura.

### `blm_require_executable <path>`
Richiede che il processo corrente abbia accesso di esecuzione/attraversamento.

Questi helper riportano l'accesso runtime tramite i file test di Bash. Non tentano escalation di privilegi.

## Risorse temporanee

### `blm_temp_file [directory]`
Crea un file temporaneo univoco tramite `mktemp` con `umask 077` effettivo. La directory base predefinita è `${TMPDIR:-/tmp}`.

### `blm_temp_dir [directory]`
Crea una directory temporanea univoca tramite `mktemp -d` con `umask 077` effettivo.

`mktemp` è richiesto solo quando queste funzioni vengono invocate; il sourcing di Bashloom non lo richiede.

## Helper filesystem idempotenti

### `blm_ensure_dir [--mode MODE] <path>`
Crea un albero di directory con `mkdir -p`. Ripetere la chiamata è sicuro. Quando viene fornito `--mode`, viene applicato `chmod` dopo la creazione.

### `blm_ensure_symlink <target> <link>`
Crea un link simbolico quando assente. Se un symlink esistente punta già al target richiesto, la chiamata termina con successo senza modifiche. Un symlink conflittuale o un path non-symlink viene rifiutato invece di essere sovrascritto.

## Scritture atomiche

### `blm_atomic_write <path> <producer-command> [args...]`
Esegue il comando producer redirigendo stdout verso un file temporaneo sicuro nella directory di destinazione. La destinazione viene sostituita con `mv` solo dopo il successo del producer.

Proprietà:
- la destinazione resta invariata se il producer fallisce;
- il file temporaneo viene creato nella stessa directory, consentendo semantica di rename atomico sullo stesso filesystem;
- quando sostituisce un file esistente su GNU/Linux, ne copia i permessi tramite `chmod --reference`;
- non viene valutata alcuna command string.

Questa implementazione iniziale è Linux-first. Il comportamento di preservazione permessi con `--reference` verrà rivisto durante l'hardening di compatibilità macOS.

## Helper path

### `blm_path_is_absolute <path>`
Restituisce successo per path che iniziano con `/`.

### `blm_path_dirname <path>`
Restituisce la componente directory in modo lessicale usando solo Bash.

### `blm_path_basename <path>`
Restituisce la componente finale in modo lessicale usando solo Bash.

### `blm_path_join <part>...`
Unisce componenti di path senza invocare utility esterne.

Questi helper sono esclusivamente lessicali: non risolvono symlink, `..` o canonicalizzazione del filesystem.

## Miglioramento source-safe

L'entrypoint Bashloom ora risolve la propria directory senza chiamare `dirname` esterno. Il runtime può quindi essere importato anche con `PATH` vuoto/non utilizzabile, purché Bash possa accedere ai file sorgente.
