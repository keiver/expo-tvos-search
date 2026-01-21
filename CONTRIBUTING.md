# Contributing to expo-tvos-search

Thank you for your interest in contributing to expo-tvos-search! This guide will help you get started with development, testing, and submitting contributions.

## Table of Contents

- [Development Setup](#development-setup)
- [Running Tests](#running-tests)
- [Building Locally](#building-locally)
- [Code Style Guidelines](#code-style-guidelines)
- [Commit Conventions](#commit-conventions)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)

## Development Setup

### Prerequisites

- Node.js 18+ and npm/yarn
- Xcode 15+ (for iOS/tvOS development)
- macOS (required for iOS/tvOS builds)
- Expo CLI (`npm install -g expo-cli`)

### Installation

1. Fork and clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/expo-tvos-search.git
   cd expo-tvos-search
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Build the TypeScript files:
   ```bash
   npm run build
   ```

### Testing with Example App

To test your changes in a real tvOS app:

1. Create a test Expo app:
   ```bash
   npx create-expo-app my-test-app
   cd my-test-app
   ```

2. Configure for tvOS following the [Prerequisites section](README.md#prerequisites-for-tvos-builds-expo) in the README

3. Link your local development version:
   ```bash
   npm install ../expo-tvos-search
   ```

4. Run prebuild and start the app:
   ```bash
   EXPO_TV=1 npx expo prebuild --clean
   npx expo run:ios
   ```

## Running Tests

### JavaScript/TypeScript Tests

Run Jest tests:
```bash
npm test
```

Run tests in watch mode:
```bash
npm test -- --watch
```

Run tests with coverage:
```bash
npm test -- --coverage
```

### Swift Tests

Swift unit tests are located in `ios/ExpoTvosSearchTests/`. To run them:

1. Open the Xcode project:
   ```bash
   cd example  # if you have an example app
   open ios/*.xcworkspace
   ```

2. Select the test target and run tests with `Cmd+U`

Or run from command line:
```bash
cd ios && xcodebuild test -scheme ExpoTvosSearch -destination 'platform=tvOS Simulator,name=Apple TV'
```

## Building Locally

### TypeScript Build

Compile TypeScript to JavaScript:
```bash
npm run build
```

This outputs to the `build/` directory.

### Type Checking

Run TypeScript type checking:
```bash
npm run typecheck
```

### Linting

Check code style:
```bash
npm run lint
```

Auto-fix linting issues:
```bash
npm run lint -- --fix
```

## Code Style Guidelines

### TypeScript/JavaScript

- Use TypeScript for all new code
- Follow functional React patterns (hooks, not classes)
- Prefer explicit types over `any`
- Use meaningful variable and function names
- Keep functions small and focused on a single responsibility

### Swift

- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use descriptive property and method names
- Add doc comments for public APIs
- Keep view logic in views, business logic in separate functions

### General

- Write tests for new features and bug fixes
- Update documentation when changing public APIs
- Keep commits focused and atomic
- Don't commit commented-out code or debug logs

## Commit Conventions

This project uses [Conventional Commits](https://www.conventionalcommits.org/).

### Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, no logic change)
- `refactor`: Code refactoring (no feature/bug change)
- `perf`: Performance improvements
- `test`: Adding or updating tests
- `chore`: Build process, tooling, dependencies

### Examples

```bash
feat(search): add debounce to search input

fix(results): handle empty image URLs gracefully

docs: update installation instructions for Expo SDK 52

chore: bump expo-modules-core to 2.0.0
```

### Scope Guidelines

Common scopes:
- `search`: Search input and query handling
- `results`: Result grid and display
- `focus`: Focus management and navigation
- `marquee`: Marquee scrolling animation
- `validation`: Input validation and error handling
- `props`: Prop definitions and TypeScript interfaces
- `ios`: iOS/tvOS native module code
- `types`: TypeScript type definitions
- `deps`: Dependency updates

## Pull Request Process

### Before Submitting

1. Ensure all tests pass (`npm test`)
2. Build successfully (`npm run build`)
3. Lint your code (`npm run lint`)
4. Update documentation if needed
5. Add/update tests for your changes

### Submitting

1. Create a feature branch:
   ```bash
   git checkout -b feat/your-feature-name
   ```

2. Commit your changes following [commit conventions](#commit-conventions)

3. Push to your fork:
   ```bash
   git push origin feat/your-feature-name
   ```

4. Open a Pull Request on GitHub with:
   - Clear title following conventional commits format
   - Description of what changed and why
   - Screenshots/videos for UI changes
   - Link to related issues

### Version Labels

Maintainers will add one of these labels to determine the next release version:

- `release:patch` - Bug fixes, small changes (1.0.0 → 1.0.1)
- `release:minor` - New features, backwards-compatible (1.0.0 → 1.1.0)
- `release:major` - Breaking changes (1.0.0 → 2.0.0)

### Review Process

- A maintainer will review your PR
- Address any requested changes
- Once approved, a maintainer will merge and release

## Reporting Bugs

### Before Reporting

1. Check [existing issues](https://github.com/keiver/expo-tvos-search/issues) for duplicates
2. Verify you're using the latest version
3. Confirm the issue occurs on tvOS (not iOS)

### Bug Report Template

Include:

1. **Description**: Clear description of the bug
2. **Reproduction Steps**: Minimal steps to reproduce
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Environment**:
   - `expo-tvos-search` version
   - `expo` version
   - `react-native-tvos` version
   - Xcode version
   - tvOS simulator/device version
6. **Code Sample**: Minimal reproduction code
7. **Screenshots/Videos**: If applicable

### Example

```markdown
### Description
Search results don't display when query contains special characters

### Reproduction
1. Type "test@123" in search field
2. Call setResults() with valid data
3. Results grid remains empty

### Expected
Results should display regardless of query characters

### Actual
Results array is not rendered

### Environment
- expo-tvos-search: 1.2.3
- expo: 52.0.0
- react-native-tvos: 0.76.0
- Xcode: 15.4
- tvOS Simulator: 17.0

### Code
[Attach minimal reproduction]
```

## Questions?

For questions not covered here:
- Open a [Discussion](https://github.com/keiver/expo-tvos-search/discussions)
- Check the [README](README.md) for usage docs
- Review existing [Issues](https://github.com/keiver/expo-tvos-search/issues)

Thank you for contributing!
