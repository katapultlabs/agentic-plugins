---
name: frontend-slides
description: >
  This skill should be used when the user asks to "create a presentation",
  "make slides", "build a slide deck", "convert a PowerPoint", "convert PPT
  to HTML", "make a slideshow", "create a pitch deck", "design slides",
  or needs to build animation-rich HTML presentations from scratch or from
  existing .pptx files. Also triggers on "web presentation", "HTML slides",
  or "browser presentation".
---

# Frontend Slides

Create zero-dependency, animation-rich HTML presentations that run entirely in the browser.

## Core Principles

1. **Zero Dependencies** — Single HTML files with inline CSS/JS. No npm, no build tools.
2. **Show, Don't Tell** — Generate visual previews, not abstract choices. People discover what they want by seeing it.
3. **Distinctive Design** — No generic "AI slop." Every presentation must feel custom-crafted.
4. **Viewport Fitting (NON-NEGOTIABLE)** — In landscape, every slide MUST fit exactly within 100vh with no scrolling. Content overflows? Split into multiple slides. In portrait, dense content slides (6+ cards, multi-row stats) may use inner scroll (`overflow-y: auto`) when content physically cannot fit without becoming illegible.

## Design Aesthetics

You tend to converge toward generic, "on distribution" outputs. In frontend design, this creates what users call the "AI slop" aesthetic. Avoid this: make creative, distinctive frontends that surprise and delight.

Focus on:
- Typography: Choose fonts that are beautiful, unique, and interesting. Avoid generic fonts like Arial and Inter; opt instead for distinctive choices that elevate the frontend's aesthetics.
- Color & Theme: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes. Draw from IDE themes and cultural aesthetics for inspiration.
- Motion: Use animations for effects and micro-interactions. Prioritize CSS-only solutions for HTML. Use Motion library for React when available. Focus on high-impact moments: one well-orchestrated page load with staggered reveals (animation-delay) creates more delight than scattered micro-interactions.
- Backgrounds: Create atmosphere and depth rather than defaulting to solid colors. Layer CSS gradients, use geometric patterns, or add contextual effects that match the overall aesthetic.

Avoid generic AI-generated aesthetics:
- Overused font families (Inter, Roboto, Arial, system fonts)
- Cliched color schemes (particularly purple gradients on white backgrounds)
- Predictable layouts and component patterns
- Cookie-cutter design that lacks context-specific character

Interpret creatively and make unexpected choices that feel genuinely designed for the context. Vary between light and dark themes, different fonts, different aesthetics. You still tend to converge on common choices (Space Grotesk, for example) across generations. Avoid this: it is critical that you think outside the box!

## Viewport Fitting Rules

These invariants apply to EVERY slide in EVERY presentation:

- The fluid root font-size rule on `html` (`clamp(18px, calc(14px + 0.35vw + 0.2vh), 26px)`) MUST be the very first CSS rule. It drives all downstream `rem` values.
- Every `.slide` must have `height: 100vh; height: 100dvh; overflow: hidden;` (landscape). In portrait, slides default to `overflow: hidden` too — only slides with class `.dense` get `overflow-y: auto` (see portrait section).
- ALL font sizes and spacing must use `clamp(min, preferred, max)` — never fixed px/rem
- Content containers need `max-height` constraints
- Images: `max-height: min(50vh, 400px)`
- Height breakpoints: 700px, 600px, 500px
- Width breakpoints: 800px (tablet/narrow desktop — stack splits, reduce grid columns), 600px (phone — single-column everything, tighter padding)
- Portrait breakpoint: `@media (orientation: portrait)` flips root font formula to lean on `vh`, switches `scroll-snap-type` to `proximity` (so inner-scroll on `.dense` slides doesn't fight snap), stacks splits/grids to single-column, hides nav dots. Add class `dense` to slides with 6+ cards or multi-row stats to enable inner scroll. Plus 480px portrait-specific for extra-narrow phones.
- Include `prefers-reduced-motion` support
- Font smoothing MUST be on: `-webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale;` (included on the `html` rule)
- Never negate CSS functions directly (`-clamp()`, `-min()`, `-max()` are silently ignored) — use `calc(-1 * clamp(...))` instead

**When generating, read `references/viewport-base.css` and include its full contents in every presentation.**

### Legibility Floor Table

No text in any presentation may ever render below these minimums. When writing custom `clamp()` overrides, the first value (minimum) must respect these floors:

| Element | Minimum Size |
|---------|-------------|
| Title / h1 | `2rem` |
| h2 | `1.6rem` |
| h3 | `1.1rem` |
| Body text | `1rem` |
| Small text / labels | `0.85rem` |

These floors apply at all breakpoints, all orientations, and all display densities — **with one exception**: the ≤500px height breakpoint (landscape phones) relaxes floors to title ≥ 1.6rem, h2 ≥ 1.3rem, h3 ≥ 1rem, body ≥ 0.85rem, small ≥ 0.75rem. This is a last resort; prefer splitting into more slides over relying on this breakpoint. The fluid root font-size ensures `1rem` stays physically readable from 1080p to 4K.

### Content Density Limits Per Slide

| Slide Type | Maximum Content |
|------------|-----------------|
| Title slide | 1 heading + 1 subtitle + optional tagline |
| Content slide | 1 heading + 4-6 bullet points OR 1 heading + 2 paragraphs |
| Feature grid | 1 heading + 6 cards maximum (2x3 or 3x2) |
| Code slide | 1 heading + 8-10 lines of code |
| Quote slide | 1 quote (max 3 lines) + attribution |
| Image slide | 1 heading + 1 image (max 60vh height) |

**Content exceeds limits in landscape?** Split into multiple slides. Never cram, never scroll in landscape. In portrait, slides with 6+ cards or multi-row stats should get class `dense` — the portrait media query in viewport-base.css enables `overflow-y: auto` on `.slide.dense` only. Non-dense slides stay locked.

---

## Phase 0: Detect Mode

Determine what the user wants:

- **Mode A: New Presentation** — Create from scratch. Go to Phase 1.
- **Mode B: PPT Conversion** — Convert a .pptx file. Go to Phase 4.
- **Mode C: Enhancement** — Improve an existing HTML presentation. Read it, understand it, enhance. **Follow Mode C modification rules below.**

### Mode C: Modification Rules

When enhancing existing presentations, viewport fitting is the biggest risk:

1. **Before adding content:** Count existing elements, check against density limits
2. **Adding images:** Must have `max-height: min(50vh, 400px)`. If slide already has max content, split into two slides
3. **Adding text:** Max 4-6 bullets per slide. Exceeds limits? Split into continuation slides
4. **After ANY modification, verify:** `.slide` has `overflow: hidden` (portrait `.slide.dense` gets `overflow-y: auto` via media query), new elements use `clamp()` with legibility-floor minimums, images have viewport-relative max-height, content fits at 1280x720 landscape and stacks correctly in portrait
5. **Proactively reorganize:** If modifications will cause overflow, automatically split content and inform the user. Don't wait to be asked

**When adding images to existing slides:** Move image to new slide or reduce other content first. Never add images without checking if existing content already fills the viewport.

---

## Phase 1: Content Discovery (New Presentations)

**Ask ALL questions in a single AskUserQuestion call** so the user fills everything out at once:

**Question 1 — Purpose** (header: "Purpose"):
What is this presentation for? Options: Pitch deck / Teaching-Tutorial / Conference talk / Internal presentation

**Question 2 — Length** (header: "Length"):
Approximately how many slides? Options: Short 5-10 / Medium 10-20 / Long 20+

**Question 3 — Content** (header: "Content"):
Do you have content ready? Options: All content ready / Rough notes / Topic only

**Question 4 — Inline Editing** (header: "Editing"):
Do you need to edit text directly in the browser after generation? Options:
- "Yes (Recommended)" — Can edit text in-browser, auto-save to localStorage, export file
- "No" — Presentation only, keeps file smaller

**Remember the user's editing choice — it determines whether edit-related code is included in Phase 3.**

If user has content, ask them to share it.

### Step 1.2: Image Evaluation (if images provided)

If user selected "No images" → skip to Phase 2.

If user provides an image folder:
1. **Scan** — List all image files (.png, .jpg, .svg, .webp, etc.)
2. **View each image** — Use the Read tool (Claude is multimodal)
3. **Evaluate** — For each: what it shows, USABLE or NOT USABLE (with reason), what concept it represents, dominant colors
4. **Co-design the outline** — Curated images inform slide structure alongside text. This is NOT "plan slides then add images" — design around both from the start (e.g., 3 screenshots → 3 feature slides, 1 logo → title/closing slide)
5. **Confirm via AskUserQuestion** (header: "Outline"): "Does this slide outline and image selection look right?" Options: Looks good / Adjust images / Adjust outline

**Logo in previews:** If a usable logo was identified, embed it (base64) into each style preview in Phase 2 — the user sees their brand styled three different ways.

---

## Phase 2: Style Discovery

**This is the "show, don't tell" phase.** Most people can't articulate design preferences in words.

### Step 2.0: Style Path

Ask how they want to choose (header: "Style"):
- "Show me options" (recommended) — Generate 3 previews based on mood
- "I know what I want" — Pick from preset list directly

**If direct selection:** Show preset picker and skip to Phase 3. Available presets are defined in [STYLE_PRESETS.md](references/STYLE_PRESETS.md).

### Step 2.1: Mood Selection (Guided Discovery)

Ask (header: "Vibe", multiSelect: true, max 2):
What feeling should the audience have? Options:
- Impressed/Confident — Professional, trustworthy
- Excited/Energized — Innovative, bold
- Calm/Focused — Clear, thoughtful
- Inspired/Moved — Emotional, memorable

### Step 2.2: Generate 3 Style Previews

Based on mood, generate 3 distinct single-slide HTML previews showing typography, colors, animation, and overall aesthetic. Read [STYLE_PRESETS.md](references/STYLE_PRESETS.md) for available presets and their specifications.

| Mood | Suggested Presets |
|------|-------------------|
| Impressed/Confident | Bold Signal, Electric Studio, Dark Botanical |
| Excited/Energized | Creative Voltage, Neon Cyber, Split Pastel |
| Calm/Focused | Notebook Tabs, Paper & Ink, Swiss Modern |
| Inspired/Moved | Dark Botanical, Vintage Editorial, Pastel Geometry |

Save previews to `.claude-design/slide-previews/` (style-a.html, style-b.html, style-c.html). Each should be self-contained, ~50-100 lines, showing one animated title slide.

Open each preview automatically for the user.

### Step 2.3: User Picks

Ask (header: "Style"):
Which style preview do you prefer? Options: Style A: [Name] / Style B: [Name] / Style C: [Name] / Mix elements

If "Mix elements", ask for specifics.

---

## Phase 3: Generate Presentation

Generate the full presentation using content from Phase 1 (text, or text + curated images) and style from Phase 2.

If images were provided, the slide outline already incorporates them from Step 1.2. If not, CSS-generated visuals (gradients, shapes, patterns) provide visual interest — this is a fully supported first-class path.

**Before generating, read these supporting files:**
- [html-template.md](references/html-template.md) — HTML architecture and JS features
- [viewport-base.css](references/viewport-base.css) — Mandatory CSS (include in full)
- [animation-patterns.md](references/animation-patterns.md) — Animation reference for the chosen feeling

**Key requirements:**
- Single self-contained HTML file, all CSS/JS inline
- Include the FULL contents of viewport-base.css in the `<style>` block
- Use fonts from Fontshare or Google Fonts — never system fonts
- Add detailed comments explaining each section
- Every section needs a clear `/* === SECTION NAME === */` comment block

---

## Phase 4: PPT Conversion

When converting PowerPoint files:

1. **Extract content** — Run `python ${CLAUDE_PLUGIN_ROOT}/skills/frontend-slides/scripts/extract-pptx.py <input.pptx> <output_dir>` (install python-pptx if needed: `pip install python-pptx`)
2. **Confirm with user** — Present extracted slide titles, content summaries, and image counts
3. **Style selection** — Proceed to Phase 2 for style discovery
4. **Generate HTML** — Convert to chosen style, preserving all text, images (from assets/), slide order, and speaker notes (as HTML comments)

---

## Phase 5: Delivery

1. **Clean up** — Delete `.claude-design/slide-previews/` if it exists
2. **Open** — Use `open [filename].html` to launch in browser
3. **Summarize** — Tell the user:
   - File location, style name, slide count
   - Navigation: Arrow keys, Space, scroll/swipe, click nav dots
   - How to customize: `:root` CSS variables for colors, font link for typography, `.reveal` class for animations
   - If inline editing was enabled: Hover top-left corner or press E to enter edit mode, click any text to edit, Ctrl+S to save

---

## Display Density Checklist

**Before delivering any presentation, verify every item:**

- [ ] **Fluid root font-size** — `html { font-size: clamp(18px, calc(14px + 0.35vw + 0.2vh), 26px); }` is the very first CSS rule
- [ ] **No text below 0.85rem** — Every `clamp()` minimum respects the legibility floor table (title ≥ 2rem, h2 ≥ 1.6rem, h3 ≥ 1.1rem, body ≥ 1rem, small ≥ 0.85rem). Exception: ≤500px height breakpoint relaxes floors (title ≥ 1.6rem, body ≥ 0.85rem) — prefer splitting slides over relying on this
- [ ] **Legible at 1440px laptop AND 3840px 4K** — Open the presentation at both resolutions and confirm text, spacing, and layout scale correctly
- [ ] **Portrait mode stacks correctly** — Split layouts go vertical, grids become single-column, stat rows stack
- [ ] **Dense slides scroll in portrait** — Slides with 6+ cards or multi-row stats have class `dense` and allow inner scroll (`overflow-y: auto`) in portrait; non-dense slides stay locked
- [ ] **Nav dots hidden in portrait** — `.nav-dots { display: none }` is active in the portrait media query
- [ ] **Font smoothing is on** — `-webkit-font-smoothing: antialiased; -moz-osx-font-smoothing: grayscale;` present on `html`
- [ ] **Width breakpoints active** — Layouts adapt at ≤ 800px (stack splits) and ≤ 600px (single-column everything)

---

## Supporting Files

| File | Purpose | When to Read |
|------|---------|-------------|
| [STYLE_PRESETS.md](references/STYLE_PRESETS.md) | 12 curated visual presets with colors, fonts, and signature elements | Phase 2 (style selection) |
| [viewport-base.css](references/viewport-base.css) | Mandatory responsive CSS — copy into every presentation | Phase 3 (generation) |
| [html-template.md](references/html-template.md) | HTML structure, JS features, code quality standards | Phase 3 (generation) |
| [animation-patterns.md](references/animation-patterns.md) | CSS/JS animation snippets and effect-to-feeling guide | Phase 3 (generation) |
| [extract-pptx.py](scripts/extract-pptx.py) | Python script for PPT content extraction | Phase 4 (conversion) |
