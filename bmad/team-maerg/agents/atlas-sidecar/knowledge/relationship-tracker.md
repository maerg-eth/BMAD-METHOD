---
type: agent-knowledge
maintained_by: Atlas 🪶
last_updated: 2026-05-04
decay_class: volatile
---

# Atlas Relationship Tracker

> CoS relationship management layer. Updated after every meaningful interaction.
> Heat: 🟢 active & on track | 🟡 needs attention soon | 🔴 overdue or at risk | ⚫ archived
> Engagement-level taxonomy (per Casnocha / Reid Hoffman): Principal | Board | Investor | Friend | Team

---

## Heat Map

| Contact                                                  | Organisation | Last Contact | Heat | Engagement | Next Action | Due |
| -------------------------------------------------------- | ------------ | ------------ | ---- | ---------- | ----------- | --- |
| <!-- Atlas appends rows here as relationships emerge --> |              |              |      |            |             |     |

---

## Meeting Prep/Debrief Log

_One entry per significant meeting. Format: [Date] | [Contact] | [Prep notes or debrief outcome] | [Next action set]_

| Date                                                                     | Contact | Notes | Next action |
| ------------------------------------------------------------------------ | ------- | ----- | ----------- |
| <!-- Atlas appends rows here after *meeting-prep or *meeting-debrief --> |         |       |             |

---

## Intro Architecture

_Tracks warm intro chains — who can introduce whom, and when to activate._

| Target                                                 | Route | Via | Status | Timing |
| ------------------------------------------------------ | ----- | --- | ------ | ------ |
| <!-- Atlas appends rows here as intro paths emerge --> |       |     |        |        |

---

## Engagement-level definitions

Per Framework research (Casnocha, Reid Hoffman 10,000-hour practitioner accounts), classifying each contact's engagement level conditions tone and routing:

- **Principal** — peer-level relationships where Maerg is principal-to-principal (other founders, key investors, peer CEOs). High-context, low-frequency, high-stakes.
- **Board** — board members and advisors with formal oversight role. Medium-frequency, structured cadence.
- **Investor** — current and target investors. Cadence driven by fundraising stage; updates expected.
- **Friend** — personal relationships that overlap professional context. Low formality, high trust.
- **Team** — direct reports, advisors who function as extended team. High-frequency, deliverable-driven.

Engagement level is a stable property — set at first significant interaction, revised only on relationship type change (e.g., friend → investor when they invest).

---

## Update Rules

- **After any meaningful conversation** with a contact: update Last Contact date + Heat (via Maerg confirmation if mid-session, or auto if Maerg invokes `*meeting-debrief`)
- **After a meeting:** add one line to Meeting Prep/Debrief Log
- **After an intro activates:** update Intro Architecture status
- **Weekly:** Atlas runs heat check in `*brief` — flags any 🔴 contacts with no movement in 7+ days
- **Engagement-level setting:** at first significant contact OR when relationship type changes (e.g., friend → investor)

---

## Cross-references

- `_data/recommendation-discipline.md` — `*meeting-prep` talking points and `*relationship-map` action recommendations emit T2 footers
- `cos-frameworks.md` Framework 008 (Proactive Scan, Layer 3) — relationship heat scan in every `*brief`
- `instructions.md` §11-relationship-map, §12-meeting-prep, §13-meeting-debrief

---

_Created: 2026-05-04 (Atlas v2 sidecar) | Schema ported from v1 + engagement-level field added per Q1 lock_
_Maintained by Atlas 🪶 | Structure ratified by Chuck 🧠_
