import XCTest
@testable import ExpoTvosSearchCore
import SwiftUI

#if os(tvOS)

/// Unit tests for SelectiveRoundedRectangle.
///
/// This shape backs every card's clip and border. `InsettableShape` conformance is
/// what lets the card use `.strokeBorder`, so the border is drawn inside the card
/// bounds instead of straddling the edge. These tests pin the inset geometry.
final class SelectiveRoundedRectangleTests: XCTestCase {
    private let rect = CGRect(x: 0, y: 0, width: 340, height: 510)

    private func uniform(_ radius: CGFloat) -> SelectiveRoundedRectangle {
        SelectiveRoundedRectangle(
            topLeadingRadius: radius,
            topTrailingRadius: radius,
            bottomLeadingRadius: radius,
            bottomTrailingRadius: radius
        )
    }

    // MARK: - Default (uninset) behavior

    func testNoInset_fillsTheGivenRect() {
        // clipShape() relies on this: adding InsettableShape must not have moved the
        // default path off the card bounds
        let bounds = uniform(32).path(in: rect).boundingRect

        XCTAssertEqual(bounds.minX, 0, accuracy: 0.01)
        XCTAssertEqual(bounds.minY, 0, accuracy: 0.01)
        XCTAssertEqual(bounds.width, 340, accuracy: 0.01)
        XCTAssertEqual(bounds.height, 510, accuracy: 0.01)
    }

    func testZeroRadius_fillsTheGivenRect() {
        let bounds = uniform(0).path(in: rect).boundingRect

        XCTAssertEqual(bounds.width, 340, accuracy: 0.01)
        XCTAssertEqual(bounds.height, 510, accuracy: 0.01)
    }

    func testNoInset_isNotEmpty() {
        XCTAssertFalse(uniform(32).path(in: rect).isEmpty)
    }

    // MARK: - inset(by:)

    func testInset_shrinksTheRectOnAllSides() {
        let bounds = uniform(32).inset(by: 2).path(in: rect).boundingRect

        XCTAssertEqual(bounds.minX, 2, accuracy: 0.01)
        XCTAssertEqual(bounds.minY, 2, accuracy: 0.01)
        XCTAssertEqual(bounds.width, 336, accuracy: 0.01)
        XCTAssertEqual(bounds.height, 506, accuracy: 0.01)
    }

    func testInset_accumulatesAcrossCalls() {
        let once = uniform(32).inset(by: 4)
        let twice = uniform(32).inset(by: 2).inset(by: 2)

        XCTAssertEqual(once.insetAmount, twice.insetAmount)
        XCTAssertEqual(twice.path(in: rect).boundingRect.width,
                       once.path(in: rect).boundingRect.width,
                       accuracy: 0.01)
    }

    func testInset_doesNotMutateTheOriginal() {
        let shape = uniform(32)
        _ = shape.inset(by: 10)

        XCTAssertEqual(shape.insetAmount, 0)
    }

    // MARK: - Degenerate insets

    func testInsetLargerThanHalfTheRect_returnsEmptyPath() {
        // Guards the arc math: a negative-size rect would otherwise produce garbage
        XCTAssertTrue(uniform(32).inset(by: 300).path(in: rect).isEmpty)
    }

    func testInsetExactlyHalfTheWidth_returnsEmptyPath() {
        XCTAssertTrue(uniform(32).inset(by: 170).path(in: rect).isEmpty)
    }

    // MARK: - Radius handling

    func testRadiusLargerThanRect_isClampedToHalfTheShortestSide() {
        // A 500pt radius on a 340x510 rect must not invert the arcs
        let bounds = uniform(500).path(in: rect).boundingRect

        XCTAssertEqual(bounds.width, 340, accuracy: 0.01)
        XCTAssertEqual(bounds.height, 510, accuracy: 0.01)
    }

    func testSelectiveCorners_squareBottomStillFillsRect() {
        // The shape used when showTitle/showSubtitle add an external text block
        let shape = SelectiveRoundedRectangle(
            topLeadingRadius: 32,
            topTrailingRadius: 32,
            bottomLeadingRadius: 0,
            bottomTrailingRadius: 0
        )
        let bounds = shape.path(in: rect).boundingRect

        XCTAssertEqual(bounds.width, 340, accuracy: 0.01)
        XCTAssertEqual(bounds.height, 510, accuracy: 0.01)
    }

    func testInsetSmallerThanRadius_keepsAPositiveCornerRadius() {
        // Inner radius = radius - inset, so a 2pt border on a 32pt corner leaves 30pt
        let shape = uniform(32).inset(by: 2)

        XCTAssertFalse(shape.path(in: rect).isEmpty)
        XCTAssertEqual(shape.path(in: rect).boundingRect.width, 336, accuracy: 0.01)
    }

    func testInsetLargerThanRadius_doesNotProduceANegativeRadius() {
        // A 20pt border on a 4pt corner: the inner radius floors at 0 rather than
        // going negative, which would throw off the arc centers
        let shape = SelectiveRoundedRectangle(
            topLeadingRadius: 4,
            topTrailingRadius: 4,
            bottomLeadingRadius: 4,
            bottomTrailingRadius: 4
        ).inset(by: 20)

        let bounds = shape.path(in: rect).boundingRect
        XCTAssertEqual(bounds.width, 300, accuracy: 0.01)
        XCTAssertEqual(bounds.height, 470, accuracy: 0.01)
    }
}

#endif
