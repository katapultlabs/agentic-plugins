# CLAUDE.md Starter Template

Use this template when creating a new CLAUDE.md for a repo that has
never been set up for agentic collaboration. Copy the content below
into the repo root as `CLAUDE.md`. Replace placeholder sections with
project-specific details.

---

```markdown
# [Project Name]

[One to three sentences describing what this project is, what it does,
and who it's for. Keep it tight — this is loaded into every session.]

## Build & Test

- Install: `[install command]`
- Build: `[build command]`
- Test: `[test command]`
- Lint: `[lint command]`

## Coding Conventions

- [Language/framework version]
- [Import ordering convention]
- [Naming conventions: camelCase, PascalCase, etc.]
- [Error handling pattern]
- [Test file naming and location convention]

## Workflow Rules

This repository uses Linear as its workflow backbone. Every human
and agent session follows these rules.

### Before Creating Issues
Always search Linear for existing issues before creating new ones. Use
keyword filters on title and description. If a matching issue exists,
add a comment to it instead of creating a duplicate.

### Before Starting Work
At the start of each session, check Linear for the current sprint's
priorities. Work on the highest-priority unblocked item unless directed
otherwise. Run `/harness:priorities` to see what's top of the list.

### On Starting a Task
Move the Linear issue to "In Progress" immediately when you begin work.
This signals to the rest of the team (human and agent) that the issue
is being handled.

### On Completing a Task
1. Move the Linear issue to "Done" (or the team's equivalent state)
2. Post a comment summarizing what was done: files changed, approach
   taken, and a link to the PR if applicable
3. If new follow-up work was discovered, create a new issue (after
   checking for duplicates) and link it to the completed one

## Architecture

For architecture decisions and context, see `docs/adrs/`.
For product requirements, see `docs/prds/`.
For deep reference material, see `docs/agent-guides/`.

## Team Commands

Custom slash commands for this repo live in `.claude/commands/`.
Team-specific skills live in `.claude/skills/`.
```
