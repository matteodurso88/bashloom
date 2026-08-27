# Terminal UX

M6E fornisce primitive terminal UX leggere senza trasformare Bashloom in un framework TUI full-screen. M6E.1 aggiunge un rendering più ricco per terminali human mantenendo fallback deterministici per CI, pipe e output machine-readable.

## Obiettivi

- comportamento deterministico in CI e pipe;
- nessuna risposta inventata per i prompt interattivi;
- rendering stabile human/plain/JSON;
- output visivamente più ricco sui terminali reali;
- nessuna dipendenza UI third-party obbligatoria;
- preservazione esatta dello status del comando eseguito.

## API prompt

- `blm_prompt <message> [default]`
- `blm_confirm <message> [yes|no]`
- `blm_password <message>`
- `blm_select <message> [--default N] -- <option> [option...]`

`blm_prompt`, `blm_confirm` e `blm_select` possono usare default espliciti quando stdin non è interattivo. Senza default falliscono invece di inventare input. `blm_password` richiede sempre stdin interattivo e usa `read -s` di Bash per non mostrare il segreto digitato. `blm_select` restituisce il valore dell'opzione scelta, mentre il menu viene renderizzato su stderr.

## API rendering

- `blm_panel <title> [line...]`
- `blm_table <row> [row...]`
- `blm_tree <depth> <label>`

La modalità human TTY ora renderizza panel auto-dimensionati, tabelle tab-delimited realmente allineate e tree con branch marker. La modalità plain resta deterministica e JSON resta machine-readable.

## API progress

- `blm_progress <current> <total> [label]`
- `blm_spinner <label> <command> [args...]`

Su un terminale human reale, `blm_progress` renderizza una barra visiva a larghezza fissa, ad esempio:

```text
[████████████░░░░░░░░░░░░]  50%  Building release
```

`BLM_PROGRESS_WIDTH` controlla la larghezza della barra e il default è 24 celle.

`blm_spinner` usa uno spinner Unicode animato dove disponibile e uno spinner ASCII classico negli altri casi. Preserva comunque lo status esatto del comando wrapped. In contesti non interattivi/plain/JSON degrada a record lifecycle stabili.

## Policy charset e stile

`BLM_UI_CHARSET` accetta:

- `auto` (default): Unicode quando la locale attiva dichiara UTF-8, altrimenti ASCII;
- `unicode`: forza i glifi Unicode;
- `ascii`: forza il rendering ASCII portabile.

`BLM_UI_STYLE` accetta `rich` (default) o `minimal`. Il rendering rich viene usato soltanto per output human collegato a terminale. Plain/JSON non dipendono mai dalle capability grafiche del terminale.

Questo evita di assumere la presenza di font emoji: il rendering rich usa normali simboli Unicode da terminale e glifi block/box, non emoji.

## Demo

`examples/10-terminal-ux.sh` resta l'esempio foundation CI-safe. `examples/11-rich-terminal.sh` è invece la showcase visuale da eseguire manualmente in un terminale reale:

```bash
bash examples/11-rich-terminal.sh
```

Con stdout collegato a un vero TTY mostra spinner animato, progress bar, tabella allineata, panel rich e tree. In pipe o CI lo stesso script resta non bloccante e deterministico.

## Caricamento selettivo

Il loader espone il gruppo modulo `terminal`. Il runtime completo `all` lo include automaticamente.

## Non-obiettivi

M6E/M6E.1 non introducono ancora applicazioni full-screen con cursor addressing, mouse terminale, layout engine o backend Gum/fzf obbligatori. Restano possibili estensioni post-v0.1, non requisiti della foundation.
