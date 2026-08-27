# Documentation Policy / Policy della documentazione

## English

Documentation is a first-class deliverable in Bashloom.

### Language policy

- The **canonical project documentation** is maintained in **English and Italian**.
- English and Italian are peer canonical versions: neither is considered a summary of the other.
- Source code, API names and identifiers are written in **English**.
- Code comments in the merged codebase are written in **English**.
- Commit messages and pull-request titles should be written in **English** when reasonably possible; maintainers may normalize them during review.
- Examples may contain localized output only when localization itself is being demonstrated.

### Contributor language accessibility

Bashloom's language policy must not become a barrier to contribution.

Contributors may submit documentation, explanations, review notes and draft code comments in **their native language**, including languages other than English or Italian. A contribution must not be rejected solely because its author is not comfortable writing English or Italian.

During final maintainer review:

1. documentation relevant to the accepted change is adapted into the canonical **EN and IT** versions;
2. source-code comments are translated or rewritten into **English** before merge;
3. identifiers and public API names remain English;
4. maintainers may rewrite wording to preserve technical accuracy, terminology and consistency.

The responsibility for final EN/IT parity and English-only merged source comments belongs to the **project at merge time**, not necessarily to the individual contributor.

### Community translations

When a contributor provides documentation in another language, Bashloom may preserve a reviewed version as an **optional community translation**.

Community translations:

- are supplementary and do not replace the canonical EN/IT documentation;
- may be stored under `docs/translations/<locale>/`;
- should link to the corresponding canonical document;
- may be adapted by maintainers and, when practical, reviewed again by the contributor or another speaker of that language;
- are not subject to mandatory parity with every future EN/IT change and may therefore lag behind;
- must be clearly marked as non-canonical when they are not guaranteed to be current.

This allows contributors to read and verify the maintainer-adapted result in a language they understand, without turning every accepted language into a permanent mandatory maintenance obligation for the project.

### Parity rule

A change that affects public API, behavior, installation, compatibility, security assumptions or project architecture is incomplete **at merge time** until both canonical EN and IT documentation are updated.

Preferred layout:

```text
docs/
├── en/
│   └── <document>.md
├── it/
│   └── <document>.md
├── translations/
│   └── <locale>/
│       └── <document>.md
└── adr/
    ├── NNNN-<decision>-en.md
    └── NNNN-<decision>-it.md
```

Each canonical EN/IT pair should preserve the same headings, semantic content and examples unless language-specific clarification is necessary.

### Documentation review checklist

Before merging a behavior or API change, verify:

1. canonical EN documentation is present and current;
2. canonical IT documentation is present and current;
3. contributor-supplied native-language material has been reflected accurately in the accepted implementation;
4. source comments in merged code are in English;
5. examples remain executable or clearly marked as conceptual;
6. public function names and signatures match source code;
7. compatibility statements are still correct;
8. security implications are documented when relevant;
9. optional community translations are clearly marked and linked to their canonical counterpart.

### Source comments

Contributors may initially write draft comments in a language they understand. Before merge, maintainers normalize source comments to English.

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

- La **documentazione canonica del progetto** viene mantenuta in **inglese e italiano**.
- Le versioni canoniche inglese e italiana hanno pari dignità: nessuna è un semplice riassunto dell'altra.
- Sorgenti, nomi delle API e identificatori sono scritti in **inglese**.
- I commenti nel codice della versione integrata sono scritti in **inglese**.
- Commit message e titoli delle pull request dovrebbero essere in **inglese** quando ragionevolmente possibile; i maintainer possono normalizzarli durante la revisione.
- Gli esempi possono contenere output localizzato solo quando la localizzazione stessa è oggetto della dimostrazione.

### Accessibilità linguistica per i contributor

La policy linguistica di Bashloom non deve diventare una barriera alla contribuzione.

I contributor possono inviare documentazione, spiegazioni, note di revisione e commenti provvisori nel codice nella **propria lingua madre**, comprese lingue diverse da inglese e italiano. Un contributo non deve essere rifiutato esclusivamente perché il suo autore non è a proprio agio nello scrivere in inglese o italiano.

Durante la revisione finale dei maintainer:

1. la documentazione relativa alla modifica accettata viene adattata nelle versioni canoniche **EN e IT**;
2. i commenti nei sorgenti vengono tradotti o riscritti in **inglese** prima del merge;
3. identificatori e nomi delle API pubbliche restano in inglese;
4. i maintainer possono riscrivere il testo per preservare accuratezza tecnica, terminologia e coerenza.

La responsabilità della parità finale EN/IT e dei commenti in inglese nella codebase integrata appartiene al **progetto al momento del merge**, non necessariamente al singolo contributor.

### Traduzioni della community

Quando un contributor fornisce documentazione in un'altra lingua, Bashloom può conservarne una versione revisionata come **traduzione opzionale della community**.

Le traduzioni della community:

- sono supplementari e non sostituiscono la documentazione canonica EN/IT;
- possono essere salvate sotto `docs/translations/<locale>/`;
- devono rimandare al corrispondente documento canonico;
- possono essere adattate dai maintainer e, quando possibile, nuovamente revisionate dal contributor o da un altro parlante della lingua;
- non sono soggette all'obbligo di parità con ogni futura modifica EN/IT e possono quindi non essere sempre aggiornate;
- devono essere chiaramente marcate come non canoniche quando non è garantito che siano aggiornate.

Questo permette al contributor di leggere e verificare il risultato adattato dai maintainer in una lingua che comprende, senza trasformare ogni lingua accettata in un obbligo permanente di manutenzione per il progetto.

### Regola di parità

Una modifica che influenza API pubblica, comportamento, installazione, compatibilità, assunzioni di sicurezza o architettura del progetto è incompleta **al momento del merge** finché entrambe le versioni canoniche EN e IT non vengono aggiornate.

Layout preferito:

```text
docs/
├── en/
│   └── <document>.md
├── it/
│   └── <document>.md
├── translations/
│   └── <locale>/
│       └── <document>.md
└── adr/
    ├── NNNN-<decision>-en.md
    └── NNNN-<decision>-it.md
```

Ogni coppia canonica EN/IT dovrebbe mantenere gli stessi titoli, contenuti semantici ed esempi salvo chiarimenti specifici della lingua.

### Checklist di revisione documentale

Prima di integrare una modifica ad API o comportamento, verificare:

1. documentazione canonica EN presente e aggiornata;
2. documentazione canonica IT presente e aggiornata;
3. materiale in lingua madre fornito dal contributor recepito correttamente nell'implementazione accettata;
4. commenti nei sorgenti integrati in inglese;
5. esempi ancora eseguibili o chiaramente marcati come concettuali;
6. nomi e firme delle funzioni pubbliche allineati ai sorgenti;
7. dichiarazioni di compatibilità ancora corrette;
8. implicazioni di sicurezza documentate quando rilevanti;
9. eventuali traduzioni community chiaramente marcate e collegate alla controparte canonica.

### Commenti nei sorgenti

I contributor possono inizialmente scrivere commenti provvisori in una lingua che comprendono. Prima del merge, i maintainer normalizzano i commenti nei sorgenti in inglese.

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
