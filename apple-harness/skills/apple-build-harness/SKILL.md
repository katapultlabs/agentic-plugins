---
name: apple-build-harness
description: >
  Native Apple platform (iOS, macOS) build, test, and run harness for Claude Code.
  Use when the user asks to "build the app", "run tests", "run on simulator",
  "scaffold a new iOS project", "create an Xcode project", "set up build
  tooling", "diagnose build issues", "fix build errors", "make build",
  "make test", "make run", "console logs", or any task involving xcodebuild,
  iOS Simulator, SwiftUI, UIKit, AppKit, or native Swift/Objective-C development.
  Also activates for XcodeGen scaffolding, Makefile setup, agent-isolated builds,
  strict Swift 6 compiler settings, or Xcode toolchain troubleshooting.
---

# Apple Build Harness

Build, test, and run native iOS and macOS Xcode projects with agent-isolated builds, simulator auto-resolution, and strict Swift 6 defaults.

## Prerequisites

Verify before any build operation. Run `scripts/doctor.sh` or check manually.

**Required:**
- macOS with full Xcode install (not just Command Line Tools)
- `xcode-select -p` must point to `/Applications/Xcode.app/Contents/Developer`
- `xcodebuild`, `xcrun` available on PATH
- `python3` available on PATH (used by simulator auto-resolution)

**Recommended:**
- `xcodegen` for project scaffolding: `brew install xcodegen`
- `xcbeautify` for readable build output: `brew install xcbeautify`

**Fix common issue** — xcode-select pointing to CommandLineTools:
```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

Quick environment check:
```bash
bash <skill-path>/scripts/doctor.sh
```

## Setup for a Project

### One-command install (recommended)

From your project root (where the `.xcodeproj` or `.xcworkspace` is):

```bash
bash <skill-path>/../scripts/install.sh
```

This auto-detects your app name, scheme, and platform from the Xcode project, then:
- Copies `scripts/` (xcbuild.sh, resolve-sim.sh, doctor.sh, clean.sh, setup.sh)
- Generates a `Makefile` with your project's configuration filled in
- Merges harness entries into `.gitignore`
- Creates or appends to `CLAUDE.md` with build workflow reference

After install, verify:
```bash
make diagnose
make build
```

### Install with overrides

If auto-detection picks the wrong values, or you don't have an .xcodeproj yet:

```bash
bash <skill-path>/../scripts/install.sh --app-name Recipes --platform ios --scheme Recipes
```

### Preview without writing

```bash
bash <skill-path>/../scripts/install.sh --dry-run
```

### Reinstall / upgrade

```bash
bash <skill-path>/../scripts/install.sh --force
```

## Build Workflow

### Agent-Isolated Builds

Every build runs in a sandboxed environment under `build/` to prevent collisions when multiple agents or a human and agent work simultaneously:

```
build/
├── DerivedData/<AGENT_NAME>/     # Xcode build products
├── cache/<AGENT_NAME>/           # Clang/Swift module caches, SPM packages
│   ├── clang/ModuleCache/
│   ├── swift/ModuleCache/
│   └── swiftpm/
├── logs/<AGENT_NAME>/            # Build logs and .xcresult bundles
│   └── archive/                  # Rotated previous logs
└── tmp/<AGENT_NAME>/             # Temporary build files
```

The build wrapper (`scripts/xcbuild.sh`) overrides `TMPDIR` and all Xcode cache paths to point into this agent-specific tree. `HOME` is preserved so signing credentials and SSH keys remain accessible. This means:
- Two agents can build the same project at the same time
- A human building in Xcode won't corrupt an agent's DerivedData
- Each agent's logs and test results are separate and inspectable

**AGENT_NAME resolution order:**
1. `--agent` flag (when calling scripts directly)
2. `$AGENT_NAME` environment variable
3. Contents of `agents/current_name.txt` (if file exists)
4. Default: `CLAUDE`

### Building

```bash
# Recommended — via Makefile
make build

# With explicit agent name
AGENT_NAME=CLAUDE make build

# Direct script usage
bash scripts/xcbuild.sh --agent CLAUDE --action build -- \
  -scheme "{{APP_NAME}}" \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro" \
  -configuration Debug
```

**Strict compiler flags** — always use these (the Makefile sets them by default):

| Setting | Value | Why |
|---------|-------|-----|
| `GCC_TREAT_WARNINGS_AS_ERRORS` | `YES` | Catch C/ObjC issues at build time |
| `SWIFT_TREAT_WARNINGS_AS_ERRORS` | `YES` | No warnings in production code |
| `SWIFT_STRICT_CONCURRENCY` | `complete` | Full Swift 6 data-race safety |
| `SWIFT_VERSION` | `6.0` | Latest Swift language version |

### Testing

```bash
make test

# Or directly
bash scripts/xcbuild.sh --agent CLAUDE --action test -- \
  -scheme "{{APP_NAME}}" \
  -destination "platform=iOS Simulator,name=iPhone 16 Pro" \
  test
```

Test results are saved to `build/logs/<AGENT_NAME>/test.xcresult`.

### Running on iOS Simulator

```bash
# Auto-selects best available simulator
make run

# Build + run in one step
make build-and-run

# Specify a simulator
SIM_NAME="iPhone 16 Pro" make run
```

**Simulator auto-resolution** picks the best device by:
1. Prefer already-booted simulators (avoid boot latency)
2. Among booted: highest iOS runtime version
3. Among equal runtime: best iPhone model (Pro Max > Pro > Plus > standard > Mini > SE)
4. If nothing booted: same ranking among all available devices

See `references/simulator-resolution.md` for the full algorithm.

### Running macOS apps

```bash
PLATFORM=macos make build-and-run
```

macOS builds use `platform=macOS,arch=<host arch>` destination (auto-detected).

## Diagnostics

```bash
make diagnose
```

Prints:
- Project/workspace detection (.xcworkspace preferred over .xcodeproj)
- Active scheme and platform
- Agent name, DerivedData path, and log path
- Xcode version and developer directory
- Tool availability: xcrun, python3, xcodegen, xcbeautify

## Cleaning

```bash
# Clean current agent's artifacts only
make clean

# Clean ALL agents' build artifacts
make clean-all

# Script directly
bash scripts/clean.sh --agent CLAUDE
bash scripts/clean.sh --all
```

Cleaning removes DerivedData, caches, logs, and temp files for the specified scope.

## Console Logs

Stream simulator console output for debugging (iOS only):

```bash
make console
```

This runs `xcrun simctl spawn <device> log stream` in ndjson format, filtering out noisy system subsystems. Press Ctrl-C to stop. Useful for reading `print()`, `os_log`, and `NSLog` output from the running app.

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make help` | List available targets |
| `make diagnose` | Print build config and tool status |
| `make build` | Build with strict Swift 6 flags |
| `make test` | Run unit tests |
| `make run` | Launch app (assumes prior build) |
| `make build-and-run` | Build then launch |
| `make console` | Stream simulator console logs |
| `make clean` | Remove current agent's build artifacts |
| `make clean-all` | Remove all build artifacts |

## Gotchas

See `references/gotchas.md` for full details. The critical ones:

- **xcode-select wrong path**: Must point to Xcode.app, not CommandLineTools. Fix: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
- **DerivedData corruption**: Symptoms: stale errors, phantom build failures. Fix: `make clean` then rebuild. Agent isolation prevents cross-contamination.
- **SPM resolution failures**: Delete `build/cache/<AGENT_NAME>/swiftpm/` and rebuild.
- **Simulator not found**: Check `xcrun simctl list devices available`. If the target runtime isn't installed: Xcode > Settings > Platforms.
- **Code signing in CI/agent builds**: Add `CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO` to skip signing.
- **Swift 6 concurrency errors**: These are real data-race bugs. Do not downgrade `SWIFT_STRICT_CONCURRENCY` — fix the code. See `references/swift-conventions.md`.
- **"No such module" after SPM update**: Clean module caches: `rm -rf build/cache/<AGENT_NAME>/swift/ModuleCache build/cache/<AGENT_NAME>/clang/ModuleCache` then rebuild.

## Companion: Axiom

For deep iOS development knowledge beyond build tooling — Swift concurrency patterns, memory debugging, SwiftUI architecture, database migrations, performance profiling — install [Axiom](https://github.com/CharlesWiltgen/Axiom) alongside this plugin: `/plugin marketplace add CharlesWiltgen/Axiom`

## Credits

Inspired by [Paul Solt's](https://github.com/PaulSolt) App Creator toolkit and [Charles Wiltgen's](https://github.com/CharlesWiltgen) Axiom project. The agent-isolated build architecture, Makefile workflow, and simulator auto-resolution patterns originated in Paul's work at [Super Easy Apps](https://www.supereasyapps.com/).
