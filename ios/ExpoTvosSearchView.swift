import ExpoModulesCore
import SwiftUI

#if os(tvOS)

/// Custom shape for cards with selectively rounded corners
/// Provides backwards compatibility for tvOS versions before 16.0
struct SelectiveRoundedRectangle: Shape {
    var topLeadingRadius: CGFloat
    var topTrailingRadius: CGFloat
    var bottomLeadingRadius: CGFloat
    var bottomTrailingRadius: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let tl = min(topLeadingRadius, min(rect.width, rect.height) / 2)
        let tr = min(topTrailingRadius, min(rect.width, rect.height) / 2)
        let bl = min(bottomLeadingRadius, min(rect.width, rect.height) / 2)
        let br = min(bottomTrailingRadius, min(rect.width, rect.height) / 2)

        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr),
                   radius: tr, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br),
                   radius: br, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl),
                   radius: bl, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl),
                   radius: tl, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        path.closeSubpath()

        return path
    }
}

struct SearchResultItem: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String?
    let imageUrl: String?
}

/// ObservableObject that holds state for the search view.
/// This allows updating properties without recreating the entire view hierarchy.
class SearchViewModel: ObservableObject {
    @Published var results: [SearchResultItem] = []
    @Published var isLoading: Bool = false
    @Published var searchText: String = ""

    var onSearch: ((String) -> Void)?
    var onSelectItem: ((String) -> Void)?
    var columns: Int = 5
    var placeholder: String = "Search movies and videos..."

    // Card styling options (configurable from JS)
    var showTitle: Bool = false
    var showSubtitle: Bool = false
    var showFocusBorder: Bool = false
    var topInset: CGFloat = 0  // Extra top padding for tab bar

    // Title overlay options (configurable from JS)
    var showTitleOverlay: Bool = true
    var enableMarquee: Bool = true
    var marqueeDelay: Double = 1.5

    // State text options (configurable from JS)
    var emptyStateText: String = "Search for movies and videos"
    var searchingText: String = "Searching..."
    var noResultsText: String = "No results found"
    var noResultsHintText: String = "Try a different search term"

    // Color customization options (configurable from JS)
    var textColor: Color? = nil
    var accentColor: Color = Color(red: 1, green: 0.765, blue: 0.07) // #FFC312 (gold)

    // Card dimension options (configurable from JS)
    var cardWidth: CGFloat = 280
    var cardHeight: CGFloat = 420

    // Image display options (configurable from JS)
    var imageContentMode: ContentMode = .fill

    // Layout spacing options (configurable from JS)
    var cardMargin: CGFloat = 40  // Spacing between cards
    var cardPadding: CGFloat = 16  // Padding inside cards
    var overlayTitleSize: CGFloat = 20  // Font size for overlay title
}

struct TvosSearchContentView: View {
    @ObservedObject var viewModel: SearchViewModel

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: viewModel.cardMargin), count: viewModel.columns)
    }

    var body: some View {
        NavigationView {
            ZStack {
                Group {
                    if viewModel.results.isEmpty && viewModel.searchText.isEmpty {
                        emptyStateView
                    } else if viewModel.results.isEmpty && !viewModel.searchText.isEmpty {
                        if viewModel.isLoading {
                            searchingStateView
                        } else {
                            noResultsView
                        }
                    } else {
                        resultsGridView
                    }
                }

                // Loading overlay when loading with results
                if viewModel.isLoading && !viewModel.results.isEmpty {
                    loadingOverlay
                }
            }
            .searchable(text: $viewModel.searchText, prompt: viewModel.placeholder)
            .onChange(of: viewModel.searchText) { newValue in
                viewModel.onSearch?(newValue)
            }
        }
        .padding(.top, viewModel.topInset)
        .ignoresSafeArea(.all, edges: .top)
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 80))
                .foregroundColor(viewModel.textColor ?? .secondary)
            Text(viewModel.emptyStateText)
                .font(.headline)
                .foregroundColor(viewModel.textColor ?? .secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var searchingStateView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text(viewModel.searchingText)
                .font(.headline)
                .foregroundColor(viewModel.textColor ?? .secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "film.stack")
                .font(.system(size: 80))
                .foregroundColor(viewModel.textColor ?? .secondary)
            Text(viewModel.noResultsText)
                .font(.headline)
                .foregroundColor(viewModel.textColor ?? .secondary)
            Text(viewModel.noResultsHintText)
                .font(.subheadline)
                .foregroundColor(viewModel.textColor ?? .secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadingOverlay: some View {
        VStack {
            HStack {
                Spacer()
                ProgressView()
                    .padding(16)
                    .background(Color.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.trailing, 60)
            .padding(.top, 20)
            Spacer()
        }
    }

    private var resultsGridView: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: viewModel.cardMargin) {
                ForEach(viewModel.results) { item in
                    SearchResultCard(
                        item: item,
                        showTitle: viewModel.showTitle,
                        showSubtitle: viewModel.showSubtitle,
                        showFocusBorder: viewModel.showFocusBorder,
                        showTitleOverlay: viewModel.showTitleOverlay,
                        enableMarquee: viewModel.enableMarquee,
                        marqueeDelay: viewModel.marqueeDelay,
                        textColor: viewModel.textColor,
                        accentColor: viewModel.accentColor,
                        cardWidth: viewModel.cardWidth,
                        cardHeight: viewModel.cardHeight,
                        imageContentMode: viewModel.imageContentMode,
                        cardPadding: viewModel.cardPadding,
                        overlayTitleSize: viewModel.overlayTitleSize,
                        onSelect: { viewModel.onSelectItem?(item.id) }
                    )
                }
            }
            .padding(.horizontal, 60)
            .padding(.vertical, 40)
        }
    }
}

struct SearchResultCard: View {
    let item: SearchResultItem
    let showTitle: Bool
    let showSubtitle: Bool
    let showFocusBorder: Bool
    let showTitleOverlay: Bool
    let enableMarquee: Bool
    let marqueeDelay: Double
    let textColor: Color?
    let accentColor: Color
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    let imageContentMode: ContentMode
    let cardPadding: CGFloat
    let overlayTitleSize: CGFloat
    let onSelect: () -> Void
    @FocusState private var isFocused: Bool

    private let placeholderColor = Color(white: 0.2)

    // Title overlay constants
    private var overlayHeight: CGFloat { cardHeight * 0.25 }  // 25% of card

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: showTitle || showSubtitle ? 12 : 0) {
                ZStack(alignment: .bottom) {
                    // Card image content
                    ZStack {
                        placeholderColor

                        if let imageUrl = item.imageUrl, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: imageContentMode)
                                        .frame(width: cardWidth, height: cardHeight)
                                case .failure:
                                    placeholderIcon
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: cardWidth, height: cardHeight)
                        } else {
                            placeholderIcon
                        }
                    }
                    .frame(width: cardWidth, height: cardHeight)
                    .clipped()

                    // Title overlay with native material blur
                    if showTitleOverlay {
                        VStack(alignment: .center, spacing: 0) {
                            Spacer(minLength: 0)
                            if enableMarquee {
                                MarqueeText(
                                    item.title,
                                    font: .system(size: overlayTitleSize, weight: .semibold),
                                    leftFade: 12,
                                    rightFade: 12,
                                    startDelay: marqueeDelay,
                                    animate: isFocused
                                )
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                            } else {
                                Text(item.title)
                                    .font(.system(size: overlayTitleSize, weight: .semibold))
                                    .foregroundColor(.white)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, cardPadding)
                        .frame(width: cardWidth, height: overlayHeight)
                        .background(.ultraThinMaterial)
                    }
                }
                .frame(width: cardWidth, height: cardHeight)
                .clipShape(
                    SelectiveRoundedRectangle(
                        topLeadingRadius: 12,
                        topTrailingRadius: 12,
                        bottomLeadingRadius: (showTitle || showSubtitle) ? 0 : 12,
                        bottomTrailingRadius: (showTitle || showSubtitle) ? 0 : 12
                    )
                )
                .overlay(
                    SelectiveRoundedRectangle(
                        topLeadingRadius: 12,
                        topTrailingRadius: 12,
                        bottomLeadingRadius: (showTitle || showSubtitle) ? 0 : 12,
                        bottomTrailingRadius: (showTitle || showSubtitle) ? 0 : 12
                    )
                    .stroke(showFocusBorder && isFocused ? accentColor : Color.clear, lineWidth: 4)
                )

                if showTitle || showSubtitle {
                    VStack(alignment: .leading, spacing: 4) {
                        if showTitle {
                            Text(item.title)
                                .font(.callout)
                                .fontWeight(.medium)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(.primary)
                        }

                        if showSubtitle, let subtitle = item.subtitle {
                            Text(subtitle)
                                .font(.caption)
                                .foregroundColor(textColor ?? .secondary)
                                .lineLimit(1)
                        }
                    }
                    .padding(cardPadding)
                    .frame(width: cardWidth, alignment: .leading)
                }
            }
        }
        .buttonStyle(.card)
        .focused($isFocused)
    }

    private var placeholderIcon: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.1))
                .frame(width: 120, height: 120)

            Image(systemName: "photo")
                .font(.system(size: 60, weight: .light))
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

class ExpoTvosSearchView: ExpoView {
    private var hostingController: UIHostingController<TvosSearchContentView>?
    private let viewModel = SearchViewModel()

    var columns: Int = 5 {
        didSet {
            viewModel.columns = columns
        }
    }

    var placeholder: String = "Search movies and videos..." {
        didSet {
            viewModel.placeholder = placeholder
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

    var emptyStateText: String = "Search for movies and videos" {
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
            case "fit":
                viewModel.imageContentMode = .fit
            case "contain":
                viewModel.imageContentMode = .fit  // SwiftUI uses .fit for contain
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

    required init(appContext: AppContext? = nil) {
        super.init(appContext: appContext)
        setupView()
    }

    deinit {
        // Clean up hosting controller and view model references to prevent memory leaks
        hostingController?.view.removeFromSuperview()
        hostingController = nil
        viewModel.onSearch = nil
        viewModel.onSelectItem = nil
    }

    private func setupView() {
        // Configure viewModel callbacks
        viewModel.onSearch = { [weak self] query in
            self?.onSearch(["query": query])
        }
        viewModel.onSelectItem = { [weak self] id in
            self?.onSelectItem(["id": id])
        }

        // Create hosting controller once
        let contentView = TvosSearchContentView(viewModel: viewModel)
        let controller = UIHostingController(rootView: contentView)
        controller.view.backgroundColor = .clear
        hostingController = controller

        addSubview(controller.view)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }

    func updateResults(_ results: [[String: Any]]) {
        var validResults: [SearchResultItem] = []
        var skippedCount = 0
        var urlValidationFailures = 0
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
                // Accept HTTP/HTTPS URLs only, reject other schemes for security
                if let url = URL(string: imageUrl),
                   let scheme = url.scheme?.lowercased(),
                   scheme == "http" || scheme == "https" {
                    validatedImageUrl = imageUrl
                } else {
                    urlValidationFailures += 1
                    #if DEBUG
                    print("[expo-tvos-search] Result '\(title)' (id: '\(id)'): invalid imageUrl '\(imageUrl)'. Only HTTP/HTTPS URLs are supported for security reasons.")
                    #endif
                }
            }

            // Limit string lengths to prevent memory issues
            let maxIdLength = 500
            let maxTitleLength = 500
            let maxSubtitleLength = 500

            // Track if any fields were truncated
            let idTruncated = id.count > maxIdLength
            let titleTruncated = title.count > maxTitleLength
            let subtitle = dict["subtitle"] as? String
            let subtitleTruncated = (subtitle?.count ?? 0) > maxSubtitleLength

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
                id: String(id.prefix(maxIdLength)),
                title: String(title.prefix(maxTitleLength)),
                subtitle: subtitle.map { String($0.prefix(maxSubtitleLength)) },
                imageUrl: validatedImageUrl
            ))
        }

        // Log summary of validation issues and emit warnings
        #if DEBUG
        if skippedCount > 0 {
            print("[expo-tvos-search] ⚠️ Skipped \(skippedCount) result(s) due to missing required fields (id or title)")
        }
        if urlValidationFailures > 0 {
            print("[expo-tvos-search] ⚠️ \(urlValidationFailures) image URL(s) failed validation (non-HTTP/HTTPS or malformed)")
        }
        if truncatedFields > 0 {
            print("[expo-tvos-search] ℹ️ Truncated \(truncatedFields) result(s) with fields exceeding maximum length (500 chars)")
        }
        if validResults.count > 0 {
            print("[expo-tvos-search] ✓ Processed \(validResults.count) valid result(s)")
        }
        #endif

        // Emit validation warnings for production monitoring
        if skippedCount > 0 {
            #if DEBUG
            let skipContext = "validResults=\(validResults.count), skipped=\(skippedCount)"
            #else
            let skipContext = "validation completed"
            #endif

            onValidationWarning([
                "type": "validation_failed",
                "message": "Skipped \(skippedCount) result(s) due to missing required fields",
                "context": skipContext
            ])
        }
        if urlValidationFailures > 0 {
            #if DEBUG
            let urlContext = "Non-HTTP/HTTPS or malformed URLs"
            #else
            let urlContext = "validation completed"
            #endif

            onValidationWarning([
                "type": "url_invalid",
                "message": "\(urlValidationFailures) image URL(s) failed validation",
                "context": urlContext
            ])
        }
        if truncatedFields > 0 {
            #if DEBUG
            let truncContext = "Check id, title, or subtitle field lengths"
            #else
            let truncContext = "validation completed"
            #endif

            onValidationWarning([
                "type": "field_truncated",
                "message": "Truncated \(truncatedFields) result(s) with fields exceeding 500 characters",
                "context": truncContext
            ])
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
    /// Returns nil if the string cannot be parsed as a valid hex color
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#else

// Fallback for non-tvOS platforms (iOS)
class ExpoTvosSearchView: ExpoView {
    var columns: Int = 5
    var placeholder: String = "Search movies and videos..."
    var isLoading: Bool = false
    var showTitle: Bool = false
    var showSubtitle: Bool = false
    var showFocusBorder: Bool = false
    var topInset: CGFloat = 0
    var showTitleOverlay: Bool = true
    var enableMarquee: Bool = true
    var marqueeDelay: Double = 1.5
    var emptyStateText: String = "Search for movies and videos"
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

    let onSearch = EventDispatcher()
    let onSelectItem = EventDispatcher()
    let onError = EventDispatcher()
    let onValidationWarning = EventDispatcher()

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
