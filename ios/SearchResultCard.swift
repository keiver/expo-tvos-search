#if os(tvOS)

import SwiftUI

/// Custom shape for cards with selectively rounded corners
/// Provides backwards compatibility for tvOS versions before 16.0
struct SelectiveRoundedRectangle: Shape {
    var topLeadingRadius: CGFloat
    var topTrailingRadius: CGFloat
    var bottomLeadingRadius: CGFloat
    var bottomTrailingRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let tl = min(topLeadingRadius, min(rect.width, rect.height) / 2)
        let tr = min(topTrailingRadius, min(rect.width, rect.height) / 2)
        let bl = min(bottomLeadingRadius, min(rect.width, rect.height) / 2)
        let br = min(bottomTrailingRadius, min(rect.width, rect.height) / 2)

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
/// The card's own `.overlay(cardShape.stroke(...))` provides focus feedback.
private struct NoHaloButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.85 : 1.0)
    }
}

struct SearchResultCard: View {
    let item: SearchResultItem
    let showTitle: Bool
    let showSubtitle: Bool
    let showFocusBorder: Bool
    let showTitleOverlay: Bool
    let enableMarquee: Bool
    let marqueeDelay: Double
    let textColor: Color?
    let accentColor: Color
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let imageContentMode: ContentMode
    let cardPadding: CGFloat
    let overlayTitleSize: CGFloat
    let onSelect: () -> Void
    @FocusState private var isFocused: Bool

    private let placeholderColor = Color(white: 0.2)

    /// On tvOS < 17, .card button style isn't usable (gesture conflict with RN),
    /// so always show a focus border since there's no other visual feedback.
    private var shouldShowFocusBorder: Bool {
        if #available(tvOS 17, *) {
            return showFocusBorder
        } else {
            return true
        }
    }

    /// White border on tvOS < 17 for visibility; accent color on tvOS 17+ when opt-in.
    private var focusBorderColor: Color {
        if #available(tvOS 17, *) {
            return accentColor
        } else {
            return .white
        }
    }

    /// Computed shape for the card with selective rounded corners.
    /// Bottom corners are rounded only when no title/subtitle section is displayed.
    private var cardShape: SelectiveRoundedRectangle {
        SelectiveRoundedRectangle(
            topLeadingRadius: 12,
            topTrailingRadius: 12,
            bottomLeadingRadius: (showTitle || showSubtitle) ? 0 : 12,
            bottomTrailingRadius: (showTitle || showSubtitle) ? 0 : 12
        )
    }

    // Title overlay height
    private var overlayHeight: CGFloat { cardHeight * 0.25 }  // 25% of card

    /// Card visual content extracted to avoid duplication in version-gated body
    @ViewBuilder
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: showTitle || showSubtitle ? 12 : 0) {
            ZStack(alignment: .bottom) {
                // Card image content
                ZStack {
                    placeholderColor

                    if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                        CachedAsyncImage(
                            url: url,
                            contentMode: imageContentMode,
                            width: cardWidth,
                            height: cardHeight
                        )
                    } else {
                        placeholderIcon
                    }
                }
                .frame(width: cardWidth, height: cardHeight)
                .clipped()

                // Title overlay with native material blur
                if showTitleOverlay {
                    ZStack {
                        Rectangle()
                            .fill(.ultraThinMaterial)
                            .frame(width: cardWidth, height: overlayHeight)

                        if enableMarquee {
                            MarqueeText(
                                item.title,
                                font: .system(size: overlayTitleSize, weight: .semibold),
                                leftFade: 12,
                                rightFade: 12,
                                startDelay: marqueeDelay,
                                animate: isFocused
                            )
                            .foregroundColor(.white)
                            .padding(.horizontal, cardPadding)
                        } else {
                            Text(item.title)
                                .font(.system(size: overlayTitleSize, weight: .semibold))
                                .foregroundColor(.white)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, cardPadding)
                        }
                    }
                    .frame(width: cardWidth, height: overlayHeight)
                }
            }
            .frame(width: cardWidth, height: cardHeight)
            .clipShape(cardShape)
            .overlay(
                cardShape.stroke(shouldShowFocusBorder && isFocused ? focusBorderColor : Color.clear, lineWidth: 4)
            )

            if showTitle || showSubtitle {
                VStack(alignment: .leading, spacing: 4) {
                    if showTitle {
                        Text(item.title)
                            .font(.callout)
                            .fontWeight(.medium)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .foregroundColor(.primary)
                    }

                    if showSubtitle, let subtitle = item.subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(textColor ?? .secondary)
                            .lineLimit(1)
                    }
                }
                .padding(cardPadding)
                .frame(width: cardWidth, alignment: .leading)
            }
        }
    }

    var body: some View {
        // tvOS 16 has a gesture recognizer conflict between .buttonStyle(.card)
        // and React Native's RCTTVRemoteSelectHandler inside ScrollView + .searchable,
        // causing Enter/Select to not fire the button action.
        // Use .plain on older versions as a workaround.
        if #available(tvOS 17, *) {
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
