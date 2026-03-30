Save the current project — stages all changes, scans for secrets, and backs everything up.

Run `bash ${CLAUDE_PLUGIN_ROOT}/ghsetup.sh save`.

Translate the result into plain language:
- Success → "All saved! Your changes are safely backed up."
- `nothing_to_save` → "Everything is already saved — you're up to date."
- `secrets_detected` → "I found something that looks like a password or API key. I can't upload that — let me help you move it somewhere safe."
- `push_failed` → "Saved on your computer, but couldn't upload. Check your internet connection."

Never show raw JSON or git output.
