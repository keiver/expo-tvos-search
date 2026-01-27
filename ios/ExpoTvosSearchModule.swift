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

        // Forces UIKit to re-discover SwiftUI focus items after fullScreenModal dismiss.
        // Walks the key window's view hierarchy to find ExpoTvosSearchView instances
        // and cycles their hosting controller through the VC lifecycle (detach → attach),
        // which re-registers UIKitFocusableViewResponderItem focus proxies.
        Function("restoreTVFocus") {
            DispatchQueue.main.async {
                guard let windowScene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first,
                    let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
                else { return }

                ExpoTvosSearchView.refreshAllInHierarchy(keyWindow)
            }
        }

        // Registers NotificationCenter observers for UIFocusSystem.didUpdateNotification
        // and UIFocusSystem.movementDidFailNotification (tvOS 12+). Logs every focus
        // update and every failed movement attempt with direction, source, and target.
        Function("enableFocusDebugging") {
            DispatchQueue.main.async {
                FocusDebugHelper.enable()
            }
        }

        Function("disableFocusDebugging") {
            DispatchQueue.main.async {
                FocusDebugHelper.disable()
            }
        }

        // Dumps the currently focused item, its superview chain, scroll view
        // state, and root VC hierarchy to the Xcode console via NSLog.
        Function("logFocusState") {
            DispatchQueue.main.async {
                FocusDebugHelper.logCurrentState()
            }
        }

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

// MARK: - Focus Debug Helper

/// Observes UIFocusSystem notifications and logs focus state for debugging
/// the tvOS vertical traversal bug after modal dismiss.
///
/// Usage from JS:
///   enableFocusDebugging()  — start logging
///   logFocusState()         — dump current state on demand
///   disableFocusDebugging() — stop logging
///
/// Also add -UIFocusLoggingEnabled to Xcode scheme launch arguments
/// for Apple's built-in focus logging (WWDC 2017 Session 224).
private enum FocusDebugHelper {
    private static var observers: [NSObjectProtocol] = []

    static func enable() {
        guard observers.isEmpty else {
            NSLog("[FocusDebug] Already enabled")
            return
        }

        let didUpdate = NotificationCenter.default.addObserver(
            forName: UIFocusSystem.didUpdateNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let context = notification.userInfo?[UIFocusSystem.focusUpdateContextUserInfoKey] as? UIFocusUpdateContext else { return }
            let prev = describeItem(context.previouslyFocusedItem)
            let next = describeItem(context.nextFocusedItem)
            let heading = describeHeading(context.focusHeading)
            NSLog("[FocusDebug] UPDATE: %@ -> %@ (heading: %@)", prev, next, heading)
        }

        let didFail = NotificationCenter.default.addObserver(
            forName: UIFocusSystem.movementDidFailNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let context = notification.userInfo?[UIFocusSystem.focusUpdateContextUserInfoKey] as? UIFocusUpdateContext else {
                NSLog("[FocusDebug] FAILED: no context in notification")
                return
            }
            let focused = describeItem(context.previouslyFocusedItem)
            let heading = describeHeading(context.focusHeading)
            NSLog("[FocusDebug] FAILED MOVEMENT from %@ heading %@", focused, heading)
            if let next = context.nextFocusedItem {
                NSLog("[FocusDebug]   nextFocusedItem: %@ (blocked by shouldUpdateFocusInContext?)", describeItem(next))
            } else {
                NSLog("[FocusDebug]   nextFocusedItem: NIL (focus engine found no target in that direction)")
            }
            // Log the focused view's scroll view ancestor state if any
            if let view = context.previouslyFocusedView {
                logScrollViewAncestors(of: view)
            }
        }

        observers = [didUpdate, didFail]
        NSLog("[FocusDebug] Enabled. Tip: also add -UIFocusLoggingEnabled to Xcode scheme launch args.")
    }

    static func disable() {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
        observers = []
        NSLog("[FocusDebug] Disabled")
    }

    static func logCurrentState() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first,
            let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            NSLog("[FocusDebug] No key window")
            return
        }

        NSLog("[FocusDebug] === FOCUS STATE DUMP ===")

        // Log focused item via UIFocusSystem
        if let focusSystem = UIFocusSystem.focusSystem(for: keyWindow) {
            if let item = focusSystem.focusedItem {
                NSLog("[FocusDebug] Focused item: %@", describeItem(item))
                if let view = item as? UIView {
                    logSuperviewChain(of: view)
                    logScrollViewAncestors(of: view)
                }
            } else {
                NSLog("[FocusDebug] No focused item")
            }
        } else {
            NSLog("[FocusDebug] No focus system for key window")
        }

        // Log root VC hierarchy
        if let rootVC = keyWindow.rootViewController {
            NSLog("[FocusDebug] --- VC Hierarchy ---")
            logVCHierarchy(rootVC, depth: 0)
        }

        NSLog("[FocusDebug] === END STATE DUMP ===")
    }

    // MARK: - Formatting helpers

    private static func describeItem(_ item: UIFocusItem?) -> String {
        guard let item = item else { return "nil" }
        if let view = item as? UIView {
            return describeView(view)
        }
        return String(describing: type(of: item))
    }

    private static func describeView(_ view: UIView) -> String {
        let cls = String(describing: type(of: view))
        let frame = view.frame
        let tag = view.tag
        let focused = view.isFocused ? " [FOCUSED]" : ""
        let hidden = view.isHidden ? " [HIDDEN]" : ""
        let alpha = view.alpha < 1.0 ? String(format: " alpha=%.1f", view.alpha) : ""
        return String(format: "%@(tag=%d frame=(%.0f,%.0f,%.0f,%.0f)%@%@%@)",
                       cls, tag, frame.origin.x, frame.origin.y, frame.size.width, frame.size.height,
                       focused, hidden, alpha)
    }

    private static func describeHeading(_ heading: UIFocusHeading) -> String {
        var parts: [String] = []
        if heading.contains(.up) { parts.append("UP") }
        if heading.contains(.down) { parts.append("DOWN") }
        if heading.contains(.left) { parts.append("LEFT") }
        if heading.contains(.right) { parts.append("RIGHT") }
        if heading.contains(.next) { parts.append("NEXT") }
        if heading.contains(.previous) { parts.append("PREVIOUS") }
        return parts.isEmpty ? "NONE" : parts.joined(separator: "|")
    }

    private static func logSuperviewChain(of view: UIView) {
        var parent = view.superview
        var depth = 1
        while let p = parent, depth <= 15 {
            NSLog("[FocusDebug]   parent[%d]: %@", depth, describeView(p))
            parent = p.superview
            depth += 1
        }
    }

    private static func logScrollViewAncestors(of view: UIView) {
        var current: UIView? = view.superview
        while let v = current {
            if let scrollView = v as? UIScrollView {
                let offset = scrollView.contentOffset
                let size = scrollView.contentSize
                let frame = scrollView.frame
                let scrollEnabled = scrollView.isScrollEnabled
                NSLog("[FocusDebug]   scroll ancestor: %@ contentOffset=(%.0f,%.0f) contentSize=(%.0f,%.0f) frame=(%.0f,%.0f,%.0f,%.0f) scrollEnabled=%@",
                      String(describing: type(of: scrollView)),
                      offset.x, offset.y, size.width, size.height,
                      frame.origin.x, frame.origin.y, frame.size.width, frame.size.height,
                      scrollEnabled ? "YES" : "NO")
            }
            current = v.superview
        }
    }

    private static func logVCHierarchy(_ vc: UIViewController, depth: Int) {
        let indent = String(repeating: "  ", count: depth)
        let cls = String(describing: type(of: vc))
        let presented = vc.presentedViewController != nil ? " (presenting modal)" : ""
        NSLog("[FocusDebug] %@%@%@", indent, cls, presented)
        for child in vc.children {
            logVCHierarchy(child, depth: depth + 1)
        }
    }
}
