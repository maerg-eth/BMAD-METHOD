# Architecture-Decision Workflow Checklist

Validates ADR records produced by the `*architecture-decision` workflow. Each check is evaluated against the written ADR file at `{decisions_folder}/{YYYY-MM-DD}-{slug}.md`. A failed check indicates either a workflow bug or a capture-quality gap that should HALT step 6 before final ratification.

## Frontmatter Integrity

- [ ] Frontmatter block present, opens with `---`, closes with `---`.
- [ ] `id` present; format `YYYY-MM-DD-slug` matching the filename's date and slug components.
- [ ] `date` is a valid ISO date (YYYY-MM-DD).
- [ ] `status` is exactly one of: `Proposed`, `Accepted`, `Superseded` (canonical) or `Rejected` (non-canonical but allowed when explicitly chosen at step 6 ratification).
- [ ] `title` is non-empty and imperative (e.g., "Adopt X" / "Defer X to Phase 2", not "Should we X?").
- [ ] `deciders` is a non-empty list.
- [ ] `supersedes` is null OR a valid prior ADR id.
- [ ] `superseded_by` is null OR a valid future ADR id.

## Section Presence

- [ ] All eight H2 sections present in order: Context, Lens citations, Options Considered, Tradeoffs, Recommendation, Dissent, Outcome, Cross-references.
- [ ] No section contains only template placeholders (e.g., unfilled `<...>` angle-bracket prompts).

## Lens Citations

- [ ] At least one lens cited with: lens number, name, and one-sentence justification.
- [ ] If "no lens fits" was the path taken at workflow step 2, the new lens proposal is recorded in the Cross-references section.

## Options Considered

- [ ] Minimum 2 options present (single-option ADRs are an anti-pattern per MADR docs).
- [ ] Each option has all four sub-sections filled: What, Pros, Cons, Cost / blast radius / reversibility.
- [ ] If only 1 option is genuinely viable, the rejected alternatives are named and explained in Context or Cross-references — they belong documented, not absent.

## Tradeoffs

- [ ] Axis of choice named explicitly (e.g., "cost vs correctness", "in-lane vs cross-lane", "reversibility vs commitment").

## Recommendation

- [ ] States which option.
- [ ] Cites ≥1 lens from the Lens Citations section.
- [ ] If subagents were spawned (workflow substep 3a fired), specific subagent claims are attributed by source — no anonymous "research showed" voice.

## Dissent (Principle 8)

- [ ] Dissent section is present and non-empty.
- [ ] If contents are "none — structurally clean", the absence is flagged (per workflow step 5: absence-of-dissent on a non-trivial decision means the option space may not have been fully explored — re-examine before accepting).

## Outcome

- [ ] If `status: Proposed`, Outcome reads "Pending ratification."
- [ ] If `status: Accepted` / `Rejected` / `Modified`, Outcome contains the Decided / By / As fields filled.
- [ ] `Followup commits` field is present (may be empty if implementation hasn't followed yet).

## Cross-references

- [ ] At least one of: prior ADR ids, lens references, principle references, or session/commit refs is named (the ADR exists in a system; isolation is a smell).

## Filename

- [ ] Matches `YYYY-MM-DD-slug.md` (or `YYYY-MM-DD-slug-HHMMSS.md` for same-day re-runs).
- [ ] Slug matches the frontmatter `id`'s slug component.

## Final Validation

- [ ] Frontmatter Integrity — Issue list:
- [ ] Section Presence — Issue list:
- [ ] Lens Citations — Issue list:
- [ ] Options Considered — Issue list:
- [ ] Tradeoffs — Issue list:
- [ ] Recommendation — Issue list:
- [ ] Dissent — Issue list:
- [ ] Outcome — Issue list:
- [ ] Cross-references — Issue list:
- [ ] Filename — Issue list:
