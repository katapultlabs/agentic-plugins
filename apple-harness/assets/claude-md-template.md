## Apple Build Harness

This project uses the Apple Harness plugin for Claude Code. Build, test, and run via Makefile.

### Quick reference

```bash
make build          # Build with strict Swift 6 flags
make test           # Run unit tests
make run            # Launch on simulator
make build-and-run  # Build then launch
make diagnose       # Print build config + tool status
make clean          # Clean current agent's artifacts
```

### Project details

- **App name:** {{APP_NAME}}
- **Platform:** {{PLATFORM}}
- **Bundle ID:** {{BUNDLE_ID}}

### Build conventions

- All builds use `SWIFT_STRICT_CONCURRENCY=complete` and `SWIFT_TREAT_WARNINGS_AS_ERRORS=YES`
- Builds are agent-isolated under `build/DerivedData/<AGENT_NAME>/`
- Always run `make build` after code changes to verify — do not rely on Xcode's incremental state
- Run `make test` to verify tests pass before committing
- If the build fails with stale errors, run `make clean` and rebuild
