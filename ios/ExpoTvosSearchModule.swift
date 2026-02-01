import ExpoModulesCore

public class ExpoTvosSearchModule: Module {
    // Validation constants
    private static let minColumns = 1
    private static let maxColumns = 10
    private static let maxResults = 500
    private static let maxMarqueeDelay: Double = 60.0
    private static let maxStringLength = 500

    /// Truncates a string to maxStringLength and emits a validation warning if truncation occurred.
    private static func truncateString(
        _ value: String,
        propName: String,
        view: ExpoTvosSearchView
    ) -> String {
        let truncated = String(value.prefix(maxStringLength))
        if truncated.count < value.count {
            view.onValidationWarning([
                "type": "value_truncated",
                "message": "\(propName) truncated to \(maxStringLength) characters",
                "context": "original length: \(value.count)"
            ])
        }
        return truncated
    }

    public func definition() -> ModuleDefinition {
        Name("ExpoTvosSearch")

        View(ExpoTvosSearchView.self) {
            Events("onSearch", "onSelectItem", "onError", "onValidationWarning", "onSearchFieldFocused", "onSearchFieldBlurred")

            Prop("results") { (view: ExpoTvosSearchView, results: [[String: Any]]) in
                // Limit results array size to prevent memory issues
                let limitedResults = Array(results.prefix(Self.maxResults))
                if results.count > Self.maxResults {
                    view.onValidationWarning([
                        "type": "value_clamped",
                        "message": "Results array truncated from \(results.count) to \(Self.maxResults) items",
                        "context": "maxResults=\(Self.maxResults)"
                    ])
                }
                view.updateResults(limitedResults)
            }

            Prop("columns") { (view: ExpoTvosSearchView, columns: Int) in
                // Clamp columns between min and max for safe grid layout
                let clampedValue = min(max(Self.minColumns, columns), Self.maxColumns)
                if clampedValue != columns {
                    view.onValidationWarning([
                        "type": "value_clamped",
                        "message": "columns value \(columns) was clamped to range [\(Self.minColumns), \(Self.maxColumns)]",
                        "context": "columns=\(clampedValue)"
                    ])
                }
                view.columns = clampedValue
            }

            Prop("placeholder") { (view: ExpoTvosSearchView, placeholder: String) in
                view.placeholder = Self.truncateString(placeholder, propName: "placeholder", view: view)
            }

            Prop("searchText") { (view: ExpoTvosSearchView, text: String?) in
                if let text = text {
                    view.searchTextProp = Self.truncateString(text, propName: "searchText", view: view)
                } else {
                    view.searchTextProp = nil
                }
            }

            Prop("isLoading") { (view: ExpoTvosSearchView, isLoading: Bool) in
                view.isLoading = isLoading
            }

            Prop("showTitle") { (view: ExpoTvosSearchView, showTitle: Bool) in
                view.showTitle = showTitle
            }

            Prop("showSubtitle") { (view: ExpoTvosSearchView, showSubtitle: Bool) in
                view.showSubtitle = showSubtitle
            }

            Prop("showFocusBorder") { (view: ExpoTvosSearchView, showFocusBorder: Bool) in
                view.showFocusBorder = showFocusBorder
            }

            Prop("topInset") { (view: ExpoTvosSearchView, topInset: Double) in
                // Clamp to non-negative values (max 500 points reasonable for any screen)
                let clampedValue = min(max(0, topInset), 500)
                if clampedValue != topInset {
                    view.onValidationWarning([
                        "type": "value_clamped",
                        "message": "topInset value \(topInset) was clamped to range [0, 500]",
                        "context": "topInset=\(clampedValue)"
                    ])
                }
                view.topInset = CGFloat(clampedValue)
            }

            Prop("showTitleOverlay") { (view: ExpoTvosSearchView, show: Bool) in
                view.showTitleOverlay = show
            }

            Prop("enableMarquee") { (view: ExpoTvosSearchView, enable: Bool) in
                view.enableMarquee = enable
            }

            Prop("marqueeDelay") { (view: ExpoTvosSearchView, delay: Double) in
                // Clamp between 0 and maxMarqueeDelay seconds
                let clampedValue = min(max(0, delay), Self.maxMarqueeDelay)
                if clampedValue != delay {
                    view.onValidationWarning([
                        "type": "value_clamped",
                        "message": "marqueeDelay value \(delay) was clamped to range [0, \(Self.maxMarqueeDelay)]",
                        "context": "marqueeDelay=\(clampedValue)"
                    ])
                }
                view.marqueeDelay = clampedValue
            }

            Prop("emptyStateText") { (view: ExpoTvosSearchView, text: String) in
                view.emptyStateText = Self.truncateString(text, propName: "emptyStateText", view: view)
            }

            Prop("searchingText") { (view: ExpoTvosSearchView, text: String) in
                view.searchingText = Self.truncateString(text, propName: "searchingText", view: view)
            }

            Prop("noResultsText") { (view: ExpoTvosSearchView, text: String) in
                view.noResultsText = Self.truncateString(text, propName: "noResultsText", view: view)
            }

            Prop("noResultsHintText") { (view: ExpoTvosSearchView, text: String) in
                view.noResultsHintText = Self.truncateString(text, propName: "noResultsHintText", view: view)
            }

            Prop("textColor") { (view: ExpoTvosSearchView, colorHex: String?) in
                view.textColor = colorHex
            }

            Prop("accentColor") { (view: ExpoTvosSearchView, colorHex: String) in
                view.accentColor = colorHex
            }

            Prop("colorScheme") { (view: ExpoTvosSearchView, scheme: String) in
                view.colorScheme = scheme
            }

            Prop("cardWidth") { (view: ExpoTvosSearchView, width: Double) in
                let clampedValue = min(max(50, width), 1000)
                if clampedValue != width {
                    view.onValidationWarning([
                        "type": "value_clamped",
                        "message": "cardWidth value \(width) was clamped to range [50, 1000]",
                        "context": "cardWidth=\(clampedValue)"
                    ])
                }
                view.cardWidth = CGFloat(clampedValue)
            }

            Prop("cardHeight") { (view: ExpoTvosSearchView, height: Double) in
                let clampedValue = min(max(50, height), 1000)
                if clampedValue != height {
                    view.onValidationWarning([
                        "type": "value_clamped",
                        "message": "cardHeight value \(height) was clamped to range [50, 1000]",
                        "context": "cardHeight=\(clampedValue)"
                    ])
                }
                view.cardHeight = CGFloat(clampedValue)
            }

            Prop("imageContentMode") { (view: ExpoTvosSearchView, mode: String) in
                view.imageContentMode = mode
            }

            Prop("cardMargin") { (view: ExpoTvosSearchView, margin: Double) in
                let clampedValue = min(max(0, margin), 200)
                if clampedValue != margin {
                    view.onValidationWarning([
                        "type": "value_clamped",
                        "message": "cardMargin value \(margin) was clamped to range [0, 200]",
                        "context": "cardMargin=\(clampedValue)"
                    ])
                }
                view.cardMargin = CGFloat(clampedValue)
            }

            Prop("cardPadding") { (view: ExpoTvosSearchView, padding: Double) in
                let clampedValue = min(max(0, padding), 100)
                if clampedValue != padding {
                    view.onValidationWarning([
                        "type": "value_clamped",
                        "message": "cardPadding value \(padding) was clamped to range [0, 100]",
                        "context": "cardPadding=\(clampedValue)"
                    ])
                }
                view.cardPadding = CGFloat(clampedValue)
            }

            Prop("overlayTitleSize") { (view: ExpoTvosSearchView, size: Double) in
                let clampedValue = min(max(8, size), 72)
                if clampedValue != size {
                    view.onValidationWarning([
                        "type": "value_clamped",
                        "message": "overlayTitleSize value \(size) was clamped to range [8, 72]",
                        "context": "overlayTitleSize=\(clampedValue)"
                    ])
                }
                view.overlayTitleSize = CGFloat(clampedValue)
            }
        }
    }
}
