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

I gruppi supportati includono `core`, `status`, `terminal`, `logging`, `requirements`, `runtime`, `reliability`, `system`, `state`, `git`, `systemd`, `docker`, `network`, `integrations` e `all`. I nomi sconosciuti restituiscono status `2`.

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

Un'installazione esistente non viene mai sostituita senza `--force`. Bashloom non invoca mai `sudo`: l'elevazione dei privilegi resta una policy dell'applicazione o dell'operatore.

## Vendoring pinned

Per applicazioni che portano Bashloom nel proprio repository, il vendoring pinned è il modello raccomandato prima della v1.0.

Da un checkout/tag/commit Bashloom approvato:

```bash
bash tools/vendor.sh \
  --destination /percorso/consumer/vendor/bashloom \
  --pin b6a096ba1feb31f41a639856b29ae07e25ba3676
```

Se `--pin` viene omesso, il tool risolve il `HEAD` Git corrente di Bashloom. Se i metadata Git non sono disponibili, il caller deve fornire `--pin` esplicitamente.

Il bundle risultante è:

```text
vendor/bashloom/
├── PIN
├── LICENSE
├── SHA256SUMS
└── src/
    ├── bashloom.sh
    ├── bashloom-loader.sh
    └── ...
```

Il consumer fa source dal tree `src/` vendorizzato:

```bash
source "$PROJECT_ROOT/vendor/bashloom/src/bashloom.sh"
```

oppure:

```bash
source "$PROJECT_ROOT/vendor/bashloom/src/bashloom-loader.sh"
blm_load runtime reliability
```

Il bundle vendor deve restare byte-identico al materiale upstream approvato. Le personalizzazioni specifiche del consumer devono vivere fuori da `vendor/bashloom/src/`.

### Verifica di integrità

La CI del consumer può verificare il bundle senza accesso di rete:

```bash
bash /percorso/bashloom/tools/vendor-verify.sh \
  "$PROJECT_ROOT/vendor/bashloom"
```

Il verifier richiede un `PIN` non vuoto, controlla la struttura attesa e valida `LICENSE` più ogni file sotto `src/` contro `SHA256SUMS`. Un file runtime modificato o mancante fa fallire la verifica.

Il lifecycle previsto è:

```text
commit/tag upstream approvato
→ aggiornamento vendor esplicito
→ PIN + SHA256SUMS committati nel consumer
→ verifica integrità in CI consumer
→ deploy usa solo la copia vendorizzata locale
```

Non esiste tracking automatico di upstream `main`, non esistono clone/download runtime durante deploy e non esiste repin automatico. Il rollback è un normale revert del consumer oppure un repin esplicito a una versione Bashloom precedentemente approvata.

Una destinazione vendor già esistente non viene sostituita senza `--force`.

## Workflow di release

I tag di release Bashloom usano la convenzione `vMAJOR.MINOR.PATCH`. Prima della pubblicazione, `tools/release-check.sh` verifica che la versione richiesta corrisponda esattamente a `BLM_VERSION` in `src/core/version.sh`.

Un tag `v*` rilancia sintassi, ShellCheck, shfmt, Bats, esempi mantenuti e gate metadata release prima di pubblicare archivio e checksum SHA-256.

Il tag `v0.1.0` non deve essere creato finché la milestone di validazione in produzione non è completata.

## Policy di versioning prima della v1.0

Bashloom segue il Semantic Versioning per le release pubbliche, ma prima della 1.0 le API possono ancora cambiare sulla base dell'esperienza raccolta nei deployment reali.

`BLM_VERSION` è metadata diagnostico pubblico. Prima della v1.0 i consumer dovrebbero fissare una release nota o un commit vendorizzato invece di dedurre la compatibilità API analizzando la stringa di versione.
