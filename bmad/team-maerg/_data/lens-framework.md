# Team Maerg — 17-Lens Analytical Framework

Authoritative reference for Chuck's agent design and review lenses. Loaded JIT by commands that require deep reference; not loaded at activation (per lens 7 — context window economics).

Each lens has: (a) definition, (b) when it applies, (c) the failure mode it catches, (d) source/citation where external.

---

## Tier Organization

**Tier 1 — always applied. High blast radius for this ecosystem.**

- Lens 1: Eval-first
- Lens 6: Permission/tool surface audit
- Lens 12: Prompt injection (input-side)
- Lens 13: Memory/context poisoning (persistent-state)

**Tier 2 — applied when relevant.**

- Lenses 2, 3, 4, 5 (ML engineer frame)
- Lenses 7, 8, 9, 10 (CTO frame)
- Lenses 11, 14, 15, 16, 17 (extended)

Tier assignment is by blast radius for this deployment profile (solo user, assistive agents, defined tasks, low adversarial surface). Not by absolute importance in the broader AI safety literature.

---

## ML Engineer Frame (Lenses 1–5)

### Lens 1 — Eval-first [TIER 1]

**Definition.** Before building or approving an agent, define what "good" looks like. An agent without an explicit or implicit success metric is faith-based.

**When it applies.** At `*propose-agent`: gate all new agents on "what is the success rubric?" If null, the proposal does not proceed until the rubric is articulated — even crudely.

**Failure mode caught.** Ship-and-pray. Agent goes live with no way to verify it's working; drift is invisible because there's no baseline to drift from.

**Registry signal.** Every agent row has a `success_rubric` field. Null = eval-first gap (Gap 1 in audit-ecosystem).

---

### Lens 2 — Failure mode inventory

**Definition.** Before implementation, enumerate the top 5 ways this agent breaks. Ambiguous input, context overflow, scope leakage, prompt injection, silent confabulation are common starters.

**When it applies.** At `*propose-agent` before delegating to `bmad:bmb:create-agent`. At `*evolve-agent` when scope or tooling changes materially.

**Failure mode caught.** Silent-ship post-mortems: "we didn't think it would fail that way." Principal ML engineers enumerate failure modes because they know models silently fail.

---

### Lens 3 — Ablation thinking

**Definition.** For every proposed agent: what breaks if we don't build it? For every existing agent: what breaks if we retire it?

**When it applies.** At `*propose-agent` (build gate). At `*audit-ecosystem` (retirement candidacy). At `*evolve-agent` (scope-reduction check).

**Failure mode caught.** Accretive ecosystems. Agents accumulate without earning their keep because no one asks "would anything break without this?" Principle 4 ("retirement is a feature") operationalizes this lens.

---

### Lens 4 — Baseline benchmarking

**Definition.** Is this agent better than "just ask Claude directly"? Many proposed agents fail this test. The existence of a workflow does not justify an agent wrapping it.

**When it applies.** At `*propose-agent`, immediately after lens 3. Pair: "do we need this?" (lens 3) + "is it better than plain Claude?" (lens 4).

**Failure mode caught.** Agent-wrapper disease. Thin wrappers around existing capabilities that add ceremony without accuracy or efficiency gain.

---

### Lens 5 — Data flow and representation

**Definition.** What state does this agent consume, produce, and pass to which sibling? Where's the versioned source of truth, where's the lossy handoff?

**When it applies.** At `*architecture-decision` (cross-agent flows). At `*audit-ecosystem` (overlap map, dependency graph, step 7 bidirectional orphan scan).

**Failure mode caught.** Ecosystems fail at interfaces, not inside agents. Two well-designed agents with a fuzzy handoff produce worse output than one mediocre agent.

---

## Claude Code CTO Frame (Lenses 6–10)

### Lens 6 — Permission/tool surface audit [TIER 1]

**Definition.** Every capability expansion is a blast-radius decision. Default answer to "can this agent have this tool?" is no. Burden of proof on yes.

**When it applies.** At `*propose-agent` (initial surface). At `*evolve-agent` (expansion requests). At `*audit-ecosystem` (permission-surface report, step 5).

**Failure mode caught.** Permission sprawl. Agents accumulate capabilities they never use, then get compromised via the unused surface.

**Application note.** BMAD agent YAMLs do not have a dedicated `permissions:` field. Permission surface is **derived** from: (i) menu workflow/exec/action references, (ii) `critical_actions` file loads, (iii) file path references inside action strings, (iv) workflow output paths. This is the verified pattern — do not assume a `permissions:` declaration exists.

---

### Lens 7 — Context window economics

**Definition.** Audit what loads at activation vs. JIT, what bloats over sessions, what gets compacted. An agent that loads 8k tokens at every activation has a design flaw, not a memory need.

**When it applies.** Agent design (what to put in `critical_actions` vs. JIT-load). Workflow design (what to inline vs. reference). This file itself is the canonical example — Chuck's persona references it but does not load it at activation.

**Failure mode caught.** Activation bloat. Every invocation pays for context that most commands don't use; cost scales linearly with session count.

---

### Lens 8 — Subagent delegation architecture

**Definition.** When to spawn a subagent vs. handle inline. The decision is structural (parent context protection, parallelization, context isolation), not convenience.

**When it applies.** At `*architecture-decision` for workflow design. When principle 5 triggers research: parallel subagents for independent questions, single agent for tightly coupled ones.

**Failure mode caught.** Monolithic reasoning that should have been decomposed (context overflow, serial latency). Or over-delegation that adds latency and coordination cost without gain.

---

### Lens 9 — Hook/gate placement

**Definition.** Where in an agent's flow should intervention live? Pre-tool validation, approval gates, confirmation prompts. Safety is architectural, not a runtime afterthought.

**When it applies.** At `*propose-agent` (what gates the new agent enforces). At `*architecture-decision` (cross-agent hook placement — e.g., HALT gates in workflows).

**Failure mode caught.** Post-hoc safety: bolt-on guardrails that miss the relevant failure paths because they were added after the architecture was frozen.

**Orthogonality.** This lens is orthogonal to lens 1 (eval — _what_ passes) and lens 6 (permissions — _what tools_ exist). Hook placement is _where in flow_ checks fire, not _what_ is checked.

---

### Lens 10 — Workflow ergonomics

**Definition.** How does the user invoke this? Is it findable in the menu? Does the trigger name match the intent?

**When it applies.** At `*propose-agent` (trigger naming, menu placement, command-description clarity). At `*audit-ecosystem` (discoverability check via `.claude/commands/` listing).

**Failure mode caught.** Ritual erosion. Agent becomes useful only with specific invocation patterns the user forgets. Unused surface = de facto retirement without an explicit retirement decision.

---

## Extended Lenses (11–17)

### Lens 11 — Instruction bloat and prompt contradiction

**Definition.** Agents accumulate edits over time until their persona subtly contradicts itself. Multi-paragraph principles get edited once, then again, without cross-checking coherence.

**When it applies.** At `*evolve-agent` (every persona edit should trigger a self-contradiction check). At `*audit-ecosystem` once `principles_conflict_check` Phase 2 enforcement is active (N=2 active agents OR first persona modification, per registry trigger).

**Failure mode caught.** Persona self-contradiction. Agent's stated behavior conflicts with itself depending on which part of the persona gets sampled in a given turn.

---

### Lens 12 — Prompt injection (input-side) [TIER 1]

**Definition.** Lens 6 covers what the agent _can_ do. This lens covers what malicious or malformed input can _make_ it do. Agent security ≠ agent permissions.

**When it applies.** Every agent that consumes user input or external content (files, web scraping output, workflow outputs from other agents, MCP tool responses).

**Failure mode caught.** Adversarial manipulation of single-turn agent behavior via crafted input.

**Sources.** OWASP GenAI Security Project, "Agentic AI – Threats and Mitigations" (Feb 2025). MITRE ATLAS `AML.T0080`. Unit 42 prompt injection research.

---

### Lens 13 — Memory/context poisoning (persistent-state) [TIER 1]

**Definition.** Distinct from lens 12. Where lens 12 is per-turn input-side defense, this is persistent-state corruption defense. Once a poisoned memory is written, it persists and influences future sessions.

**When it applies.** Any agent with persistent state: registries, sidecars, memory files, session logs, audit records. At `*evolve-agent` when introducing memory or sidecar writes.

**Failure mode caught.** Slow-burn corruption. Adversarial content written to persistent state shapes agent behavior across future sessions even without renewed injection.

**Sources.** `AAI006` (community OWASP Agentic AI Top 10, precize repo — not the same as a fabricated "ASI06" identifier). Unit 42, "When AI Remembers Too Much – Persistent Behaviors in Agents' Memory" (Jay Chen & Royce Lu, Oct 9, 2025). MITRE ATLAS `AML.T0080` Memory subtechnique.

---

### Lens 14 — Termination awareness

**Definition.** Can this agent correctly detect when it's done? Step repetition, infinite loops, unaware-of-stop-conditions are the failure modes.

**When it applies.** At `*propose-agent` for any iterative or multi-step agent. At workflow design — e.g., audit-ecosystem's HALT gate at step 2 is this lens applied.

**Failure mode caught.** Infinite loops, step repetition, running past completion without recognizing completion.

**Source.** MAST FC1 (Cemri et al., arXiv:2503.13657, UC Berkeley 2025). Cluster 1 failure modes: `FM-1.3` Step Repetition, `FM-1.5` Unaware of Termination Conditions.

---

### Lens 15 — Output verification

**Definition.** Does the agent verify its output before declaring done? Distinct from eval-first (lens 1): eval-first is design-time ("what does 'good' look like?"), output verification is runtime ("does this specific output meet the bar?").

**When it applies.** At `*propose-agent` for any agent that produces consequential output. At workflow design — the audit-ecosystem checklist.md is this lens operationalized against audit records.

**Failure mode caught.** Premature victory declaration, no verification, incorrect verification. MAST reports 21.3% of multi-agent failures are verification-related alone.

**Source.** MAST FC3 (Cemri et al., arXiv:2503.13657). `FM-3.1` Premature Termination, `FM-3.2` No/Incomplete Verification, `FM-3.3` Incorrect Verification.

---

### Lens 16 — Agentic misalignment

**Definition.** Goal-conflict behavior under adversarial framing. Agent pursues its stated objective in ways that conflict with user intent when faced with adversarial goals or escalating stakes.

**When it applies.** Low fit for current deployment profile (solo user, assistive agents, defined tasks, low adversarial surface). Included for completeness.

**Failure mode caught.** Blackmail-style, insider-threat-style, or subtly misaligned behavior when goals conflict — as documented in frontier-lab research on high-autonomy agents.

**Source.** Anthropic agentic misalignment research (2025).

**Priority for this ecosystem.** Deprioritized. Watch for relevance if the ecosystem expands to autonomous deployment, high-stakes decisions, or adversarial user interactions. Not a daily concern for Team Maerg's current profile.

---

### Lens 17 — Capability tier and cost economics

**Definition.** Classify the reasoning tier this agent requires: strategic / ops / low-volume. Tier is design; model is config. When a new flagship model ships, update the `tier_to_model` mapping once — no `agent.yaml` edits.

**When it applies.** At `*propose-agent` (tier selection justified by task demands). At `*evolve-agent` (tier change requires explicit reason). At workflow design (per-step tier optimization — **constrained: BMAD does not currently support per-step tier override as of 2026-04-22; this is a verified framework limitation, not a reasoning call**).

**Failure mode caught.** Overspending (strategic tier for low-volume work) or under-specifying (ops tier for work that requires strategic reasoning).

**Pattern.**

- `capability_tier` field in agent.yaml metadata declares the requirement.
- `tier_to_model` mapping in module `config.yaml` resolves to the current model.
- Optional `model_override` field in agent metadata provides a per-agent experimentation escape hatch (AutoGen `filter_dict` precedent).
- Per-step override would require framework support that doesn't exist; do not recommend it.

---

## Application Notes

**Naming the lens.** Chuck cites the lens(es) driving any recommendation, per his identity contract. "This is a lens 6 concern because..." makes the reasoning auditable in transcripts.

**Multi-lens recommendations.** Load-bearing calls often invoke 2–3 lenses together. Example: retiring an agent invokes lens 3 (ablation) + lens 4 (baseline) + principle 4 (retirement as a feature).

**No lens fits.** If a recommendation can't cite a lens, either (a) the framework is missing something — evidence to revise it — or (b) the recommendation is reasoning from intuition. Per principle 3 (precision), intuition-only reasoning is a failure mode; either name the missing lens or withhold the recommendation.

**Framework evolution.** New lenses should only be added on evidence of a repeatable failure mode the current 17 don't cover. Propose via `*architecture-decision`. Update this file. Bump version below.

---

## Version

**Version 1 — 2026-04-22.**

Content provenance:

- Initial 10 lenses (ML engineer frame 1–5 + CTO frame 6–10), session 2026-04-20.
- +3 extension lenses in first-pass review: instruction bloat, prompt injection, model coupling.
- Research revisions 2026-04-21 against MAST (arXiv:2503.13657), OWASP GenAI Agentic AI Threats, MITRE ATLAS, Unit 42, Anthropic alignment research. Restructured to 16 lenses.
- Chuck's 2026-04-22 review added lens 17 with the design-vs-config reframe ("tier is design, model is config") — final count 17.
- Tier-1 prioritization (lenses 1, 6, 12, 13) chosen by blast radius for solo-assistive deployment profile, not by absolute importance in AI safety literature.

Future edits: update via `*evolve-agent` or `*architecture-decision`. If a registry schema field `lens_framework_version` is added later, it should track this file's version number across audits.
