# Terminal UX

M6E aggiunge primitive terminal UX leggere senza trasformare Bashloom in un framework TUI full-screen.

## Obiettivi

- comportamento deterministico in CI e pipe;
- nessuna risposta inventata per i prompt interattivi;
- rendering stabile human/plain/JSON;
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

Queste primitive restano volutamente line-oriented. La modalità human aggiunge struttura minima, plain resta deterministica e JSON emette record machine-readable.

## API progress

- `blm_progress <current> <total> [label]`
- `blm_spinner <label> <command> [args...]`

`blm_progress` usa aggiornamenti tramite carriage return solo su terminale human interattivo. Negli altri casi ogni chiamata emette una riga completa stabile oppure un record JSON.

`blm_spinner` anima soltanto su terminale human interattivo. In contesti non interattivi/plain/JSON degrada a normali record di lifecycle e preserva sempre lo status del comando wrapped.

## Caricamento selettivo

Il loader espone il gruppo modulo `terminal`. Il runtime completo `all` lo include automaticamente.

## Non-obiettivi

M6E non introduce widget full-screen con cursor addressing, mouse terminale, layout engine ricchi, backend esterni Gum/fzf o decorazioni Unicode avanzate. Questi elementi potranno essere valutati dopo la stabilizzazione della foundation v0.1.