Add or remove a collaborator from the project. Usage: `/site:collab add <github-username>` or `/site:collab remove <github-username>`.

Parse `$ARGUMENTS` to extract the action (add/remove) and username.

If no username is provided, ask the user for their collaborator's GitHub username (not email).

Run `bash ${CLAUDE_PLUGIN_ROOT}/ghsetup.sh collab $ARGUMENTS`.

Translate the result:
- add success → "Done! They'll get an email invitation to join your project."
- remove success → "Removed. They no longer have access."
- `collab_failed` → "I couldn't add that person. Double-check their GitHub username and try again."

No jargon, no raw JSON.
