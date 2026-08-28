# Hardening semantico RC v0.1

Questo documento registra i comportamenti intenzionalmente stabilizzati prima della campagna comune di validazione multi-consumer della release candidate v0.1.

## Timeout e discendenti

`blm_timeout` conserva il contratto esistente sullo status del comando e lo status `124` per le deadline applicate da Bashloom.

Quando il comando wrapped si risolve in un eseguibile esterno e GNU coreutils `timeout` è disponibile, Bashloom delega la deadline a quel backend. GNU timeout fornisce una gestione matura dei process group, quindi l'escalation TERM/KILL raggiunge sia il comando diretto sia i discendenti da esso creati.

Le funzioni shell e i builtin mantengono invece il backend direct-child di Bashloom, perché rieseguire lo stato shell del caller tramite un wrapper esterno ne modificherebbe la semantica. Anche gli host senza GNU timeout usano il backend Bash diretto. Tutte le dipendenze restano call-time: il sourcing di Bashloom non richiede GNU timeout.

`--timeout 0` conserva il comportamento storico Bashloom di deadline immediata, anche se GNU timeout interpreta una durata zero come timeout disabilitato. `--grace 0` significa escalation immediata e viene mappato su un intervallo GNU kill-after minimo positivo, perché GNU `-k 0` disabilita l'escalation.

## Mode filesystem numerici

`blm_ensure_dir --mode` e `blm_ensure_mode` accettano solo permission mode ottali numerici. Un mode invalido o non ottale restituisce `2` prima di qualsiasi mutazione del filesystem.

Uno zero iniziale convenzionale viene normalizzato solo per il confronto con GNU `stat -c %a`; il mode originale, già validato, viene passato a `chmod`.

## Convergenza su singola riga

`blm_ensure_line` è esplicitamente un'API per una singola riga logica. LF e CR nel valore richiesto vengono rifiutati con status `2` prima che la destinazione venga modificata.

## Semantica atomic write

`blm_atomic_write` garantisce **sostituzione atomica sullo stesso filesystem**, non durabilità rispetto a power loss. Non promette `fsync` del file né dei metadati della directory.

Quando sostituisce una destinazione esistente, la conservazione del mode richiede attualmente GNU `chmod --reference`. Se la conservazione del mode fallisce, la sostituzione viene annullata e la destinazione precedente resta intatta.

## Stringhe JSON

L'escaping JSON del core Bashloom ora copre tutti i control character C0 rappresentabili in una variabile Bash. Le variabili Bash non possono contenere byte NUL. L'Unicode stampabile viene preservato.

Resta un helper di escaping mirato ai record JSON line-oriented di Bashloom, non un serializer JSON binario/general-purpose.

## Policy lock

I directory lock deliberatamente **non** effettuano auto-recovery dei path stale nella v0.1. Determinare in sicurezza se un lock è stale dipende da policy applicative su ownership, host e liveness. Un lock directory già esistente resta quindi un'acquisizione non-blocking fallita.

## Commenti config

Il formato config letterale riconosce intenzionalmente i commenti solo quando `#` è il primo byte. Il whitespace iniziale è dato e farà fallire la validazione della key quando la rende invalida. Bashloom non effettua trim o normalizzazione dell'input config.

## Policy parent del log file

`BLM_LOG_FILE` è append-only e non induce mai Bashloom a creare implicitamente la directory parent. Un parent mancante o non scrivibile rende fallita la persistenza. I caller che vogliono convergenza devono creare/validare esplicitamente la directory prima di abilitare il logging su file.

Queste policy fanno parte del candidato al freeze RC v0.1 e dovrebbero cambiare solo se l'evidenza emersa dalla validazione sul campo dimostra un difetto o un problema di usabilità inaccettabile.
