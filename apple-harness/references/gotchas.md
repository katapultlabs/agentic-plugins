# Common Gotchas

Battle-tested fixes for Xcode and iOS build issues encountered during agent-assisted development.

## xcode-select pointing to Command Line Tools

**Symptom:** `xcodebuild` fails with "unable to find a destination matching the provided destination specifier" or "no developer directory found."

**Cause:** `xcode-select -p` returns `/Library/Developer/CommandLineTools` instead of the full Xcode app.

**Fix:**
```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

**Verify:** `xcode-select -p` should show `/Applications/Xcode.app/Contents/Developer`

## DerivedData corruption

**Symptom:** Stale build errors that don't match the current source. Phantom "file not found" errors. Incremental builds producing wrong results.

**Cause:** DerivedData contains cached artifacts from a previous build state. Common when switching branches, changing build settings, or after Xcode updates.

**Fix:**
```bash
make clean      # Agent-scoped
make clean-all  # Nuclear option
make build      # Rebuild from scratch
```

**Prevention:** Agent isolation (`xcbuild.sh`) keeps each agent's DerivedData separate, so human Xcode usage won't corrupt agent builds.

## Swift Package Manager resolution failures

**Symptom:** "Package resolution failed" or "unable to resolve dependencies" during build.

**Cause:** Stale SPM cache, network issues, or version conflicts.

**Fix:**
```bash
# Remove the agent's SPM cache
rm -rf build/cache/<AGENT_NAME>/swiftpm/
make build
```

If that doesn't work:
```bash
# Also remove the shared Package.resolved
rm -f Package.resolved
make build
```

## "No such module" after dependency update

**Symptom:** Build fails with "No such module 'SomePackage'" even though Package.resolved includes it.

**Cause:** Stale Clang or Swift module caches pointing to old locations.

**Fix:**
```bash
rm -rf build/cache/<AGENT_NAME>/clang/ModuleCache
rm -rf build/cache/<AGENT_NAME>/swift/ModuleCache
make build
```

## Simulator not found

**Symptom:** `resolve-sim.sh` exits with "No available iPhone simulator found" or the Makefile fails to determine a destination.

**Cause:** No iOS simulator runtime installed, or the requested device name doesn't match any available simulator.

**Fix:**
1. Check what's available: `xcrun simctl list devices available`
2. If no iPhones listed: Xcode > Settings > Platforms > download an iOS runtime
3. If the name doesn't match: use the exact name from `simctl list`, or use `SIM_NAME=auto` for auto-selection

## Simulator won't boot

**Symptom:** `xcrun simctl boot` hangs or errors.

**Fix:**
```bash
xcrun simctl shutdown all            # Kill zombie sims
xcrun simctl delete unavailable      # Remove broken devices
xcrun simctl list devices available  # Verify what remains
```

Then boot a fresh one:
```bash
xcrun simctl boot "<device UDID>"
```

## Code signing errors in agent builds

**Symptom:** "Signing requires a development team" or "No signing certificate" during agent/CI builds.

**Cause:** Agents don't have access to developer certificates or provisioning profiles.

**Fix:** Add these flags to skip signing (fine for debug/simulator builds):
```
CODE_SIGN_IDENTITY=""
CODE_SIGNING_REQUIRED=NO
CODE_SIGNING_ALLOWED=NO
```

The Makefile does not set these by default because signed builds are needed for device deployment. Add them manually for CI or agent-only workflows.

## Swift 6 concurrency errors

**Symptom:** "Sending 'self' risks a data race", "Non-sendable type captured", etc.

**Cause:** The harness enforces `SWIFT_STRICT_CONCURRENCY=complete`. These are real data-race bugs, not false positives.

**Fix:** See `references/swift-conventions.md` for migration patterns. Key principles:
- Use `@MainActor` for UI types
- Mark value types as `Sendable`
- Use actors for shared mutable state
- Do **not** downgrade to `targeted` or `minimal`

## xcbeautify not installed

**Symptom:** Build output is raw xcodebuild text (verbose, hard to read).

**Cause:** `xcbeautify` is not installed. The harness falls back to `cat` (raw output).

**Fix:**
```bash
brew install xcbeautify
```

Build functionality is unaffected — this is cosmetic only.

## Xcode version mismatch

**Symptom:** "The selected Xcode (version X) does not support the requested deployment target (iOS Y)."

**Cause:** Project targets a newer iOS version than the installed Xcode supports.

**Fix:**
1. Update Xcode from the App Store
2. Or lower `DEPLOYMENT_TARGET` in `project.yml` to match your Xcode's maximum supported version
3. Check: `xcodebuild -version` and compare against deployment target

## Multiple Xcode installations

**Symptom:** Builds use the wrong Xcode version.

**Fix:**
```bash
# List installed Xcodes
ls /Applications/Xcode*.app

# Switch to the one you want
sudo xcode-select -s /Applications/Xcode-16.2.app/Contents/Developer

# Verify
xcode-select -p
xcodebuild -version
```
