import ExpoModulesCore
import SwiftUI

// React Native tvOS notification names for controlling gesture handler behavior
// These match the constants in RCTTVRemoteHandler.h
private let RCTTVDisableGestureHandlersCancelTouchesNotification = Notification.Name("RCTTVDisableGestureHandlersCancelTouchesNotification")
private let RCTTVEnableGestureHandlersCancelTouchesNotification = Notification.Name("RCTTVEnableGestureHandlersCancelTouchesNotification")

#if os(tvOS)

class ExpoTvosSearchView: ExpoView {
    private var hostingController: UIHostingController<TvosSearchContentView>?
    private var viewModel = SearchViewModel()

    /// Maximum length for string fields (id, title, subtitle) to prevent memory issues.
    private static let maxStringFieldLength = 500

    /// Maximum length for data: URIs to prevent memory exhaustion (~750KB decoded).
    private static let maxDataUrlLength = 1_000_000

    // Track if we've disabled RN gesture handlers for keyboard input
    private var gestureHandlersDisabled = false

    // Store references to disabled gesture recognizers so we can re-enable them
    private var disabledGestureRecognizers: [UIGestureRecognizer] = []

    // Select long press recognizer, attached only while enableLongPress is set
    private var longPressRecognizer: UILongPressGestureRecognizer?

    /// Short id so interleaved instances are distinguishable in the log.
    private lazy var debugId = String(UInt(bitPattern: ObjectIdentifier(self).hashValue), radix: 16).suffix(4)

    /// Matches RN's TouchableOpacity, so a native card and a JS card feel the same.
    private static let longPressDuration: TimeInterval = 0.5

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
            if #unavailable(tvOS 18) {
                hostingController?.additionalSafeAreaInsets = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
            }
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

    var colorScheme: String = "system" {
        didSet {
            applyColorScheme()
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

    var cardCornerRadius: CGFloat = 12 {
        didSet {
            viewModel.cardCornerRadius = cardCornerRadius
        }
    }

    var cardBackgroundColor: String? = nil {
        didSet {
            viewModel.cardBackgroundColor = cardBackgroundColor.flatMap { Color(hex: $0) }
        }
    }

    // Named cardBorder*, not border*: ExpoView inherits from RCTView, which already declares
    // `borderWidth: CGFloat` and `borderColor: UIColor?`. Same names here would shadow/clash with the
    // superclass (borderColor's String? type can't override UIColor?). The JS prop names are still
    // `borderWidth` / `borderColor` — see the Prop() mapping in ExpoTvosSearchModule.
    var cardBorderWidth: CGFloat = 0 {
        didSet {
            viewModel.borderWidth = cardBorderWidth
        }
    }

    var cardBorderColor: String? = nil {
        didSet {
            viewModel.borderColor = cardBorderColor.flatMap { Color(hex: $0) }
        }
    }

    var focusBorderWidth: CGFloat = 4 {
        didSet {
            viewModel.focusBorderWidth = focusBorderWidth
        }
    }

    var focusStyle: String = "system" {
        didSet {
            viewModel.focusStyle = FocusStyle(rawValue: focusStyle.lowercased()) ?? .system
        }
    }

    var focusScale: CGFloat = 1.0 {
        didSet {
            viewModel.focusScale = focusScale
        }
    }

    var focusGlowColor: String? = nil {
        didSet {
            viewModel.focusGlowColor = focusGlowColor.flatMap { Color(hex: $0) }
        }
    }

    var focusGlowOpacity: Double = 0.55 {
        didSet {
            viewModel.focusGlowOpacity = focusGlowOpacity
        }
    }

    var focusGlowRadius: CGFloat = 0 {
        didSet {
            viewModel.focusGlowRadius = focusGlowRadius
        }
    }

    var overlayBackgroundColor: String? = nil {
        didSet {
            viewModel.overlayBackgroundColor = overlayBackgroundColor.flatMap { Color(hex: $0) }
        }
    }

    var overlayTextColor: String? = nil {
        didSet {
            viewModel.overlayTextColor = overlayTextColor.flatMap { Color(hex: $0) }
        }
    }

    var overlayBackgroundColorFocused: String? = nil {
        didSet {
            viewModel.overlayBackgroundColorFocused = overlayBackgroundColorFocused.flatMap { Color(hex: $0) }
        }
    }

    var overlayTextColorFocused: String? = nil {
        didSet {
            viewModel.overlayTextColorFocused = overlayTextColorFocused.flatMap { Color(hex: $0) }
        }
    }

    var overlayTitleWeight: String = "semibold" {
        didSet {
            switch overlayTitleWeight.lowercased() {
            case "regular": viewModel.overlayTitleWeight = .regular
            case "medium": viewModel.overlayTitleWeight = .medium
            case "bold": viewModel.overlayTitleWeight = .bold
            case "heavy": viewModel.overlayTitleWeight = .heavy
            default: viewModel.overlayTitleWeight = .semibold
            }
        }
    }

    var overlayHeight: CGFloat? = nil {
        didSet {
            viewModel.overlayHeight = overlayHeight
        }
    }

    var marqueeSpeed: CGFloat = 30 {
        didSet {
            viewModel.marqueeSpeed = marqueeSpeed
        }
    }

    var marqueeMode: String = "loop" {
        didSet {
            viewModel.marqueeMode = MarqueeMode(rawValue: marqueeMode.lowercased()) ?? .loop
        }
    }

    var enableLongPress: Bool = false {
        didSet {
            updateLongPressRecognizer()
        }
    }

    let onSearch = EventDispatcher()
    let onSelectItem = EventDispatcher()
    let onLongSelectItem = EventDispatcher()
    let onError = EventDispatcher()
    let onValidationWarning = EventDispatcher()
    let onSearchFieldFocused = EventDispatcher()
    let onSearchFieldBlurred = EventDispatcher()
    let onContentLayout = EventDispatcher()

    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)
        setupView()
    }

    deinit {
        // Remove notification observers explicitly (also auto-removed on dealloc, but explicit is safer)
        NotificationCenter.default.removeObserver(self)

        if let recognizer = longPressRecognizer {
            hostingController?.view.removeGestureRecognizer(recognizer)
            longPressRecognizer = nil
        }

        // Clean up child view controller relationship
        hostingController?.willMove(toParent: nil)
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

    private func applyColorScheme() {
        let style: UIUserInterfaceStyle
        switch colorScheme.lowercased() {
        case "dark":
            style = .dark
        case "light":
            style = .light
        default:
            style = .unspecified
        }
        hostingController?.overrideUserInterfaceStyle = style
    }

    private func setupView() {
        viewModel.childrenContainer.debugId = String(debugId)
        viewModel.childrenContainer.onSizeChange = { [weak self] size in
            self?.onContentLayout(["width": size.width, "height": size.height])
        }
        let contentView = TvosSearchContentView(viewModel: viewModel)
        let controller = UIHostingController(rootView: contentView)
        controller.view.backgroundColor = .clear
        // On tvOS < 18, .searchable doesn't respect SwiftUI padding for keyboard
        // positioning, so we set additionalSafeAreaInsets to inform UIKit directly.
        // tvOS 18+ handles this correctly, and adding insets would double the offset.
        if #unavailable(tvOS 18) {
            controller.additionalSafeAreaInsets = UIEdgeInsets(top: viewModel.topInset, left: 0, bottom: 0, right: 0)
        }
        hostingController = controller

        // Apply initial color scheme (default "system" → .unspecified)
        applyColorScheme()

        // Configure viewModel callbacks
        viewModel.onSearch = { [weak self] query in
            self?.onSearch(["query": query])
        }
        viewModel.onSelectItem = { [weak self] id in
            self?.onSelectItem(["id": id])
        }
        viewModel.onLongSelectItem = { [weak self] id in
            self?.onLongSelectItem(["id": id])
        }

        // Add hosting controller view with constraints
        guard let controller = hostingController else { return }
        addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        // Ensure child VC containment if already in a window at setup time
        if let parentVC = parentViewController() {
            parentVC.addChild(controller)
            controller.didMove(toParent: parentVC)
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

    // MARK: - View Controller Containment

    /// Manages UIHostingController child VC containment when the view moves
    /// in/out of the window hierarchy. This ensures SwiftUI receives proper
    /// lifecycle events (viewWillAppear/viewDidAppear) which are required for
    /// .searchable to integrate with UIKit's focus system on tvOS.
    override func didMoveToWindow() {
        super.didMoveToWindow()
        guard let controller = hostingController else { return }

        if window != nil {
            // View added to window — establish child VC relationship
            if controller.parent == nil, let parentVC = parentViewController() {
                parentVC.addChild(controller)
                controller.didMove(toParent: parentVC)
            }
        } else {
            // View removed from window — tear down child VC relationship
            controller.willMove(toParent: nil)
            controller.removeFromParent()
        }
    }

    /// Walks the responder chain to find the nearest parent UIViewController.
    private func parentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while let next = responder?.next {
            if let vc = next as? UIViewController {
                return vc
            }
            responder = next
        }
        return nil
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

        // A held key on the search keyboard is the system's, not a card long press
        longPressRecognizer?.isEnabled = false

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

        longPressRecognizer?.isEnabled = true

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

    // MARK: - Select Long Press

    /// Adds or removes the select long press recognizer to match `enableLongPress`.
    /// It rides on the hosting view, not the card: SwiftUI gives a focused Button no
    /// press gesture of its own, so the container reads the press and the view model
    /// supplies the card the focus engine is on.
    private func updateLongPressRecognizer() {
        guard let hostingView = hostingController?.view else { return }

        if enableLongPress && !viewModel.hasChildren {
            guard longPressRecognizer == nil else { return }
            let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleSelectLongPress(_:)))
            recognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue)]
            recognizer.minimumPressDuration = Self.longPressDuration
            // The Button keeps the select; this recognizer only listens alongside it.
            recognizer.cancelsTouchesInView = false
            recognizer.delegate = self
            hostingView.addGestureRecognizer(recognizer)
            longPressRecognizer = recognizer
        } else if let recognizer = longPressRecognizer {
            hostingView.removeGestureRecognizer(recognizer)
            longPressRecognizer = nil
        }
    }

    @objc private func handleSelectLongPress(_ recognizer: UILongPressGestureRecognizer) {
        guard recognizer.state == .began else { return }
        viewModel.longSelectFocusedItem()
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

    /// Fabric mounts a child here. Deliberately does not call super: the child goes into the
    /// container the SwiftUI content hosts, not into this view.
    override func mountChildComponentView(_ childComponentView: UIView, index: Int) {
        viewModel.childrenContainer.attach(childComponentView, at: index)
        NSLog("%@", "[tvos-search][\(debugId)] mountChild index=\(index) total=\(viewModel.childrenContainer.subviews.count) class=\(type(of: childComponentView)) frame=\(childComponentView.frame)")
        syncChildren()
    }

    override func unmountChildComponentView(_ childComponentView: UIView, index: Int) {
        viewModel.childrenContainer.detach(childComponentView)
        NSLog("%@", "[tvos-search][\(debugId)] unmountChild index=\(index) total=\(viewModel.childrenContainer.subviews.count) class=\(type(of: childComponentView))")
        syncChildren()
    }

    /// Fabric pools this view as well as its children (RCTComponentViewRegistry). Without a reset
    /// a reused instance renders the previous mount's children.
    override func prepareForRecycle() {
        super.prepareForRecycle()
        viewModel.childrenContainer.reset()
        viewModel.hasChildren = false
    }

    private func syncChildren() {
        let hasChildren = !viewModel.childrenContainer.subviews.isEmpty
        if viewModel.hasChildren != hasChildren {
            viewModel.hasChildren = hasChildren
        }
        // A consumer-rendered card carries its own long press, so the container recognizer would
        // fire a second time on top of it.
        updateLongPressRecognizer()
    }

    func updateResults(_ results: [[String: Any]]) {
        var validResults: [SearchResultItem] = []
        var skippedCount = 0
        var urlValidationFailures = 0
        var httpUrlCount = 0
        var truncatedFields = 0

        for (index, dict) in results.enumerated() {
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
                // Accept HTTP/HTTPS URLs, file: URLs (bundled assets), and data: URIs
                if let url = URL(string: imageUrl),
                   let scheme = url.scheme?.lowercased(),
                   ImageUrlParser.allowedSchemes.contains(scheme) {
                    // Reject oversized data URIs to prevent memory exhaustion
                    if scheme == "data" && imageUrl.count > Self.maxDataUrlLength {
                        urlValidationFailures += 1
                        #if DEBUG
                        print("[expo-tvos-search] Result '\(title)' (id: '\(id)'): data URL too large (\(imageUrl.count) chars, max \(Self.maxDataUrlLength)). Skipped.")
                        #endif
                    } else {
                        validatedImageUrl = imageUrl
                    }
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
                    print("[expo-tvos-search] Result '\(title)' (id: '\(id)'): invalid imageUrl '\(imageUrl)'. Only HTTP/HTTPS URLs, file: URLs, and data: URIs are supported.")
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

// Runs alongside SwiftUI's own press handling and React Native's recognizers
// rather than replacing either.
extension ExpoTvosSearchView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
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
    var colorScheme: String = "system"
    var accentColor: String = "#FFC312"
    var cardWidth: CGFloat = 280
    var cardHeight: CGFloat = 420
    var imageContentMode: String = "fill"
    var cardMargin: CGFloat = 40
    var cardPadding: CGFloat = 16
    var overlayTitleSize: CGFloat = 20
    var cardCornerRadius: CGFloat = 12
    var cardBackgroundColor: String? = nil
    // See the tvOS class above: border* would clash with RCTView's own properties.
    var cardBorderWidth: CGFloat = 0
    var cardBorderColor: String? = nil
    var focusBorderWidth: CGFloat = 4
    var focusStyle: String = "system"
    var focusScale: CGFloat = 1.0
    var focusGlowColor: String? = nil
    var focusGlowOpacity: Double = 0.55
    var focusGlowRadius: CGFloat = 0
    var overlayBackgroundColor: String? = nil
    var overlayTextColor: String? = nil
    var overlayBackgroundColorFocused: String? = nil
    var overlayTextColorFocused: String? = nil
    var overlayTitleWeight: String = "semibold"
    var overlayHeight: CGFloat? = nil
    var marqueeSpeed: CGFloat = 30
    var marqueeMode: String = "loop"
    var enableLongPress: Bool = false

    // Event dispatchers required by ExpoTvosSearchModule's Event() registration.
    // Intentionally no-ops on non-tvOS — the fallback view never fires events.
    let onSearch = EventDispatcher()
    let onSelectItem = EventDispatcher()
    let onLongSelectItem = EventDispatcher()
    let onError = EventDispatcher()
    let onValidationWarning = EventDispatcher()
    let onSearchFieldFocused = EventDispatcher()
    let onSearchFieldBlurred = EventDispatcher()
    let onContentLayout = EventDispatcher()

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
