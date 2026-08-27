# M6F — Production Validation

M6F validates Bashloom against real consumer workflows before `v0.1.0`. The purpose is not to force consumers to adopt Bashloom wholesale; it is to discover API, reliability and operability defects that unit/integration tests cannot expose.

## Ownership boundary

Consumer repositories retain full ownership of their runtime, deployment, rollback and release procedures.

Bashloom maintainers may:

- propose a low-risk integration boundary;
- provide pinned consumption instructions;
- define validation criteria;
- review feedback and reproduce defects in the Bashloom repository.

Bashloom maintainers must not independently merge or deploy changes in a consumer repository unless that repository's normal ownership workflow explicitly authorizes it.

## Candidate consumers

### Oriqo Infrastructure

Repository: `oriqoproject/oriqo-infrastructure`

Status: candidate real deployment consumer.

A draft integration proposal exists in the consumer repository for OR/DEV review. Oriqo OR/DEV remain responsible for deciding whether, where and how Bashloom is adopted in that repository.

The current validation pin is:

```text
b6a096ba1feb31f41a639856b29ae07e25ba3676
```

## Validation protocol

For each consumer integration:

1. Pick one representative, low-blast-radius workflow.
2. Pin Bashloom to an exact commit or release.
3. Preserve the consumer's existing behavior, exit codes and rollback policy.
4. Prefer opt-in adoption for the first validation pass.
5. Exercise the same workflow both with and without Bashloom where practical.
6. Run the consumer's native CI/static checks.
7. Run the consumer's normal staging or test procedure under its own ownership process.
8. Record every Bashloom defect or missing primitive in the Bashloom repository.
9. Fix library defects in Bashloom rather than adding consumer-specific compensation unless the workaround is itself a legitimate consumer policy.
10. Re-pin or upgrade only after the Bashloom fix is merged and validated.

## Feedback contract

Consumer maintainers should report findings to `matteodurso88/bashloom` as issues or pull requests.

A useful report includes:

- Bashloom commit/release used;
- consumer repository and workflow;
- exact command or API involved;
- expected behavior;
- observed behavior;
- exit status and relevant stdout/stderr;
- whether `set -e`, traps, pipelines, CI or non-TTY execution were involved;
- minimal reproduction when available;
- whether the finding is a bug, missing capability, usability issue or performance/operability improvement.

When a consumer discovers a possible improvement rather than a defect, it should still be reported upstream. The Bashloom repository is the source of truth for deciding whether that improvement belongs in the generic library, in a future milestone, or only in the consumer.

## M6F exit criteria

Before `v0.1.0`, Bashloom should have evidence for:

- at least one real deployment workflow;
- one desktop/installer-style workflow;
- one system/provisioning workflow;
- feedback-driven review of unstable APIs;
- no known critical source-safety, exit-status or rollback regressions in validated consumers.

Cross-distribution, macOS and WSL manual matrices remain deferred until those environments can be validated directly.
