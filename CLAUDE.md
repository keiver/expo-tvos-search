# expo-tvos-search

Native tvOS search component wrapping SwiftUI `.searchable`. This is a library, not an app.

## Commands

```bash
npm run build          # TypeScript → build/
npm test               # Jest tests
npm run test:coverage  # Coverage report
```

## Conventions

- Conventional Commits with scopes: search, results, focus, marquee, validation, props, ios, types
- Target tvOS 15.0+. Use `@available` checks or custom shapes for 16.0+ APIs.
- Prop addition requires Expo Module registration (`Prop("name")` in ExpoTvosSearchModule.swift). See `/prop-workflow` skill.

## Quirks

- podspec version IS bumped by the release workflow (sed on ios/ExpoTvosSearch.podspec).
- Gesture handler management disables RN gesture recognizers when search field is focused. Skipped on simulator.
- `memories/` directory has detailed debugging history. Read `memories/CLAUDE-lessons-learned.md` when investigating bugs.

## Verification

After any change: `npm test && npm run build`
