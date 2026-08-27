# Modello Output ed Errori

Bashloom mantiene espliciti presentazione, diagnostica e segnalazione degli errori, così gli script che fanno source del runtime restano sicuri da comporre dentro applicazioni, script di deployment e job CI.

## Helper di presentazione

```bash
blm_title <messaggio...>
blm_section <messaggio...>
```

Entrambi rispettano `BLM_OUTPUT_MODE`:

- `human` produce heading leggeri orientati al terminale;
- `plain` emette record deterministici `tipo: messaggio`;
- `json` emette un oggetto JSON per record.

Non dipendono dalla larghezza del terminale e non richiedono decorazioni Unicode.

## Diagnostica runtime

```bash
blm_diagnostics
```

Il contratto diagnostico attuale espone:

- `bashloom_version`
- `bash_version`
- `output_mode`
- `tty`
- `color`
- `ci`

La diagnostica usa `blm_kv`, quindi resta coerente con le modalità human/plain/JSON. La funzione è informativa e non produce effetti collaterali sul runtime.

## Helper di failure espliciti

```bash
blm_fail <status> <messaggio...>
blm_usage_error <messaggio...>
```

`blm_fail` renderizza un errore e restituisce lo status richiesto. Gli status validi sono interi da 1 a 255. Uno status non valido restituisce `2`.

`blm_usage_error` renderizza un errore e restituisce `2`, convenzione Bashloom per argomenti o utilizzo non validi delle API pubbliche.

Nessuno dei due helper chiama `exit`. È una scelta intenzionale: Bashloom viene spesso importata tramite source, quindi il caller conserva il controllo su rollback, cleanup, recovery o terminazione del processo.

Esempio:

```bash
if blm_fail 17 "deployment failed"; then
  :
else
  status=$?
  rollback_deployment
  exit "$status"
fi
```

## Comportamento machine-readable

In modalità JSON, presentazione e diagnostica producono oggetti JSON newline-delimited. Bashloom non incapsula l'intera esecuzione di un comando in un unico grande documento JSON; questo mantiene l'output utilizzabile in streaming dentro CI e pipeline shell.

Gli helper di stato continuano a inviare errori e warning su stderr e informazioni/successi su stdout secondo i contratti già esistenti.

## Source safety

Fare source di Bashloom continua a non produrre automaticamente presentazione, diagnostica o errori. Tutto il comportamento M6B è opt-in tramite chiamate esplicite alle funzioni.
