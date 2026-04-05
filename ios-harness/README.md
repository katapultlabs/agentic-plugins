# iOS Harness

A Claude Code plugin for building, testing, and running native iOS and macOS Xcode projects autonomously.

## What it does

When this plugin is active, Claude Code can:

- **Build** native Swift/Objective-C projects with strict compiler flags (Swift 6, warnings-as-errors)
- **Test** with unit tests via xcodebuild, with isolated DerivedData per agent
- **Run** on the iOS Simulator with intelligent device auto-selection
- **Scaffold** new Xcode projects via XcodeGen templates
- **Diagnose** toolchain issues and common build failures
- **Isolate** builds so multiple agents (or human + agent) never collide on DerivedData

No manual Xcode interaction required. Claude follows a Makefile-driven workflow with shell scripts that handle simulator resolution, build isolation, and log management.

## Prerequisites

- macOS with Xcode (full install, not just Command Line Tools)
- `xcode-select` pointing to Xcode.app

Optional but recommended:
- `xcodegen` — for project scaffolding (`brew install xcodegen`)
- `xcbeautify` — for readable build output (`brew install xcbeautify`)

Run `scripts/setup.sh` to verify and install prerequisites.

## What's included

### Skill: `ios-build-harness`

Activates when you ask Claude to build, test, run, scaffold, or diagnose a native iOS or macOS project. Contains the full build workflow, Makefile target reference, and integration guidance.

### Scripts

| Script | Purpose |
|--------|---------|
| `setup.sh` | One-command environment verification and tool installation |
| `xcbuild.sh` | Agent-isolated xcodebuild wrapper with logging |
| `resolve-sim.sh` | Intelligent iOS Simulator auto-selection |
| `doctor.sh` | Toolchain diagnostics with remediation hints |
| `clean.sh` | Agent-scoped or full build artifact cleanup |

### Assets

| Asset | Purpose |
|-------|---------|
| `Makefile.template` | Drop-in Makefile with build/test/run targets |
| `claude-md-template.md` | CLAUDE.md section for your project |
| `gitignore-template` | iOS/macOS project .gitignore |
| `project-yml-template.yml` | XcodeGen project.yml for new projects |

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
- "Scaffold a new iOS SwiftUI app called Recipes"
- "Why is the build failing?"
- "Set up the Makefile for this project"

## Trigger phrases

The skill activates on: "build the app", "run tests", "run on simulator", "scaffold iOS project", "set up Xcode", "diagnose build", "fix build error", "make build", or any task involving xcodebuild, iOS Simulator, or native Swift development.
