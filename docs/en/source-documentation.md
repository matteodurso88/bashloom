# Source documentation standard

Bashloom treats source comments as part of the maintainability contract, not as incidental prose.

## Goals

Source documentation must make it possible to understand a public primitive without first reverse-engineering its implementation. Comments should explain the contract and the non-obvious engineering decisions around it.

For every public `blm_*` function, the source should document at least:

- the public API name;
- purpose;
- usage/signature;
- arguments when they are not self-evident;
- return/status semantics;
- stdout/stderr behavior when relevant;
- side effects;
- external dependencies when present;
- security, source-safety or portability constraints when relevant;
- important invariants or design rationale that are not obvious from the code.

The canonical marker is:

```bash
# Public API: blm_example
```

CI verifies that every public `blm_*` function has this marker near its definition.

## Internal helpers

Internal `_blm_*` functions do not require the machine-checkable public marker, but non-trivial helpers should still explain their purpose, assumptions and relationship to public behavior.

## What not to comment

Comments should not mechanically restate syntax. For example, comments such as “increment counter” or “assign variable” add little value. Prefer explaining why a counter exists, which invariant it represents, why a branch preserves an exit status, or why an external command is intentionally invoked only at call time.

## Language

Source comments are maintained in English, matching Bashloom's identifier and source-comment policy. Canonical user-facing explanatory documentation remains available in both English and Italian.

## Maintenance rule

A pull request that adds or materially changes a public API must update its source documentation in the same change. A public function without the required marker fails CI.
