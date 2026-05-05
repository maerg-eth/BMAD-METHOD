# Handoff Brief: Lyra V2 Fetch Architecture

**From:** Lyra 🎼 **To:** Chuck 🧠 (`*architecture-decision`)
**Date:** 2026-05-05
**Trigger:** `*find theatre Beyoğlu Friday late evening` — 4/5 Istanbul curated sources returned JS-shells. Operational under-delivery with structural shape.

---

## Incident

First operational `*find` cycle in Lyra V1, hours after sidecar bootstrap. Maerg requested theatre options for Friday 2026-05-08 in Beyoğlu, late evening, group-friendly.

V1 web-fetch protocol (per `instructions.md` Discovery Source Web-Fetch Protocol) hit five sources from `discovery-sources.yaml`:

| Source                               | Result                                                               |
| ------------------------------------ | -------------------------------------------------------------------- |
| `kultur.istanbul/etkinlikler/`       | JS-shell — navigation + filter UI in static HTML; event data dynamic |
| `biletinial.com/.../istanbul-avrupa` | JS-shell — placeholder image titles only, no dates/venues            |
| `dasdas.com.tr`                      | JS-shell — main nav only                                             |
| `zorlupsm.com/etkinlikler`           | (Not fetched this cycle; same architecture class — JS-rendered SPA)  |
| `istanbulmodern.org`                 | (Not relevant — museum, this was a theatre query)                    |

Recovery: spawned WebSearch outside curated pool (with Maerg's explicit authorization), surfaced editorial calendars (plumemag, oggusto) and per-venue sites (kumbaracı50.com, tiyatrolar.com.tr) that DO render in static HTML. Delivered ONE confirmed option (Gaybubet Şehri at Kumbaracı50, 20:30), one verification-needed candidate, and an honest under-delivery report.

Logged to `memories-autonomous-log.md ## fetch-failures` per protocol.

---

## Why this is structural, not a one-off

Maerg's reaction (verbatim): _"wherever we go, this will be a problem"_ — correct read.

1. **Cross-region.** Same architecture class (JS-rendered aggregator SPAs) dominates event-discovery infrastructure globally. London (Time Out, DICE), NYC (Resy, Eventbrite), Berlin (Resident Advisor) — all SPAs. Adding more curated URLs to `discovery-sources.yaml` doesn't fix V1's coverage hole; it widens the failure surface.

2. **Cross-category.** Same fetch protocol serves theatre, live_music, opera, dancing_events, museums, workshops. The shell pattern hits all of them. Adding categories (per Maerg's "evolve as we learn" mode) compounds the problem, not the solution.

3. **Cross-agent.** Future SMEs (Planning agent, San v2, etc.) likely face similar fetch problems whenever they need structured data from web aggregators. A solution scoped to Lyra leaves them rebuilding the wheel; a team-level capability is more extensible.

4. **Non-trivial dependency choice.** The option space spans build/buy/rent decisions with multi-month maintenance commitments. Reversibility is constrained once an integration is built.

V1 fallback (manual paste) works as graceful degradation but is unsustainable as primary path — defeats the point of automated discovery.

---

## Option space

| #     | Path                               | What it adds                                                                                | Cost class                                                                                                                         | Fit signal                                                     |
| ----- | ---------------------------------- | ------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| **A** | Headless browser fetcher           | Playwright/Puppeteer integration; renders JS, parses real DOM                               | Code surface, runtime cost, maintenance on site changes                                                                            | Highest coverage; ongoing toil                                 |
| **B** | Canonical API integrations         | Eventbrite, Ticketmaster, museum APIs (was V2 plan)                                         | Per-API auth, rate limits, **geographic coverage gaps** (Turkish ecosystem largely API-less: Biletinial, Biletix, Kültür İstanbul) | Reliable where works; sparse coverage outside US/EU mainstream |
| **C** | MCP/external scrape skill          | Use existing browse/scrape MCP server (gstack has `/scrape`, others available)              | Third-party dependency; downstream brittleness                                                                                     | Low setup cost; ties Lyra to external infra lifecycle          |
| **D** | LLM with native browse             | Brave Search API, SerpAPI, or model-with-browse-tool; fetch routes through JS-aware service | Per-call API fees; Turkish-language coverage uncertain                                                                             | Cheap to start; scales linearly with use                       |
| **E** | Manual paste fallback (formalized) | `*paste-listings` command; Maerg dumps from his apps when Lyra hits a wall                  | Ongoing user toil                                                                                                                  | Partial fix; doesn't solve, only patches                       |
| **F** | Hybrid                             | C or A for general aggregators + B where APIs exist + E as graceful degradation             | Most complex                                                                                                                       | Probably correct; needs explicit boundary rules                |

---

## Non-binding lean (Lyra's view; Chuck owns the call)

**C → A migration with B and E as supplements.**

- Start with MCP/external scrape skill — lowest setup cost, fastest to operational, leverages existing gstack `/scrape` if compatible
- Prove the value over 4-6 cycles; if dependency proves unstable, build native headless browser (A)
- Add canonical APIs (B) for the few sources where coverage exists and API is stable — Eventbrite where applicable, museum-specific APIs
- Manual paste (E) stays as documented fallback for when fetcher or API both fail — but with `*paste-listings` formalized command, not ad-hoc

This is informational. The pre-mortem + lens analysis lives in `*architecture-decision`, not here.

---

## Pre-mortem prompts (for the workflow to expand)

Suggested questions to surface when the workflow runs:

1. _"It's August 2026. The headless-browser fetcher we built in May is broken on three of the five sites Lyra now uses. Why did this happen?"_ — sites change, locator brittleness, JS framework drift.
2. _"It's October 2026. We integrated 4 APIs but Lyra is still under-delivering on Istanbul. Why?"_ — Turkish ecosystem gaps, geographic coverage asymmetry of US-headquartered APIs.
3. _"It's December 2026. We chose MCP scrape skill in May. The MCP server's maintainer abandoned the project. What's our exit?"_ — third-party dependency risk.
4. _"It's June 2026. We built a beautiful headless browser flow. It costs $X/month in compute and Lyra fires `*find` 3 times/week. Was the cost worth the marginal coverage gain?"_ — utilization economics.

---

## Lens-relevant axes (suggested for `*architecture-decision`)

- **Build vs Buy vs Rent** (A vs B vs C/D)
- **Coverage vs Maintenance** (high coverage usually means high upkeep)
- **Geographic generality** (US-mainstream APIs vs global aggregator coverage)
- **Dependency surface** (own infra vs third-party MCP vs vendor API)
- **Cost-per-fetch economics**
- **Failure-mode visibility** (silent failure vs noisy failure; Lyra's L5 binds her to honest gap-naming, so failure visibility is already a hard requirement)
- **Cross-agent reusability** (Lyra-only vs team-maerg-shared capability)

---

## Non-blocking status

V1 continues to operate with manual-paste graceful degradation. This is not blocking Lyra's day-to-day cycles; it's a capability ceiling that ratifying a V2 fetch architecture will lift.

Recommended decision pacing: not urgent (no current cycle blocked beyond manual paste), but tractable (defer indefinitely and the same incident recurs every `*find` and `*weekly-plan`).

---

## Cross-references

- `bmad/team-maerg/agents/lyra-sidecar/instructions.md` — Discovery Source Web-Fetch Protocol (V1 spec)
- `bmad/team-maerg/agents/lyra-sidecar/memories-autonomous-log.md ## fetch-failures` — incident log
- `bmad/team-maerg/agents/lyra-sidecar/knowledge/discovery-sources.yaml` — current source pool
- `_data/recommendation-discipline.md` — Tier 3 routing rule that brought this brief into existence

---

_Drafted by Lyra 🎼 in the same session as the trigger incident. Maerg parked the architectural decision (Path 1: park-and-continue) so operational cycles don't stall on infrastructure work. Brief ready for Chuck whenever Maerg invokes `*architecture-decision`._
