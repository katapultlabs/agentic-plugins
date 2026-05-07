# brand-dna

Capture a brand's identity from a live website into your repo as agent-readable artifacts.

## What it does

Given a brand URL, the skill extracts and persists four things:

1. **`tokens.dtcg.json`** — machine-readable design tokens in [DTCG (W3C Design Tokens Community Group)](https://design-tokens.github.io/community-group/format/) format. The canonical source of truth. Pipe directly into [Style Dictionary](https://amzn.github.io/style-dictionary/) (CSS / Swift / Kotlin), Tailwind, [Token Studio](https://tokens.studio), or Figma Variables import.
2. **`DESIGN.md`** — human/AI-readable wrapper around the JSON in [Google Stitch DESIGN.md](https://designmd.app) format. References tokens by name, with hex tables for quick reference. Drop-in for Claude Code, Cursor, Lovable, v0, Bolt — any AI coding agent.
3. **`BRAND_VOICE.md`** — voice and tone. Verbatim taglines, vocabulary rules, sentence patterns, length budgets, examples of on-brand vs off-brand copy.
4. **`.claude/skills/<brand>-brand/SKILL.md`** — a project-specific skill that auto-applies the brand DNA to any visual or copy work in the repo. Self-checks before emitting output.

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
2. Run [`dembrandt`](https://github.com/dembrandt/dembrandt) via `npx` with `--dtcg` to extract design tokens
3. Use WebFetch to pull voice copy from the homepage and any secondary pages
4. Synthesize `tokens.dtcg.json`, `DESIGN.md`, and `BRAND_VOICE.md` at the project root
5. Scaffold the project skill at `.claude/skills/<brand>-brand/SKILL.md`
6. Add `.brand-extraction/` to `.gitignore`

## Quick mode

Skip the questions and ship a draft:

```
> /brand-dna https://litsalt.com --quick
```

## Optional flags

- `--with-css` — also emit `tokens.css` (CSS custom properties) for direct browser consumption.
- `--with-tailwind` — also emit `tokens.tailwind.json` for Tailwind theme extension.

Both are off by default — most teams compile from `tokens.dtcg.json` via Style Dictionary, which generates these and more.

## Refresh

Re-run on an existing project. The skill diffs current files against the new extraction and offers to update or replace.

## Output principles

- **Brand voice is whatever the source actually uses.** No imposed templates. If the brand writes in Spanish, gold-standard copy stays in Spanish.
- **Brand-class-aware** — consumer product, B2B SaaS, person/creator, agency. The skill prompts and output templates vary slightly per class.
- **Honest gap analysis** — if the brand has a notable mechanism gap (e.g., LIT's no-glucose / SGLT1 example for a hydration brand), it goes in `BRAND_NOTES.md`.

## Requirements

- `node` and `npx` available (the skill runs `dembrandt` via `npx`)
- WebFetch available in the host agent

## What's new

### v0.2.0
- **DTCG token output.** New `tokens.dtcg.json` at the project root, generated via dembrandt's `--dtcg` flag. Canonical source of truth; Style Dictionary, Tailwind, and Figma Variables consume it directly.
- **DESIGN.md references token names** (e.g. `color.lit.lime`) instead of bare hex values. Hex still shown in tables for quick reference, but the JSON is authoritative.
- **Project SKILL.md teaches agents the source-of-truth rule**: when JSON and markdown disagree, JSON wins on values, markdown wins on rules.
- **Optional flags** `--with-css` and `--with-tailwind` for direct emission of those formats.
- **Refresh path preserves user-curated rules** in DESIGN.md / BRAND_VOICE.md while always overwriting the machine-generated JSON.

### v0.1.0
Initial release. DESIGN.md, BRAND_VOICE.md, project SKILL.md.

## Contributing

Improvements welcome via PR to [katapultlabs/agentic-plugins](https://github.com/katapultlabs/agentic-plugins). The skill itself is a single SKILL.md — no executable code.
