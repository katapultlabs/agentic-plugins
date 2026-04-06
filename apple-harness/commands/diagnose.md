---
name: diagnose
description: Run environment diagnostics — verify Xcode toolchain, check tool availability, list simulators, and print build configuration.
---

# Diagnose Environment

Run the doctor script to verify all prerequisites, then print the current build configuration.

## Steps

1. Run `bash scripts/doctor.sh` from the project root to check:
   - Xcode installation and `xcode-select` path
   - Required tools: xcodebuild, xcrun, python3
   - Recommended tools: xcodegen, xcbeautify
   - Available iOS Simulators (count and boot status)

2. If a Makefile exists, also run `make diagnose` to show:
   - App name, scheme, platform, configuration
   - Workspace/project detection
   - Agent name and isolation paths

3. Report any issues with specific remediation commands.

## Common fixes

- **xcode-select wrong path**: `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
- **No simulators**: Xcode > Settings > Platforms > download iOS runtime
- **Missing python3**: `brew install python3`
- **Missing xcbeautify**: `brew install xcbeautify`
