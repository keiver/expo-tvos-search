import Foundation

/// Parses and validates image URL strings for the search view.
/// Extracted from view code to enable unit testing without tvOS target.
struct ImageUrlParser {

    /// Accepted URL schemes for image loading.
    /// Single source of truth — used by both CachedAsyncImage and ExpoTvosSearchView.
    static let allowedSchemes: Set<String> = ["http", "https", "data", "file"]

    /// Returns true if the URL string has an allowed scheme.
    static func isAllowedScheme(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString),
              let scheme = url.scheme?.lowercased() else {
            return false
        }
        return allowedSchemes.contains(scheme)
    }

    /// Extracts the base64 payload from a data URI string by splitting on the first comma.
    /// Returns nil if there is no comma in the string or the string is empty.
    static func extractBase64(from dataUriString: String) -> String? {
        guard !dataUriString.isEmpty,
              let commaIndex = dataUriString.firstIndex(of: ",") else {
            return nil
        }
        return String(dataUriString[dataUriString.index(after: commaIndex)...])
    }

    /// Decodes a data URI string into raw Data.
    /// Extracts the base64 payload after the first comma, then decodes it.
    /// Returns nil if extraction fails or the base64 is invalid.
    static func decodeDataUri(_ dataUriString: String) -> Data? {
        guard let base64String = extractBase64(from: dataUriString) else {
            return nil
        }
        return Data(base64Encoded: base64String)
    }
}
