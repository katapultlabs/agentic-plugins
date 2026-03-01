---
name: whatsapp-markdown
description: "Convert standard Markdown into WhatsApp-compatible formatting. Use this skill whenever the user mentions WhatsApp, wants to format text for WhatsApp, asks for WhatsApp-friendly markdown, wants to send formatted content via WhatsApp, or needs to strip unsupported markdown features for messaging apps. Also trigger when the user says things like 'format this for messaging', 'make this WhatsApp-ready', or 'simplify this markdown for chat'."
---

# WhatsApp Markdown Converter

Convert standard Markdown to the simplified formatting that WhatsApp actually supports. WhatsApp uses a subset of Markdown — some things carry over directly, others need translation, and some features just don't exist.

## WhatsApp's Supported Formatting (the complete list)

| Format | WhatsApp Syntax | Notes |
|---|---|---|
| **Bold** | `*text*` | Single asterisks, not double |
| *Italic* | `_text_` | Underscores only |
| ~~Strikethrough~~ | `~text~` | Single tilde, not double |
| Monospace block | ` ```text``` ` | Triple backticks (same as Markdown code blocks) |
| `Inline code` | `` `text` `` | Single backtick (same as Markdown) |
| Bulleted list | `* item` or `- item` | Asterisk or hyphen + space |
| Numbered list | `1. item` | Number + period + space |
| Quote | `> text` | Angle bracket + space |

That's it. No headers, no links, no images, no tables, no horizontal rules, no nested formatting beyond what naturally works.

Reference: https://faq.whatsapp.com/539178204879377/

## Conversion Rules

When converting standard Markdown to WhatsApp format, apply these transformations:

### Direct conversions

1. **Bold**: `**text**` or `__text__` → `*text*`
2. **Italic**: `*text*` or `_text_` → `_text_` (use underscores to avoid collision with bold)
3. **Strikethrough**: `~~text~~` → `~text~`
4. **Code blocks**: Already compatible (triple backticks). Remove any language identifier after the opening backticks (e.g., ` ```python ` → ` ``` `)
5. **Inline code**: Already compatible (single backtick)
6. **Bulleted lists**: Already compatible (`- item` or `* item`)
7. **Numbered lists**: Already compatible (`1. item`)
8. **Blockquotes**: Already compatible (`> text`)

### Features that need replacement

9. **Headers** (`# H1` through `###### H6`): Convert to bold text on its own line. Add a blank line before and after for visual separation.
   - `# My Title` → `*My Title*`
   - `## Section` → `*Section*`

10. **Links**: `[text](url)` → `text (url)` — keep the URL visible since WhatsApp doesn't support hyperlinks. If the link text IS the URL, just leave the URL bare.

11. **Images**: `![alt](url)` → remove entirely, or if the alt text is meaningful, keep it as a note: `[Image: alt text]`

12. **Tables**: Convert to a readable plain-text layout. Use bold for headers and line breaks between rows. For simple tables, a colon-separated format works well:
    ```
    *Name*: Alice
    *Role*: Engineer
    *Team*: Platform
    ```

13. **Horizontal rules** (`---`, `***`, `___`): Replace with a blank line or a visual separator like `———`

14. **HTML tags**: Strip all HTML. If `<br>` or `<br/>`, convert to newline.

15. **Nested lists**: Flatten to single level. WhatsApp doesn't reliably render indented list nesting.

### Bold + italic combined

Standard Markdown `***text***` or `**_text_**` → `*_text_*` in WhatsApp (bold wraps italic). This nesting does work in WhatsApp.

## Workflow

1. Read the user's Markdown content
2. Apply the conversion rules above
3. Present the WhatsApp-ready text in a fenced code block so the user can copy-paste it cleanly (use a plain code block with no language tag)
4. If anything was lost in translation (images, complex tables, footnotes), briefly note what was dropped and why

## Edge Cases

- **Escaped characters**: If the source Markdown has `\*` or `\_`, remove the backslash — WhatsApp doesn't use escape characters.
- **Bold inside italic or vice versa**: WhatsApp supports `_*text*_` and `*_text_*`. Preserve the intent.
- **Empty formatting**: `** **` or `_ _` — strip the formatting markers entirely.
- **Consecutive formatting**: Ensure there's no accidental merging, e.g., `*bold1**bold2*` should remain `*bold1* *bold2*`.
