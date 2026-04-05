---
name: ios-build-harness
description: >
  Native iOS and macOS Xcode build, test, and run harness for Claude Code.
  Use when the user asks to "build the app", "run tests", "run on simulator",
  "scaffold a new iOS project", "create an Xcode project", "set up build
  tooling", "diagnose build issues", "fix build errors", "make build",
  "make test", "make run", or any task involving xcodebuild, iOS Simulator,
  SwiftUI, UIKit, AppKit, or native Swift/Objective-C development. Also
  activates for XcodeGen scaffolding, Makefile setup, agent-isolated builds,
  strict Swift 6 compiler settings, or Xcode toolchain troubleshooting.
---

# iOS Build Harness

Build, test, and run native iOS and macOS Xcode projects with agent-isolated builds, simulator auto-resolution, and strict Swift 6 defaults.

## Prerequisites

Verify before any build operation. Run `scripts/doctor.sh` or check manually.

**Required:**
- macOS with full Xcode install (not just Command Line Tools)
- `xcode-select -p` must point to `/Applications/Xcode.app/Contents/Developer`
- `xcodebuild`, `xcrun` available on PATH

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

### New project with XcodeGen

1. Install xcodegen: `brew install xcodegen`
2. Copy `assets/project-yml-template.yml` to your project as `project.yml`
3. Replace placeholders: `{{APP_NAME}}`, `{{BUNDLE_ID}}`, `{{DEPLOYMENT_TARGET}}`
4. Generate the Xcode project: `xcodegen generate`
5. Copy `assets/Makefile.template` to your project as `Makefile`
6. Edit the Makefile header variables: `APP_NAME`, `PLATFORM`
7. Copy `assets/gitignore-template` as `.gitignore`
8. Run `make diagnose` to verify, then `make build`

### Existing project

1. Copy `assets/Makefile.template` to your project as `Makefile`
2. Edit the header variables to match your project (scheme, platform, etc.)
3. Copy `assets/gitignore-template` and merge with your existing `.gitignore`
4. Run `make diagnose` to verify

### Add CLAUDE.md section

Adapt `assets/claude-md-template.md` into your project's CLAUDE.md. Replace `{{APP_NAME}}`, `{{PLATFORM}}`, and `{{BUNDLE_ID}}` placeholders.

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

The build wrapper (`scripts/xcbuild.sh`) overrides `HOME`, `TMPDIR`, and all Xcode cache paths to point into this agent-specific tree. This means:
- Two agents can build the same project at the same time
- A human building in Xcode won't corrupt an agent's DerivedData
- Each agent's logs and test results are separate and inspectable

**AGENT_NAME resolution order:**
1. `$AGENT_NAME` environment variable
2. Contents of `agents/current_name.txt` (if file exists)
3. Default: `CLAUDE`

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

macOS builds use `platform=macOS,arch=arm64` destination.

## Diagnostics

```bash
make diagnose
```

Prints:
- Project/workspace detection (.xcworkspace preferred over .xcodeproj)
- Active scheme and platform
- Simulator destination (iOS) or macOS arch
- Agent name and isolation paths
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

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make help` | List available targets |
| `make diagnose` | Print build config and tool status |
| `make build` | Build with strict Swift 6 flags |
| `make test` | Run unit tests |
| `make run` | Launch app (assumes prior build) |
| `make build-and-run` | Build then launch |
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

## Credits

Inspired by [Paul Solt's](https://github.com/PaulSolt) App Creator toolkit. The agent-isolated build architecture, Makefile workflow, and simulator auto-resolution patterns originated in his work at [Super Easy Apps](https://www.supereasyapps.com/).
