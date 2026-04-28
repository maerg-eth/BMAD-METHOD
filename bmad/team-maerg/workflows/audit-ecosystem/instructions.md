# Audit-Ecosystem Workflow Instructions

<critical>The workflow execution engine is governed by: {project-root}/bmad/core/tasks/workflow.xml</critical>
<critical>You MUST have already loaded and processed: {project-root}/bmad/team-maerg/workflows/audit-ecosystem/workflow.yaml</critical>
<critical>Communicate in {communication_language} throughout the workflow process</critical>
<critical>This is an action-workflow (template: false). The engine does NOT auto-create the output directory — step 1 performs an explicit mkdir before any writes.</critical>
<critical>The audit record is written on BOTH run_status paths: aborted (drift detected at step 2) and completed (all steps run). Never exit without writing.</critical>

<workflow>

<step n="1" goal="Load inputs and initialize audit record">

<action>Run `mkdir -p {audit_output_folder}` via Bash. Action-workflow engine does not create this directory.</action>

<action>Determine final audit filepath. Base path: `{audit_output_folder}/audit-{{date}}.md`. If that file already exists (same-day re-run), append `-HHMMSS` suffix: `{audit_output_folder}/audit-{{date}}-{{hhmmss}}.md`. Use `date +%H%M%S` via Bash for the suffix. Store as `{{audit_filepath}}`.</action>

<action>Load ecosystem registry from {ecosystem_registry}. Parse the full YAML and store as {{registry_parse}}. From {{registry_parse}}: extract `agents` list where `status == "active"` into {{active_agents}}. Compute {{agents_active}} = count of active.</action>

<action>Glob `{project-root}/src/modules/team-maerg/agents/*.agent.yaml` and read each file in full. For every file, parse into {{agent_yaml_parse[id]}} (keyed by `metadata.id`):

- metadata.id, metadata.name
- persona.role, persona.identity, persona.communication_style, persona.principles
- activation.critical_actions (or equivalent activation block — list of startup steps, file loads, invocations)
- menu items (cmd, and any of: workflow, exec, tmpl, data, action, validate-workflow attributes)</action>

<critical>The registry and the agent YAML file are BOTH authoritative — each carries different fields. Step 2 is the certifier: it uses the raw parses {{registry_parse}} and {{agent_yaml_parse[id]}} directly, because the bundle's correctness depends on properties (id presence, name coherence, file existence) that step 2 verifies. Steps 3+ reference {{agent_bundle[id]}} only, since by then reconciliation has certified the merge is safe. `scope_boundaries`, `purpose`, `success_rubric`, `capability_tier`, `last_reviewed`, `status` live in the registry only. `principles`, `role`, `identity`, `communication_style`, `metadata`, `critical_actions`, `menu` live in the agent YAML only.</critical>

<action>For every active agent, construct {{agent_bundle[id]}} by merging the registry row (matched by id) and the parsed agent YAML. The bundle is provisional until step 2 completes successfully; step 2 references the raw parses, not this bundle.

```
agent_bundle[id] = {
  # from registry row (matched by id)
  scope_boundaries: registry_parse.agents[id].scope_boundaries,
  purpose:          registry_parse.agents[id].purpose,
  success_rubric:   registry_parse.agents[id].success_rubric,
  capability_tier:  registry_parse.agents[id].capability_tier,
  last_reviewed:    registry_parse.agents[id].last_reviewed,
  status:           registry_parse.agents[id].status,

  # from src/modules/team-maerg/agents/{id}.agent.yaml
  metadata:            agent_yaml_parse[id].metadata,
  role:                agent_yaml_parse[id].persona.role,
  identity:            agent_yaml_parse[id].persona.identity,
  communication_style: agent_yaml_parse[id].persona.communication_style,
  principles:          agent_yaml_parse[id].persona.principles,
  critical_actions:    agent_yaml_parse[id].critical_actions,
  menu:                agent_yaml_parse[id].menu,
}
```

Steps 3 through 10 reference {{agent_bundle[id]}}. Step 2 uses the raw parses directly.</action>

<action>Read `{project-root}/bmad/_cfg/agent-manifest.csv` and `{project-root}/bmad/_cfg/manifest.yaml`. Extract all rows/entries referencing team-maerg agents. Store as {{manifest_csv_rows}} and {{manifest_yaml_entries}}.</action>

<action>Glob `{project-root}/bmad/team-maerg/agents/*.md` into {{compiled_md_files}}. Glob `{project-root}/.claude/commands/bmad/team-maerg/agents/*.md` into {{claude_cmd_files}}. For each, capture filesystem mtime.</action>

<action>Check whether `{project-root}/bmad/team-maerg/workflows/` contains subdirectories other than `audit-ecosystem/`. If yes, glob into {{other_workflows}}. If no, {{other_workflows}} = empty — skip downstream workflow-aware checks conditionally.</action>

<action>Check whether `{project-root}/bmad/team-maerg/_data/lens-framework.md` exists. Store as boolean {{lens_framework_present}}. If false, this is flagged in step 7 as a special dangling reference.</action>

<action>Initialize audit record state in memory:

- date: {{date}}
- run_status: "in-progress"
- reconciliation: "pending"
- findings_count: 0
- drift_count: 0
- agents_active: {{agents_active}}

This record is written to {{audit_filepath}} at step 2 on abort, or at step 10 on completion. No writes occur at step 1 beyond mkdir.</action>

</step>

<step n="2" goal="Reconciliation — drift-first HALT gate">

<critical>This step is the hard gate. If any drift is detected, the audit aborts here and no subsequent step runs. The aborted audit record is still written in full (not a stub) with run_status=aborted, reconciliation=drift, and complete drift findings.</critical>

<action>BMAD uses two id conventions for the same agent. The registry uses short form `<module>/<short-name>` (e.g., `team-maerg/chuck`). The YAML `metadata.id` uses compiled-path form (e.g., `bmad/team-maerg/agents/chuck.md`). Filenames use short-name only (e.g., `chuck.agent.yaml`, `chuck.md`). The id-resolution algorithms below are binding for step 2 — naive `{id}` substitution into a path is incorrect.

Forward resolution (registry row → resolved paths). Apply once per active agent before running coherence checks:

```
For each registry_row in {{active_agents}}:
  registry_id      = registry_row.id                                            # "team-maerg/chuck"
  if "/" not in registry_id: flag as "registry.id format violation" (drift); continue
  module, short    = registry_id.split("/", 1)                                  # ("team-maerg", "chuck")
  source_path      = "{project-root}/src/modules/" + module + "/agents/" + short + ".agent.yaml"
  compiled_path    = "{project-root}/bmad/" + module + "/agents/" + short + ".md"
  claude_cmd_path  = "{project-root}/.claude/commands/bmad/" + module + "/agents/" + short + ".md"
  resolved_paths[registry_id] = {module, short, source_path, compiled_path, claude_cmd_path}
```

Reverse resolution (YAML `metadata.id` → registry id). Apply once per source YAML file:

```
For each yaml_file in {project-root}/src/modules/team-maerg/agents/*.agent.yaml:
  metadata_id  = agent_yaml_parse[yaml_file].metadata.id                        # "bmad/team-maerg/agents/chuck.md"
  parts        = metadata_id.split("/")                                          # ["bmad", "team-maerg", "agents", "chuck.md"]
  if len(parts) != 4 or parts[0] != "bmad" or parts[2] != "agents" or not parts[3].endswith(".md"):
    flag yaml_file as "yaml metadata.id format violation" (drift); skip remaining steps for this file
  module = parts[1]
  short  = parts[3][:-3]                                                         # strip trailing ".md"
  derived_registry_id = module + "/" + short                                    # "team-maerg/chuck"
  yaml_to_registry_id[yaml_file] = derived_registry_id
```

Format violations from either algorithm are recorded as drift findings (one per violation, with check type "id format violation" and the offending value).</action>

<action>For each active agent in {{active_agents}}, verify coherence across sources using the resolved forms above. Step 2 references the raw parses {{registry_parse}} and {{agent_yaml_parse[id]}} — NOT {{agent_bundle[id]}}, because this step certifies the properties the bundle assumes. Record each check as a pass/fail row in {{drift_findings}}:

Coherence checks per agent (let `r = resolved_paths[registry_id]`):

1. Registry → source YAML: Does `r.source_path` exist on disk?
2. Registry → compiled MD: Does `r.compiled_path` exist on disk?
3. Registry → Claude command: Does `r.claude_cmd_path` exist on disk?
4. Registry → manifest CSV: Is there a row in {{manifest_csv_rows}} where `name == r.short` AND `module == r.module`?
5. Registry → manifest YAML: Is `r.module` listed in {{manifest_yaml_entries}}'s modules list?
6. Name match: `registry_parse.agents[registry_id].name == agent_yaml_parse[r.source_path].metadata.name`?
7. Status match: registry says active AND `r.source_path` exists (not moved to a retired location)?</action>

<action>For each file under `{project-root}/src/modules/team-maerg/agents/*.agent.yaml`, verify reverse direction using `yaml_to_registry_id`:

8. Source → registry: Is `yaml_to_registry_id[yaml_file]` present (as active or retired) in {{registry_parse}}? A source file with no registry presence is drift.</action>

<action>Count drift findings into {{drift_count}}. Any failed check = one drift finding (record agent id, check type, expected vs observed).</action>

<check if="{{drift_count}} > 0">
  <action>Set audit record fields:
- run_status: "aborted"
- reconciliation: "drift"
- findings_count: {{drift_count}}</action>

<action>Write full audit record to {{audit_filepath}} with YAML frontmatter + body. Frontmatter:

```
---
date: {{date}}
run_status: aborted
reconciliation: drift
findings_count: {{drift_count}}
drift_count: {{drift_count}}
agents_active: {{agents_active}}
---
```

Body sections — identical section topology to the completed case, just with placeholders for steps that didn't run. Shape-stable for cross-audit trend analysis:

- "# Reconciliation" — full {{drift_findings}} table
- "# Agent-Vintage Signals" — "[not run — audit aborted at reconciliation gate]"
- "# Scope Overlap — Jaccard (4a)" — "[not run — audit aborted at reconciliation gate]"
- "# Scope Overlap — LLM Judgment (4b)" — "[not run — audit aborted at reconciliation gate]"
- "# Scope Overlap — Joined View" — "[not run — audit aborted at reconciliation gate]"
- "# Derived Surface Report" — "[not run — audit aborted at reconciliation gate]"
- "# Registry-Quality Gaps" — "[not run — audit aborted at reconciliation gate]"
- "# Orphan Scan" — "[not run — audit aborted at reconciliation gate]"
- "# Summary & Prioritized Actions" — concise drift-only summary with fix instructions
- "# Registry Updates" — "[not run — no updates performed]"</action>

  <action>Report to user in {communication_language}: "Drift detected — audit aborted. {{drift_count}} finding(s) written to {{audit_filepath}}. Fix drift manually (do not silently reconcile) and re-run \*audit-ecosystem."</action>

  <action>HALT workflow. Do not proceed to step 3.</action>
  </check>

<check if="{{drift_count}} == 0">
  <action>Set audit record field reconciliation = "clean". Proceed to step 3.</action>
</check>

</step>

<step n="3" goal="Freshness and git-recency signals">

<action>For each active agent, build an agent-vintage row:

- id
- src_mtime: filesystem mtime of `{project-root}/src/modules/team-maerg/agents/{id}.agent.yaml`
- compiled_md_mtime: filesystem mtime of `{project-root}/bmad/team-maerg/agents/{id}.md`
- claude_cmd_mtime: filesystem mtime of `{project-root}/.claude/commands/bmad/team-maerg/agents/{id}.md`
- stale_compile: true if `src_mtime > compiled_md_mtime` OR `src_mtime > claude_cmd_mtime`
- git_last_touched: ISO timestamp from `git log --follow --format=%aI -1 -- <src yaml path>` via Bash

<note>This step assumes step 2 passed. Step 2's checks 2 and 3 guarantee compiled_md_mtime and claude_cmd_mtime are non-null by the time step 3 runs — a missing compiled file is drift and would have halted the workflow. Belt-and-suspenders handling: if either compiled mtime is null despite step 2 passing, do NOT compute stale_compile; instead record `stale_compile: undefined` and `compile_missing: true` for that agent, and surface the inconsistency in step 8's summary under permission-surface as "post-gate compile state anomaly".</note>

Run git commands one agent at a time to keep the output scoped. If `git log` returns empty (file not committed yet), record git_last_touched as null and flag `uncommitted: true`.</action>

<action>Persist {{agent_vintage_table}} as a markdown table: id | src_mtime | compiled_md_mtime | claude_cmd_mtime | stale_compile | git_last_touched | uncommitted | compile_missing.</action>

</step>

<step n="4" goal="Scope overlap — dual signal, independent passes">

<critical>4a and 4b are independent passes on the same pair axis. 4b must not see 4a's numerical output. Both persist their full result set (no threshold-based trimming) so the reviewer can compare at step 8.</critical>

<note>Scope independence is step-level, not context-level. The executing agent's conversation window has already processed 4a's numerical output by the time 4b runs in the same session. At current scale (N≤20, monthly cadence) and with a tight 4b prompt that refuses numerical framing, this contamination is acceptable — the prompt constraints dominate. Full context-level independence would require spawning a fresh subagent for 4b. Deferred until scale or calibration data justifies the orchestration cost.</note>

<check if="{{agents_active}} <= 1">
  <action>Record in audit: "Scope Overlap — Jaccard (4a): Skipped — N≤1, no pairs to compute." Same for 4b. Proceed to step 5.</action>
</check>

<check if="{{agents_active}} >= 2">
  <action>Construct canonical pair list once. For every unordered pair of active agents (A, B):
- pair_id = "{agent_a_id}::{agent_b_id}" where agent_a_id and agent_b_id are sorted alphabetically (lexicographically smaller first).
- Every pair appears exactly once. pair(Chuck, Doe) and pair(Doe, Chuck) resolve to the same pair_id.

Store as {{pair_list}}.</action>

  <step n="4a" goal="Deterministic Jaccard — prescriptive">
    <critical>Apply this specification exactly. No loose wording, no alternative tokenization.</critical>

    <action>For each pair in {{pair_list}}:

Concatenate for agent A, referencing fields explicitly by source:

```
agent_bundle[a].scope_boundaries       (from registry)
+ " "
+ agent_bundle[a].purpose              (from registry)
+ " "
+ join(agent_bundle[a].principles, " ")  (from YAML persona — principles is a list of strings, joined on whitespace)
```

Same pattern for agent B. The explicit source annotations are part of the spec — do not collapse them; downstream readers must be able to verify the dual-source merge without re-deriving it.

Tokenization (applied to the concatenated string for each agent):

- lowercase
- replace all non-alphanumeric characters with spaces
- split on whitespace
- filter to tokens with length ≥ 4
- collect as a set (deduplicated) → T_A and T_B respectively

Compute J(A, B) = |T_A ∩ T_B| / |T_A ∪ T_B|. If |T_A ∪ T_B| = 0, define J = 0. Round to 3 decimal places.

Record per-pair row: pair_id | jaccard_score | |T_A| | |T_B| | |intersection|.</action>

    <action>Persist {{table_4a}} in the audit record as a markdown table under heading "# Scope Overlap — Jaccard (4a)". Persist all rows, no filtering.</action>

  </step>

  <step n="4b" goal="LLM pairwise judgment — clean input, no anchoring">
    <critical>The pass below must not reference Jaccard, numerical similarity, or any output from 4a. Render only the agents' raw text.</critical>

    <action>For each pair in {{pair_list}} (iterated fresh, not interleaved with 4a):

Render each agent's three fields — `agent_bundle[x].scope_boundaries` (from registry), `agent_bundle[x].purpose` (from registry), and `agent_bundle[x].principles` (from YAML persona, list joined on whitespace) — as a labeled block (Agent A: ..., Agent B: ...). Use the same field sources as 4a; the two passes are joined on pair_id at step 8 and must describe the same agents. Then apply this exact prompt:

```
Given these two agents' scope_boundaries + purpose + principles [rendered below], do they have overlapping scope? Answer: Yes / Partial / No. Provide a one-sentence rationale. No numerical scores.
```

Record per-pair row: pair_id | judgment (Yes|Partial|No) | rationale.</action>

    <action>Persist {{table_4b}} in the audit record as a markdown table under heading "# Scope Overlap — LLM Judgment (4b)". Persist all rows.</action>

  </step>
</check>

</step>

<step n="5" goal="Derived surface report">

<critical>BMAD agents do not have explicit permission declarations. Surface is derived from four sources: menu items, critical_actions, file references in invoked workflows, and workflow outputs. The absence of a permission declaration is not a finding — inferred surface is the finding.</critical>

<action>For each active agent, extract surface signals from {{agent_bundle[id]}}:

Source 1 — menu items:

- Each `<item cmd="...">` with a `workflow` or `exec` or `action` attribute contributes invocations and/or file references.

Source 2 — critical_actions (activation block):

- Every file path loaded during activation (e.g., config.yaml, registry, data files) contributes a read.

Source 3 — invoked workflows (cross-module, always):

- Scan `agent_bundle[id].menu` for every item carrying a `workflow=` attribute. Each such path may reference ANY module, not just team-maerg — e.g., `bmad/bmb/workflows/create-agent/workflow.yaml`, `bmad/bmm/workflows/*`, etc.
- For each invoked workflow path, resolve and read the target `workflow.yaml` at its actual location. If the workflow path is "todo" or the file does not exist, record as a dangling invocation (fed into step 7's dangling-ref scan).
- From each resolved workflow.yaml, collect: `instructions`, `template`, `validation`, `recommended_inputs`, `default_output_file`. Reads and writes derive accordingly.
- Do NOT gate this on {{other_workflows}}. The {{other_workflows}} glob collected at step 1 is team-maerg-local and is used by step 7 for orphan detection, not by step 5 for surface derivation.

Source 4 — workflow outputs:

- `default_output_file` paths from invoked workflows (regardless of module) = writes.</action>

<action>Classify each signal into surface categories:

- reads: file paths the agent (or its workflows) load
- writes: file paths the agent (or its workflows) write/modify
- invokes: workflows/tasks the agent calls
- tools: external tools (Bash, WebFetch, MCP) referenced by the agent or its invoked workflows</action>

<action>Small intent-based sub-action for classification ambiguity: when a menu item's `action=` attribute references a file but the action description does not make read-vs-write clear, reason about the most likely classification from the semantic context of the action description (e.g., "load and render" → read; "append to" → write; "update last_reviewed" → write). Do not default to read when ambiguous — err on the side of the broader privilege.</action>

<action>Persist {{surface_report}} in the audit record under heading "# Derived Surface Report" as a per-agent block with four subsections (reads, writes, invokes, tools). Mark ambiguous classifications with a footnote explaining the reasoning.</action>

</step>

<step n="6" goal="Registry-quality gaps">

<action>For each active agent (iterate {{active_agents}} — retired agents are not flagged; their review state is immaterial by definition):

Gap 1 — eval-alignment: `success_rubric` is null, missing, or empty string → flag.

Gap 2 — time-based staleness: `({{date}} - last_reviewed) > 90 days` → flag. (Explicit subtraction: the review timestamp lies more than 90 calendar days before today.)

Gap 3 — edit-based staleness: `git_last_touched` (from {{agent_vintage_table}}) > `last_reviewed` → flag as "reviewed-before-last-edit". This is a stronger signal than time-based staleness because it indicates the review predates the current implementation regardless of calendar age.</action>

<action>Record gap findings per agent with gap type(s) and supporting timestamps. Persist {{quality_gaps}} in the audit record under heading "# Registry-Quality Gaps". Store the subset of agents flagged with Gap 3 separately as {{edit_stale_agents}} for use in step 9.</action>

</step>

<step n="7" goal="Bidirectional orphan scan">

<action>Orphans — files present but unreferenced:

- Recursively glob `{project-root}/bmad/team-maerg/_data/**/*` with `_data/audits/**/*` excluded at the glob level (audit records are valid outputs of this workflow by design, not orphans).
- For each remaining file, check whether any active agent references it. Sources to check: agent YAMLs, invoked workflow YAMLs, critical_actions, menu items, registry entries.
- Flag files with zero references as orphans.</action>

<action>Dangling references — references that point nowhere:

- From {{surface_report}} (step 5), collect every file path in reads/writes/invokes.
- For each referenced path, verify it exists on the filesystem.
- Flag missing targets as dangling refs with the referring agent.</action>

<action>Special flag — lens framework:

- If {{lens_framework_present}} is false (from step 1), record a top-priority dangling reference: "`bmad/team-maerg/_data/lens-framework.md` is referenced by the Chuck agent (and expected as the source of the 17-lens framework per his identity block) but does not exist on disk."</action>

<action>Persist {{orphan_scan}} in the audit record under heading "# Orphan Scan" with two subsections (Orphans, Dangling References) and the lens-framework special flag if applicable.</action>

</step>

<step n="8" goal="Summary and prioritized action list — intent-based framing">

<check if="{{agents_active}} >= 2">
  <action>Precondition — axis integrity check. Verify that the set of pair_id values in {{table_4a}} exactly equals the set of pair_id values in {{table_4b}}. If the axes diverge (different pairs, or different canonical orderings), record an audit-internal error and halt with message: "Axis drift between 4a and 4b — step 8 join aborted. Investigate pair construction in step 4." Do not produce a summary on drifted axes.</action>

<action>Join tables 4a and 4b on pair_id into {{overlap_joined}}: pair_id | jaccard_score | judgment | rationale. This is the reviewer's artifact — not filtered, sorted by jaccard_score descending for readability.</action>
</check>

<check if="{{agents_active}} <= 1">
  <action>Skip axis integrity check and the join entirely — there are no tables 4a and 4b to reconcile. Record {{overlap_joined}} = "Skipped — N≤1, no pairs to reconcile." The overlap category will be omitted from the summary below; step 10 renders this literal string in the Joined View section so shape stability holds.</action>
</check>

<action>Aggregate findings into prioritized categories. Severity order (strictly): drift > permission > overlap > eval > staleness > orphans.

For each category, guide the reader to the actionable signal:

- Drift: not applicable at this step — reconciliation is clean by precondition (step 2 gate passed).
- Permission surface: call out agents whose derived surface includes writes or tools not expected for their capability tier or scope. Be specific — name the agent, the surface item, why it is surprising.
- Overlap: surface pairs where (jaccard_score ≥ 0.25) OR (judgment ∈ {Yes, Partial}). Flag disagreement between the two signals as its own sub-finding (high Jaccard + No judgment, or low Jaccard + Yes judgment). These disagreements are where signal noise lives and where the reviewer should focus.

<note>The `jaccard_score ≥ 0.25` threshold is a provisional initial value — a guess, not a calibrated constant. Recalibrate from audit history once ≥10 audits with pair data exist: use the Jaccard distribution at which LLM judgment agrees "Yes" or "Partial" to set the threshold by evidence. Until then, treat the value as an instrumentation starting point rather than a load-bearing rule.</note>

- Eval: list agents with null success_rubric. Recommend \*evolve-agent to add one.
- Staleness: list Gap 2 and Gap 3 agents. Gap 3 (edit-based staleness) is strictly more urgent than Gap 2.
- Orphans: list orphan files and dangling refs. Lens-framework absence gets top billing if present.</action>

<action>Compute {{findings_count}} = total count across all categories (not including drift, which is zero here).</action>

<action>Render the summary to the user in {communication_language}. Structure: one-paragraph reconciliation confirmation, then findings by severity. Keep each category to a focused list — actionable items only, no restating raw tables (those live in the audit record). End with "Full audit record written to {{audit_filepath}}."</action>

</step>

<step n="9" goal="Registry update confirmation gate" optional="true">

<critical>Only agents flagged with Gap 3 (git_last_touched > last_reviewed) are candidates for prompting here. Agents that are merely time-stale (Gap 2) but not edit-stale do not get prompts — time alone is a weaker signal than material change, and prompt fatigue degrades the value of the gate.</critical>

<check if="{{edit_stale_agents}} is empty">
  <action>Record in audit under "# Registry Updates": "No edit-stale agents — no prompts issued, no updates performed." Proceed to step 10.</action>
</check>

<check if="{{edit_stale_agents}} is non-empty">
  <action>For each agent in {{edit_stale_agents}}:</action>

<ask>Agent `{{agent.id}}` was last touched at {{agent.git_last_touched}} but last_reviewed is {{agent.last_reviewed}}. Update last_reviewed to {{date}}? [y/n]</ask>

  <check if="response == 'y'">
    <action>Update {ecosystem_registry} via the Edit tool with multi-line context anchoring. A naive `last_reviewed: {{old_date}}` → `last_reviewed: {{date}}` edit fails with non-unique-match whenever two or more agents share the same `last_reviewed` value (common at initial state). Anchor uniqueness on the agent's `id` line.

Deterministic construction algorithm:

1. Read {ecosystem_registry} in full.
2. Locate the line matching exactly `  - id: {{agent.id}}` (two-space indent, one space after dash — the registry's YAML list style).
3. From that line, collect lines sequentially until — but NOT including — the next line matching `^  - id: ` OR end of file.
4. The collected line set is `old_string`.
5. Copy `old_string`. Within the copy, locate the single line `    last_reviewed: {{agent.last_reviewed}}` and replace it with `    last_reviewed: {{date}}`. Do not modify any other line.
6. The modified copy is `new_string`.
7. Call the Edit tool with `old_string` and `new_string`.</action>

   <action>Verify the write: re-read {ecosystem_registry} and confirm the updated `last_reviewed: {{date}}` value is present on the target agent's row and that no other agent's row was modified. If verification passes, record in {{registry_updates}}: "{{agent.id}}: last_reviewed updated from {{agent.last_reviewed}} to {{date}}."</action>

   <action>Graceful failure mode — if the Edit fails with non-unique-match or the verification step finds the update absent or applied to the wrong row: do NOT retry, do NOT halt the audit. Record in {{registry_updates}}: "{{agent.id}}: update failed — block anchor not unique or verification mismatch; manual fix required." Continue to the next agent. Registry writes are optional; the audit completes regardless.</action>
   </check>

  <check if="response == 'n'">
    <action>Record in {{registry_updates}}: "{{agent.id}}: user declined update on {{date}}."</action>
  </check>

<action>After processing all {{edit_stale_agents}}: persist {{registry_updates}} in the audit record under heading "# Registry Updates". Include each decision (updated / declined) with {{date}}.</action>
</check>

</step>

<step n="10" goal="Finalize audit record">

<action>Assemble and write the complete audit record to {{audit_filepath}}. Frontmatter:

```
---
date: {{date}}
run_status: completed
reconciliation: clean
findings_count: {{findings_count}}
drift_count: 0
agents_active: {{agents_active}}
---
```

Body sections in this order:

1. "# Reconciliation" — summary pass (agents checked, all coherent)
2. "# Agent-Vintage Signals" — {{agent_vintage_table}}
3. "# Scope Overlap — Jaccard (4a)" — {{table_4a}} (or skipped note if N≤1)
4. "# Scope Overlap — LLM Judgment (4b)" — {{table_4b}} (or skipped note if N≤1)
5. "# Scope Overlap — Joined View" — {{overlap_joined}} (or skipped note if N≤1)
6. "# Derived Surface Report" — {{surface_report}}
7. "# Registry-Quality Gaps" — {{quality_gaps}}
8. "# Orphan Scan" — {{orphan_scan}}
9. "# Summary & Prioritized Actions" — rendered summary from step 8
10. "# Registry Updates" — {{registry_updates}} (or "no prompts issued" note)</action>

<action>Report to {user_name} in {communication_language}: "Audit complete. {{findings_count}} finding(s). Record at {{audit_filepath}}." Include a one-line next-action pointer to the top-severity finding if any.</action>

</step>

</workflow>
