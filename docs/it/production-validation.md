# M6F — Production Validation

M6F valida Bashloom su workflow consumer reali prima della `v0.1.0`. Lo scopo è individuare difetti di API, affidabilità e operabilità che test unitari e di integrazione possono non evidenziare, preservando al tempo stesso ownership e policy di deployment di ciascun consumer.

## Confine di ownership

I repository consumer mantengono piena ownership su runtime, deploy, rollback e procedure di release.

I maintainer Bashloom possono:

- proporre un confine di integrazione a basso rischio;
- fornire istruzioni di consumo pinnate;
- definire criteri di validazione;
- analizzare il feedback e riprodurre i difetti nel repository Bashloom.

I maintainer Bashloom non devono mergiare o distribuire autonomamente modifiche in un repository consumer, salvo autorizzazione esplicita attraverso il normale workflow di ownership di quel progetto.

## Evidence consumer

### Oriqo Infrastructure — validazione deployment M6F storica

Repository: `oriqoproject/oriqo-infrastructure`

Stato: **PASS**.

Oriqo Infrastructure ha completato la prima validazione reale di deployment tramite il workflow di staging del consumer owner. L'evidence storica è tracciata nella issue Bashloom `#16` e nel corrispondente tracker consumer completato di Oriqo Infrastructure.

Pin storico di validazione:

```text
b6a096ba1feb31f41a639856b29ae07e25ba3676
```

Questo pin rappresenta l'evidence della validazione deployment M6F completata e non è il target corrente di adozione repository-wide.

### Baseline corrente per l'adozione/validazione multi-consumer RC

Il target comune corrente è:

```text
release: v0.1.0-rc1
commit: bbbbd9b8e61c7d951b8b9fc8f00c351b50a1bf51
```

La campagna RC amplia la validazione rispetto alla singola evidence M6F storica e verifica Bashloom sull'intera superficie Bash di più repository consumer reali. Questa campagna resta distinta dal deployment PASS Oriqo già completato.

## Protocollo di validazione

Per ogni integrazione consumer:

1. Scegliere un workflow rappresentativo o una superficie Bash con uno scopo di validazione chiaro.
2. Pinnare Bashloom a un commit o release esatti.
3. Preservare comportamento, exit code e policy di rollback del consumer.
4. Usare il normale workflow di ownership e review del repository consumer.
5. Verificare, dove praticabile, l'equivalenza di comportamento pre/post-migrazione.
6. Eseguire CI e controlli statici nativi del consumer.
7. Eseguire staging, test o procedura device seguendo il normale processo di ownership del consumer.
8. Registrare nel repository Bashloom ogni difetto o primitiva mancante relativa a Bashloom.
9. Correggere i difetti di libreria in Bashloom invece di aggiungere compensazioni specifiche nel consumer, salvo che il workaround rappresenti una policy legittima del consumer stesso.
10. Aggiornare il pin solo dopo merge e validazione della correzione Bashloom.

## Contratto di feedback

I maintainer consumer devono riportare i finding a `matteodurso88/bashloom` tramite issue o pull request.

Un report utile include:

- commit/release Bashloom usato;
- repository consumer e workflow interessato;
- comando o API esatti coinvolti;
- comportamento atteso;
- comportamento osservato;
- exit status e stdout/stderr rilevanti;
- presenza di `set -e`, trap, pipeline, CI o esecuzione non-TTY;
- riproduzione minima quando disponibile;
- classificazione come bug, capability mancante, problema di usabilità o miglioramento di performance/operabilità.

Anche un possibile miglioramento, non solo un bug, va riportato upstream. Il repository Bashloom resta la source of truth per decidere se il miglioramento appartiene alla libreria generica, a una milestone futura o soltanto al consumer.

Anche il drift documentale scoperto dai consumer è un finding upstream valido quando roadmap canonica, release notes ed evidence di validazione registrata non concordano.

## Stato corrente M6F / RC

Evidence completata:

- [x] protocollo di ownership e feedback per field validation definito;
- [x] almeno un workflow reale di deployment validato — staging Oriqo Infrastructure PASS;
- [x] prima baseline RC pubblica `v0.1.0-rc1`.

Ancora richiesto prima della `v0.1.0` stabile:

- [ ] evidence su workflow desktop/installer;
- [ ] evidence su workflow system/provisioning;
- [ ] validazione multi-consumer RC sufficientemente ampia da esercitare core/runtime, reliability, filesystem/idempotenza, integrazioni e terminal UX;
- [ ] review/fix evidence-driven di eventuali comportamenti instabili emersi nei consumer;
- [ ] assenza di regressioni blocker-class note su source-safety, exit status o rollback.

Le matrici manuali cross-distribution, macOS e WSL restano rimandate finché tali ambienti non potranno essere validati direttamente.
