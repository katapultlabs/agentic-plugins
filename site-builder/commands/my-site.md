Check the current project status — whether it's online, if there are unsaved changes, and the live URL if available.

Run `bash ${CLAUDE_PLUGIN_ROOT}/ghsetup.sh status`.

Translate the result into plain language:
- If `initialized` is false → "There's no project set up in this folder yet. Want me to create one?"
- If `pages_enabled` is true → share the URL and mention whether there are unsaved changes.
- If `pages_enabled` is false → let them know their project isn't online yet and offer to publish it.
- If `has_unsaved_changes` is true → proactively offer to save.

No jargon, no raw JSON.
