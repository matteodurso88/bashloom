# Documentation Policy / Policy della documentazione

## English

Documentation is a first-class deliverable in Bashloom.

### Language policy

- User-facing documentation is maintained in **English and Italian**.
- English and Italian are peer versions: neither is considered a summary of the other.
- Source code, API names, identifiers and code comments are written in **English**.
- Commit messages and pull-request titles are written in **English**.
- Examples may contain localized output only when localization itself is being demonstrated.

### Contributor language accessibility

Bashloom's bilingual policy must not become a barrier to contribution.

Contributors who are comfortable with only one of the project's documentation languages may submit or update documentation in **English or Italian only**. They are encouraged to state clearly which language they have provided and, when useful, note that maintainer translation or adaptation is required.

The responsibility for final EN/IT parity belongs to the **project at merge time**, not necessarily to the individual contributor. During final maintainer review, maintainers may translate, adapt, rewrite or complete the missing language counterpart before integration.

A contribution must not be rejected solely because the contributor does not know English or Italian well enough to maintain both versions.

### Parity rule

A change that affects public API, behavior, installation, compatibility, security assumptions or project architecture is incomplete **at merge time** until both EN and IT documentation are updated.

Preferred layout:

```text
docs/
├── en/
│   └── <document>.md
├── it/
│   └── <document>.md
└── adr/
    ├── NNNN-<decision>-en.md
    └── NNNN-<decision>-it.md
```

Each translated pair should preserve the same headings, semantic content and examples unless language-specific clarification is necessary.

### Documentation review checklist

Before merging a behavior or API change, verify:

1. EN documentation is present and current;
2. IT documentation is present and current;
3. missing translations or language adaptations have been completed by contributors or maintainers;
4. examples remain executable or clearly marked as conceptual;
5. public function names and signatures match source code;
6. compatibility statements are still correct;
7. security implications are documented when relevant.

### Source comments

Comments should explain **why**, invariants, edge cases, shell-specific traps and non-obvious portability decisions. Avoid comments that merely restate the next command.

Good:

```bash
# Preserve the wrapped command's exit status before rendering UI output.
local status=$?
```

Poor:

```bash
# Set status.
local status=$?
```

---

## Italiano

La documentazione è un deliverable di prima classe in Bashloom.

### Policy linguistica

- La documentazione destinata agli utenti viene mantenuta in **inglese e italiano**.
- Le versioni inglese e italiana hanno pari dignità: nessuna è un semplice riassunto dell'altra.
- Sorgenti, nomi delle API, identificatori e commenti nel codice sono scritti in **inglese**.
- Commit message e titoli delle pull request sono scritti in **inglese**.
- Gli esempi possono contenere output localizzato solo quando la localizzazione stessa è oggetto della dimostrazione.

### Accessibilità linguistica per i contributor

La policy bilingue di Bashloom non deve diventare una barriera alla contribuzione.

I contributor che conoscono in modo adeguato una sola delle due lingue documentali del progetto possono inviare o aggiornare la documentazione **solo in inglese oppure solo in italiano**. È consigliato indicare chiaramente quale lingua è stata fornita e, quando utile, segnalare che è necessaria la traduzione o l'adattamento da parte dei maintainer.

La responsabilità della parità finale EN/IT appartiene al **progetto al momento del merge**, non necessariamente al singolo contributor. Durante la revisione finale, i maintainer possono tradurre, adattare, riscrivere o completare la controparte linguistica mancante prima dell'integrazione.

Un contributo non deve essere rifiutato esclusivamente perché il contributor non conosce abbastanza bene l'inglese o l'italiano da mantenere entrambe le versioni.

### Regola di parità

Una modifica che influenza API pubblica, comportamento, installazione, compatibilità, assunzioni di sicurezza o architettura del progetto è incompleta **al momento del merge** finché la documentazione EN e IT non viene aggiornata.

Layout preferito:

```text
docs/
├── en/
│   └── <document>.md
├── it/
│   └── <document>.md
└── adr/
    ├── NNNN-<decision>-en.md
    └── NNNN-<decision>-it.md
```

Ogni coppia tradotta dovrebbe mantenere gli stessi titoli, contenuti semantici ed esempi salvo chiarimenti specifici della lingua.

### Checklist di revisione documentale

Prima di integrare una modifica ad API o comportamento, verificare:

1. documentazione EN presente e aggiornata;
2. documentazione IT presente e aggiornata;
3. eventuali traduzioni o adattamenti mancanti completati dai contributor o dai maintainer;
4. esempi ancora eseguibili o chiaramente marcati come concettuali;
5. nomi e firme delle funzioni pubbliche allineati ai sorgenti;
6. dichiarazioni di compatibilità ancora corrette;
7. implicazioni di sicurezza documentate quando rilevanti.

### Commenti nei sorgenti

I commenti devono spiegare il **perché**, gli invarianti, gli edge case, le insidie specifiche della shell e le decisioni di portabilità non ovvie. Evitare commenti che ripetono semplicemente il comando successivo.

Buono:

```bash
# Preserve the wrapped command's exit status before rendering UI output.
local status=$?
```

Scarso:

```bash
# Set status.
local status=$?
```
