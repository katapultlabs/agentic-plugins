# CLAUDE.md Router Example

This is a concrete example of a well-structured CLAUDE.md that follows
the router pattern. It's based on a real project (Bocelli — AI legal ops
platform) and demonstrates all the key sections.

Use this as a model, not a template. Adapt the sections to your project's
actual conventions, commands, and safety constraints.

---

```markdown
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Project Name

One-sentence description of the project and its primary goal.

## Quick Reference

| Command | What it does |
|---------|-------------|
| `pnpm build` | Production build — always verify before pushing |
| `pnpm test` | Run test suite |
| `pnpm check` | Lint + type checking |
| `pnpm sync` | Pull remote data into local environment |

## Safety Constraints

- **NEVER** delete or truncate [critical tables/data] without explicit consent.
- **NEVER** commit `.env.local` or credentials.
- [Other project-specific constraints]

## How Claude Code Should Work in This Repo

These rules apply automatically every session. The user should not need to ask.

### When building UI
- Follow [design system/framework]. Full spec in `docs/design-system.md`.
- Use existing components from `src/components/` before creating new ones.
- New screens go in [directory pattern]. Pattern documented in `docs/guides/adding-a-screen.md`.

### When creating or modifying data
- New tables need a migration. Full workflow in `docs/guides/database-migrations.md`.
- New fixture data goes in `src/data/`. Update the seed script after adding.
- New queries go through the data layer in `src/lib/data/`.

### When something breaks
1. [Most common fix — e.g., run sync/reset command]
2. [Second fix — e.g., reinstall dependencies]
3. [Third fix — e.g., restart services]

### Before finishing any task
1. Run `pnpm build` — never done without a passing build.
2. If you created a migration → run migration test.
3. If you modified data → run seed command.

## Build Conventions

- [3-5 critical conventions, one line each]
- [e.g., "Use pnpm, not npm or yarn"]
- [e.g., "Path alias: @/* maps to ./src/*"]

## Deep Reference (read on demand)

| Document | What it covers |
|----------|---------------|
| `docs/architecture.md` | Directory structure, tech stack, data layer, auth |
| `docs/design-system.md` | Colors, fonts, spacing, component patterns |
| `docs/guides/database-migrations.md` | Creating, testing, pushing migrations |
| `docs/guides/developer-setup.md` | Zero-to-running setup, troubleshooting |
| `docs/prds/prd.md` | Product requirements and screen specs |

## Workflow Rules

[Linear/GitHub workflow rules — appended by /harness:setup]
```

---

## Why This Works

1. **82 lines, not 450.** Claude Code loads this every session. Lean = fast.
2. **Behavioral rules, not reference docs.** "When X, do Y" is actionable.
   "Here is the architecture" is not.
3. **Self-healing built in.** Claude Code knows how to fix common issues
   without the user diagnosing them.
4. **Pointers, not content.** Deep docs live in `docs/` and are loaded
   only when the current task needs them.
5. **Decision filter.** Every project should have a north star that
   Claude Code uses to prioritize ("does this make the demo more
   compelling?" or "does this improve test coverage?").
