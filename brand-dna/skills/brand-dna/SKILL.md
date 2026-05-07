---
name: brand-dna
description: "Capture a brand's identity from a live URL into the current repo as DESIGN.md, BRAND_VOICE.md, and an auto-applying project skill. Use when the user says: capture this brand, extract brand DNA, set up brand for this project, get [URL] into our repo, refresh the brand from the site, our project needs the [brand] design system."
allowed-tools: Bash, Read, Write, Edit, Grep, Glob, WebFetch
---

# brand-dna

You are capturing a brand's identity from a live website and persisting it into the user's current repository as four artifacts:

1. **`tokens.dtcg.json`** at repo root — machine-readable design tokens in [DTCG (W3C Design Tokens Community Group)](https://design-tokens.github.io/community-group/format/) format. The canonical source of truth for downstream tooling (Style Dictionary, Tailwind, Token Studio, Figma Variables import, custom build scripts).
2. **`DESIGN.md`** at repo root — human-readable wrapper around the JSON. References tokens by name, with hex/value tables for quick lookup. Google Stitch DESIGN.md spec format.
3. **`BRAND_VOICE.md`** at repo root — voice / tone with verbatim copy.
4. **`.claude/skills/<brand-slug>-brand/SKILL.md`** — project-specific skill that auto-loads all three files for every UI/copy task in this repo.

Raw extraction artifacts go to `.brand-extraction/` (gitignored).

**Source-of-truth rule.** When the JSON and the markdown disagree (e.g. a manual edit drifted), `tokens.dtcg.json` wins on values; `DESIGN.md` wins on rules / do-don'ts. The project SKILL.md tells future agents this explicitly.

This skill runs in the user's *current* working directory — not the marketplace repo. Always confirm the working directory is the project where the brand should land before writing files.

## Step 0 — gather inputs

Parse the user's invocation for:

- **`URL`** — required. The brand's primary website (homepage). Extract from the user's message; ask if missing.
- **`--quick`** — if present, skip the clarifying questions and ship drafts the user can edit.
- **Working directory** — `pwd` to confirm. If the user is in a marketplace / dotfiles / unrelated repo, ask before writing.

If `--quick` is present, jump to Step 1.

Otherwise ask **at most three** short questions (combine into one message when reasonable):

1. **Secondary pages?** — "Any other pages I should pull voice from? (about / story / product / mission). Paste URLs or say `none`." Default: just the homepage.
2. **Primary language?** — Detect from the homepage `<html lang>` or visible copy. Confirm if ambiguous: "Voice in {detected}, or another?" The brand's voice should stay in the language the brand actually uses.
3. **Refresh or create?** — only ask if `DESIGN.md` or `BRAND_VOICE.md` already exist at the project root. Options: `refresh` (diff and update), `replace` (overwrite), `cancel`.

Do NOT ask for: brand name, colors, fonts, voice attributes, or anything else extractable from the source. The whole point is zero friction.

## Step 1 — extract design tokens with `dembrandt`

Make sure node is available:

```bash
command -v npx
```

If absent: tell the user "I need `node` / `npx` to run the design-token extractor. Install Node and re-invoke." Stop.

Run dembrandt against the URL. It opens the page in headless Chromium and emits a JSON dump, a draft DESIGN.md, AND a DTCG-spec token file:

```bash
npx -y dembrandt@latest --design-md --dtcg --save-output "{URL}"
```

Output lands in `./output/<host>/`. Move it into `.brand-extraction/`:

```bash
mkdir -p .brand-extraction
mv output/<host>/* .brand-extraction/ 2>/dev/null
rmdir output/<host> output 2>/dev/null
```

If the user passed `--with-css` or `--with-tailwind`, also pass `--css` or `--tailwind` to dembrandt — those flags emit additional `tokens.css` and `tokens.tailwind.json` files that some teams want for direct consumption.

If dembrandt fails (`--help` shows an unknown flag, or the network is blocked, or Chromium can't launch), continue with WebFetch only and tell the user "Visual extraction failed; using a copy-only capture. You'll need to fill in colors and fonts manually."

## Step 2 — extract voice with WebFetch

Fetch the homepage and any secondary pages the user mentioned. Use a single WebFetch call per URL with this prompt (adapt to the user's primary language):

> Extract: (1) full brand voice and tone — exact taglines, headlines, hero copy, CTA copy, product descriptions, mission statements; (2) full color palette — every hex / RGB you can see; (3) typography — font families, weights, sizes; (4) brand pillars and values; (5) target customer language; (6) any "about" or "story" copy. Quote text VERBATIM where possible. Be exhaustive.

Save the raw responses to `.brand-extraction/voice-<page-slug>.md`.

If the homepage WebFetch returns thin content (less than 500 characters), check the sitemap:

```bash
curl -sL "{URL}/sitemap.xml" 2>/dev/null | grep -oE '<loc>[^<]+</loc>' | sed 's/<[^>]*>//g' | head -20
```

Pick the most-likely about / story / product pages and fetch one or two.

## Step 3 — synthesize the artifacts

Read the dembrandt outputs in `.brand-extraction/` and the WebFetch results. Synthesize three (or four) files at the project root.

### `tokens.dtcg.json` (repo root) — write this FIRST

This is the canonical, machine-readable source of truth. Downstream tooling (Style Dictionary, Tailwind, Figma Variables) parses this file; everything else is a wrapper.

If dembrandt produced a DTCG output (look for `*.dtcg.json` or a file with `$value` keys in `.brand-extraction/`), copy it to the project root as `tokens.dtcg.json`. Validate it parses:

```bash
python3 -m json.tool tokens.dtcg.json > /dev/null && echo "tokens.dtcg.json: valid" || echo "INVALID"
```

If dembrandt's DTCG output isn't strictly DTCG-spec-compliant (e.g., missing `$type` keys), reshape to this skeleton — fill the values from the dembrandt JSON dump and assign `$type` per token category (`color`, `dimension`, `fontFamily`, `fontWeight`, `typography`, `shadow`, `duration`, `cubicBezier`):

```json
{
  "$schema": "https://design-tokens.github.io/community-group/format/",
  "color": {
    "{brand}": {
      "ink":   { "$value": "#xxxxxx", "$type": "color", "$description": "Primary text, headers, secondary buttons" },
      "{accent}": { "$value": "#xxxxxx", "$type": "color", "$description": "Brand signature; one primary action per screen" },
      "cream": { "$value": "#xxxxxx", "$type": "color", "$description": "Default page background" }
    },
    "semantic": {
      "success": { "$value": "#xxxxxx", "$type": "color" },
      "warning": { "$value": "#xxxxxx", "$type": "color" },
      "error":   { "$value": "#xxxxxx", "$type": "color" }
    }
  },
  "spacing": {
    "xs": { "$value": "4px", "$type": "dimension" },
    "s":  { "$value": "8px", "$type": "dimension" },
    "m":  { "$value": "16px", "$type": "dimension" },
    "l":  { "$value": "24px", "$type": "dimension" },
    "xl": { "$value": "32px", "$type": "dimension" }
  },
  "borderRadius": {
    "xs":   { "$value": "2px",   "$type": "dimension" },
    "s":    { "$value": "4px",   "$type": "dimension" },
    "m":    { "$value": "8px",   "$type": "dimension" },
    "pill": { "$value": "30px",  "$type": "dimension", "$description": "Brand button radius" },
    "full": { "$value": "999px", "$type": "dimension" }
  },
  "fontFamily": {
    "display": { "$value": "Clash Display, -apple-system, system-ui, sans-serif", "$type": "fontFamily" },
    "body":    { "$value": "Barlow, -apple-system, system-ui, sans-serif", "$type": "fontFamily" },
    "label":   { "$value": "Barlow Condensed, -apple-system, system-ui, sans-serif", "$type": "fontFamily" }
  },
  "typography": {
    "displayXl": {
      "$value": { "fontFamily": "{fontFamily.display}", "fontWeight": 600, "fontSize": "66px", "lineHeight": "1.20" },
      "$type": "typography"
    },
    "displayL": {
      "$value": { "fontFamily": "{fontFamily.display}", "fontWeight": 600, "fontSize": "50px", "lineHeight": "1.20" },
      "$type": "typography"
    },
    "body": {
      "$value": { "fontFamily": "{fontFamily.body}", "fontWeight": 500, "fontSize": "15px", "lineHeight": "1.55" },
      "$type": "typography"
    }
  },
  "shadow": {
    "card": { "$value": "0 2px 8px rgba(0,0,0,0.10)", "$type": "shadow" },
    "lift": { "$value": "0 5px 15px rgba(0,0,0,0.10)", "$type": "shadow" }
  }
}
```

Token-naming rules:
- The accent / signature color should be named after the brand's actual term for it (`lit.lime`, `linear.electric`, `stripe.indigo`) when the source uses one. Default to a descriptive name (`lit.accent`) only if no brand term exists.
- Group semantic colors under `color.semantic` so brand colors and semantic colors don't fight in the namespace.
- Typography composite tokens (`displayXl`, `body`) reference `fontFamily.*` by name; downstream tools resolve the references.

### `DESIGN.md` (repo root)

Use this exact structure. Fill `{placeholders}` from the extraction. Drop sections that don't apply (e.g., omit Iconography if no icon system was detected).

```markdown
# DESIGN.md - {Brand Name}

> Drop-in design system for AI coding agents (Claude Code, Cursor, v0, Lovable, Bolt).
> Source: extracted from {URL} on {YYYY-MM-DD} via dembrandt + manual cleanup.
> Format: Google Stitch DESIGN.md spec (Apache 2.0).

## Brand

- **Name:** {Brand Name}
- **Category:** {one-line category — what the brand sells / does}
- **Origin:** {country / city if visible}
- **Audience:** {who the brand explicitly addresses}

## Logo

- **Primary file:** `{logo-filename or URL}`
- **Reverse:** {if a light-on-dark variant exists}
- **Clear space:** ≥ 1× cap-height on all sides (default; override if the brand publishes a different rule)

## Tokens (machine-readable)

The canonical source of truth is [`./tokens.dtcg.json`](./tokens.dtcg.json) — DTCG-spec design tokens. Downstream tools read it directly. This document references tokens by their JSON path (e.g. `color.{brand}.ink`).

If a hex / value in this doc disagrees with the JSON, **the JSON wins**.

## Colors

### Core palette

| Token | Hex | Usage | Source weight |
|-------|-----|-------|---------------|
| `color.{brand}.ink` | `#xxxxxx` | Primary text, headers | {N occurrences} |
| `color.{brand}.{accent}` | `#xxxxxx` | Primary CTA fill | {N occurrences} |
| ... | ... | ... | ... |

### Semantic

| Token | Hex | Notes |
|-------|-----|-------|
| `color.semantic.success` | `#xxxxxx` | |
| `color.semantic.warning` | `#xxxxxx` | |
| `color.semantic.error` | `#xxxxxx` | |

### Rules

- {rule 1 — e.g., "Use `{brand}/{accent}` for ONE primary action per screen, ever."}
- {rule 2 — e.g., body text contrast on each background}
- {rule 3 — e.g., never tint the accent below 100% opacity for CTAs}
- Maintain WCAG AA (4.5:1) for all body copy.

## Typography

### Type families

| Role | Family | Fallback stack |
|------|--------|----------------|
| Display / Headlines | **{font name}** ({weight}) | `-apple-system, system-ui, sans-serif` |
| Body / UI | **{font name}** ({weight}) | `-apple-system, system-ui, sans-serif` |
| Labels / Eyebrows | **{font name}** ({weight}, uppercase) | same |

### Type scale

| Token | Size | Family | Weight | Line-height | Transform |
|-------|------|--------|--------|-------------|-----------|
| `typography.displayXl` | {Npx} | {family} | {weight} | {lh} | {transform} |
| `typography.displayL` | ... | ... | ... | ... | ... |
| ... | ... | ... | ... | ... | ... |

### Rules

- {rule 1 — e.g., "Headlines are always semi-bold (600), never bold (700)"}
- {rule 2 — e.g., "Display sizes are uppercase; sentence case from heading/s and below"}
- {rule 3 — e.g., emphasis weight in body text}

## Spacing

{N}px base scale. Common values: `{list of px values from extraction}`.

## Radii

| Token | Value | Usage |
|-------|-------|-------|
| `borderRadius.xs` | {Npx} | inline tags |
| `borderRadius.s` | {Npx} | cards (secondary) |
| `borderRadius.m` | {Npx} | cards (primary) |
| `borderRadius.pill` | {Npx} | **buttons (default)**, primary CTAs |
| `borderRadius.full` | 999px | pills |
| `borderRadius.circle` | 50% | avatars, icon buttons |

{One-line note about which radius is the brand signature, if obvious.}

## Elevation / Shadows

| Token | Value | Usage |
|-------|-------|-------|
| `shadow.card` | `{value}` | default card |
| `shadow.lift` | `{value}` | hover, lifted modals |

## Components

### Primary button

```
background: {hex}
color: {hex}
padding: {Npx Npx}
border-radius: {Npx}
font: {family} {weight}, {size}, {transform if any}
hover: {behavior}
```

### Secondary button

```
{spec}
```

### Card

```
{spec}
```

## Breakpoints

`{list of px values}`.

For native iOS / watchOS / Android, map to platform size classes; the visual language above is the source of truth, not the breakpoints.

## Iconography

{Detected icon system, e.g., "Font Awesome on web; SF Symbols on Apple platforms with weight `medium` to match {body family}."}

## Consuming the tokens

The `tokens.dtcg.json` file is consumable by:

- **Direct import** (no build step): React, SwiftUI (via Codable), Kotlin, plain JS — walk the JSON at runtime.
- **Style Dictionary** (`v4+`): drop in a `style-dictionary.config.js`, run `style-dictionary build` to generate `tokens.css`, `Tokens.swift`, `tokens.kt`, etc. Recipe:
  ```js
  // style-dictionary.config.js
  export default {
    source: ['tokens.dtcg.json'],
    platforms: {
      css:    { transformGroup: 'css',    buildPath: 'build/', files: [{ destination: 'tokens.css', format: 'css/variables' }] },
      swift:  { transformGroup: 'ios-swift', buildPath: 'build/', files: [{ destination: 'Tokens.swift', format: 'ios-swift/class.swift', className: 'Tokens' }] },
      kotlin: { transformGroup: 'compose', buildPath: 'build/', files: [{ destination: 'Tokens.kt', format: 'compose/object', className: 'Tokens', packageName: 'com.{brand}.tokens' }] }
    }
  }
  ```
- **Tailwind**: import the JSON in `tailwind.config.js` and map under `theme.extend.colors` / `theme.extend.fontFamily`.
- **Figma Variables**: use the [Figma Tokens plugin](https://docs.tokens.studio) to import `tokens.dtcg.json` directly.

## Voice

This is the visual system only. For tone, copy patterns, taglines, and messaging rules, see [`BRAND_VOICE.md`](./BRAND_VOICE.md).

## Do / Don't

- **Do** {observation 1 from the extraction}
- **Do** {observation 2}
- **Do** {observation 3}
- **Don't** {anti-pattern 1}
- **Don't** {anti-pattern 2}
- **Don't** {anti-pattern 3}

## How agents should use this file

When asked to build UI for the {Brand Name} project, an agent should:
1. Read `tokens.dtcg.json` for the canonical values, then this file for the rules and component specs.
2. Default to {primary background}, {primary text color}, {display family} headlines, {body family} body.
3. Reserve {accent token} for the single primary action per view.
4. Read [`BRAND_VOICE.md`](./BRAND_VOICE.md) for any user-facing copy.
```

### `BRAND_VOICE.md` (repo root)

Use this exact structure. The voice attributes table is filled from the patterns the extraction surfaced — do NOT impose attributes the brand doesn't actually exhibit.

```markdown
# BRAND_VOICE.md - {Brand Name}

> Companion to `DESIGN.md`. Voice / tone / copy rules for AI agents writing {Brand}-facing text.
> Source: extracted verbatim from {URL} on {YYYY-MM-DD}.

## Brand essence

{One paragraph: what the brand is, who it's for, and the voice attribute that defines it. End with a one-line voice summary.}

The voice in one line: **"{exact tagline that captures it, or a paraphrase if no single line nails it}"**

## Audience

Primary: {who they describe as the buyer / user}. Secondary: {if a second segment is visible}.

Self-described targets (verbatim from the site):
- "{verbatim phrase 1}"
- "{verbatim phrase 2}"
- "{verbatim phrase 3}"

## Founder / origin context

{One short paragraph if the site has a founder story / about page. Anchor in lived experience, not corporate prose.}

## Voice attributes

| Attribute | Dial | Notes |
|-----------|------|-------|
| Formality | {low / mid / high} | {observation} |
| Intensity | {low / mid / high} | {observation} |
| Clinical / data-density | {low / mid / high} | {observation} |
| Humor | {none / dry / playful} | {observation} |
| Aspiration | {low / mid / high} | {observation} |
| Inclusivity | {open / selective by design} | {observation} |

## Gold-standard copy (verbatim from {host})

### Headlines / taglines
- "{verbatim 1}"
- "{verbatim 2}"
- "{verbatim 3}"

### Product descriptions
- "{verbatim 1}"
- "{verbatim 2}"

### CTAs
- "{verbatim CTA 1}"
- "{verbatim CTA 2}"

### Cart / utility copy
- "{verbatim 1}"

### Founder / brand pillars
- "{verbatim story line 1}"
- "{verbatim mission}"

## Brand pillars

{N}. **{Pillar 1}** — {one-line description}
{N}. **{Pillar 2}** — {one-line description}
{N}. **{Pillar 3}** — {one-line description}

When in doubt, every piece of copy should ladder up to one of these.

## Vocabulary

### Always use
- "{term}" (not "{lesser alternative}")
- "{term}" (not "{lesser alternative}")
- {N} additional precise vocabulary items

### Avoid
- "{generic term 1}" — {why}
- "{generic term 2}" — {why}
- {N} additional anti-patterns observed by absence in the source

## Sentence patterns the brand uses

These are the structural moves that make copy "sound like {Brand}":

1. **{Pattern name}:** "{example from the site}"
   {one-line description}

2. **{Pattern name}:** "{example}"
   {one-line description}

{N total patterns. 3-5 is typical.}

## Bilingual rules

{If the brand operates in more than one language, document the priority and translation principles. If single-language, write "Single-language brand. Don't introduce translations." and stop.}

## Length budgets

| Surface | Target |
|---------|--------|
| Headline | {N words} |
| Subhead | {N words} |
| Body paragraph | {N sentences max} |
| CTA | {N words}, {case} |
| Notification / push | {N words} |
| Empty state | {pattern} |

## Don'ts

- {observed anti-pattern 1}
- {observed anti-pattern 2}
- {observed anti-pattern 3}

## How agents should use this file

When writing any user-facing copy for the {Brand} project:
1. Read this file before drafting.
2. Default to a sentence pattern from the "Sentence patterns" list above.
3. Match the **length budget** for the surface.
4. Run a final pass through "Vocabulary - Avoid" to catch off-brand words.
5. For any visual styling decision in the same artifact, see [`DESIGN.md`](./DESIGN.md).

## Examples (good vs off-brand)

**Push notification - {scenario 1}**
- ❌ Off-brand: "{example off-brand line}"
- ✅ On-brand: "{example on-brand line in the brand's voice}"

**Empty state - {scenario 2}**
- ❌ Off-brand: "{example}"
- ✅ On-brand: "{example}"

**Achievement - {scenario 3}**
- ❌ Off-brand: "{example}"
- ✅ On-brand: "{example}"
```

### `BRAND_NOTES.md` (repo root, OPTIONAL)

Only write this file if you've identified a notable mechanism / strategy gap or a fact about the brand that wouldn't fit naturally in the visual or voice doc. Examples: a product science gap (e.g., LIT's no-glucose / SGLT1), a contested market position, a stated future SKU.

If nothing rises to that bar, do not create the file.

```markdown
# BRAND_NOTES.md - {Brand Name}

> Brand-strategy notes captured alongside the visual + voice extraction.

## {Note title}

{1-3 paragraphs. Source where possible.}
```

## Step 4 — scaffold the project skill

Create `.claude/skills/<brand-slug>-brand/SKILL.md` so future Claude Code sessions in this repo auto-apply the brand DNA.

Where `<brand-slug>` is a kebab-case slug derived from the brand name (`Lit Salt` → `litsalt`, `Anthropic` → `anthropic`, `The Dor Brothers` → `dor-brothers`).

```markdown
---
name: {brand-slug}-brand
description: Apply the {Brand Name} ({URL}) brand identity - tokens, typography, components, voice, and tone - to any artifact in this repo. Triggers on requests to design, style, write copy, or build UI for {Brand Name}. Auto-loads tokens.dtcg.json, DESIGN.md, and BRAND_VOICE.md into context.
allowed-tools: Read, Edit, Write, Bash, Grep, Glob
---

# {Brand Name} brand skill

You have been invoked because the user is doing work on the {Brand Name} project (`{URL}`) and the artifact at hand should be on-brand.

## Step 1 — load brand DNA

Before any visual / UI work or user-facing copy, read these files at the project root, in order:

1. `tokens.dtcg.json` — **canonical** machine-readable design tokens (colors, type, spacing, radii, shadows). DTCG-spec.
2. `DESIGN.md` — human/AI-readable wrapper: rules, do/don'ts, component specs, how to consume the tokens.
3. `BRAND_VOICE.md` — voice attributes, gold-standard copy, vocabulary rules, sentence patterns.

**Source of truth**: when `tokens.dtcg.json` and `DESIGN.md` show different values for the same token, `tokens.dtcg.json` wins. `DESIGN.md` is the rules layer; the JSON is the values layer.

If `tokens.dtcg.json` is missing, stop and tell the user "the brand DNA hasn't been extracted yet — run `/brand-dna {URL}` from the marketplace." Do not proceed with guesses.

## Step 2 — apply

When the task involves **visual styling** (UI, layouts, components, marketing assets):
- Reference token names from `tokens.dtcg.json` (e.g. `color.{brand}.ink`), not hex values, in any code you generate. The build pipeline resolves names to platform values; hard-coded hexes drift.
- Reserve `color.{brand}.{accent}` for the single most-important action per view.
- For native platforms without a tokens build pipeline, copy the resolved value once into a `Color` extension named after the token (e.g. `Color.brandInk`). Don't sprinkle hex literals.

When the task involves **copy** (microcopy, push notifications, headlines, marketing):
- Match a sentence pattern from `BRAND_VOICE.md`.
- Match the length budget for the surface.
- Run drafted copy through "Vocabulary - Avoid".
- Default to {primary language} unless the user specifies otherwise.

## Step 3 — self-check before emitting

- [ ] Token names referenced, not raw hexes (where a build pipeline exists).
- [ ] Headlines use the display typography token at the appropriate scale.
- [ ] Buttons use the brand's signature radius (`borderRadius.pill` or equivalent).
- [ ] No more than one accent-color primary action per screen.
- [ ] No off-brand vocabulary.
- [ ] Length budgets respected.

## When NOT to use this skill

- Internal-only artifacts (test fixtures, debug logs, code comments).
- The user explicitly asks for a generic / off-brand mockup.
- Backend / data / non-visual / non-copy work.

## Refresh

The brand DNA was extracted on {YYYY-MM-DD} from `{URL}`. If the source has visibly changed, re-run the brand-dna skill from the marketplace:

```
> /brand-dna {URL} --refresh
```
```

## Step 5 — `.gitignore` and finishing touches

Append `.brand-extraction/` to `.gitignore` if it isn't already there:

```bash
grep -q "^\.brand-extraction" .gitignore 2>/dev/null || echo ".brand-extraction/" >> .gitignore
```

Then summarize for the user:

- What was created (`tokens.dtcg.json`, `DESIGN.md`, `BRAND_VOICE.md`, optional `BRAND_NOTES.md`, project skill).
- One-sentence headline observation about the brand (e.g., "Voice is direct and selective — `No es para todos`. Lime accent for primary actions only.").
- One concrete next step. Two good defaults:
  - "Try `/<brand-slug>-brand: design the empty state` to see the skill in action."
  - "Pipe `tokens.dtcg.json` into Style Dictionary or Tailwind to ship the tokens to your UI code."

## Refresh flow

When invoked with `--refresh` or when the user explicitly asks to refresh:

1. Re-run dembrandt and WebFetch as in Steps 1-2.
2. Always overwrite `tokens.dtcg.json` — it is machine-generated and shouldn't carry manual edits. If a user did edit it (rename a token, add a description), preserve those by reading the existing file first, capturing the diff against the new extraction, and asking before overwriting.
3. Diff the new extraction against existing `DESIGN.md` and `BRAND_VOICE.md`. Report the substantive changes (new colors, changed taglines, new pillars).
4. Ask: `update` (merge new findings, keep user-curated rules / examples) or `replace` (overwrite). Default to `update`.
5. On `update`, only write the deltas to `DESIGN.md` and `BRAND_VOICE.md` — don't blow away custom rules / examples the user added by hand.

## Brand-class adaptation

Adjust the synthesis based on what the brand is:

- **Consumer product** (default): the templates above.
- **B2B SaaS**: replace "founder context" with "company positioning"; voice attributes lean toward credibility / specificity / no-fluff.
- **Person / creator**: collapse "audience" and "founder context" into one section; voice attributes include personal-pronoun usage and signature phrases.
- **Agency / studio**: the "audience" is clients in a sector; pillars often reflect process or service shape rather than product lines.

Detect the class from the homepage; ask if ambiguous.

## Failure modes

- **dembrandt times out / Chromium fails to launch.** Continue with WebFetch only, mark the visual sections as `(needs manual review)`, tell the user. Do NOT write a placeholder `tokens.dtcg.json` — better to ship without it than ship invalid tokens.
- **dembrandt's `--dtcg` output is malformed** (missing `$type` keys or non-DTCG shape). Reshape using the skeleton in Step 3 before writing to the project root. Validate JSON parses before declaring success.
- **WebFetch returns a paywall / authentication wall.** Try the sitemap to find an open page; if everything is gated, ask the user for a public mirror URL or to share an HTML export.
- **Source language is not the language we asked about.** Override the user's stated language with what the source actually uses; tell the user which language we used.
- **Brand has multiple sub-brands on the same domain** (e.g., a parent company with several products). Ask which sub-brand the user wants captured before extracting.
- **Source is a Figma file or design tool URL, not a live site.** dembrandt can't crawl those. Tell the user this skill captures live websites; for Figma, suggest [Claude Design](https://claude.ai/design) or the Figma Dev Mode MCP.

## Don'ts

- Don't fabricate hex codes, fonts, or pillars. If the source doesn't supply something, leave the field as `{needs manual review}` rather than guessing.
- Don't ship a `tokens.dtcg.json` with placeholder values. Either ship a valid file with real values, or ship without it and tell the user.
- Don't impose generic startup voice attributes ("approachable, friendly, modern") if the source clearly isn't those things.
- Don't translate gold-standard copy. If the brand is in German, the verbatim quotes stay in German.
- Don't write to a directory you haven't confirmed is the user's project. Always `pwd` first.
- Don't commit the changes. Leave the working tree dirty so the user reviews before committing.
