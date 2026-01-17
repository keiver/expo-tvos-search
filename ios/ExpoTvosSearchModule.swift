import ExpoModulesCore

public class ExpoTvosSearchModule: Module {
    public func definition() -> ModuleDefinition {
        Name("ExpoTvosSearch")

        View(ExpoTvosSearchView.self) {
            Events("onSearch", "onSelectItem")

            Prop("results") { (view: ExpoTvosSearchView, results: [[String: Any]]) in
                view.updateResults(results)
            }

            Prop("columns") { (view: ExpoTvosSearchView, columns: Int) in
                view.columns = columns
            }

            Prop("placeholder") { (view: ExpoTvosSearchView, placeholder: String) in
                view.placeholder = placeholder
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
                view.topInset = CGFloat(topInset)
            }
        }
    }
}
