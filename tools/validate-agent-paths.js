/**
 * validate-agent-paths.js
 *
 * Walks every .md file under bmad/<module>/agents/ and verifies that every
 * `{project-root}/...` reference (ending in .md/.yaml/.yml/.json) resolves to
 * an existing file on disk.
 *
 * This is a regression guard for activation-path drift, e.g. agents pointing
 * at `{project-root}/src/modules/<x>/agents/...` when files actually live at
 * `{project-root}/bmad/<x>/agents/...`. That class of bug is invisible to
 * schema validation and to web-bundle XML linting.
 *
 * Usage:
 *   node tools/validate-agent-paths.js
 *
 * Exits non-zero on violations.
 *
 * Stdlib only (no chalk, no glob).
 */

'use strict';

const fs = require('node:fs');
const path = require('node:path');

const REPO_ROOT = path.resolve(__dirname, '..');
const AGENTS_GLOB_ROOT = path.join(REPO_ROOT, 'bmad');

// Match {project-root}/<path>.<ext> where ext is md|yaml|yml|json.
// Stops at whitespace, quotes, backticks, or angle brackets.
const REF_REGEX = /\{project-root\}\/([^\s"'`<>]+?\.(?:md|yaml|yml|json))/g;

/**
 * Recursively collect every .md file beneath `dir` whose path contains an
 * `/agents/` segment. Skips node_modules and .git defensively.
 */
function collectAgentMarkdown(dir, out = []) {
  let entries;
  try {
    entries = fs.readdirSync(dir, { withFileTypes: true });
  } catch {
    return out;
  }
  for (const entry of entries) {
    if (entry.name === 'node_modules' || entry.name === '.git') continue;
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      collectAgentMarkdown(full, out);
    } else if (entry.isFile() && entry.name.endsWith('.md')) {
      const rel = path.relative(REPO_ROOT, full);
      // Only consider files whose path traverses an `agents` directory.
      if (rel.split(path.sep).includes('agents')) {
        out.push(full);
      }
    }
  }
  return out;
}

/**
 * Extract every `{project-root}/<file>` reference from `content`, with
 * 1-based line numbers. Returns array of { ref, lineNo, resolved }.
 */
function extractRefs(content) {
  const refs = [];
  const lines = content.split('\n');
  for (const [i, line] of lines.entries()) {
    REF_REGEX.lastIndex = 0;
    let m;
    while ((m = REF_REGEX.exec(line)) !== null) {
      const relPath = m[1];
      refs.push({
        ref: `{project-root}/${relPath}`,
        lineNo: i + 1,
        resolved: path.join(REPO_ROOT, relPath),
      });
    }
  }
  return refs;
}

function main() {
  const files = collectAgentMarkdown(AGENTS_GLOB_ROOT);
  files.sort();

  const violations = [];
  let totalRefs = 0;

  for (const file of files) {
    const content = fs.readFileSync(file, 'utf8');
    const refs = extractRefs(content);
    totalRefs += refs.length;
    for (const r of refs) {
      if (!fs.existsSync(r.resolved)) {
        violations.push({
          file: path.relative(REPO_ROOT, file),
          line: r.lineNo,
          ref: r.ref,
          resolved: r.resolved,
        });
      }
    }
  }

  console.log('Agent activation-path validator');
  console.log('================================');
  console.log(`Repo root:        ${REPO_ROOT}`);
  console.log(`Agents scanned:   ${files.length}`);
  console.log(`References checked: ${totalRefs}`);
  console.log(`Violations:       ${violations.length}`);
  console.log('');

  if (violations.length === 0) {
    console.log('OK — every {project-root} file reference resolves.');
    process.exit(0);
  }

  console.log('Violations:');
  for (const v of violations) {
    console.log(`  ${v.file}:${v.line} -> missing ${v.resolved}`);
    console.log(`    (ref: ${v.ref})`);
  }
  process.exit(1);
}

// Export internals for testing / mutation harnesses.
module.exports = { extractRefs, collectAgentMarkdown, REF_REGEX, REPO_ROOT };

if (require.main === module) {
  main();
}
