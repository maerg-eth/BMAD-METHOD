---
type: agent-memory
maintained_by: Lyra 🎼 (append-only, autonomous)
authority: Lyra-write-only per Q7 lock — Maerg never edits this file
last_updated: 2026-05-05
---

# Lyra Autonomous Log

> Lyra's own write surface. Append-only by Lyra; never edited by Maerg.
> Each entry carries frontmatter provenance: `source` + `timestamp` + `agent: lyra`.
> Subject-axis subsections (per Letta-canonical pattern + Q7 lock).

---

## drift-signals

_Preference shifts surfaced from accept/reject patterns. Triggers (per Drift Capture Rule in instructions.md): ≥3 rejects in previously-accepted category; new category Maerg requests; ≥4 consecutive accepts in previously-rejected category. Drift signals feed `*reflect` (monthly synthesis surfaces drifts)._

## <!-- Format:

source: drift-signal
timestamp: 2026-05-05T...
agent: lyra

---

[date] | Category: <cat> | Pattern: <observation> | Suggested model update: <delta>
-->

---

## fetch-failures

_When discovery-source web-fetch breaks (URL changed, parsing failed, rate-limited). Logged on every *weekly-plan or *find that hits a failure. Surfaced in plan output as honest gap; Maerg can manually paste OR remove dead source via \*edit (no command yet — manual edit of discovery-sources.yaml until evidenced)._

## <!-- Format:

source: fetch-failure
timestamp: 2026-05-05T...
agent: lyra

---

[date] | URL: <url> | Error: <type> | Source still valid? <unknown/no/yes-format-changed>
-->

---

source: fetch-failure
timestamp: 2026-05-05T19:30:00Z
agent: lyra

---

2026-05-05 | URL: https://kultur.istanbul/etkinlikler/ | Error: js-shell (event listings load dynamically; static HTML returns navigation + filter controls only) | Source still valid? yes-format-changed (site live, but server-side fetch insufficient — needs headless browser OR canonical API)

---

source: fetch-failure
timestamp: 2026-05-05T19:30:00Z
agent: lyra

---

2026-05-05 | URL: https://biletinial.com/tr-tr/sehrineozel/istanbul-avrupa | Error: js-shell (returns "Aradığınız sonuçlarla eşleşen etkinlik yok" + placeholder images; actual listings dynamic) | Source still valid? yes-format-changed (placeholder-image titles like "Dublörün Dilemması", "Fareler ve İnsanlar" surface but no dates/venues attached)

---

**Pattern note (first \*find cycle 2026-05-05):** All three Istanbul aggregator sources (kultur.istanbul, biletinial.com, zorlupsm.com — last one not fetched this cycle but same architecture class) appear to be JS-rendered SPAs. V1 web-fetch protocol is structurally insufficient for these. Two recovery paths in play: (a) Maerg pastes listings manually per fetch session, (b) escalate scope to general WebSearch outside curated pool — surfaces meta-decision for *reflect cycle whether V2 (canonical APIs) needs to come earlier than originally scoped, or whether to add headless-browser fetcher as a pre-V2 capability. Drift-signal flag candidate if pattern repeats across 3+ *find / \*weekly-plan cycles.

---

## cross-cycle-notes

_Lyra observations between weekly cycles — emerging interests Lyra notices, dormant categories, patterns that don't yet meet drift-signal threshold but worth tracking. Also: Maerg-narrated cross-agent context (per Cross-agent visibility floor protocol in instructions.md)._

## <!-- Format:

source: cross-cycle-note
timestamp: 2026-05-05T...
agent: lyra

---

[date] | [observation: emerging interest, dormant category, cross-agent context, etc.]
-->

---

## scan-observations

_Phase 3 future — proactive horizon scans. Today: empty. When V3 lands (proactive trigger-driven surfacing on location/schedule shifts), this becomes the active autonomous-monitoring substrate._

<!-- Format reserved for V3 -->

---

## first-run-calibration

_Lyra's own runtime calibration data — empty-state baseline, lane integrity notes for future-me. Not drift-signals (those are model-driven). Not Pearls (Lyra doesn't have a Pearls subsection because preferences-as-revealed-state IS the Pearl-equivalent for her domain — captured directly into preferences.yaml). Owned by Lyra, append-only._

---

source: first-run-calibration
timestamp: 2026-05-05T00:00:00Z
agent: lyra

---

2026-05-05 | First operational session of Lyra v1 sidecar (fresh state, second SME after Atlas v2).

Baseline: 0 weekly plans generated, 0 recommendations decided, 0 post-event reflections, 0 calendar invites created. preferences.yaml seeded with 8 empty categories awaiting first signals.

Lane integrity (recorded for future-me): per Q2 lock, Calendar IS the shared surface with Atlas. I write calendar events; Atlas reads via gcal.py (his existing tool). No backchannel files for V1. Future scoped-blocks pattern (per Q2 future-trigger) handles non-calendar cross-agent state when it emerges.

Calendar-write authority: V1 invariant locked per L3 — invites only after explicit Maerg accept; confirmation gate mandatory; no booking/purchasing/payment at V1. V2 booking authority is its own \*evolve-agent ADR cycle.

Two automations registered (per Q7 lock): weekly-plan-generation (Sunday 19:00 UTC) and event-proximity-check (every 2-3 days). Both mechanism: TBD until /schedule routines wired in a future bmb session (mirroring Atlas's calibration + upstream-scan pattern).

---

## Archive

_When this file grows unbounded (per Letta-canonical archival tier guideline), older entries rotate to `memories-autonomous-log-archive/YYYY-MM.md`. Rotation logic deferred to Tier-C reactive trigger (per scalability roadmap ADR) — when retrieval pain materializes._

---

## Cross-references

- `instructions.md` Drift Capture Rule + Discovery Source Web-Fetch Protocol
- `_data/recommendation-discipline.md` — recommendations carry tier footers (drift-signals feed recommendation calibration over time)
- `preferences.yaml` — model state (drift-signals propose updates; Q12-mirror gate enforces Maerg confirmation)
- `memories.md` — Maerg-sovereign state (separate authority)

---

_Created: 2026-05-05 (Lyra v1 fresh autonomous-log per Q7 lock). Lyra-append-only, never user-edited._
