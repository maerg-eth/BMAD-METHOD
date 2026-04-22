# Audit-Ecosystem Workflow Checklist

Validates audit records produced by the `audit-ecosystem` workflow. Each check is evaluated against the written audit file at `{audit_output_folder}/audit-{YYYY-MM-DD}[-HHMMSS].md` — not against the in-memory workflow state. A failed check indicates either a workflow bug, a drift event between audit write and validation, or a misclassified audit state.

## Frontmatter Integrity

- [ ] Frontmatter block is present, opens with `---`, and closes with `---`.
- [ ] `date` field is present and is a valid ISO date (YYYY-MM-DD).
- [ ] `run_status` is exactly one of: `completed`, `aborted`. No other values permitted.
- [ ] `reconciliation` is exactly one of: `clean`, `drift`. No other values permitted.
- [ ] `findings_count` is a non-negative integer.
- [ ] `drift_count` is a non-negative integer.
- [ ] `agents_active` is a non-negative integer and matches the registry's active-status count at the time the audit was run.

## HALT / Completed State Consistency

- [ ] If `run_status: aborted`, then `reconciliation: drift` and `drift_count > 0`.
- [ ] If `run_status: aborted`, then `findings_count == drift_count` (no other findings produced when the audit halted at the reconciliation gate).
- [ ] If `run_status: aborted`, sections 2 through 10 except "Reconciliation" and "Summary & Prioritized Actions" and "Registry Updates" contain the exact placeholder text "[not run — audit aborted at reconciliation gate]".
- [ ] If `run_status: completed`, then `reconciliation: clean` and `drift_count == 0`.
- [ ] If `run_status: completed`, no section body contains the "[not run — audit aborted at reconciliation gate]" placeholder.
- [ ] The audit record exists on disk in both abort and completed cases — there is no path where the workflow exits without writing.

## Section Presence

- [ ] All ten top-level sections are present in order: Reconciliation, Agent-Vintage Signals, Scope Overlap — Jaccard (4a), Scope Overlap — LLM Judgment (4b), Scope Overlap — Joined View, Derived Surface Report, Registry-Quality Gaps, Orphan Scan, Summary & Prioritized Actions, Registry Updates.
- [ ] Section headings use exactly the form `# <Section Name>` as written above — capitalization and punctuation match.

## Step 4 — Axis Integrity

- [ ] If `agents_active >= 2` and `run_status: completed`: the set of `pair_id` values in the 4a table exactly equals the set in the 4b table. No pair appears in one table and not the other.
- [ ] Every `pair_id` uses the canonical form `{smaller_id}::{larger_id}` with alphabetical ordering (lexicographically smaller id first).
- [ ] No duplicate `pair_id` values exist within either table.
- [ ] If `agents_active <= 1`, sections 4a and 4b both contain the exact text "Skipped — N≤1" (or equivalent skipped-pair note) and the Joined View section is consistently marked skipped.
- [ ] If `agents_active >= 2` and `run_status: completed`: the Joined View section is present and contains one row per pair_id present in both 4a and 4b.

## Step 4 — Signal Independence

- [ ] The 4b rationale column contains no numerical scores, no reference to "Jaccard", "similarity", or any numeric value that could be read as a similarity metric.
- [ ] The 4b `judgment` column values are each exactly one of: `Yes`, `Partial`, `No`.

## Step 6 — Gap Classification Distinctness

- [ ] Gap 1 (eval-alignment / null success_rubric), Gap 2 (time-based staleness / last_reviewed > 90 days), and Gap 3 (edit-based staleness / git_last_touched > last_reviewed) are each surfaced as distinct flag types — not collapsed into a single "stale" category.
- [ ] Every Gap 3 entry cites both the `git_last_touched` timestamp and the `last_reviewed` timestamp so a reader can verify the comparison without re-running the audit.

## Step 7 — Orphan Scan Completeness

- [ ] The Orphan Scan section contains two subsections: Orphans and Dangling References. Both subsections are present (may be empty) — neither may be omitted.
- [ ] If `bmad/team-maerg/_data/lens-framework.md` is absent on disk, it is called out with top billing in the Dangling References subsection, with its specific expected-by explanation.
- [ ] The audit records in `bmad/team-maerg/_data/audits/` are NOT listed as orphans — they are valid outputs of this workflow.

## Step 8 — Severity Ordering

- [ ] The Summary & Prioritized Actions section presents findings in this exact severity order: drift, permission, overlap, eval, staleness, orphans. Sections for categories with zero findings may be omitted entirely — but any present category must appear in that relative order.
- [ ] Overlap disagreement (high Jaccard + No judgment, or low Jaccard + Yes/Partial judgment) is called out as its own named sub-finding within the overlap category.
- [ ] The `jaccard_score ≥ 0.25` threshold is annotated as provisional (explicit note in the section, not silently applied).

## Step 9 — Gap-3-Only Scoping

- [ ] The Registry Updates section contains entries ONLY for agents flagged with Gap 3 at step 6 — no entries exist for agents flagged solely under Gap 1 or Gap 2.
- [ ] Each Registry Updates entry records one of: updated, declined, or failed. No entry is left ambiguous.
- [ ] Any "updated" entry includes both the prior `last_reviewed` value and the new `last_reviewed` value so the change is auditable.
- [ ] Any "failed" entry explicitly states the failure reason (block anchor not unique, or verification mismatch).

## Step 10 — Completion Artifact

- [ ] If `run_status: completed`, the Joined View section is present when `agents_active >= 2` (this is the reviewer's artifact — missing it is a workflow bug, not a clean state).
- [ ] The final audit file path matches the workflow's canonical pattern: `bmad/team-maerg/_data/audits/audit-{YYYY-MM-DD}.md` or, for same-day re-runs, `audit-{YYYY-MM-DD}-{HHMMSS}.md`. No other filename patterns appear in the audits directory from this workflow.

## Final Validation

- [ ] Frontmatter Integrity — Issue list:
- [ ] HALT / Completed State Consistency — Issue list:
- [ ] Section Presence — Issue list:
- [ ] Step 4 Axis Integrity — Issue list:
- [ ] Step 4 Signal Independence — Issue list:
- [ ] Step 6 Gap Classification Distinctness — Issue list:
- [ ] Step 7 Orphan Scan Completeness — Issue list:
- [ ] Step 8 Severity Ordering — Issue list:
- [ ] Step 9 Gap-3-Only Scoping — Issue list:
- [ ] Step 10 Completion Artifact — Issue list:
