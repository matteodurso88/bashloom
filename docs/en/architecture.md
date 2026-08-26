# Architecture

Bashloom is designed as a modular runtime library that can be sourced as a whole or by selected modules.

## Layers

```text
Bashloom
├── core          terminal/runtime capabilities and shared primitives
├── ui            human-facing terminal output
├── ops           execution, retry, wait, cleanup and reliability helpers
├── system        filesystem, paths, permissions, XDG and platform helpers
└── integrations  optional adapters for external tools
```

## Architectural rules

### Core

The core must remain dependency-free except for Bash itself. It must not require `gum`, `fzf`, `jq`, Python, Node.js or platform-specific package managers.

### Source safety

Sourcing Bashloom must not silently enable `set -e`, `set -u`, `pipefail`, replace caller traps or mutate `IFS`. If strict mode helpers are ever provided, they must be explicit opt-in APIs.

### Public namespace

- `blm_*`: public functions
- `_blm_*`: internal functions
- `BLM_*`: public configuration variables
- `_BLM_*`: internal state

### Optional capabilities

External tools may improve behavior, but their absence must not break unrelated core features. Enhanced backends should be discovered through capability checks and degrade deterministically.

### Output and execution separation

UI rendering and command execution are separate concerns. A pretty wrapper around a command must preserve the wrapped command's exit status and must not convert failures into success.

### Compatibility

Initial target:

- Bash >= 4.3
- Linux: first-class
- WSL: supported target
- macOS: best effort during early releases
- POSIX `sh` and BusyBox `ash`: explicitly out of scope

## Module loading

The intended long-term model supports:

1. full runtime loading;
2. selective module sourcing;
3. generated/vendorable bundles containing only requested modules.

The bundler is not part of v0.1, but the source tree must not prevent it.
