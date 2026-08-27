# Standard di documentazione nel sorgente

Bashloom considera i commenti nel sorgente parte del contratto di manutenibilità, non semplice prosa accessoria.

## Obiettivi

La documentazione in-source deve permettere di capire una primitiva pubblica senza dover prima ricostruire mentalmente l'implementazione. I commenti devono descrivere il contratto e le decisioni ingegneristiche non ovvie che lo sostengono.

Per ogni funzione pubblica `blm_*`, il sorgente deve documentare almeno:

- nome dell'API pubblica;
- scopo;
- utilizzo/firma;
- argomenti quando non sono autoesplicativi;
- semantica degli status di ritorno;
- comportamento stdout/stderr quando rilevante;
- side effect;
- dipendenze esterne quando presenti;
- vincoli di sicurezza, source-safety o portabilità quando rilevanti;
- invarianti o motivazioni progettuali importanti non immediatamente evidenti dal codice.

Il marker canonico è:

```bash
# Public API: blm_example
```

La CI verifica che ogni funzione pubblica `blm_*` abbia questo marker vicino alla propria definizione.

## Helper interni

Le funzioni interne `_blm_*` non richiedono il marker pubblico machine-checkable, ma gli helper non banali devono comunque descrivere scopo, assunzioni e relazione con il comportamento pubblico.

## Cosa non commentare

I commenti non devono limitarsi a ripetere meccanicamente la sintassi. Commenti come “incrementa il contatore” o “assegna la variabile” aggiungono poco valore. È preferibile spiegare perché esiste quel contatore, quale invariante rappresenta, perché un ramo preserva un exit status o perché una dipendenza esterna viene invocata soltanto a call-time.

## Lingua

I commenti nei sorgenti vengono mantenuti in inglese, in coerenza con la policy relativa a identificatori e commenti source. La documentazione esplicativa canonica destinata agli utenti continua a essere mantenuta in inglese e italiano.

## Regola di manutenzione

Una pull request che aggiunge o modifica materialmente un'API pubblica deve aggiornare nello stesso cambiamento la relativa documentazione in-source. Una funzione pubblica senza il marker richiesto fa fallire la CI.
