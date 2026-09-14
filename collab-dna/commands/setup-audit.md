---
description: Audit the Claude Code setup for this project — model, permission mode, hooks, every CLAUDE.md in scope, plugins, MCP servers, memory — for anything that forces stops or taxes context
allowed-tools: Bash(python3:*), Bash(claude:*), Read, Glob
---

Audit the setup that shapes sessions in the current project, before
auditing the person.

1. The skill directory is `${CLAUDE_PLUGIN_ROOT}/skills/collab-dna/`
   (fall back to locating `collab-dna/skills/collab-dna/` under
   `~/.claude/plugins/` if that variable is unset).
2. Run `python3 <skill-dir>/scripts/inspect_setup.py --out <temp file>`.
   It writes the inventory to that file and prints its path; read the
   file. It is a read-only inventory with
   secrets masked: Claude Code version, global settings (model, effort,
   permission mode and rules, hooks, enabled plugins), MCP servers,
   every instruction file in scope (global, ancestor, project, local,
   rules) in full, project settings, project skills and commands,
   installed plugins with their skill counts, the project's memory,
   and the model that answered each recent session.
3. Read `<skill-dir>/references/setup-rubric.md` and walk its six
   surfaces against the inventory.
4. Verify the two or three findings you intend to rank highest
   against the repo itself before writing them: the docs the project
   CLAUDE.md links to, `git log` for anything the instruction files
   claim about state, the plugin's own files for a description you
   are calling overlapping. The inventory is a map; the strongest
   findings usually need one look at the territory.
5. Produce the report in the rubric's shape. Every finding cites the
   inventory line, names the effect on the loop, and gives the exact
   edit: the setting value, the line to delete, the text to add, or
   the command to run. "Do this first" is three edits in order of
   turns saved.

If a session audit of this project exists (the human may paste one),
use its repeated corrections and absent moves as the test cases, as
the rubric's "durable home" test describes.

Do not change any setting or file. The report is the deliverable;
the human applies it.
