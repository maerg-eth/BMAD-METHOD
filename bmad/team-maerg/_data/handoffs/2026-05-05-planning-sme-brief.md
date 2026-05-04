<!-- Handoff brief from Maerg + Chuck (team-maerg/chuck) to bmb (bmad/bmb/agents/bmad-builder).
     Authored 2026-05-05. Purpose: input to bmb's *create-agent workflow for the
     personal-logistics Planning SME (the second SME in team-maerg after Atlas v2).
     Per the build-retro routing convention from Atlas v2 ADR — handoff captures
     intent, bmb's *create-agent discovers persona shape, locks decisions, ships. -->

# Handoff brief: Personal-logistics Planning SME (working name TBD)

**From:** Maerg + team-maerg/chuck
**To:** bmad/bmb/agents/bmad-builder (next focused session)
**Date:** 2026-05-05
**Type:** new-agent authoring brief — input to `*create-agent` workflow

## Context

This is the personal-logistics Planning SME flagged in `project_planning_agent_roadmap.md` (Maerg's roadmap, 2026-05-03) and refined with substantial scope expansion in today's session (2026-05-05). It is the second SME-agent for team-maerg after Atlas v2 — first non-Brix-coupled SME, first agent whose primary loop includes preference modeling + recommendation generation + execution (calendar / booking).

Per the build-retro routing convention (Atlas v2 ADR `2026-05-04-atlas-v2-build.md`):

- Locks → ADR in `_data/decisions/`
- Calibration data → agent's autonomous-log
- Build patterns → Chuck's feedback memories
- Build-session observations of agent → ADR

Per the distributed-automation-ownership ADR (`2026-05-05-distributed-automation-ownership.md`): this agent owns automations within its own domain (e.g., weekly-plan generation cadence) — register them in `_data/automations-registry.yaml` with `owning_agent: team-maerg/<name>`.

## Maerg's brief (verbatim, 2026-05-05)

> _"I want to spin an agent, the only and priority task is for that agent to learn my likings of social activities; events, museum visits, restaurants, comedy shows, jazz etc. and then tracks what available activities nearby my at that point current location, recommends me a weekly plan with multiple options to test out, the ones that i like prepares me calendar invite. later on, it could book / reserve / purchase for me"_

## Decomposed scope

The brief contains two distinct loops + a phased capability ladder:

### Loop 1 — Preference modeling (the taste model)

The agent maintains a learned model of Maerg's preferences across social-activity categories:

- **Categories** (initial — discovery may expand): museums + galleries, restaurants + food experiences, comedy shows, jazz + live music (extending to other genres on signal), film + theater, events (markets, festivals, talks, exhibitions), outdoor + activity-based (sports, classes, walks), social gatherings (parties, meetups, conferences)
- **Signal sources** for the model: explicit accept/reject from recommendations, post-event reflection (loved it / fine / wouldn't repeat), passive signals (which recommendations got skipped, which categories Maerg adds himself), drift over time (what he liked 6 months ago may not match now)
- **Model output**: per-category preference scores + qualitative notes on what KIND of thing in each category (e.g., "modern art galleries > classical, especially small + curated"; "jazz: cool/post-bop > traditional dixieland"; "restaurants: chef's-counter / tasting menu over à la carte")

### Loop 2 — Recommendation cycle (the weekly plan)

Cadence-driven discovery + recommendation:

- **Cadence:** weekly (probably Sunday or Monday morning — to be confirmed in \*create-agent flow)
- **Inputs:** preference model + Maerg's current location + calendar availability (read-only from Atlas's calendar tool OR direct calendar API) + activity discovery (sources TBD — see external integration section)
- **Outputs:** a weekly plan with **multiple options per slot** (some confident-pick, some test-and-learn for preference model improvement) — e.g., 3 options for Wednesday evening, 2 options for Saturday afternoon
- **Maerg interaction:** reviews the plan, accepts / rejects / requests alternatives per slot
- **Accepted options** → calendar invite prep (Phase 1 capability, see ladder)
- **Reject signals** → feed back into preference model

### Capability ladder (phased)

- **Phase 1 (V1 ship):** preference model + weekly recommendation + calendar invite prep on accept (Maerg manually finalizes booking/reservation)
- **Phase 2:** booking / reservation / purchase via APIs (OpenTable, Resy, Eventbrite, Ticketmaster, restaurant direct, museum tickets, etc.) — agent autonomously executes after Maerg accepts
- **Phase 3 (speculative):** proactive surfacing on schedule changes, location changes, time-sensitive events (e.g., "you're in NYC tomorrow — here's tonight's options")

Phase boundaries are intentional:

- Phase 1 ships value with minimal external integration (calendar-only)
- Phase 2 requires external API integrations + authorization model + payment (significant trust step) — should be its own \*evolve-agent cycle with explicit ADR for the booking-permissions surface
- Phase 3 requires autonomous trigger detection (location changes, calendar shifts) — depends on automation infrastructure that may evolve from the distributed-automation-ownership pattern

## Critical lane-boundary thought (for \*create-agent step 1: discovery)

Atlas v2 already exists. The Planning SME's lane vs Atlas's lane needs explicit definition during authoring.

**Suggested initial framing (refine in \*create-agent):**

| Capability                                       | Atlas (CoS)                                                                                    | Planning SME                                                       |
| ------------------------------------------------ | ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| Capture social-activity request from Maerg       | Yes (her \*add)                                                                                | No — receives via Atlas routing                                    |
| Route to Planning SME                            | Yes                                                                                            | N/A                                                                |
| Surface accepted plans in \*daily-brief          | Yes (read-only summary)                                                                        | Pushes accepted plans to Atlas's brief                             |
| Preference model                                 | No (not her domain)                                                                            | YES (her core IP)                                                  |
| Activity discovery (what's available near Maerg) | No                                                                                             | YES                                                                |
| Weekly recommendation generation                 | No                                                                                             | YES                                                                |
| Calendar invite _creation_                       | NO (Q9/Q10 — Atlas read-only on calendar; Planning SME propose-only deferred to V2 explicitly) | **YES from V1** — this is the load-bearing case for calendar-write |
| Calendar event _modification_                    | No                                                                                             | YES                                                                |
| Booking / reservation / purchase                 | No                                                                                             | YES (Phase 2)                                                      |

**The calendar-write authority** is the most structural decision in the lane boundary. Atlas v2 ADR Q6/Q9/Q10 explicitly deferred Atlas's calendar-write to "explicit calendar-write affordance grant"; that grant fires for Planning SME at V1. Worth treating as its own ADR cycle within the \*create-agent flow OR explicit step in step 1 discovery.

## Likely structural questions bmb's \*create-agent will surface

These are unprimed — bmb should discover them organically — but flagging in advance helps Maerg arrive prepared:

1. **Naming:** Atlas-style mythological / archetypal name? Or descriptive? (Atlas is "weight of the world" → CoS holds the picture. Possible: Polaris / Selene / Pomona / Lyra etc. — lots of room.)
2. **Capability tier:** ops or strategic? (Recommendation engine + autonomous booking trends strategic; calendar coordination + preference tracking is ops. Probably **strategic** because the recommendation IS the value, not the coordination.)
3. **Read scope (Q10-equivalent):** what does this agent read? Own sidecar + team-shared `_data/` is baseline. Plus calendar (which tool — gcal.py per Atlas, or different?). Plus Maerg's preference history (where stored?). External API access (booking sources) deferred to Phase 2.
4. **Autonomy for booking (Q-equivalent):** even at V1, calendar invite creation is authority Atlas doesn't have. Hard write-invariant on what (e.g., never books without Maerg confirm in V1)? Confirmation-gate pattern (mirroring Atlas Q12)?
5. **Preference model storage:** new `_data/preferences/` directory? Or per-category files? Or single yaml? Schema design.
6. **Location source:** how does the agent know "near current location"? Manual (Maerg states) / calendar-derived / external (location services API) / hybrid?
7. **Activity discovery sources:** Eventbrite, Resy, OpenTable, museum websites, jazz clubs, etc. — Phase 1 may be Maerg-curated source list; Phase 2 web-scraping or API integration.
8. **Cadence + automation:** weekly-recommendation as scheduled routine via /schedule (per distributed-automation-ownership pattern)? Or Maerg-invoked (`*weekly-plan`) on demand? Or hybrid?

## Pre-existing artifacts to load during \*create-agent

- `project_planning_agent_roadmap.md` (Maerg's original 2026-05-03 framing)
- This handoff brief (today's refinement)
- Atlas v2 ADR (`2026-05-04-atlas-v2-build.md`) — for lane-boundary patterns + calendar-write deferral context
- Distributed-automation-ownership ADR — for cadence pattern
- Recommendation-discipline.md — for footer requirement on weekly recommendations
- Team-principles.md v1.2 — coherence audit required
- Atlas's instructions.md — for handoff protocol pattern (cross-agent capture-then-route)

## Acknowledgment expected

After bmb runs `*create-agent` to completion in a future session:

- Confirm to Maerg the agent is shipped (per Atlas v2 build pattern: agent file + sidecar + slash command + registry row + first-run-calibration entry)
- Surface the locks ratified during build (Q1...Qn) for Chuck's build ADR authoring
- Flag any handoff-spec items that didn't get addressed (e.g., booking authorization may be its own future ADR cycle)
- Note: do NOT auto-ship Phase 2 or Phase 3 work — V1 ships, then \*evolve-agent for Phase 2 with its own ADR, etc.

## Cross-references

- **Existing roadmap memory:** `project_planning_agent_roadmap.md` (will be updated with today's refinements as a follow-on to this commit)
- **Atlas v2 ADR:** `bmad/team-maerg/_data/decisions/2026-05-04-atlas-v2-build.md`
- **Distributed-automation-ownership ADR:** `bmad/team-maerg/_data/decisions/2026-05-05-distributed-automation-ownership.md`
- **Recommendation discipline:** `bmad/team-maerg/_data/recommendation-discipline.md`
- **Team principles v1.2:** `bmad/team-maerg/_data/team-principles.md`
- **Originating Maerg messages:** 2026-05-03 (initial flag), 2026-05-05 (today's refinement with preference learning + location-aware + weekly cycle + calendar-write capability)
