---
type: agent-memory
maintained_by: Maerg (sovereign) — Lyra reads only
authority: Maerg-sovereign per Q12 invariant — Lyra writes only via *accept / *reject / *post-event-reflect / *capture-preference / *edit-preference / *add-source commands which surface change for Maerg's confirmation
last_updated: 2026-05-05
---

# Lyra Memories — Maerg-Sovereign State

> This file is **Maerg-sovereign**. Lyra reads it on every session start. Lyra never writes to it directly — all updates flow through Maerg-confirmed commands.
>
> Lyra's own autonomous writes live in `memories-autonomous-log.md`.

---

## Active Plans

_Weekly plans per §0b in instructions.md. States: Active (generated, awaiting review) / Reviewed (≥1 slot decided, cycle in progress) / Closed (week ended, captured)._

| Plan ID                                                                         | Week of | State | Slots Total | Slots Decided | Generated |
| ------------------------------------------------------------------------------- | ------- | ----- | ----------- | ------------- | --------- |
| <!-- Lyra surfaces plan-state in *plan-status; Maerg confirms state changes --> |         |       |             |               |           |

---

## Recommendations Decided

_Lyra-generated recommendations with Maerg's accept/reject decisions. Format: REC00X | description | category | slot | status (accepted/rejected) | reason (if rejected) | decided-date._

| Rec ID                                                                                 | Description | Category | Slot | Status | Reason | Decided |
| -------------------------------------------------------------------------------------- | ----------- | -------- | ---- | ------ | ------ | ------- |
| <!-- REC001, REC002, ... — appended via *accept / *reject (via Maerg confirmation) --> |             |          |      |        |        |         |

---

## Post-Event Reflections

_Captured via `*post-event-reflect`. Format: REC-id | event | overall (loved/fine/wouldn't-repeat) | what-worked | what-didn't | venue-revisit (yes/no/conditional) | reflection-date._

| Rec ID                                                             | Event | Overall | What Worked | What Didn't | Revisit | Reflected |
| ------------------------------------------------------------------ | ----- | ------- | ----------- | ----------- | ------- | --------- |
| <!-- Appended via *post-event-reflect (via Maerg confirmation) --> |       |         |             |             |         |           |

---

## Cross-Cycle Notes (Maerg-stated context)

_Maerg-narrated context that affects future cycles — emerging interests, dormant categories, life events that shift availability. Format: [Date] | [context]._

| Date                                                  | Context |
| ----------------------------------------------------- | ------- |
| <!-- Maerg shares; Lyra appends with confirmation --> |         |

---

## Session History

_One entry per session. Format: ## [Date] — what we worked on, plans generated/reviewed, preferences updated, reflections captured._

<!-- Lyra appends a section per session via Maerg-confirmed save on *exit -->

---

## Cross-references

- `instructions.md` — operating rules per command
- `memories-autonomous-log.md` — Lyra-only autonomous writes (drift-signals, fetch-failures, cross-cycle-notes from Lyra observation)
- `preferences.yaml` — preference model (Lyra-write via Q12-mirror gate)
- `weekly-plans/YYYY-MM.md` — INTENDED vs DELIVERED per cycle
- `knowledge/recommendation-frameworks.md` — Lyra's methodology library
- `knowledge/discovery-sources.yaml` — curated source URLs

---

_Created: 2026-05-05 (Lyra v1 fresh template). Maerg-sovereign — Lyra reads, never writes directly._
