<!-- Handoff spec from Chuck (team-maerg/chuck) to bmb (bmad/bmb/agents/bmad-builder).
     Authored 2026-05-05. Per Atlas v2 ADR Q5 (System-agnostic Handoff Protocol),
     this is the first cross-namespace handoff using file-based mechanism.

     Goal: bmb creates the /schedule routine for the bi-weekly upstream-scan
     automation owned by Chuck (per ADR 2026-05-05-distributed-automation-ownership).
     Updates the automations-registry mechanism field with the routine ID after
     creation. -->

# Handoff: create bi-weekly upstream-scan /schedule routine

**From:** team-maerg/chuck
**To:** bmad/bmb/agents/bmad-builder (or any agent with schedule-skill access)
**Date:** 2026-05-05
**Type:** routine creation request

## Context

Chuck's `*automations` registry has a row `upstream-scan-bi-weekly` with `mechanism: "TBD"` — needs a real /schedule routine wired in. Per ADR `bmad/team-maerg/_data/decisions/2026-05-05-distributed-automation-ownership.md`, the routine is owned by Chuck (meta-architecture lane) but creation goes through the schedule skill which lives in your access path.

Background on the broader policy: each team-maerg agent owns automations within their domain; shared `automations-registry.yaml` provides cross-agent visibility. The 2026-05-18 calibration routine you previously created for Atlas (ID `trig_01CVRB9vm6vHgr38EWm8QD8F`) is the existing precedent for cadence + clone + bash + commit + push pattern.

## What the routine should do

Each fire (bi-weekly Monday 06:00 UTC, starting 2026-05-18):

1. **Clone or pull** `git@github.com:maerg-eth/BMAD-METHOD.git` branch `v6-alpha` into the routine's working directory
2. **Add upstream remote** (if not present): `git remote add upstream git@github.com:bmad-code-org/BMAD-METHOD.git` (note: SSH may not work in cloud routine — use HTTPS if needed: `https://github.com/bmad-code-org/BMAD-METHOD.git`)
3. **Fetch upstream main with explicit refspec:** `git fetch upstream main:refs/remotes/upstream/main` (the explicit refspec form is needed — bare `git fetch upstream` fails in this repo because upstream's fetch refspec is configured for `v6-alpha` only)
4. **Run the scan command:** `git log v6-alpha..upstream/main --oneline -- bmad/core/ bmad/bmb/ tools/ package.json`
5. **Bucket commits by area** based on commit messages and paths touched. Use these buckets (derived from today's manual scan; adjust per actual content):
   - `installer/` — anything in `tools/installer/` or `tools/cli/` or related installer changes
   - `skills system` — anything mentioning skills config, TOML manifest, agent customization
   - `core / bmb workflows` — changes to `bmad/core/`, `bmad/bmb/` not covered above
   - `package.json / deps / scripts` — package.json changes (deps, scripts, lint-staged config)
   - `platform support` — anything adding/modifying support for specific IDEs / CLIs
   - `bug fixes / chore / docs` — non-substantive
   - `other` — uncategorized
6. **Recommend cherry-pick targets** (default: none). Flag a commit as a recommended candidate IF any of:
   - Commit message matches keywords: `lint-staged`, `husky`, `prettier`, `format:fix`, `package.json` (infrastructure we use)
   - Touches paths team-maerg directly references: `bmad/core/agents/`, `bmad/core/tasks/`, `bmad/bmb/workflows/create-agent/` (paths Chuck and Atlas activation depends on)
   - Tagged as `fix(security)` or contains `CVE` / `vulnerability`
7. **Write output** to `bmad/team-maerg/_data/upstream-scans/<YYYY-MM-DD>.md` with this format:

```markdown
# Upstream scan — <YYYY-MM-DD>

**Routine:** <routine-id>
**Scanned range:** v6-alpha..upstream/main (origin: maerg-eth/BMAD-METHOD; upstream: bmad-code-org/BMAD-METHOD)
**Total team-maerg-relevant commits since last scan:** <N>
**Total commits since last scan (any area):** <M>

## Bucket summary

| Bucket                        | Count | Notable                  |
| ----------------------------- | ----- | ------------------------ |
| installer/                    | N     | <commit-list-or-summary> |
| skills system                 | N     | ...                      |
| core / bmb workflows          | N     | ...                      |
| package.json / deps / scripts | N     | ...                      |
| platform support              | N     | ...                      |
| bug fixes / chore / docs      | N     | ...                      |
| other                         | N     | ...                      |

## Recommended cherry-picks

<EITHER "None — no commits met cherry-pick criteria this scan" OR a list of commits with sha, message, reason flagged>

## Notes

<Any anomalies — e.g., upstream renamed a path team-maerg depends on, large refactor that may break compatibility, etc.>

---

Per ADR 2026-05-05-distributed-automation-ownership.
```

8. **Commit + push** the brief to `origin/v6-alpha` with message: `chore(upstream-scan): bi-weekly upstream-scan brief <YYYY-MM-DD>`
9. **STOP gracefully** if any prerequisite fails:
   - origin clone fails (e.g., maerg-eth/BMAD-METHOD/v6-alpha doesn't exist) → surface "fork or branch missing"
   - upstream fetch fails → surface "upstream unreachable"
   - bash command produces no output → surface "v6-alpha is current with upstream main (no scan needed)"
   - Don't fabricate a brief on missing data; STOP cleanly so user knows action is needed

## Cadence + scheduling

- **Cadence:** bi-weekly Mondays at 06:00 UTC
- **First fire:** 2026-05-18 06:00 UTC (matches the existing calibration routine date — convenient, both fire same morning)
- **Subsequent fires:** every 2 weeks (next: 2026-06-01, 2026-06-15, ...)

If your /schedule mechanism doesn't support "every 2 weeks" directly, options:

- Cron expression: `0 6 1-31/14 * 1` may work depending on cron flavor (fires Monday on every 14th day-of-month — imperfect; alternatives welcome)
- Two staggered weekly routines, each fires bi-weekly when day-of-year is even/odd parity
- Or whatever bi-weekly mechanism your skill supports

If genuinely bi-weekly isn't supported, fall back to weekly with a check-and-skip: routine fires weekly, but on weeks where `(week-of-year mod 2) != 0` it self-exits with "skipping — not a scan week."

## Reporting back to Chuck

After routine creation, please:

1. **Report the routine ID** (e.g., `trig_XXXXXXXXXX`)
2. **Update the registry** at `bmad/team-maerg/_data/automations-registry.yaml`, row `id: upstream-scan-bi-weekly`:
   - Replace `mechanism: "TBD — /schedule routine to be created by schedule skill"` with `mechanism: "/schedule routine <routine-id>"`
   - Confirm `next_fire: 2026-05-18` is still accurate (update if the actual first fire date differs)
3. **Commit the registry update** with message: `chore(automations-registry): wire upstream-scan-bi-weekly routine ID`
4. **Push to origin/v6-alpha**
5. **Acknowledge back to Maerg** — the routine is wired, registry reflects reality, first fire is 2026-05-18

## Failure modes to anticipate

- **Schedule skill doesn't support bi-weekly directly:** see fallback options above; pick the cleanest one available.
- **Routine needs different clone URL:** if SSH doesn't work in your routine environment, use HTTPS form. If neither works, may need to use GitHub API to fetch tree contents — escalate back if so.
- **Bash command output is huge** (e.g., 1000+ commits): truncate to top 50 in the brief, include total count in summary; user can run full scan locally if needed.
- **Upstream has restructured paths since this spec was written:** the bash command's path filter may need updating. If `bmad/core/` no longer exists upstream, that's a load-bearing finding — surface in brief notes section.

## Cross-references

- **ADR:** `bmad/team-maerg/_data/decisions/2026-05-05-distributed-automation-ownership.md`
- **Registry row:** `bmad/team-maerg/_data/automations-registry.yaml` → `id: upstream-scan-bi-weekly`
- **Sibling routine** (already exists, similar pattern): the 2026-05-18 calibration routine (`trig_01CVRB9vm6vHgr38EWm8QD8F`)
- **Today's session context:** scan was originally proposed monthly (signal-density argument); Maerg countered with bi-weekly for active-build-state awareness; ADR documents the cadence reasoning for future calibration.

## Acknowledgment expected

Once the routine is created, registry updated, and changes pushed, acknowledge to Maerg with:

- Routine ID
- Confirmed first-fire date
- Any deviations from this spec (e.g., cron expression chosen, fallback mechanism used)
- Any unresolved issues that need Chuck or Maerg attention
