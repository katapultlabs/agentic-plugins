---
description: Run harness preflight — check MCPs, plugins, CLAUDE.md, and repo structure
allowed-tools: Read, Write, Edit, Bash(ls:*), Bash(mkdir:*), Bash(cat:*), Glob, Grep
---

Run the full environment preflight check described in the harness skill.

Walk through every check in Part 1 (CLAUDE.md, Linear MCP, GitHub MCP,
Engineering plugin, repo structure, .claude/ dirs) and then the repo
scaffolding check in Part 2.

For each check:
1. Report pass or fail with a clear one-line status
2. If something is missing, offer to fix it immediately
3. Wait for confirmation before creating or modifying any files

After all checks complete, print the preflight summary checklist.

If CLAUDE.md is missing, tell the engineer to run `/init` first — it
auto-detects the project's stack and generates a tailored CLAUDE.md.
Once that's done, continue the harness preflight to layer on workflow
rules and scaffolding.

If this is a brand-new repo with nothing set up: "Looks like this repo
needs the full setup. Start by running `/init` to generate your
CLAUDE.md, then run `/harness:setup` again and I'll handle the rest —
MCP configs, docs structure, and workflow rules."

Read the SKILL.md and its reference files for rules to use when
scaffolding.
