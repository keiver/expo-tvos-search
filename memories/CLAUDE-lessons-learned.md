# Lessons Learned Memory Bank

> **Category:** Implementation
> **Keywords:** debugging, bugs, lessons, marquee, animation, state machine, focus, SwiftUI
> **Last Updated:** 2026-01-26

## Quick Reference

- **Marquee State Machine Race (Jan 2026):** Three `onChange` handlers + manual `Task` management = non-deterministic animation. Fix: `.task(id: shouldAnimate)`.
- **Marquee Text Disappearing (Jan 2026):** Visual gap in `Text(text + " " + text)` didn't match `calculator.spacing`. Fix: `HStack(spacing: calculator.spacing)`.
- **Library vs App Threat Model:** Inputs come from integrating developers, not untrusted end users. Don't apply app-level security to library code.

---

## Marquee State Machine Race Condition (January 2026)

### Problem
Animation was inverted/broken on card focus change. When a user focused a card, the marquee animation would sometimes play in reverse, freeze, or start scrolling in the wrong direction. The animation state was non-deterministic.

### Root Cause
Three `onChange` handlers (for `animate`, `textWidth`, `containerWidth`) each managed their own `Task` lifecycle with manual cancellation. During tvOS card focus animation, multiple state changes fired in rapid succession:

1. `animate` changed → started a Task with delay
2. `textWidth` changed (layout shift during focus scale) → cancelled first Task, started another
3. `containerWidth` changed → cancelled second Task, started a third

Each handler had its own `animationTask` reference and cancellation logic, creating race conditions where:
- Tasks were cancelled after already setting the offset
- New tasks started before old tasks fully cleaned up
- `withAnimation` blocks overlapped, causing SwiftUI to interpolate between conflicting targets

### Solution
Replaced the entire state machine with SwiftUI's `.task(id:)` modifier:

```swift
// BEFORE: Three onChange handlers with manual Task management
.onChange(of: animate) { ... animationTask?.cancel(); animationTask = Task { ... } }
.onChange(of: textWidth) { ... animationTask?.cancel(); animationTask = Task { ... } }
.onChange(of: containerWidth) { ... animationTask?.cancel(); animationTask = Task { ... } }

// AFTER: Single control point
.task(id: shouldAnimate) {
    if shouldAnimate {
        try await Task.sleep(nanoseconds: ...)
        withAnimation(.linear(duration: ...).repeatForever(autoreverses: false)) {
            offset = -distance
        }
    } else {
        withAnimation(.easeOut(duration: 0.2)) { offset = 0 }
    }
}
```

Where `shouldAnimate` is a computed property: `animate && needsScroll` (which depends on `textWidth` and `containerWidth`).

### What Went Wrong
- Assumed manual Task management was needed for fine-grained control
- Didn't account for tvOS focus animations triggering rapid sequential state changes
- Each handler independently managing async work created a distributed state machine with no single coordinator

### What Worked
- `.task(id:)` provides automatic cancellation when the id changes — SwiftUI handles the lifecycle
- Collapsing three triggers into one computed boolean (`shouldAnimate`) eliminated the race condition entirely
- The `shouldAnimate` property naturally captures all three dependencies (animate, textWidth > containerWidth)

### Key Takeaways
1. **SwiftUI lifecycle modifiers > manual Task management**: `.task(id:)` handles cancellation, restart, and lifecycle automatically
2. **Single control point pattern**: Derive one boolean from multiple inputs rather than reacting to each input independently
3. **tvOS focus animations cause rapid state changes**: Card scale animations trigger layout changes that fire multiple `onChange` handlers in a single frame
4. **`withAnimation` is not atomic**: Overlapping `withAnimation` blocks from concurrent Tasks create undefined interpolation behavior

---

## Marquee Text Disappearing (January 2026)

### Problem
Text disappeared during the scroll loop. When the marquee scrolled to the end and wrapped around, there was a visible gap where no text was shown, making the text appear to "blink out."

### Root Cause
The original implementation used inline string concatenation for the repeated text:

```swift
Text(text + "     " + text)
```

The whitespace gap (~27px) didn't match `calculator.spacing` (40px) used to compute the total scroll distance:

```swift
func scrollDistance(textWidth: CGFloat) -> CGFloat {
    max(0, textWidth) + spacing  // spacing = 40
}
```

When the offset reached `-scrollDistance`, the visual gap was smaller than the mathematical gap, causing the second copy of the text to not yet be in position — creating a frame where neither copy was visible.

### Solution
Replaced string concatenation with `HStack` using the calculator's spacing:

```swift
HStack(spacing: calculator.spacing) {
    Text(text).font(font).fixedSize()
    Text(text).font(font).fixedSize()
}
```

Now the visual spacing between text copies is exactly `calculator.spacing`, matching the scroll distance calculation.

### Key Takeaway
**Visual gap and scroll math must use the same source of truth.** When animation distance is computed from a value, the visual layout must use that same value — not an approximation.

---

## Library vs App Threat Modeling

### Lesson
This is a **library**, not an app. The threat model is fundamentally different:
- **App threat model**: Inputs come from untrusted end users → sanitize everything, assume malice
- **Library threat model**: Inputs come from integrating developers → a developer passing bad data is a bug in their app, not a vulnerability in this lib

### Implications
- Don't add excessive input sanitization that hurts DX (developer experience) for a threat that doesn't exist
- Validation should be **defensive** (clamp out-of-range values, truncate long strings) not **paranoid** (reject everything, throw errors)
- Security measures like `HexColorParser.maxInputLength` are about preventing accidental performance issues (e.g., a developer accidentally passing a base64 string), not defending against attackers
- When reviewing code or doing security audits, evaluate in the context of "would a developer do this accidentally?" not "could an attacker exploit this?"

### Audience Context
Consumers are tvOS/Expo developers building media apps (Jellyfin clients, streaming apps). Recommendations should be practical for that context, not generic web security advice.

---

## Template for New Lessons

```markdown
## [Title] ([Month Year])

### Problem
[What was observed — the symptom]

### Root Cause
[Technical explanation of why it happened]

### Solution
[What was changed and why it works]

### What Went Wrong
[Assumptions or approaches that didn't work]

### What Worked
[The key insight or technique that resolved it]

### Key Takeaways
1. [Generalizable lesson]
2. [Another lesson if applicable]
```

---

## Related Documentation

- [`CLAUDE-patterns.md`](./CLAUDE-patterns.md) - Patterns that emerged from these lessons
- [`CLAUDE-architecture.md`](./CLAUDE-architecture.md) - Architecture context for understanding the bugs
