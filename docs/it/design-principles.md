# Principi di progettazione

Bashloom nasce per rendere gli script Bash più affidabili, leggibili, operabili e semplici da contribuire.

## 1. Affidabilità prima dell'estetica

La UX da terminale ha valore solo se preserva la semantica di esecuzione. Status rendering, spinner e indicatori di progresso non devono mai nascondere o alterare l'exit status dell'operazione rappresentata.

## 2. Core senza dipendenze obbligatorie

Bash è l'unica dipendenza runtime obbligatoria. Strumenti opzionali possono migliorare capability specifiche, ma il core deve restare utile anche senza di essi.

## 3. Esplicito prima di implicito

Bashloom non abilita silenziosamente strict mode, non sostituisce trap, non modifica `IFS`, non effettua escalation di privilegi e non altera stato del chiamante non correlato.

## 4. Superficie pubblica ridotta

L'API pubblica deve crescere lentamente. Una funzione appartiene al core solo se risolve un problema generale ricorrente e può essere specificata, testata e documentata chiaramente.

## 5. Degradazione corretta

Le feature di terminale devono comportarsi correttamente con output TTY e non-TTY, pipe, CI, `TERM=dumb`, `NO_COLOR` e ambienti con supporto Unicode limitato.

## 6. Composizione operativa

La libreria deve rendere semplice costruire preflight check, step di comando, retry loop, condizioni di attesa, cleanup stack e workflow orientati al rollback a partire da primitive piccole.

## 7. Shell code consapevole della sicurezza

Quotatura, file temporanei, permessi, parsing dell'ambiente, logging e operazioni distruttive sono considerate aree sensibili dal punto di vista della sicurezza.

## 8. Parità documentale

Il comportamento pubblico viene documentato in inglese e italiano. L'aggiornamento della documentazione fa parte dell'implementazione e non è un'attività successiva.

## 9. Leggibilità per i contributor

I commenti spiegano intento, invarianti ed edge case specifici della shell. I trucchi Bash eccessivamente furbi vengono evitati quando esiste un'implementazione più chiara.

## 10. Origine italiana, respiro internazionale

Bashloom è un progetto open source italiano. La sua origine fa parte dell'identità del progetto, mentre linguaggio tecnico e modello di contribuzione sono volutamente internazionali.
