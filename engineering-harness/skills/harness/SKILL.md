---
name: harness
description: >
  This skill should be used when someone asks to "set up my environment",
  "configure my repo", "check my setup", "onboard to the repo", "what should I
  work on", "check for duplicates", "is this already filed", "what are the
  priorities", "start a task", "update my issue", "close my issue",
  "scaffold the repo", "set up docs structure", "initialize the project",
  or any request related to ensuring the repo is structured for human+agent
  collaboration with Linear as the workflow backbone. Also triggers on
  "harness setup", "environment check", "preflight", "plugin check",
  "CLAUDE.md check", "repo structure", "agentic setup", or when starting
  any new session where project context should be loaded first.
  Use this skill liberally — if someone is asking about onboarding,
  project setup, or workflow hygiene, this is the skill to use.
version: 0.1.0
---

# Harness

Setup, scaffolding, and workflow enforcement for repositories where Linear
is the single source of truth and humans and agents collaborate as peers.

This skill does three things:

1. **Environment preflight** — verifies MCPs, plugins, CLAUDE.md, and
   repo structure are properly configured
2. **Repo scaffolding** — ensures the directory structure supports agentic
   collaboration (docs, PRDs, ADRs, RFCs, guides, agent-guides)
3. **Workflow enforcement** — duplicate checking, priority surfacing,
   status updates, and audit-trail comments via Linear

---

## Part 1: Environment Preflight

When a collaborator runs `/harness:setup` or asks to check their environment,
walk through each check below and report a pass/fail checklist.

### 1.1 — CLAUDE.md Exists

Check for `CLAUDE.md` at the repo root. This is the first and most
important check because everything else depends on it.

**If missing entirely:** tell the collaborator to run `/init` first. Claude
Code's built-in `/init` command does self-discovery of the project —
detecting languages, frameworks, build commands, test runners, and
conventions — and generates a CLAUDE.md tailored to the actual repo.
This is always better than a static template. Once `/init` completes,
come back and continue the harness preflight to layer on the workflow
rules.

> Run `/init` to generate your CLAUDE.md. It will auto-detect your
> project's stack, build commands, and conventions. Once that's done,
> run `/harness:setup` again and I'll add the workflow rules on top.

**If it exists but is very short** (<10 lines): it may be a stub. Ask
the collaborator whether they want to re-run `/init` to enrich it (it
will preserve existing content), or whether they'd prefer to keep it
as-is. Either way, check for and offer to append the workflow rules.

**If it exists and has content:** check for:

1. **Size** — is it under 100 lines? If over 150, suggest restructuring
   as a router (see "The Router Pattern" below). A bloated CLAUDE.md
   wastes context every session and dilutes the important rules.
2. **Automatic Behaviors** — does it have a "How Claude Code Should Work"
   or equivalent section with "when X, do Y" rules? If missing, offer
   to append the template from `references/claude-md-rules.md` (Block 1).
3. **Self-healing** — does it have a "When something breaks" section?
   Claude Code should know how to diagnose and fix common issues without
   the user asking. If missing, suggest adding it.
4. **Deep Reference pointers** — does it have a table pointing to docs/
   files? CLAUDE.md should be a router, not an encyclopedia.
5. **Workflow rules** — are the four Linear workflow rules present
   (see Part 3)? If missing, offer to append from
   `references/claude-md-rules.md` (Block 2).

### 1.2 — Linear MCP

Check whether `.mcp.json` exists at the repo root with a `linear` server
entry pointing to `https://mcp.linear.app/mcp`.

- **If `.mcp.json` is missing:** offer to create it with the Linear
  entry from this plugin's `.mcp.json`.
- **If `.mcp.json` exists but has no `linear` entry:** offer to add it.
- **If the entry exists:** test connectivity by calling the Linear MCP's
  `list_issues` tool with a limit of 1. If the call fails with an auth
  error, walk the collaborator through the OAuth flow: run `/mcp` in Claude
  Code to authenticate interactively.

### 1.3 — GitHub CLI (`gh`)

Check that the `gh` CLI is installed and authenticated. Run
`gh auth status` to verify. The `gh` CLI is far more context-efficient
than a GitHub MCP and is the standard way Claude Code interacts with
GitHub (PRs, issues, repos, Actions, etc.).

- **If `gh` is not installed:** tell the collaborator to install it
  (`brew install gh` on macOS, or see https://cli.github.com/).
- **If `gh` is installed but not authenticated:** walk them through
  `gh auth login` — they can authenticate interactively by running
  `! gh auth login` in the Claude Code prompt.
- **If `gh` is authenticated:** report the logged-in user and active
  account.

If the team uses GitLab instead, check for the `glab` CLI or an
appropriate GitLab MCP entry in `.mcp.json`.

### 1.4 — Engineering Plugin (optional)

Check whether the Engineering plugin is available by looking
for engineering-related skills (standup, code-review, architecture, etc.)
in the current session's available skills.

If not found:

> The Engineering plugin adds standup summaries, code review, incident
> response, and more — all wired to Linear. Install it from the plugin
> marketplace: search "engineering" under knowledge-work-plugins.

This is optional — the harness works without it.

### 1.5 — Repo Structure

Check for the presence of the target directory structure described in
Part 2. Report which directories and templates exist and which are
missing. Offer to scaffold only what's missing.

### 1.6 — .claude/ Directory

Check for `.claude/commands/` and `.claude/skills/` directories. These
are where teams put their repo-specific slash commands and skills. If
missing, create them with a brief README in each explaining their purpose.

### 1.7 — Preflight Summary

Print a clear checklist summarizing all results:

```
Harness — Preflight
─────────────────────────────────────────────
✓ CLAUDE.md ............. exists, 4/4 workflow rules present
✓ Linear MCP ............ connected, authenticated
✓ GitHub CLI (gh) ....... authenticated as @username
✓ Engineering plugin .... installed
✓ Repo structure ........ docs/ scaffold present
✓ .claude/ dirs ......... commands/ and skills/ present
```

Mark ✗ with a one-line remediation for anything that failed.

---

## Part 2: Repo Scaffolding

A well-structured repo is what makes agentic collaboration work. Agents
need the same context that humans need — they just consume it from files
instead of hallway conversations.

When running `/harness:setup` or when asked to scaffold the repo, check
for and offer to create any missing pieces of this structure.

### Target Structure

```
repo-root/
├── CLAUDE.md                    # Agent + human onboarding (Tier 1)
├── .mcp.json                    # MCP server configs (Linear)
├── .claude/
│   ├── commands/                # Team slash commands
│   │   └── README.md            # Explains how to add commands
│   └── skills/                  # Team-specific skills
│       └── README.md            # Explains how to add skills
├── docs/
│   ├── prds/                    # Product requirement documents
│   │   └── TEMPLATE.md          # PRD template with agent-friendly
│   │                            #   acceptance criteria
│   ├── adrs/                    # Architecture decision records
│   │   └── TEMPLATE.md          # ADR template: status, context,
│   │                            #   decision, consequences
│   ├── rfcs/                    # Request for comments / design docs
│   │   └── TEMPLATE.md          # RFC template with reviewers section
│   ├── guides/                  # Runbooks, onboarding, how-tos
│   │   └── onboarding.md        # New collaborator/agent onboarding
│   └── agent-guides/            # Tier 3 deep reference for agents
│       └── README.md            # Index of available agent guides
└── src/                         # (existing source code — untouched)
```

### Scaffolding Rules

- **Never overwrite existing files.** Only create directories and files
  that don't already exist.
- **Templates are opinionated but not heavy.** Each TEMPLATE.md is 30-50
  lines — enough structure to be genuinely useful without feeling like
  bureaucracy. Read the templates in `references/templates/`.
- **docs/agent-guides/ is Tier 3 context.** This is where deep reference
  material lives (architecture docs, API contracts, deployment runbooks)
  that agents load on demand. CLAUDE.md should point here with explicit
  instructions like: "For deployment procedures, read
  `docs/agent-guides/deploy.md`."
- **PRDs bridge humans and agents.** The template includes a "Success
  Criteria" section that doubles as acceptance criteria for agent-driven
  work, and a "Non-Goals" section that prevents scope creep for both.
- **ADRs keep decisions durable.** When a human or agent makes an
  architectural decision, it gets recorded so future sessions don't
  re-derive or contradict it.
- **RFCs are for proposals that need review.** The template includes a
  reviewers section and a status field (Draft, In Review, Accepted,
  Superseded) so agents know whether an RFC is still active.

### Progressive Disclosure Model

| Tier | Location | Loaded when | Target size |
|------|----------|-------------|-------------|
| 1 | `CLAUDE.md` | Every session, automatically | <100 lines |
| 2 | `.claude/skills/` | On demand, when skill triggers | <500 lines each |
| 3 | `docs/agent-guides/` | On demand, via CLAUDE.md pointers | Unlimited |

The key insight: CLAUDE.md is a table of contents, skills are chapters,
and agent-guides are appendices. An agent loads only what the current
task requires. Keep Tier 1 lean so every session starts fast.

### The Router Pattern

CLAUDE.md should be a **behavioral router**, not reference documentation.
It tells Claude Code *what to do* (rules) and *where to look* (pointers),
not *how things work* (architecture docs).

**What belongs in CLAUDE.md (~80-100 lines):**
- Project name + one-line description
- Quick reference table of common commands
- Safety constraints (what NOT to do — critical for data safety)
- **Automatic Behaviors** — "when X, do Y" rules Claude follows without
  being asked. This is the most important section. It covers:
  - When building UI → follow design system, use existing components
  - When creating data → create migrations, use the data layer
  - When something breaks → self-healing steps (sync, reset, reinstall)
  - Before finishing → always build, always test
- **Decision filter** — the project's north star for prioritization
  (e.g., "does this make the demo more compelling?")
- Build conventions (3-5 lines max)
- **Deep Reference index** — table of pointers to docs/ files

**What does NOT belong in CLAUDE.md:**
- Full architecture docs → `docs/architecture.md`
- Setup/installation scripts → `docs/guides/developer-setup.md`
- Design system specs → `docs/design-system.md`
- Environment variable tables → `docs/architecture.md`
- Migration/workflow procedures → `docs/guides/`
- Agent system details → `docs/agent-guides/`

The rule of thumb: if a section is only relevant to specific tasks
(not every session), it belongs in `docs/`, not `CLAUDE.md`.

See `references/claude-md-router-example.md` for a complete 82-line
example based on a real project.

---

## Part 3: Workflow Rules

These four rules are the harness collaboration contract. They apply to
every human and every agent session in the repo.

### Rule 1: Check for Duplicates Before Creating Issues

Before creating any new Linear issue, search for existing issues with
similar titles or descriptions.

```
1. Extract 3-5 key terms from the proposed issue
2. Search Linear: list_issues with keyword filter
3. Review results — if any issue overlaps significantly in intent,
   comment on the existing issue instead of creating a new one
4. Only if no match → create the new issue
```

This prevents the issue sprawl that kills velocity in teams where
both humans and agents are filing work.

### Rule 2: Check Sprint Priorities Before Starting Work

At the start of every session or when asked "what should I work on":

```
1. Query list_cycles to find the active cycle
2. Query list_issues filtered to that cycle, sorted by priority
3. Present the top 3-5 items: priority | status | summary
4. Ask which issue to pick up (or let the user specify)
```

This ensures nobody (human or agent) starts work on something that
isn't the highest-leverage thing to do right now.

### Rule 3: Update Issue Status on Start and Complete

- When starting work on an issue → move it to "In Progress"
- When done (PR opened, tests passing) → move it to "Done"

This is how the team avoids collisions. An agent picking up work
can see what's already in flight, and a human checking Linear at
standup sees accurate status without asking anyone.

### Rule 4: Post Summary Comments to Linear Issues

After completing work on an issue, post a comment summarizing:
- What was done (files changed, approach taken)
- PR link if applicable
- Any follow-up issues created (after running the duplicate check)

This creates the audit trail that makes async, mixed human+agent
collaboration actually work. Every issue tells its own story.

---

## Commands

| Command | Purpose |
|---------|---------|
| `/harness:setup` | Full environment preflight + repo scaffold check |
| `/harness:priorities` | Query Linear for current sprint priorities |
| `/harness:check-duplicates` | Search Linear for potential duplicates before filing |
| `/harness:start-task` | Pick up an issue, move to In Progress, load context |
| `/harness:complete-task` | Mark done, post summary, link the PR |

---

## Reference Files

- **`references/claude-md-rules.md`** — append blocks for CLAUDE.md
  (automatic behaviors + workflow rules)
- **`references/claude-md-router-example.md`** — complete example of a
  well-structured 82-line CLAUDE.md following the router pattern
- **`references/templates/prd-template.md`** — PRD template
- **`references/templates/adr-template.md`** — ADR template
- **`references/templates/rfc-template.md`** — RFC template
- **`references/setup-troubleshooting.md`** — common auth and config issues
