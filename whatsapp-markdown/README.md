# WhatsApp Markdown

Convert standard Markdown into WhatsApp-compatible formatting.

## What it does

WhatsApp supports a small subset of Markdown. This plugin teaches Claude the exact conversions needed so you can write in full Markdown and get back copy-pasteable WhatsApp text.

**Conversions handled:**

- `**bold**` → `*bold*` (single asterisks)
- `*italic*` → `_italic_` (underscores)
- `~~strikethrough~~` → `~strikethrough~` (single tilde)
- `# Headers` → `*Bold text*` (no header support in WhatsApp)
- `[links](url)` → `text (url)` (no hyperlinks in WhatsApp)
- Tables → readable plain-text layout
- Images, HTML, horizontal rules → stripped or replaced
- Code blocks, inline code, lists, quotes → kept as-is (already compatible)

## How to use

Just ask Claude to format something for WhatsApp:

- "Convert this to WhatsApp format"
- "Make this WhatsApp-ready"
- "Format this markdown for messaging"

Reference: https://faq.whatsapp.com/539178204879377/
