import SwiftUI

struct StretchyHeader: View {
    let imageURL: URL?
    let minHeight: CGFloat = 250
    
    var body: some View {
        GeometryReader { proxy in
            let y = proxy.frame(in: .global).minY
            let height = max(minHeight, minHeight + y)
            
            AsyncImage(url: imageURL) { phase in
                switch phase {
                case .empty:
                    Color(AppColors.cardBackground)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    Color(AppColors.cardBackground)
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: proxy.size.width, height: height)
            .clipped()
            .offset(y: -y) // Keep top pinned
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, AppColors.background]),
                    startPoint: .center,
                    endPoint: .bottom
                )
                .frame(height: height)
                .offset(y: -y)
            )
        }
        .frame(height: minHeight)
    }
}
