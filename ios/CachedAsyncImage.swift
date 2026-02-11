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

            // Local file — load directly, no network needed
            if url.isFileURL {
                if let image = UIImage(contentsOfFile: url.path) {
                    ImageCache.shared.setImage(image, for: url)
                    uiImage = image
                } else {
                    #if DEBUG
                    print("[expo-tvos-search] Failed to load local image at \(url.path)")
                    #endif
                }
                isLoading = false
                return
            }

            // Data URI — manually extract and decode base64, no network needed
            // Uses Data(base64Encoded:) instead of Data(contentsOf:) for tvOS 16.x compatibility
            if url.scheme?.lowercased() == "data" {
                if let data = ImageUrlParser.decodeDataUri(url.absoluteString),
                   let image = UIImage(data: data) {
                    ImageCache.shared.setImage(image, for: url)
                    uiImage = image
                } else {
                    #if DEBUG
                    print("[expo-tvos-search] Failed to decode data URI")
                    #endif
                }
                isLoading = false
                return
            }

            // Remote URL — fetch via URLSession
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    ImageCache.shared.setImage(image, for: url)
                    uiImage = image
                } else {
                    #if DEBUG
                    print("[expo-tvos-search] UIImage(data:) returned nil for \(url) (\(data.count) bytes)")
                    #endif
                }
            } catch {
                #if DEBUG
                print("[expo-tvos-search] Image load failed for \(url): \(error.localizedDescription)")
                #endif
            }
            isLoading = false
        }
    }
}

#endif
