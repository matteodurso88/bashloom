# API runtime e affidabilità

Questo documento descrive le prime primitive operative di Bashloom introdotte per il runtime v0.1.

> Stato: pre-v0.1. Le API pubbliche possono ancora cambiare prima della prima release utilizzabile con tag.

## Esecuzione dei comandi

### `blm_run [--dry-run] [--] <command> [args...]`

Esegue un comando utilizzando il vettore originale degli argomenti Bash. Bashloom non costruisce e non valuta stringhe di comando.

Proprietà:

- preserva l'exit status del comando eseguito;
- resta utilizzabile quando il caller abilita `set -e`;
- supporta `--dry-run` locale e `BLM_DRY_RUN=1` globale;
- in dry-run stampa una rappresentazione shell-escaped e restituisce `0` senza eseguire il comando;
- le opzioni Bashloom sconosciute restituiscono `2`.

Usare `--` prima di comandi che potrebbero iniziare con `-`.

### `blm_step <label> <command> [args...]`

Mostra lo stato iniziale/finale attorno a `blm_run` e restituisce senza alterazioni l'exit status del comando eseguito.

## Retry e polling

### `blm_retry [--attempts N] [--delay S] [--backoff N] [--] <command> [args...]`

Default:

- tentativi: `3`;
- delay: `1` secondo;
- moltiplicatore di backoff: `1`.

Il comando viene riprovato finché ha successo o termina il budget di tentativi. Se tutti i tentativi falliscono, viene restituito lo status dell'ultimo comando.

I delay positivi usano l'utility standard `sleep`. Bashloom resta sourceable anche senza `sleep`; solo le funzioni che effettuano attese la richiedono realmente.

### `blm_wait_for [--timeout S] [--interval S] [--] <command> [args...]`

Esegue polling finché il comando restituisce `0`.

Default:

- timeout: `30` secondi;
- intervallo: `1` secondo.

Restituisce:

- `0` quando la condizione ha successo;
- `124` quando scade la deadline;
- `2` per argomenti Bashloom non validi;
- `127` se non può essere eseguita una utility necessaria all'attesa.

## Timeout dei comandi

### `blm_timeout [--timeout S] [--grace S] [--] <command> [args...]`

Esegue il comando in un processo figlio isolato. Alla deadline Bashloom invia `TERM`, attende il periodo di grace, quindi invia `KILL` se il processo è ancora attivo.

Default:

- timeout: `30` secondi;
- grace: `1` secondo.

Restituisce `124` in caso di timeout. Negli altri casi preserva lo status del comando figlio.

### Contratto di isolamento

Poiché un comando con timeout deve poter essere terminato indipendentemente, viene eseguito in una subshell. Una funzione shell passata a `blm_timeout` **non può quindi rendere persistenti nel caller modifiche a variabili o working directory**. Usare `blm_timeout` per lavoro osservabile esternamente, probe e comandi, non per funzioni il cui scopo è modificare lo stato shell del caller.

## Cleanup stack

### `blm_cleanup_add <command> [args...]`

Registra un'azione di cleanup. Comandi e argomenti vengono conservati come array Bash; non vengono usati `eval` né ricostruzione di stringhe comando.

### `blm_cleanup_run`

Esegue le azioni registrate in ordine **LIFO**. Tutte le azioni vengono tentate anche se una fallisce. Dopo aver processato lo stack viene restituito il primo status di cleanup non-zero.

### `blm_cleanup_clear`

Scarta le azioni di cleanup registrate senza eseguirle.

### `blm_cleanup_enable_traps`

Installa esplicitamente gli handler Bashloom per `EXIT`, `INT` e `TERM`.

La funzione è intenzionalmente conservativa: se una di queste trap esiste già, Bashloom rifiuta l'installazione invece di sovrascrivere il comportamento del caller.

Il semplice sourcing di Bashloom non installa mai trap automaticamente.

### `blm_cleanup_disable_traps`

Rimuove le trap precedentemente installate da Bashloom.

## Rollback e transazioni

### `blm_rollback_add <command> [args...]`

Registra un'azione esplicita di rollback.

### `blm_rollback_run`

Esegue le azioni di rollback in ordine **LIFO**, tenta tutte le azioni e restituisce il primo status di rollback non-zero.

### `blm_transaction_begin`

Avvia una singola transazione Bashloom e pulisce eventuale stato rollback precedente. Le transazioni annidate non sono supportate nel runtime v0.1.

### `blm_transaction_commit`

Conferma la transazione attiva scartandone lo stack di rollback.

### `blm_transaction_rollback`

Esegue lo stack di rollback attivo e termina la transazione.

## Comportamento con `set -e`

Il runtime cattura i fallimenti tramite contesti condizionali dei comandi invece di disabilitare temporaneamente `errexit`. Bashloom quindi non modifica le shell option del caller e può ispezionare gli status dei comandi falliti prima di restituirli.

Il caller mantiene il controllo del comportamento finale. Per esempio:

```bash
set -e
source ./src/bashloom.sh

blm_run deploy
```

Se `deploy` restituisce non-zero, `blm_run` restituisce lo stesso status e la policy `set -e` del caller può quindi terminare normalmente lo script.

Per gestire esplicitamente il fallimento:

```bash
if blm_run deploy; then
  blm_success "Deployment complete"
else
  status=$?
  blm_error "Deployment failed with exit $status"
fi
```
