---
type: agent-memory
maintained_by: Maerg (sovereign) — Atlas reads only
authority: Maerg-sovereign per Q12 invariant — Atlas writes only via *add / *edit / *done / *park / *received commands which surface change for Maerg's confirmation
last_updated: 2026-05-04
---

# Atlas Memories — Maerg-Sovereign State

> This file is **Maerg-sovereign**. Atlas reads it on every session start. Atlas never writes to it directly — all updates flow through Maerg-confirmed commands (`*add`, `*edit`, `*done`, `*park`, `*received`).
>
> Atlas's own autonomous writes live in `memories-autonomous-log.md`.

---

## Active Sprints

_Sprint state per §0b in instructions.md. States: Active / ⚠️ Stalled (3+ days no gate movement) / Shipping (gate met)._

| Sprint ID                                                                   | Initiative | State | Owner | Gate | Started | Last Update |
| --------------------------------------------------------------------------- | ---------- | ----- | ----- | ---- | ------- | ----------- |
| <!-- Atlas surfaces stall flags in *brief; Maerg confirms state changes --> |            |       |       |      |         |             |

---

## Active Tasks

_Tasks captured via `*add`. Format: T00X | description | priority | agent tag | status. Status = active unless Waiting on someone (then waiting)._

| ID                                                | Description | Priority | Agent | Status | Tag | Captured |
| ------------------------------------------------- | ----------- | -------- | ----- | ------ | --- | -------- |
| <!-- T001, T002, ... — increment from last ID --> |             |          |       |        |     |          |

---

## Waiting

_Tasks blocked on someone else. Format: T00X | description | waiting on [Person] | what's expected | since._

| ID                                                          | Description | Waiting on | Expected | Since |
| ----------------------------------------------------------- | ----------- | ---------- | -------- | ----- |
| <!-- Atlas surfaces in *brief WAITING ON OTHERS section --> |             |            |          |       |

---

## Parked

_Tasks deprioritized. Format: T00X | description | reason | parked date._

| ID                                                                | Description | Reason | Parked |
| ----------------------------------------------------------------- | ----------- | ------ | ------ |
| <!-- Moved here via *park; surface in *backlog Parked section --> |             |        |        |

---

## Recently Completed

_Last 30 days of completed tasks. Older items prune to a separate archive on `*reflect` month-end synthesis if needed._

| ID                                          | Description | Completed | Notes |
| ------------------------------------------- | ----------- | --------- | ----- |
| <!-- Moved here via *done; date-stamped --> |             |           |       |

---

## Weekly Review Log

_Friday `*weekly-review` entries. Format: [Date] | Delivered: X/Y | Slips: [names] | Pattern: [one line if any]. Mid-week `*received` entries also append here._

| Date                                                     | Type | Notes |
| -------------------------------------------------------- | ---- | ----- |
| <!-- Friday review entries + mid-week *received logs --> |      |       |

**Mid-week deliverable log** (per `*received`):

```
[Day] | ✓ [Name] — [Deliverable] — received
```

---

## Session History

_One entry per session. Format: ## [Date] — what we worked on, decisions made, tomorrow's #1, captured tasks._

<!-- Atlas appends a section per session via Maerg-confirmed save on *exit -->

---

## Cross-references

- `instructions.md` — operating rules per command
- `memories-autonomous-log.md` — Atlas-only autonomous writes (Pearls, scan observations, dispatch log)
- `knowledge/cos-frameworks.md` — Atlas's CoS methodology library
- `knowledge/relationship-tracker.md` — relationship heat map

---

_Created: 2026-05-04 (Atlas v2 fresh template). Maerg-sovereign — Atlas reads, never writes directly._
