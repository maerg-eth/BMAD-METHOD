<!-- Scalability roadmap ADR. Captures Tier A/B/C structural decisions surfaced by
     this session's research arc. Each Tier A item gets its own future *architecture-decision
     ADR when its trigger fires. -->

---

id: 2026-05-01-scalability-roadmap
date: 2026-05-01
status: Proposed
title: "Adopt sequenced scalability roadmap (Tier A/B/C) for team-maerg SME-agent ecosystem growth"
deciders: ["Chuck (team-maerg)", "Maerg (user)"]
supersedes: null
superseded_by: null

---

# Adopt sequenced scalability roadmap (Tier A/B/C) for team-maerg SME-agent ecosystem growth

## Context

Ecosystem state at decision time: team-maerg has 1 active agent (Chuck, the meta-architect / coordinator). About to grow toward N=2-7+ via SME-agent authoring — Atlas v2 next (today), San v2 after, then potentially Accel / Razmik / Vox / Follett over coming sessions.

User's stated north-star (this session): "independently working agents that are subject matter experts to ensure we do good work for Brix." Not abstract scalability — rich SMEs producing high-quality Brix work, transitioning into BMAD-METHOD as the canonical home.

Three research subagents this session surfaced concrete scaling stress points BEFORE N=10:

1. **Multi-agent framework patterns at scale** (Subagent #1): canonical solo-user pattern is flat markdown for human-edited definitions + SQLite/vector for runtime memory (Claude Code, Cline, Letta all ship this shape). AutoGen 0.2→0.4 ground-up rewrite cited "tight coupling" + state-leak between agents as the explicit reason — flat-file collapse at scale is documented.

2. **Knowledge representation at scale** (Subagent #2, blocked on web access but produced unverified claims): premature graph adoption is documented anti-pattern ("graph becomes second source of truth, drift, abandonment"). Risk for current BMAD scale: HIGH relative to expected benefit. Don't graph yet.

3. **BMAD-specific audit** (Subagent #3): identified five concrete scaling stress points with breaking-point evidence. The most-likely N=10 failure: anchor-collision in `ecosystem-registry.yaml` step-9 edits leading to silent registry rot. Cost-of-fix is bounded if addressed before N grows; compounds if deferred.

Goal: sequence the scalability work so Tier A cleanups land before they bite, Tier B kicks in at mid-scale, Tier C stays reactive.

## Lens citations

- **Lens 5 (Data flow and representation):** Multi-agent ecosystems fail at interfaces. Dual-id convention bridge logic spreads across every agent-touching workflow — interface drift class.
- **Lens 7 (Context window economics):** Per-agent state files (sidecar memories, knowledge bases) compound activation cost as agent count grows. Hybrid memory pattern (Tier C) addresses this when pain materializes.
- **Lens 11 (Instruction bloat / prompt contradiction):** Hardcoded `team-maerg` strings (18+ in audit-ecosystem) prevent module reuse and force prose drift at every cross-module port.
- **Lens 13 (Memory/context poisoning):** Single-file registry edits with anchor-collision class (per Subagent #3) are a quiet integrity failure mode — silent registry rot under multi-machine concurrent writes.
- **Team Principle 5 (Protocols evolve from incidents):** Tier B / C items are speculative until their pain materializes. Don't preemptively rebuild.
- **Principle 7 (Siblings stay in their lane):** Type-based pattern (coordinator vs SME) maps to role, not module — Chuck's `_data/` pattern fits cross-agent reasoning; SMEs' sidecar pattern fits per-agent encapsulation.

## Options Considered

### Option A: Address all Tier A cleanups today, before authoring more agents

- **What:** Halt agent authoring (Atlas, San). Land all Tier A items first: dual-id elimination, audit-ecosystem module-parametric, type-based pattern documentation. Each as its own ADR + execution.
- **Pros:**
  - All future SME agents authored on the cleaner foundation.
  - No retroactive migration when agents accumulate.
- **Cons:**
  - Postpones SME-agent value (rich Brix-supporting agents) by ~3-5 sessions.
  - Tier A items are speculative until N grows — over-investing pre-evidence.
  - Strip-down compounds + user's explicit "ship the smallest enforceable thing" framing — addressing all Tier A pre-evidence is exactly the policy-of-intent failure mode.
- **Cost / blast radius:** ~10-15 hours across 3-5 sessions. Mostly reversible per item.

### Option B: Defer all scalability work; react when it bites

- **What:** Author SME agents (Atlas, San, future) using existing structures. Trust that pain will be loud when it arrives. Address only when broken.
- **Pros:**
  - Maximum velocity on SME-agent work.
  - Honors team principle 5 strictly (incident-driven only).
  - No speculative effort.
- **Cons:**
  - Anchor-collision class (Subagent #3's most-likely N=10 failure) can fail SILENTLY — registry rot accumulates without loud signal until it cascades.
  - Some Tier A items have lower cost pre-N=10 than at N=10 (e.g., dual-id elimination touches 1 workflow today, will touch N when more workflows depend on it).
- **Cost / blast radius:** 0 today; potentially compounding debt at N=10+.

### Option C: Sequenced rollout — Tier A items as discrete ADRs at trigger conditions; Tier B at N=8-10; Tier C reactive

- **What:**
  - **Tier A**: Each item gets its own `*architecture-decision` ADR + execution session, triggered by either (a) the next agent-authoring session that would benefit from the cleanup, or (b) explicit user decision. Items: dual-id elimination, audit-ecosystem module-parametric, type-based-pattern documentation.
  - **Tier B**: At N≥8 active agents, address: registry to per-agent files, audit-ecosystem step 4 tier-scoping.
  - **Tier C**: Reactive — hybrid memory, layered memory pattern, graph layer ONLY when cross-cutting query pain becomes demonstrable.
- **Pros:**
  - Each item lands when its evidence is strongest, not pre-evidence.
  - SME-agent authoring proceeds in parallel.
  - Per-item ADRs mean each gets proper scoping per `*architecture-decision` discipline.
  - Honors strip-down (each item is the smallest enforceable thing for its tier).
- **Cons:**
  - Multiple sessions involved; coordination overhead per item.
  - Tier A items might land out of order if triggers fire in unexpected sequence.
- **Cost / blast radius:** ~2-3 hours per Tier A item, distributed across sessions. Tier B ~4-6 hours when triggered. Tier C reactive only.

## Tradeoffs

**Axis of choice: rigor-now vs incident-driven sequencing.** Option A maximizes structural cleanliness pre-growth. Option B minimizes today's effort but risks silent failure modes. Option C threads the needle — incident-aware sequencing, Tier A items still land before they compound, but no premature investment in Tier B / C.

## Recommendation

**Option C — sequenced rollout.**

Rationale:

1. **Team principle 5 (incidents drive protocols)** is load-bearing here — Tier B / C items are genuinely speculative until N grows. Premature investment violates this.
2. **Tier A items have proximate triggers**: Atlas v2 authoring this session is a natural trigger for type-based-pattern documentation; first cross-module workflow port will trigger audit-ecosystem module-parametric; first multi-agent-write conflict will trigger dual-id elimination. Each item lands when its evidence sharpens.
3. **`*architecture-decision` workflow** built earlier this session is purpose-built for these per-item structural calls. Each Tier A item is exactly the workflow's use case — dogfooding it on real decisions earns its keep.
4. **Strip-down discipline** (`feedback_smallest_enforceable_strip_down.md` + extended today): ship the smallest enforceable thing per tier. Tier A only what fires now.
5. **SME-agent authoring** (the user's stated goal) proceeds in parallel — Atlas v2 today, San v2 next session, etc. Tier A doesn't block agent value delivery.

### Tier A items (each becomes a future ADR when triggered)

**A1. Eliminate dual id convention.**

- _What:_ Pick ONE canonical id form (registry-form `<module>/<short-name>` OR full-path `bmad/<module>/agents/<short>.md`). Derive others mechanically.
- _Why (Subagent #3):_ current `audit-ecosystem` step 2 has 24 lines of forward+reverse id-resolution algorithm; this spec-debt multiplies across every workflow that operates on agents.
- _Trigger:_ first multi-agent workflow that needs id-bridging beyond audit-ecosystem; OR user-explicit decision when convenient.
- _Cost:_ ~2-3 hours via `*architecture-decision` + execution.

**A2. Document type-based pattern (coordinators vs SMEs).**

- _What:_ Document explicitly: coordinator agents (Chuck-shape, cross-agent reasoning) → `_data/<agent>/` for state. SME agents (Atlas-shape, per-agent expertise) → sidecar pattern. Map to agent role, not module convention.
- _Why (Subagent #3):_ mixed pattern in team-maerg today (Chuck no sidecar, Atlas sidecar) is "the bug" — but only because it's undocumented. Documenting it as type-based resolves the inconsistency without forcing migration.
- _Trigger:_ Atlas v2 authoring (this session) — the natural moment to commit the convention.
- _Cost:_ ~1 hour. Could be a brief addendum to `team-principles.md` or a sibling design doc.

**A3. Make audit-ecosystem module-parametric.**

- _What:_ Replace 18+ hardcoded `team-maerg` strings in `bmad/team-maerg/workflows/audit-ecosystem/instructions.md` with `{module}` parameter. Move workflow to `bmad/core/workflows/` or `bmb/` for generalization.
- _Why (Subagent #3):_ second team module (`team-brix`?) means forking the workflow today.
- _Trigger:_ second module materializes; OR user-explicit "we'll have multiple modules soon."
- _Cost:_ ~2-3 hours via `*architecture-decision` + execution.

### Tier B items (defer to N≥8)

**B1.** Promote registry to per-agent files + generated index. Eliminates anchor-collision class entirely.
**B2.** Tier-scope audit-ecosystem step 4 (cap O(N²) explosion by capability_tier).

### Tier C items (reactive)

**C1.** Hybrid memory: flat for definitions/knowledge + SQLite/vector for high-frequency runtime memory.
**C2.** Layered memory (working/episodic/semantic) for state-heavy agents.
**C3.** Graph layer ONLY when cross-cutting query pain becomes demonstrable.

## Dissent

The strongest argument FOR Option A (do all Tier A today): the user's intent is clearly to author multiple SME agents over coming sessions. If that velocity holds (3+ SMEs in next month), Tier A cleanups touch multiple workflows by the time they're addressed reactively. Doing them once before agent #2 is cheaper than fixing across N agents later.

Counter: Tier A items are still bounded at N=2-3 — the cost differential vs N=8 is modest. And the speculative-investment risk is real: not all Tier A items may bite at the same scale, and locking choices pre-evidence forecloses better options that emerge during agent authoring.

The Option B argument (do nothing) is weakest — silent registry rot is a real failure mode that costs significant debugging when it cascades.

Net: Option C respects the principle-5 framing (incident-driven) while not waiting until pain. Acceptable residual risk: Tier A items might land in a different order than expected if triggers fire unevenly.

## Outcome

Pending ratification.

- **Decided:**
- **By:**
- **As:**
- **Followup commits:**

---

## Cross-references

- **Related ADRs:**
  - `2026-04-29-phase-2-cross-module-awareness-convention.md` (Phase 2 routing — also deferred per principle 5)
- **Related lenses:** Lens 5, 7, 11, 13 in `bmad/team-maerg/_data/lens-framework.md`
- **Related principles:** Team principles 5 + Chuck's principle 7 in `bmad/team-maerg/_data/team-principles.md` and `chuck.agent.yaml`
- **Subagent research (this session):**
  - Multi-agent framework patterns at scale (Subagent task `a142024a1599b13ee`) — flat markdown + SQLite/vector hybrid is canonical solo-user pattern
  - Knowledge representation at scale (Subagent task `a5614bf65ad5053c2`, web-blocked) — premature graph adoption is documented anti-pattern
  - BMAD-specific scalability audit (Subagent task `abb063a3fb7937461`) — 5 concrete stress points + tiered recommendations
- **Related session work:**
  - Phase 1 Atomic principle 9 routing (commit `fd6745a6`)
  - `*architecture-decision` workflow built (commit `9205f9d8`) — purpose-built for Tier A per-item ADRs
  - 14 feedback memories captured this session arc — operational discipline for executing these decisions
- **Atlas v2 authoring (today, post-this-ADR):**
  - Trigger for A2 (type-based pattern documentation)
  - Sidecar pattern adopted for SME agents (Atlas, future San)
  - bmb's `*create-agent` workflow used for canonical authoring
