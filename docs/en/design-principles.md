# Design Principles

Bashloom exists to make Bash scripts easier to trust, read, operate and contribute to.

## 1. Reliability before decoration

Terminal UX is valuable only when it preserves execution semantics. Status rendering, spinners and progress indicators must never swallow or rewrite the exit status of the operation they represent.

## 2. Dependency-free core

Bash is the only mandatory runtime dependency. Optional tools may enhance specific capabilities, but core behavior must remain useful without them.

## 3. Explicit over implicit

Bashloom does not silently enable strict mode, replace traps, modify `IFS`, escalate privileges or mutate unrelated caller state.

## 4. Small public surface

The public API should grow slowly. A function belongs in the core only when it solves a general recurring problem and can be specified, tested and documented clearly.

## 5. Graceful degradation

Terminal features must behave correctly under TTY and non-TTY output, pipes, CI, `TERM=dumb`, `NO_COLOR` and limited Unicode environments.

## 6. Operational composition

The library should make it straightforward to build preflight checks, command steps, retry loops, wait conditions, cleanup stacks and rollback-oriented workflows from small primitives.

## 7. Security-aware shell code

Quoting, temporary files, permissions, environment parsing, logging and destructive operations are treated as security-sensitive areas.

## 8. Documentation parity

Public behavior is documented in English and Italian. Documentation changes are part of implementation work, not a follow-up task.

## 9. Contributor readability

Code comments explain intent, invariants and shell-specific edge cases. Clever shell tricks are avoided when a clearer implementation is available.

## 10. Italian origin, international scope

Bashloom is an Italian open-source project. Its origin is part of its identity, while its technical language and contribution model are intentionally international.
