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

### testID Conventions
Every interactive element has a testID:
- Screens: `screen-{name}` (e.g., `screen-home`, `screen-login`)
- Buttons: `btn-{action}` (e.g., `btn-send`, `btn-sign-in`)
- Text inputs: `input-{field}` (e.g., `input-email`, `input-message`)
- Lists: `list-{name}` (e.g., `list-messages`, `list-conversations`)
- List items: `item-{name}-{index}` or `card-{name}-{index}`
- Filters: `btn-filter-{type}` (e.g., `btn-filter-breakfast`)
- Views/sections: `view-{name}` (e.g., `view-error`, `view-empty-state`)

### Key screens and their testIDs
<!-- Fill in your project's screen map here -->
- **Login**: `screen-login`, `input-email`, `btn-sign-in`
- **Home**: `screen-home`, ...
