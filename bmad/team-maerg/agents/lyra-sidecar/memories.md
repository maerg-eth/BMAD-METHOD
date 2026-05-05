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

| Rec ID | Description                                                                                    | Category | Slot           | Status           | Reason                                                                      | Decided    |
| ------ | ---------------------------------------------------------------------------------------------- | -------- | -------------- | ---------------- | --------------------------------------------------------------------------- | ---------- |
| REC001 | Gaybubet Şehri at Kumbaracı50 — theatre, Fri 2026-05-08 20:30, Beyoğlu (Lyra `*find` cycle #1) | theatre  | theatre-friday | tentative-accept | Placeholder; final go/no-go on Thursday 2026-05-07 (calendar nudge created) | 2026-05-05 |

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

### 2026-05-05 — V1 first-run bootstrap

**Work:**

- Cold-start sidecar bootstrap (0 signals → operational state)
- Maps Takeout ingestion: 6 reviews + 1 saved place + 2 labelled places → `restaurants` seed
- Schema revision: 8 placeholder categories → 14 Maerg-specific (split `film_theater`, renamed `jazz` → `live_music`, removed generic `events`, added `opera` / `dancing_events` / `wine_tasting` / `city_visits` / `workshops` / `classes`)
- 5 Istanbul discovery sources added (Istanbul Modern, Nardis Jazz, kultur.istanbul, Zorlu PSM, Biletinial — under regions.istanbul with multi-category aggregators flagged via `covers:`)
- First `*find` cycle: theatre Friday Beyoğlu late evening
  - **REC001 = Gaybubet Şehri at Kumbaracı50, 20:30** (tentative-accept; final decision Thursday 2026-05-07)
  - Verification-needed: Pera'da Bir Lola at Paribu Art – Yan Sahne (venue uncertain — DasDas main site lists Ataşehir Watergarden ~12 km Asian side; date listed as May 5 not May 8 in plumemag)
  - Honest gap report: 4/5 curated aggregators returned JS-shells (kultur.istanbul, biletinial.com, dasdas.com.tr, presumed zorlupsm.com); only static-HTML sources delivered usable signal (kumbaracı50.com, tiyatrolar.com.tr, plumemag, oggusto, sehirtiyatrolari.ibb.istanbul/takvim)
- HTML rendering of `*find` output written to `output/` (gitignored) — tactical bridge per Maerg's "different medium" request before strategic Telegram-bot frontend lands
- Two architecture handoffs queued for Chuck:
  - `_data/handoffs/2026-05-05-lyra-fetch-architecture.md` — V2 fetch protocol (option space: headless browser / canonical APIs / MCP scrape / LLM-with-browse / manual paste / hybrid)
  - `_data/handoffs/2026-05-05-lyra-frontend-architecture.md` — chat-first UX (Telegram lean) + 6 sub-decisions (platform, hosting, brain integration, state concurrency, auth, cross-agent scope) — **expanded mid-session** to cover routine-wiring gap (`event-proximity-check` + `weekly-plan-generation` registered but unwired) per Maerg's "how are you going to remind me?" framing; same hosting decision ratifies all three

**Preference state (post-session):**

- `restaurants`: score 7 (provisional — Maps reviews capture loved-it ceiling), 6 liked examples (Cairo / Istanbul / Bangkok / Kyoto / Berlin × 2), notes: atmosphere non-negotiable, insider-craft loop, wide price tolerance, international palate
- Active-null (interest declared 2026-05-05, awaits first signal): `live_music`, `theatre`, `film` (old-school cinemas as strong sub-pref), `opera`, `museums`, `dancing_events`, `wine_tasting`, `city_visits`, `workshops`, `classes`
- Dormant-null (kept open in case drift-signal surfaces): `social`, `comedy`, `outdoor`

**Calendar:**

- REC001 placeholder render URL generated (Fri 2026-05-08 20:30, Europe/Istanbul) — pending Maerg's Save click in Calendar's render form
- Thursday 2026-05-07 09:00–09:15 decision-nudge render URL generated — pending Maerg's Save click

**Validations for future cycles (incident-anchored, per principle 5):**

- L1 + L2 + L5 held under cold-start pressure: `*find` delivered 1 confirmed + 1 verification-needed (gaps named) instead of fabricating 3 confident options
- L3 calendar-write invariant held cleanly: explicit accept → confirmation gate (Lyra-side y/n) → render-URL surface → user-side Save click in Calendar UI = double confirmation
- Schema-grows mechanism worked as designed: V1 placeholder schema replaced with Maerg-specific 14-category schema on first-run interest declaration
- Discovery brittleness materialized first cycle (JS-shell aggregators) — validates Q6 lock to ship V1 with manual-paste fallback rather than waiting for V2 APIs
- Q12-mirror gate held: every preference and memories mutation surfaced for y/n before write

**Open threads carried over:**

- REC001 final decision: Thursday 2026-05-07 (Google Calendar nudge fires at 09:00; Lyra is NOT autonomous in V1 — requires manual `/bmad:team-maerg:agents:lyra` invocation if Lyra's voice is wanted on the decision)
- Two architecture handoffs awaiting Chuck `*architecture-decision` invocation
- Six newly-found discovery URLs from this `*find` (kumbaracı50.com, tiyatrolar.com.tr, dasdas.com.tr, plumemag.com, oggusto.com, sehirtiyatrolari.ibb.istanbul) NOT yet added to `discovery-sources.yaml` — proposed but not confirmed for write; next session
- Recurrence watch: if next 3+ `*find` / `*weekly-plan` cycles show same JS-shell pattern, escalate fetch-architecture decision urgency or add headless-browser fetcher as pre-V2 capability
- iCalendar / V1 `gcal.py` limitation: `invite` does not support description field — flag for V2 calendar tool ADR cycle (separate from queued handoffs)

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
