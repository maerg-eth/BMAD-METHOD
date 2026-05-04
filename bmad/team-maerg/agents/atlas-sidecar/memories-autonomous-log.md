---
type: agent-memory
maintained_by: Atlas 🪶 (append-only, autonomous)
authority: Atlas-write-only per Q7 lock — Maerg never edits this file
last_updated: 2026-05-04
---

# Atlas Autonomous Log

> Atlas's own write surface. Append-only by Atlas; never edited by Maerg.
> Each entry carries frontmatter provenance: `source` + `timestamp` + `agent: atlas`.
> Subject-axis subsections (per Letta-canonical pattern + Q7 lock).

---

## scan-observations

_Proactive horizon scans per Framework 008. Atlas appends entries when session-start scan or \*brief layer scan surfaces something noteworthy. Phase 2 expansion: autonomous Slack/calendar/doc deltas log here when monitoring integration ships._

## <!-- Format:

source: scan
timestamp: 2026-05-04T10:00:00Z
agent: atlas

---

[1-2 line observation: what was scanned, what was flagged, link to action if any]
-->

---

## dispatch-log

_Agent handoffs Atlas has produced via Agent Handoff Protocol (system-agnostic per Q5 lock). Phase 2 expansion: when \*dispatch command ships with San v2, file-based handoffs land in atlas-sidecar/dispatched/{task-id}.md and get logged here._

## <!-- Format:

source: dispatch
timestamp: 2026-05-04T10:00:00Z
agent: atlas
target: san | vox | chuck | ...
task_id: T042

---

HANDOFF → [Agent]: [task summary]. Maerg-confirmed: y/n. Output expected: [what comes back].
-->

---

## revealed-preferences

_Pearls of Learnings — Maerg's revealed preferences captured from corrections, explicit preferences, repeated frustrations. Threshold: corrections + explicit preferences only, NOT every utterance. Pearls feed \*reflect, briefs, routing decisions._
_Promote to standalone `pearls.md` only when ≥10 entries accumulate._
_Pearls >90 days flagged for relevance review during \*reflect._

## <!-- Format:

source: revealed-preference
timestamp: 2026-05-04T10:00:00Z
agent: atlas

---

[date] | Trigger: <what context surfaced this> | Maerg: '<his actual phrasing>' | Rule: <Atlas's read of the rule>
-->

---

## between-session-prework

_Anything Atlas observed or did between Maerg sessions. Phase 2 expansion: autonomous monitoring + cross-medium ask responses log here. Today: Maerg-narrated cross-agent context (per "Cross-agent visibility" floor protocol in instructions.md) lands here when Maerg shares non-Atlas session content._

## <!-- Format:

source: between-session-prework
timestamp: 2026-05-04T10:00:00Z
agent: atlas

---

[1-2 line observation: what happened between sessions, source: Maerg-narrated | scan | future-monitoring]
-->

---

## first-run-calibration

_Atlas's own runtime calibration data — empty-state baselines, recalibration triggers, deferral records, lane-integrity notes for future-me. Not Pearls (those are Maerg-correction-driven). Not scan-observations (those are horizon flags). Owned by Atlas, append-only._

---

source: first-run-calibration
timestamp: 2026-05-04T15:00:00Z
agent: atlas

---

2026-05-04 | First operational session of Atlas v2 sidecar (fresh state + refined architecture per ADR a3d09ad8: Q5 Handoff Protocol, Q7 memory split, Q8 predict drop, Q12 write-invariant).

Baseline: 0 task captures confirmed, 0 briefs issued, 0 Pearls captured, 0 sessions logged. T001 (test) drafted, unconfirmed.

Standing gap (carried from v1→v2 ledger): cross-agent visibility — invisible non-Atlas-session state lags until Maerg narrates back. Deferred to Tier-A *architecture-decision at San v2 spawn per project_team_session_sync_convention memory; do NOT re-fire *research on it.

Calibration recommendation: defer operational *reflect cadence to first full operational week (≥5 briefs, ≥3 Pearls confirmed). 0/0/0 input → theatre output; logging it would pollute the cos-frameworks Reflection Log baseline future reflects compare against. *reflect held this session per Maerg-confirmed Option 1.

Lane integrity (recorded for future-me reference): build-retrospective on Atlas v2 spawn (6 build-session observations, architecture decisions, build patterns) is Chuck's lane → ADR a3d09ad8 with explicit bmb-observed provenance + Chuck feedback memories. Not Atlas's runtime-calibration concern per team-principle 7.

---

## Archive

_When this file grows unbounded (per Letta-canonical archival tier guideline), older entries rotate to `memories-autonomous-log-archive/YYYY-MM.md`. Rotation logic deferred to Tier-C reactive trigger (per scalability roadmap ADR) — when retrieval pain materializes._

---

## Cross-references

- `instructions.md` §0 (Pearls capture rule, \*exit Pearls flush) and §digest (autonomous-log surfaced in digest)
- `_data/recommendation-discipline.md` — Pearls feed every recommendation surface
- `cos-frameworks.md` Framework 008 (Proactive Scan) — scan-observations log here
- `memories.md` — Maerg-sovereign state (separate authority)

---

_Created: 2026-05-04 (Atlas v2 fresh autonomous-log per Q7 lock). Atlas-append-only, never user-edited._
