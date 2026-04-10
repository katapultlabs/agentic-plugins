Submit your changes for review. Saves any pending work and creates a review request so your team can look at what you've done before it goes live.

If `$ARGUMENTS` is provided, use it as the title for the review request. Otherwise generate one from the change description.

Run `bash ${CLAUDE_PLUGIN_ROOT}/ghsetup.sh pr $ARGUMENTS`.

Translate the result:
- Success -> "Your changes have been submitted for review! Here's the link: [PR URL]. Share this with your team so they can take a look. Once they approve it, the changes will go live."
- `already_exists` -> "You already submitted this change for review. Here's the link: [PR URL]."
- `no_changes_branch` -> "You haven't started a new change yet. Use `/site:new-change` first to start working on something."
- `secrets_detected` -> "I found something that looks like a password in your files. I need to fix that before submitting."
- `pr_failed` -> "I couldn't submit your changes. Let me check what's wrong..." (then run doctor)

Never say "pull request", "PR", "branch", or "merge". Say "review request", "changes", or "submitted".
No raw JSON, no git output.
