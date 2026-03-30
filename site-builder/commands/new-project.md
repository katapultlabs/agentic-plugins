Start a new web project. Creates a GitHub repo and scaffolds HTML/CSS/JS starter files.

Run `bash ${CLAUDE_PLUGIN_ROOT}/ghsetup.sh doctor` first to check prerequisites. If `auth` is `not_authenticated`, run `bash ${CLAUDE_PLUGIN_ROOT}/setup.sh` before continuing (tell the user to run `/site:connect` first).

If `$ARGUMENTS` is provided, use it as the project name. Otherwise use the current folder name.

Run `bash ${CLAUDE_PLUGIN_ROOT}/ghsetup.sh init $ARGUMENTS`.

If the result has `"needs_choice":true`, ask the user in plain language where to create the project — under their personal account or one of their teams — then re-run with `--owner <chosen>`.

On success, tell them their project is ready and offer to help them build something. Speak in plain language — no git jargon.
