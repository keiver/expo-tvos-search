#if os(tvOS)

import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var results: [SearchResultItem] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""

    var onSearch: ((String) -> Void)?
    var onSelectItem: ((String) -> Void)?
    @Published var columns: Int = 5
    @Published var placeholder: String = "Search..."

    // Card styling options (configurable from JS)
    @Published var showTitle: Bool = false
    @Published var showSubtitle: Bool = false
    @Published var showFocusBorder: Bool = false
    @Published var topInset: CGFloat = 0  // Extra top padding for tab bar

    // Title overlay options (configurable from JS)
    @Published var showTitleOverlay: Bool = true
    @Published var enableMarquee: Bool = true
    @Published var marqueeDelay: Double = 1.5

    // State text options (configurable from JS)
    @Published var emptyStateText: String = "Search your library"
    @Published var searchingText: String = "Searching..."
    @Published var noResultsText: String = "No results found"
    @Published var noResultsHintText: String = "Try a different search term"

    // Color customization options (configurable from JS)
    @Published var textColor: Color? = nil
    @Published var accentColor: Color = Color(red: 1, green: 0.765, blue: 0.07) // #FFC312 (gold)

    // Card dimension options (configurable from JS)
    @Published var cardWidth: CGFloat = 280
    @Published var cardHeight: CGFloat = 420

    // Image display options (configurable from JS)
    @Published var imageContentMode: ContentMode = .fill

    // Layout spacing options (configurable from JS)
    @Published var cardMargin: CGFloat = 40  // Spacing between cards
    @Published var cardPadding: CGFloat = 16  // Padding inside cards
    @Published var overlayTitleSize: CGFloat = 20  // Font size for overlay title

    // Card shell options (configurable from JS)
    @Published var cardCornerRadius: CGFloat = 12
    @Published var cardBackgroundColor: Color? = nil  // nil = Color(white: 0.2)
    @Published var borderWidth: CGFloat = 0           // Resting border, drawn on every card
    @Published var borderColor: Color? = nil          // nil = transparent
    @Published var focusBorderWidth: CGFloat = 4

    // Focus appearance options (configurable from JS)
    @Published var focusStyle: FocusStyle = .system
    @Published var focusScale: CGFloat = 1.0
    @Published var focusGlowColor: Color? = nil       // nil = accentColor
    @Published var focusGlowOpacity: Double = 0.55
    @Published var focusGlowRadius: CGFloat = 0       // 0 = no glow

    // Title overlay appearance options (configurable from JS)
    @Published var overlayBackgroundColor: Color? = nil         // nil = .ultraThinMaterial
    @Published var overlayTextColor: Color? = nil               // nil = .white
    @Published var overlayBackgroundColorFocused: Color? = nil  // nil = overlayBackgroundColor
    @Published var overlayTextColorFocused: Color? = nil        // nil = overlayTextColor
    @Published var overlayTitleWeight: Font.Weight = .semibold
    @Published var overlayHeight: CGFloat? = nil                // nil = cardHeight * 0.25

    // Marquee animation options (configurable from JS)
    @Published var marqueeSpeed: CGFloat = 30         // Points per second
    @Published var marqueeMode: MarqueeMode = .loop

    /// Assembles every card visual into one value. Adding a prop now touches this
    /// builder rather than the card's parameter list and its call site as well.
    var cardStyle: SearchResultCardStyle {
        SearchResultCardStyle(
            width: cardWidth,
            height: cardHeight,
            padding: cardPadding,
            cornerRadius: cardCornerRadius,
            backgroundColor: cardBackgroundColor,
            borderWidth: borderWidth,
            borderColor: borderColor,
            showFocusBorder: showFocusBorder,
            focusBorderWidth: focusBorderWidth,
            focusStyle: focusStyle,
            focusScale: focusScale,
            focusGlowColor: focusGlowColor,
            focusGlowOpacity: focusGlowOpacity,
            focusGlowRadius: focusGlowRadius,
            showTitle: showTitle,
            showSubtitle: showSubtitle,
            showTitleOverlay: showTitleOverlay,
            imageContentMode: imageContentMode,
            overlayTitleSize: overlayTitleSize,
            overlayTitleWeight: overlayTitleWeight,
            overlayHeight: overlayHeight,
            overlayBackgroundColor: overlayBackgroundColor,
            overlayTextColor: overlayTextColor,
            overlayBackgroundColorFocused: overlayBackgroundColorFocused,
            overlayTextColorFocused: overlayTextColorFocused,
            enableMarquee: enableMarquee,
            marqueeDelay: marqueeDelay,
            marqueeSpeed: marqueeSpeed,
            marqueeMode: marqueeMode,
            textColor: textColor,
            accentColor: accentColor
        )
    }
}

#endif
