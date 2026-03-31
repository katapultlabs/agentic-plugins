## iOS Simulator Testing (MCP)

The project has `ios-simulator-mcp` configured in `.mcp.json` for autonomous iOS testing.

### Prerequisites
- IDB installed: `brew tap facebook/fb && brew install idb-companion && pipx install fb-idb`
- Simulator booted: `xcrun simctl boot "{{DEVICE_NAME}}"`

### Bundle ID
`{{BUNDLE_ID}}`

### Testing workflow
1. **Build**: `cd {{MOBILE_DIR}} && npx expo run:ios --device "{{DEVICE_NAME}}"`
2. **Launch**: Use `launch_app` with bundle ID `{{BUNDLE_ID}}`
3. **Read screen**: Use `ui_describe_all` (10-50 tokens) instead of screenshots (1,600+ tokens)
4. **Navigate**: Use `ui_tap` / `ui_swipe` based on accessibility tree positions
5. **Verify**: Read accessibility tree again, compare expected vs actual
6. **Screenshot**: Only for visual verification or when accessibility data is insufficient

### Gotchas
- **Expo Go modal**: Dismiss Close/X button on first launch before interacting
- **Metro cache**: After switching `.env`, must `npx expo start --clear`
- **Native modules**: New native packages need `npx expo run:ios` rebuild
- **IDB Python**: Use 3.11-3.12, not 3.13+ (asyncio incompatibilities)
- **Local auth**: Synced OAuth users login with `localdev123` (set by sync script)

### testID Conventions
- Screens: `screen-{name}`
- Buttons: `btn-{action}`
- Text inputs: `input-{field}`
- Lists: `list-{name}`
- Items: `item-{name}-{index}` or `card-{name}-{index}`
- Filters: `btn-filter-{type}`
- Views: `view-{name}`

### Key screens and their testIDs
<!-- Fill in your project's screen map -->
- **Login**: `screen-login`, `input-email`, `btn-sign-in`
- **Home**: `screen-home`, ...
