---
name: rn-simulator-harness
description: >
  Autonomous iOS Simulator testing for React Native and Expo projects. Use when
  the user asks to "test the app", "verify the UI", "check the screen", "run the
  mobile app", "test a flow", "navigate the app", "take a screenshot", "build and
  test", or any task involving iOS Simulator interaction with a React Native or
  Expo project. Also use when setting up iOS simulator testing infrastructure,
  adding testIDs, or debugging simulator issues.
---

# React Native iOS Simulator Harness

Autonomously build, launch, navigate, and verify React Native / Expo apps on the iOS Simulator.

## Prerequisites

Verify before testing. If missing, run `scripts/setup.sh` or guide the user through manual install.

- **macOS** with Xcode + iOS Simulators
- **Facebook IDB**: `brew tap facebook/fb && brew install idb-companion && pipx install fb-idb`
- **ios-simulator-mcp** in project `.mcp.json` — use `assets/mcp-config.json` as template

IDB requires Python 3.11-3.12. Python 3.13+ has asyncio incompatibilities. If using mise: `pipx install fb-idb --python "$(mise where python 3.12)/bin/python3"`.

## Testing Workflow

1. **Boot simulator**: `xcrun simctl boot "iPhone 17 Pro"`
2. **Build**: `cd <mobile-dir> && npx expo run:ios --device "<device-name>"`
3. **Launch**: MCP `launch_app` with bundle ID from `app.json` → `expo.ios.bundleIdentifier`
4. **Read screen**: MCP `ui_describe_all` — returns accessibility tree (10-50 tokens)
5. **Navigate**: MCP `ui_tap` at element center from accessibility tree frame
6. **Type**: MCP `ui_type` to input text into focused fields
7. **Swipe**: MCP `ui_swipe` with `x_start`, `y_start`, `x_end`, `y_end` for scrolling
8. **Verify**: `ui_describe_all` again, compare expected vs actual
9. **Screenshot**: MCP `screenshot` only for visual checks (1,600+ tokens, use sparingly)

Always prefer `ui_describe_all` over screenshots. 96% token reduction.

## Element Identification

Elements in the accessibility tree report:
- `AXUniqueId` — the testID (most reliable identifier)
- `AXLabel` — visible text or accessibility label
- `frame` — `{x, y, width, height}` position
- `type` — Button, TextField, StaticText, etc.

To tap, calculate center: `x = frame.x + frame.width/2`, `y = frame.y + frame.height/2`.

## testID Conventions

Add testIDs to all interactive elements. See `references/testid-conventions.md` for the full guide. Summary:

| Element | Pattern | Example |
|---------|---------|---------|
| Screen | `screen-{name}` | `screen-home` |
| Button | `btn-{action}` | `btn-send` |
| Input | `input-{field}` | `input-email` |
| List | `list-{name}` | `list-messages` |
| Item | `item-{name}-{index}` | `item-message-0` |
| Card | `card-{name}-{index}` | `card-recipe-0` |
| Filter | `btn-filter-{type}` | `btn-filter-all` |
| View | `view-{name}` | `view-error` |

## Common Gotchas

See `references/gotchas.md` for full details. Critical ones:

- **Expo Go dev tools modal**: Appears on first launch. Dismiss by tapping Close/X before interacting with app.
- **Metro env cache**: After switching `.env`, restart with `npx expo start --clear` or old URLs persist.
- **Native module errors**: New native packages need `npx expo run:ios` rebuild, not just hot reload. Wrap imports in try/catch for graceful degradation.
- **Keyboard blocking**: If `ui_type` fails, toggle hardware keyboard with Cmd+Shift+K in Simulator.
- **Expo SDK upgrades**: `npx expo install expo@latest --fix` → `npx expo prebuild --clean` → rebuild. Never manually edit `ios/` or `android/` after prebuild.

## Setup

Run `scripts/setup.sh` from any directory to install prerequisites and verify:

```bash
bash <skill-path>/scripts/setup.sh
```

To add the CLAUDE.md testing section to a project, adapt `assets/claude-md-template.md` — replace `{{BUNDLE_ID}}` and `{{DEVICE_NAME}}` placeholders.

## Environment Switching

For projects with local/production environments:

```bash
cp .env.local-dev .env   # Switch to local
cp .env.local-prod .env  # Switch to production
npx expo start --clear   # REQUIRED — flush Metro cache
```

## Local Auth for Synced Users

Production OAuth users won't have passwords locally. Set one directly:

```sql
UPDATE auth.users SET
  encrypted_password = crypt('localdev123', gen_salt('bf')),
  raw_app_meta_data = raw_app_meta_data || '{"provider":"email","providers":["email"]}'::jsonb
WHERE email = 'user@example.com';
```

Gate the password field in the login UI on `SUPABASE_URL` containing `localhost`.

## Troubleshooting

**App won't load?** Metro running → Simulator booted → App built for device → Expo Go modal blocking?

**Taps not working?** Element in tree → Tapping center of frame → Keyboard/modal blocking?

**Wrong data?** Which `.env` active → Metro cache cleared → API running?

**"Cannot find native module"?** Needs `npx expo run:ios` rebuild.
