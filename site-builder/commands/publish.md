Publish the project online using GitHub Pages and share the live URL.

Run `bash ${CLAUDE_PLUGIN_ROOT}/ghsetup.sh deploy`.

Translate the result:
- Success → "Your site is live! Here's the link: [URL]. It might take a minute or two to show the latest changes."
- `pages_failed` → "I couldn't turn on the website hosting. Make sure there's an index.html file in your project."
- `secrets_detected` → "Found something that looks like a password in your files — I can't put that online. Let me help you fix it first."

Never show raw JSON, git output, or terminal errors. No jargon.
