import ExpoModulesCore

public class ExpoTvosSearchModule: Module {
    // Validation constants
    private static let minColumns = 1
    private static let maxColumns = 10
    private static let maxResults = 500
    private static let maxMarqueeDelay: Double = 60.0
    private static let maxStringLength = 500

    public func definition() -> ModuleDefinition {
        Name("ExpoTvosSearch")

        View(ExpoTvosSearchView.self) {
            Events("onSearch", "onSelectItem", "onError", "onValidationWarning")

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
                // Limit placeholder length to prevent layout issues
                view.placeholder = String(placeholder.prefix(Self.maxStringLength))
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
                view.emptyStateText = String(text.prefix(Self.maxStringLength))
            }

            Prop("searchingText") { (view: ExpoTvosSearchView, text: String) in
                view.searchingText = String(text.prefix(Self.maxStringLength))
            }

            Prop("noResultsText") { (view: ExpoTvosSearchView, text: String) in
                view.noResultsText = String(text.prefix(Self.maxStringLength))
            }

            Prop("noResultsHintText") { (view: ExpoTvosSearchView, text: String) in
                view.noResultsHintText = String(text.prefix(Self.maxStringLength))
            }

            Prop("textColor") { (view: ExpoTvosSearchView, colorHex: String?) in
                view.textColor = colorHex
            }

            Prop("accentColor") { (view: ExpoTvosSearchView, colorHex: String) in
                view.accentColor = colorHex
            }

            Prop("cardWidth") { (view: ExpoTvosSearchView, width: Double) in
                view.cardWidth = CGFloat(max(50, min(1000, width)))  // Clamp to reasonable range
            }

            Prop("cardHeight") { (view: ExpoTvosSearchView, height: Double) in
                view.cardHeight = CGFloat(max(50, min(1000, height)))  // Clamp to reasonable range
            }

            Prop("imageContentMode") { (view: ExpoTvosSearchView, mode: String) in
                view.imageContentMode = mode
            }

            Prop("cardMargin") { (view: ExpoTvosSearchView, margin: Double) in
                view.cardMargin = CGFloat(max(0, min(200, margin)))  // Clamp to reasonable range
            }

            Prop("cardPadding") { (view: ExpoTvosSearchView, padding: Double) in
                view.cardPadding = CGFloat(max(0, min(100, padding)))  // Clamp to reasonable range
            }

            Prop("overlayTitleSize") { (view: ExpoTvosSearchView, size: Double) in
                view.overlayTitleSize = CGFloat(max(8, min(72, size)))  // Clamp to reasonable font size range
            }
        }
    }
}
