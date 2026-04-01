# Engineering Harness

Opinionated setup, scaffolding, and workflow enforcement for repositories where
humans and agents collaborate as peers — with Linear as the workflow backbone.

## What It Does

- **Environment preflight** — verifies Linear MCP, GitHub MCP, Engineering plugin,
  CLAUDE.md, and repo structure are properly configured
- **Repo scaffolding** — creates the directory structure for agentic collaboration:
  docs with PRD, ADR, and RFC templates, agent-guides, and .claude/ dirs
- **Workflow enforcement** — duplicate checking before filing issues, sprint
  priority surfacing, automatic status updates, and audit-trail comments

## Components

| Type | Name | Purpose |
|------|------|---------|
| Skill | `harness` | Core setup, scaffolding, and workflow knowledge |
| Command | `/harness:setup` | Full environment preflight + repo scaffolding |
| Command | `/harness:priorities` | Query Linear for current sprint priorities |
| Command | `/harness:check-duplicates` | Search for existing issues before creating new ones |
| Command | `/harness:start-task` | Pick up an issue and move to In Progress |
| Command | `/harness:complete-task` | Mark done, post summary, link PR |
| MCP | `linear` | Linear project management (official server) |
| MCP | `github` | GitHub source control integration |

## Setup

1. Install this plugin from the marketplace
2. Run `/harness:setup` in any repository to check your environment
3. The setup command will walk you through anything that's missing

### Required Authentication

- **Linear**: OAuth via `/mcp` command (first time only per workspace)
- **GitHub**: GitHub Copilot subscription or personal access token

## Usage

### New Repo Onboarding
```
/harness:setup
```
Walks through everything: CLAUDE.md creation, MCP verification, docs scaffolding.

### Daily Workflow
```
/harness:priorities              # What should I work on?
/harness:start-task ENG-123      # Pick up an issue
# ... do the work ...
/harness:complete-task ENG-123   # Wrap up and post summary
```

### Before Filing an Issue
```
/harness:check-duplicates Add rate limiting to the API gateway
```

## Repo Structure Created by /harness:setup

```
repo-root/
├── CLAUDE.md
├── .mcp.json
├── .claude/
│   ├── commands/
│   └── skills/
└── docs/
    ├── prds/           (with template)
    ├── adrs/           (with template)
    ├── rfcs/           (with template)
    ├── guides/
    └── agent-guides/
```

## Dependencies

- **Linear MCP** (bundled) — official server at mcp.linear.app
- **GitHub MCP** (bundled) — GitHub Copilot MCP endpoint
- **Engineering plugin** (recommended) — Anthropic's knowledge-work-plugins
