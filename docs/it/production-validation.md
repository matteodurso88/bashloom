# M6F — Production Validation

M6F valida Bashloom su workflow consumer reali prima della `v0.1.0`. Lo scopo non è imporre l'adozione completa di Bashloom ai consumer, ma individuare difetti di API, affidabilità e operabilità che test unitari e di integrazione possono non evidenziare.

## Confine di ownership

I repository consumer mantengono piena ownership su runtime, deploy, rollback e procedure di release.

I maintainer Bashloom possono:

- proporre un confine di integrazione a basso rischio;
- fornire istruzioni di consumo pinnate;
- definire criteri di validazione;
- analizzare il feedback e riprodurre i difetti nel repository Bashloom.

I maintainer Bashloom non devono mergiare o distribuire autonomamente modifiche in un repository consumer, salvo autorizzazione esplicita attraverso il normale workflow di ownership di quel progetto.

## Consumer candidati

### Oriqo Infrastructure

Repository: `oriqoproject/oriqo-infrastructure`

Stato: consumer candidato per un workflow reale di deployment.

Nel repository consumer esiste una proposta di integrazione in draft per review OR/DEV. OR/DEV restano responsabili della decisione su se, dove e come adottare Bashloom in Oriqo.

Pin di validazione corrente:

```text
b6a096ba1feb31f41a639856b29ae07e25ba3676
```

## Protocollo di validazione

Per ogni integrazione consumer:

1. Scegliere un workflow rappresentativo e a basso blast radius.
2. Pinnare Bashloom a un commit o release esatti.
3. Preservare comportamento, exit code e policy di rollback del consumer.
4. Preferire un'adozione opt-in nella prima fase di validazione.
5. Eseguire, dove praticabile, lo stesso workflow con e senza Bashloom.
6. Eseguire CI e controlli statici nativi del consumer.
7. Eseguire staging o procedura di test seguendo il normale processo di ownership del consumer.
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

## Criteri di uscita M6F

Prima della `v0.1.0`, Bashloom dovrebbe avere evidenza per:

- almeno un workflow reale di deployment;
- un workflow desktop/installer;
- un workflow system/provisioning;
- revisione delle API instabili guidata dal feedback sul campo;
- assenza di regressioni critiche note relative a source-safety, exit status o rollback nei consumer validati.

Le matrici manuali cross-distribution, macOS e WSL restano rimandate finché tali ambienti non potranno essere validati direttamente.
