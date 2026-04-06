---
name: fix-build
description: Guided build failure diagnosis — analyze xcodebuild errors, suggest fixes, clean caches, and rebuild.
---

# Fix Build Failures

Diagnose and fix Xcode build failures systematically.

## Diagnosis workflow

1. **Read the build log** — Check `build/logs/<AGENT_NAME>/build.log` for the actual error. Look for the FIRST error, not subsequent cascading failures.

2. **Classify the error**:
   - **"No such module"** → SPM cache stale. Fix: `rm -rf build/cache/<AGENT_NAME>/swiftpm/ && make build`
   - **"Cannot find in scope"** → Missing import or typo. Check imports and spelling.
   - **"Sending risks data race" / "Non-sendable"** → Swift 6 concurrency error. These are real bugs — see `references/swift-conventions.md`.
   - **"Unable to resolve destination"** → Simulator not found. Run `xcrun simctl list devices available`.
   - **"Signing requires a development team"** → Add `CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO` to build flags for debug/simulator builds.
   - **Linker errors** → Missing framework or duplicate symbols. Check target dependencies.
   - **Stale/phantom errors** → DerivedData corruption. Fix: `make clean && make build`

3. **If the error is unclear**, run diagnostics:
   ```bash
   make diagnose
   bash scripts/doctor.sh
   ```

4. **Clean and rebuild** as a last resort:
   ```bash
   make clean      # Agent-scoped
   make build      # Fresh build
   ```

5. **Nuclear option** (removes ALL agents' artifacts):
   ```bash
   make clean-all
   make build
   ```

## After fixing

Always run `make build` to verify the fix, then `make test` to ensure no regressions.
