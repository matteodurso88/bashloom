# Contratto consumer Bashloom

Questo documento definisce il modello di integrazione consigliato per i progetti che utilizzano Bashloom in locale, in CI e nei workflow di deployment.

Gli obiettivi sono riproducibilità, pin esplicito della versione, utilizzo runtime offline, verifica di integrità e un unico pattern coerente tra repository diversi.

## Struttura repository consigliata

```text
my-project/
├── vendor/
│   └── bashloom/
│       ├── PIN
│       ├── LICENSE
│       ├── SHA256SUMS
│       └── src/
│           ├── bashloom.sh
│           ├── bashloom-loader.sh
│           ├── core/
│           ├── ops/
│           ├── system/
│           ├── integrations/
│           └── ui/
├── scripts/
│   ├── lib/
│   │   └── bashloom.sh
│   ├── ci/
│   │   ├── verify-bashloom-vendor.sh
│   │   └── validate.sh
│   └── ...
└── .github/
    └── workflows/
```

Il runtime Bashloom viene conservato dentro il repository consumer. Deployment e CI non devono dipendere da clone di Bashloom o download di codice shell al momento dell'esecuzione.

## 1. Vendorizzare una copia Bashloom pinnata

Eseguire il tool di vendoring da un checkout Bashloom fidato:

```bash
bash /percorso/bashloom/tools/vendor.sh \
  --destination vendor/bashloom \
  --pin <COMMIT_O_TAG>
```

L'aggiornamento di una copia esistente è sempre esplicito:

```bash
bash /percorso/bashloom/tools/vendor.sh \
  --destination vendor/bashloom \
  --pin <NUOVO_COMMIT_O_TAG> \
  --force
```

Il bundle risultante contiene:

```text
vendor/bashloom/
├── PIN
├── LICENSE
├── SHA256SUMS
└── src/
```

Il consumer non deve modificare localmente `vendor/bashloom/src/`. I difetti generici appartengono al progetto Bashloom upstream.

## 2. Verificare l'integrità del vendor

Il verifier ufficiale può controllare offline l'albero vendorizzato:

```bash
bash /percorso/bashloom/tools/vendor-verify.sh vendor/bashloom
```

Un consumer può incapsulare questo controllo in uno script CI locale. Ad esempio:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
exec bash "$ROOT_DIR/tools/bashloom-vendor-verify.sh" "$ROOT_DIR/vendor/bashloom"
```

I progetti che non copiano il verifier possono eseguire in CI un controllo SHA-256 equivalente basato su `vendor/bashloom/SHA256SUMS`.

Il contratto importante è poter dimostrare che il runtime vendorizzato non è stato modificato prima dell'uso.

## 3. Usare un solo adapter di progetto

Non fare source di Bashloom in modo indipendente da ogni script. È preferibile un unico adapter locale al repository, per esempio:

```text
scripts/lib/bashloom.sh
```

Esempio:

```bash
#!/usr/bin/env bash

PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)"
BASHLOOM_ROOT="$PROJECT_ROOT/vendor/bashloom"

project_bashloom_init() {
  local loader="$BASHLOOM_ROOT/src/bashloom-loader.sh"

  if [[ ! -f $loader ]]; then
    printf 'ERROR: Bashloom loader not found: %s\n' "$loader" >&2
    return 1
  fi

  # shellcheck source=/dev/null
  source "$loader"
  blm_load runtime system reliability
}
```

Gli script consumer fanno source solo dell'adapter:

```bash
source "$PROJECT_ROOT/scripts/lib/bashloom.sh"
project_bashloom_init
```

In questo modo la policy di caricamento Bashloom resta centralizzata.

## 4. Preferire il caricamento selettivo dei moduli

I consumer production dovrebbero caricare solo i gruppi necessari.

Esempio installer:

```bash
blm_load runtime system
```

Esempio deployment:

```bash
blm_load runtime reliability docker network
```

Esempio orientato a systemd:

```bash
blm_load runtime reliability systemd
```

`blm_load all` è utile per tool completi e prototipi, ma il caricamento selettivo rende più chiara la superficie di dipendenze.

## 5. Modalità migrazione / validazione

Durante l'adozione o la validazione pre-release, un consumer può mantenere il percorso baseline e rendere Bashloom opt-in:

```bash
PROJECT_BASHLOOM=${PROJECT_BASHLOOM:-0}
```

Un wrapper di progetto può preservare il comportamento baseline:

```bash
project_run() {
  case "$PROJECT_BASHLOOM" in
    1|true)
      blm_run -- "$@"
      ;;
    *)
      "$@"
      ;;
  esac
}
```

Questo abilita test di parity come:

```bash
PROJECT_BASHLOOM=0 bash scripts/install.sh
PROJECT_BASHLOOM=1 bash scripts/install.sh
```

Quando l'integrazione è validata e il progetto decide che Bashloom è una dipendenza normale, il fallback può essere rimosso.

## 6. CI locale e GitHub Actions devono eseguire gli stessi script

È preferibile avere entrypoint CI locali al progetto:

```text
scripts/ci/
├── verify-bashloom-vendor.sh
├── lint.sh
├── test.sh
└── validate.sh
```

Esempio `validate.sh`:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/verify-bashloom-vendor.sh"
bash "$SCRIPT_DIR/lint.sh"
bash "$SCRIPT_DIR/test.sh"
```

Esecuzione locale:

```bash
bash scripts/ci/validate.sh
```

GitHub Actions:

```yaml
- uses: actions/checkout@v4

- name: Validate
  run: bash scripts/ci/validate.sh
```

Il workflow CI deve restare sottile. La logica operativa deve stare in script shell versionati e rieseguibili anche localmente.

## 7. Non scaricare ed eseguire Bashloom in CI o deploy

Evitare pattern come:

```bash
git clone ...bashloom...
```

oppure:

```bash
curl ... | bash
```

dentro workflow di deployment o validazione.

La versione Bashloom fidata deve essere già presente nel checkout del consumer.

## 8. Aggiornare Bashloom è una modifica consumer esplicita

Flusso di aggiornamento consigliato:

```text
commit/tag Bashloom approvato
→ vendor --force
→ verifica integrità
→ review del git diff
→ consumer CI
→ test reale dove necessario
→ merge
```

Esempio:

```bash
bash /percorso/bashloom/tools/vendor.sh \
  --destination vendor/bashloom \
  --pin <NUOVO_SHA> \
  --force

bash scripts/ci/verify-bashloom-vendor.sh
bash scripts/ci/validate.sh
```

I consumer non devono mai seguire silenziosamente upstream `main`.

## 9. Semantica del file PIN

`vendor/bashloom/PIN` è volutamente semplice e deve contenere l'esatto commit o riferimento tag approvato usato per creare il bundle.

Esempio:

```text
8489c1a14bca668febd977dfb826fb55d5bb27b1
```

Eventuali metadata più ricchi, se introdotti in futuro, dovrebbero vivere in un file separato invece di sovraccaricare `PIN`.

## 10. Policy di feedback upstream

Se un consumer scopre un problema Bashloom generico, deve riportarlo upstream includendo:

- PIN Bashloom;
- workflow consumer;
- comportamento atteso;
- comportamento osservato;
- exit status;
- riproduzione minima sanitizzata quando possibile.

Non mantenere fix locali nascosti dentro l'albero vendorizzato.

Dopo il merge di una correzione upstream, il consumer esegue un repin esplicito e rilancia la propria validazione.

## Riepilogo del contratto consigliato

1. Vendorizzare Bashloom nel repository consumer.
2. Pinnare un commit o tag esplicito.
3. Conservare `PIN`, `LICENSE`, `SHA256SUMS` e `src/` completa.
4. Non modificare localmente i sorgenti Bashloom vendorizzati.
5. Usare un solo adapter Bashloom locale al progetto.
6. Preferire gruppi `blm_load` selettivi.
7. Eseguire gli stessi script CI in locale e su GitHub Actions.
8. Non clonare/scaricare Bashloom durante deploy o CI.
9. Aggiornare Bashloom solo tramite repin esplicito.
10. Eseguire la consumer CI dopo ogni repin.
11. Riportare upstream bug e miglioramenti generici.

Questo modello è la baseline di integrazione Bashloom consigliata per applicazioni riutilizzabili, installer, repository infrastrutturali e workflow CI/CD.
