import SwiftUI
import SwiftData

struct ReviewsListView: View {
    @Query(filter: #Predicate<BookEntity> { $0.review != nil }, sort: \BookEntity.updatedAt, order: .reverse) 
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
                    Image(systemName: "star")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.secondaryText.opacity(0.3))
                    Text("No reviews yet")
                        .textStyle(.body)
                        .foregroundColor(AppColors.secondaryText)
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(books) { book in
                        ReviewRow(book: book)
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

struct ReviewRow: View {
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
                        
                        if let rating = book.review?.rating {
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { index in
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 10))
                                        .foregroundColor(index <= rating ? .orange : Color.gray.opacity(0.3))
                                }
                            }
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
