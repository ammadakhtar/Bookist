import SwiftUI

struct BookCard: View {
    let book: Book
    var showDetails: Bool = true
    let width: CGFloat = 120
    let height: CGFloat = 180
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Cover Image
            CachedAsyncImage(url: book.coverImageURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.15)) // Light gray background for contrast against white
                    .shimmer() // Add shimmer
            }
            .frame(width: width, height: height)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 4)
            
            // Title (No Author)
            VStack(alignment: .leading, spacing: 0) {
                Text(book.title)
                    .font(.system(size: 14, weight: .bold)) // Reduced font size
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color.black) // Strict Black to match White bg
                    .frame(height: 36, alignment: .topLeading) // Fixed height for 2 lines (~14pt * 1.3 * 2)
            }
            .frame(width: width, alignment: .leading)
        }
        .contentShape(Rectangle())
    }
}
