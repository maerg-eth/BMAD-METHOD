<!-- ADR template for Chuck's *architecture-decision workflow.
     Loaded JIT by workflows/architecture-decision/instructions.md.
     Per the build research (2026-04-29):
     - Nygard's canonical ADR structure (Title, Status, Context, Decision, Consequences) is the base.
     - MADR adds Considered Options + Decision Drivers — included.
     - Chuck-specific extension: Lens citations REQUIRED + Dissent slot REQUIRED (principle 8).
     - Per OWASP/MAST research: "objectives, not hypotheses" — prompt sub-research with neutral options framing, not pre-formed conclusions. -->

---

id: <YYYY-MM-DD-slug>
date: <YYYY-MM-DD>
status: Proposed | Accepted | Superseded
title: "<imperative title — what the decision does>"
deciders: ["<name or role>"]
supersedes: null
superseded_by: null

---

# <title>

## Context

<Plain-language statement of the problem driving this decision. What broke, what's needed, what constraint is in play. Aim for: a future maintainer reads this in 18 months and understands WHY without reading the surrounding code. ~100-300 words.>

## Lens citations

**REQUIRED.** Name the Chuck lenses driving this analysis, with one-line justification each. If a recommendation cannot cite a lens, per `feedback_smallest_enforceable_strip_down.md` and the lens-framework's "no lens fits" rule, either name a missing lens (and propose adding it via \*architecture-decision recursion) or withhold the recommendation.

- Lens N (<name>): <one-line why this lens applies>
- Lens M (<name>): <one-line why>
- (etc.)

## Options Considered

**Minimum 2 options.** Single-option ADRs are a smell — they document foregone conclusions, not decisions. If only one option is viable, name the alternatives ruled out and why.

### Option A: <name>

- **What:** <description>
- **Pros:** <list>
- **Cons:** <list>
- **Cost / blast radius:** <effort estimate, scope of change, reversibility>

### Option B: <name>

- **What:** <description>
- **Pros:** <list>
- **Cons:** <list>
- **Cost / blast radius:** <effort estimate, scope of change, reversibility>

<!-- Add Option C, D... as needed -->

## Tradeoffs

<What factor most differentiates these options? Cost vs. correctness? Scope vs. simplicity? Reversibility vs. up-front commitment? Name the axis explicitly so a future reader can re-evaluate if priorities shift.>

## Recommendation

<Which option. Why — cite the lens(es) applied and principle(s) invoked. If derived from research subagents, attribute the load-bearing finding to the specific subagent (per Anthropic's "objectives, not hypotheses" + integration-drift mitigation: cite which subagent's claim drove which conclusion).>

## Dissent

**REQUIRED — Principle 8 (dissent openly, commit fully).** Articulate the strongest honest argument AGAINST the recommendation. If genuinely none, write "None — recommendation is structurally clean." Absence-of-dissent on a non-trivial decision is itself a finding to surface (it means we may not have explored the option space).

<the dissent>

## Outcome

<Filled AFTER ratification. Initially: "Pending ratification.">

- **Decided:** <date>
- **By:** <user / agent / consensus>
- **As:** <Accepted | Modified | Rejected>
- **Followup commits:** <git hashes if implementation followed>

---

## Cross-references

- **Related ADRs:** <ids, if any prior decisions inform this>
- **Related lenses:** <full text in `bmad/team-maerg/_data/lens-framework.md`>
- **Related principles:** <full text in `bmad/team-maerg/_data/team-principles.md`>
- **Session / commits:** <git refs, transcript pointers if useful>
