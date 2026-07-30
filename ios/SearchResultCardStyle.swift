#if os(tvOS)

import SwiftUI

/// How a card reacts to focus.
enum FocusStyle: String {
    /// tvOS card button style: Apple's lift, parallax, and shadow.
    case system
    /// No system effect. Only the card's own border, glow, and scale apply.
    /// Always used on tvOS 16 and earlier, where `.buttonStyle(.card)` conflicts
    /// with React Native's remote gesture handler.
    case custom
}

/// Every visual knob for a search result card, resolved from `SearchViewModel`.
///
/// These were once 30-odd individual parameters on `SearchResultCard`, which meant
/// `TvosSearchContentView` had to be edited in lockstep for every new prop with
/// nothing but argument arity to catch a mismatch. Grouping them keeps the card to
/// three parameters and makes the resolution rules (defaults, clamping, fallbacks)
/// testable on their own.
struct SearchResultCardStyle {
    // Layout
    var width: CGFloat = 280
    var height: CGFloat = 420
    var padding: CGFloat = 16
    var cornerRadius: CGFloat = 12
    var backgroundColor: Color?

    // Borders. The focused border replaces the resting one rather than adding to
    // it, matching how a CSS border swaps width and color on focus.
    var borderWidth: CGFloat = 0
    var borderColor: Color?
    var showFocusBorder: Bool = false
    var focusBorderWidth: CGFloat = 4

    // Focus
    var focusStyle: FocusStyle = .system
    var focusScale: CGFloat = 1
    var focusGlowColor: Color?
    var focusGlowOpacity: Double = 0.55
    var focusGlowRadius: CGFloat = 0

    // Content
    var showTitle: Bool = false
    var showSubtitle: Bool = false
    var showTitleOverlay: Bool = true
    var imageContentMode: ContentMode = .fill

    // Title overlay
    var overlayTitleSize: CGFloat = 20
    var overlayTitleWeight: Font.Weight = .semibold
    var overlayHeight: CGFloat?
    var overlayBackgroundColor: Color?
    var overlayTextColor: Color?
    var overlayBackgroundColorFocused: Color?
    var overlayTextColorFocused: Color?

    // Marquee
    var enableMarquee: Bool = true
    var marqueeDelay: Double = 1.5
    var marqueeSpeed: CGFloat = 30
    var marqueeMode: MarqueeMode = .loop

    // Text
    var textColor: Color?
    var accentColor: Color = Color(red: 1, green: 0.765, blue: 0.07) // #FFC312

    /// Overlay height, defaulting to a quarter of the card and never taller than it.
    /// `overlayHeight` is clamped to 0-500 without knowing `height`, so an oversized
    /// value on a short card would otherwise be silently swallowed by the clip shape.
    var resolvedOverlayHeight: CGFloat {
        min(max(0, overlayHeight ?? (height * 0.25)), max(0, height))
    }

    /// Glow color already carrying its opacity. Falls back to the accent color so a
    /// consumer that sets only `focusGlowRadius` still gets a matching glow.
    var resolvedGlowColor: Color {
        (focusGlowColor ?? accentColor).opacity(focusGlowOpacity)
    }

    /// Overlay fill for the current focus state. `nil` means the native blur
    /// material is used instead of a solid color.
    func overlayFill(isFocused: Bool) -> Color? {
        isFocused ? (overlayBackgroundColorFocused ?? overlayBackgroundColor) : overlayBackgroundColor
    }

    /// Overlay text color for the current focus state, defaulting to white.
    func overlayForeground(isFocused: Bool) -> Color {
        let resting = overlayTextColor ?? .white
        return isFocused ? (overlayTextColorFocused ?? resting) : resting
    }

    /// Whether the card should render an external title/subtitle block, which also
    /// squares off the card's bottom corners so the two read as one surface.
    var hasExternalText: Bool {
        showTitle || showSubtitle
    }
}

#endif
