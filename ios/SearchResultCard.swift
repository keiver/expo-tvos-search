#if os(tvOS)

import SwiftUI

/// Custom shape for cards with selectively rounded corners
/// Provides backwards compatibility for tvOS versions before 16.0
///
/// `InsettableShape` conformance lets the card use `.strokeBorder`, which draws
/// the border entirely inside the shape (like a CSS `border-box` border) rather
/// than straddling the path the way `.stroke` does.
struct SelectiveRoundedRectangle: InsettableShape {
    var topLeadingRadius: CGFloat
    var topTrailingRadius: CGFloat
    var bottomLeadingRadius: CGFloat
    var bottomTrailingRadius: CGFloat
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> SelectiveRoundedRectangle {
        var shape = self
        shape.insetAmount += amount
        return shape
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        guard rect.width > 0, rect.height > 0 else { return path }

        // Inner radii shrink with the inset so the border keeps a constant width
        // around the curve, matching how CSS derives the inner border radius.
        let maxRadius = min(rect.width, rect.height) / 2
        let tl = min(max(0, topLeadingRadius - insetAmount), maxRadius)
        let tr = min(max(0, topTrailingRadius - insetAmount), maxRadius)
        let bl = min(max(0, bottomLeadingRadius - insetAmount), maxRadius)
        let br = min(max(0, bottomTrailingRadius - insetAmount), maxRadius)

        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
                   radius: tr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br),
                   radius: br, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl),
                   radius: bl, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
                   radius: tl, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.closeSubpath()

        return path
    }
}

/// Suppresses the default system focus halo on tvOS 16.
/// The card's own border overlay provides focus feedback instead.
private struct NoHaloButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

struct SearchResultCard: View {
    let item: SearchResultItem
    let style: SearchResultCardStyle
    let onSelect: () -> Void

    @FocusState private var isFocused: Bool

    private var placeholderColor: Color { style.backgroundColor ?? Color(white: 0.2) }

    /// On tvOS < 17, .card button style isn't usable (gesture conflict with RN),
    /// so always show a focus border since there's no other visual feedback.
    private var shouldShowFocusBorder: Bool {
        if #available(tvOS 17, *) {
            return style.showFocusBorder
        } else {
            return true
        }
    }

    /// White border on tvOS < 17 for visibility; accent color on tvOS 17+ when opt-in.
    private var focusBorderColor: Color {
        if #available(tvOS 17, *) {
            return style.accentColor
        } else {
            return .white
        }
    }

    /// The focused border replaces the resting border rather than adding to it,
    /// matching how a CSS border swaps width and color on focus.
    private var currentBorderWidth: CGFloat {
        (shouldShowFocusBorder && isFocused) ? style.focusBorderWidth : style.borderWidth
    }

    private var currentBorderColor: Color {
        (shouldShowFocusBorder && isFocused) ? focusBorderColor : (style.borderColor ?? .clear)
    }

    /// tvOS 16 and earlier always use the custom path: .buttonStyle(.card) has a
    /// gesture conflict with React Native there (see `body`).
    private var usesSystemFocusStyle: Bool {
        if #available(tvOS 17, *) {
            return style.focusStyle == .system
        } else {
            return false
        }
    }

    /// Computed shape for the card with selective rounded corners.
    /// Bottom corners are rounded only when no title/subtitle section is displayed.
    private var cardShape: SelectiveRoundedRectangle {
        SelectiveRoundedRectangle(
            topLeadingRadius: style.cornerRadius,
            topTrailingRadius: style.cornerRadius,
            bottomLeadingRadius: style.hasExternalText ? 0 : style.cornerRadius,
            bottomTrailingRadius: style.hasExternalText ? 0 : style.cornerRadius
        )
    }

    /// Card visual content extracted to avoid duplication in version-gated body
    @ViewBuilder
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: style.hasExternalText ? 12 : 0) {
            ZStack(alignment: .bottom) {
                // Card image content
                ZStack {
                    placeholderColor

                    if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                        CachedAsyncImage(
                            url: url,
                            contentMode: style.imageContentMode,
                            width: style.width,
                            height: style.height
                        )
                    } else {
                        placeholderIcon
                    }
                }
                .frame(width: style.width, height: style.height)
                .clipped()

                if style.showTitleOverlay {
                    titleOverlay
                }
            }
            .frame(width: style.width, height: style.height)
            .clipShape(cardShape)
            .overlay(
                cardShape.strokeBorder(currentBorderColor, lineWidth: currentBorderWidth)
            )
            .shadow(
                color: (style.focusGlowRadius > 0 && isFocused) ? style.resolvedGlowColor : .clear,
                radius: style.focusGlowRadius,
                x: 0,
                y: 0
            )

            if style.hasExternalText {
                externalText
            }
        }
    }

    @ViewBuilder
    private var titleOverlay: some View {
        let height = style.resolvedOverlayHeight

        ZStack {
            // A solid fill replaces the blur material when a color is supplied,
            // so a custom bar reads as one flat surface (a translucent color
            // composited over the material muddies it).
            if let fill = style.overlayFill(isFocused: isFocused) {
                Rectangle()
                    .fill(fill)
                    .frame(width: style.width, height: height)
            } else {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(width: style.width, height: height)
            }

            if style.enableMarquee {
                MarqueeText(
                    item.title,
                    font: .system(size: style.overlayTitleSize, weight: style.overlayTitleWeight),
                    leftFade: 12,
                    rightFade: 12,
                    startDelay: style.marqueeDelay,
                    animate: isFocused,
                    speed: style.marqueeSpeed,
                    mode: style.marqueeMode
                )
                .foregroundColor(style.overlayForeground(isFocused: isFocused))
                .padding(.horizontal, style.padding)
            } else {
                Text(item.title)
                    .font(.system(size: style.overlayTitleSize, weight: style.overlayTitleWeight))
                    .foregroundColor(style.overlayForeground(isFocused: isFocused))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, style.padding)
            }
        }
        .frame(width: style.width, height: height)
    }

    @ViewBuilder
    private var externalText: some View {
        VStack(alignment: .leading, spacing: 4) {
            if style.showTitle {
                Text(item.title)
                    .font(.callout)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
            }

            if style.showSubtitle, let subtitle = item.subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(style.textColor ?? .secondary)
                    .lineLimit(1)
            }
        }
        .padding(style.padding)
        .frame(width: style.width, alignment: .leading)
    }

    var body: some View {
        // tvOS 16 has a gesture recognizer conflict between .buttonStyle(.card)
        // and React Native's RCTTVRemoteSelectHandler inside ScrollView + .searchable,
        // causing Enter/Select to not fire the button action.
        // Use the plain style on older versions as a workaround.
        //
        // On tvOS 17+, focusStyle "custom" also takes the plain path so the card's
        // own border, glow, and scale are the only focus feedback. The system card
        // style layers its own lift, parallax, and shadow on top otherwise.
        if usesSystemFocusStyle {
            Button(action: onSelect) {
                cardContent
            }
            .buttonStyle(.card)
            .focused($isFocused)
        } else {
            Button(action: onSelect) {
                cardContent
            }
            .buttonStyle(NoHaloButtonStyle())
            .focused($isFocused)
            .scaleEffect(isFocused ? style.focusScale : 1)
            .animation(.easeOut(duration: 0.2), value: isFocused)
        }
    }

    private var placeholderIcon: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 120, height: 120)

            Image(systemName: "photo")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

#endif
