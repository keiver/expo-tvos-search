---
paths:
  - "ios/**/*.swift"
---

# Swift/tvOS Rules

- Target tvOS 15.0+. Never use `UnevenRoundedRectangle` (16.0+). Use `SelectiveRoundedRectangle` from `SearchResultCard.swift`.
- Use `@available(tvOS 16.0, *)` with fallbacks when newer APIs are unavoidable.
- Validation: clamp out-of-range values, truncate long strings, emit `onValidationWarning` for non-fatal issues. Only fatal errors use `onError`.
- Hex colors: use `Color(hex:)` extension which calls `HexColorParser.parse()`. Max input 20 chars.
- Async animation: use `.task(id:)` pattern, not manual `Task` management with `onChange`.
- Props must be registered in `ExpoTvosSearchModule.swift` via `Prop("name")` or they are silently ignored.
