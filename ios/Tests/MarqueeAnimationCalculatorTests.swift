import XCTest

/// Unit tests for MarqueeAnimationCalculator
final class MarqueeAnimationCalculatorTests: XCTestCase {
    var calculator: MarqueeAnimationCalculator!

    override func setUp() {
        super.setUp()
        calculator = MarqueeAnimationCalculator()
    }

    override func tearDown() {
        calculator = nil
        super.tearDown()
    }

    // MARK: - shouldScroll Tests

    func testShouldScroll_textWiderThanContainer_returnsTrue() {
        XCTAssertTrue(calculator.shouldScroll(textWidth: 500, containerWidth: 300))
    }

    func testShouldScroll_textFitsContainer_returnsFalse() {
        XCTAssertFalse(calculator.shouldScroll(textWidth: 200, containerWidth: 300))
    }

    func testShouldScroll_zeroContainerWidth_returnsFalse() {
        XCTAssertFalse(calculator.shouldScroll(textWidth: 500, containerWidth: 0))
    }

    func testShouldScroll_equalWidths_returnsFalse() {
        XCTAssertFalse(calculator.shouldScroll(textWidth: 300, containerWidth: 300))
    }

    func testShouldScroll_zeroTextWidth_returnsFalse() {
        XCTAssertFalse(calculator.shouldScroll(textWidth: 0, containerWidth: 300))
    }

    func testShouldScroll_negativeContainerWidth_returnsFalse() {
        XCTAssertFalse(calculator.shouldScroll(textWidth: 500, containerWidth: -100))
    }

    // MARK: - scrollDistance Tests

    func testScrollDistance_defaultSpacing() {
        XCTAssertEqual(calculator.scrollDistance(textWidth: 400), 440)
    }

    func testScrollDistance_customSpacing() {
        let customCalculator = MarqueeAnimationCalculator(spacing: 20)
        XCTAssertEqual(customCalculator.scrollDistance(textWidth: 400), 420)
    }

    func testScrollDistance_zeroSpacing() {
        let noSpacingCalculator = MarqueeAnimationCalculator(spacing: 0)
        XCTAssertEqual(noSpacingCalculator.scrollDistance(textWidth: 400), 400)
    }

    func testScrollDistance_zeroTextWidth() {
        XCTAssertEqual(calculator.scrollDistance(textWidth: 0), 40)
    }

    // MARK: - animationDuration Tests

    func testAnimationDuration_defaultSpeed() {
        XCTAssertEqual(calculator.animationDuration(for: 300), 10.0, accuracy: 0.001)
    }

    func testAnimationDuration_customSpeed() {
        let fastCalculator = MarqueeAnimationCalculator(pixelsPerSecond: 60)
        XCTAssertEqual(fastCalculator.animationDuration(for: 300), 5.0, accuracy: 0.001)
    }

    func testAnimationDuration_zeroDistance() {
        XCTAssertEqual(calculator.animationDuration(for: 0), 0.0, accuracy: 0.001)
    }

    func testAnimationDuration_largeDistance() {
        XCTAssertEqual(calculator.animationDuration(for: 3000), 100.0, accuracy: 0.001)
    }

    // MARK: - Integration Tests

    func testFullCalculation_typicalLongTitle() {
        let textWidth: CGFloat = 500
        let containerWidth: CGFloat = 280

        XCTAssertTrue(calculator.shouldScroll(textWidth: textWidth, containerWidth: containerWidth))

        let distance = calculator.scrollDistance(textWidth: textWidth)
        XCTAssertEqual(distance, 540)

        let duration = calculator.animationDuration(for: distance)
        XCTAssertEqual(duration, 18.0, accuracy: 0.001)
    }

    func testFullCalculation_shortTitle() {
        let textWidth: CGFloat = 200
        let containerWidth: CGFloat = 280

        XCTAssertFalse(calculator.shouldScroll(textWidth: textWidth, containerWidth: containerWidth))
    }
}
