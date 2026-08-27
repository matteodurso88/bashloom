# Terminal UX

M6E provides lightweight terminal UX primitives without turning Bashloom into a full-screen TUI framework. M6E.1 adds a richer human-terminal rendering layer while preserving deterministic fallbacks for CI, pipes and machine output.

## Goals

- deterministic behavior in CI and pipes;
- no hidden answers for interactive prompts;
- stable human/plain/JSON rendering;
- visibly richer output on real terminals;
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

Human TTY mode now renders auto-sized panels, aligned tab-delimited tables and branch-marked trees. Plain mode remains deterministic and JSON remains machine-readable.

## Progress APIs

- `blm_progress <current> <total> [label]`
- `blm_spinner <label> <command> [args...]`

On a real human TTY, `blm_progress` renders a fixed-width visual bar such as:

```text
[████████████░░░░░░░░░░░░]  50%  Building release
```

`BLM_PROGRESS_WIDTH` controls bar width and defaults to 24 cells.

`blm_spinner` uses an animated Unicode spinner where available and a classic ASCII spinner otherwise. It still preserves the exact wrapped command status. In non-interactive/plain/JSON contexts it degrades to stable lifecycle records.

## Character-set and style policy

`BLM_UI_CHARSET` accepts:

- `auto` (default): Unicode when the active locale advertises UTF-8, otherwise ASCII;
- `unicode`: force Unicode terminal glyphs;
- `ascii`: force portable ASCII rendering.

`BLM_UI_STYLE` accepts `rich` (default) or `minimal`. Rich rendering is only used for human output attached to a terminal. Plain/JSON output never depends on terminal glyph capabilities.

This avoids assuming emoji-font availability: rich rendering uses ordinary terminal Unicode symbols and block/box glyphs, not emoji.

## Demonstrations

`examples/10-terminal-ux.sh` remains the CI-safe foundation example. `examples/11-rich-terminal.sh` is the visual showcase intended to be run manually in a real terminal:

```bash
bash examples/11-rich-terminal.sh
```

When stdout is a real TTY it demonstrates the animated spinner, progress bar, aligned table, rich panel and tree rendering. When piped or executed in CI, the same script remains non-blocking and deterministic.

## Selective loading

The loader exposes a `terminal` module group. The complete `all` runtime includes it automatically.

## Non-goals

M6E/M6E.1 still do not provide full-screen cursor-addressed applications, terminal mouse handling, a layout engine, or mandatory Gum/fzf backends. Those remain possible post-v0.1 extensions rather than foundation requirements.
