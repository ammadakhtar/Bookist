import SwiftUI

struct AboutSection: View {
    let book: Book
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Subjects
            if !book.subjects.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.subjects.count == 1 ? "Subject" : "Subjects")
                        .textStyle(.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(book.subjects.joined(separator: ", "))
                        .textStyle(.body)
                        .foregroundColor(AppColors.secondaryText)
                        .lineLimit(nil)
                }
            }
            
            // Bookshelves
            if !book.bookshelves.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(book.bookshelves.count == 1 ? "Bookshelf" : "Bookshelves")
                        .textStyle(.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    Text(book.bookshelves.joined(separator: ", "))
                        .textStyle(.body)
                        .foregroundColor(AppColors.secondaryText)
                        .lineLimit(nil)
                }
            }
            
             // Languages
            if !book.languages.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Language")
                        .textStyle(.headline)
                        .foregroundColor(AppColors.primaryText)
                    
                    ForEach(book.languages, id: \.self) { lang in
                        Text(lang.uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                LinearGradient(colors: [AppColors.accent, AppColors.accent.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                            )
                            .cornerRadius(6)
                    }
                }
            }
        }
    }
}
