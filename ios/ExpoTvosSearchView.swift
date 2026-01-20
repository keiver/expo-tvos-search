import ExpoModulesCore
import SwiftUI

#if os(tvOS)

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
}

struct TvosSearchContentView: View {
    @ObservedObject var viewModel: SearchViewModel

    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 40), count: viewModel.columns)
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
                .foregroundColor(.secondary)
            Text(viewModel.emptyStateText)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var searchingStateView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text(viewModel.searchingText)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var noResultsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "film.stack")
                .font(.system(size: 80))
                .foregroundColor(.secondary)
            Text(viewModel.noResultsText)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(viewModel.noResultsHintText)
                .font(.subheadline)
                .foregroundColor(.secondary)
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
            LazyVGrid(columns: gridColumns, spacing: 50) {
                ForEach(viewModel.results) { item in
                    SearchResultCard(
                        item: item,
                        showTitle: viewModel.showTitle,
                        showSubtitle: viewModel.showSubtitle,
                        showFocusBorder: viewModel.showFocusBorder,
                        showTitleOverlay: viewModel.showTitleOverlay,
                        enableMarquee: viewModel.enableMarquee,
                        marqueeDelay: viewModel.marqueeDelay,
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
    let onSelect: () -> Void
    @FocusState private var isFocused: Bool

    private let placeholderColor = Color(white: 0.2)
    private let focusedBorderColor = Color(red: 1, green: 0.765, blue: 0.07) // #FFC312

    // Fixed card dimensions for consistent grid layout
    // Width calculated for 5 columns: (1920 - 120 padding - 160 spacing) / 5 ≈ 280
    private let cardWidth: CGFloat = 280
    private var cardHeight: CGFloat { cardWidth * 1.5 } // 2:3 aspect ratio

    // Title overlay constants
    private let overlayGradientHeight: CGFloat = 30
    private let titleBarHeight: CGFloat = 36
    private let overlayOpacity: Double = 0.8

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
                                        .aspectRatio(contentMode: .fill)
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

                    // Title overlay (gradient + title bar)
                    if showTitleOverlay {
                        VStack(spacing: 0) {
                            // Gradient fade
                            LinearGradient(
                                colors: [.clear, .black.opacity(overlayOpacity)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: overlayGradientHeight)

                            // Title bar
                            HStack {
                                if enableMarquee {
                                    MarqueeText(
                                        item.title,
                                        font: .callout,
                                        leftFade: 8,
                                        rightFade: 8,
                                        startDelay: marqueeDelay,
                                        animate: isFocused
                                    )
                                    .foregroundColor(.white)
                                } else {
                                    Text(item.title)
                                        .font(.callout)
                                        .foregroundColor(.white)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.horizontal, 12)
                            .frame(width: cardWidth, height: titleBarHeight, alignment: .leading)
                            .background(Color.black.opacity(overlayOpacity))
                        }
                    }
                }
                .frame(width: cardWidth, height: cardHeight)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(showFocusBorder && isFocused ? focusedBorderColor : Color.clear, lineWidth: 4)
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
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .frame(width: cardWidth, alignment: .leading)
                }
            }
        }
        .buttonStyle(.card)
        .focused($isFocused)
    }

    private var placeholderIcon: some View {
        Image(systemName: "film")
            .font(.system(size: 50))
            .foregroundColor(.secondary)
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
                let idValue = dict["id"]
                print("[expo-tvos-search] Result at index \(index) skipped: missing or empty 'id' field (value: \(String(describing: idValue)))")
                #endif
                continue
            }

            guard let title = dict["title"] as? String, !title.isEmpty else {
                skippedCount += 1
                #if DEBUG
                let titleValue = dict["title"]
                print("[expo-tvos-search] Result at index \(index) (id: '\(id)') skipped: missing or empty 'title' field (value: \(String(describing: titleValue)))")
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
            onValidationWarning([
                "type": "validation_failed",
                "message": "Skipped \(skippedCount) result(s) due to missing required fields",
                "context": "validResults=\(validResults.count), skipped=\(skippedCount)"
            ])
        }
        if urlValidationFailures > 0 {
            onValidationWarning([
                "type": "url_invalid",
                "message": "\(urlValidationFailures) image URL(s) failed validation",
                "context": "Non-HTTP/HTTPS or malformed URLs"
            ])
        }
        if truncatedFields > 0 {
            onValidationWarning([
                "type": "field_truncated",
                "message": "Truncated \(truncatedFields) result(s) with fields exceeding 500 characters",
                "context": "Check id, title, or subtitle field lengths"
            ])
        }

        viewModel.results = validResults
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
