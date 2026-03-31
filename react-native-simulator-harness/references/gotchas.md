# Common Gotchas & Solutions

Battle-tested lessons from production React Native / Expo projects.

## Expo Go Dev Tools Modal

**Symptom:** After launching the app, the accessibility tree shows Expo Go buttons (Reload, Go home, Source code explorer) instead of your app's UI.

**Cause:** Expo Go shows a dev tools onboarding modal on first launch.

**Fix:** Look for a button with `AXUniqueId: "xmark"` or `AXLabel: "Close"` in the accessibility tree. Tap it. Alternatively, tap the dimmed area above the modal to dismiss.

## Metro Bundle Cache

**Symptom:** App shows wrong API URLs, old data, or connects to production instead of local dev (or vice versa) after switching `.env` files.

**Cause:** Metro caches environment variables at bundle time. Changing `.env` without restarting Metro has no effect.

**Fix:** Always restart Metro with cache cleared after switching environments:
```bash
npx expo start --clear
```

## Native Module Not Found

**Symptom:** `Cannot find native module 'ExpoDocumentPicker'` (or similar) at runtime.

**Cause:** A new native dependency was installed via npm/pnpm but the native binary wasn't rebuilt. JS hot reload can't add native modules.

**Fix:** Full native rebuild: `npx expo run:ios --device "<device-name>"`

**Prevention:** Wrap native imports in try/catch for graceful degradation:
```tsx
let DocumentPicker: typeof import("expo-document-picker") | null = null;
try {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  DocumentPicker = require("expo-document-picker");
} catch {
  // Native module not available — needs rebuild
}
```

## IDB Python Version

**Symptom:** `RuntimeError: There is no current event loop` when running `idb` commands.

**Cause:** fb-idb is incompatible with Python 3.13+ due to asyncio API changes.

**Fix:** Reinstall with Python 3.11 or 3.12:
```bash
pipx install fb-idb --python python3.12
# Or with mise:
pipx install fb-idb --python "$(mise where python 3.12)/bin/python3"
```

## Expo SDK Major Upgrades

**Symptom:** Build fails after upgrading Expo SDK (e.g., `EXAppDelegateWrapper` not found, pod install failures).

**Cause:** Major SDK upgrades change native project templates. Manual `ios/` edits break.

**Fix:** Full regeneration:
```bash
npx expo install expo@latest --fix    # Bump all packages
npx expo prebuild --clean              # Regenerate ios/ and android/
npx expo run:ios --device "<device>"   # Rebuild
```

**Common peer deps to install after upgrade:**
- Reanimated 4.x requires `react-native-worklets`
- Check `npx expo install --fix` output for all needed updates

## Keyboard Blocking Input

**Symptom:** `ui_type` doesn't produce text in the simulator, or typed text goes to the wrong field.

**Cause:** The macOS hardware keyboard intercepts keystrokes before they reach the simulated software keyboard.

**Fix:** In the Simulator menu: I/O → Keyboard → Connect Hardware Keyboard (uncheck). Or press `Cmd + Shift + K`.

## Simulator Won't Boot

**Symptom:** `xcrun simctl boot` fails or `idb list-targets` shows "No Companion Connected".

**Fix:**
1. Check available devices: `xcrun simctl list devices available`
2. Make sure the target runtime is installed: Xcode → Settings → Platforms
3. Try a different device name (use exact name from `list devices`)
4. Kill zombie simulators: `xcrun simctl shutdown all` then retry

## Local Auth for Synced OAuth Users

**Symptom:** Users synced from production via OAuth (Google/Apple) can't log in locally because they have no password.

**Fix:** Set a local dev password directly in Supabase:
```sql
UPDATE auth.users SET
  encrypted_password = crypt('localdev123', gen_salt('bf')),
  raw_app_meta_data = raw_app_meta_data || '{"provider":"email","providers":["email"]}'::jsonb
WHERE email = 'user@example.com';
```

Add a password field to the login screen gated on `SUPABASE_URL` containing `localhost` or `127.0.0.1` — it never appears in production.
