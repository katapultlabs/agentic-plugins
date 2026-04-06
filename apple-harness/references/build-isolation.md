# Build Isolation

## Why agent isolation matters

Xcode stores intermediate build products, module caches, and SPM packages in DerivedData. When two processes (two agents, or a human in Xcode + an agent on CLI) write to the same DerivedData simultaneously, you get:

- Phantom "file not found" or "module not found" errors
- Stale object files causing incorrect behavior
- SPM package resolution races
- Corrupted `.xcresult` bundles

Agent isolation eliminates all of these by giving each builder its own sandboxed tree.

## How it works

`xcbuild.sh` creates a per-agent directory structure under `build/`:

```
build/
├── DerivedData/CLAUDE/       # Xcode build products
├── cache/CLAUDE/
│   ├── clang/ModuleCache/    # Clang module cache
│   ├── swift/ModuleCache/    # Swift module cache
│   └── swiftpm/              # SPM packages + resolved sources
├── logs/CLAUDE/
│   ├── build.log             # Latest build log
│   ├── test.log              # Latest test log
│   ├── build.xcresult        # Latest build result bundle
│   └── archive/              # Rotated previous logs
├── tmp/CLAUDE/               # Temp files
└── home/CLAUDE/              # Sandboxed HOME for Xcode
```

The script overrides these environment variables before calling xcodebuild:

| Variable | Points to |
|----------|-----------|
| `TMPDIR` | `build/tmp/<agent>/` |
| `XDG_CACHE_HOME` | `build/cache/<agent>/xdg/` |

Note: `HOME` is **not** overridden — signing credentials, SSH keys, `.gitconfig`, and provisioning profiles in your real home directory remain accessible.

And passes these as xcodebuild flags:

| Flag | Points to |
|------|-----------|
| `-derivedDataPath` | `build/DerivedData/<agent>/` |
| `-clonedSourcePackagesDirPath` | `build/cache/<agent>/swiftpm/SourcePackages/` |
| `-resultBundlePath` | `build/logs/<agent>/<action>.xcresult` |
| `CLANG_MODULE_CACHE_PATH` | `build/cache/<agent>/clang/ModuleCache/` |
| `SWIFT_MODULE_CACHE_PATH` | `build/cache/<agent>/swift/ModuleCache/` |

## AGENT_NAME resolution

The agent name determines which subdirectory tree is used. It resolves in order:

1. **`--agent` flag** — highest priority when calling scripts directly
2. **`$AGENT_NAME` environment variable** — set by the caller or Makefile
3. **`agents/current_name.txt`** — file in project root, persists across sessions
4. **Default: `CLAUDE`** — fallback when nothing else is configured

To switch agents:
```bash
echo "AGENT_2" > agents/current_name.txt
```

Or pass it explicitly:
```bash
AGENT_NAME=AGENT_2 make build
```

## Concurrent build scenarios

| Scenario | Result |
|----------|--------|
| Human in Xcode + Claude on CLI | Safe — Xcode uses its own DerivedData, Claude uses `build/DerivedData/CLAUDE/` |
| Two Claude agents | Safe — each uses its own AGENT_NAME |
| Same agent, two terminals | Unsafe — same DerivedData, same as opening two Xcode builds. Avoid this. |

## Log rotation

Each build archives the previous log and result bundle with a timestamp:
```
build/logs/CLAUDE/archive/build-20260405143210.log
build/logs/CLAUDE/archive/build-20260405143210.xcresult
```

This keeps history without accumulating in the main log directory.

## Cleaning

```bash
make clean           # Removes build/{DerivedData,cache,logs,tmp,home}/CLAUDE/
make clean-all       # Removes entire build/ directory
```

Agent-scoped cleaning is the default. Full clean is available when you need a fresh start for everyone.
