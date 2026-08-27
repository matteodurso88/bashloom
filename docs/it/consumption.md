# Modello di utilizzo

Durante la fase pre-v0.1 Bashloom può essere utilizzato in tre modi supportati:

1. fare source del runtime completo da un checkout o da una copia vendorizzata;
2. fare source del loader selettivo e richiedere solo i gruppi di moduli necessari;
3. installare il runtime sotto un prefix esplicito e fare source da quella posizione.

Nessun flusso supportato scarica ed esegue implicitamente codice shell remoto e nessun installer tenta escalation dei privilegi.

## Runtime completo

Il modello più semplice è:

```bash
source /percorso/bashloom/src/bashloom.sh
```

Questo carica tutte le primitive pubbliche attualmente distribuite da Bashloom.

## Caricamento selettivo dei moduli

I consumer che vogliono una superficie runtime più ridotta possono fare source del loader:

```bash
source /percorso/bashloom/src/bashloom-loader.sh
blm_load runtime system
```

`blm_load` è idempotente e risolve automaticamente le dipendenze dichiarate.

Gruppi di moduli supportati:

| Modulo | Scopo |
| --- | --- |
| `core` | versione, capability, validazione, output e helper environment |
| `status` | core più rendering degli status |
| `logging` | status più logging |
| `requirements` | status più controlli requisiti |
| `runtime` | requirements più esecuzione comandi e step |
| `reliability` | runtime più retry, wait, timeout, cleanup e rollback |
| `system` | requirements più helper path, risorse temporanee e filesystem |
| `state` | system più configurazione sicura e stato persistente |
| `all` | runtime pubblico completo |

I nomi modulo sconosciuti restituiscono status `2`.

## Installazione sotto prefix

Da un repository Bashloom già clonato:

```bash
bash tools/install.sh
```

La destinazione predefinita è:

```text
$HOME/.local/lib/bashloom
```

Quindi:

```bash
source "$HOME/.local/lib/bashloom/bashloom.sh"
```

È possibile selezionare esplicitamente un altro prefix:

```bash
bash tools/install.sh --prefix /opt/example
```

Un'installazione esistente non viene mai sostituita senza `--force`.

Per un'installazione di sistema, l'elevazione dei privilegi resta deliberatamente esterna a Bashloom:

```bash
sudo bash tools/install.sh --prefix /usr/local
```

Bashloom non invoca mai `sudo` autonomamente.

## Vendoring

Per applicazioni che devono portare nel proprio repository una copia Bashloom fissata:

```bash
bash /percorso/bashloom/tools/vendor.sh \
  --destination vendor/bashloom
```

Il progetto risultante può usare:

```bash
source "$PROJECT_ROOT/vendor/bashloom/bashloom.sh"
```

oppure il caricamento selettivo:

```bash
source "$PROJECT_ROOT/vendor/bashloom/bashloom-loader.sh"
blm_load runtime reliability
```

Il vendoring copia l'intero runtime `src/`, in modo che la risoluzione delle dipendenze resti autosufficiente. Una copia già presente richiede `--force` per essere sostituita.

## Workflow di release

I tag di release Bashloom usano la convenzione `vMAJOR.MINOR.PATCH`.

Prima della pubblicazione di una release taggata, `tools/release-check.sh` verifica che la versione richiesta corrisponda esattamente a `BLM_VERSION` in `src/core/version.sh`.

Un tag `v*` attiva il workflow di release, che esegue:

- controllo sintassi Bash;
- ShellCheck;
- verifica shfmt;
- test Bats;
- full feature tour mantenuto;
- validazione metadata release;
- creazione archivio e checksum SHA-256;
- pubblicazione della GitHub Release.

L'archivio di release contiene `src/`, `examples/`, `docs/`, `README.md`, `LICENSE` e `CHANGELOG.md`.

Il tag `v0.1.0` non deve essere creato finché la milestone di validazione in produzione non è completata.

## Policy di versioning prima della v1.0

Bashloom segue il Semantic Versioning per le release pubbliche, ma prima della 1.0 le API possono ancora cambiare sulla base dell'esperienza raccolta nei deployment reali.

`BLM_VERSION` è metadata diagnostico pubblico. Prima della v1.0 i consumer dovrebbero fissare una release nota o un commit vendorizzato invece di dedurre la compatibilità API analizzando la stringa di versione.
