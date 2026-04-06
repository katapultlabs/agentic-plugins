---
name: setup
description: Verify and install prerequisites — check Xcode, install optional tools, boot a simulator, and configure project build tooling.
---

# Setup Environment

Run the setup script to verify and install all prerequisites for Apple platform development.

## Steps

1. Run the setup script:
   ```bash
   bash scripts/setup.sh
   ```
   This checks macOS, Xcode, xcodebuild, xcrun, python3, and optionally installs xcodegen and xcbeautify.

2. If this is a new project, copy the harness files:
   ```bash
   cp -r <plugin-path>/scripts/ ./scripts/
   cp <plugin-path>/assets/Makefile.template ./Makefile
   cp <plugin-path>/assets/gitignore-template ./.gitignore
   ```

3. Edit the Makefile header variables:
   - `APP_NAME` — your app name
   - `PLATFORM` — `ios` or `macos`
   - `SCHEME` — your Xcode scheme (defaults to APP_NAME)

4. Verify the setup:
   ```bash
   make diagnose
   make build
   ```

## Non-interactive mode

For CI or scripted environments:
```bash
bash scripts/setup.sh --yes      # Auto-install optional tools
bash scripts/setup.sh --check    # Check only, no installs
```
