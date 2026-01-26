# Development Memory Bank

> **Category:** Development
> **Keywords:** setup, build, release, CI, npm, workflow, GitHub Actions
> **Last Updated:** 2026-01-26

## Quick Reference

- **Build:** `npm run build` (tsc → `build/`)
- **Test:** `npm test` | `npm run test:watch` | `npm run test:coverage`
- **Clean:** `npm run clean` (rm -rf build)
- **Release:** Add version label to PR → merge → automated publish
- **CI:** `test-pr.yml` (on PR) + `release.yml` (on merge to main)

---

## Build Commands

| Command | What it does |
|---------|-------------|
| `npm run build` | Runs `tsc`, outputs to `build/` directory |
| `npm test` | Runs Jest test suite |
| `npm run test:watch` | Jest in watch mode |
| `npm run test:coverage` | Jest with coverage report (80% threshold) |
| `npm run clean` | Deletes `build/` directory |
| `npm run prepublishOnly` | Runs clean + build (triggered automatically by npm publish) |

---

## Package Configuration

**Entry points (`package.json`):**
```json
{
  "main": "build/index.js",        // CommonJS output (Node/bundlers)
  "types": "build/index.d.ts",     // TypeScript declarations
  "react-native": "src/index.tsx"  // React Native bundler uses source directly
}
```

**Conditional exports:**
```json
{
  "exports": {
    ".": {
      "types": "./build/index.d.ts",
      "react-native": "./src/index.tsx",
      "default": "./build/index.js"
    }
  }
}
```

**Published files:** `build/`, `src/`, `ios/`, `expo-module.config.json`, `README.md`, `CHANGELOG.md`, `LICENSE`

**Peer dependencies:** Expo >=51.0.0, expo-modules-core >=1.0.0, React >=18.0.0, react-native (optional)

---

## Release Automation

Releases are fully automated via GitHub Actions. No manual version bumping or npm publishing.

### How to Release

1. Create a PR to `main` with changes
2. Add **one** version label:
   - `version:patch` — Bug fixes (1.3.2 → 1.3.3)
   - `version:minor` — New features, backward compatible (1.3.2 → 1.4.0)
   - `version:major` — Breaking changes (1.3.2 → 2.0.0)
3. Merge the PR

### What the Workflow Does

**`.github/workflows/release.yml`** triggers on PR merge to main with a version label:

1. Runs `npm run test:coverage` (tests must pass)
2. `npm version <patch|minor|major> --no-git-tag-version` (bumps `package.json`)
3. Updates `CHANGELOG.md` with PR title and number
4. Commits: `chore: release v{version}`
5. Creates and pushes git tag `v{version}`
6. Creates GitHub Release with changelog excerpt
7. `npm publish` (using `NPM_TOKEN` secret)
8. Comments on PR with release links

### Requirements

- `NPM_TOKEN` secret configured in GitHub repository settings
- PR must be **merged** (not just closed)
- Only one version label per PR

---

## CI Workflows

### `test-pr.yml` — On Pull Request

**Triggers:** PR opened, synchronized, or reopened against `main`

**Jobs:**
1. **test** — Checkout → Node 18 → `npm ci` → `npm run test:coverage` → `npm run build` → Check for uncommitted changes
2. **validate-version-label** — Warns if no version label, errors if multiple labels

### `release.yml` — On PR Merge

**Triggers:** PR closed (merged) to `main` with version label

**Condition:** `github.event.pull_request.merged == true && (has version label)`

**Steps:** Full release pipeline (see above)

**Permissions:** `contents: write` (git push, releases), `pull-requests: write` (PR comments)

---

## Pre-Release Checklist

Before adding a version label, ensure:

- [ ] All tests pass (`npm test`)
- [ ] TypeScript builds (`npm run build`)
- [ ] CHANGELOG.md has entry for changes
- [ ] README.md updated if user-facing changes
- [ ] No breaking changes without `version:major` label

---

## Commit Conventions

Uses [Conventional Commits](https://www.conventionalcommits.org/):

| Prefix | Use |
|--------|-----|
| `feat(scope):` | New features |
| `fix(scope):` | Bug fixes |
| `refactor(scope):` | Code changes without feature/bug changes |
| `test(scope):` | Test additions/updates |
| `docs(scope):` | Documentation changes |
| `chore(scope):` | Maintenance (release commits, deps) |

**Common scopes:** `search`, `results`, `focus`, `marquee`, `validation`, `props`, `ios`, `types`

---

## Development Environment

- **Node.js:** >=18.0.0
- **TypeScript:** ~5.3.0
- **Jest:** ^29.7.0 with ts-jest ^29.4.6
- **Platform:** tvOS 15.0+, Expo SDK 51+, React Native tvOS 0.71+

---

## Related Documentation

- [`CLAUDE-architecture.md`](./CLAUDE-architecture.md) - What you're building and how it fits together
- [`CLAUDE-testing.md`](./CLAUDE-testing.md) - Testing setup details and strategies
