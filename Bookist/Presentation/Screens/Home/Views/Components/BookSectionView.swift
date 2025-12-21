import SwiftUI

struct BookSectionView: View {
    let title: String
    let books: [Book]
    var onBookTap: (Book) -> Void
    var onScrollEnd: (() -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .textStyle(.title2)
                .foregroundColor(AppColors.primaryText)
                .padding(.horizontal, 16)
                .padding(.top, 0)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 16) {
                    ForEach(books) { book in
                        BookCard(book: book)
                            .onTapGesture {
                                onBookTap(book)
                            }
                            .onAppear {
                                if let onScrollEnd = onScrollEnd, book == books.last {
                                    onScrollEnd()
                                }
                            }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
