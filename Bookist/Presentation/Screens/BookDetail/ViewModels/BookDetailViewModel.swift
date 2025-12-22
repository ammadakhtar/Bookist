import Foundation
import SwiftData

@MainActor
class BookDetailViewModel: ObservableObject {
    @Published var state: BookDetailViewState = .idle
    @Published var isSaved: Bool = false
    @Published var isStarted: Bool = false
    @Published var existingReview: ReviewEntity?
    
    private let context = SwiftDataManager.shared.container.mainContext
    private let fetchBookDetailUseCase: FetchBookDetailUseCaseProtocol
    private var bookId: Int
    private var previewBook: Book?
    
    init(bookId: Int,
         previewBook: Book? = nil,
         fetchBookDetailUseCase: FetchBookDetailUseCaseProtocol) {
        self.bookId = bookId
        self.previewBook = previewBook
        self.fetchBookDetailUseCase = fetchBookDetailUseCase
        
        // Initial setup
        loadSaveState()
        loadExistingReview()
        checkIfStarted()
    }
    
    convenience init(bookId: Int, previewBook: Book? = nil) {
        let networkService = NetworkService.shared
        let repo = BookRepository(networkService: networkService)
        self.init(bookId: bookId, previewBook: previewBook, fetchBookDetailUseCase: FetchBookDetailUseCase(repository: repo))
    }
    
    // MARK: - Local Data Logic
    
    func loadSaveState() {
        let currentId = bookId
        let descriptor = FetchDescriptor<SavedBookEntity>(
            predicate: #Predicate<SavedBookEntity> { $0.bookId == currentId }
        )
        do {
            let matches = try context.fetch(descriptor)
            isSaved = !matches.isEmpty
        } catch {
            print("Error loading save state: \(error)")
        }
    }
    
    func checkIfStarted() {
        let currentId = bookId
        let descriptor = FetchDescriptor<ReadingHistoryEntity>(
            predicate: #Predicate<ReadingHistoryEntity> { $0.bookId == currentId }
        )
        do {
            let matches = try context.fetch(descriptor)
            isStarted = !matches.isEmpty
        } catch {
            print("Error checking history: \(error)")
        }
    }
    
    func toggleSave() {
        if isSaved {
            // Remove
            let currentId = bookId
            let descriptor = FetchDescriptor<SavedBookEntity>(
                predicate: #Predicate<SavedBookEntity> { $0.bookId == currentId }
            )
            do {
                let matches = try context.fetch(descriptor)
                for match in matches {
                    // Break relationship
                    match.book?.savedBook = nil
                    context.delete(match)
                }
                try context.save()
                isSaved = false
            } catch {
                print("Error removing book: \(error)")
            }
        } else {
            // Add
            if let bookEntity = findOrCreateBookEntity() {
                let newSaved = SavedBookEntity(bookId: bookId)
                newSaved.book = bookEntity
                bookEntity.savedBook = newSaved
                context.insert(newSaved)
                do {
                    try context.save()
                    isSaved = true
                } catch {
                    print("Error saving book: \(error)")
                }
            }
        }
    }
    
    private func findOrCreateBookEntity(from book: Book? = nil) -> BookEntity? {
        let currentId = bookId
        let descriptor = FetchDescriptor<BookEntity>(
            predicate: #Predicate<BookEntity> { $0.id == currentId }
        )
        do {
            if let existing = try context.fetch(descriptor).first {
                return existing
            }
            
            // Determine which book object to use
            let bookToUse: Book?
            if let provided = book {
                bookToUse = provided
            } else if case .loaded(let loadedBook) = state {
                bookToUse = loadedBook
            } else if let preview = previewBook {
                // Fallback to preview book if detail isn't loaded yet
                bookToUse = preview
            } else {
                bookToUse = nil
            }
            
            if let book = bookToUse {
                print("Creating BookEntity for \(book.title) (ID: \(book.id))")
                let newEntity = BookEntity(book: book)
                context.insert(newEntity)
                try? context.save()
                return newEntity
            }
        } catch {
            print("Error finding/creating book entity: \(error)")
        }
        return nil
    }
    
    func loadExistingReview() {
        let currentId = bookId
        let descriptor = FetchDescriptor<ReviewEntity>(
            predicate: #Predicate<ReviewEntity> { $0.bookId == currentId }
        )
        do {
            let matches = try context.fetch(descriptor)
            existingReview = matches.first
        } catch {
            print("Error loading review: \(error)")
        }
    }
    
    func saveOrUpdateReview(rating: Int, text: String) {
        if let review = existingReview {
            review.update(rating: rating, reviewText: text)
        } else {
            let newReview = ReviewEntity(bookId: bookId, rating: rating, reviewText: text)
            if let bookEntity = findOrCreateBookEntity() {
                newReview.book = bookEntity
                bookEntity.review = newReview
                context.insert(newReview)
                existingReview = newReview
                
                // Increment review count in profile
                updateProfileStats(reviewCountDelta: 1)
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Error saving review: \(error)")
        }
    }
    
    func markAsRead() {
        let currentId = bookId
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Check if we already marked THIS book as read TODAY to prevent double-tap
        let descriptor = FetchDescriptor<BookReadStatusEntity>(
            predicate: #Predicate<BookReadStatusEntity> { $0.bookId == currentId }
        )
        
        do {
            let allMatches = try context.fetch(descriptor)
            let alreadyReadToday = allMatches.contains { calendar.isDate($0.finishedAt, inSameDayAs: today) }
            
            if !alreadyReadToday {
                let newStatus = BookReadStatusEntity(bookId: bookId)
                context.insert(newStatus)
                
                // Increment read count in profile
                updateProfileStats(readCountDelta: 1)
            }

            // Always save/update history when "Start Reading" is tapped
            let bookToSave: Book? = {
                if case .loaded(let book) = state { return book }
                return previewBook
            }()
            
            if let book = bookToSave {
                Task {
                    let historyRepo = ReadingHistoryRepository()
                    try? await historyRepo.saveBookToHistory(book: book)
                    await MainActor.run {
                        self.isStarted = true
                    }
                }
            }

            try context.save()
            HapticHelper.success()
        } catch {
            print("Error marking book as read: \(error)")
        }
    }
    
    private func updateProfileStats(readCountDelta: Int = 0, reviewCountDelta: Int = 0) {
        let descriptor = FetchDescriptor<UserProfileEntity>()
        do {
            let profiles = try context.fetch(descriptor)
            if let profile = profiles.first {
                profile.booksReadCount += readCountDelta
                profile.reviewsCount += reviewCountDelta
            } else {
                // Create profile if it doesn't exist
                let newProfile = UserProfileEntity()
                newProfile.booksReadCount = readCountDelta
                newProfile.reviewsCount = reviewCountDelta
                context.insert(newProfile)
            }
        } catch {
            print("Error updating profile stats: \(error)")
        }
    }
    
    // MARK: - Button Logic
    
    struct ButtonConfig {
        let title: String
        let isEnabled: Bool
        let action: () -> Void
    }
    
    func getButtonConfig(selectedTab: Int, currentRating: Int, currentText: String, onStartReading: @escaping () -> Void) -> ButtonConfig {
        if selectedTab == 0 {
            return ButtonConfig(
                title: isStarted ? "Continue Reading" : "Start Reading",
                isEnabled: true,
                action: { [weak self] in
                    self?.markAsRead()
                    onStartReading()
                }
            )
        } else {
            let hasReview = existingReview != nil
            let title = hasReview ? "Update Review" : "Save Review"
            let isEnabled = currentRating > 0
            
            return ButtonConfig(
                title: title,
                isEnabled: isEnabled,
                action: { [weak self] in
                    self?.saveOrUpdateReview(rating: currentRating, text: currentText)
                    HapticHelper.success()
                }
            )
        }
    }
    
    // MARK: - Fetch Logic
    
    func loadBookDetail() {
        state = .loading
        let id = self.bookId
        Task { [weak self] in
            guard let self = self else { return }
            do {
                let book = try await self.fetchBookDetailUseCase.execute(id: id)
                self.state = .loaded(book)
                
                // Proactively ensure BookEntity is in SwiftData
                _ = self.findOrCreateBookEntity(from: book)
            } catch {
                self.state = .error(error.localizedDescription)
            }
        }
    }
}
