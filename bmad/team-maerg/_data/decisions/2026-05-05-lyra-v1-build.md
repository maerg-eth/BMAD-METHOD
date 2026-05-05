<!-- Lyra v1 build-session ADR. Single record wrapping the structural locks
     ratified during bmb's *create-agent flow on 2026-05-05. Per the build-retro
     routing convention from Atlas v2 ADR (2026-05-04-atlas-v2-build.md):
     locks → this ADR; calibration data → lyra-sidecar/memories-autonomous-log.md;
     build patterns → Chuck's feedback memories.

     Lock table amended 2026-05-05 (same day, follow-up turn) to match bmb's
     session relay — Q1-Q8 are bmb's session-numbered locks; Q9-Q10 are
     supplementary locks artifact-confirmed but not numbered by bmb. Initial
     reconstruction (six locks under different numbering) preserved in git
     history at commit 580a591dd. -->

---

id: 2026-05-05-lyra-v1-build
date: 2026-05-05
status: Accepted
title: "Lyra v1 build session — ratify structural locks for second SME (personal-logistics curator) under recommendation-discipline"
deciders: ["Maerg (user)", "bmad/bmb/agents/bmad-builder", "team-maerg/chuck"]
supersedes: null
superseded_by: null

---

# Lyra v1 build session — ratify structural locks for second SME (personal-logistics curator) under recommendation-discipline

## Context

Lyra is the **second SME-agent in team-maerg** after Atlas v2 (`2026-05-04-atlas-v2-build.md`) and the **first agent with calendar-write authority**. Personal-logistics curator: preference modeling + weekly recommendation cycle + calendar invite creation. Capability tier: strategic. Built 2026-05-05 via bmb's `*create-agent` workflow; handoff brief `bmad/team-maerg/_data/handoffs/2026-05-05-planning-sme-brief.md` was the input.

V1 ships preference + recommendation + calendar-write (confirmation-gated). V2 (own `*evolve-agent` ADR cycle) adds booking/reservation/purchase via APIs. V3 (deferred) adds proactive trigger-driven surfacing on location/schedule shifts.

Inheriting the build-retro routing convention from Atlas v2:

- Locks → this ADR
- Calibration data → `lyra-sidecar/memories-autonomous-log.md` `## first-run-calibration` (Lyra-attestable)
- Build-session observations → ADR (build-session observations from bmb, third-party from Lyra's frame)
- Build patterns → Chuck's feedback memories

Per distributed-automation-ownership ADR (`2026-05-05-distributed-automation-ownership.md`), Lyra owns automations within her domain — both registered in `_data/automations-registry.yaml` with `owning_agent: team-maerg/lyra`.

## Lens citations

- **Lens 6 (permission/tool surface):** Calendar-write authority is the most consequential single decision in this build — Lyra is the FIRST agent in team-maerg with this capability. Hard confirmation gate (Q3 lock) is the mitigation for the asymmetric-risk surface that calendar-write creates.
- **Lens 7 (context window economics):** Memory split (Q7), shared discovery-sources file, calendar-as-shared-surface-with-Atlas (Q2) — all minimize cross-agent state load.
- **Lens 9 (subagent delegation architecture):** Lane boundary with Atlas — Atlas captures + routes social-activity tasks; Lyra owns preference + recommendation + calendar-write. Calendar IS the contract (Q2) — no backchannel files needed at V1.
- **Lens 10 (hook/gate placement):** Three confirmation gates ratified — Q3 (calendar-write), Q12-mirror (preferences.yaml writes), implicit gate on memories.md sovereignty (Maerg-only writes). Each gate sits at a specific authority-asymmetry surface.
- **Lens 11 (workflow ergonomics):** 16-command menu (substantial — more than Atlas's 19, similar volume; reflects the multi-loop design — preference modeling + recommendation cycle + calendar gateway + reflection).
- **Lens 14 (termination awareness, MAST FM-1.5/3.1):** Discovery-source web-fetch failures + thin-data preference categories surface as honest gaps (per L5), not fabricated recommendations. STOP gate on "no discovery sources curated yet."
- **Lens 17 (capability tier + cost economics):** Strategic tier (recommendation IS the value, not just coordination) — confirms initial roadmap memory framing and supersedes the original "ops" classification from `project_planning_agent_roadmap.md` 2026-05-03 framing.

## Options considered

### Option A: Single session-record ADR (chosen — same pattern as Atlas v2 build)

- **What:** Single file with structural locks summarized; per-row Source/Incident + Revisit-trigger preserves independent reasoning. Mirrors Atlas v2 ADR pattern exactly — convention now applies to all future SME builds.
- **Pros:** Captures cohesion of the build session; one file per build; convention consistency with Atlas v2 establishes the pattern for San v2 + future agents.
- **Cons:** Lock list is reconstructed from artifacts (lyra.agent.yaml + lyra-sidecar/instructions.md), not from bmb's full session output (relay was partial). Risk of lock-numbering drift vs bmb's intent.
- **Cost / blast radius:** ~30 min author. Reversible if Maerg or future-bmb amends the lock list.

### Option B: Multi-file per-lock ADRs

- **What:** One ADR per lock, six files.
- **Pros:** Maximum granularity.
- **Cons:** Loses build-session cohesion; six files for one session is record-keeping bloat (per the same dissent as Atlas v2 ADR Option B). Misleading — these locks decided together via *create-agent inline, not individually through *architecture-decision.
- **Cost / blast radius:** Higher; deviates from Atlas v2 convention without justification.

### Option C: No ADR, leave bmb's output as ephemera

- **What:** Skip the formal record.
- **Pros:** Zero authoring cost.
- **Cons:** Convention violation — Atlas v2 established locks → ADR routing. San v2 + future SMEs lose the precedent. Context decay.
- **Cost / blast radius:** Negative long-term.

## Tradeoffs

**Cohesion vs reconstruction-precision.** Option A preserves build-session cohesion at the cost of lock-list precision (reconstructed from artifacts, not bmb's verbatim list). The mitigation: explicit note in this ADR that locks were reconstructed; if any lock differs from bmb's intent, amendment-via-evolve is cheap. Option B would force per-lock individual reasoning capture but deviates from the established convention without justification.

## Recommendation

**Option A — single session-record ADR matching Atlas v2 convention.**

### Eight structural locks (bmb's session numbering) + two supplementary locks (artifact-confirmed, unnumbered by bmb)

| #     | Lock                                                                                                                                                                                                                                                                                                               | Source / Incident                                                                                                                                                                                                                    | Revisit trigger                                                                                   |
| ----- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------- |
| Q1    | `capability_tier: strategic` (claude-opus-4-7). Implementation: sidecar at `bmad/team-maerg/agents/lyra-sidecar/`; first-SME-template inheritance from Atlas                                                                                                                                                       | Recommendation IS the value (judgment-heavy); not coordination throughput. Supersedes initial "ops" framing in `project_planning_agent_roadmap.md` 2026-05-03                                                                        | Cost / volume changes; degradation on Opus tier                                                   |
| Q2    | Calendar IS the shared surface with Atlas. No backchannel files for V1; future scoped-blocks pattern (Letta-style) reserved for non-calendar shared state                                                                                                                                                          | Subagent simulation rejected single-shared-log as worst-of-both-worlds (production canonicals — Letta / MCP / LangGraph — converge on domain-scoped resources). Memory `project_team_session_sync_convention.md` refined accordingly | First non-calendar cross-agent state need that doesn't fit a domain channel                       |
| Q3    | Calendar-write HARD confirmation gate — invites only after explicit Maerg accept; never books/purchases at V1                                                                                                                                                                                                      | Brief explicitly carved this; Atlas Q12 invariant mirror. Asymmetric-risk: calendar-write creates real-world commitments. Flagged for Tier-S treatment under hook-bypass policy ADR                                                  | V2 booking authority via own `*evolve-agent` ADR cycle                                            |
| Q4    | Single yaml `preferences.yaml` + no rotation logic V1. `*reflect` surfaces rotation trigger when threshold crosses                                                                                                                                                                                                 | Smallest-enforceable; defer rotation to first-incident                                                                                                                                                                               | Single category > 30 entries OR file > 50KB                                                       |
| Q5    | Calendar as VERIFICATION GATE (not fallback) — Maerg-stated location cross-checked against calendar event locations in `*weekly-plan` flow                                                                                                                                                                         | "Double check with calendar is a must" — verification gate refinement. Wrong-location recommendations are high-cost (jazz in NYC when Maerg's in SF that week)                                                                       | Verification mismatch becomes silent (location-services drift)                                    |
| Q6    | V1 = light web-fetch automation per curated sources; V2 = canonical API integrations                                                                                                                                                                                                                               | "Automation is king" — ship light V1, defer API auth + payment to V2                                                                                                                                                                 | Web-fetch parsing breaks ≥30% rate → expedite V2 API integration                                  |
| Q7    | Two automations registered: `weekly-plan-generation` (Sunday 19:00 UTC) + `event-proximity-check` (Mon/Wed/Fri 18:00 UTC). Both `mechanism: TBD` until /schedule routines wired. Owning_agent field carries the Lyra attribution; ID convention is no-agent-prefix per Chuck's `upstream-scan-bi-weekly` precedent | User confirmation of cadence + proactive notifications                                                                                                                                                                               | Cadence drift, notification fatigue, autonomous-monitoring infrastructure landing                 |
| Q8    | Name = Lyra (icon 🎼)                                                                                                                                                                                                                                                                                              | User-confirmed                                                                                                                                                                                                                       | N/A                                                                                               |
| Q9\*  | Calendar tool inheritance from Atlas — `{calendar_tool}` defaults to `gcal.py` (Atlas's Q6 lock), overridable in customize.yaml                                                                                                                                                                                    | DRY principle — Atlas already owns calendar tool selection; Lyra inherits rather than re-deciding. Artifact-confirmed in `lyra.agent.yaml`; not numbered by bmb                                                                      | Atlas's Q6 lock changes (calendar tool changes upstream)                                          |
| Q10\* | Memory split — `memories.md` Maerg-sovereign + `memories-autonomous-log.md` Lyra-append-only with frontmatter provenance + subject-axis subsections (Letta-canonical: drift-signals / fetch-failures / cross-cycle-notes / scan-observations)                                                                      | Inheriting Atlas v2 Q7 lock + Letta-block pattern — different content, same shape. Artifact-confirmed in `lyra-sidecar/instructions.md`; not numbered by bmb                                                                         | Second autonomous writer pattern emerges (e.g., another agent appending to Lyra's autonomous-log) |

\* Q9-Q10 are supplementary locks present in the build artifacts but not numbered in bmb's session relay. Treated as load-bearing structural decisions; numbered here for reference. Calibration sub-triggers worth tracking (not session-locked but observed in artifacts): re-evaluation of strategic-vs-ops classification (Q1 sub-trigger); confirm-on-every-accept friction at scale → batched-confirm pattern when Maerg accepts 5+ slots/week (Q3 sub-trigger); repeated location-verification false positives where Maerg travels more than calendar reflects (Q5 sub-trigger).

### Cross-cutting deliverables ratified during this build

- 16-command menu (`*weekly-plan`, `*plan-status`, `*find`, `*accept`, `*reject`, `*alternatives`, `*preferences`, `*capture-preference`, `*edit-preference`, `*post-event-reflect`, `*event-prep`, `*upcoming`, `*sources`, `*add-source`, `*reflect`, `*research`)
- 8 persona principles (L1-L8) — preference-revealed-not-declared, multi-option-floor, calendar-confirm-gate, deliberate-diversification, bounded-claims, drift-as-data, lane-integrity, calendar-as-shared-surface
- `lyra-sidecar/preferences.yaml` — the preference model (core IP; 8 categories: museums, restaurants, jazz, comedy, events, outdoor, social + film/theater)
- `lyra-sidecar/knowledge/discovery-sources.yaml` — curated source URLs (V1 manual; V2 API)
- `lyra-sidecar/knowledge/recommendation-frameworks.md` — methodology library (populated via `*research`)
- `lyra-sidecar/weekly-plans/YYYY-MM.md` — weekly plan archive (INTENDED + DELIVERED tracking)
- Two automations registered in `_data/automations-registry.yaml`: `lyra-weekly-plan-generation` (Sunday 19:00 UTC) + `lyra-event-proximity-check` (every 2-3 days). Both `mechanism: "TBD"` — to be wired by bmb in a future session, mirroring Atlas's calibration + upstream-scan pattern.

### Two deferrals

| Deferral                                                             | Trigger to revisit                                                                                                                                               |
| -------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **V2 booking authority** (booking/reservation/purchase via APIs)     | Maerg ratifies V2 capability ladder via `*evolve-agent` cycle with own ADR for booking-permissions surface — payment authorization, API auth tokens, audit trail |
| **V3 proactive trigger-driven surfacing** (location/schedule shifts) | Autonomous-monitoring infrastructure matures; concrete use case where Maerg's location/calendar shifts trigger Lyra surfacing without manual invoke              |

## Initial calibration observations (build session, bmb-observed)

These observations of Lyra's behavior are recorded HERE per the build-retro routing convention (third-party observations of agent during construction; not Lyra-attestable since she has no internal trace of the build session). Lyra's own first-person calibration is in `lyra-sidecar/memories-autonomous-log.md` `## first-run-calibration`.

bmb's session-end notes flagged five runtime-test follow-ups for first real-use cycles:

| Observation                                                                                                                                                             | Status                                                         |
| ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| Calendar-write confirmation gate friction at scale (Maerg accepting 5+ slots per weekly plan) — Q3 lock said hard gate; may need batched-confirm pattern after evidence | ⚠ watch — first 4 weeks of operational data                   |
| Discovery-source web-fetch reliability — V1 acknowledged parsing brittleness; first few fetches reveal which sites scrape vs need API                                   | ⚠ expected fragility (V2 API integration is the resolution)   |
| Cold-start recommendation quality — preferences.yaml empty at spawn; first 3-4 weekly cycles produce thin recommendations; track accept rate week-over-week             | ⚠ baseline; calibration target                                |
| Lane-boundary clarity with Atlas — manual-invoke handoff at V1; watch for friction; future scoped-blocks pattern may emerge                                             | ⚠ watch — Q2 future-trigger                                   |
| Drift signal threshold sensitivity (3+ rejects in same category) — may fire too often or too rarely; adjust per evidence in `*reflect`                                  | ⚠ calibration tuning expected over first 2-3 \*reflect cycles |

Lyra calibration routine deferred to ~2026-06-02 (4-week-out check when Lyra has actual operational data: ≥4 weekly cycles + ≥3 post-event reflections). Earlier than that = thin sample.

## Dissent

**Strongest honest counter (resolved):** initial commit (580a591dd) recorded six locks reconstructed from `lyra.agent.yaml` + `lyra-sidecar/instructions.md` artifacts because bmb's session output had not been relayed in full. bmb's full Q1-Q8 relay arrived in a follow-up turn the same day (2026-05-05); the lock table was amended to bmb's session numbering with two supplementary locks (Q9-Q10) preserved for the artifact-derived structural decisions bmb didn't explicitly number. Original reconstruction is preserved in git history at commit 580a591dd. Any further discrepancies between this amended table and bmb's intent are themselves cheap to amend — re-correction path remains the same.

**Adjacent concern:** Lyra's calendar-write authority is the largest single capability expansion in team-maerg's ecosystem so far. Q3 hard confirmation gate is the only mitigation between Lyra and real-world calendar damage (events on wrong day, wrong people invited, deletion of pre-existing commitments — though deletion is explicitly forbidden at V1). If Q3 gate is bypassed accidentally (e.g., a future `*evolve-agent` weakens it without explicit ADR), the blast radius is significant. Worth treating Q3 as Tier-S-equivalent (per hook-bypass policy ADR) — never weaken without explicit ADR cycle. Recommend amending the hook-bypass policy ADR to include "agent confirmation gates" as a Tier S surface.

**Adjacent concern 2:** Two automations registered with `mechanism: "TBD"` — drift-flag will fire in `*automations` view + `*audit-ecosystem` until /schedule routines are wired. Pre-flagged honestly rather than masked.

## Outcome

- **Decided:** 2026-05-05
- **By:** Maerg + bmb (build session) + Chuck (this ADR ratifying the locks)
- **As:** Accepted (lock reconstruction noted as partial-confidence; amendment trivial if discrepancies)
- **Followup commits:**
  - Lyra ecosystem-registry row appended (commit 580a591dd)
  - Two automations rows appended to `_data/automations-registry.yaml` (commit 580a591dd)
  - `project_team_session_sync_convention` memory refined per bmb's note — single-shared-log shape was "worst of both worlds"; refine to scoped-blocks-per-state-type framing, trigger condition shifts from "San v2 spawns" to "first concrete cross-agent state need that doesn't fit a domain channel"
  - Lock table amended 2026-05-05 to match bmb's session-numbered Q1-Q8 with two supplementary locks (Q9-Q10) preserved (this commit)
  - Future bmb session: wire /schedule routines for Lyra's two automations; update mechanism fields
  - Future Chuck session (~2026-06-02): Lyra calibration check after 4-week operational data accumulates

---

## Cross-references

- **Related ADRs:** `2026-05-04-atlas-v2-build.md` (first-SME-template + Q5/Q6/Q7/Q12 patterns inherited); `2026-05-05-graduated-hook-bypass-policy.md` (Q3 gate is Tier-S-equivalent); `2026-05-05-distributed-automation-ownership.md` (Lyra owns her two automations).
- **Related principles:** team-principles.md v1.2 — principle 6 (recommendations carry their tier), principle 7 (siblings stay in their lane — load-bearing for Q2), principle 1 (fact-at-emission — load-bearing for L5).
- **Related memories:** `project_planning_agent_roadmap.md` (originating intent, capability-tier supersession noted), `project_session_2026_05_05_deferred_followups.md` (audit-ecosystem extensions), `feedback_anchoring_on_plausible_defaults.md` (Lyra explicitly applies — discovery-source defaults verified before priming).
- **Related artifacts:** `bmad/team-maerg/_data/handoffs/2026-05-05-planning-sme-brief.md` (input to this build); `lyra-sidecar/instructions.md`, `lyra-sidecar/preferences.yaml`, `lyra-sidecar/memories-autonomous-log.md`, `lyra-sidecar/knowledge/recommendation-frameworks.md`, `lyra-sidecar/knowledge/discovery-sources.yaml`.
- **Build retrospective routing convention:** locks → this ADR; calibration data → `lyra-sidecar/memories-autonomous-log.md`; build patterns → Chuck's feedback memories. Continues precedent established in Atlas v2 ADR.
