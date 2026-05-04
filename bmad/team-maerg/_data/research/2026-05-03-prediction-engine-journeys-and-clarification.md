<!-- Prediction-engine vision + journey map + clarification protocol.
     Synthesis of 5 research subagents on 2026-05-03. Reference document for
     San v2 + Atlas v2 authoring + future prediction infrastructure work. -->

# Prediction-engine journeys, lane boundaries, and clarification protocol

**Date:** 2026-05-03
**Status:** Reference document for San v2 + Atlas v2 + future prediction infrastructure
**Subagent inputs:** 5 parallel research runs (3 on Brix-flavored journeys, 1 on Atlas integration, 1 on clarification protocol)

## How the prediction agent works (mechanically)

```
   ┌─ Trigger ─┐    ┌─ Clarification ─┐    ┌─ Engine (MiroFish-pattern) ───────────┐    ┌─ Agent interprets ─┐
   │            │    │ 8-step protocol │    │ 1. GraphRAG knowledge graph from     │    │ Confidence-banded  │
   │ • Atlas    │    │ produces frozen │    │    seed material                     │    │ recommendation +   │
   │   captures │ ─▶ │ prediction-     │ ─▶ │ 2. Generate 100s-1000s of stake-     │ ─▶ │ dissent block +    │ ─▶ User
   │ • Schedule │    │ brief.yaml      │    │    holder personas with relations    │    │ trigger conditions │
   │ • Signal   │    │ (the audit      │    │ 3. Multi-agent simulation over time  │    │ for re-eval        │
   │ • On-demand│    │ trail)          │    │ 4. ReportAgent synthesizes outputs   │    │                    │
   └────────────┘    └─────────────────┘    └───────────────────────────────────────┘    └────────────────────┘
```

Engine = MiroFish-style ([dev.to](https://dev.to/arshtechpro/mirofish-the-open-source-ai-engine-that-builds-digital-worlds-to-predict-the-future-ki8) | [GitHub](https://github.com/666ghj/MiroFish)) or built internally on OASIS (CAMEL-AI). Adjacent: Meta ARE for agent evaluation/regression testing.

Key differentiator from single-LLM: **emergent dynamics** — reflexive feedback loops, coalition formation, second-order reactions. Single LLM narrates these; multi-agent generates them.

## Journey map — 12 San (PMF strategist) + 2 Atlas (CoS) journeys

### Strategic decisions (San) — bounded structural calls

| #   | Journey                                    | Trigger                                             | Cadence                                                     | Horizon | Ship priority                                                   |
| --- | ------------------------------------------ | --------------------------------------------------- | ----------------------------------------------------------- | ------- | --------------------------------------------------------------- |
| S1  | wiTRY moat vs Binance entrant              | Maerg remark + competitor signal                    | On-demand + auto-fires on competitor liquidity-product news | 90d     | **🟢 ship-first** (fast falsifiability)                         |
| S2  | Egypt-vs-Argentina sequencing              | Quarterly review + macro signal                     | Quarterly                                                   | 18mo    | hold (long feedback loop, unfalsifiable for engine credibility) |
| S3  | ENBD-class partnership accept/counter/walk | Term sheet arrives                                  | Per partnership (3-5×/year)                                 | 24mo    | **🟢 ship-first** (one-shot, irreversible)                      |
| S4  | DLF institutional-vs-retail pivot          | Bi-annual + threshold (institutional pipeline drop) | Bi-annual                                                   | 24mo    | hold (long feedback loop)                                       |

### Pre-launch experiments (San) — pre-commitment what-ifs

| #   | Journey                                       | Trigger                            | Cadence   | Horizon | Ship priority                                                                        |
| --- | --------------------------------------------- | ---------------------------------- | --------- | ------- | ------------------------------------------------------------------------------------ |
| P1  | Pre-launch wiTRY adoption + competitor reflex | Tokenomics ready, ~2 weeks to ship | 2-4×/year | 90d     | medium                                                                               |
| P2  | Tokenized real estate regulatory stress test  | New asset class scoped             | 4-6×/year | 12mo    | **🟢 ship-first** (one-shot + irreversible + adversarial multi-stakeholder dynamics) |
| P3  | ENBD announcement market reaction sim         | Partnership ready to publish       | 3-5×/year | 14d     | **🟢 ship-first** (unifies with S3+R3)                                               |
| P4  | Fee restructure churn-vs-revenue Pareto       | Finance proposes change            | ~6×/year  | 180d    | medium                                                                               |

### Risk / stakeholder modeling (San) — failure-mode + cascade simulation

| #   | Journey                                                     | Trigger                                                   | Cadence                   | Horizon | Ship priority                                                                                       |
| --- | ----------------------------------------------------------- | --------------------------------------------------------- | ------------------------- | ------- | --------------------------------------------------------------------------------------------------- |
| R1  | Tri-jurisdictional regulatory pre-mortem (SPK + DFSA + FRA) | GTM scoping + policy-seed delta                           | Pre-launch + quarterly    | 18mo    | **🟢 ship-first** (coordination dynamics emergent only multi-agent)                                 |
| R2  | iTRY 48-hour redemption cascade                             | Macro signal (lira drop, redemption velocity 2x baseline) | Continuous, deep on event | 48-72h  | **🟢 high-leverage continuous** (genuinely requires multi-agent — reflexive cascade is the product) |
| R3  | ENBD partnership-withdrawal cascade                         | Compliance escalation pattern detected                    | Triggered + monthly       | 6mo     | medium (unifies with S3+P3)                                                                         |
| R4  | Tokenization-legality FUD storm                             | KOL post detected                                         | Continuous monitoring     | 14d     | medium                                                                                              |

### Atlas (CoS) — only 2 journeys earn prediction-engine cost

| #   | Journey                                           | Trigger                                                              | Cadence          | Horizon | Atlas-owned because                                    |
| --- | ------------------------------------------------- | -------------------------------------------------------------------- | ---------------- | ------- | ------------------------------------------------------ |
| A1  | Cross-plane conflict cascade ("hell week triage") | `*weekly-review` surfaces collision (Brix sprint + family + partner) | 2-4× per quarter | 7d      | Atlas is ONLY agent seeing both Brix + personal planes |
| A2  | Roster-scale relationship trajectory scoring      | Batched review of dormant relationships                              | Quarterly        | 60d     | Network second-order effects emergent only at scale    |

**Honest finding from Atlas subagent:** Atlas needs prediction for ~1.5 journeys, NOT many. Most operations (`*add`, `*done`, `*park`, `*daily-brief`, `*roster`, individual meeting prep, individual relationship triage) are CRUD with light intelligence — prediction engine is overkill and would actively reduce Atlas's UX value (speed). **Strategic prediction routes to San**; Atlas detects the need, San runs the simulation, Atlas integrates result back into state.

## Convergent ship-first themes

### Theme A — Partnership-class decisions (unifies S3 + P3 + R3)

ENBD-tier partnership work spans accept/counter/walk decision (S3) + announcement reaction simulation (P3) + pre-empt withdrawal modeling (R3). **One unified workflow, three sub-questions.** Fires per major partnership (3-5×/year). Bounded, falsifiable within 90 days, structurally beyond single-LLM (requires adversarial multi-stakeholder dynamics).

### Theme B — Regulatory pre-mortem (unifies R1 + P2)

Tri-jurisdictional regulatory simulation for any new asset class or major launch. **Coordination dynamics between regulators** (SPK→FRA→DFSA cascade with SPK as first mover) is genuine multi-agent emergence, not derivable from single-LLM reasoning.

## Lane boundaries

| Agent                                                       | Owns prediction work for                                                                                                                                                                               |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **San (PMF strategist)**                                    | All strategic predictions: moat analysis, market entry, competitive response, pre-launch experiments, regulatory pre-mortem, partnership decisions, risk scenarios. v1 menu items map directly.        |
| **Atlas (CoS)**                                             | Only 2 cross-cutting journeys: cross-plane cascades (sees both planes uniquely), roster-scale relationship scoring (batch). Detects strategic-prediction needs and routes to San.                      |
| **Chuck (meta-architect)**                                  | None. Structural reasoning ≠ scenario simulation. Predictions are about future-state futures; Chuck reasons about present-state architecture.                                                          |
| **Future planning agent**                                   | Calendar-aware optimization (booking, venue research) is NOT prediction-engine work — closer to constraint-satisfaction over real availability data. Prediction would be overkill.                     |
| **Future Brix-coupled SMEs** (Accel/GTM, Vox/content, etc.) | Domain-specific predictions per role: Accel runs market-response simulations; Vox runs content-reception simulations. All wrap the same prediction-engine via different `prediction_engine` contracts. |

## Clarification protocol (8 steps)

**Problem:** garbage-in-garbage-out. Mis-framed questions ("should we expand to Egypt?" when actual decision is "should we double-down on Turkey first?") yield meaningless predictions regardless of engine sophistication.

**Solution:** mandatory clarification gate BEFORE engine invocation.

```
1. Restate.            Agent paraphrases: "You're asking whether X under Y within Z."
                       Forces explicit reading.
2. Decompose terms.    Flag every load-bearing word with >1 plausible meaning.
                       List candidate readings; ask user to pick or split.
3. Surface prior       "What decision does this prediction inform?" If answer reveals
   decision.           a bigger open question, escalate to that one first.
4. Slot-fill prediction Required slots: decision, alternatives (≥2 including null),
   frame.              horizon, stakeholders-of-record, success-criteria, kill-criteria.
                       Empty slots block invocation.
5. Falsifiability      "In 6 months, what observation would prove this prediction
   check.              wrong?" If no answer exists, reject or reframe.
6. Stakeholder         Cross-reference named stakeholders against GraphRAG persona
   coverage scan.      index. Flag obvious omissions.
7. Cost-vs-clarity     If engine cost > threshold AND ambiguity flags remain, force
   gate.               additional clarification round.
8. Lock & log.         Emit frozen `prediction-brief.yaml`. Engine consumes this
                       artifact, NOT raw user question. Brief = audit trail.
```

**File location:** `bmad/team-maerg/_data/clarify-protocol.md` (shared single source of truth) + `bmad/team-maerg/workflows/clarify-and-predict/` (workflow wrapping every prediction call).

**V1 (smallest enforceable):** Steps 1, 4, 5, 8 only. Slot-fill is a literal YAML form. Skip requires explicit `--unsafe-skip-clarify` flag, logged.

**Full version:** Adds steps 2, 3, 6, 7. GraphRAG-aware stakeholder coverage. Cost-aware gating. Memory of past clarifications.

**Firing policy:** Mandatory gate by default. Conditional bypass for trivial re-runs of already-locked briefs (parameter sweeps). User-toggle is no — skip flag exists but logged + surfaced in reports. Garbage predictions are worse than slow ones.

**Autonomy mode (no human present):**

1. Agent self-clarifies against protocol, generates brief autonomously.
2. If any required slot is empty OR falsifiability fails, agent **does not invoke engine**. Emits `clarification-needed` artifact to queue and waits.
3. Pre-approved brief templates (e.g., "weekly competitor scan") bypass clarification because slots are pre-filled by template.

Trades autonomous throughput for hard guarantee: no engine spend on under-specified questions.

### Critical insight: ship the protocol BEFORE the engine

Three reasons:

1. **Protocol is cheap** (days, not weeks). Engine is expensive (weeks + per-run cost).
2. **Standalone value:** improves every decision conversation, even those that never reach the engine. Many "I need a prediction" questions dissolve at step 3 (the real decision was elsewhere).
3. **Sunk-cost defense:** building engine first creates pressure to USE it — sunk-cost bias pushes invocation on under-specified questions to justify the build. Gate must exist before temptation does.

**Engine input contract = clarification artifact** (not raw question). Build engine against the brief format; that way engine's input contract is defined by the protocol, not the other way around.

## Cadence framework — autonomy connection

| Cadence type                  | Examples                                                                                          | Atlas integration                                                                                                               |
| ----------------------------- | ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| **Continuous monitoring**     | iTRY cascade (R2), FUD storm (R4)                                                                 | Atlas autonomously runs background sim; surfaces in brief if anomaly threshold crossed                                          |
| **Signal-triggered**          | wiTRY moat (S1), partnership withdrawal (R3)                                                      | Atlas detects signal (competitor announcement, compliance escalation), auto-fires San prediction, surfaces report in next brief |
| **Scheduled**                 | Quarterly market review (S2), bi-annual pivot (S4)                                                | Atlas's calendar tool fires the review; San runs prediction; brief delivered at scheduled time                                  |
| **Pre-event**                 | Token launch (P1), fee change (P4), partnership announcement (P3), regulatory pre-mortem (R1, P2) | User invokes via Atlas's `*route` → San; or San's own menu commands                                                             |
| **On-demand**                 | ENBD term sheet (S3), strategic question (any)                                                    | User prompts San directly; degraded path: single-LLM if engine unavailable                                                      |
| **Cross-plane (Atlas-owned)** | Hell-week cascade (A1)                                                                            | Atlas's `*weekly-review` triggers; runs Atlas-scoped prediction                                                                 |

## Build sequence — cost-staged

**Stage 0 (days, ships now/soon)** — Clarification protocol V1.

- File: `bmad/team-maerg/_data/clarify-protocol.md` (8-step spec)
- Workflow: `bmad/team-maerg/workflows/clarify-and-predict/` (wrapper)
- Slot-fill YAML schema for `prediction-brief.yaml`
- Steps 1, 4, 5, 8 implemented; steps 2, 3, 6, 7 deferred
- Standalone value: improves every decision conversation, even pre-engine

**Stage 1 (~3-5 hrs separate session)** — San v2 with degraded prediction.

- San v2 ships with `prediction_engine` contract in customize.yaml
- Default = single-agent LLM simulation (degraded but functional, ~40-60% value per Subagent #3 estimate)
- All prediction calls go through clarification protocol → produce brief.yaml → engine consumes
- Validates the contract pattern + accumulates real prediction-brief artifacts as calibration data

**Stage 2 (~1-2 weeks focused infrastructure session)** — Multi-agent prediction engine for partnership decisions.

- OASIS/CAMEL-AI integration OR custom 50-200 persona simulation engine
- Wired to ENBD-class partnership unified workflow (S3+P3+R3)
- First **autonomous predictive capability** — fires when partnership signals detected
- Calibration data from Stage 1 informs persona weighting

**Stage 3 (~1-2 weeks per journey type, after Stage 2 calibration validates)** — Expand to other journey types.

- Add R1 (regulatory pre-mortem) next
- Then P2 (tokenized RE)
- Then continuous monitoring (R2, R4)
- Long-horizon journeys (S2, S4) added LAST — calibration takes longest

**Stage 4 (reactive)** — full MiroFish integration if usage/value justifies. Or build out OASIS direct. Decision deferred to evidence at that point.

## Calibration discipline

- Every shipped prediction logged with: timestamp + confidence band + observed outcome (when knowable) + lessons-learned annotation
- Quarterly Brier-score review — predictions vs. observed
- Persona weights re-fit against accumulated outcomes
- Engine reports confidence intervals, NOT point estimates
- Trust earned via track record, not asserted
- **Load-bearing for autonomy** — without calibration, user can't trust autonomous prediction-driven decisions

## Anti-patterns flagged

1. **Asking the wrong question precisely.** No engine sophistication recovers from mis-framed questions. Clarification protocol is the defense; precision in slots ≠ precision in framing.
2. **Skipping clarification because question "seems clear."** Steps 1-3 surface the real decision under the apparent decision. The cost of the protocol is rounding-error vs the engine's per-run cost.
3. **Using prediction engine for bounded operations.** Atlas backlog pruning, individual meeting prep, schedule optimization for one event — these don't have multi-stakeholder emergent dynamics. Smart heuristics + single-LLM win on speed and clarity.
4. **Long-horizon journeys for engine-credibility-building.** Egypt-vs-Argentina (18mo feedback) is unfalsifiable for engine calibration. Ship S3+R1 type (90-day falsifiable) first; expand to long-horizon only after track record exists.
5. **Skipping calibration logging.** Without observed-outcome capture, the engine can't improve. Calibration is the autonomous-trust foundation.
6. **Building engine before protocol.** Sunk-cost bias drives invocation on under-specified questions. Protocol is cheap; ships first; defines engine's input contract.

## Open questions for future ADRs

- Which prediction-engine substrate? (MiroFish full integration, OASIS direct, custom build, hybrid) — `*architecture-decision` cycle when Stage 2 starts.
- Where does GraphRAG seed data live? `bmad/team-maerg/_data/brix/` already has core knowledge files; expand or new structure?
- How do calibration outcomes feed back into persona weights? Manual quarterly review vs automated drift correction?
- What's the lane boundary between San's PMF predictions and future Accel's GTM predictions? (Both are Brix-coupled, both use prediction engine — when they overlap, who runs what?)

## Cross-references

- **Source subagent reports** (this session, 2026-05-03):
  - Strategic decisions journeys (4 journeys + ship-first analysis)
  - Pre-launch experiments journeys (4 journeys + simulation-vs-A/B framing)
  - Risk/stakeholder modeling journeys (4 journeys + stakeholder-modeling depth)
  - Atlas prediction journeys (2 load-bearing + lane-boundary discipline)
  - Clarification protocol design (8-step + V1 + ship-order)
- **Related project memories:**
  - `project_prediction_engine_san_strategist.md` — broader prediction-engine framing
  - `project_planning_agent_roadmap.md` — future planning agent (does NOT need prediction engine)
- **Related ADRs:**
  - `2026-05-01-scalability-roadmap.md` — Tier C item C1 (counterfactual simulation engine) maps to this work
  - `2026-04-29-phase-2-cross-module-awareness-convention.md` — routing convention foundational for Atlas→San routing
- **External references:**
  - MiroFish ([dev.to article](https://dev.to/arshtechpro/mirofish-the-open-source-ai-engine-that-builds-digital-worlds-to-predict-the-future-ki8) | [GitHub](https://github.com/666ghj/MiroFish))
  - Meta ARE ([landing](https://facebookresearch.github.io/meta-agents-research-environments/) | [GitHub](https://github.com/facebookresearch/meta-agents-research-environments))
  - Digital twin architecture vision (Kimi.ai paper, 2026-04 — captured separately)

## Next concrete action

Ship the clarification protocol (Stage 0). Cheap, standalone value, defines engine input contract before engine exists. Then San v2 authoring with `prediction_engine` contract + degraded default. Then per-journey infrastructure builds.
