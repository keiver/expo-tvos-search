import SwiftUI

// MARK: - Color Extension for Hex String Parsing
extension Color {
    /// Initialize a Color from a hex string (e.g., "#FFFFFF", "#FF5733", "FFC312")
    /// Returns nil if the string cannot be parsed as a valid hex color.
    /// Parsing logic is in HexColorParser for testability.
    init?(hex: String) {
        guard let rgba = HexColorParser.parse(hex) else {
            return nil
        }
        self.init(.sRGB, red: rgba.red, green: rgba.green, blue: rgba.blue, opacity: rgba.alpha)
    }
}
