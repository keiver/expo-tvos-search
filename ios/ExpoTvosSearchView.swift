import ExpoModulesCore
import SwiftUI

// React Native tvOS notification names for controlling gesture handler behavior
// These match the constants in RCTTVRemoteHandler.h
private let RCTTVDisableGestureHandlersCancelTouchesNotification = Notification.Name("RCTTVDisableGestureHandlersCancelTouchesNotification")
private let RCTTVEnableGestureHandlersCancelTouchesNotification = Notification.Name("RCTTVEnableGestureHandlersCancelTouchesNotification")

#if os(tvOS)

/// ObservableObject that holds state for the search view.
/// This allows updating properties without recreating the entire view hierarchy.
class SearchViewModel: ObservableObject {
    @Published var results: [SearchResultItem] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""

    var onSearch: ((String) -> Void)?
    var onSelectItem: ((String) -> Void)?
    @Published var columns: Int = 5
    @Published var placeholder: String = "Search..."

    // Card styling options (configurable from JS)
    @Published var showTitle: Bool = false
    @Published var showSubtitle: Bool = false
    @Published var showFocusBorder: Bool = false
    @Published var topInset: CGFloat = 0  // Extra top padding for tab bar

    // Title overlay options (configurable from JS)
    @Published var showTitleOverlay: Bool = true
    @Published var enableMarquee: Bool = true
    @Published var marqueeDelay: Double = 1.5

    // State text options (configurable from JS)
    @Published var emptyStateText: String = "Search your library"
    @Published var searchingText: String = "Searching..."
    @Published var noResultsText: String = "No results found"
    @Published var noResultsHintText: String = "Try a different search term"

    // Color customization options (configurable from JS)
    @Published var textColor: Color? = nil
    @Published var accentColor: Color = Color(red: 1, green: 0.765, blue: 0.07) // #FFC312 (gold)

    // Card dimension options (configurable from JS)
    @Published var cardWidth: CGFloat = 280
    @Published var cardHeight: CGFloat = 420

    // Image display options (configurable from JS)
    @Published var imageContentMode: ContentMode = .fill

    // Layout spacing options (configurable from JS)
    @Published var cardMargin: CGFloat = 40  // Spacing between cards
    @Published var cardPadding: CGFloat = 16  // Padding inside cards
    @Published var overlayTitleSize: CGFloat = 20  // Font size for overlay title

    // Focus restoration: changing this forces SwiftUI to destroy and recreate the view tree
    @Published var focusRefreshToken: Int = 0
}

class ExpoTvosSearchView: ExpoView {
    private var hostingController: UIHostingController<TvosSearchContentView>?
    private var viewModel = SearchViewModel()

    /// Maximum length for string fields (id, title, subtitle) to prevent memory issues.
    private static let maxStringFieldLength = 500

    /// Maximum number of results to process to prevent memory exhaustion.
    private static let maxResultsCount = 500

    // Track if we've disabled RN gesture handlers for keyboard input
    private var gestureHandlersDisabled = false

    // Store references to disabled gesture recognizers so we can re-enable them
    private var disabledGestureRecognizers: [UIGestureRecognizer] = []

    // Validation is handled by ExpoTvosSearchModule
    var columns: Int = 5 {
        didSet {
            viewModel.columns = columns
        }
    }

    var placeholder: String = "Search..." {
        didSet {
            viewModel.placeholder = placeholder
        }
    }

    var searchTextProp: String? = nil {
        didSet {
            guard let text = searchTextProp, text != viewModel.searchText else { return }
            viewModel.searchText = text
        }
    }

    var isLoading: Bool = false {
        didSet {
            viewModel.isLoading = isLoading
        }
    }

    var showTitle: Bool = false {
        didSet {
            viewModel.showTitle = showTitle
        }
    }

    var showSubtitle: Bool = false {
        didSet {
            viewModel.showSubtitle = showSubtitle
        }
    }

    var showFocusBorder: Bool = false {
        didSet {
            viewModel.showFocusBorder = showFocusBorder
        }
    }

    var topInset: CGFloat = 0 {
        didSet {
            viewModel.topInset = topInset
        }
    }

    var showTitleOverlay: Bool = true {
        didSet {
            viewModel.showTitleOverlay = showTitleOverlay
        }
    }

    var enableMarquee: Bool = true {
        didSet {
            viewModel.enableMarquee = enableMarquee
        }
    }

    var marqueeDelay: Double = 1.5 {
        didSet {
            viewModel.marqueeDelay = marqueeDelay
        }
    }

    var emptyStateText: String = "Search your library" {
        didSet {
            viewModel.emptyStateText = emptyStateText
        }
    }

    var searchingText: String = "Searching..." {
        didSet {
            viewModel.searchingText = searchingText
        }
    }

    var noResultsText: String = "No results found" {
        didSet {
            viewModel.noResultsText = noResultsText
        }
    }

    var noResultsHintText: String = "Try a different search term" {
        didSet {
            viewModel.noResultsHintText = noResultsHintText
        }
    }

    var textColor: String? = nil {
        didSet {
            if let hexColor = textColor {
                viewModel.textColor = Color(hex: hexColor)
            } else {
                viewModel.textColor = nil
            }
        }
    }

    var accentColor: String = "#FFC312" {
        didSet {
            viewModel.accentColor = Color(hex: accentColor) ?? Color(red: 1, green: 0.765, blue: 0.07)
        }
    }

    var cardWidth: CGFloat = 280 {
        didSet {
            viewModel.cardWidth = cardWidth
        }
    }

    var cardHeight: CGFloat = 420 {
        didSet {
            viewModel.cardHeight = cardHeight
        }
    }

    var imageContentMode: String = "fill" {
        didSet {
            switch imageContentMode.lowercased() {
            case "fit", "contain":
                viewModel.imageContentMode = .fit
            default:
                viewModel.imageContentMode = .fill
            }
        }
    }

    var cardMargin: CGFloat = 40 {
        didSet {
            viewModel.cardMargin = cardMargin
        }
    }

    var cardPadding: CGFloat = 16 {
        didSet {
            viewModel.cardPadding = cardPadding
        }
    }

    var overlayTitleSize: CGFloat = 20 {
        didSet {
            viewModel.overlayTitleSize = overlayTitleSize
        }
    }

    let onSearch = EventDispatcher()
    let onSelectItem = EventDispatcher()
    let onError = EventDispatcher()
    let onValidationWarning = EventDispatcher()
    let onSearchFieldFocused = EventDispatcher()
    let onSearchFieldBlurred = EventDispatcher()

    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)
        setupView()
    }

    deinit {
        // Remove notification observers explicitly (also auto-removed on dealloc, but explicit is safer)
        NotificationCenter.default.removeObserver(self)

        // Properly tear down VC hierarchy
        hostingController?.willMove(toParent: nil)
        hostingController?.view.removeFromSuperview()
        hostingController?.removeFromParent()

        // Re-enable any disabled gesture recognizers (only needed on real hardware)
        #if !targetEnvironment(simulator)
        enableParentGestureRecognizers()
        #endif

        // Post notification to re-enable cancelsTouchesInView if needed
        if gestureHandlersDisabled {
            NotificationCenter.default.post(
                name: RCTTVEnableGestureHandlersCancelTouchesNotification,
                object: nil
            )
        }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()

        if window != nil {
            // Integrate the hosting controller into the UIKit VC hierarchy.
            // This is critical for tvOS focus engine: without addChild/didMove,
            // the focus engine cannot traverse to SwiftUI's .searchable() targets
            // after a fullScreenModal is dismissed.
            attachHostingController()

            // Reset gesture handler state when view re-enters window.
            // Handles the case where a modal interrupted editing and the
            // handleTextFieldDidEndEditing notification never fired.
            if gestureHandlersDisabled {
                gestureHandlersDisabled = false

                #if !targetEnvironment(simulator)
                enableParentGestureRecognizers()
                #endif

                NotificationCenter.default.post(
                    name: RCTTVEnableGestureHandlersCancelTouchesNotification,
                    object: nil
                )
            }

            // Force the focus engine to re-evaluate focus targets.
            // Dispatched async to avoid racing with UIKit's own transition handling.
            DispatchQueue.main.async { [weak self] in
                guard let hostingController = self?.hostingController else { return }
                hostingController.setNeedsFocusUpdate()
                hostingController.updateFocusIfNeeded()
            }
        } else {
            // Clean up VC hierarchy when leaving window
            detachHostingController()
        }
    }

    // MARK: - Hosting Controller VC Lifecycle

    /// Adds the hosting controller as a child of the nearest parent view controller.
    /// Follows the UIKit child VC contract: addChild → addSubview → didMove(toParent:).
    /// This ensures the tvOS focus engine can traverse to SwiftUI focus targets.
    private func attachHostingController() {
        guard let controller = hostingController,
              controller.parent == nil,
              let parentVC = self.reactViewController() else { return }

        parentVC.addChild(controller)
        addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        controller.didMove(toParent: parentVC)
    }

    /// Removes the hosting controller from the VC hierarchy.
    /// Follows the UIKit child VC contract: willMove(toParent: nil) → removeFromSuperview → removeFromParent.
    private func detachHostingController() {
        guard let controller = hostingController,
              controller.parent != nil else { return }

        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }

    // MARK: - Focus Restoration

    /// Forces SwiftUI to destroy and recreate its internal view tree by incrementing
    /// the `.id()` token on the NavigationView. This causes UISearchContainerViewController
    /// (and its stale focus proxy items) to be torn down and rebuilt with fresh focus
    /// registrations. The UIHostingController stays in the VC hierarchy.
    /// After a 300ms delay for SwiftUI to process, requests a UIKit focus update.
    func refreshFocusEnvironment() {
        guard hostingController?.parent != nil else { return }

        NSLog("[FocusRestore] incrementing focusRefreshToken (was %d)", viewModel.focusRefreshToken)
        viewModel.focusRefreshToken += 1

        // Wait for SwiftUI to process the identity change and re-register focus items
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let controller = self?.hostingController else {
                NSLog("[FocusRestore] hostingController nil at focus update time")
                return
            }
            controller.setNeedsFocusUpdate()
            controller.updateFocusIfNeeded()
            NSLog("[FocusRestore] focus update requested after identity reset")
        }
    }

    /// Walks the view hierarchy and calls refreshFocusEnvironment() on
    /// every ExpoTvosSearchView found. Typically only one exists.
    static func refreshAllInHierarchy(_ root: UIView) {
        if let searchView = root as? ExpoTvosSearchView {
            searchView.refreshFocusEnvironment()
            return
        }
        for subview in root.subviews {
            refreshAllInHierarchy(subview)
        }
    }

    private func setupView() {
        let contentView = TvosSearchContentView(viewModel: viewModel)
        let controller = UIHostingController(rootView: contentView)
        controller.view.backgroundColor = .clear
        controller.restoresFocusAfterTransition = true
        hostingController = controller

        // Configure viewModel callbacks
        viewModel.onSearch = { [weak self] query in
            self?.onSearch(["query": query])
        }
        viewModel.onSelectItem = { [weak self] id in
            self?.onSelectItem(["id": id])
        }

        // Observe text field editing to detect when search keyboard is active
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTextFieldDidBeginEditing),
            name: UITextField.textDidBeginEditingNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTextFieldDidEndEditing),
            name: UITextField.textDidEndEditingNotification,
            object: nil
        )
    }

    @objc private func handleTextFieldDidBeginEditing(_ notification: Notification) {
        guard let textField = notification.object as? UITextField,
              let hostingView = hostingController?.view,
              textField.isDescendant(of: hostingView) else {
            return
        }

        // Skip if already disabled
        guard !gestureHandlersDisabled else { return }
        gestureHandlersDisabled = true

        // Post notification to RN to stop cancelling touches
        NotificationCenter.default.post(
            name: RCTTVDisableGestureHandlersCancelTouchesNotification,
            object: nil
        )

        // Only disable parent gesture recognizers on real hardware.
        // On the Simulator, the RCT notification alone is sufficient and
        // disabling gesture recognizers interferes with keyboard input
        // (Mac keyboard events are delivered as UIPress events through the
        // responder chain, which breaks when recognizers are disabled).
        #if !targetEnvironment(simulator)
        disableParentGestureRecognizers()
        #endif

        // Fire JS event
        onSearchFieldFocused([:])
    }

    @objc private func handleTextFieldDidEndEditing(_ notification: Notification) {
        guard let textField = notification.object as? UITextField,
              let hostingView = hostingController?.view,
              textField.isDescendant(of: hostingView) else {
            return
        }

        // Skip if not disabled
        guard gestureHandlersDisabled else { return }
        gestureHandlersDisabled = false

        // Re-enable gesture recognizers (only needed on real hardware)
        #if !targetEnvironment(simulator)
        enableParentGestureRecognizers()
        #endif

        // Post notification to RN
        NotificationCenter.default.post(
            name: RCTTVEnableGestureHandlersCancelTouchesNotification,
            object: nil
        )

        // Fire JS event
        onSearchFieldBlurred([:])
    }

    // MARK: - Validation Warning Helper

    /// Emits a validation warning event with optional debug-only context
    private func emitWarning(type: String, message: String, context: String? = nil, debugContext: String? = nil) {
        #if DEBUG
        let ctx = debugContext ?? context ?? "validation completed"
        #else
        let ctx = context ?? "validation completed"
        #endif
        onValidationWarning(["type": type, "message": message, "context": ctx])
    }

    // MARK: - Gesture Recognizer Management

    /// Walks up the view hierarchy and disables tap/long-press gesture recognizers.
    /// Swipe/pan recognizers are kept enabled for keyboard navigation.
    private func disableParentGestureRecognizers() {
        disabledGestureRecognizers.removeAll()

        var currentView: UIView? = self.superview
        while let view = currentView {
            for recognizer in view.gestureRecognizers ?? [] {
                // Only disable tap and long press recognizers
                let isTapOrPress = recognizer is UITapGestureRecognizer ||
                                   recognizer is UILongPressGestureRecognizer
                if isTapOrPress && recognizer.isEnabled {
                    recognizer.isEnabled = false
                    disabledGestureRecognizers.append(recognizer)
                }
            }
            currentView = view.superview
        }
    }

    /// Re-enables all gesture recognizers that were previously disabled.
    private func enableParentGestureRecognizers() {
        for recognizer in disabledGestureRecognizers {
            recognizer.isEnabled = true
        }
        disabledGestureRecognizers.removeAll()
    }

    func updateResults(_ results: [[String: Any]]) {
        // Limit results to prevent memory exhaustion from malicious/buggy input
        let limitedResults = results.prefix(Self.maxResultsCount)
        let truncatedResultsCount = results.count - limitedResults.count

        var validResults: [SearchResultItem] = []
        var skippedCount = 0
        var urlValidationFailures = 0
        var httpUrlCount = 0
        var truncatedFields = 0

        #if DEBUG
        if truncatedResultsCount > 0 {
            print("[expo-tvos-search] Truncated \(truncatedResultsCount) results (max \(Self.maxResultsCount) allowed)")
        }
        #endif

        for (index, dict) in limitedResults.enumerated() {
            // Validate required fields
            guard let id = dict["id"] as? String, !id.isEmpty else {
                skippedCount += 1
                #if DEBUG
                print("[expo-tvos-search] Result at index \(index) skipped: missing or empty 'id' field")
                #endif
                continue
            }

            guard let title = dict["title"] as? String, !title.isEmpty else {
                skippedCount += 1
                #if DEBUG
                print("[expo-tvos-search] Result at index \(index) (id: '\(id)') skipped: missing or empty 'title' field")
                #endif
                continue
            }

            // Validate and sanitize imageUrl if present
            var validatedImageUrl: String? = nil
            if let imageUrl = dict["imageUrl"] as? String, !imageUrl.isEmpty {
                // Accept HTTP/HTTPS URLs and data: URIs, reject other schemes for security
                if let url = URL(string: imageUrl),
                   let scheme = url.scheme?.lowercased(),
                   scheme == "http" || scheme == "https" || scheme == "data" {
                    validatedImageUrl = imageUrl
                    // Warn about insecure HTTP URLs (HTTPS recommended)
                    if scheme == "http" {
                        httpUrlCount += 1
                        #if DEBUG
                        print("[expo-tvos-search] Result '\(title)' (id: '\(id)'): using insecure HTTP URL. HTTPS is recommended for security.")
                        #endif
                    }
                } else {
                    urlValidationFailures += 1
                    #if DEBUG
                    print("[expo-tvos-search] Result '\(title)' (id: '\(id)'): invalid imageUrl '\(imageUrl)'. Only HTTP/HTTPS URLs and data: URIs are supported.")
                    #endif
                }
            }

            // Track if any fields were truncated
            let maxLen = Self.maxStringFieldLength
            let subtitle = dict["subtitle"] as? String
            let idTruncated = id.count > maxLen
            let titleTruncated = title.count > maxLen
            let subtitleTruncated = (subtitle?.count ?? 0) > maxLen

            if idTruncated || titleTruncated || subtitleTruncated {
                truncatedFields += 1
                #if DEBUG
                var truncatedList: [String] = []
                if idTruncated { truncatedList.append("id (\(id.count) chars)") }
                if titleTruncated { truncatedList.append("title (\(title.count) chars)") }
                if subtitleTruncated { truncatedList.append("subtitle (\(subtitle?.count ?? 0) chars)") }
                print("[expo-tvos-search] Result '\(title)' (id: '\(id)'): truncated fields: \(truncatedList.joined(separator: ", "))")
                #endif
            }

            validResults.append(SearchResultItem(
                id: String(id.prefix(maxLen)),
                title: String(title.prefix(maxLen)),
                subtitle: subtitle.map { String($0.prefix(maxLen)) },
                imageUrl: validatedImageUrl
            ))
        }

        // Log summary of validation issues and emit warnings
        #if DEBUG
        if skippedCount > 0 {
            print("[expo-tvos-search] Skipped \(skippedCount) result(s) due to missing required fields (id or title)")
        }
        if urlValidationFailures > 0 {
            print("[expo-tvos-search] \(urlValidationFailures) image URL(s) failed validation (non-HTTP/HTTPS or malformed)")
        }
        if httpUrlCount > 0 {
            print("[expo-tvos-search] \(httpUrlCount) image URL(s) use insecure HTTP. HTTPS is recommended.")
        }
        if truncatedFields > 0 {
            print("[expo-tvos-search] Truncated \(truncatedFields) result(s) with fields exceeding maximum length (500 chars)")
        }
        if validResults.count > 0 {
            print("[expo-tvos-search] Processed \(validResults.count) valid result(s)")
        }
        #endif

        // Emit validation warnings for production monitoring
        if truncatedResultsCount > 0 {
            emitWarning(type: "results_truncated",
                       message: "Truncated \(truncatedResultsCount) result(s) exceeding maximum of \(Self.maxResultsCount)",
                       context: "Consider implementing pagination")
        }
        if skippedCount > 0 {
            emitWarning(type: "validation_failed",
                       message: "Skipped \(skippedCount) result(s) due to missing required fields",
                       debugContext: "validResults=\(validResults.count), skipped=\(skippedCount)")
        }
        if urlValidationFailures > 0 {
            emitWarning(type: "url_invalid",
                       message: "\(urlValidationFailures) image URL(s) failed validation",
                       debugContext: "Non-HTTP/HTTPS or malformed URLs")
        }
        if httpUrlCount > 0 {
            emitWarning(type: "url_insecure",
                       message: "\(httpUrlCount) image URL(s) use insecure HTTP. HTTPS is recommended.",
                       context: "Consider using HTTPS URLs")
        }
        if truncatedFields > 0 {
            emitWarning(type: "field_truncated",
                       message: "Truncated \(truncatedFields) result(s) with fields exceeding 500 characters",
                       debugContext: "Check id, title, or subtitle field lengths")
        }

        // Ensure UI updates happen on main thread
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.results = validResults
        }
    }
}

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

#else

// Fallback for non-tvOS platforms (iOS)
class ExpoTvosSearchView: ExpoView {
    var columns: Int = 5
    var placeholder: String = "Search..."
    var searchTextProp: String? = nil
    var isLoading: Bool = false
    var showTitle: Bool = false
    var showSubtitle: Bool = false
    var showFocusBorder: Bool = false
    var topInset: CGFloat = 0
    var showTitleOverlay: Bool = true
    var enableMarquee: Bool = true
    var marqueeDelay: Double = 1.5
    var emptyStateText: String = "Search your library"
    var searchingText: String = "Searching..."
    var noResultsText: String = "No results found"
    var noResultsHintText: String = "Try a different search term"
    var textColor: String? = nil
    var accentColor: String = "#FFC312"
    var cardWidth: CGFloat = 280
    var cardHeight: CGFloat = 420
    var imageContentMode: String = "fill"
    var cardMargin: CGFloat = 40
    var cardPadding: CGFloat = 16
    var overlayTitleSize: CGFloat = 20

    // Event dispatchers required by ExpoTvosSearchModule's Event() registration.
    // Intentionally no-ops on non-tvOS — the fallback view never fires events.
    let onSearch = EventDispatcher()
    let onSelectItem = EventDispatcher()
    let onError = EventDispatcher()
    let onValidationWarning = EventDispatcher()
    let onSearchFieldFocused = EventDispatcher()
    let onSearchFieldBlurred = EventDispatcher()

    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)
        setupFallbackView()
    }

    private func setupFallbackView() {
        let label = UILabel()
        label.text = "TvOS Search View is only available on Apple TV"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func updateResults(_ results: [[String: Any]]) {
        // No-op on non-tvOS
    }
}

#endif
