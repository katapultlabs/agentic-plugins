Start working on a new change. Creates a separate workspace so your edits don't affect the current version until they're reviewed.

Derive a short description from `$ARGUMENTS` if provided, or from the conversation context — what the user has been working on, what they asked for, or the nature of recent changes. You should always be able to come up with something reasonable.

First check for unsaved work — if there are pending changes, offer to save them before continuing.

Run `bash ${CLAUDE_PLUGIN_ROOT}/ghsetup.sh branch <description>`.

Translate the result:
- Success -> "You're all set! You're now working on: [description]. Any changes you make from here are separate from the current version. When you're done, use `/site:submit` to send your work for review."
- `unsaved_changes` -> "You have unsaved work. Want me to save it first before starting something new?"
- `branch_failed` -> "Something went wrong setting up your workspace. Let me check what happened..." (then run doctor)
- `push_failed` -> "Set up locally but couldn't sync with GitHub. Check your internet connection."

Never say "branch", "checkout", or "merge". Say "workspace", "change", or "version" instead.
No raw JSON, no git output.
