# Katapult AI Plugins

A plugin marketplace for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) and Claude Cowork. Browse, install, and use community plugins that extend Claude's capabilities.

## Install the marketplace

Add this marketplace to your Claude Code instance:

```
/plugin marketplace add katapultlabs/agentic-plugins
```

Then browse available plugins:

```
/plugin
```

Go to the **Discover** tab to see all plugins from this marketplace, or install one directly:

```
/plugin install whatsapp-markdown@katapult-plugins
```

## Available Plugins

| Plugin | Description |
|--------|-------------|
| [whatsapp-markdown](./whatsapp-markdown) | Convert standard Markdown into WhatsApp-compatible formatting |

## Using a plugin

Once installed, plugins add skills that Claude can use automatically or that you can invoke via slash commands. For example:

```
/whatsapp-markdown:whatsapp-markdown
```

Or just ask Claude naturally — "format this for WhatsApp" — and the skill activates automatically.

## Contributing a plugin

We welcome contributions! See [CONTRIBUTING.md](./CONTRIBUTING.md) for the full guide.

**Quick start:**

1. Fork this repository
2. Create your plugin directory:
   ```
   my-plugin/
   ├── .claude-plugin/
   │   └── plugin.json
   ├── README.md
   └── skills/
       └── my-skill/
           └── SKILL.md
   ```
3. Add your plugin to `.claude-plugin/marketplace.json`
4. Open a pull request

## Plugin structure

Each plugin follows this layout:

```
plugin-name/
├── .claude-plugin/
│   └── plugin.json          # Plugin metadata (name, version, description, author)
├── README.md                # Human-readable documentation
└── skills/
    └── skill-name/
        └── SKILL.md         # Skill instructions with YAML frontmatter
```

### plugin.json

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "What this plugin does.",
  "author": {
    "name": "Your Name"
  },
  "keywords": ["relevant", "keywords"]
}
```

### SKILL.md

```yaml
---
name: my-skill
description: "When to activate this skill. Be specific about triggers."
---

# My Skill

Instructions for Claude go here...
```

## License

[MIT](./LICENSE)
