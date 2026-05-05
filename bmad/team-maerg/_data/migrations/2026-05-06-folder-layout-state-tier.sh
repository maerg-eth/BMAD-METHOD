#!/usr/bin/env bash
# Folder-layout migration — state-tier hoist (Option E smallest variant)
# Authored: 2026-05-06 by Chuck (team-maerg)
# ADR: bmad/team-maerg/_data/decisions/2026-05-05-folder-layout-scalability.md
#
# Purpose: hoist 5 human-edited state files from agents/<x>-sidecar/ into
# a state/<state-type>/ tier per Letta / Claude Code convention.
# Semantic-clarity move; does NOT reduce absolute path depth (see ADR Outcome).
#
# Files moved (5):
#   lyra-sidecar/preferences.yaml          → state/preferences/lyra.yaml
#   lyra-sidecar/memories.md               → state/memories/lyra.md
#   lyra-sidecar/memories-autonomous-log.md → state/memories/lyra-autonomous-log.md
#   atlas-sidecar/memories.md              → state/memories/atlas.md
#   atlas-sidecar/memories-autonomous-log.md → state/memories/atlas-autonomous-log.md
#
# Files updated (8 — path references):
#   bmad/team-maerg/agents/atlas.md
#   bmad/team-maerg/agents/lyra.md
#   bmad/team-maerg/agents/atlas-sidecar/instructions.md
#   bmad/team-maerg/agents/lyra-sidecar/instructions.md
#   .claude/commands/bmad/team-maerg/agents/atlas.md
#   .claude/commands/bmad/team-maerg/agents/lyra.md
#   src/modules/team-maerg/agents/atlas.agent.yaml
#   src/modules/team-maerg/agents/lyra.agent.yaml
#
# Files explicitly NOT touched (audit-trail preservation):
#   bmad/team-maerg/_data/decisions/*.md   (historical record)
#   bmad/team-maerg/_data/handoffs/*.md    (historical record)
#
# Usage:
#   ./2026-05-06-folder-layout-state-tier.sh --dry-run    # preview, no changes
#   ./2026-05-06-folder-layout-state-tier.sh --execute    # apply changes
#   ./2026-05-06-folder-layout-state-tier.sh --verify     # post-execute checks only

set -euo pipefail

REPO_ROOT="/Users/maerg/Projects/Agentic/BMAD-METHOD"
MODE="${1:-}"

case "$MODE" in
  --dry-run|--execute|--verify) ;;
  *)
    echo "Usage: $0 [--dry-run|--execute|--verify]"
    exit 1
    ;;
esac

DRY_RUN=true
VERIFY_ONLY=false

case "$MODE" in
  --dry-run) DRY_RUN=true ;;
  --execute) DRY_RUN=false ;;
  --verify)  DRY_RUN=true; VERIFY_ONLY=true ;;
esac

cd "$REPO_ROOT"

SIDECAR_LYRA="bmad/team-maerg/agents/lyra-sidecar"
SIDECAR_ATLAS="bmad/team-maerg/agents/atlas-sidecar"
STATE_PREFS="bmad/team-maerg/state/preferences"
STATE_MEMS="bmad/team-maerg/state/memories"

declare -a MOVES=(
  "$SIDECAR_LYRA/preferences.yaml:$STATE_PREFS/lyra.yaml"
  "$SIDECAR_LYRA/memories.md:$STATE_MEMS/lyra.md"
  "$SIDECAR_LYRA/memories-autonomous-log.md:$STATE_MEMS/lyra-autonomous-log.md"
  "$SIDECAR_ATLAS/memories.md:$STATE_MEMS/atlas.md"
  "$SIDECAR_ATLAS/memories-autonomous-log.md:$STATE_MEMS/atlas-autonomous-log.md"
)

declare -a UPDATE_FILES=(
  "bmad/team-maerg/agents/atlas.md"
  "bmad/team-maerg/agents/lyra.md"
  "bmad/team-maerg/agents/atlas-sidecar/instructions.md"
  "bmad/team-maerg/agents/lyra-sidecar/instructions.md"
  ".claude/commands/bmad/team-maerg/agents/atlas.md"
  ".claude/commands/bmad/team-maerg/agents/lyra.md"
  "src/modules/team-maerg/agents/atlas.agent.yaml"
  "src/modules/team-maerg/agents/lyra.agent.yaml"
)

# Substitution order matters: long-form paths first, then short-form.
# Long-form contains short-form as substring; replacing short-form first
# would corrupt long-form (state/preferences/lyra.yaml inside bmad/team-maerg/agents/)
declare -a SUBS=(
  # === long-form (contain bmad/team-maerg/agents/ prefix) ===
  "bmad/team-maerg/agents/lyra-sidecar/preferences.yaml|bmad/team-maerg/state/preferences/lyra.yaml"
  "bmad/team-maerg/agents/lyra-sidecar/memories-autonomous-log.md|bmad/team-maerg/state/memories/lyra-autonomous-log.md"
  "bmad/team-maerg/agents/lyra-sidecar/memories.md|bmad/team-maerg/state/memories/lyra.md"
  "bmad/team-maerg/agents/atlas-sidecar/memories-autonomous-log.md|bmad/team-maerg/state/memories/atlas-autonomous-log.md"
  "bmad/team-maerg/agents/atlas-sidecar/memories.md|bmad/team-maerg/state/memories/atlas.md"
  # === short-form (sidecar-relative) ===
  "lyra-sidecar/preferences.yaml|state/preferences/lyra.yaml"
  "lyra-sidecar/memories-autonomous-log.md|state/memories/lyra-autonomous-log.md"
  "lyra-sidecar/memories.md|state/memories/lyra.md"
  "atlas-sidecar/memories-autonomous-log.md|state/memories/atlas-autonomous-log.md"
  "atlas-sidecar/memories.md|state/memories/atlas.md"
)

log() { echo "[migration] $*"; }
err() { echo "[migration ERROR] $*" >&2; }

preflight() {
  log "=== PRE-FLIGHT ==="

  if [[ "$PWD" != "$REPO_ROOT" ]]; then
    err "cwd is not $REPO_ROOT — abort"; exit 1
  fi
  log "✓ cwd correct"

  if ! git diff --quiet || ! git diff --cached --quiet; then
    if $DRY_RUN; then
      log "⚠ git tree dirty (warning, dry-run continuing). Must be clean before --execute:"
      git status --short | sed 's/^/    /'
    else
      err "git working tree not clean — commit or stash first"
      git status --short
      exit 1
    fi
  else
    log "✓ git working tree clean"
  fi

  # Detect MULTIPLE active sessions (>1 .jsonl written in last 30s).
  # The script itself runs from inside a session, so 1 recent write is normal.
  local PROJECT_DIR="$HOME/.claude/projects/-Users-maerg-Projects-Agentic-BMAD-METHOD"
  if [[ -d "$PROJECT_DIR" ]]; then
    local NOW
    NOW=$(date +%s)
    local recent_count=0
    for f in "$PROJECT_DIR"/*.jsonl; do
      [[ -f "$f" ]] || continue
      local mtime
      mtime=$(stat -f "%m" "$f" 2>/dev/null || echo 0)
      if [[ -n "$mtime" && "$mtime" != "0" ]]; then
        local diff=$((NOW - mtime))
        if [[ $diff -lt 30 ]]; then
          recent_count=$((recent_count + 1))
        fi
      fi
    done
    if [[ "$recent_count" -gt 1 ]]; then
      if $DRY_RUN; then
        log "⚠ $recent_count active sessions detected — close all but this one before --execute"
      else
        err "$recent_count active sessions detected (>1 .jsonl written in last 30s) — close all but this one"
        exit 1
      fi
    else
      log "✓ only this session active ($recent_count recent .jsonl writes)"
    fi
  fi

  for move in "${MOVES[@]}"; do
    local src="${move%%:*}"
    [[ -f "$src" ]] || { err "missing source file: $src"; exit 1; }
  done
  log "✓ all 5 state files present at expected source paths"

  if [[ -d "$STATE_PREFS" && -n "$(ls -A "$STATE_PREFS" 2>/dev/null)" ]]; then
    err "$STATE_PREFS already exists and non-empty"; exit 1
  fi
  if [[ -d "$STATE_MEMS" && -n "$(ls -A "$STATE_MEMS" 2>/dev/null)" ]]; then
    err "$STATE_MEMS already exists and non-empty"; exit 1
  fi
  log "✓ target dirs absent or empty"

  log "=== PRE-FLIGHT PASS ==="
}

create_dirs() {
  log ""
  log "=== PHASE 1: CREATE TIER DIRS ==="
  for dir in "$STATE_PREFS" "$STATE_MEMS"; do
    if $DRY_RUN; then
      log "[DRY] mkdir -p $dir"
    else
      mkdir -p "$dir"
      log "created $dir"
    fi
  done
}

move_files() {
  log ""
  log "=== PHASE 2: MOVE 5 STATE FILES ==="
  for move in "${MOVES[@]}"; do
    local src="${move%%:*}"
    local dst="${move##*:}"
    if $DRY_RUN; then
      log "[DRY] git mv $src $dst"
    else
      git mv "$src" "$dst"
      log "moved $src → $dst"
    fi
  done
}

update_refs() {
  log ""
  log "=== PHASE 3: UPDATE PATH REFERENCES IN 8 FILES ==="
  local total=0
  for file in "${UPDATE_FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
      log "(skip $file — not present)"
      continue
    fi
    log "→ $file"
    local file_count=0
    for sub in "${SUBS[@]}"; do
      local from="${sub%%|*}"
      local to="${sub##*|}"
      local count
      count=$(grep -c -F "$from" "$file" 2>/dev/null || true)
      count=$(echo "$count" | tr -d '[:space:]')
      count=${count:-0}
      if [[ "$count" -gt 0 ]]; then
        if $DRY_RUN; then
          log "    [DRY] ${count}× '$from' → '$to'"
        else
          # macOS BSD sed; -F-equivalent literal substitution via | delimiter
          sed -i '' "s|$from|$to|g" "$file"
          log "    replaced ${count}× '$from'"
        fi
        file_count=$((file_count + count))
      fi
    done
    log "    [file total: ${file_count} substitutions]"
    total=$((total + file_count))
  done
  log "=== TOTAL: ${total} substitutions across ${#UPDATE_FILES[@]} files ==="
}

verify() {
  log ""
  log "=== PHASE 4: POST-MIGRATION VERIFICATION ==="

  if $DRY_RUN && ! $VERIFY_ONLY; then
    log "(dry-run mode — skipping verification; rerun with --verify after --execute)"
    return 0
  fi

  local fails=0

  log ""
  log "Check 1: state files at new locations"
  local expected=(
    "$STATE_PREFS/lyra.yaml"
    "$STATE_MEMS/lyra.md"
    "$STATE_MEMS/lyra-autonomous-log.md"
    "$STATE_MEMS/atlas.md"
    "$STATE_MEMS/atlas-autonomous-log.md"
  )
  for f in "${expected[@]}"; do
    if [[ -f "$f" ]]; then
      log "  ✓ $f"
    else
      err "  ✗ MISSING: $f"
      fails=$((fails + 1))
    fi
  done

  log ""
  log "Check 2: source dirs no longer have state files"
  local should_be_gone=(
    "$SIDECAR_LYRA/preferences.yaml"
    "$SIDECAR_LYRA/memories.md"
    "$SIDECAR_LYRA/memories-autonomous-log.md"
    "$SIDECAR_ATLAS/memories.md"
    "$SIDECAR_ATLAS/memories-autonomous-log.md"
  )
  for f in "${should_be_gone[@]}"; do
    if [[ ! -f "$f" ]]; then
      log "  ✓ $f removed"
    else
      err "  ✗ STILL PRESENT: $f"
      fails=$((fails + 1))
    fi
  done

  log ""
  log "Check 3: no remaining old-path refs in updated files"
  local old_patterns=(
    "lyra-sidecar/preferences.yaml"
    "lyra-sidecar/memories.md"
    "lyra-sidecar/memories-autonomous-log.md"
    "atlas-sidecar/memories.md"
    "atlas-sidecar/memories-autonomous-log.md"
  )
  for pattern in "${old_patterns[@]}"; do
    local hits=0
    for file in "${UPDATE_FILES[@]}"; do
      [[ -f "$file" ]] || continue
      local n
      n=$(grep -c -F "$pattern" "$file" 2>/dev/null || true)
      n=$(echo "$n" | tr -d '[:space:]')
      n=${n:-0}
      hits=$((hits + n))
    done
    if [[ "$hits" -gt 0 ]]; then
      err "  ✗ STILL FOUND ${hits}× '$pattern' in updated files"
      fails=$((fails + 1))
    else
      log "  ✓ no remaining '$pattern' refs"
    fi
  done

  log ""
  log "Check 4: historical refs preserved (expected non-zero)"
  local decisions_refs handoffs_refs
  decisions_refs=$(grep -rE "(lyra-sidecar|atlas-sidecar)/(preferences|memories)" bmad/team-maerg/_data/decisions/ 2>/dev/null | wc -l | tr -d ' ' || echo 0)
  handoffs_refs=$(grep -rE "(lyra-sidecar|atlas-sidecar)/(preferences|memories)" bmad/team-maerg/_data/handoffs/ 2>/dev/null | wc -l | tr -d ' ' || echo 0)
  log "  decisions/: ${decisions_refs} historical refs preserved (expected ≥6)"
  log "  handoffs/: ${handoffs_refs} refs (informational)"

  log ""
  if [[ "$fails" -eq 0 ]]; then
    log "=== VERIFICATION PASS — ${fails} failures ==="
  else
    err "=== VERIFICATION FAIL — ${fails} failures ==="
    return 1
  fi
}

print_test_plan() {
  cat <<'EOF'

=== MANUAL TEST PLAN (run after --execute, before commit) ===

In a FRESH Claude Code session against this repo, run each of these:

1. Atlas activation:
   /bmad:team-maerg:agents:atlas
   - confirm activates without file-not-found errors
   - run *roster — confirms registry + memory load worked

2. Lyra activation:
   /bmad:team-maerg:agents:lyra
   - confirm activates
   - run *preferences — confirms preferences.yaml load worked

3. Chuck activation (sanity check, no state-file dep):
   /bmad:team-maerg:agents:chuck
   - confirm activates
   - run *registry — confirms ecosystem-registry load works

4. Source-vs-built check:
   - Inspect whether bmad:install would revert these changes
   - If yes: run install + verify changes survive (or commit source files first)

If any test fails:
   git restore .                       # undo unstaged changes
   git reset --hard HEAD                # nuclear (only if clean pre-migration)
   git restore --staged --worktree .   # alternative

If all tests pass, commit:
   git add -A
   git commit -m "migrate: state-tier hoist per ADR 2026-05-05-folder-layout-scalability"

EOF
}

main() {
  log "Folder-layout state-tier migration"
  log "Mode: $MODE"
  log "Repo: $REPO_ROOT"
  log ""

  if $VERIFY_ONLY; then
    verify
    exit $?
  fi

  preflight
  create_dirs
  move_files
  update_refs
  verify
  print_test_plan

  log ""
  if $DRY_RUN; then
    log "=== DRY-RUN COMPLETE — no changes made ==="
    log "To execute: $0 --execute"
  else
    log "=== EXECUTION COMPLETE ==="
    log "Run the manual tests above before committing."
  fi
}

main
