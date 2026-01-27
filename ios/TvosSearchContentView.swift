#if os(tvOS)

import SwiftUI

struct TvosSearchContentView: View {
    @ObservedObject var viewModel: SearchViewModel
    @FocusState private var focusedCardId: String?

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
            .focusSection()
        }
        .padding(.top, viewModel.topInset)
        .ignoresSafeArea(.all, edges: .top)
        .onChange(of: focusedCardId) { newValue in
            viewModel.lastFocusedCardId = newValue
        }
        .onChange(of: viewModel.focusRestoreGeneration) { _ in
            focusedCardId = viewModel.lastFocusedCardId
        }
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
                        onSelect: { viewModel.onSelectItem?(item.id) },
                        focusedCardId: $focusedCardId
                    )
                }
            }
            .padding(.horizontal, 60)
            .padding(.vertical, 40)
        }
    }
}

#endif
