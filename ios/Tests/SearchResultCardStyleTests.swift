import XCTest
@testable import ExpoTvosSearchCore
import SwiftUI

#if os(tvOS)

/// Unit tests for SearchResultCardStyle.
///
/// The struct holds the card's resolution rules: overlay height defaulting and
/// clamping, and the focus-state colour fallback chains. Those used to live as
/// computed properties inside the view, where they could not be tested.
final class SearchResultCardStyleTests: XCTestCase {

    // MARK: - Defaults

    func testDefaults_matchTheDocumentedValues() {
        let style = SearchResultCardStyle()

        XCTAssertEqual(style.width, 280)
        XCTAssertEqual(style.height, 420)
        XCTAssertEqual(style.padding, 16)
        XCTAssertEqual(style.cornerRadius, 12)
        XCTAssertNil(style.backgroundColor)
        XCTAssertEqual(style.borderWidth, 0)
        XCTAssertNil(style.borderColor)
        XCTAssertFalse(style.showFocusBorder)
        XCTAssertEqual(style.focusBorderWidth, 4)
        XCTAssertEqual(style.focusStyle, .system)
        XCTAssertEqual(style.focusScale, 1)
        XCTAssertNil(style.focusGlowColor)
        XCTAssertEqual(style.focusGlowOpacity, 0.55, accuracy: 0.0001)
        XCTAssertEqual(style.focusGlowRadius, 0)
        XCTAssertEqual(style.overlayTitleSize, 20)
        XCTAssertEqual(style.overlayTitleWeight, .semibold)
        XCTAssertNil(style.overlayHeight)
        XCTAssertTrue(style.enableMarquee)
        XCTAssertEqual(style.marqueeDelay, 1.5, accuracy: 0.0001)
        XCTAssertEqual(style.marqueeSpeed, 30)
        XCTAssertEqual(style.marqueeMode, .loop)
        XCTAssertTrue(style.showTitleOverlay)
        XCTAssertFalse(style.showTitle)
        XCTAssertFalse(style.showSubtitle)
    }

    // MARK: - resolvedOverlayHeight

    func testOverlayHeight_defaultsToAQuarterOfTheCard() {
        let style = SearchResultCardStyle(height: 420)

        XCTAssertEqual(style.resolvedOverlayHeight, 105)
    }

    func testOverlayHeight_usesTheOverrideWhenSet() {
        let style = SearchResultCardStyle(height: 420, overlayHeight: 46)

        XCTAssertEqual(style.resolvedOverlayHeight, 46)
    }

    func testOverlayHeight_neverExceedsTheCardHeight() {
        // overlayHeight is clamped 0-500 without knowing the card height, so a tall
        // overlay on a short card would otherwise be silently eaten by the clip shape
        let style = SearchResultCardStyle(height: 200, overlayHeight: 500)

        XCTAssertEqual(style.resolvedOverlayHeight, 200)
    }

    func testOverlayHeight_zeroOverrideIsHonored() {
        let style = SearchResultCardStyle(height: 420, overlayHeight: 0)

        XCTAssertEqual(style.resolvedOverlayHeight, 0)
    }

    func testOverlayHeight_negativeOverrideFloorsAtZero() {
        let style = SearchResultCardStyle(height: 420, overlayHeight: -50)

        XCTAssertEqual(style.resolvedOverlayHeight, 0)
    }

    func testOverlayHeight_negativeCardHeightDoesNotProduceANegativeOverlay() {
        let style = SearchResultCardStyle(height: -100)

        XCTAssertEqual(style.resolvedOverlayHeight, 0)
    }

    // MARK: - resolvedGlowColor

    func testGlowColor_fallsBackToTheAccentColor() {
        // Setting only focusGlowRadius should still produce a matching glow
        let style = SearchResultCardStyle(focusGlowOpacity: 0.55, accentColor: .red)

        XCTAssertEqual(style.resolvedGlowColor, Color.red.opacity(0.55))
    }

    func testGlowColor_prefersTheExplicitColor() {
        let style = SearchResultCardStyle(
            focusGlowColor: .green,
            focusGlowOpacity: 0.55,
            accentColor: .red
        )

        XCTAssertEqual(style.resolvedGlowColor, Color.green.opacity(0.55))
    }

    func testGlowColor_appliesTheConfiguredOpacity() {
        let style = SearchResultCardStyle(focusGlowColor: .blue, focusGlowOpacity: 0.25)

        XCTAssertEqual(style.resolvedGlowColor, Color.blue.opacity(0.25))
    }

    // MARK: - overlayFill

    func testOverlayFill_nilByDefaultSoTheBlurMaterialIsUsed() {
        let style = SearchResultCardStyle()

        XCTAssertNil(style.overlayFill(isFocused: false))
        XCTAssertNil(style.overlayFill(isFocused: true))
    }

    func testOverlayFill_focusedFallsBackToTheRestingColor() {
        let style = SearchResultCardStyle(overlayBackgroundColor: .black)

        XCTAssertEqual(style.overlayFill(isFocused: false), .black)
        XCTAssertEqual(style.overlayFill(isFocused: true), .black)
    }

    func testOverlayFill_focusedOverrideWins() {
        let style = SearchResultCardStyle(
            overlayBackgroundColor: .black,
            overlayBackgroundColorFocused: .yellow
        )

        XCTAssertEqual(style.overlayFill(isFocused: false), .black)
        XCTAssertEqual(style.overlayFill(isFocused: true), .yellow)
    }

    func testOverlayFill_focusedOverrideAloneLeavesTheRestingBlurIntact() {
        // A card that is blurred at rest and solid on focus
        let style = SearchResultCardStyle(overlayBackgroundColorFocused: .yellow)

        XCTAssertNil(style.overlayFill(isFocused: false))
        XCTAssertEqual(style.overlayFill(isFocused: true), .yellow)
    }

    // MARK: - overlayForeground

    func testOverlayForeground_defaultsToWhiteInBothStates() {
        let style = SearchResultCardStyle()

        XCTAssertEqual(style.overlayForeground(isFocused: false), .white)
        XCTAssertEqual(style.overlayForeground(isFocused: true), .white)
    }

    func testOverlayForeground_focusedFallsBackToTheRestingColor() {
        let style = SearchResultCardStyle(overlayTextColor: .gray)

        XCTAssertEqual(style.overlayForeground(isFocused: false), .gray)
        XCTAssertEqual(style.overlayForeground(isFocused: true), .gray)
    }

    func testOverlayForeground_focusedOverrideWins() {
        let style = SearchResultCardStyle(
            overlayTextColor: .white,
            overlayTextColorFocused: .black
        )

        XCTAssertEqual(style.overlayForeground(isFocused: false), .white)
        XCTAssertEqual(style.overlayForeground(isFocused: true), .black)
    }

    func testOverlayForeground_focusedOverrideAloneStillDefaultsRestingToWhite() {
        let style = SearchResultCardStyle(overlayTextColorFocused: .black)

        XCTAssertEqual(style.overlayForeground(isFocused: false), .white)
        XCTAssertEqual(style.overlayForeground(isFocused: true), .black)
    }

    // MARK: - hasExternalText

    func testHasExternalText_falseWhenNeitherIsShown() {
        XCTAssertFalse(SearchResultCardStyle().hasExternalText)
    }

    func testHasExternalText_trueWhenEitherIsShown() {
        XCTAssertTrue(SearchResultCardStyle(showTitle: true).hasExternalText)
        XCTAssertTrue(SearchResultCardStyle(showSubtitle: true).hasExternalText)
    }
}

#endif
