# Terminal UX

M6E adds lightweight terminal UX primitives without turning Bashloom into a full-screen TUI framework.

## Goals

- deterministic behavior in CI and pipes;
- no hidden answers for interactive prompts;
- stable human/plain/JSON rendering;
- no mandatory third-party UI dependency;
- exact wrapped command status preservation.

## Prompt APIs

- `blm_prompt <message> [default]`
- `blm_confirm <message> [yes|no]`
- `blm_password <message>`
- `blm_select <message> [--default N] -- <option> [option...]`

`blm_prompt`, `blm_confirm`, and `blm_select` may use explicit defaults when stdin is non-interactive. Without a default they fail instead of inventing input. `blm_password` always requires an interactive stdin and uses Bash `read -s` so input is not echoed. `blm_select` returns the selected option value, while the menu is rendered to stderr.

## Rendering APIs

- `blm_panel <title> [line...]`
- `blm_table <row> [row...]`
- `blm_tree <depth> <label>`

These primitives are intentionally line-oriented. Human mode adds minimal structure, plain mode stays deterministic, and JSON emits machine-readable records.

## Progress APIs

- `blm_progress <current> <total> [label]`
- `blm_spinner <label> <command> [args...]`

`blm_progress` uses carriage-return updates only on an interactive human terminal. Otherwise every call emits a stable full line or JSON record.

`blm_spinner` animates only on an interactive human terminal. In non-interactive/plain/JSON contexts it degrades to ordinary lifecycle status records and always preserves the wrapped command status.

## Selective loading

The loader exposes a `terminal` module group. The complete `all` runtime includes it automatically.

## Non-goals

M6E does not provide full-screen cursor-addressed widgets, terminal mouse handling, rich layout engines, external Gum/fzf backends, or advanced Unicode decoration. Those can be evaluated after the v0.1 foundation proves stable.