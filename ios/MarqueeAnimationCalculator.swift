import Foundation

/// Calculator for marquee text animation parameters.
/// Extracted from MarqueeText view to enable unit testing.
struct MarqueeAnimationCalculator {
    /// Minimum scroll speed to prevent division by zero
    private static let minPixelsPerSecond: CGFloat = 1.0

    let spacing: CGFloat
    let pixelsPerSecond: CGFloat

    init(spacing: CGFloat = 40, pixelsPerSecond: CGFloat = 30) {
        // Ensure non-negative spacing
        self.spacing = max(0, spacing)
        // Ensure minimum scroll speed to prevent division by zero
        self.pixelsPerSecond = max(Self.minPixelsPerSecond, pixelsPerSecond)
    }

    /// Determines if the text needs to scroll based on its width vs container width.
    /// - Parameters:
    ///   - textWidth: The measured width of the text content
    ///   - containerWidth: The available container width
    /// - Returns: `true` if text is wider than container and container has valid width
    func shouldScroll(textWidth: CGFloat, containerWidth: CGFloat) -> Bool {
        textWidth > containerWidth && containerWidth > 0
    }

    /// Calculates the total scroll distance including spacing between repeated text.
    /// - Parameter textWidth: The measured width of the text content
    /// - Returns: Total distance the text needs to scroll (always non-negative)
    func scrollDistance(textWidth: CGFloat) -> CGFloat {
        max(0, textWidth) + spacing
    }

    /// Calculates animation duration based on scroll distance and scroll speed.
    /// - Parameter distance: The total scroll distance
    /// - Returns: Duration in seconds for the scroll animation (always non-negative)
    func animationDuration(for distance: CGFloat) -> Double {
        Double(max(0, distance)) / pixelsPerSecond
    }
}
