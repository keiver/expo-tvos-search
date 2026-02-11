import XCTest

/// Unit tests for ImageUrlParser
final class ImageUrlParserTests: XCTestCase {

    // MARK: - allowedSchemes set

    func testAllowedSchemes_containsExpectedSchemes() {
        XCTAssertTrue(ImageUrlParser.allowedSchemes.contains("http"))
        XCTAssertTrue(ImageUrlParser.allowedSchemes.contains("https"))
        XCTAssertTrue(ImageUrlParser.allowedSchemes.contains("data"))
        XCTAssertTrue(ImageUrlParser.allowedSchemes.contains("file"))
    }

    func testAllowedSchemes_doesNotContainDangerousSchemes() {
        XCTAssertFalse(ImageUrlParser.allowedSchemes.contains("ftp"))
        XCTAssertFalse(ImageUrlParser.allowedSchemes.contains("javascript"))
        XCTAssertFalse(ImageUrlParser.allowedSchemes.contains("tel"))
        XCTAssertFalse(ImageUrlParser.allowedSchemes.contains("mailto"))
    }

    func testAllowedSchemes_exactCount() {
        XCTAssertEqual(ImageUrlParser.allowedSchemes.count, 4)
    }

    // MARK: - isAllowedScheme

    func testIsAllowedScheme_httpsUrl_returnsTrue() {
        XCTAssertTrue(ImageUrlParser.isAllowedScheme("https://example.com/image.png"))
    }

    func testIsAllowedScheme_httpUrl_returnsTrue() {
        XCTAssertTrue(ImageUrlParser.isAllowedScheme("http://example.com/image.png"))
    }

    func testIsAllowedScheme_fileUrl_returnsTrue() {
        XCTAssertTrue(ImageUrlParser.isAllowedScheme("file:///path/to/image.png"))
    }

    func testIsAllowedScheme_dataUri_returnsTrue() {
        XCTAssertTrue(ImageUrlParser.isAllowedScheme("data:image/png;base64,iVBOR"))
    }

    func testIsAllowedScheme_ftpUrl_returnsFalse() {
        XCTAssertFalse(ImageUrlParser.isAllowedScheme("ftp://example.com/image.png"))
    }

    func testIsAllowedScheme_javascriptScheme_returnsFalse() {
        XCTAssertFalse(ImageUrlParser.isAllowedScheme("javascript:alert(1)"))
    }

    func testIsAllowedScheme_customScheme_returnsFalse() {
        XCTAssertFalse(ImageUrlParser.isAllowedScheme("myapp://callback"))
    }

    func testIsAllowedScheme_emptyString_returnsFalse() {
        XCTAssertFalse(ImageUrlParser.isAllowedScheme(""))
    }

    func testIsAllowedScheme_noScheme_returnsFalse() {
        XCTAssertFalse(ImageUrlParser.isAllowedScheme("example.com/image.png"))
    }

    func testIsAllowedScheme_caseInsensitive_HTTP() {
        XCTAssertTrue(ImageUrlParser.isAllowedScheme("HTTP://example.com/image.png"))
    }

    func testIsAllowedScheme_caseInsensitive_HTTPS() {
        XCTAssertTrue(ImageUrlParser.isAllowedScheme("HTTPS://example.com/image.png"))
    }

    func testIsAllowedScheme_caseInsensitive_FILE() {
        XCTAssertTrue(ImageUrlParser.isAllowedScheme("FILE:///path/to/image.png"))
    }

    // MARK: - extractBase64

    func testExtractBase64_validDataUri_returnsBase64() {
        let result = ImageUrlParser.extractBase64(from: "data:image/png;base64,iVBORw0KGgo=")
        XCTAssertEqual(result, "iVBORw0KGgo=")
    }

    func testExtractBase64_noComma_returnsNil() {
        let result = ImageUrlParser.extractBase64(from: "data:image/png;base64")
        XCTAssertNil(result)
    }

    func testExtractBase64_emptyAfterComma_returnsEmptyString() {
        let result = ImageUrlParser.extractBase64(from: "data:image/png;base64,")
        XCTAssertEqual(result, "")
    }

    func testExtractBase64_multipleCommas_splitsOnFirst() {
        let result = ImageUrlParser.extractBase64(from: "data:text/plain,hello,world")
        XCTAssertEqual(result, "hello,world")
    }

    func testExtractBase64_emptyString_returnsNil() {
        let result = ImageUrlParser.extractBase64(from: "")
        XCTAssertNil(result)
    }

    func testExtractBase64_commaOnly_returnsEmptyString() {
        let result = ImageUrlParser.extractBase64(from: ",")
        XCTAssertEqual(result, "")
    }

    func testExtractBase64_commaAtStart_returnsRest() {
        let result = ImageUrlParser.extractBase64(from: ",abc123")
        XCTAssertEqual(result, "abc123")
    }

    // MARK: - decodeDataUri

    func testDecodeDataUri_validBase64_returnsData() {
        // "Hello" in base64 is "SGVsbG8="
        let dataUri = "data:text/plain;base64,SGVsbG8="
        let data = ImageUrlParser.decodeDataUri(dataUri)
        XCTAssertNotNil(data)
        XCTAssertEqual(String(data: data!, encoding: .utf8), "Hello")
    }

    func testDecodeDataUri_invalidBase64_returnsNil() {
        let dataUri = "data:image/png;base64,!!!not-valid-base64!!!"
        let data = ImageUrlParser.decodeDataUri(dataUri)
        XCTAssertNil(data)
    }

    func testDecodeDataUri_emptyPayload_returnsEmptyData() {
        // Empty string is valid base64 that decodes to empty Data
        let dataUri = "data:text/plain;base64,"
        let data = ImageUrlParser.decodeDataUri(dataUri)
        XCTAssertNotNil(data)
        XCTAssertEqual(data!.count, 0)
    }

    func testDecodeDataUri_noComma_returnsNil() {
        let data = ImageUrlParser.decodeDataUri("data:image/png;base64")
        XCTAssertNil(data)
    }

    func testDecodeDataUri_emptyString_returnsNil() {
        let data = ImageUrlParser.decodeDataUri("")
        XCTAssertNil(data)
    }

    func testDecodeDataUri_roundTrip_plainText() {
        let original = "Hello, World!"
        let base64 = Data(original.utf8).base64EncodedString()
        let dataUri = "data:text/plain;base64,\(base64)"
        let decoded = ImageUrlParser.decodeDataUri(dataUri)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(String(data: decoded!, encoding: .utf8), original)
    }

    func testDecodeDataUri_roundTrip_binaryData() {
        let original = Data([0x00, 0xFF, 0x42, 0x89, 0xAB])
        let base64 = original.base64EncodedString()
        let dataUri = "data:application/octet-stream;base64,\(base64)"
        let decoded = ImageUrlParser.decodeDataUri(dataUri)
        XCTAssertEqual(decoded, original)
    }

    func testDecodeDataUri_realWorldPngHeader() {
        // PNG magic bytes: 89 50 4E 47 0D 0A 1A 0A
        let pngHeader = Data([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A])
        let base64 = pngHeader.base64EncodedString()
        let dataUri = "data:image/png;base64,\(base64)"
        let decoded = ImageUrlParser.decodeDataUri(dataUri)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded!.count, 8)
        XCTAssertEqual(decoded![0], 0x89) // PNG signature byte
    }
}
