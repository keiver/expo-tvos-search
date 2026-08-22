import XCTest
@testable import ExpoTvosSearchCore
import SwiftUI

#if os(tvOS)

/// Unit tests for SearchViewModel
final class SearchViewModelTests: XCTestCase {
    var viewModel: SearchViewModel!

    override func setUp() {
        super.setUp()
        viewModel = SearchViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func testInitialState_resultsEmpty() {
        XCTAssertTrue(viewModel.results.isEmpty)
    }

    func testInitialState_isLoadingFalse() {
        XCTAssertFalse(viewModel.isLoading)
    }

    func testInitialState_searchTextEmpty() {
        XCTAssertEqual(viewModel.searchText, "")
    }

    func testInitialState_defaultColumns() {
        XCTAssertEqual(viewModel.columns, 5)
    }

    func testInitialState_defaultPlaceholder() {
        XCTAssertEqual(viewModel.placeholder, "Search...")
    }

    func testInitialState_showTitleFalse() {
        XCTAssertFalse(viewModel.showTitle)
    }

    func testInitialState_showSubtitleFalse() {
        XCTAssertFalse(viewModel.showSubtitle)
    }

    func testInitialState_showFocusBorderFalse() {
        XCTAssertFalse(viewModel.showFocusBorder)
    }

    func testInitialState_topInsetZero() {
        XCTAssertEqual(viewModel.topInset, 0)
    }

    // MARK: - Title Overlay Config Initial State

    func testInitialState_showTitleOverlayTrue() {
        XCTAssertTrue(viewModel.showTitleOverlay)
    }

    func testInitialState_enableMarqueeTrue() {
        XCTAssertTrue(viewModel.enableMarquee)
    }

    func testInitialState_marqueeDelayDefault() {
        XCTAssertEqual(viewModel.marqueeDelay, 1.5, accuracy: 0.001)
    }

    // MARK: - Property Updates

    func testColumnsUpdate() {
        viewModel.columns = 3
        XCTAssertEqual(viewModel.columns, 3)
    }

    func testPlaceholderUpdate() {
        viewModel.placeholder = "Custom placeholder"
        XCTAssertEqual(viewModel.placeholder, "Custom placeholder")
    }

    func testShowTitleUpdate() {
        viewModel.showTitle = true
        XCTAssertTrue(viewModel.showTitle)
    }

    func testShowSubtitleUpdate() {
        viewModel.showSubtitle = true
        XCTAssertTrue(viewModel.showSubtitle)
    }

    func testShowFocusBorderUpdate() {
        viewModel.showFocusBorder = true
        XCTAssertTrue(viewModel.showFocusBorder)
    }

    func testTopInsetUpdate() {
        viewModel.topInset = 100
        XCTAssertEqual(viewModel.topInset, 100)
    }

    // MARK: - Title Overlay Config Updates

    func testShowTitleOverlayUpdate() {
        viewModel.showTitleOverlay = false
        XCTAssertFalse(viewModel.showTitleOverlay)
    }

    func testEnableMarqueeUpdate() {
        viewModel.enableMarquee = false
        XCTAssertFalse(viewModel.enableMarquee)
    }

    func testMarqueeDelayUpdate() {
        viewModel.marqueeDelay = 2.5
        XCTAssertEqual(viewModel.marqueeDelay, 2.5, accuracy: 0.001)
    }

    func testMarqueeDelayUpdate_zeroValue() {
        viewModel.marqueeDelay = 0
        XCTAssertEqual(viewModel.marqueeDelay, 0, accuracy: 0.001)
    }

    // MARK: - Results Tests

    func testResultsUpdate() {
        let item = SearchResultItem(id: "1", title: "Test Movie", subtitle: "2024", imageUrl: nil)
        viewModel.results = [item]

        XCTAssertEqual(viewModel.results.count, 1)
        XCTAssertEqual(viewModel.results.first?.title, "Test Movie")
    }

    func testResultsClear() {
        let item = SearchResultItem(id: "1", title: "Test Movie", subtitle: nil, imageUrl: nil)
        viewModel.results = [item]
        viewModel.results = []

        XCTAssertTrue(viewModel.results.isEmpty)
    }

    // MARK: - Callback Tests

    func testOnSearchCallback() {
        var capturedQuery: String?
        viewModel.onSearch = { query in
            capturedQuery = query
        }

        viewModel.onSearch?("test query")

        XCTAssertEqual(capturedQuery, "test query")
    }

    func testOnSelectItemCallback() {
        var capturedId: String?
        viewModel.onSelectItem = { id in
            capturedId = id
        }

        viewModel.onSelectItem?("item-123")

        XCTAssertEqual(capturedId, "item-123")
    }

    func testOnSearchCallback_emptyQuery() {
        var capturedQuery: String?
        viewModel.onSearch = { query in
            capturedQuery = query
        }

        viewModel.onSearch?("")

        XCTAssertEqual(capturedQuery, "")
    }

    func testCallbacksNil_noError() {
        viewModel.onSearch = nil
        viewModel.onSelectItem = nil

        viewModel.onSearch?("test")
        viewModel.onSelectItem?("test")
    }

    // MARK: - Published Property Tests

    func testIsLoadingPublished() {
        viewModel.isLoading = true
        XCTAssertTrue(viewModel.isLoading)

        viewModel.isLoading = false
        XCTAssertFalse(viewModel.isLoading)
    }

    func testSearchTextPublished() {
        viewModel.searchText = "action"
        XCTAssertEqual(viewModel.searchText, "action")
    }

    // MARK: - Card Appearance Defaults
    //
    // These back the claim that the card appearance props are not a visual change
    // for existing consumers. If a default drifts, the rendered card changes for
    // everyone who never set that prop.

    func testInitialState_cardShellDefaults() {
        XCTAssertEqual(viewModel.cardCornerRadius, 12)
        XCTAssertNil(viewModel.cardBackgroundColor)
        XCTAssertEqual(viewModel.borderWidth, 0, "no resting border unless opted in")
        XCTAssertNil(viewModel.borderColor)
        XCTAssertEqual(viewModel.focusBorderWidth, 4)
    }

    func testInitialState_focusDefaults() {
        XCTAssertEqual(viewModel.focusStyle, .system)
        XCTAssertEqual(viewModel.focusScale, 1, "no scaling unless opted in")
        XCTAssertNil(viewModel.focusGlowColor)
        XCTAssertEqual(viewModel.focusGlowOpacity, 0.55, accuracy: 0.001)
        XCTAssertEqual(viewModel.focusGlowRadius, 0, "glow is off unless a radius is set")
    }

    func testInitialState_overlayDefaults() {
        XCTAssertNil(viewModel.overlayBackgroundColor, "nil keeps the native blur material")
        XCTAssertNil(viewModel.overlayTextColor)
        XCTAssertNil(viewModel.overlayBackgroundColorFocused)
        XCTAssertNil(viewModel.overlayTextColorFocused)
        XCTAssertEqual(viewModel.overlayTitleWeight, .semibold)
        XCTAssertNil(viewModel.overlayHeight, "nil means 25% of the card height")
    }

    func testInitialState_marqueeDefaults() {
        XCTAssertEqual(viewModel.marqueeSpeed, 30)
        XCTAssertEqual(viewModel.marqueeMode, .loop)
    }

    // MARK: - cardStyle

    func testCardStyle_mirrorsTheModel() {
        let style = viewModel.cardStyle

        XCTAssertEqual(style.width, viewModel.cardWidth)
        XCTAssertEqual(style.height, viewModel.cardHeight)
        XCTAssertEqual(style.padding, viewModel.cardPadding)
        XCTAssertEqual(style.cornerRadius, viewModel.cardCornerRadius)
        XCTAssertEqual(style.borderWidth, viewModel.borderWidth)
        XCTAssertEqual(style.showFocusBorder, viewModel.showFocusBorder)
        XCTAssertEqual(style.focusBorderWidth, viewModel.focusBorderWidth)
        XCTAssertEqual(style.focusStyle, viewModel.focusStyle)
        XCTAssertEqual(style.focusScale, viewModel.focusScale)
        XCTAssertEqual(style.focusGlowRadius, viewModel.focusGlowRadius)
        XCTAssertEqual(style.showTitle, viewModel.showTitle)
        XCTAssertEqual(style.showSubtitle, viewModel.showSubtitle)
        XCTAssertEqual(style.showTitleOverlay, viewModel.showTitleOverlay)
        XCTAssertEqual(style.overlayTitleSize, viewModel.overlayTitleSize)
        XCTAssertEqual(style.overlayTitleWeight, viewModel.overlayTitleWeight)
        XCTAssertEqual(style.enableMarquee, viewModel.enableMarquee)
        XCTAssertEqual(style.marqueeDelay, viewModel.marqueeDelay, accuracy: 0.001)
        XCTAssertEqual(style.marqueeSpeed, viewModel.marqueeSpeed)
        XCTAssertEqual(style.marqueeMode, viewModel.marqueeMode)
        XCTAssertEqual(style.accentColor, viewModel.accentColor)
    }

    func testCardStyle_propagatesChanges() {
        viewModel.cardCornerRadius = 32
        viewModel.focusGlowRadius = 7
        viewModel.focusStyle = .custom
        viewModel.marqueeMode = .bounce
        viewModel.overlayHeight = 46

        let style = viewModel.cardStyle

        XCTAssertEqual(style.cornerRadius, 32)
        XCTAssertEqual(style.focusGlowRadius, 7)
        XCTAssertEqual(style.focusStyle, .custom)
        XCTAssertEqual(style.marqueeMode, .bounce)
        XCTAssertEqual(style.resolvedOverlayHeight, 46)
    }

    func testCardStyle_defaultAccentIsTheDocumentedGold() {
        // #FFC312, the value both the README and the TypeScript defaults claim
        XCTAssertEqual(viewModel.cardStyle.accentColor, Color(red: 1, green: 0.765, blue: 0.07))
    }

    // MARK: - Focus tracking

    func testInitialState_noFocusedItem() {
        XCTAssertNil(viewModel.focusedItemId)
    }

    func testSetFocused_tracksTheFocusedCard() {
        viewModel.setFocused("a", true)

        XCTAssertEqual(viewModel.focusedItemId, "a")
    }

    func testSetFocused_blurClearsTheCard() {
        viewModel.setFocused("a", true)
        viewModel.setFocused("a", false)

        XCTAssertNil(viewModel.focusedItemId)
    }

    func testSetFocused_lateBlurDoesNotClearItsSuccessor() {
        viewModel.setFocused("a", true)
        viewModel.setFocused("b", true)
        viewModel.setFocused("a", false)

        XCTAssertEqual(viewModel.focusedItemId, "b")
    }

    // MARK: - Long press

    func testLongSelect_reportsTheFocusedCard() {
        var longPressed: String?
        viewModel.onLongSelectItem = { longPressed = $0 }
        viewModel.setFocused("a", true)

        XCTAssertTrue(viewModel.longSelectFocusedItem())
        XCTAssertEqual(longPressed, "a")
    }

    func testLongSelect_noFocusedCardFiresNothing() {
        var fired = false
        viewModel.onLongSelectItem = { _ in fired = true }

        XCTAssertFalse(viewModel.longSelectFocusedItem())
        XCTAssertFalse(fired)
    }

    func testSelect_firesWithoutALongPress() {
        var selected: String?
        viewModel.onSelectItem = { selected = $0 }

        viewModel.selectItem("a")

        XCTAssertEqual(selected, "a")
    }

    func testSelect_swallowsTheReleaseThatEndsALongPress() {
        var selected: String?
        let start = Date(timeIntervalSince1970: 0)
        viewModel.onSelectItem = { selected = $0 }
        viewModel.setFocused("a", true)

        viewModel.longSelectFocusedItem(now: start)
        viewModel.selectItem("a", now: start.addingTimeInterval(0.1))

        XCTAssertNil(selected)
    }

    func testSelect_swallowsOnlyOneRelease() {
        var selected: String?
        let start = Date(timeIntervalSince1970: 0)
        viewModel.onSelectItem = { selected = $0 }
        viewModel.setFocused("a", true)

        viewModel.longSelectFocusedItem(now: start)
        viewModel.selectItem("a", now: start.addingTimeInterval(0.1))
        viewModel.selectItem("a", now: start.addingTimeInterval(0.2))

        XCTAssertEqual(selected, "a")
    }

    func testSelect_windowExpiresSoASlowReleaseStillSelects() {
        var selected: String?
        let start = Date(timeIntervalSince1970: 0)
        viewModel.onSelectItem = { selected = $0 }
        viewModel.setFocused("a", true)

        viewModel.longSelectFocusedItem(now: start)
        viewModel.selectItem("a", now: start.addingTimeInterval(5))

        XCTAssertEqual(selected, "a")
    }
}

#endif
