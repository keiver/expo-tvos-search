import XCTest

#if os(tvOS)

/// Unit tests for SearchResultItem data model
final class SearchResultItemTests: XCTestCase {

    // MARK: - Initialization Tests

    func testInit_allProperties() {
        let item = SearchResultItem(
            id: "123",
            title: "Test Movie",
            subtitle: "2024",
            imageUrl: "https://example.com/poster.jpg"
        )

        XCTAssertEqual(item.id, "123")
        XCTAssertEqual(item.title, "Test Movie")
        XCTAssertEqual(item.subtitle, "2024")
        XCTAssertEqual(item.imageUrl, "https://example.com/poster.jpg")
    }

    func testInit_minimalProperties() {
        let item = SearchResultItem(
            id: "456",
            title: "Minimal Movie",
            subtitle: nil,
            imageUrl: nil
        )

        XCTAssertEqual(item.id, "456")
        XCTAssertEqual(item.title, "Minimal Movie")
        XCTAssertNil(item.subtitle)
        XCTAssertNil(item.imageUrl)
    }

    // MARK: - Identifiable Conformance

    func testIdentifiable_idProperty() {
        let item = SearchResultItem(
            id: "unique-123",
            title: "Title",
            subtitle: nil,
            imageUrl: nil
        )

        XCTAssertEqual(item.id, "unique-123")
    }

    func testIdentifiable_emptyId() {
        let item = SearchResultItem(
            id: "",
            title: "Title",
            subtitle: nil,
            imageUrl: nil
        )

        XCTAssertEqual(item.id, "")
    }

    // MARK: - Equatable Conformance

    func testEquality_sameValues_areEqual() {
        let item1 = SearchResultItem(
            id: "1",
            title: "Movie",
            subtitle: "2024",
            imageUrl: "https://example.com/img.jpg"
        )
        let item2 = SearchResultItem(
            id: "1",
            title: "Movie",
            subtitle: "2024",
            imageUrl: "https://example.com/img.jpg"
        )

        XCTAssertEqual(item1, item2)
    }

    func testEquality_differentId_notEqual() {
        let item1 = SearchResultItem(id: "1", title: "Movie", subtitle: nil, imageUrl: nil)
        let item2 = SearchResultItem(id: "2", title: "Movie", subtitle: nil, imageUrl: nil)

        XCTAssertNotEqual(item1, item2)
    }

    func testEquality_differentTitle_notEqual() {
        let item1 = SearchResultItem(id: "1", title: "Movie A", subtitle: nil, imageUrl: nil)
        let item2 = SearchResultItem(id: "1", title: "Movie B", subtitle: nil, imageUrl: nil)

        XCTAssertNotEqual(item1, item2)
    }

    func testEquality_differentSubtitle_notEqual() {
        let item1 = SearchResultItem(id: "1", title: "Movie", subtitle: "2023", imageUrl: nil)
        let item2 = SearchResultItem(id: "1", title: "Movie", subtitle: "2024", imageUrl: nil)

        XCTAssertNotEqual(item1, item2)
    }

    func testEquality_differentImageUrl_notEqual() {
        let item1 = SearchResultItem(id: "1", title: "Movie", subtitle: nil, imageUrl: "url1")
        let item2 = SearchResultItem(id: "1", title: "Movie", subtitle: nil, imageUrl: "url2")

        XCTAssertNotEqual(item1, item2)
    }

    func testEquality_nilVsValue_notEqual() {
        let item1 = SearchResultItem(id: "1", title: "Movie", subtitle: nil, imageUrl: nil)
        let item2 = SearchResultItem(id: "1", title: "Movie", subtitle: "2024", imageUrl: nil)

        XCTAssertNotEqual(item1, item2)
    }

    func testEquality_bothNil_areEqual() {
        let item1 = SearchResultItem(id: "1", title: "Movie", subtitle: nil, imageUrl: nil)
        let item2 = SearchResultItem(id: "1", title: "Movie", subtitle: nil, imageUrl: nil)

        XCTAssertEqual(item1, item2)
    }

    // MARK: - Optional Properties Tests

    func testOptionalProperties_nilSubtitle() {
        let item = SearchResultItem(
            id: "1",
            title: "Title",
            subtitle: nil,
            imageUrl: "https://example.com"
        )

        XCTAssertNil(item.subtitle)
        XCTAssertNotNil(item.imageUrl)
    }

    func testOptionalProperties_nilImageUrl() {
        let item = SearchResultItem(
            id: "1",
            title: "Title",
            subtitle: "Subtitle",
            imageUrl: nil
        )

        XCTAssertNotNil(item.subtitle)
        XCTAssertNil(item.imageUrl)
    }

    func testOptionalProperties_emptyStringSubtitle() {
        let item = SearchResultItem(
            id: "1",
            title: "Title",
            subtitle: "",
            imageUrl: nil
        )

        XCTAssertNotNil(item.subtitle)
        XCTAssertEqual(item.subtitle, "")
    }

    // MARK: - Edge Cases

    func testLongTitle() {
        let longTitle = String(repeating: "A", count: 500)
        let item = SearchResultItem(
            id: "1",
            title: longTitle,
            subtitle: nil,
            imageUrl: nil
        )

        XCTAssertEqual(item.title.count, 500)
    }

    func testSpecialCharactersInTitle() {
        let specialTitle = "Movie: The Sequel (2024) - Director's Cut [4K]"
        let item = SearchResultItem(
            id: "1",
            title: specialTitle,
            subtitle: nil,
            imageUrl: nil
        )

        XCTAssertEqual(item.title, specialTitle)
    }

    func testUnicodeTitle() {
        let unicodeTitle = "映画 🎬 Film"
        let item = SearchResultItem(
            id: "1",
            title: unicodeTitle,
            subtitle: nil,
            imageUrl: nil
        )

        XCTAssertEqual(item.title, unicodeTitle)
    }
}

#endif
