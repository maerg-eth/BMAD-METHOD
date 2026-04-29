# Architecture-Decision Workflow Instructions

<critical>The workflow execution engine is governed by: {project-root}/bmad/core/tasks/workflow.xml</critical>
<critical>You MUST have already loaded and processed: {project-root}/bmad/team-maerg/workflows/architecture-decision/workflow.yaml</critical>
<critical>Communicate in {communication_language} throughout the workflow process</critical>
<critical>This is an action-workflow (template: false). The engine does NOT auto-create the decisions directory — step 1 performs an explicit mkdir before any writes.</critical>
<critical>Per build research (2026-04-29): research subagents are JUDGMENT-DRIVEN at step 3, not auto-fired. Default to single-agent reasoning unless the option space is breadth-bound. Spawning by default uses ~15× tokens (Anthropic data, June 2025) without quality gains for ≤3-hop tasks (Zhang et al., 7/12 reasoning benchmarks).</critical>

<workflow>

<step n="1" goal="Load inputs and frame the decision question">

<action>Run `mkdir -p {decisions_folder}` via Bash. Action-workflow engine does not create this directory.</action>

<action>Determine the decision question:

- If the user provided a question parameter at invocation, use it directly.
- Otherwise, ask the user: "What architecture decision needs analysis? State the question in one sentence."

Wait for response. Store as {{question}}.

The question should describe a non-trivial structural call: split / merge / retire an agent, hook-layer placement, autonomous-deployment topology, framework-wide convention, capability-tier reassignment. If the question reads as trivial (single-file edit, typo fix, content tweak), return to user: "This doesn't appear to require an architecture decision. Proceed with a direct edit instead." HALT.</action>

<action>Generate a slug for the ADR filename: lowercase the question, strip non-alphanumeric chars, join non-empty tokens with hyphens, truncate to 50 chars. Confirm with user (allow override). Store as {{slug}}.</action>

<action>Determine final ADR filepath: `{decisions_folder}/{{date}}-{{slug}}.md`. If that file already exists (same-day re-run on the same question), append `-HHMMSS` suffix via `date +%H%M%S`. Store as {{adr_filepath}}.</action>

<action>Load these files in full:

- ADR template at {adr_template}
- Lens framework at {lens_framework}
- Team principles at {team_principles}
- Prior decisions glob at `{decisions_folder}/*.md` (for cross-reference + supersedes detection)

Store parsed contents in working state.</action>

</step>

<step n="2" goal="Lens framework analysis and team-principle conflict check">

<action>Identify which Chuck lens(es) are load-bearing for this decision. The lens framework defines 17 lenses across two frames (ML engineer 1-5, CTO 6-10) plus extended lenses 11-17.

For each lens that materially applies, record:

- Lens number and name
- One-sentence justification

Minimum: ≥1 lens must apply. If no lens fits cleanly, per the lens framework's "no lens fits" rule, either (a) propose a new lens (note in working state for inclusion in the ADR's Outcome / cross-references section), or (b) withhold the recommendation pending lens addition.

Store as {{lens_citations}}.</action>

<action>Surface team-principle conflicts. For each team principle (1-5 in team-principles.md), check whether the proposed decision creates a conflict on the same axis (per principle 5's coherence-attestation pattern).

If any conflict: HALT and surface to user — _"Decision implicates team-principle conflict on axis X. Per principle 5's runtime conflict clause, requesting resolution before proceeding."_ Wait for user resolution before continuing.

If no conflicts: proceed.</action>

</step>

<step n="3" goal="Subagent-spawning judgment">

<critical>Default: single-agent reasoning. Spawn research subagents ONLY when the option space is breadth-bound. Per build research:

- Multi-agent research costs ~15× single-agent CoT tokens (Anthropic, "Building Multi-Agent Research System", June 2025)
- Single-agent matches or beats multi-agent on ≤3-hop tasks (Zhang et al., arXiv:2310.10701, 7/12 benchmarks)
- Multi-agent justified for: parallelizable + breadth-bound + multi-source fact-lookup + >3 reasoning hops</critical>

<action>Apply this decision algorithm:

```
spawn_signals = 0
if question requires external fact-lookup (frameworks, libraries, papers, benchmarks): spawn_signals += 1
if option space has >= 3 plausible options each needing independent research: spawn_signals += 1
if estimated reasoning hops to recommendation > 3: spawn_signals += 1
if user explicitly requested research subagents: spawn_signals += 2

if spawn_signals >= 2:
  proceed to substep 3a (spawn)
else:
  proceed to substep 3b (inline)
```

Record the score and rationale in working state for the ADR's Recommendation section.</action>

<check if="spawn_signals >= 2">

<action>Substep 3a — Spawn research subagents with HETEROGENEOUS prompts.

For each research question identified in step 2, design a prompt with:

- **Objectives, not hypotheses** (per Anthropic's research-system guidance — give subagents what to find out, not what to confirm).
- **Adversarial framing** where applicable (per `feedback_adversarial_verification.md`): "what evidence would falsify the obvious answer?"
- **Citations required** where the question is fact-lookup; reasoning-with-attribution required where it's tradeoff analysis.
- **Tight token budget** (under 600 words output by default).
- **Heterogeneous framing across subagents** to mitigate correlated-error / rubber-stamp failure (MAST FM-1.1, FM-2.4).

Spawn in parallel via Agent tool with `run_in_background=true`. When all return, integrate findings.</action>

<action>Integration discipline (per MAST FM-2.6/3.3 mitigations + recommendation-laundering risk):

- For each conclusion drawn into the ADR, cite which specific subagent's claim drove it.
- Do NOT collapse findings into a single anonymous voice.
- If subagents disagreed, surface the disagreement in the ADR's Tradeoffs or Dissent section — disagreement is signal.</action>

</check>

<check if="spawn_signals < 2">

<action>Substep 3b — Inline single-agent reasoning.

Reason through the option space directly. Apply the lens framework. If the analysis surfaces unanticipated fact-lookup mid-stream, it's acceptable to spawn a single targeted subagent at that point — flag the deviation in the ADR's Recommendation section as "single subagent spawned at <reason>; original spawn_signals=N."</action>

</check>

</step>

<step n="4" goal="Generate options and tradeoffs">

<action>Identify a minimum of **2 options**. Single-option ADRs are an anti-pattern (per MADR documentation) — they document foregone conclusions, not decisions. If only one option seems viable, name the alternatives ruled out and why; they belong as documented context, not absent.

For each option, fill:

- **What:** plain-language description of what the option does
- **Pros:** list
- **Cons:** list
- **Cost / blast radius / reversibility:** effort estimate, scope of change, ease of reversal

Store as {{options}}.</action>

<action>Identify the **axis of choice** — which factor most differentiates the options? (e.g., cost vs correctness, scope vs simplicity, reversibility vs commitment, in-lane vs cross-lane). Naming the axis lets a future reader re-evaluate if priorities shift. Store as {{axis_of_choice}}.</action>

</step>

<step n="5" goal="Recommendation and dissent">

<action>Form the recommendation:

- State which option.
- Cite specific lenses from {{lens_citations}} that drive the call.
- Cite specific principles invoked (registry-as-source-of-truth, lane-staying, etc.).
- If substep 3a fired, attribute load-bearing conclusions to specific subagent claims.

Store as {{recommendation}}.</action>

<action>Articulate **dissent** (principle 8 — dissent openly, commit fully). The strongest honest argument AGAINST the recommendation.

If genuinely none: write _"None — recommendation is structurally clean."_ But treat absence-of-dissent on a non-trivial decision as a finding worth flagging — it usually means the option space wasn't fully explored. Re-examine before accepting "no dissent."

Store as {{dissent}}.</action>

</step>

<step n="6" goal="Validate against checklist, write ADR, surface ratification">

<action>Run validation against {validation} (checklist.md). Required checks:

- Title is imperative (not interrogative).
- Status is one of: Proposed, Accepted, Superseded.
- Context section is filled (no template placeholders remaining).
- Lens citations: ≥1 lens with one-line justification.
- Options Considered: ≥2 options each with What/Pros/Cons/Cost.
- Tradeoffs: axis of choice named.
- Recommendation: cites lenses and (if substep 3a fired) subagent attributions.
- Dissent: present (even if "none — structurally clean").

If any check fails: HALT, surface to user with the specific failure, allow inline fix before write.</action>

<action>Render the ADR by filling {adr_template} with working state ({{question}}, {{slug}}, {{lens_citations}}, {{options}}, {{axis_of_choice}}, {{recommendation}}, {{dissent}}). Set Status: Proposed.

Write to {{adr_filepath}} via the Write tool.</action>

<ask>ADR written to {{adr_filepath}} with Status: Proposed. Ratify now?

(a) **Accept** — set Status: Accepted, fill Outcome (Decided/By/As).
(b) **Modify** — describe modifications inline; loop back to step 5 with revised recommendation.
(c) **Reject** — set Status: Rejected (non-canonical but documents the call), fill Outcome with rejection reason.
(d) **Defer** — leave as Proposed; ratification happens later.</ask>

<action>Apply user response: edit the ADR's Outcome section accordingly. For (b) Modify, goto step 5 with revised input. For (a)/(c)/(d), proceed to final report.</action>

<action>Report to {user_name} in {communication_language}: "Architecture-decision complete. ADR at {{adr_filepath}}, status: <Proposed|Accepted|Modified|Rejected|Deferred>. Follow-up actions surfaced in the Recommendation section of the ADR if any."</action>

</step>

</workflow>
