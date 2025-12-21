import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
    private let url: URL?
    private let scale: CGFloat
    private let transaction: Transaction
    @ViewBuilder private let content: (Image) -> Content
    @ViewBuilder private let placeholder: () -> Placeholder
    
    @State private var phase: AsyncImagePhase
    
    init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
        self.placeholder = placeholder
        self._phase = State(initialValue: .empty)
    }
    
    var body: some View {
        contentPhase
            .task(id: url) {
                await load()
            }
    }
    
    @ViewBuilder
    private var contentPhase: some View {
        if case let .success(image) = phase {
            content(image)
        } else if case .failure = phase {
            placeholder()
        } else {
            placeholder()
        }
    }
    
    private func load() async {
        guard let url = url else {
            phase = .empty
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad)
        
        // Check memory cache first (URLCache.shared)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let image = UIImage(data: cachedResponse.data) {
            phase = .success(Image(uiImage: image))
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            // Allow caching
            if let httpResponse = response as? HTTPURLResponse,
               let image = UIImage(data: data) {
                
                let cachedData = CachedURLResponse(response: httpResponse, data: data)
                URLCache.shared.storeCachedResponse(cachedData, for: request)
                
                withAnimation(transaction.animation) {
                    phase = .success(Image(uiImage: image))
                }
            } else {
                phase = .failure(URLError(.cannotDecodeContentData))
            }
        } catch {
            phase = .failure(error)
        }
    }
}
