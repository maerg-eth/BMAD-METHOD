<!-- Distributed automation ownership ADR. Establishes the convention that each
     team-maerg agent owns automations within its own domain (rather than Atlas
     as central orchestrator), with a shared automations-registry.yaml for
     coordination/visibility and Atlas surfacing aggregates in *monday-brief.
     Authored 2026-05-05 in response to the upstream-scan habit question
     surfacing the broader "where do automations live" architecture choice. -->

---

id: 2026-05-05-distributed-automation-ownership
date: 2026-05-05
status: Accepted
title: "Distributed automation ownership — each agent owns its own automations; shared registry for visibility"
deciders: ["Chuck (team-maerg)", "Maerg (user)"]
supersedes: null
superseded_by: null

---

# Distributed automation ownership — each agent owns its own automations; shared registry for visibility

## Context

Team-maerg is about to acquire its first scheduled automation outside of Atlas's existing brief cadence (a bi-weekly upstream-scan routine for tracking BMAD-METHOD upstream evolution). The question of WHERE that routine should live — on Atlas (who already has cadence DNA via `*daily-brief`, `*monday-brief`, `*weekly-review`) or on Chuck (whose meta-architecture lane the upstream scan actually belongs to) — surfaces a broader convention question this ADR ratifies.

Today (2026-05-05) team-maerg has 2 active agents (Chuck, Atlas). Two automations exist or are being added:

1. Atlas's brief cadence (`*daily-brief`, `*weekly-review`) — Atlas-owned, Atlas-fired, Atlas-output. Pattern is clean: domain (CoS coordination) → owner (Atlas).
2. The bi-weekly upstream-scan routine (newly proposed) — domain is meta-architecture (BMAD-METHOD framework awareness), owner should be Chuck. Pattern would be the same: domain (meta-architecture) → owner (Chuck).

Without an explicit convention, the next agent (San v2) will face the same question for prediction-calibration cadence, Brier-score reviews, etc. — and may default to "give it to Atlas" because she's already the cadence agent. That defaults Atlas into an everything-coordinator role, violating principle 7 (siblings stay in their lane).

This ADR ratifies the distributed-ownership pattern explicitly so San v2 + every future SME inherits it without re-arguing.

## Lens citations

- **Lens 9 (subagent delegation architecture):** Distributed ownership maps automation responsibility to domain expertise — the agent that knows the substantive work owns the cadence around it. Atlas-as-central-orchestrator forces meta-knowledge of all domains into one persona.
- **Lens 11 (workflow ergonomics):** Distributed ownership scales linearly with agent count (each agent adds its own automations); central ownership scales quadratically (Atlas's surface bloats as N agents grow, each requiring Atlas to learn their domain enough to schedule for them).
- **Lens 12 (instruction bloat):** Atlas-central pattern would require Atlas to load every agent's automation logic at activation. Distributed pattern keeps each agent's automations in their own sidecar, loaded only when that agent activates.
- **Lens 17 (capability tier + cost economics):** Distributed allows automation development cost to be paid by the agent that benefits — Chuck pays for meta-architecture automations (he's the consumer); Atlas pays for CoS automations (her consumers); etc.

## Options considered

### Option A: Atlas as central orchestrator

- **What:** Atlas owns ALL scheduled automation routines (calibration check, upstream scan, security audit cadence, prediction calibration, ecosystem audits, etc.). Other agents do substantive work; Atlas handles "when to fire" and "where to land output."
- **Pros:** Single coordination surface — Maerg knows where to look for "what's running on schedule." Atlas already has cadence DNA. Doesn't fragment ownership across agents.
- **Cons:** Lane bleed — Atlas becomes a meta-agent, not just CoS. Routine logic for OTHER domains lives in Atlas's instructions even when the substantive work isn't hers. Atlas's surface bloats as N agents grow. Violates principle 7.
- **Cost / blast radius:** Atlas's instruction bloat scales with agent count. Today 2 agents × 1-2 automations each = ~3 automations. At N=5 SMEs × 2-3 automations each = ~12 automations all routed through Atlas's surface.

### Option B: Each agent owns their own automations + shared registry for visibility (chosen)

- **What:**
  - Each agent owns the automations relevant to its domain (Chuck → meta-architecture; Atlas → CoS coordination; San v2 → prediction calibration; future SMEs → their domain).
  - Shared `bmad/team-maerg/_data/automations-registry.yaml` tracks all automations across the ecosystem. Schema: `id`, `owning_agent`, `cadence`, `mechanism` (/schedule routine ID, agent menu trigger, etc.), `purpose`, `output_location`, `last_fired`, `next_fire`, `created`.
  - Atlas reads the registry in her `*monday-brief` to surface aggregate "automations this week" line — that's COORDINATION (Atlas's lane), not ownership.
  - Chuck's `*audit-ecosystem` includes "automations health check" — flags stale, failed, or drifted automations.
  - New menu item on Chuck: `*automations` — read-only summary of the registry (analogous to `*registry`).
- **Pros:** Lane integrity per principle 7. Composable — new agents add their own automations without Atlas modification. Failure isolation — one agent's automation breaking doesn't affect others. Maps to `feedback_evaluate_from_agent_epistemic_frame` (each agent knows its own domain best).
- **Cons:** No single "what's scheduled" view without the registry. Discoverability requires consulting the registry rather than asking Atlas directly. Adds a new artifact (registry) + new Chuck menu item to maintain.
- **Cost / blast radius:** Registry is small (one row per automation, ~15 fields). Chuck menu item is ~20 lines of action prompt. Atlas's monday-brief gets one new aggregate line. One-time setup; permanent pattern.

### Option C: No formal pattern — ad-hoc per automation

- **What:** Don't decide. Each automation lives wherever the author drops it. Some on Atlas, some on Chuck, some standalone.
- **Pros:** Zero design cost.
- **Cons:** Inconsistency confuses Maerg + future agents. San v2 author hits "where does my prediction calibration routine live?" and re-decides. Compounds with each agent.
- **Cost / blast radius:** Decision deferral — pays interest as N agents grow.

## Tradeoffs

**Coordination-overhead vs lane-integrity.** Option A optimizes single-pane-of-glass at the cost of forcing meta-knowledge into Atlas's persona. Option B optimizes lane integrity at the cost of needing a coordination artifact (the registry). Option B's coordination cost is bounded (one yaml file + one menu item); Option A's lane-bleed cost grows linearly with agent count.

The principled answer is B per principle 7. Option A's "single coordination surface" advantage is preserved by the registry + Atlas's monday-brief aggregate — coordination is decoupled from ownership.

**Sub-question: cadence for the upstream-scan routine.** Initial Chuck recommendation was monthly (signal-density argument: ~73 commits/month upstream, ~0 cherry-pickable today; weekly trains skip-and-dismiss, monthly preserves "if it fires, read it"). Maerg countered with bi-weekly (better awareness during active build-state without weekly's noise). Bi-weekly is the right resolution: ~36 commits per scan, 2-week latency, retains signal property. Re-evaluate cadence if bi-weekly briefs consistently surface 0 relevant items for 3+ scans (downgrade to monthly) OR consistently surface 5+ (upgrade to weekly).

## Recommendation

**Option B with bi-weekly cadence for the upstream-scan routine (first instance of the convention).**

Concrete shape:

1. Each agent owns automations within its domain. Cadence definition + output location + mechanism live in the agent's sidecar (or via /schedule routines registered to the agent).
2. Every new automation REGISTERS in `bmad/team-maerg/_data/automations-registry.yaml` at creation. Registry update is a required step in the \*propose-automation flow (or whatever creation path the owning agent uses).
3. Atlas's `*monday-brief` reads the registry and surfaces an aggregate "automations this week" line — fired this week / firing this week / failed / overdue.
4. Chuck's `*audit-ecosystem` adds an "automations health check" — flags stale registrations, failed routines, automations whose last_fired exceeds 2× cadence (drift).
5. Chuck gains a new menu item `*automations` — read-only registry summary (analogous to `*registry`).

**First instance:** bi-weekly upstream-scan routine, owned by Chuck, registered in automations-registry.yaml, mechanism = /schedule routine to be created by bmb (or via the schedule skill directly). Output: `bmad/team-maerg/_data/upstream-scans/<YYYY-MM-DD>.md`.

## Dissent

**Strongest honest counter:** distributed ownership with a registry creates a new failure mode — registry-vs-reality drift. If an agent registers an automation but never wires the actual /schedule routine (or vice versa), the registry lies. Today's lint-staged incident was caused by exactly this kind of drift (registry implicitly claimed format:fix worked on staged files; reality was it ran on the whole codebase). The audit step (Chuck's `*audit-ecosystem` automations health check) mitigates but doesn't eliminate.

**Counter-argument to the dissent:** centralized ownership has the same drift surface (Atlas claims to own a routine but doesn't actually fire it correctly). Distributed doesn't introduce a new failure mode; it just relocates it. The registry-vs-reality drift is a general automation-management problem, not a distributed-vs-centralized one. Chuck's audit-ecosystem reconciliation already exists as the pattern for catching registry-filesystem drift on agents — extending it to automations is a small marginal cost.

**Adjacent concern:** Atlas's monday-brief "automations this week" line could become noise if registry has many low-value entries. Mitigation: registry entries earn keep — if an automation hasn't fired or surfaced anything actionable in 6 months, audit-ecosystem flags it for retirement (analogous to agent retirement). Same retire-when-not-earning-keep discipline as Chuck's principle 4 applied to automations.

## Outcome

- **Decided:** 2026-05-05
- **By:** Chuck + Maerg (consensus this session)
- **As:** Accepted
- **Followup commits:**
  - Create `bmad/team-maerg/_data/automations-registry.yaml` with schema + Chuck's first row (bi-weekly upstream-scan)
  - Add `*automations` menu item to Chuck (chuck.agent.yaml + chuck.md)
  - Cross-reference in recommendation-discipline.md (note: automation ownership policy lives here)
  - bmb (or schedule skill directly) creates the actual /schedule routine for the bi-weekly upstream-scan
  - Atlas's `*monday-brief` instructions extended with the "automations this week" aggregate line (deferred to first time it actually has content to surface — V0 = read but no surface; V1 = surface when ≥1 automation fired in the week)

---

## Cross-references

- **Related ADRs:** `2026-05-04-atlas-v2-build.md` (Atlas's existing cadence work — preserved as Atlas-owned), `2026-05-05-graduated-hook-bypass-policy.md` (sibling: also a meta-policy ratified this session).
- **Related lenses:** lens-framework.md — lenses 9, 11, 12, 17 named above.
- **Related principles:** team-principles.md — principle 6 (recommendations carry their tier — applies to automation outputs that include recommendations), principle 7 (lane integrity — load-bearing for this decision).
- **Related memories:** `feedback_evaluate_from_agent_epistemic_frame.md` (each agent's domain knowledge is foundational to good automation design in that domain), `feedback_workflow_vs_runbook_threshold.md` (registry pattern earns keep at N≥3 automations — currently building toward that threshold).
- **Originating context:** today's question "how do I know what's available upstream + make this a habit?" surfaced the upstream-scan need, which surfaced the broader automation-ownership architecture question.
