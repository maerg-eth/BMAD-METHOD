# Scott's Engineering Log - CLI Chief Memories

## Mission Parameters

- **Primary Domain:** BMAD CLI tooling (`{project-root}/tools/cli/`)
- **Specialization:** Installers, bundlers, IDE configurations
- **Personality:** Star Trek Chief Engineer (systematic, urgent, capable)

## Known Issues Database

### Installation Issues

<!-- Scott will populate this as issues are discovered and resolved -->

### Bundler Issues

<!-- Compilation and bundle validation problems -->

### IDE Configuration Issues

<!-- IDE integration problems and solutions -->

### Module Installer Issues

#### bmd silently skipped by Compile Agents (until Defect #1 is patched)

- `rebuildAgentFiles` at `tools/cli/installers/lib/core/installer.js:1135` hardcodes the source path to `src/modules/{moduleName}/agents/`. bmd lives at top-level `bmd/agents/` post-2025-10-19 reorg (commit 0a048f2), so the path miss triggers a no-op return.
- Symptom: Compile Agents reports success for every OTHER module but bmd's installed `.md` files stay frozen, with no warning.
- Mitigation shipped in `dc013fbc` (2026-04-23): the silent return now emits a yellow warning naming the module and missing path. Future operator gets a loud signal.
- Permanent fix is owned by `bmd/bmad-custom-module-installer-plan.md` (Phase 1).

#### buildAgent() emits wrong config refs for non-standard module paths

- `tools/cli/lib/yaml-xml-builder.js` lines 388–393 has a hardcoded allowlist `['bmm','bmb','cis','core']` on the `/bmad/{module}/` path-extraction branch.
- bmd's source path matches neither `/src/modules/` nor `/bmad/{allowlisted}/`, so `module` defaults to `'core'`. Step 2 of the rendered agent references `bmad/core/config.yaml` instead of `bmad/bmd/config.yaml`.
- Until Defect #3 is fixed by the installer plan: do NOT run `buildAgent()` directly on bmd sources. The output will be wrong.

## Successful Patterns

### Installer Best Practices

<!-- Patterns that work well for module installation -->

### Configuration Strategies

<!-- Effective ways to handle config merging and overrides -->

### Debugging Techniques

#### Dry-run live code before recommending an invocation

- Read source before inferring intent — but read isn't run. Four parallel adversarial subagents + my own static read of yaml-xml-builder.js failed to catch Defect #3. One dry-run of `buildAgent()` against the real bmd source surfaced it immediately.
- Rule: if a recommendation tells the operator to invoke a builder, installer, compile path, or CLI command, run that invocation once on representative input before the recommendation goes out.
- See feedback memory `feedback_dry_run_live_code.md` (sibling to Chuck's `feedback_static_verification_is_not_runtime_test.md` — same orthogonal axis, build/code domain instead of persona/spec).

#### Adversarial subagent fan-out is necessary but not sufficient

- 4 parallel subagents each tasked with falsifying a specific claim is a strong static check. It caught compile-surface gaps, the activation-path bug, and installer-plan status correctly.
- But all four were reading the same code paths I was. They converged on the same blind spot. The dry-run was the orthogonal axis.
- One subagent in the bmd session also pattern-matched "code exists" into "feature exists for this use case" without testing the case (claimed `compileAgents` was an interim mechanism — when in fact it was the very path that silently skipped bmd). Verify subagent conclusions against the actual question being asked, not just the surface evidence they cite.

## Session History

### 2026-04-23 → 2026-04-29: bmd compile-drift multi-defect diagnostic

- **Symptom**: 3 bmd agents (cli-chief/me, doc-keeper, release-chief) silently broken at activation. Step 4 referenced `{project-root}/src/modules/bmd/agents/{name}-sidecar/...` — a path that hadn't existed since the 2025-10-19 reorg moved bmd to top-level `bmd/` (commit 0a048f2). I hit this myself at session start when my own activation tried to load the missing sidecar.
- **3 defects identified** (only the user-facing one fully fixed today; the 2 upstream defects deferred to the custom-module installer plan):
  1. `rebuildAgentFiles` silent no-op for top-level modules — partial mitigation shipped (`dc013fbc` adds warning).
  2. Stale sidecar path refs in 3 sources + 6 mirrors — patched in `fd06bc2c` (9 files, 18 line changes).
  3. `yaml-xml-builder` module allowlist fallback to `'core'` — defers to installer plan Phase 1.
- **Validator landed** (`e4277bb9`): `tools/validate-agent-paths.js` walks every bmad agent `.md` and asserts `{project-root}/...` references resolve. Catches this bug class going forward. CI integration pending (`Phase 2`, bmb territory).
- **Diagnostic technique that mattered**: dry-run of `buildAgent()` against a real bmd source _after_ 4 adversarial subagents had already cleared the recommendation. Caught Defect #3 that would have shipped wrong config refs. See `feedback_dry_run_live_code.md`.
- **Format migration deferred**: the 3 bmd agents stay in old `<!-- Powered by BMAD-CORE™ -->` format until Defect #3 is fixed; running `buildAgent()` on them now would regress step-2 config refs to `bmad/core/config.yaml`. Format closes for free once the allowlist is fixed.
- **Cross-domain**: Chuck's parallel session (`fd6745a6`) shipped routing-awareness changes that reference the same agent-manifest.csv freshness assumption. CI-gating for manifest regen + audit-ecosystem cadence is on the Phase 2 backlog.

## Personal Notes

<!-- Scott's observations about the CLI architecture, potential improvements, etc. -->
