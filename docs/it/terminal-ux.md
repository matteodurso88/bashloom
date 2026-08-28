# Terminal UX

Il layer terminale della RC v0.1 di Bashloom fornisce sia rendering line-oriented sia una foundation TUI full-screen senza dipendenze obbligatorie, mantenendo comportamento deterministico in CI, pipe e ambienti non interattivi.

## Obiettivi

- comportamento deterministico in CI e pipe;
- nessuna risposta inventata per i prompt interattivi;
- rendering stabile human/plain/JSON;
- più stili visuali riutilizzabili senza proliferazione di API;
- layout Unicode width-aware con fallback deterministico;
- lifecycle TUI full-screen esplicito senza side effect al source;
- nessuna dipendenza UI third-party obbligatoria;
- preservazione esatta dello status del comando wrapped.

## API prompt

- `blm_prompt <message> [default]`
- `blm_confirm <message> [yes|no]`
- `blm_password <message>`
- `blm_select <message> [--default N] -- <option> [option...]`

I default espliciti possono essere usati quando stdin non è interattivo. Senza default, gli helper falliscono invece di inventare input. `blm_password` richiede sempre stdin interattivo.

## Registry theme e style

`BLM_UI_THEME` seleziona un preset coerente:

- `default`
- `modern`
- `minimal`
- `ascii`
- `ci`

`blm_ui_theme` restituisce il theme attivo validato. `blm_ui_style <component>` restituisce lo style risolto per `spinner`, `progress`, `panel`, `table` o `tree`.

Sono supportati override environment per componente:

```bash
BLM_SPINNER_STYLE=pulse
BLM_PROGRESS_STYLE=dots
BLM_PANEL_STYLE=double
BLM_TABLE_STYLE=compact
BLM_TREE_STYLE=ascii
```

Gli override per chiamata hanno precedenza dove supportati:

```bash
blm_spinner --style dots "Deploy" command ...
blm_progress --style thin 3 10 "Uploading"
blm_panel --style double "Runtime" "ready"
blm_table --style compact $'Name\tState'
blm_tree --style ascii 1 child
```

`BLM_UI_STYLE=rich|minimal` resta lo switch di densità ad alto livello. Theme o style invalidi restituiscono status `2` invece di degradare silenziosamente.

## API rendering

- `blm_panel [--style rounded|square|double|minimal|ascii] <title> [line...]`
- `blm_table [--style unicode|ascii|compact|minimal] <row> [row...]`
- `blm_tree [--style unicode|ascii|minimal] <depth> <label>`
- `blm_tree_view [--style unicode|ascii|minimal] <tab-indented-line> [line...]`

`blm_tree` resta l'helper compatibile orientato alla singola riga. Una singola riga non può conoscere i sibling futuri, quindi non può inferire la topologia dell'ultimo figlio.

`blm_tree_view` riceve invece un albero completo in cui i TAB iniziali dichiarano la profondità. Può quindi inferire correttamente `├─`, `└─` e le linee verticali di continuazione, con fallback ASCII/minimal.

Esempio:

```bash
blm_tree_view \
  "Bashloom" \
  $'\tcore' \
  $'\tui' \
  $'\t\tterminal' \
  $'\t\ttui'
```

## Display width

`blm_display_width <text>` restituisce la larghezza visuale del testo in celle terminale.

Bash non possiede una primitiva `wcwidth` nativa. Quando `python3` è disponibile, Bashloom usa il modulo standard `unicodedata` per considerare combining characters e caratteri East Asian wide/full-width. In assenza di Python usa un fallback deterministico basato sul conteggio caratteri Bash. Gli ambienti ASCII/minimal restano quindi dependency-free.

Panel e table usano la display width invece della semplice lunghezza della stringa Bash.

## API progress

- `blm_progress [--style blocks|bar|thin|dots|percent] <current> <total> [label]`
- `blm_spinner [--style braille|line|dots|pulse] <label> <command> [args...]`

`BLM_PROGRESS_WIDTH` controlla la larghezza della barra e ha default 24 celle.

Qualsiasi render progress valido, anche intermedio, restituisce `0`, quindi resta sicuro sotto `set -e` del caller. `blm_spinner` preserva lo status esatto del comando eseguito.

In plain/JSON/non-TTY il comportamento resta line-oriented e deterministico indipendentemente dallo style visuale selezionato.

## Policy charset

`BLM_UI_CHARSET` accetta:

- `auto` (default): Unicode quando la locale attiva dichiara UTF-8;
- `unicode`: richiede glifi Unicode;
- `ascii`: forza rendering ASCII portabile.

I theme `ascii` e `ci` forzano una presentazione ASCII effettiva. Bashloom non assume la disponibilità di font emoji: usa simboli terminale, block e box-drawing, non emoji.

## Foundation TUI full-screen

API pubbliche:

- `blm_tui_available`
- `blm_tui_enter`
- `blm_tui_leave`
- `blm_tui_clear`
- `blm_tui_move <row> <column>`
- `blm_tui_size`
- `blm_tui_read_key [timeout-seconds]`
- `blm_tui_run <command> [args...]`

Il layer TUI usa alternate screen e controllo cursor soltanto quando l'output human è collegato a un TTY adatto. In esecuzione non interattiva o `TERM=dumb` rifiuta l'attivazione invece di inquinare i log con sequenze di controllo.

`blm_tui_run` è il wrapper lifecycle raccomandato: entra nell'alternate screen, esegue il comando, ripristina sempre cursor/screen e restituisce lo status esatto del comando wrapped.

Non viene installato alcun trap automaticamente. Questo preserva il contratto source-safe e non sovrascrive la trap policy del caller.

`blm_tui_size` è resize-aware perché risolve le dimensioni a ogni chiamata. Sono disponibili gli override `BLM_TUI_COLUMNS`/`BLM_TUI_LINES` per i test; altrimenti usa `COLUMNS`/`LINES`, `tput` opzionale e infine fallback deterministico `80x24`.

`blm_tui_read_key` normalizza eventi comuni: frecce, HOME/END, ESC, ENTER, TAB e BACKSPACE.

## Demo

`examples/10-terminal-ux.sh` resta CI-safe. `examples/11-rich-terminal.sh` viene ampliato durante il ciclo RC per mostrare theme, varianti, tree topology-aware e foundation TUI.

## Caricamento selettivo

Il gruppo loader `terminal` contiene prompt, registry theme/style, rendering width-aware, progress/spinner e foundation TUI. `all` include automaticamente `terminal`.

## Backend esterni

Gum, fzf o strumenti analoghi non sono dipendenze obbligatorie. Potranno essere aggiunti come backend opzionali, ma la superficie terminale della RC v0.1 resta utilizzabile con Bash e sole utility standard feature-specific.
