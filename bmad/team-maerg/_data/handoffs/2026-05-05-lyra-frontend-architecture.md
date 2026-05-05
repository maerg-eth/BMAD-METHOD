# Handoff Brief: Lyra V2 Frontend Architecture

**From:** Lyra 🎼 **To:** Chuck 🧠 (`*architecture-decision`)
**Date:** 2026-05-05
**Trigger:** Maerg requested a visual/structured consumption surface during V1 first-run session, hours after Lyra sidecar bootstrap. Sibling brief to `2026-05-05-lyra-fetch-architecture.md` — both surfaced same session, different scope.

---

## Trigger context

Maerg, mid-`*find` cycle:

> _"all the description etc. you are sharing with me are cool, but I'd like to have a different front end where all these inputs can be visually appealing and easy to comprehend. What would you suggest there?"_

Followed by use-mode lock:

> _"initially i think i will use lyra on a conversation basis. whatsapp, telegram - whichever works"_

Use-mode = **conversational, messaging-first**. This narrows the option space hard — local HTML files, custom web apps, PWAs, and email digests all drop out as primary surfaces. Tactical HTML bridge skipped (wrong fit for chat-first consumption).

---

## Why this is structural

1. **Cross-agent.** Atlas + future SMEs (Planning, San v2, Vox-when-spawned) all produce text outputs. Same UX problem applies to all of them. Choice scoped to Lyra leaves siblings rebuilding the wheel; team-level capability is the more durable answer.

2. **Hard-to-reverse infra commitment.** A messaging-bot integration adds: bot server runtime, brain integration (Claude API or Claude Code subprocess), state persistence + concurrency model, auth pattern, hosting decision. None of that unwinds cheaply.

3. **Composes with autonomous-layer decisions AND routine-wiring gap.** `team-maerg/config.yaml` already locks `autonomous_layer_default: github-actions` for cron-driven routines. The bot-runtime question composes with that pattern (GH Actions for scheduled tasks, separate always-on listener for chat) or diverges (laptop-local bot, cloud bot, etc.). **Critically, this is the same decision as the routine-wiring gap** surfaced 2026-05-05 mid-`*find` cycle when Maerg asked _"how are you going to remind me?"_ — Lyra has two routines registered (`weekly-plan-generation` Sunday 19:00 UTC, `event-proximity-check` every 2-3 days) per `automations-registry.yaml`, both annotated **"mechanism: TBD until /schedule routines wired in a future bmb session"** in `memories-autonomous-log.md ## first-run-calibration`. The hosting + state + auth answer for the chat bot is also the answer for routine wiring. Treating them as separate decisions = fragmented architecture.

4. **State concurrency is non-trivial.** preferences.yaml, memories.md, autonomous-log are mutable Lyra state. If the bot can write AND Claude Code can write, concurrent-mutation hazards emerge — schema corruption, lost writes, race conditions. Single-writer guarantee or explicit conflict-resolution protocol needed.

5. **Auth + identity.** Single-user system today (Maerg-only). Bot must reject all non-Maerg messages. Telegram user ID lock pattern is the cheap answer; needs explicit ratification.

---

## Sub-decisions Chuck owns

### Sub-decision 1 — Platform

Lyra's informational lean: **Telegram**. Rationale below; final lock is Chuck's.

| Platform                       | Solo-API friction                                                              | Rich UX                                  | Library ecosystem                          | Operational time-to-first-message |
| ------------------------------ | ------------------------------------------------------------------------------ | ---------------------------------------- | ------------------------------------------ | --------------------------------- |
| **Telegram**                   | None — `@BotFather` → bot token in 30s                                         | Native cards, buttons, polls, MarkdownV2 | Mature (`python-telegram-bot`, `telegraf`) | Hours                             |
| **WhatsApp**                   | Severe — Meta Business verification, business API, phone provisioning, expense | Limited (buttons in template msgs only)  | Enterprise-focused                         | Weeks                             |
| **Discord**                    | None — bot creation similar to Telegram                                        | Native cards, buttons, threads           | Mature (`discord.py`, `discord.js`)        | Hours                             |
| **iMessage / Apple Shortcuts** | Mac-only, AppleScript or Shortcuts integration                                 | Limited; native message format           | Sparse                                     | Days                              |
| **Signal**                     | Possible but limited bot ecosystem                                             | Limited                                  | Sparse                                     | Days+                             |

**Caveat to surface in pre-mortem:** the friend-facing surface (Lyra drafts an invite, Maerg forwards to Burcu/etc.) is WhatsApp regardless of platform choice — that's Maerg→Friend, not Maerg→Lyra. Different surface, no conflict. But: if a future feature wants Lyra to send messages directly to friends (V3+ scope), WhatsApp re-enters as a platform conversation.

### Sub-decision 2 — Hosting (also resolves the two registered-but-unwired routines)

| Pattern                                                    | Always-on chat?                             | Scheduled routines?                           | Cost                | Risk                                                                                         |
| ---------------------------------------------------------- | ------------------------------------------- | --------------------------------------------- | ------------------- | -------------------------------------------------------------------------------------------- |
| **Laptop-bound** (bot + cron on Maerg's MacBook)           | Only when laptop is open                    | Only when laptop is open at routine fire-time | $0                  | Misses messages + skipped routines when laptop is closed/sleeping; Maerg's travel = downtime |
| **Cloud VPS** (small DigitalOcean/Fly droplet)             | Yes                                         | Yes (built-in cron OR systemd timers)         | ~$5-10/mo           | Always-available; secrets posture (bot token + Claude API key on cloud)                      |
| **GitHub Actions**                                         | No (polling/cron only — not real-time chat) | Yes (matches `autonomous_layer_default`)      | $0 within free tier | Bad fit for conversational latency; right fit for routines                                   |
| **Hybrid: laptop chat + GH Actions routines**              | Laptop only                                 | Always (GH Actions)                           | $0                  | Two runtimes, shared state — concurrency hazard surface                                      |
| **Hybrid: cloud chat + GH Actions routines**               | Yes                                         | Always (GH Actions)                           | ~$5/mo              | Two runtimes, shared state, two secrets surfaces                                             |
| **Cloud-everything** (chat AND routines on same cloud VPS) | Yes                                         | Yes                                           | ~$5-10/mo           | Single runtime, single secrets surface, single concurrency model                             |

**Two registered routines per `automations-registry.yaml`** (both currently in TBD-wiring state per `memories-autonomous-log.md ## first-run-calibration`):

1. `weekly-plan-generation` — fires Sunday 19:00 UTC; calls Lyra's `*weekly-plan` autonomously to surface the upcoming week's options before Maerg invokes
2. `event-proximity-check` — fires every 2-3 days; scans calendar for Lyra-rec'd events approaching within 48h, surfaces "you have $event Friday — `*event-prep`?" reminders

The hosting choice ratifies wiring for BOTH routines AND the chat bot in one call. **Cloud-everything** (or **Cloud chat + GH Actions routines**) probably wins on operational simplicity once secrets posture is sorted; **laptop-everything** sounds attractive for $0 cost but fails the actual reminder-reliability test ("how are you going to remind me?" — _by being on at the right time, which a laptop is not_). Chuck's lens.

Future routines composing with this: any team-maerg agent's scheduled task (Atlas's `routine-1`, San v2 PMF cadence checks, etc.) inherits the hosting decision.

### Sub-decision 3 — Brain integration

How does the bot reach Lyra's intelligence?

| Path                       | What it means                                                                                                                                                                                                                 |
| -------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Claude API direct**      | Bot server makes Claude API calls with a system prompt that loads Lyra's sidecar files dynamically. Each chat turn = API call. Stateless between turns; conversation context maintained via prompt caching + message history. |
| **Claude Code subprocess** | Bot spawns a Claude Code session with Lyra activated, pipes messages in/out. Heavier per-turn cost but identical behavior to current Claude Code experience.                                                                  |
| **Hybrid**                 | Claude API for stateless lookups; Claude Code for stateful workflows (`*weekly-plan`, `*reflect`). Most complex.                                                                                                              |

Cost-shape and fidelity-shape differ substantially. Pre-mortem prompt: _"It's August 2026. The Claude API path drifted from Claude Code Lyra; behavior diverged after a model upgrade. How do we keep parity?"_

### Sub-decision 4 — State persistence + concurrency

V1 is single-writer: Claude Code is the only mutator of preferences.yaml, memories.md, autonomous-log. Adding the bot as a second writer creates concurrent-mutation hazards.

| Pattern                                               | Tradeoff                                                                                                                                                    |
| ----------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Single-writer (bot is read-only)**                  | Bot reflects state, never mutates. Maerg confirms preference updates via Claude Code. Preserves Q12-mirror gate cleanly but adds friction to chat-first UX. |
| **Bot is sole writer; Claude Code becomes read-only** | Inverts current model. Forces all mutation through chat. Q12-mirror gate moves to bot side.                                                                 |
| **Both writers + lock protocol**                      | File-level locking (advisory lock, mutex file, etc.) — both surfaces can mutate; conflict resolution explicit. Most flexible, most complex.                 |
| **Single source of truth = database**                 | Migrate state from YAML/MD to SQLite/Postgres; both surfaces talk to DB; transactional integrity built-in. Biggest refactor.                                |

Pre-mortem prompt: _"It's June 2026. preferences.yaml is corrupted because the bot wrote during a Claude Code edit. How do we recover, and what prevents recurrence?"_

### Sub-decision 5 — Auth + identity

Single-user lock today. Telegram user ID match is the cheap answer:

```python
ALLOWED_USER_ID = <Maerg's Telegram user ID>
if message.from_user.id != ALLOWED_USER_ID:
    return  # silently drop
```

Multi-user (e.g., spouse, friends with their own Lyra) is a much bigger architectural surface — out of V1 scope; flag if Maerg signals intent.

### Sub-decision 6 — Cross-agent scope

Is this **Lyra-only**, or **team-maerg-shared infrastructure**?

| Path                              | Implication                                                                                                                                                  |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **Lyra-only bot**                 | Faster to ship; doesn't pre-decide for Atlas + siblings. Risk: Atlas wants chat too in 3 months, we build a second one.                                      |
| **Shared bot, agent routing**     | Bot has a `/lyra`, `/atlas`, `/chuck` command prefix (or smart routing). One runtime, shared state-access layer, per-agent personas. Bigger up-front design. |
| **Shared runtime, separate bots** | Each agent has its own Telegram bot (separate token), shared infra underneath. Middle ground.                                                                |

Composes with the bigger team-maerg architecture question of how multiple SME agents share infrastructure. Worth surfacing as a related lens; may warrant separate decision after this one.

---

## Pre-mortem prompts (for the workflow to expand)

1. _"It's August 2026. The Telegram bot is operational but Lyra's responses feel slower and dumber than the Claude Code experience. Why?"_ — Claude API path drift, prompt caching breakage, system-prompt token bloat.
2. _"It's October 2026. preferences.yaml got corrupted last week and we lost 3 weeks of preference signal. What happened?"_ — concurrent writes, lock protocol failure.
3. _"It's December 2026. The cloud VPS hosting the bot was compromised; bot token + Claude API key leaked. Damage?"_ — secrets posture, blast radius.
4. _"It's January 2027. Maerg adds Atlas to the bot. The two agents are stepping on each other's state. Why didn't Sub-decision 6 prevent this?"_ — cross-agent scope under-specified.
5. _"It's March 2027. Bot has been running fine. But Maerg has stopped using Claude Code for Lyra entirely. Did we lose a useful surface?"_ — chat-first ≠ chat-only; Claude Code might still be the right tool for deep work like `*reflect`, `*research`, schema revision.
6. _"It's July 2026. The hybrid (cloud chat + GH Actions routines) drifted: routine output is reaching the bot 6 hours late because GH Actions queued behind other repo workflows; weekly-plan-generation surfaces Sunday night instead of Sunday evening. Worth it?"_ — GH Actions execution latency vs scheduled-cron-on-cloud; pre-mortem the "free tier" assumption for things that need to be timely.
7. _"It's October 2026. The Sunday weekly-plan routine fires while Maerg is mid-`*reflect` in Claude Code; preferences.yaml ends up half-written with stale data. What's the lock protocol?"_ — concurrent writers across runtimes (chat bot + scheduled routine + Claude Code) compounds Sub-decision 4's concurrency model.

---

## Lens-relevant axes (suggested for `*architecture-decision`)

- **Time-to-first-message** (operational urgency)
- **Cost economics** (laptop vs cloud, API call costs at projected fire rate)
- **Behavior parity with Claude Code Lyra** (Brain integration choice)
- **State integrity guarantees** (concurrency model)
- **Security posture** (secrets handling, single-user auth)
- **Cross-agent reusability** (Lyra-only vs team-maerg-shared)
- **Failure modes — graceful degradation** (what happens when bot is down? Maerg falls back to Claude Code, which still works)
- **Reversibility** (changing platform, hosting, brain integration mid-flight cost)
- **Composes-with** axes:
  - `autonomous_layer_default: github-actions` (scheduled routines)
  - Calendar-write invariant (bot inherits L3 confirmation gate, no booking, etc.)
  - Q12-mirror gate (preference mutations)
  - Voice tagging (bot responses tagged `[Lyra's view]` per persona)

---

## Non-binding lean (Lyra's view; Chuck owns the call)

1. **Platform: Telegram.** WhatsApp's solo-API friction makes it a bad first move; Telegram delivers operational chat in hours.
2. **Hosting: hybrid — laptop primary, cloud cron for scheduled routines.** Real-time chat on laptop while open; missed messages buffer until laptop wakes; weekly-plan-generation routine runs on GH Actions per existing default.
3. **Brain integration: Claude API direct with cached system prompt.** Lower per-turn cost; explicit version-pinning to prevent drift.
4. **State persistence: bot is read-write; lock protocol via mutex files; defer DB migration to later.**
5. **Cross-agent scope: build Lyra-only bot first; design state-access layer to be shareable so Atlas can plug in later without rewrite.**

This is informational. The pre-mortem + lens analysis lives in `*architecture-decision`, not here.

---

## Non-blocking status

V1 Claude Code surface continues to operate fully. Maerg's chat-first preference is a UX upgrade target, not a blocker. Recommended decision pacing: not urgent — current `*find` and `*weekly-plan` cycles work end-to-end in Claude Code; bot is the discovery vehicle for cleaner UX.

---

## Cross-references

- `_data/handoffs/2026-05-05-lyra-fetch-architecture.md` — sibling architectural brief, same session, different scope
- `team-maerg/config.yaml` — `autonomous_layer_default: github-actions` (composes with hosting decision)
- `bmad/team-maerg/agents/lyra-sidecar/instructions.md` — Calendar-Write Invariant, Q12-mirror gate, voice tagging (all inherit to bot)
- `_data/recommendation-discipline.md` — Tier 3 routing rule
- `_data/team-principles.md` — principles 1-6 (apply to bot identically — fact-at-emission, layered validation, spec-ambiguity, confidence ≠ evidence, protocols-from-incidents, recommendations-carry-tier)

---

_Drafted by Lyra 🎼 in same session as fetch-architecture brief. Maerg parked the architectural decision (Path 1) for a separate Chuck session; both briefs ready to be picked up whenever `*architecture-decision` fires._
