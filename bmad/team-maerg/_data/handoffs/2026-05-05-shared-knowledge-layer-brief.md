<!-- Handoff brief from Maerg + team-maerg/chuck for the shared-knowledge-layer
     architecture decision (Brix engineering signals consumed across multiple
     team-maerg agents). Captured 2026-05-05 with Maerg's leans confirmed +
     remaining open questions flagged for future *architecture-decision session.
     Defensive gitignore landed same commit. -->

# Handoff brief: shared knowledge layer for team-maerg (Brix-engineering signals)

**From:** Maerg + team-maerg/chuck
**To:** future-Chuck (next focused session) — `*architecture-decision` workflow
**Date:** 2026-05-05
**Type:** ecosystem-architecture brief — input to next-session ADR cycle

## Context

This is **shared infrastructure for team-maerg**, not an Atlas-specific feature. Multiple agents (Chuck, Atlas, San v2 future, Follett v2 future) consume Brix-engineering channel digests for different lane purposes. Originated from the question "should Atlas have Slack access?" — which decomposed into "what's the shared knowledge layer for the ecosystem?"

Maerg's verbatim framing (2026-05-05):

> _"i know the digest is valuable for most of the agents - it will be valuable for chuck to see how didier operates, it will be valuable for atlas to track tasks / dependencies and so on, it will be valuable for future San to digest strategic inputs, it will be valuable for follett to analyze team morale"_

This is foundational ecosystem infrastructure with security implications (Brix engineering content is sensitive; the team-maerg fork is public). Designed wrong, it's a security exposure surface that compounds across agents. Designed right, it's leverage that scales linearly with each new SME.

## Locked decisions (Maerg confirmed 2026-05-05)

These are NOT up for re-debate in the ADR cycle — capture as inputs to the deeper structural questions.

### LOCK-1: Privacy mechanism = Option A (gitignore + local-only)

- Brix content NEVER enters the BMAD-METHOD git repo (which is a public fork — `maerg-eth/BMAD-METHOD`, inheriting public visibility from upstream `bmad-code-org`)
- All Brix-domain files (`bmad/team-maerg/_data/brix/`) are gitignored
- Sensitive content lives at local-only paths; sync mechanism reads/writes locally without committing
- Defensive `.gitignore` for `bmad/team-maerg/_data/brix/` landed in the commit creating this brief — prevents accidental commits while ADR is being designed
- **Future evolution path:** if/when portability across machines matters, evolve to Option C (private submodule pointing at private repo). Today's smallest-enforceable is gitignore.

### LOCK-2: Per-agent explicit read access (lane integrity)

- Each team-maerg agent gets explicit read access to specific files in `_data/brix/` matching its lane — NOT shared-everywhere read
- Per principle 7 (siblings stay in their lane) — Brix-domain content remains agent-specific in scope, even when the source data is shared infrastructure
- Atlas reads task/dependency-relevant signals; Chuck reads Didier-observation signals; San reads strategic signals; Follett reads morale signals
- Atlas v2's current Q10 read scope explicitly excludes `_data/brix/` — that's correct posture by default; explicit grants are per-agent additions, not broad scope expansion

### LOCK-3: Sync = `/schedule` daily routine

- Daily 06:00 UTC routine fires the slack-digest pipeline (or equivalent for whatever sources are in scope)
- Writes to local-only paths (per LOCK-1)
- Matches existing pattern: calibration routine + upstream-scan routine already use /schedule
- Per distributed-automation-ownership ADR (`2026-05-05-distributed-automation-ownership.md`), this routine has an `owning_agent` — TBD in ADR (likely Chuck since shared-infra ownership) and registered in `_data/automations-registry.yaml`

### LOCK-4: Use cases per agent

Each agent has a distinct lane-relevant read of the SAME source data:

| Agent          | Use case                                                                                                               | Lane fit                     |
| -------------- | ---------------------------------------------------------------------------------------------------------------------- | ---------------------------- |
| **Chuck**      | Didier behavior observation — detect anomalies in Brix-internal CLI usage patterns; surface in `*audit-ecosystem`      | Meta-architecture monitoring |
| **Atlas**      | Task / dependency tracking from channel signals — who-owes-Maerg, who-Maerg-owes, commitment aging from Slack messages | CoS coordination             |
| **San v2**     | Strategic input digestion — PMF-relevant signals, competitor mentions, pricing/positioning conversations               | PMF strategist               |
| **Follett v2** | Team morale analysis — sentiment shifts, communication frequency drops, Friday-vibes signals                           | HR/people                    |

These are illustrative; ADR may refine + add use cases.

## Open questions for ADR

These need explicit decisions before the architecture ships.

### Q-A: Storage paths (per-use-case granularity)

- Single `bmad/team-maerg/_data/brix/brix-weekly.md` with all signals, agents filter by content?
- Separate files per consumer: `brix/atlas-tasks.md`, `brix/chuck-didier.md`, `brix/san-strategic.md`, `brix/follett-morale.md`?
- Hybrid: shared raw digest + per-agent filtered views generated from it?

### Q-B: Sync source — port the slack-digest pipeline, or sync from bmad-test?

- Existing slack-digest pipeline lives in `/Users/maerg/Projects/bmad-test/slack-digest` (gitignored, outside BMAD-METHOD)
- Option B1: Port the pipeline to BMAD-METHOD (heavier; full ownership)
- Option B2: Daily routine reads bmad-test's output, syncs to BMAD-METHOD's local-only path (lighter; cross-repo dependency)
- Option B3: Run pipeline from local clone of bmad-test, write directly to BMAD-METHOD path (medium; loose coupling)

### Q-C: Per-agent grant mechanism — how does each agent's read scope evolve?

- Update each agent's `agent.yaml` with explicit `_data/brix/<file>` read entries?
- Single `_data/brix/.access-control.yaml` registry that maps agent → readable files?
- Per-agent customize.yaml override?
- Audit-ecosystem extension that flags grant drift?

### Q-D: Failure modes + degraded paths

- Digest sync fails (slack-digest pipeline broken, network down) — agents should NOT fail to activate; they read stale data with a "last-updated N days ago" flag
- Brix-content sensitivity → defense-in-depth: even with gitignore, what if files are accidentally committed? (git pre-commit hook check; CI scan; manual review on touch?)
- Multi-machine portability — when Maerg moves to a new machine, what's the bootstrap process? (Defers to eventual Option C migration if/when this becomes load-bearing)

### Q-E: Use-case-specific implementation depth

For each agent, the ADR (or sub-ADRs / `*evolve-agent` cycles) needs to specify:

- Chuck's `*audit-ecosystem` extension shape — what counts as "Didier anomaly"?
- Atlas's task/dep-extraction format — confidence-tagged surfaces vs auto-captures?
- San v2's strategic-signal categorization — when authoring San v2, this is part of her persona-discovery
- Follett v2's morale-tracking schema — same, part of Follett v2 authoring (much later)

### Q-F: Source channel scope

Today's slack-digest reads "Brix engineering channels" per Maerg's note. The shared knowledge layer might also want:

- Personal Slack DMs/mentions (Maerg's earlier seed cases — currently no integration)
- Linear / DynamoDB / Lambda logs (via Didier per Maerg's note)
- Internal docs (PKB)
- Other? (calendar events from external systems? email? )

The ADR should explicitly scope V1 sources vs V2+ sources to avoid the "boil the ocean" trap.

## Cross-references

- **Atlas v2 ADR:** `bmad/team-maerg/_data/decisions/2026-05-04-atlas-v2-build.md` — Q5 (Paperclip-stripped), Q10 (Atlas read scope explicitly excludes `_data/brix/`)
- **Distributed-automation-ownership ADR:** `bmad/team-maerg/_data/decisions/2026-05-05-distributed-automation-ownership.md` — daily-routine ownership pattern
- **Hook-bypass policy ADR:** `bmad/team-maerg/_data/decisions/2026-05-05-graduated-hook-bypass-policy.md` — sibling structural ADR; sync routine wireup may engage hook-classification
- **Recommendation discipline:** `bmad/team-maerg/_data/recommendation-discipline.md` — agents surfacing brix-derived recommendations apply discipline footer
- **Planning SME brief:** `bmad/team-maerg/_data/handoffs/2026-05-05-planning-sme-brief.md` — separate concern; Planning SME does NOT consume the Brix knowledge layer (different domain — personal logistics, not Brix engineering)
- **Existing slack-digest:** `/Users/maerg/Projects/bmad-test/slack-digest` (v1, outside this repo's scope by design); pipeline `/Users/maerg/Projects/bmad-test/bmad/tools/update-brix-weekly.sh`
- **Originating Maerg quote (2026-05-05):** _"i know the digest is valuable for most of the agents - it will be valuable for chuck to see how didier operates, it will be valuable for atlas to track tasks / dependencies and so on, it will be valuable for future San to digest strategic inputs, it will be valuable for follett to analyze team morale"_

## Acknowledgment expected (from next-session Chuck after ADR)

After the ADR ratifies, follow-on work:

- Q-A through Q-F resolved
- ADR file created at `bmad/team-maerg/_data/decisions/<date>-shared-knowledge-layer.md`
- `_data/automations-registry.yaml` row added for the daily sync routine
- /schedule routine created (probably via bmb handoff)
- Per-agent read scope evolutions ratified (Atlas Q10 amendment, Chuck/San/Follett equivalents)
- Sync source decision (port vs sync from bmad-test) implemented
- Defensive gitignore stays in place

## Critical reminder

**No Brix content commits to the public fork until the ADR ratifies the privacy mechanism + storage paths.** Defensive gitignore covers `bmad/team-maerg/_data/brix/` as of this commit; widen if the ADR specifies additional sensitive paths. If anyone (human or agent) attempts to commit Brix content before ADR ratification, the gitignore catches it; if it slips past gitignore (e.g., via `git add -f`), surface as a security incident and re-audit.
