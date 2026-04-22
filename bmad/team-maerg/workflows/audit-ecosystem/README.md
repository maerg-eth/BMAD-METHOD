# audit-ecosystem

Ecosystem health check for Team Maerg. Action workflow — no document template, but emits a persisted audit record to `bmad/team-maerg/_data/audits/`.

## Purpose

Produce a time-stamped record of the state of the Team Maerg agent ecosystem across six dimensions:

1. **Reconciliation** — registry ↔ source YAML ↔ compiled MD ↔ Claude commands ↔ manifest CSV ↔ manifest YAML coherence. Drift-first HALT gate: on any mismatch, the audit aborts, writes a full drift record, and refuses to run the rest of the checks until the user fixes drift manually.
2. **Freshness and git-recency** — compiled-artifact staleness (mtime compare) and per-agent last-touched timestamps from `git log --follow`.
3. **Scope overlap** — dual-signal pairwise analysis: deterministic Jaccard over ≥4-char tokens of `scope_boundaries + purpose + principles`, plus an independent LLM Yes/Partial/No judgment on the same pair axis. Both full result sets persist; reviewer compares at step 8.
4. **Derived surface report** — per-agent reads/writes/invokes/tools derived from menu items, critical_actions, invoked workflows (cross-module), and workflow outputs. BMAD has no explicit permission declarations — inferred surface is the finding.
5. **Registry-quality gaps** — null `success_rubric`, time-based staleness (`last_reviewed` > 90 days old), and edit-based staleness (`git_last_touched` > `last_reviewed`, indicating the review predates the current implementation).
6. **Orphan scan** — bidirectional: files in `_data/` with zero active references, and agent-referenced paths that don't exist on disk. Explicit top-priority flag if `_data/lens-framework.md` is absent.

Dead-weight detection is deliberately deferred: no reliable invocation-telemetry source at time of authoring. Revisit when one exists.

## Invocation

From Chuck's menu:

```
*audit-ecosystem
```

Or directly:

```
workflow audit-ecosystem
```

## Expected inputs (read-only)

The workflow reads the following paths. None are user-provided at runtime — they are the ecosystem's own state.

| Source                | Path                                            | Role                                                                            |
| --------------------- | ----------------------------------------------- | ------------------------------------------------------------------------------- |
| Registry              | `bmad/team-maerg/_data/ecosystem-registry.yaml` | Source of truth (principle 6). Mutated only under the step-9 confirmation gate. |
| Agent YAML source     | `src/modules/team-maerg/agents/*.agent.yaml`    | Authoritative for principles, role, menu, critical_actions.                     |
| Agent compiled MD     | `bmad/team-maerg/agents/*.md`                   | Compiled artifact — freshness-compared against source.                          |
| Agent Claude commands | `.claude/commands/bmad/team-maerg/agents/*.md`  | Compiled artifact — freshness-compared against source.                          |
| Manifest CSV          | `bmad/_cfg/agent-manifest.csv`                  | Reconciliation cross-reference.                                                 |
| Manifest YAML         | `bmad/_cfg/manifest.yaml`                       | Reconciliation cross-reference.                                                 |
| Lens framework        | `bmad/team-maerg/_data/lens-framework.md`       | Referenced by Chuck's identity; absence is flagged.                             |
| Local workflows       | `bmad/team-maerg/workflows/`                    | Globbed for orphan detection (step 7 only).                                     |

Cross-module workflow paths discovered via agent menu items are also read (any `bmad/*/workflows/.../workflow.yaml` an agent invokes).

## Generated output

Single audit record written to:

```
bmad/team-maerg/_data/audits/audit-{YYYY-MM-DD}.md
```

Same-day re-runs append an `HHMMSS` suffix:

```
bmad/team-maerg/_data/audits/audit-{YYYY-MM-DD}-{HHMMSS}.md
```

Every audit record — completed or aborted — has identical section topology (10 sections). Aborted records contain drift findings in section 1 and `[not run — audit aborted at reconciliation gate]` placeholders for sections 2–8 and 10. This shape-stability is load-bearing for cross-audit trend analysis; the `checklist.md` verifies it.

Frontmatter schema:

```yaml
---
date: YYYY-MM-DD
run_status: completed | aborted
reconciliation: clean | drift
findings_count: <int>
drift_count: <int>
agents_active: <int>
---
```

## Side effects

The workflow mutates one file only: `bmad/team-maerg/_data/ecosystem-registry.yaml`, and only under the step-9 confirmation gate, and only for agents flagged with edit-based staleness (`git_last_touched > last_reviewed`). The user declines or approves per agent. Mutation is a single field per agent: `last_reviewed`. All writes use multi-line block anchoring on the agent's `id` line for uniqueness, with explicit verify-after-write and graceful failure (log and continue, never halt).

## Special requirements

- **Bash** — used for `mkdir -p` (step 1), `date +%H%M%S` (step 1 same-day suffix), and `git log --follow --format=%aI -1 -- <yaml>` (step 3 per-agent recency signal).
- **Write access** — `bmad/team-maerg/_data/audits/` (audit record) and `bmad/team-maerg/_data/ecosystem-registry.yaml` (conditional, step 9 only).
- **Runtime assumption** — executor is invoked from the project root so `{project-root}` resolves correctly.

## Instrumentation notes

Two parameters in the workflow are provisional — flagged in source, scheduled for recalibration when evidence exists:

- **Staleness threshold (90 days)** in step 6's Gap 2 — calendar-age heuristic. Recalibrate when edit-based staleness (Gap 3) data shows a divergence pattern.
- **Overlap surfacing threshold (jaccard_score ≥ 0.25)** in step 8 — set to surface candidates for reviewer inspection. Recalibrate from the Jaccard distribution at which LLM judgment agrees "Yes" or "Partial", once ≥10 audits with pair data exist.

The audit artifact itself is the calibration substrate — each completed record feeds future tuning.

## Dependencies

- `{project-root}/bmad/core/tasks/workflow.xml` — workflow execution engine.
- `{project-root}/bmad/team-maerg/config.yaml` — config source (user_name, communication_language, ecosystem_registry path).
- Chuck agent (`bmad/team-maerg/agents/chuck.md` and its source YAML) — primary invoker via `*audit-ecosystem`.
