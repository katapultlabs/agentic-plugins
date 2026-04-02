# Setup Troubleshooting

Common issues and fixes when running `/harness:setup`.

## Linear MCP

### "Authentication failed" or "Unauthorized"
The OAuth token may have expired or was never completed.
1. Run `/mcp` in your Claude Code session
2. Look for the Linear entry and click "Authenticate"
3. Complete the OAuth flow in your browser
4. Run `/harness:setup` again to verify

### "Could not connect to Linear MCP server"
The `.mcp.json` entry may be malformed. Verify it looks like:
```json
{
  "mcpServers": {
    "linear": {
      "type": "http",
      "url": "https://mcp.linear.app/mcp"
    }
  }
}
```
The `type` field must be `"http"` (not `"sse"` — Linear migrated to
streamable HTTP transport). The URL must be exactly
`https://mcp.linear.app/mcp`.

### "No issues found" but you know there are issues
Check that the authenticated user has access to the correct Linear
workspace. The MCP server scopes to the workspace you authorize during
the OAuth flow.

## GitHub CLI (`gh`)

### "gh: command not found"
The `gh` CLI is not installed. Install it:
- **macOS**: `brew install gh`
- **Linux**: see https://cli.github.com/
- **Windows**: `winget install GitHub.cli`

### "not logged in" or "authentication failed"
Run `! gh auth login` in your Claude Code prompt to authenticate
interactively. Follow the browser flow to authorize.

### Verifying your setup
Run `gh auth status` — it should show your GitHub username and the
active account. If it shows the wrong account, run `gh auth switch`
or `gh auth login` again.

### Using GitLab instead
If your team uses GitLab, install the `glab` CLI
(`brew install glab`) or add a GitLab MCP entry to `.mcp.json`.
The harness checks that at least one source control tool is present.

## Engineering Plugin

### "Engineering plugin not found"
The plugin is installed per-user, not per-repo. Each person needs to:
1. Open the Claude Code plugin marketplace
2. Search for "engineering" under knowledge-work-plugins
3. Install it

This only needs to be done once per machine. The plugin persists across
sessions and repositories.

## CLAUDE.md

### "CLAUDE.md is missing"
Run `/init` in the repo first. Claude Code's built-in `/init` does
self-discovery of your project — languages, frameworks, build commands,
conventions — and generates a CLAUDE.md tailored to the actual repo.
After `/init` completes, run `/harness:setup` again to add workflow
rules on top.

### "CLAUDE.md exists but is very short"
This usually means `/init` was run but the file was never customized,
or it's a manual stub. You can re-run `/init` to enrich it (it
preserves existing content). The `/harness:setup` command will then
offer to append the workflow rules.

### Team members see different CLAUDE.md content
Make sure CLAUDE.md is committed to git and everyone is on the same
branch. CLAUDE.md is a shared team resource — treat it like code.
Changes should go through PR review.
