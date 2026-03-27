---
name: rn-simulator-harness
description: >
  Use this skill when working with React Native or Expo mobile apps that need to be
  tested on the iOS Simulator. Triggers when the user asks to "test the app",
  "verify the UI", "check the screen", "run the mobile app", "test the login flow",
  "navigate the app", "take a screenshot", or any task involving iOS Simulator
  interaction with a React Native project. Also triggers when you need to build,
  launch, or debug a React Native app on the simulator.
---

# React Native iOS Simulator Harness

You are an autonomous mobile testing agent. You can build, launch, navigate, and verify React Native / Expo apps on the iOS Simulator without manual intervention.

## Prerequisites

Before testing, verify these are in place. If anything is missing, help the user set it up.

### Required
- **macOS** with Xcode installed (iOS Simulator is macOS-only)
- **Facebook IDB** (iOS Development Bridge) — extends `xcrun simctl` with tap/swipe/accessibility tree
- **ios-simulator-mcp** configured in `.mcp.json`

### Setup Commands (run if prerequisites are missing)

```bash
# Install IDB
brew tap facebook/fb && brew install idb-companion
brew install pipx && pipx ensurepath

# Install fb-idb Python client (use Python 3.11 or 3.12, NOT 3.13+)
pipx install fb-idb --python python3.12
# If using mise: pipx install fb-idb --python "$(mise where python 3.12)/bin/python3"

# Verify IDB works
idb list-targets
```

### MCP Configuration

The project needs an `.mcp.json` with ios-simulator-mcp. If it doesn't exist, create it:

```json
{
  "mcpServers": {
    "ios-simulator": {
      "command": "npx",
      "args": ["-y", "ios-simulator-mcp"],
      "env": {
        "IOS_SIMULATOR_MCP_DEFAULT_OUTPUT_DIR": "./test-artifacts"
      }
    }
  }
}
```

Add `test-artifacts/` to `.gitignore`.

## Testing Workflow

Follow this sequence for any testing task:

### 1. Boot the Simulator
```bash
xcrun simctl boot "iPhone 17 Pro"  # or whatever device the project uses
```

### 2. Build the App
```bash
# Expo projects:
cd apps/mobile && npx expo run:ios --device "iPhone 17 Pro"

# Bare React Native:
npx react-native run-ios --simulator="iPhone 17 Pro"
```

### 3. Launch the App
Use the MCP tool `launch_app` with the project's bundle identifier.
Check `app.json` → `expo.ios.bundleIdentifier` or `Info.plist` for the bundle ID.

### 4. Read the Screen (Token-Efficient)
**ALWAYS prefer `ui_describe_all` over `screenshot`.**

| Method | Token Cost | When to Use |
|--------|-----------|-------------|
| `ui_describe_all` | 10-50 tokens | Default — navigation, verification, element finding |
| `ui_describe_point` | 5-10 tokens | Targeted — check a specific coordinate |
| `screenshot` / `ui_view` | 1,600-6,300 tokens | Visual verification only — colors, layout, images |

### 5. Navigate
Use `ui_tap` with coordinates from the accessibility tree. Elements report their `frame` with `{x, y, width, height}` — tap the center of the element.

Use `ui_type` to enter text into focused fields.

Use `ui_swipe` for scrolling (swipe from bottom to top to scroll down).

### 6. Verify
Read the accessibility tree again after each action. Compare expected vs actual:
- Is the right screen showing? (look for `screen-{name}` testIDs)
- Are the expected elements present?
- Do text values match expectations?

### 7. Screenshot (only when needed)
Take a screenshot only for:
- Visual regression checks (colors, layout, images)
- Evidence for the developer
- When accessibility data is insufficient

## testID Conventions

Every interactive element should have a `testID` following this naming pattern:

| Element Type | Pattern | Examples |
|-------------|---------|----------|
| Screens | `screen-{name}` | `screen-home`, `screen-login`, `screen-settings` |
| Buttons | `btn-{action}` | `btn-send`, `btn-sign-in`, `btn-cancel`, `btn-back` |
| Text inputs | `input-{field}` | `input-email`, `input-password`, `input-search` |
| Lists | `list-{name}` | `list-messages`, `list-contacts`, `list-items` |
| List items | `item-{name}-{index}` | `item-message-0`, `item-contact-3` |
| Cards | `card-{name}-{index}` | `card-recipe-0`, `card-product-2` |
| Filters | `btn-filter-{type}` | `btn-filter-all`, `btn-filter-active` |
| Views/sections | `view-{name}` | `view-error`, `view-empty-state`, `view-loading` |
| Modals | `modal-{name}` | `modal-confirm`, `modal-settings` |
| Navigation tabs | `tab-{name}` | `tab-home`, `tab-profile` |

testIDs appear in the accessibility tree as `AXUniqueId` values — use them to identify elements reliably across UI changes.

## Common Gotchas

### Expo Go Dev Tools Modal
On first launch via Expo Go, a full-screen dev tools modal appears. Dismiss it by:
1. Looking for a button labeled "Close" or with `AXUniqueId: "xmark"` in the accessibility tree
2. Tapping it before attempting to interact with the app
3. Alternatively, tap "Continue" if it's the onboarding version

### Metro Bundle Cache
**Critical:** Metro caches environment variables at bundle time. After switching `.env` files (e.g., from production to local dev), you MUST restart Metro with cache cleared:
```bash
npx expo start --clear
```
Without this, the app continues using the old API URLs even though the `.env` file changed.

### Native Module Errors
If you see "Cannot find native module 'X'" at runtime:
- The module was installed via npm but requires a **native rebuild**
- Run `npx expo run:ios` (not just Metro restart)
- For graceful degradation, wrap imports in try/catch:
```tsx
let SomeModule = null;
try { SomeModule = require("some-native-module"); } catch {}
```

### IDB Python Version
fb-idb requires Python 3.11 or 3.12. Python 3.13+ has asyncio changes that break it. If you see `RuntimeError: There is no current event loop`, reinstall with an older Python.

### Expo SDK Upgrades
After a major SDK upgrade (e.g., 52 → 55):
1. `npx expo install expo@latest --fix` — bumps all Expo packages
2. `npx expo prebuild --clean` — regenerates iOS/Android native projects
3. Install new peer deps (e.g., Reanimated 4.x needs `react-native-worklets`)
4. Rebuild: `npx expo run:ios`
5. Never manually edit `ios/` or `android/` after prebuild — they're generated

### Keyboard Not Working in Simulator
If `ui_type` doesn't work, the hardware keyboard may be intercepting input. Toggle it:
- In Simulator menu: I/O → Keyboard → Connect Hardware Keyboard (uncheck)
- Or press `Cmd + Shift + K`

## Environment Switching Pattern

For projects that need to point to different backends (local dev vs production):

```
apps/mobile/
├── .env              # Active config (gitignored)
├── .env.local-dev    # Local Supabase + local API
├── .env.local-prod   # Production services
```

To switch:
```bash
# Switch to local
cp apps/mobile/.env.local-dev apps/mobile/.env

# Switch to production
cp apps/mobile/.env.local-prod apps/mobile/.env

# IMPORTANT: Clear Metro cache after switching
npx expo start --clear
```

## Local Auth for Synced Users

When syncing production users to a local database, OAuth users (Google, Apple) won't have passwords. Set a local dev password directly in the database:

```sql
UPDATE auth.users
SET encrypted_password = crypt('localdev123', gen_salt('bf')),
    raw_app_meta_data = raw_app_meta_data || '{"provider": "email", "providers": ["email"]}'::jsonb
WHERE email = 'user@example.com';
```

Then add a password field to the login screen that only appears in local dev (gate on `SUPABASE_URL` containing `localhost` or `127.0.0.1`).

## Troubleshooting Decision Tree

**App won't load in simulator?**
1. Is Metro running? → `npx expo start`
2. Is the simulator booted? → `xcrun simctl boot "iPhone 17 Pro"`
3. Was the app built for this simulator? → `npx expo run:ios --device "iPhone 17 Pro"`
4. Is there an Expo Go modal blocking? → Dismiss it (tap Close/X)

**Taps not working?**
1. Read the accessibility tree → is the element where you expect it?
2. Are you tapping the center of the element's frame?
3. Is the keyboard covering the element? → Dismiss keyboard first
4. Is a modal/alert blocking? → Dismiss it first

**Wrong data showing?**
1. Check which `.env` is active → `cat apps/mobile/.env`
2. Did you clear Metro cache after switching? → `npx expo start --clear`
3. Is the local API running? → Check the API server process

**"Cannot find native module" error?**
1. Was a new native package installed? → Needs `npx expo run:ios` rebuild
2. Was the SDK upgraded? → Needs `npx expo prebuild --clean` then rebuild
