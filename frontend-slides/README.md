# Frontend Slides Plugin

Create stunning, animation-rich HTML presentations from scratch or by converting PowerPoint files.

## What It Does

Frontend Slides helps non-designers create beautiful web presentations without knowing CSS or JavaScript. It uses a "show, don't tell" approach — instead of asking you to describe your design preferences in words, it generates visual previews and lets you pick what you like.

### Key Features

- **Zero Dependencies** — Single HTML files with inline CSS/JS. No npm, no build tools.
- **Visual Style Discovery** — Pick from 3 generated style previews instead of describing preferences.
- **PPT Conversion** — Convert existing PowerPoint files to web presentations.
- **12 Curated Styles** — Dark, light, and specialty themes designed to avoid generic AI aesthetics.
- **Viewport Fitting** — Every slide fits exactly in the browser window. No scrolling.

## Components

| Component | Name | Purpose |
|-----------|------|---------|
| Skill | `frontend-slides` | Core presentation creation workflow with style discovery, generation, and PPT conversion |

## Available Styles

**Dark:** Bold Signal, Electric Studio, Creative Voltage, Dark Botanical
**Light:** Notebook Tabs, Pastel Geometry, Split Pastel, Vintage Editorial
**Specialty:** Neon Cyber, Terminal Green, Swiss Modern, Paper & Ink

## Usage

The skill triggers when you ask to create a presentation, make slides, convert a PowerPoint to HTML, or build a pitch deck.

**New presentation:** Describe your topic and the skill walks you through content discovery, style selection (with visual previews), and generation.

**PPT conversion:** Provide a .pptx file and the skill extracts all content, lets you pick a style, and generates an HTML version.

## Requirements

- For PPT conversion: Python with `python-pptx` library (`pip install python-pptx`)

## Credits

Created by [@zarazhangrui](https://github.com/zarazhangrui). Original repo: https://github.com/zarazhangrui/frontend-slides

## License

MIT
