<!-- Atlas v2 build-session ADR. Single record wrapping the 10 architectural locks
     ratified during bmb's *create-agent flow on 2026-05-03 → 2026-05-04. Each
     lock has a Source/Incident column (what surfaced it) + Revisit trigger
     (when it gets re-examined). Authored under the build-retrospective routing
     convention established this session: locks → decisions ADR (this file),
     calibration data → Atlas's autonomous-log, build patterns → Chuck's
     feedback memories. -->

---

id: 2026-05-04-atlas-v2-build
date: 2026-05-04
status: Accepted
title: "Atlas v2 build session — ratify 10 architectural locks for first SME under recommendation-discipline"
deciders: ["Chuck (team-maerg)", "Maerg (user)", "bmb (workflow agent)"]
supersedes: null
superseded_by: null

---

# Atlas v2 build session — ratify 10 architectural locks for first SME under recommendation-discipline

## Context

Atlas v2 is the first SME-agent authored in team-maerg under the recommendation-discipline framework (ratified 2026-05-03 in commit `760ccd72`, refined `145bd538`). The build session ran across 2026-05-03 → 2026-05-04 via bmb's `*create-agent` workflow, consuming v1 Atlas (in `bmad-test/`) as input and producing a Brix-stripped, system-agnostic CoS agent shaped per the scalability-roadmap ADR (`2026-05-01-scalability-roadmap.md`).

During the session, ten distinct architectural decisions surfaced — some in response to bmb's structured Q1–Q12 discovery, others from adversarial subagent dispatch, others from incidents (icalbuddy-vs-gcal.py default mismatch, voice-tagging spec drift caught by user pushback). Ratifying these as a single session-record ADR rather than ten separate ADRs because:

1. The locks decided **together** as a coherent persona — separating loses the cohesion.
2. Each lock's per-row Source/Incident + Revisit trigger captures its independent reasoning.
3. This is the precedent for future SME-build retrospectives: one session ADR per build, plus calibration data → agent's autonomous-log, plus build patterns → Chuck's feedback memories.

## Lens citations

- **Lens 7 (context window economics):** memory split (Q7), sidecar pattern (Q1), `*predict` drop (Q8) — all cut activation cost or persistent-state load.
- **Lens 9 (subagent delegation architecture):** routing tie-break (Q11), Handoff Protocol (Q5) — formalize how Atlas dispatches without ventriloquizing.
- **Lens 10 (hook/gate placement):** confirmation-gate invariant (Q12), Pearls capture (Q8 cross-cutting) — Maerg-confirmation as the load-bearing gate.
- **Lens 11 (workflow ergonomics):** filterable tags (Q4), route escape hatches (Q11) — friction reduction without sacrificing rigor.
- **Lens 12 (instruction bloat / contradiction):** type-pattern deferred to `_data/README.md` hybrid (Q2), `*predict` dropped (Q8) — strip surfaces that the existing recommendation-discipline + recommend-confirm-learn loop already cover.
- **Lens 6 (permission/tool surface):** calendar lane ownership (Q6/Q9/Q10 unified) — Atlas owns read+draft, write deferred until explicit grant; Planning SME propose-only.
- **Lens 17 (capability tier + cost economics):** Razmik refs dropped (Q3), Paperclip refs stripped (Q5) — agents not in current trajectory don't get persona surface.

## Options considered

### Option A: One session-record ADR (chosen)

- **What:** Single file with 10 locks as table rows, source/incident + revisit-trigger per row, lens citations + dissent unified at the ADR level.
- **Pros:** Captures cohesion of the build session; one file per build is scannable; revisit-triggers per row preserve independent reasoning.
- **Cons:** Heavier than per-lock ADRs would be; reader has to scan the table to find a specific lock's reasoning.
- **Cost / blast radius:** ~30 min to author, fully reversible (locks live in agent file regardless; this ADR is the trace).

### Option B: Ten separate ADR files

- **What:** One ADR per lock — `2026-05-04-atlas-v2-q1-sidecar.md`, `…q2-type-pattern.md`, etc.
- **Pros:** Each lock is independently navigable; cleanly maps to \*architecture-decision granularity.
- **Cons:** Loses the build-session context (these decided together, not in isolation); 10 files for one session is record-keeping bloat; misleading — these weren't run through \*architecture-decision individually.
- **Cost / blast radius:** ~3 hrs to author; high cleanup cost if shape needs revision.

### Option C: No ADR, leave bmb's retrospective as ephemera

- **What:** Skip the formal record; let bmb's draft retrospective sit in session transcript only.
- **Pros:** Zero authoring cost.
- **Cons:** Context decay; no traceable record for future agent builds; violates the build-retrospective routing convention this session established (locks → decisions ADR).
- **Cost / blast radius:** Negative — short-term zero, long-term unbounded as future SME builds lose the precedent.

## Tradeoffs

**Cohesion vs granularity.** Option A buys cohesion (build session is one thing, 10 locks are its substance) at the cost of scan-to-find-a-lock friction. Option B buys granularity at the cost of loose-locks-without-session-context. The Source/Incident + Revisit trigger columns in Option A's table give back enough granularity that scan friction is manageable; the cohesion is harder to recover if lost. Pick A.

## Recommendation

**Option A — single session-record ADR.** Locks below ratify the Atlas v2 persona shape in `bmad/team-maerg/agents/atlas.md` + `bmad/team-maerg/agents/atlas-sidecar/`, capability_tier `ops`, supersedes `bmad-test/atlas-v1`.

### The 10 locks

| #         | Lock                                                                                                                                              | Source / Incident                                                                                                                | Revisit trigger                                           |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| Q1        | Sidecar at `bmad/team-maerg/agents/atlas-sidecar/`                                                                                                | Match v6 module pattern + first-SME-template                                                                                     | Structural change to module convention                    |
| Q2        | Type-based-pattern doc deferred to `_data/README.md` hybrid                                                                                       | Smallest-enforceable; full ADR fires when San v2 spawn forces it                                                                 | San v2 author asks "what pattern?"                        |
| Q3        | Razmik refs dropped from v1                                                                                                                       | Agent not being ported in current trajectory                                                                                     | If Razmik returns later via `*create-agent`               |
| Q4        | Filterable tags now; `tag-routing.yaml` deferred to N≥3                                                                                           | Premature-abstraction trap at N=1; reinforced by `feedback_workflow_vs_runbook_threshold`                                        | N≥3 dispatch targets OR ≥3 tags-per-target                |
| Q5        | System-agnostic Handoff Protocol (Paperclip-stripped)                                                                                             | Phase 1/2 Paperclip supervision was policy-of-intent without runtime mechanism                                                   | First SME beyond Chuck                                    |
| Q6/Q9/Q10 | Atlas owns calendar lane fully (read + draft today, write later); Planning SME propose-only                                                       | gcal.py is verified working; icalbuddy default was course-correction (anchoring-on-plausible-defaults — see new feedback memory) | Explicit calendar-write affordance grant                  |
| Q7        | Memory split (`memories.md` sovereign + `memories-autonomous-log.md` append-only by Atlas) with frontmatter provenance + subject-axis subsections | ChatGPT-canonical authority asymmetry; Letta lesson on subject-axis                                                              | Second autonomous writer (other agent appending)          |
| Q8        | Pearls IN as `## revealed-preferences` subsection; `*predict` DROPPED → replaced by recommendation-discipline as team-wide rule                   | `*predict` mechanic IS the existing recommend-confirm-learn loop, not a separate command                                         | ≥10 Pearls accumulate AND `*reflect` flags prediction gap |
| Q11       | Routing tie-break = ask-Atlas (LLM-judged) with confirmation gate; operator escape hatches `*route X to Y` and `*route X to Y+Z` survive          | AutoGen's argument: routing decisions need full message context, which YAML can't capture                                        | Atlas's calls drift unpredictably across sessions         |
| Q12       | Atlas never writes `memories.md` directly (hard invariant); all updates flow through Maerg-confirmation gates                                     | ChatGPT-canonical authority asymmetry                                                                                            | Confirmation-gate friction becomes annoying               |

### Cross-cutting deliverables ratified during this build

- `bmad/team-maerg/_data/recommendation-discipline.md` — ratified team-wide, behavior-tested 3 cases (commit `760ccd72`); refined post-Atlas-shape sims (commit `145bd538`).
- `bmad/team-maerg/_data/team-principles.md` v1.2 — principle 6 added ("Recommendations carry their tier") with incident anchor to this build.
- 3 future-trajectory project memories captured: `project_planning_agent_roadmap.md`, `project_sprint_planning_agent_roadmap.md`, `project_team_session_sync_convention.md`.

## Dissent

**Strongest honest counter:** session-record ADRs may obscure which lock had what reasoning, especially for future readers landing on Q-numbers in isolation (e.g., a new SME author hitting "what was Q4's tag-routing logic?"). The Source/Incident + Revisit trigger columns are the mitigation — every lock carries its own per-row context — but a reader skimming the table top-to-bottom may not pause on each row. If this turns out to bite (San v2 author can't reconstruct a lock's reasoning from this file alone), the fix is per-lock ADR backfills referenced from this session record, not a re-do of this format.

**Adjacent concern:** ratifying as `Accepted` because the locks are already shipped in the agent file. Strictly speaking, the *architecture-decision workflow's options-and-pre-mortem ceremony was bypassed (bmb's *create-agent ran the equivalent inline). If a future audit demands stricter ADR-before-implementation, this ADR is grandfathered evidence — the locks shipped because the user + Chuck + bmb decided together in-flight, not because formal ADR ratification preceded.

## Outcome

- **Decided:** 2026-05-04
- **By:** Chuck + Maerg + bmb (consensus across the build session)
- **As:** Accepted
- **Followup commits:** Atlas v2 ships across `src/modules/team-maerg/agents/atlas.agent.yaml` + `bmad/team-maerg/agents/atlas.md` + `bmad/team-maerg/agents/atlas-sidecar/`; pending registry row append (flagged by Atlas in `*roster`); pending build-pattern feedback memory commits.

---

## Cross-references

- **Related ADRs:** `2026-04-29-phase-2-cross-module-awareness-convention.md`, `2026-05-01-scalability-roadmap.md`.
- **Related lenses:** lens-framework.md — full text loaded JIT for lens analysis.
- **Related principles:** team-principles.md v1.2 — principle 1 (fact-at-emission), principle 5 (research before committing), principle 6 (recommendations carry their tier), principle 7 (siblings stay in their lane), principle 8 (dissent openly), principle 9 (route, don't ventriloquize).
- **Related memories:** `feedback_anchoring_on_plausible_defaults.md` (NEW — icalbuddy incident), `feedback_testing_before_memory_capture.md` (extended scope to discipline/persona prescriptions), `feedback_attribution_external_reader_frame.md`, `feedback_research_before_structural_questions.md`, `feedback_workflow_vs_runbook_threshold.md`.
- **Build retrospective routing convention:** locks → this ADR; calibration data → `atlas-sidecar/memories-autonomous-log.md`; build patterns → Chuck's feedback memories. This becomes the precedent for San v2 + every future SME's build retro.
- **Session refs:** bmb's `*create-agent` workflow run 2026-05-03 → 2026-05-04. Recommendation-discipline ratification commit `760ccd72`, refinement `145bd538`.
