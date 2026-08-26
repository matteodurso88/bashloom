# Security Policy / Policy di sicurezza

## English

Bashloom is a shell runtime library. A defect in quoting, temporary-file handling, command execution, permissions, environment parsing or cleanup can become a security issue in downstream automation.

Please do **not** publish exploitable security vulnerabilities as public issues before maintainers have had a reasonable opportunity to assess them.

For security reports, contact the project owner through the contact channels published on **matt88.it** and include:

- affected Bashloom version or commit;
- affected function/module;
- reproduction steps;
- expected vs. observed behavior;
- impact assessment;
- a proposed fix, if available.

### Security principles

Bashloom aims to:

- avoid unsafe `eval` usage;
- quote expansions deliberately;
- create temporary resources safely;
- avoid logging secrets by default;
- preserve file permissions explicitly;
- avoid implicit privilege escalation;
- keep core behavior deterministic in CI and non-interactive environments.

No pre-v1 release should be assumed API-stable or security-hardened for every production environment. Consumers remain responsible for reviewing automation that performs privileged or destructive actions.

---

## Italiano

Bashloom è una runtime library per shell. Un errore nella quotatura, nella gestione dei file temporanei, nell'esecuzione di comandi, nei permessi, nel parsing dell'ambiente o nel cleanup può trasformarsi in un problema di sicurezza per le automazioni che utilizzano la libreria.

Si chiede di **non** pubblicare vulnerabilità sfruttabili come issue pubbliche prima che i maintainer abbiano avuto un tempo ragionevole per valutarle.

Per le segnalazioni di sicurezza, contattare il proprietario del progetto tramite i canali pubblicati su **matt88.it**, includendo:

- versione o commit Bashloom interessato;
- funzione/modulo interessato;
- passi per riprodurre il problema;
- comportamento atteso e osservato;
- valutazione dell'impatto;
- eventuale proposta di correzione.

### Principi di sicurezza

Bashloom punta a:

- evitare l'uso non sicuro di `eval`;
- quotare deliberatamente le espansioni;
- creare risorse temporanee in modo sicuro;
- non registrare segreti nei log per impostazione predefinita;
- gestire esplicitamente i permessi dei file;
- evitare escalation di privilegi implicite;
- mantenere un comportamento deterministico in CI e ambienti non interattivi.

Nessuna release pre-v1 deve essere considerata automaticamente API-stable o hardened per ogni ambiente produttivo. Chi integra Bashloom resta responsabile della revisione delle automazioni che eseguono operazioni privilegiate o distruttive.
