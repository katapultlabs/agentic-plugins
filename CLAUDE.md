# Katapult AI Plugins — Marketplace

This is a Claude Code plugin marketplace repository. It hosts plugins that anyone can install into Claude Code or Claude Co-Work.

## Repository structure

```
.claude-plugin/
  marketplace.json         # Marketplace catalog — lists all available plugins
<plugin-name>/
  .claude-plugin/
    plugin.json            # Plugin metadata
  README.md                # Plugin documentation
  skills/
    <skill-name>/
      SKILL.md             # Skill definition with YAML frontmatter
```

## Key files

- **`.claude-plugin/marketplace.json`** — the marketplace index. Every plugin must be registered here.
- **`plugin.json`** — metadata for each plugin (name, version, description, author, keywords).
- **`SKILL.md`** — the actual skill instructions Claude follows. Must include YAML frontmatter with `name` and `description`.

## Adding a plugin

1. Create a directory at the root with your plugin name (kebab-case)
2. Add `.claude-plugin/plugin.json`, `README.md`, and `skills/<name>/SKILL.md`
3. Register the plugin in the root `marketplace.json`
4. Keep versions in sync between `plugin.json` and `marketplace.json`

## Conventions

- Plugin names use kebab-case
- One plugin per top-level directory
- Skills must have descriptive activation triggers in their `description` field
- No executable code — plugins are instruction-only
- Follow semantic versioning
