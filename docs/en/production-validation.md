# M6F — Production Validation

M6F validates Bashloom against real consumer workflows before `v0.1.0`. The purpose is to discover API, reliability and operability defects that unit/integration tests cannot expose, while preserving each consumer repository's ownership and deployment policy.

## Ownership boundary

Consumer repositories retain full ownership of their runtime, deployment, rollback and release procedures.

Bashloom maintainers may:

- propose a low-risk integration boundary;
- provide pinned consumption instructions;
- define validation criteria;
- review feedback and reproduce defects in the Bashloom repository.

Bashloom maintainers must not independently merge or deploy changes in a consumer repository unless that repository's normal ownership workflow explicitly authorizes it.

## Consumer evidence

### Oriqo Infrastructure — historical M6F deployment validation

Repository: `oriqoproject/oriqo-infrastructure`

Status: **PASS**.

Oriqo Infrastructure completed the first real deployment validation through the consumer owner's staging workflow. The historical validation evidence is tracked in Bashloom issue `#16` and the corresponding completed Oriqo Infrastructure consumer tracker.

Historical validation pin:

```text
b6a096ba1feb31f41a639856b29ae07e25ba3676
```

This pin is evidence for the completed M6F deployment validation and is not the current repository-wide adoption target.

### Current RC multi-consumer adoption baseline

The current common validation/adoption target is:

```text
release: v0.1.0-rc1
commit: bbbbd9b8e61c7d951b8b9fc8f00c351b50a1bf51
```

The RC campaign expands beyond the historical single-workflow M6F evidence and validates Bashloom across full Bash surfaces in multiple real consumer repositories. That campaign is tracked separately from the already completed Oriqo deployment PASS.

## Validation protocol

For each consumer integration:

1. Pick one representative workflow or Bash surface with a clear validation purpose.
2. Pin Bashloom to an exact commit or release.
3. Preserve the consumer's existing behavior, exit codes and rollback policy.
4. Use the consumer repository's normal ownership and review workflow.
5. Exercise equivalent pre/post-migration behavior where practical.
6. Run the consumer's native CI/static checks.
7. Run the consumer's normal staging, test or device procedure under its own ownership process.
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

Documentation drift discovered by consumers is also a valid upstream finding when canonical roadmap, release notes and recorded validation evidence disagree.

## Current M6F / RC state

Completed evidence:

- [x] field-validation ownership and feedback protocol defined;
- [x] at least one real deployment workflow validated — Oriqo Infrastructure staging PASS;
- [x] first public RC baseline published as `v0.1.0-rc1`.

Still required before stable `v0.1.0`:

- [ ] desktop/installer-style workflow evidence;
- [ ] system/provisioning workflow evidence;
- [ ] broader multi-consumer RC validation sufficient to exercise core/runtime, reliability, filesystem/idempotency, integrations and terminal UX;
- [ ] evidence-driven review/fixes for any unstable behavior found in consumers;
- [ ] no known blocker-class source-safety, exit-status or rollback regressions.

Cross-distribution, macOS and WSL manual matrices remain deferred until those environments can be validated directly.
