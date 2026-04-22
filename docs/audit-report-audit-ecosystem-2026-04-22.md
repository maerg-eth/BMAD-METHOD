# Workflow Audit Report

**Workflow:** audit-ecosystem
**Audit Date:** 2026-04-22
**Auditor:** Audit Workflow (BMAD v6) via BMad Builder
**Workflow Type:** Action (template: false)
**Target path:** `bmad/team-maerg/workflows/audit-ecosystem/`

---

## Executive Summary

**Overall Status:** PASS (clean ship)

- Critical Issues: **0**
- Important Issues: **0**
- Cleanup Recommendations: **2** (both stylistic, one already inline-commented, one already user-flagged as carry-forward)

**Strict pass rate:** ~93% (46/50 strict checks). **Charitable pass rate:** ~100% (50/50 — when convention-allowed patterns are accepted).

Either way above the 85% rework threshold and at/above the 95% clean-ship threshold.

---

## 1. Standard Config Block Validation

**Status:** PASS (7/7)

| Check                                             | Result                                         |
| ------------------------------------------------- | ---------------------------------------------- |
| `config_source` defined                           | ✓ `{project-root}/bmad/team-maerg/config.yaml` |
| Points to correct module config                   | ✓ team-maerg                                   |
| Uses `{project-root}`                             | ✓                                              |
| `output_folder` pulls from config_source          | ✓                                              |
| `user_name` pulls from config_source              | ✓                                              |
| `communication_language` pulls from config_source | ✓                                              |
| `date: system-generated`                          | ✓                                              |

No issues.

---

## 2. YAML/Instruction/Template Alignment

**Variables Analyzed:** 3 declared (2 in `variables:` block + 1 top-level output field) + 7 in `recommended_inputs` + 1 `required_tools`
**Used in Instructions (explicit reference):** 3 of 3 core variables (100%)
**Documentation-convention only:** 8 (`recommended_inputs` sub-items + `required_tools`) — not referenced as `{variable}` by design
**Unused (bloat):** 0 truly unused

Explicit variable-reference checks:

| Variable                        | Referenced in                                     | Status           |
| ------------------------------- | ------------------------------------------------- | ---------------- |
| `variables.ecosystem_registry`  | instructions step 1, step 9                       | INSTRUCTION_USED |
| `variables.audit_output_folder` | default_output_file + instructions step 1         | INSTRUCTION_USED |
| `default_output_file`           | engine-consumed, derived from audit_output_folder | ENGINE_USED      |

Convention-only (documentation inputs — ignoring per BMAD norm):

- `recommended_inputs.agent_sources`
- `recommended_inputs.agent_compiled_md`
- `recommended_inputs.agent_claude_commands`
- `recommended_inputs.agent_manifest_csv`
- `recommended_inputs.manifest_yaml`
- `recommended_inputs.lens_framework`
- `recommended_inputs.workflows_folder`
- `required_tools.Bash`

**Note:** `recommended_inputs` is per BMAD template convention "suggested inputs for the user" — documentation rather than runtime variable references. Same pattern used by bmm and bmb workflows (story-context, create-story, create-workflow itself). Not flagged.

**Hardcoded-path-that-could-be-variable check:** Instructions hardcode several paths (e.g., `src/modules/team-maerg/agents/*.agent.yaml`, `bmad/_cfg/agent-manifest.csv`). This tension is already documented with an inline comment in workflow.yaml:

> `# Audit read-scope (system paths the workflow reads — not user-provided docs).`
> `# Kept here for scope documentation; if BMAD strictness matters, move these to`
> `# variables: block.`

Flagged as **cleanup item 1** below.

---

## 3. Config Variable Usage

**Status:** PASS (4/4)

| Check                                                  | Result                                                                            |
| ------------------------------------------------------ | --------------------------------------------------------------------------------- |
| `{communication_language}` in communication            | ✓ critical header + step 2 abort msg + step 8 summary + step 10 report            |
| `{user_name}` in personalization                       | ✓ step 10 completion report                                                       |
| `{output_folder}` / `{audit_output_folder}` for writes | ✓ all writes to `{audit_output_folder}`; no hardcoded `/output/` or `/generated/` |
| `{{date}}` for date awareness                          | ✓ filename + frontmatter + step 6 Gap 2 subtraction + step 9 decline record       |

No `{{communication_language}}` misuse in template headers (N/A — no template.md, action workflow).

---

## 4. Web Bundle Validation

**Status:** PASS (intentionally absent)

No `web_bundle` section. Correct call — workflow reads git history, invokes `Bash` for `git log`/`mkdir`/`date`, reads cross-module paths (`src/modules/...`, `.claude/commands/...`), and writes to `_data/`. No web-bundleable surface.

---

## 5. Bloat Detection

**Bloat percentage:** ~0% strict (with convention ignored) / ~15% strict (counting documentation sub-items)

| Bloat category                             | Findings                                                   |
| ------------------------------------------ | ---------------------------------------------------------- |
| Unused yaml fields                         | 0 truly unused                                             |
| Commented-out variables                    | 0                                                          |
| Duplicate fields (top-level vs web_bundle) | 0 (no web_bundle)                                          |
| Hardcoded paths in instructions            | 8+ paths that could reference `recommended_inputs` entries |
| Redundant configuration                    | 0                                                          |

See **cleanup item 1** for the hardcoded-paths tension.

---

## 6. Template Variable Mapping

**Status:** SKIPPED (N/A — action workflow, no `template.md`)

---

## 7. Instructions Quality (bonus structural checks)

| Check                                                            | Result                                                                       |
| ---------------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `<critical>` headers present at top                              | ✓ (5 critical notices, including action-workflow directory-creation warning) |
| `<workflow>` wrapper present                                     | ✓                                                                            |
| Sequential step numbering (1–10)                                 | ✓ (plus 4a/4b sub-steps)                                                     |
| Each step has `goal=` attribute                                  | ✓ all 10                                                                     |
| Intent-based language at step 4b rendering and step 8 summary    | ✓                                                                            |
| Prescriptive language elsewhere                                  | ✓                                                                            |
| Conditional blocks closed correctly (`<check if="">...</check>`) | ✓ all balanced                                                               |
| Provisional parameters annotated                                 | ✓ (90-day staleness, Jaccard ≥ 0.25 both flagged with `<note>`)              |
| Graceful failure modes documented                                | ✓ step 9 Edit failure path                                                   |
| Variable cross-check complete                                    | ✓ all `{{vars}}` resolve to prior declarations or workflow.yaml              |

---

## Recommendations

### Critical (Fix Immediately)

_None._

### Important (Address Soon)

_None._

### Cleanup (Nice to Have)

**Cleanup 1 — hardcoded paths vs `recommended_inputs` references.** Several system paths (e.g., `src/modules/team-maerg/agents/*.agent.yaml`, `bmad/_cfg/agent-manifest.csv`) are written literally in instructions rather than referencing their `recommended_inputs` entries. Resolvable by either:

- (a) Moving the 7 sub-items from `recommended_inputs` into the `variables:` block and dereferencing them in instructions.md as `{agent_sources}` etc. — most strict-BMAD-conformant.
- (b) Leaving as documented tradeoff (current state) with the existing inline comment — preserves the "paths live in one place, right next to the scan logic" readability.

Neither is blocking. Tradeoff is conscious and commented. Defer until a future edit pass touches the recommended_inputs block.

**Cleanup 2 — carry-forward from user's third-pass review.** Step 4 line ~157 (`action` inside N≤1 branch) says "Record in audit: ..." which is interpretive between direct-write and variable-assignment for `{{table_4a}}` / `{{table_4b}}`. Same spec-ambiguity shape as the N1 fix that just landed on step 8's line 291. Step 10's render depends on interpretation. Functional today; worth aligning with the N1 pattern ("Record `{{table_4a}}` = 'Skipped — N≤1, no pairs to compute.'") on a future edit pass for consistent-pattern debt cleanup.

---

## Validation Checklist

- [x] All standard config variables present and correct
- [x] No unused yaml fields (truly unused)
- [x] Config variables used appropriately in instructions
- [x] Web bundle intentionally absent — correct for this workflow class
- [x] Template variables properly mapped — N/A (action workflow)
- [x] File structure follows v6 conventions

---

## Next Steps

1. No blocking issues — workflow is ready to ship.
2. Address cleanup items on the next edit pass (neither blocking).
3. Wire Chuck's `*audit-ecosystem` menu entry (currently `workflow="todo"`) to this workflow's yaml path.
4. Run BMAD installer Compile Agents step to make the command invocable.
5. First live run expected to show: `agents_active: 1`, `reconciliation: clean`, overlap section "Skipped — N≤1", top-priority dangling ref for missing `_data/lens-framework.md`.

---

**Audit Complete** — Generated by audit-workflow v1.0, run by BMad Builder.
