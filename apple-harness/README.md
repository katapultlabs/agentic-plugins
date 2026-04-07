# Apple Harness

A Claude Code plugin for building, testing, and running native Apple platform apps (iOS, macOS) autonomously.

## What it does

When this plugin is active, Claude Code can:

- **Build** native Swift/Objective-C projects with strict compiler flags (Swift 6, warnings-as-errors)
- **Test** with unit tests via xcodebuild, with isolated DerivedData per agent
- **Run** on the iOS Simulator with intelligent device auto-selection
- **Diagnose** toolchain issues and common build failures
- **Isolate** builds so multiple agents (or human + agent) never collide on DerivedData
- **Capture** simulator console logs for debugging

No manual Xcode interaction required. Claude follows a Makefile-driven workflow with shell scripts that handle simulator resolution, build isolation, and log management.

## Quick Start

Once the plugin is installed, ask Claude from your Xcode project root:

> "Set up the Apple build harness for this project"

Claude will run the installer, which auto-detects your app name, scheme, and platform from the `.xcodeproj`, then sets up scripts, Makefile, .gitignore, and CLAUDE.md. After install:

```bash
make build          # Build with strict Swift 6 flags
make test           # Run unit tests
make run            # Launch on simulator
make build-and-run  # Build then launch
make console        # Stream simulator console logs
make diagnose       # Verify toolchain and config
make clean          # Clean build artifacts
```

## Prerequisites

- macOS with Xcode (full install, not just Command Line Tools)
- `xcode-select` pointing to Xcode.app
- `python3` (used by simulator auto-resolution)

Optional but recommended:
- `xcbeautify` — for readable build output (`brew install xcbeautify`)

## What's included

### Skill: `apple-build-harness`

Activates when you ask Claude to build, test, run, or diagnose a native iOS or macOS project. Contains the full build workflow, Makefile target reference, and integration guidance.

### Commands

| Command | Description |
|---------|-------------|
| `/apple-harness:setup` | Install harness into an Xcode project (auto-detect + copy) |
| `/apple-harness:diagnose` | Run environment diagnostics and verify toolchain |
| `/apple-harness:fix-build` | Guided build failure diagnosis workflow |

### Scripts

| Script | Purpose |
|--------|---------|
| `install.sh` | One-command project setup with auto-detection |
| `xcbuild.sh` | Agent-isolated xcodebuild wrapper with logging |
| `resolve-sim.sh` | Intelligent iOS Simulator auto-selection |
| `doctor.sh` | Toolchain diagnostics with remediation hints |
| `clean.sh` | Agent-scoped or full build artifact cleanup |
| `setup.sh` | Environment verification and optional tool installation |

### Assets

| Asset | Purpose |
|-------|---------|
| `Makefile.template` | Drop-in Makefile with build/test/run/console targets |
| `claude-md-template.md` | CLAUDE.md section for your project |
| `gitignore-template` | iOS/macOS project .gitignore |
| `project-yml-template.yml` | XcodeGen project.yml reference template |

### References

| Reference | Topic |
|-----------|-------|
| `build-isolation.md` | How agent-isolated builds work |
| `simulator-resolution.md` | Simulator auto-selection algorithm |
| `swift-conventions.md` | Swift 6 strict concurrency and build settings |
| `gotchas.md` | Common Xcode/iOS build issues and fixes |

## Usage

Once installed, just ask Claude:

- "Build the app"
- "Run the tests"
- "Run it on the simulator"
- "Why is the build failing?"
- "Show me the simulator console logs"
- "Clean the build and start fresh"

## Companion Plugins

**Apple Harness** handles the build pipeline — how to build, test, and run your app. For deep iOS development knowledge (patterns, debugging, architecture), we recommend also installing:

### [Axiom](https://github.com/CharlesWiltgen/Axiom) by Charles Wiltgen

175+ battle-tested skills covering the entire iOS development lifecycle:
- Swift 6 concurrency patterns, actors, Sendable
- Memory leak detection and Instruments profiling workflows
- SwiftUI architecture, navigation, layout, and performance
- Database migration safety (Core Data, SwiftData, GRDB)
- 38 autonomous agents (build-fixer, memory-auditor, concurrency-auditor, etc.)
- App Store submission checklists

Install: `/plugin marketplace add CharlesWiltgen/Axiom` or `npx axiom-mcp` for MCP clients.

Apple Harness and Axiom are complementary — use both for the most capable AI-assisted native Apple development setup.

## Credits & Inspiration

This plugin was inspired by and built upon the foundational work of **[Paul Solt](https://github.com/PaulSolt)** ([Super Easy Apps](https://www.supereasyapps.com/)) whose [App Creator](https://github.com/PaulSolt/app-creator) toolkit pioneered agent-isolated builds, Makefile-driven xcodebuild workflows, intelligent simulator auto-resolution, and doctor/diagnose diagnostics for AI-assisted Xcode development.

The console log capture feature was inspired by **[Charles Wiltgen's](https://github.com/CharlesWiltgen)** xclog tool from the [Axiom](https://github.com/CharlesWiltgen/Axiom) project.

Full credit and gratitude to both for sharing their work openly.
