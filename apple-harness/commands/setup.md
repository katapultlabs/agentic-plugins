---
name: setup
description: Install Apple Harness into an Xcode project — auto-detects app name, scheme, and platform, then copies scripts, Makefile, and .gitignore.
---

# Setup Apple Harness

Install the build harness into an existing Xcode project with one command.

## Quick start

From the project root (where the `.xcodeproj` or `.xcworkspace` is):

```bash
bash <skill-path>/../scripts/install.sh
```

This auto-detects your app name, scheme, and platform, then sets up everything.

## What it does

1. Detects `APP_NAME` from the `.xcodeproj` or `.xcworkspace` filename
2. Detects `SCHEME` via `xcodebuild -list` (picks first non-test scheme)
3. Detects `PLATFORM` from `SDKROOT` in `project.pbxproj` (ios or macos)
4. Copies `scripts/` into the project (xcbuild.sh, resolve-sim.sh, doctor.sh, clean.sh, setup.sh)
5. Generates a `Makefile` with detected values filled in
6. Merges harness entries into `.gitignore`
7. Creates or appends Apple Harness section to `CLAUDE.md`

## Override auto-detection

```bash
bash <skill-path>/../scripts/install.sh --app-name Recipes --platform ios --scheme Recipes
```

## Options

| Flag | Purpose |
|------|---------|
| `--project-dir DIR` | Project directory (default: current directory) |
| `--app-name NAME` | Override app name |
| `--scheme NAME` | Override scheme |
| `--platform PLAT` | Override platform (ios, macos) |
| `--dry-run` | Preview without writing files |
| `--force` | Overwrite existing Makefile and scripts |

## After install

```bash
make diagnose       # Verify toolchain
make build          # Build the app
make test           # Run tests
make run            # Launch on simulator
```
