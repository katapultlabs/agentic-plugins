# Swift Conventions

## Strict build settings

The iOS Harness enforces these settings on every build:

| Setting | Value | Purpose |
|---------|-------|---------|
| `SWIFT_VERSION` | `6.0` | Latest Swift language version |
| `SWIFT_STRICT_CONCURRENCY` | `complete` | Full data-race safety checking |
| `SWIFT_TREAT_WARNINGS_AS_ERRORS` | `YES` | No warnings ship to production |
| `GCC_TREAT_WARNINGS_AS_ERRORS` | `YES` | Same for C/Objective-C code |

These are set in both the XcodeGen `project.yml` template and the Makefile build flags, so they apply regardless of how the project was created.

## Swift 6 strict concurrency

Swift 6 enables complete concurrency checking by default. `SWIFT_STRICT_CONCURRENCY=complete` makes this explicit even on projects that haven't fully migrated.

### Common errors and fixes

**"Sending 'self' risks a data race"**
```swift
// Before — captured mutable self in concurrent context
func fetchData() {
    Task {
        self.data = await api.fetch()  // Error
    }
}

// After — use @MainActor for UI-bound types
@MainActor
final class ViewModel: ObservableObject {
    func fetchData() {
        Task {
            self.data = await api.fetch()  // OK — MainActor-isolated
        }
    }
}
```

**"Non-sendable type captured in @Sendable closure"**
```swift
// Before
let formatter = DateFormatter()
Task {
    let str = formatter.string(from: date)  // Error — DateFormatter not Sendable
}

// After — create inside the closure or use a Sendable alternative
Task {
    let formatter = DateFormatter()
    let str = formatter.string(from: date)
}
```

**"Static property is not concurrency-safe"**
```swift
// Before
struct Constants {
    static let shared = Constants()  // Warning
}

// After
struct Constants: Sendable {
    static let shared = Constants()
    // Or use nonisolated(unsafe) if truly immutable after init
}
```

### Migration strategy

1. Start with `SWIFT_STRICT_CONCURRENCY=complete` (the harness default)
2. Fix errors one file at a time — prioritize model and networking layers
3. Use `@MainActor` for all UI-facing types (ViewModels, Controllers)
4. Mark immutable value types as `Sendable`
5. Use actors for mutable shared state
6. `nonisolated(unsafe)` is a last resort for legacy code — add a `// TODO: migrate` comment

Do **not** downgrade to `targeted` or `minimal` — the errors represent real data races.

## Project structure conventions

For XcodeGen projects:

```
Sources/
├── App.swift               # @main entry point
├── ContentView.swift       # Root view
├── Info.plist              # App metadata
├── Models/                 # Data models (Sendable value types)
├── Views/                  # SwiftUI views
├── ViewModels/             # @MainActor ObservableObjects
└── Services/               # Actors for async operations

Tests/
├── Info.plist
└── *Tests.swift

Resources/
└── Assets.xcassets/
    ├── AppIcon.appiconset/
    ├── AccentColor.colorset/
    └── Contents.json
```

## Recommended Xcode settings

These are set by the project.yml template:

- `CURRENT_PROJECT_VERSION: 1` — Increment on each build for TestFlight
- `MARKETING_VERSION: 1.0` — User-facing version string
- `ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon`
- `ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME: AccentColor`
