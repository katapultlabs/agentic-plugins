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

If this is a brand-new repo with nothing set up, suggest running through
everything end to end: "Looks like this repo needs the full setup. I'll
walk you through each piece — CLAUDE.md, MCP configs, docs structure,
and workflow rules. Want me to go ahead?"

Read the SKILL.md and its reference files for templates and rules to use
when scaffolding.
