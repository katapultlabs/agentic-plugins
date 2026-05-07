# brand-dna

Capture a brand's identity from a live website into your repo as agent-readable artifacts.

## What it does

Given a brand URL, the skill extracts and persists three things:

1. **`DESIGN.md`** — visual system in [Google Stitch DESIGN.md](https://designmd.app) format. Colors, typography, components, spacing, radii, shadows, do/don'ts. Drop-in for Claude Code, Cursor, Lovable, v0, Bolt — any AI coding agent.
2. **`BRAND_VOICE.md`** — voice and tone. Verbatim taglines, vocabulary rules, sentence patterns, length budgets, examples of on-brand vs off-brand copy.
3. **`.claude/skills/<brand>-brand/SKILL.md`** — a project-specific skill that auto-applies the brand DNA to any visual or copy work in the repo. Self-checks before emitting output.

Raw extraction artifacts (dembrandt JSON, fetched HTML, screenshots) land in `.brand-extraction/` (gitignored).

## When to use it

- You're starting an app or marketing project for an existing brand and want the AI agent to ship on-brand work without per-prompt explanation.
- You're refreshing a captured brand after the source site evolved.
- You're partnering with a brand and need a working representation of their identity in your codebase.

## Example

```
> /brand-dna https://litsalt.com
```

Or just say it conversationally:

> Capture the litsalt.com brand into this repo

The skill will:

1. Ask 1-3 quick questions (secondary pages, primary language, refresh-or-create)
2. Run [`dembrandt`](https://github.com/dembrandt/dembrandt) via `npx` to extract design tokens
3. Use WebFetch to pull voice copy from the homepage and any secondary pages
4. Synthesize `DESIGN.md` and `BRAND_VOICE.md` at the project root
5. Scaffold the project skill at `.claude/skills/<brand>-brand/SKILL.md`
6. Add `.brand-extraction/` to `.gitignore`

## Quick mode

Skip the questions and ship a draft:

```
> /brand-dna https://litsalt.com --quick
```

## Refresh

Re-run on an existing project. The skill diffs current files against the new extraction and offers to update or replace.

## Output principles

- **Brand voice is whatever the source actually uses.** No imposed templates. If the brand writes in Spanish, gold-standard copy stays in Spanish.
- **Brand-class-aware** — consumer product, B2B SaaS, person/creator, agency. The skill prompts and output templates vary slightly per class.
- **Honest gap analysis** — if the brand has a notable mechanism gap (e.g., LIT's no-glucose / SGLT1 example for a hydration brand), it goes in `BRAND_NOTES.md`.

## Requirements

- `node` and `npx` available (the skill runs `dembrandt` via `npx`)
- WebFetch available in the host agent

## Contributing

Improvements welcome via PR to [katapultlabs/agentic-plugins](https://github.com/katapultlabs/agentic-plugins). The skill itself is a single SKILL.md — no executable code.
