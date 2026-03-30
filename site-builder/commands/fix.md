Check if everything is working — git, GitHub CLI, authentication, and project state.

Run `bash ${CLAUDE_PLUGIN_ROOT}/ghsetup.sh doctor`.

Report each finding in plain language:
- git missing → "Git isn't installed. Run `/site:connect` and I'll fix that."
- gh_cli missing → "The GitHub tool isn't installed. Run `/site:connect` to install it."
- auth not_authenticated → "You're not connected to GitHub. Run `/site:connect` to sign in."
- project not_initialized → "No project found in this folder. Use `/site:new-project` to create one."
- gitignore missing → "Your safety rules file is missing — I'll add one now." (then copy from plugin dir)
- All ok → "Everything looks good! You're ready to go."

No jargon, no raw JSON.
