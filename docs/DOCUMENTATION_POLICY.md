# Documentation Policy / Policy della documentazione

## English

Documentation is a first-class deliverable in Bashloom.

### Language policy

- User-facing documentation is maintained in **English and Italian**.
- English and Italian are peer versions: neither is considered a summary of the other.
- Source code, API names, identifiers and code comments are written in **English**.
- Commit messages and pull-request titles are written in **English**.
- Examples may contain localized output only when localization itself is being demonstrated.

### Parity rule

A change that affects public API, behavior, installation, compatibility, security assumptions or project architecture is incomplete until both EN and IT documentation are updated.

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

1. EN documentation updated;
2. IT documentation updated;
3. examples remain executable or clearly marked as conceptual;
4. public function names and signatures match source code;
5. compatibility statements are still correct;
6. security implications are documented when relevant.

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

### Regola di parità

Una modifica che influenza API pubblica, comportamento, installazione, compatibilità, assunzioni di sicurezza o architettura del progetto è incompleta finché la documentazione EN e IT non viene aggiornata.

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

1. documentazione EN aggiornata;
2. documentazione IT aggiornata;
3. esempi ancora eseguibili o chiaramente marcati come concettuali;
4. nomi e firme delle funzioni pubbliche allineati ai sorgenti;
5. dichiarazioni di compatibilità ancora corrette;
6. implicazioni di sicurezza documentate quando rilevanti.

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
