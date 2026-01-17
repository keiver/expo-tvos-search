import XCTest

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
        XCTAssertEqual(viewModel.placeholder, "Search movies and videos...")
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
}

#endif
