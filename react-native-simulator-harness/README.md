# React Native Simulator Harness

A Claude Code plugin that gives Claude the knowledge to autonomously test React Native and Expo apps on the iOS Simulator.

## What it does

When this plugin is active, Claude Code can:

- **Build** your React Native / Expo app for the iOS Simulator
- **Launch** the app and read the screen via accessibility tree (token-efficient)
- **Navigate** by tapping elements, typing text, and swiping
- **Verify** screen state against expectations
- **Fix issues** it finds, rebuild, and re-verify — in a closed loop

No manual intervention required. Claude follows a battle-tested workflow developed on production Expo projects.

## Prerequisites

- macOS with Xcode and iOS Simulators
- [Facebook IDB](https://github.com/nicklama/idb) for simulator tap/swipe/accessibility
- [ios-simulator-mcp](https://github.com/joshuayoes/ios-simulator-mcp) configured in your project's `.mcp.json`

The plugin's skill includes full setup instructions — if prerequisites are missing, Claude will help you install them.

## What's included

### Skill: `rn-simulator-harness`

Activates when you ask Claude to test, verify, or interact with a React Native app on the simulator. Contains:

- Step-by-step testing workflow (build → launch → read → navigate → verify)
- testID naming conventions for consistent element identification
- Token efficiency strategies (accessibility tree over screenshots — 96% reduction)
- Common gotchas and their fixes (Metro cache, native modules, Expo Go modal, IDB Python version)
- Environment switching pattern (local dev / production)
- Local auth setup for synced OAuth users
- Troubleshooting decision trees

### Templates

- `templates/mcp-config.json` — Drop-in `.mcp.json` for ios-simulator-mcp
- `templates/claude-md-section.md` — Copy-paste CLAUDE.md section with placeholders for your project's bundle ID and device name

## Usage

Once installed, just ask Claude:

- "Test the login flow"
- "Verify the home screen looks correct"
- "Navigate to settings and check if the sign out button works"
- "Build the app and check for any visual issues on the profile page"

Claude will follow the harness workflow autonomously.

## Trigger phrases

The skill activates on: "test the app", "verify the UI", "check the screen", "run the mobile app", "test the login flow", "navigate the app", "take a screenshot", "build and test", or any task involving iOS Simulator interaction.

## Based on

This plugin distills lessons from:
- [ios-simulator-mcp](https://github.com/joshuayoes/ios-simulator-mcp) (1.7k stars, Anthropic-endorsed)
- [Expo MCP Server](https://docs.expo.dev/eas/ai/mcp/)
- Production use on Expo SDK 55 projects with Supabase, NativeWind, and Claude agent systems
