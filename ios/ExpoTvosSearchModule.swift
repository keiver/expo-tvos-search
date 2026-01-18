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
            Events("onSearch", "onSelectItem")

            Prop("results") { (view: ExpoTvosSearchView, results: [[String: Any]]) in
                // Limit results array size to prevent memory issues
                let limitedResults = Array(results.prefix(Self.maxResults))
                view.updateResults(limitedResults)
            }

            Prop("columns") { (view: ExpoTvosSearchView, columns: Int) in
                // Clamp columns between min and max for safe grid layout
                view.columns = min(max(Self.minColumns, columns), Self.maxColumns)
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
                view.topInset = CGFloat(min(max(0, topInset), 500))
            }

            Prop("showTitleOverlay") { (view: ExpoTvosSearchView, show: Bool) in
                view.showTitleOverlay = show
            }

            Prop("enableMarquee") { (view: ExpoTvosSearchView, enable: Bool) in
                view.enableMarquee = enable
            }

            Prop("marqueeDelay") { (view: ExpoTvosSearchView, delay: Double) in
                // Clamp between 0 and maxMarqueeDelay seconds
                view.marqueeDelay = min(max(0, delay), Self.maxMarqueeDelay)
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
        }
    }
}
