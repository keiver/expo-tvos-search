# Adding New Props

Read this skill when adding or modifying props on the TvosSearchView component.

## 9-Step Checklist

Every step is required. Missing Step 4 is the most common mistake: props will be silently ignored.

### 1. TypeScript Interface (`src/index.tsx`)
Add to `TvosSearchViewProps` with JSDoc, type, `@default` tag. Group with related props.

### 2. Swift ViewModel (`ios/SearchViewModel.swift`)
Add property to `SearchViewModel`. Use `@Published` if it changes dynamically. Default must match TypeScript.

### 3. Swift View Property (`ios/ExpoTvosSearchView.swift:328-469`)
Add property to `ExpoTvosSearchView` with `didSet` that syncs to `viewModel`. Default must match.

### 4. Expo Module Registration (`ios/ExpoTvosSearchModule.swift:14-134`) -- CRITICAL
Register with `Prop("propName")` closure. Include type conversion and value clamping.

Type conversions: JS `number` → Swift `Double` → `CGFloat`. JS `boolean` → `Bool`. JS `string` → `String`.

### 5. Pass to the Card (if it affects card rendering)
Add to `SearchResultCardStyle`, to the `cardStyle` builder in `SearchViewModel`, then read it as `style.name` in `SearchResultCard`. The card takes one style value, not a parameter list.

### 6. Add Unit Tests (`src/__tests__/index.test.tsx`)
Test prop acceptance, various values, default behavior when omitted. Update defaults documentation test.

### 7. Run Tests
`npm test`

### 8. Build Library
`npm run build`

### 9. Test in Demo App
Update demo app, `npm run prebuild`, launch on tvOS simulator.

## Adding an Event Instead

1. Payload interface plus optional callback prop in `src/index.tsx`
2. Closure property and the method firing it in `ios/SearchViewModel.swift`
3. `EventDispatcher` named exactly as the JS prop in `ios/ExpoTvosSearchView.swift`, wired in `setupView()`, and repeated in the non-tvOS fallback class
4. Name added to the single `Events(...)` call in `ios/ExpoTvosSearchModule.swift` -- missing means never delivered
5. Payload test in `src/__tests__/events.test.ts`, behaviour test in `ios/Tests/SearchViewModelTests.swift`
6. Events table row in README.md

`ExpoTvosSearchView.swift` and `ExpoTvosSearchModule.swift` sit outside `Package.swift`, so `npm test` never compiles them. Only an app build does.

## Validation Before Done

- [ ] JSDoc with `@default` on TypeScript interface
- [ ] Default values match across TypeScript, ViewModel, and View
- [ ] `Prop("name")` registered in ExpoTvosSearchModule
- [ ] Value clamping implemented for numeric props
- [ ] Tests pass, build succeeds
- [ ] tvOS 15.0+ compatible (no `UnevenRoundedRectangle`, use `SelectiveRoundedRectangle`)

## Common Mistakes

- Forgetting Step 4 (silent failure, no error)
- Mismatched defaults between TS and Swift
- Wrong type conversion (JS number arrives as `Double`, not `CGFloat`)
- Using tvOS 16.0+ APIs without `@available` checks
