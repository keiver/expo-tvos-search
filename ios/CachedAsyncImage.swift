#if os(tvOS)

import SwiftUI

/// Thread-safe NSCache-backed image cache singleton.
/// Auto-evicts under memory pressure via NSCache's built-in LRU behavior.
final class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, UIImage>()

    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 100 * 1024 * 1024 // 100 MB
    }

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func setImage(_ image: UIImage, for url: URL) {
        let cost = image.cgImage.map { $0.bytesPerRow * $0.height } ?? 0
        cache.setObject(image, forKey: url as NSURL, cost: cost)
    }
}

/// SwiftUI view that loads images with NSCache backing.
/// Cached images appear instantly (no loading flash).
/// On failure, renders EmptyView so the parent placeholder shows through.
struct CachedAsyncImage: View {
    let url: URL
    let contentMode: ContentMode
    let width: CGFloat
    let height: CGFloat

    @State private var uiImage: UIImage?
    @State private var isLoading = true

    var body: some View {
        Group {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(width: width, height: height)
            } else if isLoading {
                ProgressView()
            } else {
                // Failure — show nothing, parent placeholder shows through
                EmptyView()
            }
        }
        .frame(width: width, height: height)
        .task(id: url) {
            uiImage = nil
            isLoading = true

            if let cached = ImageCache.shared.image(for: url) {
                uiImage = cached
                isLoading = false
                return
            }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    ImageCache.shared.setImage(image, for: url)
                    uiImage = image
                }
            } catch {
                // Cancelled or network error — placeholder shows through
            }
            isLoading = false
        }
    }
}

#endif
