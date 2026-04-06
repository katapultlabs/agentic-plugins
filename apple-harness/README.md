# Apple Harness

A Claude Code plugin for building, testing, and running native Apple platform apps (iOS, macOS) autonomously.

## What it does

When this plugin is active, Claude Code can:

- **Build** native Swift/Objective-C projects with strict compiler flags (Swift 6, warnings-as-errors)
- **Test** with unit tests via xcodebuild, with isolated DerivedData per agent
- **Run** on the iOS Simulator with intelligent device auto-selection
- **Scaffold** new Xcode projects via XcodeGen templates
- **Diagnose** toolchain issues and common build failures
- **Isolate** builds so multiple agents (or human + agent) never collide on DerivedData
- **Capture** simulator console logs for debugging

No manual Xcode interaction required. Claude follows a Makefile-driven workflow with shell scripts that handle simulator resolution, build isolation, and log management.

## Prerequisites

- macOS with Xcode (full install, not just Command Line Tools)
- `xcode-select` pointing to Xcode.app
- `python3` (used by simulator auto-resolution)

Optional but recommended:
- `xcodegen` — for project scaffolding (`brew install xcodegen`)
- `xcbeautify` — for readable build output (`brew install xcbeautify`)

Run `scripts/setup.sh` to verify and install prerequisites.

## What's included

### Skill: `apple-build-harness`

Activates when you ask Claude to build, test, run, scaffold, or diagnose a native iOS or macOS project. Contains the full build workflow, Makefile target reference, and integration guidance.

### Commands

| Command | Description |
|---------|-------------|
| `/apple-harness:diagnose` | Run environment diagnostics and verify toolchain |
| `/apple-harness:fix-build` | Guided build failure diagnosis workflow |
| `/apple-harness:setup` | Verify and install prerequisites |

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
| `Makefile.template` | Drop-in Makefile with build/test/run/console targets |
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
- "Show me the simulator console logs"

## Trigger phrases

The skill activates on: "build the app", "run tests", "run on simulator", "scaffold iOS project", "set up Xcode", "diagnose build", "fix build error", "make build", "console logs", or any task involving xcodebuild, iOS Simulator, or native Swift development.

## Companion Plugins

**Apple Harness** handles the build pipeline — how to build, test, and run your app. For deep iOS development knowledge (patterns, debugging, architecture), we recommend also installing:

### [Axiom](https://github.com/CharlesWiltgen/Axiom) by Charles Wiltgen

175+ battle-tested skills covering the entire iOS development lifecycle:
- Swift 6 concurrency patterns, actors, Sendable (950+ line guides with code patterns)
- Memory leak detection and Instruments profiling workflows
- SwiftUI architecture, navigation, layout, and performance
- Database migration safety (Core Data, SwiftData, GRDB)
- 38 autonomous agents (build-fixer, memory-auditor, concurrency-auditor, etc.)
- Console log capture via xclog
- App Store submission checklists

Install: `/plugin marketplace add CharlesWiltgen/Axiom` or `npx axiom-mcp` for MCP clients.

Apple Harness and Axiom are complementary — use both for the most capable AI-assisted iOS development setup.

## Credits & Inspiration

This plugin was inspired by and built upon the foundational work of **[Paul Solt](https://github.com/PaulSolt)** and his [App Creator](https://github.com/PaulSolt/app-creator) toolkit (v0.9.8). Paul's original system — a three-part skill set comprising `app-creator`, `xcode-makefiles`, and `simple-tasks` — pioneered several of the key ideas in this plugin, including:

- **Agent-isolated builds** with per-agent DerivedData, caches, and logs
- **Makefile-driven xcodebuild workflows** with strict Swift compiler defaults
- **Intelligent simulator auto-resolution** with model and runtime ranking
- **XcodeGen-based project scaffolding** with platform-specific templates
- **Doctor/diagnose diagnostics** for Xcode toolchain verification

Paul is an experienced iOS developer, educator, and the founder of **[Super Easy Apps](https://www.supereasyapps.com/)** — he builds tools that make native iOS and macOS development more accessible, especially for AI-assisted workflows. If you're building native Apple apps and want hands-on guidance or deeper tooling, check out his work:

- **Website:** [supereasyapps.com](https://www.supereasyapps.com/)
- **GitHub:** [github.com/PaulSolt](https://github.com/PaulSolt)
- **Email:** Paul@SuperEasyApps.com

The console log capture feature was inspired by **[Charles Wiltgen's](https://github.com/CharlesWiltgen)** xclog tool from the [Axiom](https://github.com/CharlesWiltgen/Axiom) project.

We reimagined these toolkits from first principles for the Katapult plugin marketplace — but the core architecture and the insight that AI agents need build isolation to work reliably alongside humans came directly from Paul's and Charles's work. Full credit and gratitude to both for sharing openly.
