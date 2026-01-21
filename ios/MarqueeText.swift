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
    @State private var animationTask: Task<Void, Never>?

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
                        // Duplicated text for seamless scroll loop
                        Text(text + "     " + text)
                            .font(font)
                            .fixedSize()
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
            .onChange(of: animate) { shouldAnimate in
                if shouldAnimate && needsScroll {
                    startScrolling()
                } else {
                    stopScrolling()
                }
            }
            .onChange(of: needsScroll) { scrollNeeded in
                if animate && scrollNeeded {
                    startScrolling()
                } else {
                    stopScrolling()
                }
            }
            .onDisappear {
                // Cancel animation task when view disappears to prevent memory leaks
                animationTask?.cancel()
                animationTask = nil
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

    private func startScrolling() {
        animationTask?.cancel()
        offset = 0

        let distance = calculator.scrollDistance(textWidth: textWidth)
        let duration = calculator.animationDuration(for: distance)

        animationTask = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(startDelay * 1_000_000_000))
            } catch {
                return // Task was cancelled
            }

            guard !Task.isCancelled else { return }

            await MainActor.run {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    offset = -distance
                }
            }
        }
    }

    private func stopScrolling() {
        animationTask?.cancel()
        animationTask = nil
        withAnimation(.easeOut(duration: 0.2)) {
            offset = 0
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
