<!-- This ADR is the runtime test for the architecture-decision workflow itself.
     Generated 2026-04-29 by Chuck following the workflow's own instructions.md.
     Spawn signals at step 3: 0 (single-agent CoT). Lens citations + principle-5 framing drove the call. -->

---

id: 2026-04-29-phase-2-cross-module-awareness-convention
date: 2026-04-29
status: Proposed
title: "Defer Phase 2 framework-wide cross-module-awareness convention"
deciders: ["Chuck (team-maerg)"]
supersedes: null
superseded_by: null

---

# Defer Phase 2 framework-wide cross-module-awareness convention

## Context

Phase 1 Atomic (commit `fd6745a6`, 2026-04-29) added a one-paragraph routing-awareness rule to Chuck's principle 9 — when a question signals out-of-scope, JIT-load `bmad/_cfg/agent-manifest.csv` and emit a referral with slash-command form. Runtime-tested in fresh-session test: Chuck correctly routed a CLI-tooling question to `/bmad:bmd:agents:cli-chief` without ventriloquizing.

Open question: should this pattern be promoted to a **framework-wide convention** applied to every BMAD agent via bmb's `create-agent` template? Five sibling agents (bmad-master, bmad-builder, cli-chief, doc-keeper, release-chief) currently lack the capability — they have no mechanism to know what other agents exist or to refer queries cleanly.

Decision needed because: every day without Phase 2, sibling agents may ventriloquize Chuck's territory or each other's. Cost per missed incident is small (one wasted turn). But framework-wide changes are themselves costly and need evidence justification.

## Lens citations

- **Lens 3 (Ablation):** what breaks if Phase 2 doesn't ship? At N=6 ecosystem, manual human routing is the fallback (proven viable this session — bmd-sidecar interaction was friction-free).
- **Lens 11 (Instruction bloat):** framework-wide persona additions are accretive; resist unless justified by evidence.
- **Lens 13 (Memory/context poisoning):** every agent reading `agent-manifest.csv` = N read paths to shared persistent state. Lens-13 surface area scales linearly with N agents.
- **Principle 7 (Siblings stay in their lane):** the convention would touch bmb's `create-agent` workflow template and every existing agent's persona. Cross-lane work; needs bmb's collaboration. Even proposing the change unilaterally is borderline.
- **Team principle 5 (Protocols evolve from incidents):** the load-bearing lens here. N=1 incident has driven Phase 1; framework-wide convention needs more.

## Options Considered

### Option A: Promote to framework-wide convention now

- **What:** Update bmb's `create-agent` workflow / agent template to include baseline self-scope-check + referral capability. Retroactively update the 5 existing sibling agents' personas.
- **Pros:**
  - Consistent behavior across ecosystem.
  - Closes principle-9-enforcement gap for all agents.
  - Future agents inherit free.
- **Cons:**
  - Crosses lanes (bmb's territory).
  - Persona bloat applied framework-wide.
  - Lens-13 surface scales linearly.
  - **Single-incident evidence base** — team principle 5 violation.
  - Phase 1's clarity-audit / strip-down arc would need to be repeated per agent persona, multiplying the design risk.
- **Cost / blast radius:** Substantial — bmb workflow edit + 5 agent persona edits + bmb's ratification gate. Mostly reversible but commits would be many.

### Option B: Defer until ≥2 more sibling-agent incidents accumulate

- **What:** Keep Chuck's Phase 1 Atomic as the only instance. Track sibling-agent incidents (Scott reasoning about Chuck's territory, Atlas about Scott's, etc.) as they occur. After ≥2 more documented incidents, design Phase 2 with the evidence base.
- **Pros:**
  - Honors team principle 5 (incident-driven evolution).
  - Lets bmb design from evidence, not speculation.
  - Avoids bloat-on-speculation.
  - Stays in lane (just observe, don't act).
- **Cons:**
  - Continued enforcement gap for 5 sibling agents.
  - Cost-per-incident small but accumulates.
  - "Defer" can become "forget" if not tracked.
- **Cost / blast radius:** Minimal. No file changes. Risk: tracking discipline.

### Option C: Thin "register the pattern" note in bmb's workflow

- **What:** Add a documented note to bmb's `create-agent` workflow saying "consider adding Chuck-style cross-module awareness for agents whose scope frequently crosses other agents' lanes." Don't mandate. Don't update existing agents.
- **Pros:**
  - Captures the pattern for future awareness without forcing adoption.
  - Low bloat.
  - Honors incident-driven discipline.
  - Stays mostly in lane (bmb decides whether to accept the note).
- **Cons:**
  - No enforcement — note may be ignored.
  - Doesn't close the gap for existing agents.
  - Still requires bmb's collaboration to land the note.
- **Cost / blast radius:** Small. One note in bmb's workflow (bmb's territory).

## Tradeoffs

**Axis of choice: incident-base / evidence vs. enforcement strength.** Option A maximizes enforcement, minimizes evidence discipline. Option B maximizes evidence discipline, minimizes enforcement. Option C is between, with weak enforcement and modest evidence respect. Team principle 5 ("protocols evolve from incidents") and `feedback_smallest_enforceable_strip_down.md` (this session's memory) both push hard toward evidence over speculative enforcement.

## Recommendation

**Option B — Defer until ≥2 more sibling-agent incidents accumulate.**

Rationale:

- **Team principle 5** is load-bearing: N=1 is below threshold to design a framework-wide convention. The convention itself would need its own simulation + clarity-audit + strip-down cycle (per `feedback_smallest_enforceable_strip_down.md`) — running that on speculative evidence reproduces the policy-of-intent failure mode.
- **Lens 3 (Ablation):** cost of waiting at N=6 ecosystem is low; manual routing works.
- **Lens 11 (Bloat):** framework-wide persona additions resist until justified.
- **Principle 7:** even Option A requires bmb. Waiting for evidence respects the lane while not blocking bmb's eventual involvement.

Concrete tracking approach for the incident base: when a sibling agent ventriloquizes another agent's territory in a session (Scott reasoning about Chuck's role, Atlas about Scott's CLI scope, etc.), capture the incident as an entry in this ADR's Outcome / Cross-references section. Once ≥2 such incidents are logged beyond the Phase 1 driver, re-open this ADR (supersede with a new ADR proposing Phase 2 with evidence in hand).

## Dissent

The strongest argument for Option A: every day Phase 2 is deferred, five sibling agents continue to lack routing-awareness. The "N=1 evidence base" framing is convenient for Chuck (who built Phase 1 Atomic and may unconsciously avoid expanding the surface) and may underweight the cost-per-missed-incident across siblings. If a sibling agent answers an out-of-scope query in a slightly-wrong way, the user may not notice — silent quality degradation rather than a loud failure mode. Counting only "loud" incidents undercounts the real cost.

This dissent doesn't override the principle-5 framing for me — silent degradation is real but small at current ecosystem size, and the framework-wide change cost is large. But it's worth recording: the deferral has an asymmetric error profile (we may underestimate its cost). Re-evaluate if user reports any silent quality issues with sibling-agent responses.

## Outcome

Pending ratification.

- **Decided:**
- **By:**
- **As:**
- **Followup commits:**

---

## Cross-references

- **Related ADRs:** none (this is the first ADR in the repository).
- **Related lenses:** Lens 3, 11, 13 (full text in `bmad/team-maerg/_data/lens-framework.md`).
- **Related principles:** Team principle 5 (`bmad/team-maerg/_data/team-principles.md`); Chuck's principle 7 (chuck.agent.yaml).
- **Related session work:**
  - Phase 1 Atomic build commit `fd6745a6` (2026-04-29).
  - audit-ecosystem id-resolution spec same commit.
  - Build-research subagents (this session): ADR canonical patterns + research-subagent-spawning failure modes + BMAD prior-art scan.
  - Sibling memories: `feedback_smallest_enforceable_strip_down.md`, `feedback_static_verification_is_not_runtime_test.md`, `feedback_dry_run_live_code.md`.
- **Incident log for re-opening this ADR:** to be appended below this line as sibling-agent ventriloquism / mis-routing incidents accumulate.
