# Terminal UX

Bashloom's v0.1 RC terminal layer provides both line-oriented rendering and a dependency-free full-screen TUI foundation while preserving deterministic behavior in CI, pipes and non-interactive execution.

## Goals

- deterministic behavior in CI and pipes;
- no hidden answers for interactive prompts;
- stable human/plain/JSON rendering;
- multiple reusable visual styles without API proliferation;
- width-aware Unicode layout with deterministic fallback;
- explicit full-screen TUI lifecycle without source-time side effects;
- no mandatory third-party UI dependency;
- exact wrapped command status preservation.

## Prompt APIs

- `blm_prompt <message> [default]`
- `blm_confirm <message> [yes|no]`
- `blm_password <message>`
- `blm_select <message> [--default N] -- <option> [option...]`

Explicit defaults may be used when stdin is non-interactive. Without a default, prompt/select helpers fail instead of inventing input. `blm_password` always requires interactive stdin.

## Theme and style registry

`BLM_UI_THEME` selects a coherent preset:

- `default`
- `modern`
- `minimal`
- `ascii`
- `ci`

`blm_ui_theme` reports the validated active theme. `blm_ui_style <component>` reports the resolved style for `spinner`, `progress`, `panel`, `table`, or `tree`.

Component-level environment overrides are supported:

```bash
BLM_SPINNER_STYLE=pulse
BLM_PROGRESS_STYLE=dots
BLM_PANEL_STYLE=double
BLM_TABLE_STYLE=compact
BLM_TREE_STYLE=ascii
```

Per-call overrides take precedence where supported:

```bash
blm_spinner --style dots "Deploy" command ...
blm_progress --style thin 3 10 "Uploading"
blm_panel --style double "Runtime" "ready"
blm_table --style compact $'Name\tState'
blm_tree --style ascii 1 child
```

`BLM_UI_STYLE=rich|minimal` remains the high-level density switch. Invalid themes/styles return status `2` rather than silently degrading.

## Rendering APIs

- `blm_panel [--style rounded|square|double|minimal|ascii] <title> [line...]`
- `blm_table [--style unicode|ascii|compact|minimal] <row> [row...]`
- `blm_tree [--style unicode|ascii|minimal] <depth> <label>`
- `blm_tree_view [--style unicode|ascii|minimal] <tab-indented-line> [line...]`

`blm_tree` remains the compatibility-oriented single-row helper. Because one row cannot know future siblings, it cannot infer last-child topology.

`blm_tree_view` accepts a complete tree as lines whose leading TAB characters declare depth. It infers sibling topology and can render `├─`, `└─`, and continuation branches, with ASCII and minimal fallbacks.

Example:

```bash
blm_tree_view \
  "Bashloom" \
  $'\tcore' \
  $'\tui' \
  $'\t\tterminal' \
  $'\t\ttui'
```

## Display width

`blm_display_width <text>` reports terminal display width in cells.

Bash itself has no native `wcwidth` primitive. When `python3` is available, Bashloom uses Python's standard `unicodedata` module to account for combining characters and East Asian wide/full-width code points. Otherwise it falls back to deterministic Bash character count. ASCII/minimal environments therefore remain dependency-free.

Panel and table layout use display width rather than raw Bash string length.

## Progress APIs

- `blm_progress [--style blocks|bar|thin|dots|percent] <current> <total> [label]`
- `blm_spinner [--style braille|line|dots|pulse] <label> <command> [args...]`

`BLM_PROGRESS_WIDTH` controls visual bar width and defaults to 24 cells.

All valid intermediate progress renders return status `0`, making the API safe under caller `set -e`. `blm_spinner` preserves the exact wrapped command status.

Plain/JSON/non-TTY execution remains line-oriented and deterministic regardless of the selected visual style.

## Character-set policy

`BLM_UI_CHARSET` accepts:

- `auto` (default): Unicode when the active locale advertises UTF-8;
- `unicode`: request Unicode glyphs;
- `ascii`: force portable ASCII rendering.

The `ascii` and `ci` themes force effective ASCII presentation. Bashloom does not assume emoji-font availability; rich presentation uses terminal symbols, blocks and box-drawing glyphs rather than emoji.

## Full-screen TUI foundation

Public APIs:

- `blm_tui_available`
- `blm_tui_enter`
- `blm_tui_leave`
- `blm_tui_clear`
- `blm_tui_move <row> <column>`
- `blm_tui_size`
- `blm_tui_read_key [timeout-seconds]`
- `blm_tui_run <command> [args...]`

The TUI layer uses the alternate screen and explicit cursor control only when human output is attached to a suitable TTY. It refuses non-interactive/`TERM=dumb` execution instead of emitting control sequences into logs.

`blm_tui_run` is the preferred lifecycle wrapper: it enters the alternate screen, executes the command, always restores the cursor/screen, and returns the exact wrapped command status.

No trap is installed automatically. This preserves Bashloom's source-safety contract and avoids overwriting caller trap policy.

`blm_tui_size` is resize-aware by resolving dimensions each time it is called. Explicit `BLM_TUI_COLUMNS`/`BLM_TUI_LINES` overrides are available for tests. It otherwise uses `COLUMNS`/`LINES`, optional `tput`, and finally deterministic `80x24` fallback values.

`blm_tui_read_key` normalizes common keyboard events such as arrows, HOME/END, ESC, ENTER, TAB and BACKSPACE.

## Demonstrations

`examples/10-terminal-ux.sh` remains CI-safe. `examples/11-rich-terminal.sh` is the visual terminal showcase and is expanded during the RC cycle to cover themes, variants, topology-aware trees and the TUI foundation.

## Selective loading

The `terminal` loader group contains prompts, theme registry, width-aware rendering, progress/spinners and the TUI foundation. `all` includes `terminal` automatically.

## External backends

Gum, fzf or similar tools are not mandatory dependencies. They may be integrated later as optional backends, but the v0.1 RC terminal surface remains usable with Bash plus feature-specific standard utilities only.
