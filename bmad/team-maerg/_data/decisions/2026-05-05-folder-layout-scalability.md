<!-- Folder-layout scalability ADR. Authored 2026-05-05 in response to Maerg's
     screenshot observation of disorganized BMAD-METHOD root structure.
     Companion to (NOT superseding) 2026-05-01-scalability-roadmap.md, which
     covers agent-system internals (registries, sidecars, memory architecture).
     This ADR covers filesystem/repo topology specifically.
     Spawn signals at workflow step 3: 0 by algorithm; overridden per
     feedback_research_before_structural_questions.md (REFINED 2026-05-05) —
     FS/migration recommendations with orphan-side-effect surface trigger
     adversarial fan-out regardless of breadth-bound option space. Three
     subagents dispatched; their disagreement preserved in Tradeoffs and Dissent. -->

---

id: 2026-05-05-folder-layout-scalability
date: 2026-05-05
status: Accepted
title: "Adopt tier-by-state-type internal restructure (smallest variant) for team-maerg human-edited state"
deciders: ["Chuck (team-maerg)", "Maerg (user)"]
supersedes: null
superseded_by: null

---

# Adopt tier-by-state-type internal restructure (smallest variant) for team-maerg human-edited state

## Context

Today (2026-05-05), Maerg surfaced a structural observation while scanning the BMAD-METHOD project tree in Finder: the foldering "looks incredibly disorganized." Three concrete causes diagnosed from the screenshot:

1. **No separation between vendored upstream and personal-team work at root.** ~17 entries in `BMAD-METHOD/` mix upstream framework files (`package.json`, `node_modules/`, `src/`, `test/`, `tools/`, `LICENSE`, `eslint.config.mjs`, `prettier.config.mjs`, `CHANGELOG.md`) with personal-team work (`bmad/team-maerg/`).
2. **Human-edited state is 5 levels deep.** `preferences.yaml`, `memories.md`, `weekly-plans/` live at `bmad/team-maerg/agents/lyra-sidecar/…`. Files Maerg (or Lyra acting on his behalf) actually edits require a 5-segment path to reach.
3. **`bmad/` vs `bmd/` one-character collision** at root. (`bmad/` = framework runtime, `bmd/` = installer module from recent `cli-chief` commits.)

After reframing toward scalability ("what are the best way to keep the system for scalability"), this ADR locks scope at **filesystem/repo topology only** — agent-system internal scalability (registries, sidecar pattern, memory architecture, dual-id, module-parametric workflows) is covered by the still-`Proposed` `2026-05-01-scalability-roadmap.md` and is not re-litigated here.

Roadmap framing: team-maerg has 3 active agents today (Chuck, Atlas, Lyra) and is growing toward N=8+ over coming sessions (planning SME, sprint SME, San v2 strategist, future Vox / Accel / Follett). The decision needs to scale through that growth without forcing retroactive restructure at every N+1.

Spawn signals at workflow step 3 computed to 0 by the workflow's algorithm (no external fact-lookup mandate, ≤3 reasoning hops, user did not explicitly request subagents, option space well-understood). **Override declared** per `feedback_research_before_structural_questions.md` (REFINED 2026-05-05): for FS/migration recommendations on the telling side, three orphan-side-effect triggers fire (reversibility cost includes orphan side-effects; outlives sprint; novel restructure type). Three heterogeneous research subagents dispatched in parallel; their findings — including a productive disagreement on time-horizon weighting — drove this ADR.

## Lens citations

- **Lens 1 (Eval-first) [TIER 1]:** Layout success has measurable criteria — depth-to-frequent-edit-state, orphan-side-effect counts, agent-flow regression after move, upstream-pull conflict rate. The recommendation can be evaluated post-implementation; this lens is what makes it falsifiable.
- **Lens 5 (Data flow and representation):** Folder layout determines where state lives (sidecars, registries, decisions, handoffs, automations-registry, knowledge files) and which agents can touch which paths. State organization should match access pattern (edit cadence) — not ownership entity.
- **Lens 6 (Permission/tool surface audit) [TIER 1]:** Folder structure is part of permission-derivation per BMAD's pattern (paths in agent instructions = effective permission surface). Restructuring is a permission surface change, not cosmetic.
- **Lens 10 (Workflow ergonomics):** Discoverability and findability for both human (Maerg editing `preferences.yaml`) and agent (locating cross-references). Deep nesting and naming collisions are ergonomic anti-patterns at any scale; compound at N=8+.
- **Lens 11 (Instruction bloat / prompt contradiction):** Hardcoded `bmad/team-maerg/...` strings in agent instructions force prose drift on every restructure. Layout-stability matters; this is also flagged as Tier A item A3 in `scalability-roadmap.md`.

Secondary (cited but not load-bearing): Lens 2 (failure-mode inventory of restructure costs), Lens 3 (ablation — what breaks if we don't), Lens 13 (persistent-state surface).

## Options Considered

### Option A: In-repo hoist (team-maerg → top-level)

- **What:** Move `bmad/team-maerg/` to repo top-level `team-maerg/`. Internal structure unchanged. Other `bmad/<module>/` dirs (bmb, bmd, core, \_cfg) untouched.
- **Pros:** Personal work visible at root, not buried in framework module pattern. Memory dir at `~/.claude/projects/-Users-maerg-Projects-Agentic-BMAD-METHOD/` survives (cwd unchanged).
- **Cons:** Doesn't address depth-5 state (sidecars still nested inside agents). Doesn't fix `bmad/`/`bmd/` root collision (both stay at root). Triggers BMAD installer manifest reconciliation drift — `bmad/_cfg/agent-manifest.csv` + `files-manifest.csv` carry team-maerg rows expecting `bmad/<module>/` shape.
- **Cost / blast radius / reversibility:** **HIGH** — 231 hardcoded `bmad/team-maerg/...` rewrites across 30 files, manifest regen, slash-command re-registration in `.claude/commands/bmad/team-maerg/agents/*.md`, 3 `/schedule` routines (`trig_017kd3VrhFhLahp6egKMzZzE`, `trig_017T8JrZ3ta3LbEydYBibbAZ`, `trig_0194Sn2AFGzTFckQDPvDkQLd`) need recreation due to CWD-baked-at-creation orphan. Reversible mechanically; routine state doesn't auto-rewind.

### Option B: Repo split (BMAD as dependency, team-maerg standalone)

- **What:** Move team-maerg to `~/Projects/team-maerg/` as own repo. BMAD-METHOD becomes vendored or submoduled dependency at a tracked tag.
- **Pros:** Industry-canonical pattern — Doom Emacs `~/.doom.d/`, LazyVim/NvChad starter-as-plugin, Claude Code `~/.claude/skills/`, chezmoi separate dotfiles repo all converged here (Subagent 3). Upstream-pull friction → 0; personal repo never collides. Maximum top-level separation.
- **Cons:** Subagent 2 ranks **HIGHEST orphan-side-effect risk** based on actual codebase inspection. CWD changes → encoded memory dir orphans (45 MB transcript history, 27 memory files just migrated this session per the iCloud-Desktop-sync recovery). 3 `/schedule` routines fire against phantom path. `bmad/_cfg/agent-manifest.csv` cross-repo break. Cross-repo `{project-root}` resolver design needed. Adversarial: schema drift on upstream `_cfg/` between repo bumps creates silent consumer-side breakage (Subagent 3's Doom-style failure citation: [doomemacs #88](https://github.com/doomemacs/doomemacs/issues/88)).
- **Cost / blast radius / reversibility:** **VERY HIGH** — every cost from A + cwd migration + memory-dir handling + cross-repo bridge + routine recreation. Reversibility low — once split, untangling shared state is hard.

### Option C: Surface compression (gitignore + IDE rules)

- **What:** No path moves. `.git/info/exclude` to suppress upstream noise; `.vscode/settings.json` with `files.exclude` for IDE-side hiding; potentially checked-in workspace settings for portability.
- **Pros:** Zero path mutations. All 231 references stable, manifests stable, routines stable, memory dir stable. Fully reversible.
- **Cons:** Treats symptom not cause. Doesn't address depth-5 state (the most-painful current friction). Doesn't fix `bmad/`/`bmd/` collision. Doesn't scale — at N=8+ the underlying disorganization compounds. `.git/info/exclude` is local-only untracked → fresh clone (e.g., post-eviction-recovery) silently loses every hide rule (Subagent 2's silent-failure finding).
- **Cost / blast radius / reversibility:** **LOW** — config-only changes. Trivially reversible.

### Option E: Tier-by-state-type internal restructure (within current location) — chosen

- **What:** Keep `bmad/team-maerg/` as the team root. Reorganize WITHIN it from agent-entity-grouping to state-type-tier-grouping per Letta / Claude Code conventions. **Smallest variant for v1:** hoist human-edited state only — `preferences.yaml`, `memories.md`, `memories-autonomous-log.md` from `bmad/team-maerg/agents/<x>-sidecar/` to `bmad/team-maerg/state/preferences/<x>.yaml` and `state/memories/<x>.md`. Agent definitions, instructions.md, and knowledge dirs stay in current location. Defer agent-instruction and knowledge-tier hoist to v2 if evidence accumulates.
- **Pros:** Aligned with AI-agent-native convention (Letta, Claude Code skills, Doom, Spacemacs): tier-by-state-type, not by ownership-entity (Subagent 1's load-bearing finding). Improves semantic-organization (state gets its own discoverable tier rather than being buried under entity-grouped sidecar dirs). Lower path-rewrite cost than A/B/F (only sidecar-state references, ~30-50 paths in agent instruction files, not all 231). Memory dir + 3 routines + manifests all preserved (cwd unchanged, top-level shape unchanged). Slash-command paths unchanged.
- **Honest scope note:** E does NOT reduce absolute path depth from repo root (sanity-check correction post-draft — original framing claimed "5→3" which was wrong). State files move from `bmad/team-maerg/agents/<x>-sidecar/preferences.yaml` (depth 5) to `bmad/team-maerg/state/preferences/<x>.yaml` (also depth 5). The win is semantic clarity, not absolute depth. Depth reduction requires team-maerg hoist (F = A+E together) or repo split (B).
- **Cons:** Doesn't address top-level mixed concerns (still inside `bmad/<module>/`). Doesn't fix `bmad/`/`bmd/` collision. Re-paths each agent's sidecar-state references in their instructions.md. Each agent's `*reflect` / `*add` / `*memory-write` flow needs verification post-move.
- **Cost / blast radius / reversibility:** **MEDIUM** — sidecar paths in 3 agent instruction files (atlas-sidecar/instructions.md, lyra-sidecar/instructions.md, chuck.md if any state refs) + ~10 cross-references in `_data/`. Manifests + routines + slash-commands all unchanged. Reversibility: medium.

### Briefly considered, ruled out for primary recommendation

- **Option D (Submodule):** BMAD-METHOD pinned as git submodule inside parent personal repo. Subagent 2 surfaced manifest foot-gun — `bmad/_cfg/agent-manifest.csv` carries team-maerg rows but would live in pinned submodule; `bmad:install` writes commit to detached HEAD and silently lost on next `git submodule update`. With ~0 cherry-pickable upstream commits/window, ceremony is pure overhead. **Rejected** on structural grounds.
- **Option F (A + E composition):** Combines A's hoist with E's tier-restructure atomically. Addresses ALL three concerns (top-level + depth + indirect collision fix). **Cost: VERY HIGH** — A's 231 paths + E's state reorganization in a single atomic migration window. **Deferred** — atomic migration concentrates 6-7 distinct orphan-classes (memory dir, routines, manifests, slash-cmds, gitignore, cross-refs, instructions paths); two staged commits (E now, A later if/when triggered) lower-risk.

## Tradeoffs

**Axis of choice: scope of structural commitment-now × scalability ceiling vs cost-and-orphan-risk.**

| Option | Commitment scope | Scalability ceiling                 | Cost-now  | Orphan risk                                                       |
| ------ | ---------------- | ----------------------------------- | --------- | ----------------------------------------------------------------- |
| C      | Defer entirely   | Low (caps near N=5)                 | Low       | Near-zero                                                         |
| E      | State-only       | Medium (caps at upstream-pull-pain) | Medium    | Low — paths preserved                                             |
| A      | Top-level only   | Medium (same ceiling as E)          | High      | Medium — manifest + routines                                      |
| B      | Full separation  | High (industry-canonical)           | Very high | High — cwd change + routine + manifest cross-repo + memory orphan |

**Subagent disagreement (preserved as signal):**

- Subagent 3 optimizes long-term upstream-pull friction. Industry convergence: every comparable ecosystem (Doom Emacs, LazyVim, NvChad, Claude Code skills, chezmoi) moved to repo-split BEFORE forks accumulated drift. **Recommends B.**
- Subagent 2 inspected the actual codebase and ranks **B HIGHEST risk** — 231 paths, 3 routine IDs with CWD baked at creation, manifest SHA hashes, memory-dir orphan. **Risk-order C < A < D < B.**

The disagreement is the signal — they're both right on their axes; the recommendation has to weight time horizon and pick where on the cost ladder the decision sits.

**Empirical anchor (per principle 1, fact-at-emission):** Subagent 2's findings come from actual codebase inspection of THIS repo — concrete numbers, actual routine IDs, real manifest SHA hashes. Subagent 3's recommendation comes from external-pattern analogy. Empirical findings about THIS codebase weighted more heavily; the analogy is signal that B fits at SOME future scale, not proof B fits HERE today.

## Recommendation

**Option E (smallest variant) — tier-by-state-type internal restructure scoped to human-edited state.**

Concrete shape:

```
bmad/team-maerg/
├── agents/
│   ├── chuck.md                        # unchanged
│   ├── atlas.md                        # unchanged
│   ├── atlas-sidecar/
│   │   ├── instructions.md             # stays — agent-built, infrequent human edit
│   │   └── knowledge/                  # stays — v1 scope
│   ├── lyra.md                         # unchanged
│   └── lyra-sidecar/
│       ├── instructions.md             # stays
│       └── knowledge/                  # stays
├── state/                              # NEW tier
│   ├── preferences/
│   │   └── lyra.yaml                   # MOVED from lyra-sidecar/preferences.yaml
│   └── memories/
│       ├── atlas.md                    # MOVED from atlas-sidecar/memories.md
│       ├── atlas-autonomous-log.md     # MOVED from atlas-sidecar/memories-autonomous-log.md
│       ├── lyra.md                     # MOVED from lyra-sidecar/memories.md
│       └── lyra-autonomous-log.md      # MOVED from lyra-sidecar/memories-autonomous-log.md
├── _data/                              # unchanged (already at depth 3)
├── workflows/                          # unchanged
└── config.yaml                         # unchanged
```

**Why (lens citations + principles):**

- **Lens 1 (Eval-first):** Measurable success — zero orphan-side-effect counts post-move, agent `*reflect` / `*add` / preference-update flows verified working on real data, state-tier discoverability test passes ("where do I find preferences?" → answer is `state/preferences/`, not "look inside the agent's sidecar dir").
- **Lens 5 (Data flow):** Aligns layout to access pattern by tier (state vs definitions vs knowledge), even though absolute path depth from repo root is unchanged under E-alone. Discoverability for both human (find preferences via `state/`) and agent (cross-reference state files by tier) improves.
- **Lens 6 (Permission surface):** ~6-8 file moves vs A's 231 hardcoded paths touched.
- **Lens 10 (Ergonomics):** Improves semantic discoverability of human-edited state — state gets its own tier rather than being buried under entity-grouped sidecar dirs. **Does NOT reduce absolute path depth** (post-draft sanity-check correction; original "5→3" claim was wrong); that benefit would require F (A+E together) or B. E is a semantic-clarity fix, not a depth fix.
- **Lens 11 (Instruction bloat):** ~30-50 path rewrites in agent instruction files vs A's 231; minimizes accretive prose drift.
- **Team principle 5 (Incidents):** Screenshot evidences depth pain; full restructure absent further evidence would violate principle 5.
- **Smallest-enforceable principle:** smallest commitment that addresses most-painful current friction with today's evidence base.

**Subagent attribution:**

- **Option E exists at all because of Subagent 1's load-bearing finding:** AI-agent-native conventions (Letta, Claude Code skills, Doom, Spacemacs) separate human-edited state from agent-definition state by **folder tier**, not by **ownership entity**. Without Subagent 1's pattern enumeration, the option set would have been A/B/C/D only — and the recommendation would have been one of them.
- **B is ruled out as TODAY's recommendation by Subagent 2's empirical inspection of THIS codebase:** 231 hardcoded paths, 3 live `/schedule` routine IDs (`trig_017kd3VrhFhLahp6egKMzZzE`, `trig_017T8JrZ3ta3LbEydYBibbAZ`, `trig_0194Sn2AFGzTFckQDPvDkQLd`) with CWD baked at creation, manifest SHA hashes invalidated by path-rewrite, 45 MB memory dir at encoded-cwd path that JUST migrated this session.
- **Subagent disagreement preserved** — Subagent 3 (industry convergence) still recommends B; weighted lower because empirical inspection of THIS codebase trumps analogy from external ecosystems.

**Deferred / rejected with trigger conditions:**

| Option                  | Status              | Trigger to revisit                                                                                                                                              |
| ----------------------- | ------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| A (in-repo hoist)       | Deferred            | team-maerg commit-weight exceeds upstream framework AND ≥2 manifest-collision incidents from `bmad/<module>/` shape                                             |
| B (repo split)          | Deferred            | upstream-pull friction becomes blocking AND N≥6 active agents AND ≥1 documented schema-drift incident — Subagent 3's industry pattern becomes load-bearing here |
| C (surface compression) | Rejected as primary | Fails Lens 1 (no measurable scalability ceiling improvement); optional pair with E if root-level upstream noise becomes acutely friction-y                      |
| D (submodule)           | Rejected            | `bmad/_cfg/` manifest foot-gun structurally unsafe in this codebase                                                                                             |
| F (A+E composition)     | Deferred            | Atomic migration concentrates 6-7 orphan-classes; staged moves with verification intervals lower-risk                                                           |

**Pre-implementation verification gate** (per principle 1, fact-at-emission):

1. Verify `bmad/_cfg/agent-manifest.csv` + `files-manifest.csv` schemas don't enforce `agents/<x>-sidecar/` shape — confirm whether state files appear in `files-manifest.csv` and whether moving them registers as drift requiring manifest regen.
2. Enumerate all hardcoded sidecar-state paths in atlas.md / lyra.md / chuck.md / atlas-sidecar/instructions.md / lyra-sidecar/instructions.md before any move.
3. Each agent's `*reflect` / `*add` / memory-write / preference-update flow re-tested post-move on real data (per `feedback_static_verification_is_not_runtime_test.md` — static path-rewrite verification ≠ runtime test).

## Dissent

**Strongest honest counter (Subagent 3 + cost-amortization argument):**

> "Industry convergence is signal — every comparable ecosystem (Doom, LazyVim, NvChad, Claude Code skills, chezmoi) moved to repo-split BEFORE forks accumulated drift, not after. Maerg is at N=3 growing toward N=8+; cost of B at N=8 plausibly 2-3× cost at N=3. Doing E now and B later means PAYING TWICE — once for state-tier reorg, then again for full split when pull-friction bites. Single jump to F (A+E) or B-with-vendored-BMAD amortizes the migration cost."

**Counter-to-counter:**

1. **Empirical-over-extrapolation (principle 1, fact-at-emission):** Today's evidence is concrete — 231 paths, 3 routine IDs with CWD-baked creation, manifest SHA hashes, 45 MB memory-dir orphan risk. The "2-3× at N=8" cost-multiplier is hypothetical extrapolation; depending on next 5 sidecars' marginal cost stacking, multiplier could be 1.5× or 5× — unknown.
2. **Atomic-vs-staged risk:** B-now's atomic migration window concentrates 6-7 distinct orphan-classes (cwd → memory dir, 3 routines, manifest cross-repo break, slash-cmd registry, gitignore patterns, cross-repo `{project-root}` resolver, schema-drift bridge). Staged E-then-A-or-B lets each orphan-class get verified independently before committing further.
3. **B-now reverses today's work:** the iCloud-Desktop-sync recovery JUST landed at current cwd path; doing B now re-creates the same memory-dir migration cost paid earlier this session.

**Reasonable people can disagree** on this weighting. Recording the case for B explicitly so future-Maerg revisiting (or a future agent re-opening this ADR via `*evolve-agent` / `*architecture-decision`) sees the long-term-cost argument.

**Adjacent concern (strip-down honesty):** the "smallest variant" of E (preferences + memories only) is itself a tier-1 strip-down of Subagent 1's full proposal (agents + state + knowledge tiers). If post-move evidence shows partial-restructure didn't address enough friction, expanding to full E (knowledge-tier hoist + agent-dir restructure) is a follow-up `*evolve-agent` or own ADR — not a re-do of this decision.

**Adjacent concern 2 (manifest-schema verification deferred to pre-implementation gate):** the recommendation rests on the assumption that `bmad/_cfg/agent-manifest.csv` + `files-manifest.csv` don't enforce `agents/<x>-sidecar/` shape for state files. Subagent 2 noted manifests track agent and file paths but didn't verify state-file inclusion. If verification at implementation time reveals manifest enforcement, the recommendation may need amendment (state-files would also need manifest regen, increasing cost) — captured as gate item 1.

## Outcome

- **Decided:** 2026-05-05
- **By:** Chuck + Maerg (consensus this session)
- **As:** Accepted with framing modification — E ratified as **semantic-cleanup, NOT depth-fix**, per post-draft sanity check. Original draft overclaimed "depth 5→3" reduction; E-alone (without team-maerg hoist) does not reduce absolute path depth from repo root. Reframed as semantic-organization improvement (state tier discoverable separately from entity-grouped sidecars). Depth reduction deferred to F (A+E) or B per dissent's trigger conditions.
- **Followup commits:**
  - Pre-implementation verification gate (3 items in Recommendation): manifest-schema check, hardcoded-path enumeration, runtime test of `*reflect` / `*add` / memory-write flows.
  - File moves: `lyra-sidecar/preferences.yaml` → `state/preferences/lyra.yaml`; sidecar `memories.md` + `memories-autonomous-log.md` for atlas + lyra → `state/memories/<x>.md` + `<x>-autonomous-log.md`.
  - Agent instruction file path-reference updates (`atlas-sidecar/instructions.md`, `lyra-sidecar/instructions.md`, any cross-references in `_data/`).
  - `bmad/_cfg/agent-manifest.csv` + `files-manifest.csv` regen if state files appear there (verify in pre-impl gate).
  - Re-test each agent's memory-write / preference-update / `*reflect` flow on real data per `feedback_static_verification_is_not_runtime_test.md`.

---

## Cross-references

- **Related ADRs:**
  - `2026-05-01-scalability-roadmap.md` (companion — covers agent-system internal scalability; this ADR covers filesystem topology specifically; both need eventual joint ratification)
  - `2026-04-29-phase-2-cross-module-awareness-convention.md` (similar deferred-to-trigger framing)
  - `2026-05-04-atlas-v2-build.md` (Q1 sidecar-at-`bmad/team-maerg/agents/atlas-sidecar/` is the structural lock this restructures — Q1 revisit-trigger "Structural change to module convention" fires here)
  - `2026-05-05-lyra-v1-build.md` (Q1 sidecar lock; Q4 single yaml `preferences.yaml` location)
  - `2026-05-05-distributed-automation-ownership.md` (3 routines named in this ADR are owned per the distributed-automation pattern; their CWD-baked-at-creation property surfaced here as orphan risk)
- **Related lenses:** Lenses 1, 5, 6, 10, 11 (full text in `bmad/team-maerg/_data/lens-framework.md`)
- **Related principles:** team-principles.md v1.2 — principle 1 (fact-at-emission, load-bearing for empirical-over-extrapolation), principle 5 (incidents — load-bearing for smallest-enforceable framing), principle 6 (recommendations carry their tier — this entire ADR is the Tier 3 surface)
- **Related memories:**
  - `feedback_research_before_structural_questions.md` (REFINED 2026-05-05) — drove the spawn-signal override; the iCloud-Desktop-sync incident in same memory is the originating recurrence event for this session arc
  - `feedback_smallest_enforceable_strip_down.md` — recommendation explicitly applies the strip-down discipline (full Subagent 1 proposal → preferences + memories only)
  - `feedback_static_verification_is_not_runtime_test.md` — verification gate item 3 (post-move runtime test required, not just static path-rewrite verification)
  - `feedback_anchoring_on_plausible_defaults.md` — verification gate item 1 (manifest-schema assumption flagged for explicit verification, not assumed)
- **Subagent research (this session):**
  - Subagent 1 (pattern enumeration + anti-patterns): surfaced Option E (tier-by-state-type), cited Doom Emacs FAQ, Spacemacs private layers, GNU Stow, git subtree, Letta memory docs, sparse-checkout, Claude Code plugins, preset.io fork-drift writeup
  - Subagent 2 (orphan-side-effect inspection): empirical grep counts, routine IDs, manifest cross-references; key files cited: `bmad/_cfg/agent-manifest.csv`, `bmad/_cfg/files-manifest.csv`, `bmad/_cfg/manifest.yaml`, `bmad/team-maerg/_data/automations-registry.yaml`, `.gitignore`, `bmad/team-maerg/config.yaml`
  - Subagent 3 (upstream-pull dynamics): industry-convergence findings — Doom Emacs, LazyVim/NvChad, Claude Code skills, chezmoi, Cookiecutter; recommended B with adversarial framing on schema-drift bridge cost
- **Originating context:** Maerg's screenshot observation 2026-05-05; reframed from "fix the disorganization" to "what are the best way to keep the system for scalability" mid-session.
