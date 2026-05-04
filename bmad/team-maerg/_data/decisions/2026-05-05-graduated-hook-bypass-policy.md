<!-- Graduated hook-bypass policy ADR. Refines team-maerg agents' default
     handling of pre-commit hook conflicts from uniform-strict to
     graduated-by-taxonomy with mandatory transparent classification.
     Authored 2026-05-05 in response to today's lint-staged hook bypass
     incident; subagent analysis converged on graduated policy with
     transparent-classification requirement honoring Subagent 1's
     classification-accuracy counter. -->

---

id: 2026-05-05-graduated-hook-bypass-policy
date: 2026-05-05
status: Accepted
title: "Adopt graduated hook-bypass policy (S/P/C/B taxonomy) with mandatory transparent classification"
deciders: ["Chuck (team-maerg)", "Maerg (user)"]
supersedes: null
superseded_by: null

---

# Adopt graduated hook-bypass policy (S/P/C/B taxonomy) with mandatory transparent classification

## Context

Current effective policy for team-maerg agents handling pre-commit hook conflicts: "NEVER skip hooks (`--no-verify`) unless user explicitly requests it." Uniform across hook types, derived from system-level safety protocol guidance. The uniformity is safe in expectation but coarse — treats convenience-formatter bypass as identical-risk to security-gate bypass.

Today's incident (2026-05-05) exposed the operational cost: a buggy lint-staged + prettier hook (script ran prettier across the whole codebase, mangling unstaged files mid-stash) triggered ~30 minutes of bypass-speculation on Chuck's part — drafting a 3-option pros/cons (`--no-verify` / stash-around / defer) when the actual root cause was a 3-line config bug fixable in-place. The uniform policy added friction without surfacing the better path (fix the mechanism). Compounding: Chuck mis-applied the discipline footer to a structural framing question rather than running the targeted diagnostic the error literally named — captured separately as `feedback_diagnose_before_recommend_on_error` and the recommendation-discipline anti-pattern "Footer-as-investigation-substitute."

This ADR ratifies a graduated policy that distinguishes hook types by bypass cost AND mandates transparent classification in agent messages — preserving the safety property of uniform-ask while removing the user-friction cost on convenience hooks.

## Lens citations

- **Lens 9 (subagent delegation architecture):** 2 cold-frame subagents dispatched to test the tradeoff (one first-principles, one BMAD-METHOD-specific). Convergence on graduated policy with the strongest counter (classification accuracy) explicitly addressed.
- **Lens 10 (hook/gate placement):** This decision IS hook policy — defines what hook bypasses warrant gate (Tier S = hard stop), gate-with-confirmation (Tier P), or fix-mechanism-not-bypass (Tier C/B).
- **Lens 11 (workflow ergonomics):** Uniform-strict produces user-facing friction proportional to incidence of Tier C/B failures, not to actual bypass risk. Graduated reduces friction on the common case.
- **Lens 14 (termination awareness, MAST FM-1.5/3.1):** Tier S includes hard-stop on bypass attempt — agent does NOT proceed without explicit user override. Termination-aware on the asymmetric-cost case.
- **Lens 17 (capability tier + cost economics):** Graduated policy avoids over-restricting Tier C bypasses (where bypass cost ≈ a follow-up formatting commit) while preserving over-restriction on Tier S (where bypass cost ≈ unrecoverable security incident).

## Options considered

### Option A: Status quo — uniform "never bypass without explicit user request"

- **What:** Current policy. Agent asks user before any `--no-verify` regardless of hook type.
- **Pros:** Legibly deferential — every bypass is a conscious user act. No agent-judgment-laundering risk.
- **Cons:** Trains rubber-stamping (every-time-asking degrades signal of real bypass requests); shifts diagnostic load to user for Tier C/B problems agent fully understands; uniform-friction even when bypass risk is near-zero.
- **Cost / blast radius:** Status quo. Friction proportional to Tier C/B incidence.

### Option B: Graduated by hook taxonomy with mandatory transparent classification (chosen)

- **What:** Four-tier hook taxonomy (S=security-gate, P=policy-enforcement, C=convenience, B=broken/misconfigured). Agent ALWAYS classifies the hook in its message (declared classification, not silent agent discretion). Behavior varies by tier:
  - **Tier S** (secrets scan, dependency audit, signed commits): NEVER bypass. Hard stop. Surface what tripped, request user resolution.
  - **Tier P** (lint, types, tests): Don't bypass; prefer fix-the-code or fix-the-hook. If bypass is genuinely needed, ASK user (current uniform behavior).
  - **Tier C** (prettier, sort, EOL): Prefer fix-and-restage (re-run formatter, re-stage, retry — not bypass). Bypass only when hook is Tier-B-broken; requires explicit user authorization.
  - **Tier B** (broken/misconfigured regardless of intended tier): Name the bug, classify by underlying tier, apply that tier's policy. PREFER fixing the mechanism over bypassing it (today's incident: 3-line config fix > 1-shot bypass that leaves trap armed).
  - **No classification declared** → defaults to Tier P (ask before bypass). Forces agent to either classify or fall back to safe default.
- **Pros:** Reduces Tier C/B friction; preserves Tier S safety; transparent classification makes agent judgment auditable in real-time; user can override the classification immediately.
- **Cons:** Classification accuracy is itself an agent judgment call — Tier-S-misread-as-C is the catastrophic failure mode. Mitigated but not eliminated by transparent-classification requirement.
- **Cost / blast radius:** Net reduces user-facing friction; introduces new classification-error surface.

### Option C: Full agent autonomy (bypass when convenient)

- **What:** Agent decides on bypass without consultation when the operation looks routine.
- **Pros:** Lowest friction.
- **Cons:** Catastrophic on Tier S (silent secret leak); corrosive on Tier P (silent CI-shifted bugs, eroded team trust); user loses repo agency.
- **Cost / blast radius:** Unbounded on Tier S. Rejected.

## Tradeoffs

**Friction vs rubber-stamp-degradation.** Option A optimizes legibility-of-deference at the cost of training the user to rubber-stamp (which then degrades signal on real Tier S bypass requests). Option B optimizes the common case at the cost of a new classification-accuracy surface. Subagent 1's strongest counter to B: classification-error on Tier S has asymmetric cost — uniform-ask (A) dominates B on expected harm if classification is unreliable.

**Mitigation that resolves the tradeoff:** mandatory transparent classification. The classification is DECLARED in the agent's message every time. This converts Option B's failure mode from "silent agent-discretion-laundered-as-process" into "auditable agent claim the user can override at activation." A declared "Tier C, fix-and-restage" the user can immediately correct to "actually that's Tier S, hard stop"; a silent agent decision the user cannot.

The transparent-classification requirement is what makes Option B safer than it appears in Subagent 1's counter — and what would make a sloppily-implemented graduated policy collapse back into the failure mode the counter names.

## Recommendation

**Option B with mandatory transparent classification.**

Concrete behavior:

1. When a pre-commit hook fails or conflicts with an intended commit, agent runs targeted diagnostic on the error (per `feedback_diagnose_before_recommend_on_error`).
2. Agent reads `.husky/`, `lint-staged.config`, hook script to identify the underlying tools/intent.
3. Agent declares classification in the message: e.g., _"Classifying this hook as Tier C (prettier convenience formatter, broken-implementation due to glob ignoring staged-file paths). Recommended path: fix the mechanism (3-line config change) rather than bypass."_
4. Action follows tier policy (above).
5. User can override the classification at any point.

Convention captured in `bmad/team-maerg/_data/recommendation-discipline.md` so every team-maerg agent inherits at activation. Today's lint-staged incident is the originating record.

## Dissent

**Strongest honest counter** (Subagent 1, preserved verbatim from the audit): _Tier classification is itself an agent judgment call, and a confidently-wrong classification (Tier-S hook misread as Tier-C) is worse than a uniform "always ask" policy — because uniform-ask is at least legibly deferential, whereas tier-routed action launders agent discretion as principled process. Graduated policy optimizes the common case (Tier C noise) at the cost of the rare-but-catastrophic case (Tier S misclassification). If you can't guarantee classification accuracy on Tier S — and the agent can't, hooks are heterogeneous and often undocumented — uniform-ask dominates on expected harm even though it's worse on average friction._

**Counter to the counter:** uniform-ask trains rubber-stamping, which destroys the very safety property it claims to preserve. The transparent-classification requirement converts the agent's judgment from silent discretion into an auditable claim the user can override mid-message. Per Subagent 1's own admission, the counter is an empirical claim about user behavior (does graduated training cause Tier S misclassification incidents? unknown) vs uniform's known failure mode (rubber-stamping is observed).

**Re-audit triggers:** any incident where (a) Chuck (or another team-maerg agent) classifies a Tier S hook as Tier C/B and an actual security cost results, or (b) the user reports the classification declarations themselves becoming noise (suggesting classification labels are decorative rather than load-bearing — collapses back into theatre). Either incident promotes Option A back to default.

## Outcome

- **Decided:** 2026-05-05
- **By:** Chuck + Maerg (consensus this session)
- **As:** Accepted
- **Followup:** recommendation-discipline.md updated in same commit chain to include the hook-classification clause + transparent-classification requirement; team-maerg agents inherit at next activation.

---

## Cross-references

- **Related ADRs:** `2026-04-29-phase-2-cross-module-awareness-convention.md`, `2026-05-01-scalability-roadmap.md`, `2026-05-04-atlas-v2-build.md`.
- **Related lenses:** lens-framework.md — lenses 9, 10, 11, 14, 17 named above.
- **Related principles:** team-principles.md — principle 1 (fact-at-emission, applied to error-as-data), principle 5 (protocols evolve from incidents — today's hook incident IS the originating event), principle 6 (recommendations carry their tier — discipline footer applies to bypass recommendations).
- **Related memories:** `feedback_diagnose_before_recommend_on_error.md` (sibling — error-as-data discipline that complements this), `feedback_check_session_history_before_reinvestigating.md` (caught the redundant-PR move earlier this session), `feedback_evaluate_from_agent_epistemic_frame.md` (subagent dispatch was the right move because subagents have a frame Chuck doesn't).
- **Originating incident:** lint-staged + prettier hook bug surfaced 2026-05-05; commit `c9472f2c` fixed the local instance; upstream `bmad-code-org/BMAD-METHOD/main` (v6.6.0) had already fixed the same bug independently — verified before opening a redundant PR.
- **Subagent reports (this session):** First-principles hook-permission analysis (Tier S/P/C/B taxonomy + sovereignty matrix + uniform-policy failure modes); BMAD-METHOD-specific optimization (Option D fix-the-mechanism + meta-policy graduation recommendation).
