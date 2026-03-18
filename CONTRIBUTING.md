# Contributing to Katapult AI Plugins

Thanks for your interest in contributing a plugin to the marketplace!

## Adding a new plugin

### 1. Create the plugin directory

Create a new directory at the repository root with your plugin name (use kebab-case):

```
your-plugin-name/
├── .claude-plugin/
│   └── plugin.json
├── README.md
└── skills/
    └── your-skill-name/
        └── SKILL.md
```

### 2. Write plugin.json

```json
{
  "name": "your-plugin-name",
  "version": "1.0.0",
  "description": "A clear, concise description of what the plugin does.",
  "author": {
    "name": "Your Name"
  },
  "keywords": ["relevant", "keywords"]
}
```

**Guidelines:**
- `name` must match the directory name, use kebab-case
- Follow [semantic versioning](https://semver.org/)
- Keep `description` under 200 characters

### 3. Write your skill(s)

Each skill lives in `skills/<skill-name>/SKILL.md` and must include YAML frontmatter:

```yaml
---
name: your-skill-name
description: "Describe what the skill does AND when Claude should activate it. Include specific trigger phrases."
---

# Skill Title

Your instructions for Claude go here.
```

**Skill writing tips:**

- Be specific about activation triggers in the `description` field
- Write clear, step-by-step instructions
- Include examples showing expected input and output
- Document edge cases
- Reference external documentation where relevant
- Keep instructions focused — one skill should do one thing well

### 4. Write a README

Your plugin's `README.md` should include:

- What the plugin does
- What conversions, transformations, or actions it performs
- Example usage (what the user says to trigger it)

### 5. Register in the marketplace

Add an entry to the root `.claude-plugin/marketplace.json`:

```json
{
  "name": "your-plugin-name",
  "source": "./your-plugin-name",
  "description": "Same description as in plugin.json.",
  "version": "1.0.0"
}
```

### 6. Open a pull request

- Branch from `main`
- Include only your plugin files and the marketplace.json update
- Describe your plugin in the PR description
- Ensure your plugin follows all guidelines above

## Updating an existing plugin

1. Make your changes
2. Bump the version in both `plugin.json` and `marketplace.json`
3. Open a pull request describing what changed

## Guidelines

- **One concern per plugin** — don't bundle unrelated skills together
- **No executable code** — plugins are instruction-based (SKILL.md files), not code packages
- **No secrets or credentials** — never include API keys, tokens, or sensitive data
- **Test your skill** — verify it works in Claude Code before submitting
- **Keep it focused** — a skill that does one thing well is better than one that tries to do everything
