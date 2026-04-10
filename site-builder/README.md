# site

GitHub for everyone. A Claude Code plugin that helps non-technical users create, save, and publish web projects to GitHub Pages — without ever touching git.

## What it does

- **Start a project** — scaffolds HTML/CSS/JS, creates a GitHub repo, and pushes it live
- **Save progress** — backs up all changes in one step with secret scanning
- **Publish** — enables GitHub Pages and gives the user a live URL
- **Invite** — adds collaborators by GitHub username
- **Fix** — checks prerequisites and reports issues in plain language

## Installation

Add the Katapult marketplace, then install:

```
/plugin marketplace add katapult/ghsetup
/plugin install site@katapult-tools
```

## Commands

| Command | What it does |
|---|---|
| `/site:connect` | Connect your GitHub account (run once) |
| `/site:new-project` | Start a new project |
| `/site:save` | Save your work |
| `/site:publish` | Put your site online |
| `/site:my-site` | See your site's status and URL |
| `/site:invite` | Add someone to your project |
| `/site:new-change` | Start working on a new change |
| `/site:submit` | Submit your changes for review |
| `/site:fix` | Something not working? Run this |

## Requirements

- macOS or Linux
- The plugin's `connect` command installs `git`, `jq`, and `gh` CLI automatically if missing
