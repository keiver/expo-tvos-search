import XCTest

/// Unit tests for HexColorParser
final class HexColorParserTests: XCTestCase {

    // MARK: - 6-character hex (RRGGBB)

    func testParse_6charWithHash_white() {
        let rgba = HexColorParser.parse("#FFFFFF")
        XCTAssertNotNil(rgba)
        XCTAssertEqual(rgba!.red, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.green, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.blue, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.alpha, 1.0, accuracy: 0.001)
    }

    func testParse_6charWithHash_black() {
        let rgba = HexColorParser.parse("#000000")
        XCTAssertNotNil(rgba)
        XCTAssertEqual(rgba!.red, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.green, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.blue, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.alpha, 1.0, accuracy: 0.001)
    }

    func testParse_6charWithHash_red() {
        let rgba = HexColorParser.parse("#FF0000")
        XCTAssertNotNil(rgba)
        XCTAssertEqual(rgba!.red, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.green, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.blue, 0.0, accuracy: 0.001)
    }

    func testParse_6charWithoutHash() {
        let rgba = HexColorParser.parse("FFC312")
        XCTAssertNotNil(rgba)
        XCTAssertEqual(rgba!.red, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.green, 0.765, accuracy: 0.001)
        XCTAssertEqual(rgba!.blue, Double(0x12) / 255, accuracy: 0.001)
    }

    func testParse_6charLowercase() {
        let rgba = HexColorParser.parse("#ff5733")
        XCTAssertNotNil(rgba)
        XCTAssertEqual(rgba!.red, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.green, Double(0x57) / 255, accuracy: 0.001)
        XCTAssertEqual(rgba!.blue, Double(0x33) / 255, accuracy: 0.001)
    }

    // MARK: - 3-character hex (RGB shorthand)

    func testParse_3charWithHash_white() {
        let rgba = HexColorParser.parse("#FFF")
        XCTAssertNotNil(rgba)
        XCTAssertEqual(rgba!.red, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.green, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.blue, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.alpha, 1.0, accuracy: 0.001)
    }

    func testParse_3charWithHash_black() {
        let rgba = HexColorParser.parse("#000")
        XCTAssertNotNil(rgba)
        XCTAssertEqual(rgba!.red, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.green, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.blue, 0.0, accuracy: 0.001)
    }

    func testParse_3char_expandsCorrectly() {
        // #F80 should expand to #FF8800
        let rgba = HexColorParser.parse("#F80")
        XCTAssertNotNil(rgba)
        XCTAssertEqual(rgba!.red, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.green, Double(0x88) / 255, accuracy: 0.001)
        XCTAssertEqual(rgba!.blue, 0.0, accuracy: 0.001)
    }

    // MARK: - 8-character hex (AARRGGBB)

    func testParse_8charWithHash_fullAlpha() {
        let rgba = HexColorParser.parse("#FFFF0000")
        XCTAssertNotNil(rgba)
        XCTAssertEqual(rgba!.alpha, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.red, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.green, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.blue, 0.0, accuracy: 0.001)
    }

    func testParse_8charWithHash_halfAlpha() {
        let rgba = HexColorParser.parse("#80FF0000")
        XCTAssertNotNil(rgba)
        XCTAssertEqual(rgba!.alpha, Double(0x80) / 255, accuracy: 0.001)
        XCTAssertEqual(rgba!.red, 1.0, accuracy: 0.001)
    }

    func testParse_8charWithHash_zeroAlpha() {
        let rgba = HexColorParser.parse("#00FFFFFF")
        XCTAssertNotNil(rgba)
        XCTAssertEqual(rgba!.alpha, 0.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.red, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.green, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.blue, 1.0, accuracy: 0.001)
    }

    // MARK: - Invalid inputs

    func testParse_emptyString_returnsNil() {
        XCTAssertNil(HexColorParser.parse(""))
    }

    func testParse_hashOnly_returnsNil() {
        XCTAssertNil(HexColorParser.parse("#"))
    }

    func testParse_invalidHexChars_returnsNil() {
        XCTAssertNil(HexColorParser.parse("#GGGGGG"))
    }

    func testParse_wrongLength_4chars_returnsNil() {
        XCTAssertNil(HexColorParser.parse("#ABCD"))
    }

    func testParse_wrongLength_5chars_returnsNil() {
        XCTAssertNil(HexColorParser.parse("#ABCDE"))
    }

    func testParse_wrongLength_7chars_returnsNil() {
        XCTAssertNil(HexColorParser.parse("#ABCDEFF"))
    }

    func testParse_tooLongString_returnsNil() {
        let longString = String(repeating: "A", count: 21)
        XCTAssertNil(HexColorParser.parse(longString))
    }

    func testParse_maxLengthString_stillParsed() {
        // 20 chars is at the limit. After stripping "#", we get 19 chars which is > 8, so nil.
        let atLimit = "#" + String(repeating: "F", count: 19)
        XCTAssertEqual(atLimit.count, 20)
        XCTAssertNil(HexColorParser.parse(atLimit)) // 19 hex chars is not 3, 6, or 8
    }

    func testParse_exactlyMaxLength_valid8char() {
        // A valid 8-char hex within the 20-char limit
        let valid = "#FFAABBCC"
        XCTAssertEqual(valid.count, 9) // well under 20
        XCTAssertNotNil(HexColorParser.parse(valid))
    }

    // MARK: - Edge cases

    func testParse_mixedCase() {
        let rgba = HexColorParser.parse("#aAbBcC")
        XCTAssertNotNil(rgba)
        XCTAssertEqual(rgba!.red, Double(0xAA) / 255, accuracy: 0.001)
        XCTAssertEqual(rgba!.green, Double(0xBB) / 255, accuracy: 0.001)
        XCTAssertEqual(rgba!.blue, Double(0xCC) / 255, accuracy: 0.001)
    }

    func testParse_defaultAccentColor_FFC312() {
        // This is the actual default accent color used by the library
        let rgba = HexColorParser.parse("#FFC312")
        XCTAssertNotNil(rgba)
        XCTAssertEqual(rgba!.red, 1.0, accuracy: 0.001)
        XCTAssertEqual(rgba!.green, 0.765, accuracy: 0.001)
        XCTAssertEqual(rgba!.blue, Double(0x12) / 255, accuracy: 0.001)
        XCTAssertEqual(rgba!.alpha, 1.0, accuracy: 0.001)
    }

    // MARK: - RGBA Equatable conformance

    func testRGBA_equality() {
        let a = HexColorParser.RGBA(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        let b = HexColorParser.RGBA(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        XCTAssertEqual(a, b)
    }

    func testRGBA_inequality() {
        let a = HexColorParser.RGBA(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        let b = HexColorParser.RGBA(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
        XCTAssertNotEqual(a, b)
    }
}
