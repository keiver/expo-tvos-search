import SwiftUI

#if os(tvOS)

/// How a marquee scrolls text that overflows its container.
enum MarqueeMode: String {
    /// The text scrolls continuously in one direction, repeating seamlessly.
    case loop
    /// The text scrolls to the end, pauses, then scrolls back to the start.
    case bounce
}

/// A text view that scrolls horizontally when content exceeds container width.
/// Uses PreferenceKey for reactive measurement and Task for cancellable animations.
struct MarqueeText: View {
    /// Pause at the far end of a bounce before scrolling back, in seconds.
    private static let bounceHoldDuration: Double = 0.8

    let text: String
    let font: Font
    let leftFade: CGFloat
    let rightFade: CGFloat
    let startDelay: Double
    let animate: Bool
    let mode: MarqueeMode

    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var offset: CGFloat = 0

    private let calculator: MarqueeAnimationCalculator

    init(
        _ text: String,
        font: Font = .callout,
        leftFade: CGFloat = 10,
        rightFade: CGFloat = 10,
        startDelay: Double = 1.5,
        animate: Bool = true,
        speed: CGFloat = 30,
        mode: MarqueeMode = .loop
    ) {
        self.text = text
        self.font = font
        self.leftFade = leftFade
        self.rightFade = rightFade
        self.startDelay = startDelay
        self.animate = animate
        self.mode = mode
        self.calculator = MarqueeAnimationCalculator(pixelsPerSecond: speed)
    }

    private var needsScroll: Bool {
        calculator.shouldScroll(textWidth: textWidth, containerWidth: containerWidth)
    }

    private var shouldAnimate: Bool {
        animate && needsScroll
    }

    /// Identity for the animation task. Mode and speed are part of it because
    /// `.task(id:)` only restarts when the id changes: keying on `shouldAnimate`
    /// alone would leave a running loop animation driving the offset after the
    /// mode switched to bounce, scrolling the text off the card.
    private var animationKey: AnimationKey {
        AnimationKey(shouldAnimate: shouldAnimate, mode: mode, pixelsPerSecond: calculator.pixelsPerSecond)
    }

    struct AnimationKey: Equatable {
        let shouldAnimate: Bool
        let mode: MarqueeMode
        let pixelsPerSecond: CGFloat
    }

    /// Text that fits is centered; scrolling text starts flush left so the first
    /// character is never clipped mid-glyph.
    private var horizontalAlignment: HorizontalAlignment {
        needsScroll ? .leading : .center
    }

    /// Start delay is capped so a runaway value can't stall the animation task.
    private var startDelayNanoseconds: UInt64 {
        UInt64(max(0, min(startDelay, 60.0)) * 1_000_000_000)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: Alignment(horizontal: horizontalAlignment, vertical: .center)) {
                // Hidden text to measure actual width
                Text(text)
                    .font(font)
                    .fixedSize()
                    .background(
                        GeometryReader { textGeometry in
                            Color.clear
                                .preference(key: TextWidthKey.self, value: textGeometry.size.width)
                        }
                    )
                    .hidden()

                // Visible text content
                Group {
                    if needsScroll {
                        if mode == .bounce {
                            // A single copy is enough — bounce reveals the tail and
                            // returns, so there is never a gap to fill.
                            Text(text).font(font).fixedSize()
                                .offset(x: offset)
                        } else {
                            HStack(spacing: calculator.spacing) {
                                Text(text).font(font).fixedSize()
                                Text(text).font(font).fixedSize()
                            }
                            .offset(x: offset)
                        }
                    } else {
                        Text(text)
                            .font(font)
                            .lineLimit(1)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: Alignment(horizontal: horizontalAlignment, vertical: .center))
            .clipped()
            .mask(fadeMask)
            .onPreferenceChange(TextWidthKey.self) { width in
                textWidth = width
            }
            .onChange(of: geometry.size.width) { newWidth in
                containerWidth = newWidth
            }
            .onAppear {
                containerWidth = geometry.size.width
            }
            .task(id: animationKey) {
                guard shouldAnimate else {
                    if offset != 0 {
                        withAnimation(.easeOut(duration: 0.2)) {
                            offset = 0
                        }
                    }
                    return
                }

                switch mode {
                case .loop:
                    do {
                        try await Task.sleep(nanoseconds: startDelayNanoseconds)
                    } catch {
                        return
                    }
                    guard !Task.isCancelled else { return }
                    let distance = calculator.scrollDistance(textWidth: textWidth)
                    let duration = calculator.animationDuration(for: distance)
                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                        offset = -distance
                    }

                case .bounce:
                    // SwiftUI's .repeatForever(autoreverses: true) uses one delay for
                    // both directions, so the out-and-back cycle is driven manually to
                    // keep the separate start delay and end-of-scroll hold.
                    let distance = calculator.bounceDistance(textWidth: textWidth, containerWidth: containerWidth)
                    let duration = calculator.animationDuration(for: distance)
                    let scrollNanoseconds = UInt64(max(0, duration) * 1_000_000_000)
                    let holdNanoseconds = UInt64(Self.bounceHoldDuration * 1_000_000_000)

                    do {
                        while !Task.isCancelled {
                            try await Task.sleep(nanoseconds: startDelayNanoseconds)
                            guard !Task.isCancelled else { return }
                            withAnimation(.linear(duration: duration)) {
                                offset = -distance
                            }

                            try await Task.sleep(nanoseconds: scrollNanoseconds + holdNanoseconds)
                            guard !Task.isCancelled else { return }
                            withAnimation(.linear(duration: duration)) {
                                offset = 0
                            }

                            try await Task.sleep(nanoseconds: scrollNanoseconds)
                        }
                    } catch {
                        return
                    }
                }
            }
            .onDisappear {
                offset = 0
            }
        }
    }

    private var fadeMask: some View {
        HStack(spacing: 0) {
            LinearGradient(
                colors: [.clear, .black],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: needsScroll ? leftFade : 0)

            Color.black

            LinearGradient(
                colors: [.black, .clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: needsScroll ? rightFade : 0)
        }
    }

}

/// PreferenceKey for measuring text width reactively
private struct TextWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#endif
