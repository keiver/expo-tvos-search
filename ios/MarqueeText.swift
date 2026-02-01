import SwiftUI

#if os(tvOS)

/// A text view that scrolls horizontally when content exceeds container width.
/// Uses PreferenceKey for reactive measurement and Task for cancellable animations.
struct MarqueeText: View {
    let text: String
    let font: Font
    let leftFade: CGFloat
    let rightFade: CGFloat
    let startDelay: Double
    let animate: Bool

    @State private var textWidth: CGFloat = 0
    @State private var containerWidth: CGFloat = 0
    @State private var offset: CGFloat = 0

    private let calculator = MarqueeAnimationCalculator()

    init(
        _ text: String,
        font: Font = .callout,
        leftFade: CGFloat = 10,
        rightFade: CGFloat = 10,
        startDelay: Double = 1.5,
        animate: Bool = true
    ) {
        self.text = text
        self.font = font
        self.leftFade = leftFade
        self.rightFade = rightFade
        self.startDelay = startDelay
        self.animate = animate
    }

    private var needsScroll: Bool {
        calculator.shouldScroll(textWidth: textWidth, containerWidth: containerWidth)
    }

    private var shouldAnimate: Bool {
        animate && needsScroll
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
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
                        HStack(spacing: calculator.spacing) {
                            Text(text).font(font).fixedSize()
                            Text(text).font(font).fixedSize()
                        }
                        .offset(x: offset)
                    } else {
                        Text(text)
                            .font(font)
                            .lineLimit(1)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: Alignment(horizontal: .leading, vertical: .center))
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
            .task(id: shouldAnimate) {
                if shouldAnimate {
                    do {
                        try await Task.sleep(nanoseconds: UInt64(min(startDelay, 60.0) * 1_000_000_000))
                    } catch {
                        return
                    }
                    guard !Task.isCancelled else { return }
                    let distance = calculator.scrollDistance(textWidth: textWidth)
                    let duration = calculator.animationDuration(for: distance)
                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                        offset = -distance
                    }
                } else {
                    if offset != 0 {
                        withAnimation(.easeOut(duration: 0.2)) {
                            offset = 0
                        }
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
