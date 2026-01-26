import Foundation

/// Parses hex color strings into RGBA components.
/// Extracted from the Color extension to enable unit testing without tvOS target.
struct HexColorParser {
    struct RGBA: Equatable {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
    }

    /// Maximum input length for hex color strings to prevent DoS from very long strings.
    static let maxInputLength = 20

    /// Parses a hex color string into RGBA components (0.0–1.0 range).
    /// Supports 3-char (RGB), 6-char (RRGGBB), and 8-char (AARRGGBB) formats.
    /// Leading "#" or other non-alphanumeric characters are stripped.
    /// Returns nil if the string cannot be parsed.
    static func parse(_ hex: String) -> RGBA? {
        guard hex.count <= maxInputLength else {
            return nil
        }

        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

        guard hex.count == 3 || hex.count == 6 || hex.count == 8 else {
            return nil
        }

        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int) else {
            return nil
        }

        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        return RGBA(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
}
