# Simulator Resolution

## How auto-selection works

`resolve-sim.sh` queries `xcrun simctl list devices -j` and ranks all available iPhone simulators using a multi-factor scoring system.

## Ranking algorithm

Candidates are scored and sorted by these factors (highest priority first):

1. **Boot state** — Booted simulators rank higher (avoids boot latency)
2. **iOS version** — Highest runtime version wins (e.g., iOS 18.2 > iOS 18.0 > iOS 17.4)
3. **Model number** — Newest iPhone generation (e.g., iPhone 17 > iPhone 16)
4. **Model variant** — Within the same generation:

| Variant | Rank | Example |
|---------|------|---------|
| Pro Max | 6 | iPhone 16 Pro Max |
| Pro | 5 | iPhone 16 Pro |
| Plus | 4 | iPhone 16 Plus |
| Air | 3 | iPhone 16 Air |
| Standard | 2 | iPhone 16 |
| Mini | 1 | iPhone 16 Mini |
| SE / e | 0 | iPhone SE |

## Usage modes

### Auto mode (default)

```bash
bash scripts/resolve-sim.sh
# → platform=iOS Simulator,id=<UDID of best device>
```

Picks the single best simulator. Prefers an already-booted device to avoid boot delay.

### Named device

```bash
bash scripts/resolve-sim.sh --name "iPhone 16 Pro"
```

Filters to simulators whose name contains the search string (case-insensitive). Among matches, applies the same ranking. Useful when you need a specific screen size or device class.

### Direct UDID

```bash
bash scripts/resolve-sim.sh --udid 12345678-ABCD-1234-ABCD-123456789ABC
```

Bypasses all resolution. Returns `platform=iOS Simulator,id=<UDID>` directly. Use for CI or when you've already determined the exact device.

## Integration with Makefile

The Makefile calls `resolve-sim.sh` when `PLATFORM=ios`:

```makefile
DESTINATION = $(shell bash $(SCRIPTS_DIR)/resolve-sim.sh --name "$(SIM_NAME)" 2>/dev/null)
```

Override at invocation:
```bash
SIM_NAME="iPhone 16 Pro" make build
SIM_UDID="12345..." make build
```

## Troubleshooting

**"No available iPhone simulator found"**
- Check: `xcrun simctl list devices available | grep iPhone`
- If empty: Install a runtime in Xcode > Settings > Platforms

**Wrong simulator picked**
- Use `--name` to constrain: `bash scripts/resolve-sim.sh --name "iPhone 16"`
- Or get the UDID: `xcrun simctl list devices available` and use `--udid`

**Simulator won't boot**
- Kill zombies: `xcrun simctl shutdown all`
- Delete and recreate: `xcrun simctl delete unavailable`

## Testing the resolver

The script accepts pre-loaded JSON via `SIMCTL_LIST_JSON` env var for testing without a real Xcode installation:

```bash
SIMCTL_LIST_JSON='{"devices":{"com.apple.CoreSimulator.SimRuntime.iOS-18-2":[{"name":"iPhone 16 Pro","udid":"abc","isAvailable":true,"state":"Booted"}]}}' \
  bash scripts/resolve-sim.sh
```
