---
name: apple-build-harness
description: >
  Native Apple platform (iOS, macOS) build, test, and run harness for Claude Code.
  Use when the user asks to "build the app", "run tests", "run on simulator",
  "set up build tooling", "diagnose build issues", "fix build errors", "make build",
  "make test", "make run", "console logs", "install the harness", or any task
  involving xcodebuild, iOS Simulator, SwiftUI, UIKit, AppKit, or native
  Swift/Objective-C development. Also activates for Makefile setup, agent-isolated
  builds, strict Swift 6 compiler settings, or Xcode toolchain troubleshooting.
---

# Apple Build Harness

Build, test, and run native iOS and macOS Xcode projects with agent-isolated builds, simulator auto-resolution, and strict Swift 6 defaults.

## Prerequisites

**Required:** macOS with full Xcode, `xcode-select -p` pointing to Xcode.app, `xcodebuild`, `xcrun`, `python3`.

**Recommended:** `xcbeautify` (`brew install xcbeautify`) for readable build output.

If `xcode-select` points to CommandLineTools: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`

Quick check: `bash scripts/doctor.sh`

## Setup

### Install into a project (one command)

From the project root (where `.xcodeproj` or `.xcworkspace` is):

```bash
bash <skill-path>/../scripts/install.sh
```

Auto-detects app name, scheme, and platform, then copies scripts, generates Makefile, merges .gitignore, and creates CLAUDE.md. Verify with `make diagnose && make build`.

### Override auto-detection

```bash
bash <skill-path>/../scripts/install.sh --app-name MyApp --platform ios --scheme MyApp
```

### Other install options

- `--dry-run` — preview without writing files
- `--force` — overwrite existing Makefile and scripts
- `--project-dir /path` — install into a different directory

## Build Workflow

### Agent-Isolated Builds

Builds are sandboxed under `build/<AGENT_NAME>/` so multiple agents (or human + agent) never collide:

```
build/
├── DerivedData/<AGENT_NAME>/   # Xcode build products
├── cache/<AGENT_NAME>/         # Module caches, SPM packages
├── logs/<AGENT_NAME>/          # Build logs + .xcresult bundles
└── tmp/<AGENT_NAME>/           # Temp files
```

`xcbuild.sh` overrides `TMPDIR` and all Xcode cache paths per agent. `HOME` is preserved (signing credentials stay accessible).

**AGENT_NAME resolves:** `--agent` flag > `$AGENT_NAME` env > `agents/current_name.txt` > default `CLAUDE`

### Building

```bash
make build                          # Build with strict Swift 6 flags
AGENT_NAME=AGENT_2 make build       # Explicit agent
```

Strict flags (set by default): `GCC_TREAT_WARNINGS_AS_ERRORS=YES`, `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES`, `SWIFT_STRICT_CONCURRENCY=complete`, `SWIFT_VERSION=6.0`

### Testing

```bash
make test
```

Results saved to `build/logs/<AGENT_NAME>/test.xcresult`.

### Running

```bash
make run                            # Launch on auto-selected simulator
make build-and-run                  # Build then launch
SIM_NAME="iPhone 16 Pro" make run   # Specific simulator
PLATFORM=macos make build-and-run   # macOS app
```

Simulator auto-resolution prefers: booted > highest iOS version > best iPhone model. See `references/simulator-resolution.md`.

### Console Logs

```bash
make console
```

Streams simulator console output (ndjson format) — captures `print()`, `os_log`, `NSLog`. Press Ctrl-C to stop. iOS only.

### Diagnostics

```bash
make diagnose     # Print config + run doctor checks
make clean        # Clean current agent's artifacts
make clean-all    # Clean all agents' artifacts
```

## Makefile Targets

| Target | Description |
|--------|-------------|
| `make build` | Build with strict Swift 6 flags |
| `make test` | Run unit tests |
| `make run` | Launch app (assumes prior build) |
| `make build-and-run` | Build then launch |
| `make console` | Stream simulator console logs |
| `make diagnose` | Print build config and tool status |
| `make clean` | Remove current agent's build artifacts |
| `make clean-all` | Remove all build artifacts |
| `make help` | List available targets |

## Gotchas

See `references/gotchas.md` for full details. Quick fixes:

- **xcode-select wrong path:** `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
- **DerivedData corruption:** `make clean && make build`
- **SPM cache stale:** `rm -rf build/cache/<AGENT_NAME>/swiftpm/ && make build`
- **Simulator not found:** `xcrun simctl list devices available` — install runtime in Xcode > Settings > Platforms
- **Code signing in agent builds:** Add `CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO`
- **Swift 6 concurrency errors:** Real bugs — fix the code, don't downgrade. See `references/swift-conventions.md`
- **"No such module":** `rm -rf build/cache/<AGENT_NAME>/{swift,clang}/ModuleCache && make build`

## Companion: Axiom

For deep iOS knowledge beyond build tooling — Swift concurrency patterns, memory debugging, SwiftUI architecture, database migrations — install [Axiom](https://github.com/CharlesWiltgen/Axiom): `/plugin marketplace add CharlesWiltgen/Axiom`

## Credits

Inspired by [Paul Solt's](https://github.com/PaulSolt) App Creator toolkit ([Super Easy Apps](https://www.supereasyapps.com/)) and [Charles Wiltgen's](https://github.com/CharlesWiltgen) Axiom project.
