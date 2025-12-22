import SwiftUI

struct BookDetailView: View {
    let bookId: Int
    let previewBook: Book? // Preview data from previous screen
    @StateObject private var viewModel: BookDetailViewModel
    @State private var selectedTab = 0
    @State private var userRating = 0
    @State private var userReview = ""
    @State private var showReader = false
    @Environment(\.dismiss) private var dismiss
    
    init(bookId: Int, previewBook: Book? = nil) {
        self.bookId = bookId
        self.previewBook = previewBook
        _viewModel = StateObject(wrappedValue: BookDetailViewModel(bookId: bookId, previewBook: previewBook))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            AppColors.background.ignoresSafeArea()
            
            // Use preview book directly (Gutendex API returns same data for list and detail)
            if let book = previewBook {
                contentView(for: book)
            } else {
                // Fallback if no preview data
                Text("No book data available")
                    .foregroundColor(AppColors.secondaryText)
            }
            
            // Navigation Bar Overlays - Always visible
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                Spacer()
                Button(action: { 
                    if let book = previewBook {
                        shareBook(book)
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarHidden(true)
        .onReceive(viewModel.$existingReview) { review in
            if let review = review {
                userRating = review.rating
                userReview = review.reviewText ?? ""
            }
        }
        .navigationDestination(isPresented: $showReader) {
            if let book = previewBook {
                BookReaderView(book: book)
            }
        }
        .tint(.black) // Ensure pushed views have black accent color
    }
    
    // MARK: - Sharing Logic
    private func shareBook(_ book: Book) {
        let text = "Check out '\(book.title)' by \(book.authors.map { $0.name }.joined(separator: ", ")) on Project Gutenberg!"
        let urlString = "https://www.gutenberg.org/ebooks/\(book.id)"
        
        guard let url = URL(string: urlString) else { return }
        
        let activityVC = UIActivityViewController(activityItems: [text, url], applicationActivities: nil)
        
        // Find the topmost window to present from
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            
            // For iPad compatibility
            if let popoverController = activityVC.popoverPresentationController {
                popoverController.sourceView = rootVC.view
                popoverController.sourceRect = CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 0, height: 0)
                popoverController.permittedArrowDirections = []
            }
            
            rootVC.present(activityVC, animated: true)
        }
        
        HapticHelper.medium()
    }
    
    // MARK: - Content View
    @ViewBuilder
    private func contentView(for book: Book) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                StretchyHeader(imageURL: book.coverImageURL)
                
                VStack(alignment: .leading, spacing: 24) {
                    // Header Info
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(book.title)
                                .textStyle(.title1)
                                .foregroundColor(AppColors.primaryText)
                            
                            // Description/Summary with truncation (if available)
                            if let summary = book.summary, !summary.isEmpty {
                                ExpandableSummaryView(summary: summary)
                            }
                        }
                        
                        Spacer()
                        
                        // Bookmark Button
                        Button(action: {
                            HapticHelper.medium()
                            viewModel.toggleSave()
                        }) {
                            Image(systemName: viewModel.isSaved ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.black)
                                .frame(width: 44, height: 44)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                    }
                    .alignmentGuide(VerticalAlignment.center) { d in d[VerticalAlignment.center] }
                    
                    // Author and Reader Count
                    HStack(alignment: .center, spacing: 16) {
                        // Authors (left side, can wrap)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Author")
                                .textStyle(.headline)
                                .foregroundColor(AppColors.primaryText)
                            
                            ForEach(book.authors.prefix(3), id: \.id) { author in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(author.name)
                                        .textStyle(.bodyBold)
                                        .foregroundColor(AppColors.secondaryText)
                                    
                                    if let birthYear = author.birthYear, let deathYear = author.deathYear {
                                        Text("(\(birthYear) - \(deathYear))")
                                            .font(.caption)
                                            .foregroundColor(AppColors.secondaryText.opacity(0.7))
                                    } else if let birthYear = author.birthYear {
                                        Text("(b. \(birthYear))")
                                            .font(.caption)
                                            .foregroundColor(AppColors.secondaryText.opacity(0.7))
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Reader count (right side, v-centered)
                        HStack(spacing: 4) {
                            Image(systemName: "book")
                                .font(.caption)
                            Text("\(book.downloadCount.formatted()) Readers")
                                .font(.caption)
                        }
                        .foregroundColor(AppColors.secondaryText)
                    }
                    
                    // Custom Segment Control
                    CustomSegmentControl(selectedIndex: $selectedTab, titles: ["About", "Review"])
                    
                    // Content
                    if selectedTab == 0 {
                        AboutSection(book: book)
                            .transition(.move(edge: .leading).combined(with: .opacity))
                    } else {
                        RatingSection(rating: $userRating, reviewText: $userReview)
                            .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .padding(20)
                
                Spacer(minLength: 100)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .overlay(
            // Bottom Button
            VStack {
                Spacer()
                
                // Copyright notice if applicable
                if book.copyright == true {
                    Text("This work is copyrighted and distributed with permission")
                        .font(.caption)
                        .foregroundColor(AppColors.secondaryText)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                }
                
                let config = viewModel.getButtonConfig(
                    selectedTab: selectedTab,
                    currentRating: userRating,
                    currentText: userReview,
                    onStartReading: {
                        showReader = true
                    }
                )
                
                Button(action: config.action) {
                    Text(config.title)
                        .textStyle(.headline)
                        .foregroundColor(config.isEnabled ? AppColors.background : Color.white.opacity(0.6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(config.isEnabled ? AppColors.primaryText : Color.gray.opacity(0.5))
                        .cornerRadius(16)
                        .shadow(radius: config.isEnabled ? 8 : 0)
                }
                .disabled(!config.isEnabled)
                .padding(20)
            }
        )
    }
}
