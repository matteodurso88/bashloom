# Integrazione APT

Bashloom fornisce un modulo opzionale per la gestione pacchetti delle distribuzioni Debian-family, pensato per script operativi e workflow di provisioning.

Il modulo è **source-safe su ogni piattaforma**. Caricare `apt` o `integrations` non esegue APT, non ispeziona lo stato dei pacchetti e non richiede un host Debian. La disponibilità viene verificata soltanto quando viene chiamata un'API pubblica APT.

## API pubblica

```bash
blm_apt_available
blm_apt_is_installed <package>
blm_apt_installed_version <package>
blm_apt_candidate_version <package>
blm_apt_update
blm_apt_install <package> [package...]
blm_apt_remove <package> [package...]
```

Caricamento selettivo:

```bash
source /percorso/bashloom/src/bashloom-loader.sh
blm_load apt
```

Anche i gruppi completi `integrations` e `all` includono APT.

## Policy dei comandi

Bashloom usa deliberatamente:

- `apt-get` per update/install/remove;
- `dpkg-query` per query su stato/versione installata;
- `apt-cache` per la candidate version.

Il frontend interattivo `apt` non viene usato per le mutazioni scriptate.

`blm_apt_available` richiede tutti e tre i comandi supportati. Su un sistema non Debian restituisce normalmente `1`; il source di Bashloom continua comunque a riuscire.

## Privilegi

Bashloom non invoca mai `sudo` e non tenta escalation dei privilegi.

Il confine dei privilegi viene deciso dal caller. Per esempio, uno script di provisioning di sistema può essere eseguito direttamente come root oppure usare un meccanismo di elevazione esterno e controllato dall'operatore prima di chiamare Bashloom.

## Operandi package

Gli operandi install/remove vengono validati prima dell'esecuzione. Operandi vuoti, nomi simili a option e injection tramite newline/carriage return vengono rifiutati con status `2`.

Sono accettati normali package name, nomi qualificati per architettura e versioni esplicite, per esempio:

```text
curl
libssl3:amd64
package-name=1.2.3-1
```

Gli operandi vengono inoltrati come argv dopo `--`; Bashloom non usa `eval` e non riparsa sintassi shell.

## Dry-run

Gli helper APT mutanti passano attraverso `blm_run`, quindi si applica il normale contratto dry-run di Bashloom:

```bash
BLM_DRY_RUN=1 blm_apt_install curl ca-certificates
```

Il comando viene mostrato ma `apt-get` non viene eseguito.

Il dry-run non bypassa il controllo capability: la toolchain APT deve comunque essere disponibile. Questo consente di intercettare errori di piattaforma/configurazione prima di un provisioning reale.

## Semantica query

`blm_apt_is_installed` è un predicate: `0` significa installato, `1` assente/non disponibile.

`blm_apt_installed_version` stampa la versione installata e preserva lo status di `dpkg-query`.

`blm_apt_candidate_version` analizza la candidate corrente da `apt-cache policy` senza aggiornare implicitamente gli indici. Se non esiste una candidate restituisce `1`.

## Riproducibilità

Bashloom non esegue silenziosamente `apt-get update` prima di install/remove. L'aggiornamento degli indici è un'operazione esplicita:

```bash
blm_apt_update
blm_apt_install curl
```

Questo mantiene visibile al caller l'ordine del provisioning ed evita mutazioni di sistema/rete nascoste.
