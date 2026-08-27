# Integrazioni

Le integrazioni Bashloom sono adapter sottili attorno a strumenti di sistema esterni. Aggiungono gestione prevedibile degli argomenti, controllo delle dipendenze e semantica degli status coerente con Bashloom senza nascondere lo strumento sottostante o inventare policy operative.

## Regole di design

- le dipendenze vengono verificate soltanto quando viene chiamata la relativa funzione di integrazione;
- il sourcing di Bashloom resta privo di requisiti obbligatori relativi a Git, systemd, Docker, curl o getent;
- nessun adapter esegue `sudo` o escalation di privilegi implicita;
- gli argomenti vengono inoltrati come argv, mai ricostruiti tramite `eval`;
- status e diagnostica nativi vengono preservati salvo quando l'API Bashloom definisce esplicitamente una trasformazione, come il timeout `124`;
- la policy distruttiva rimane esplicita a livello applicativo.

## Git

```bash
blm_git_root [path]
blm_git_current_branch [path]
blm_git_is_clean [path]
blm_git_require_clean [path]
```

`blm_git_is_clean` considera dirty anche i file non tracciati. `blm_git_current_branch` restituisce non-zero in detached HEAD, stato del tutto normale in molti checkout CI.

## systemd

```bash
blm_systemd_is_active <unit>
blm_systemd_wait_active [--timeout S] [--interval S] <unit>
blm_systemd_restart <unit>
blm_systemd_reload <unit>
```

Gli helper invocano `systemctl` con l'utente corrente. Bashloom non aggiunge mai `sudo`. L'attesa delega a `blm_wait_for`, quindi la scadenza della deadline restituisce status `124`.

## Docker Compose

```bash
blm_docker_available
blm_docker_compose_available
blm_docker_compose <compose-args...>
blm_docker_compose_up [service...]
blm_docker_compose_down [compose-down-args...]
```

L'adapter usa il moderno plugin `docker compose` e deliberatamente non passa in modo silenzioso al vecchio `docker-compose`. `blm_docker_compose` è l'interfaccia generale argv-safe; `up` e `down` sono wrapper di comodità.

## Readiness di rete

```bash
blm_dns_resolves <host>
blm_http_check <url>
blm_wait_http [--timeout S] [--interval S] <url>
```

La risoluzione DNS usa `getent` e segue quindi la configurazione NSS del sistema. La readiness HTTP usa `curl --fail` e segue i redirect; HTTP 4xx/5xx ed errori di trasporto/TLS sono failure. Autenticazione, header o predicati applicativi più specifici devono usare curl esplicitamente tramite `blm_run`, invece di trasformare questa primitiva in un client HTTP nascosto.

## Caricamento selettivo

Il loader espone i singoli gruppi di integrazione:

```bash
source /path/to/bashloom-loader.sh
blm_load git
blm_load systemd
blm_load docker
blm_load network
```

oppure il gruppo aggregato:

```bash
blm_load integrations
```

`blm_load all` include tutte le integrazioni attualmente distribuite.

## Documentazione nel sorgente

M6D introduce anche il contratto di documentazione in-source a livello repository. Le API pubbliche vengono documentate accanto all'implementazione con marker machine-checkable `# Public API: blm_name` e prosa più profonda su status, output, side effect, dipendenze e invarianti non ovvie. La CI rifiuta funzioni pubbliche prive di documentazione.
