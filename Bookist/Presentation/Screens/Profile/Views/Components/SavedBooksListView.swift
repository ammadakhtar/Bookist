import SwiftUI
import SwiftData

struct SavedBooksListView: View {
    @Query(filter: #Predicate<BookEntity> { $0.savedBook != nil }, sort: \BookEntity.title) 
    private var books: [BookEntity]
    
    @State private var isLoaded = false
    
    var body: some View {
        Group {
            if !isLoaded {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.top, 40)
            } else if books.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "bookmark")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.secondaryText.opacity(0.3))
                    Text("No saved books yet")
                        .textStyle(.body)
                        .foregroundColor(AppColors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(books) { book in
                        SavedBookRow(book: book)
                    }
                }
            }
        }
        .task {
            // Small delay to let sheet animation complete
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
            isLoaded = true
        }
    }
}

struct SavedBookRow: View {
    let book: BookEntity
    
    var body: some View {
        NavigationLink(value: book.toDomain()) {
            VStack(spacing: 0) {
                HStack(spacing: 16) {
                    AsyncImage(url: URL(string: book.coverImageURL ?? "")) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            Color.gray.opacity(0.1)
                        }
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(book.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(AppColors.primaryText)
                            .lineLimit(1)
                        
                        if let authorName = book.authors.first?.name {
                            Text(authorName)
                                .font(.system(size: 14))
                                .foregroundColor(AppColors.secondaryText)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AppColors.secondaryText.opacity(0.5))
                }
                .padding(.vertical, 16)
                .contentShape(Rectangle())
                
                Divider()
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
