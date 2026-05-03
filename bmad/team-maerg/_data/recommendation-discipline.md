<!-- Team-Maerg recommendation discipline: tier-triaged decision-making methods
     applied at every recommendation surface. Authored 2026-05-03 from Q8 of
     Atlas v2 *create-agent flow. Behavior-tested before lock — see footer.
     Loaded by every team-maerg agent's <critical-actions>. -->

# Recommendation Discipline

**Purpose:** Force structured decision-making at every recommendation surface so recommendations are inspectable, falsifiable, and routable. Not ceremony — a mechanical floor that catches the cases where free-form reasoning silently misses an inversion or a downstream cost.

**Scope:** Applies at every **recommendation surface** (the moment an agent says "I recommend X" or equivalent), not every output line. A briefing of 10 priority items is one recommendation (the surfacing + ordering), not ten. A `*route` is one recommendation. A sprint state assessment is one recommendation.

## Tier triage — 5 mechanical triggers

```
default_tier = 1
+1 if NOT reversible in <1 day with no external commitments
+1 if commits anyone besides agent + user
+1 if consequence outlives current sprint
+1 if no cached answer / prior decision (novel)
+0 if cross-lane → route, don't recommend (separate concern)

if 2+ triggers fired AND structural → route to *architecture-decision
```

Mechanical, not deliberative. The triage is computed in-turn and cached as `Triggers: <list>` in the footer.

## Tier 1 — universal floor (routine recommendations)

Apply on every recommendation regardless of triggers fired.

- **Provenance citation** — name the rule / principle / lens / framework / Pearl / prior decision the recommendation rests on. One phrase. Prevents recommendation laundering ("this seemed right").
- **Inversion** — one sentence: "what would make this wrong?" Forces an adversarial check before commit.

**Cost:** ~2 lines per recommendation. **Catches:** silent failures where the un-disciplined recommendation feels right but rests on the wrong rule, or where a single condition would flip it.

## Tier 2 — adds when 1 trigger fires

Apply Tier 1 plus:

- **Second-order consequence** — "and then what?" One downstream effect of taking the recommendation.
- **Tradeoff axis** — name the runner-up option and the axis you chose along (speed vs reversibility, scope vs blast radius, etc.).
- **Steelmanned dissent** — strongest honest counter to the recommendation. Concrete, not generic ("it could fail" is not dissent; "if stakeholder is normally same-day, the threshold is wrong" is).

**Cost:** ~5-line footer. **Catches:** recommendations that feel like simple calls but commit someone or extend past the sprint — where the unspoken alternative or downstream cost matters.

## Tier 3 — structural call routing

When 2+ triggers fire AND the call is structural (changes architecture, lane boundaries, agent surface, or shared infrastructure), **route to `*architecture-decision`** instead of footnoting in-turn. Pre-mortem and full lens analysis live in that workflow's instructions; do not duplicate inline.

The Tier 3 footer is one line: `→ routes to *architecture-decision`.

**Important — high-trigger non-structural stays T2 (full footer), not T3.** Tactical calls with 3-4 triggers (e.g., cross-plane scheduling cascades, multi-stakeholder commitment collisions) deserve the full T2 footer but do NOT route to `*architecture-decision`. The structural gate is what triggers the workflow; high stakes alone don't. Verified 2026-05-03 against Atlas-shape Case 3 (cross-plane cascade with 4 triggers, tactical) — discipline correctly held it at T2-full rather than escalating.

## Method library — what each method does

| Method                    | Tier | Function                                                                             |
| ------------------------- | ---- | ------------------------------------------------------------------------------------ |
| **Provenance citation**   | T1   | Names the rule the recommendation rests on. Auditability.                            |
| **Inversion**             | T1   | "What would make this wrong?" Adversarial sanity check.                              |
| **Second-order thinking** | T2+  | "And then what?" Forward consequence.                                                |
| **Steelmanned dissent**   | T2+  | Concrete alternative that would flip the recommendation under specific conditions.   |
| **Pre-mortem**            | T3   | "Assume this failed in 6 weeks; why?" Captured by `*architecture-decision` workflow. |

Cynefin diagnosis (Clear / Complicated / Complex) sits in the background as the language for _why_ the tiers exist (different domains warrant different rigor); the 5 mechanical triggers are how an agent computes its tier in-turn.

## Footer shape (canonical output form)

**T1:**

```
Recommendation: <action>
Tier: 1  Triggers: none — routine
Rule: <named principle / lens / framework / Pearl>
Inversion: <one-sentence "what would make this wrong">
```

**T2:**

```
Recommendation: <action>
Tier: 2  Triggers: <which fired>
Rule: <named source>
Inversion: <one sentence>
Second-order: <downstream consequence>
Tradeoff axis: <runner-up + axis of choice>
Dissent: <concrete flip condition>
```

**T3:**

```
Recommendation: route to *architecture-decision
Tier: 3  Triggers: <which fired>
Rule: <provisional framing>
→ pre-mortem + full lens analysis captured in *architecture-decision workflow output
```

## Composition with existing \_data/ resources

| Resource                                           | Relationship                                                                                                                                                                                           |
| -------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `team-principles.md`                               | Principles are _what_ agents operate under. Discipline is _how_ recommendations get produced. Orthogonal — both load.                                                                                  |
| `lens-framework.md`                                | Lenses are architecture-time analytical surfaces (Chuck's design discipline). Discipline is recommendation-time output discipline (every team-maerg agent). Tier 1 footer citing a lens is the bridge. |
| `architecture-decision-template.md` + `decisions/` | Tier 3 routes here. Template's pre-mortem section satisfies the T3 surfacing.                                                                                                                          |
| `ecosystem-registry.yaml`                          | Discipline references registry rows when recommending agent-affecting changes (last_reviewed, capability_tier).                                                                                        |

## Anti-patterns

- **Footer-spam.** Applying the footer to every priority line in a brief instead of the brief itself. Recommendation surface = the act of recommending, not every nested item.
- **Footnoting non-recommendations.** Factual lookups ("what time is the call?"), status reports ("SP002 is at 60% capacity"), pure single-task routing of an already-fully-tagged item — these are NOT recommendation surfaces. No footer. The discipline activates when an agent is choosing between options, not when it's reporting state.
- **Theatre footers.** T1 footer that always says "Inversion: this could be wrong if user disagrees" is not inversion — it's filler. Inversion must name a concrete condition.
- **Tier-inflation.** Footnoting routine routing as T2 because more lines feel safer. Triggers are the gate; if 0 fired, T1 is correct.
- **Tier-deflation.** Skipping T3 routing on a structural call because "I've already decided." Tier 3 is the discipline that you HAVEN'T already decided unless the workflow output exists.
- **Generic dissent.** "It could fail" is not dissent. Concrete dissent names a flip condition: "if X, recommendation flips to Y."
- **Discipline as gate-keeping.** This is a producer-side discipline. The user can override at any tier; discipline records the reasoning, doesn't block the user.

## Behavior test record (lock gate)

Before this discipline locked, two test cases verified the footer changed recommendation behavior on honest application:

1. **T1 routing call** ("which agent gets task tagged [:brix, :content]?") — inversion line forced explicit check on whether strategic frame was settled, catching off-distribution cases free-form gloss.
2. **T2 sprint state** ("4-day stall — escalate or carry?") — dissent line surfaced per-stakeholder threshold question that would flip the recommendation under realistic conditions; second-order line named carryover-to-next-sprint as concrete cost.

Test passed. Discipline ratified 2026-05-03. Re-test trigger: any agent reports the footer becoming ceremony (no recommendation behavior change observed across 5+ uses).

## Calibration

Quarterly review (or on `*audit-ecosystem` cadence): sample 10 recent recommendations across active agents. For each, ask: did the footer change behavior? If <30% changed behavior, compress; if >70% routed to T3, the trigger threshold is too low. Adjust file, version-bump.
