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
    @State private var isScrolling: Bool = false

    private let calculator = MarqueeAnimationCalculator()

    /// Distance the text scrolls based on current measured width
    private var scrollDistance: CGFloat {
        calculator.scrollDistance(textWidth: textWidth)
    }

    /// Duration of one scroll cycle at the configured speed
    private var scrollDuration: Double {
        calculator.animationDuration(for: scrollDistance)
    }

    /// View-scoped animation that switches between scrolling and reset modes.
    /// Using `.animation(_:value:)` prevents transaction leaking to sibling views.
    private var offsetAnimation: Animation? {
        isScrolling
            ? .linear(duration: scrollDuration).repeatForever(autoreverses: false)
            : .easeOut(duration: 0.2)
    }

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
                            .animation(offsetAnimation, value: offset)
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
                updateAnimationState()
            }
            .onChange(of: animate) { _ in
                updateAnimationState()
            }
            .onChange(of: needsScroll) { _ in
                updateAnimationState()
            }
            .onChange(of: isScrolling) { newValue in
                if newValue {
                    offset = -calculator.scrollDistance(textWidth: textWidth)
                }
            }
            .onDisappear {
                // Cancel animation task when view disappears to prevent memory leaks
                animationTask?.cancel()
                animationTask = nil
                isScrolling = false
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

    /// Updates animation state based on current `animate` and `needsScroll` values.
    private func updateAnimationState() {
        if animate && needsScroll {
            startScrolling()
        } else {
            stopScrolling()
        }
    }

    private func startScrolling() {
        guard animate else { return }

        animationTask?.cancel()
        // Reset to start position; the .animation() modifier on the view
        // handles animation — no withAnimation needed.
        isScrolling = false
        offset = 0

        animationTask = Task {
            do {
                try await Task.sleep(nanoseconds: UInt64(startDelay * 1_000_000_000))
            } catch {
                return // Task was cancelled
            }

            guard !Task.isCancelled else { return }

            await MainActor.run {
                guard !Task.isCancelled, self.animate else { return }
                // Only set isScrolling here; the .onChange(of: isScrolling)
                // handler applies the offset in a separate render cycle,
                // ensuring .animation() picks up the repeating animation.
                isScrolling = true
            }
        }
    }

    private func stopScrolling() {
        animationTask?.cancel()
        animationTask = nil
        // Set isScrolling to false so the .animation() modifier applies
        // easeOut for the return transition. Only animate when offset
        // actually needs resetting to avoid spurious animations during init.
        if offset != 0 {
            isScrolling = false
            offset = 0
        } else {
            isScrolling = false
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
