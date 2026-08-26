# ADR 0001 — Foundation del progetto

- **Stato:** Accettato
- **Data:** 2026-08-27

## Contesto

Bashloom viene creato come libreria Bash pubblica e riutilizzabile, non come semplice raccolta di helper interni. Il progetto deve supportare contributor internazionali mantenendo e comunicando esplicitamente la propria origine italiana. Deve inoltre restare utilizzabile in ambienti Linux/server minimali dove installare binari ausiliari può essere indesiderato.

## Decisione

1. Bashloom è un **progetto open source italiano** creato e di proprietà di Matteo D'Urso (`matteodurso88`).
2. Developer Oriqo (`dev-oriqo`) è l'**account tecnico di sviluppo** del proprietario e può eseguire commit, pull request, manutenzione issue e altre operazioni sul repository. Non rappresenta un proprietario separato.
3. **matt88.it** viene accreditato come vetrina del progetto e superficie di contatto del proprietario.
4. La documentazione destinata agli utenti viene mantenuta con **parità inglese/italiano**.
5. Sorgenti, identificatori, commenti, commit message e titoli delle pull request usano **l'inglese**.
6. L'unica dipendenza runtime obbligatoria del core è **Bash**.
7. Il sourcing di Bashloom deve essere **source-safe**: nessuno strict mode implicito, sostituzione trap, modifica di `IFS` o alterazione di stato non correlato del chiamante.
8. L'API pubblica usa `blm_*`; quella interna usa `_blm_*`.
9. Bashloom punta inizialmente a Bash >= 4.3 con Linux come piattaforma first-class.

## Conseguenze

- L'aggiornamento della documentazione fa parte del completamento delle feature.
- I contributor possono lavorare con una sola lingua tecnica nei sorgenti mentre gli utenti italiani ricevono documentazione di prima classe.
- Tool opzionali come Gum, fzf o jq possono migliorare alcuni moduli ma non diventare requisiti core nascosti.
- La crescita dell'API deve essere deliberata perché il progetto è destinato al riuso pubblico.

## Alternative considerate

### Commenti bilingui nei sorgenti

Scartati perché la duplicazione aumenterebbe rumore e costo di sincronizzazione senza migliorare realmente la contribuzione internazionale.

### Compatibilità POSIX sh come target primario

Scartata nell'architettura iniziale perché limiterebbe significativamente l'implementazione mentre Bash è una premessa esplicita del progetto.

### Gum o altro binario esterno come runtime obbligatoria

Scartato perché impedirebbe a Bashloom di servire server minimali, container, sistemi di rescue e SBC senza installazioni aggiuntive.
