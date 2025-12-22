import Foundation
import SwiftData
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var state: ProfileViewState = .idle
    @Published var userName: String = ""
    @Published var avatarId: Int = 1
    @Published var booksReadCount: Int = 0
    @Published var reviewsCount: Int = 0
    @Published var readingGoal: Int = 30
    
    private let context = SwiftDataManager.shared.container.mainContext
    private var cancellables = Set<AnyCancellable>()
    private var isInitialLoad = true
    
    init() {
        setupDebounce()
    }
    
    private func setupDebounce() {
        $userName
            .dropFirst()
            .debounce(for: .seconds(1.0), scheduler: RunLoop.main)
            .sink { [weak self] name in
                self?.saveName(name)
            }
            .store(in: &cancellables)
            
        $avatarId
            .dropFirst()
            .sink { [weak self] id in
                self?.saveAvatar(id)
            }
            .store(in: &cancellables)
    }
    
    func loadProfile() {
        let descriptor = FetchDescriptor<UserProfileEntity>()
        do {
            let profiles = try context.fetch(descriptor)
            if let profile = profiles.first {
                userName = profile.name
                avatarId = profile.avatarId ?? 0
                readingGoal = profile.yearlyReadingGoal
                
                // Recalculate accurately from DB - only count real books (bookId > 0)
                let readStatusDescriptor = FetchDescriptor<BookReadStatusEntity>(
                    predicate: #Predicate<BookReadStatusEntity> { $0.bookId > 0 }
                )
                let reviewsDescriptor = FetchDescriptor<ReviewEntity>()
                booksReadCount = (try? context.fetchCount(readStatusDescriptor)) ?? profile.booksReadCount
                reviewsCount = (try? context.fetchCount(reviewsDescriptor)) ?? profile.reviewsCount
                
                state = .loaded(profile)
                
                // Trigger repair for orphans
                repairData()
            } else {
                // ... same old logic
                let newProfile = UserProfileEntity()
                newProfile.avatarId = 0
                context.insert(newProfile)
                try context.save()
                userName = newProfile.name
                avatarId = 0
                state = .loaded(newProfile)
            }
        } catch {
            state = .error(error.localizedDescription)
        }
    }
    
    func repairData() {
        Task {
            let savedDescriptor = FetchDescriptor<SavedBookEntity>()
            let reviewDescriptor = FetchDescriptor<ReviewEntity>()
            
            do {
                let saved = try context.fetch(savedDescriptor)
                let reviews = try context.fetch(reviewDescriptor)
                
                let orphanSaved = saved.filter { $0.book == nil }
                let orphanReviews = reviews.filter { $0.book == nil }
                
                let allOrphanIds = Array(Set(orphanSaved.map { $0.bookId } + orphanReviews.map { $0.bookId }))
                
                if !allOrphanIds.isEmpty {
                    print("🛠 Repairing \(allOrphanIds.count) orphan records...")
                    let repo = BookRepository()
                    let books = try await repo.fetchBooksByIds(ids: allOrphanIds)
                    
                    for book in books {
                        // Check if book already exists in DB
                        let bookId = book.id
                        let bookDescriptor = FetchDescriptor<BookEntity>(
                            predicate: #Predicate<BookEntity> { $0.id == bookId }
                        )
                        
                        let entity: BookEntity
                        if let existing = try context.fetch(bookDescriptor).first {
                            entity = existing
                            // Update relationships if missing
                            if entity.subjects.isEmpty && !book.subjects.isEmpty {
                                for s in book.subjects { entity.subjects.append(SubjectEntity(name: s)) }
                            }
                            if entity.bookshelves.isEmpty && !book.bookshelves.isEmpty {
                                for b in book.bookshelves { entity.bookshelves.append(BookshelfEntity(name: b)) }
                            }
                            if (entity.summary == nil || entity.summary!.isEmpty) && book.summary != nil {
                                entity.summary = book.summary
                            }
                        } else {
                            entity = BookEntity(book: book)
                            context.insert(entity)
                        }
                        
                        // Link existing orphans
                        for s in orphanSaved where s.bookId == book.id { 
                            s.book = entity 
                            entity.savedBook = s
                        }
                        for r in orphanReviews where r.bookId == book.id { 
                            r.book = entity 
                            entity.review = r
                        }
                    }
                    try context.save()
                    print("✅ Repair complete")
                }
            } catch {
                print("❌ Repair failed: \(error)")
            }
        }
    }
    
    private func saveName(_ name: String) {
        Task.detached(priority: .background) {
            // Create a background ModelContext for off-main-thread operations
            let context = ModelContext(SwiftDataManager.shared.container)
            let descriptor = FetchDescriptor<UserProfileEntity>()
            
            do {
                let profiles = try context.fetch(descriptor)
                if let profile = profiles.first {
                    profile.name = name
                    profile.updatedAt = Date()
                    try context.save()
                }
            } catch {
                print("Failed to save name: \(error)")
            }
        }
    }
    
    private func saveAvatar(_ id: Int) {
        Task.detached(priority: .background) {
            // Create a background ModelContext for off-main-thread operations
            let context = ModelContext(SwiftDataManager.shared.container)
            let descriptor = FetchDescriptor<UserProfileEntity>()
            
            do {
                let profiles = try context.fetch(descriptor)
                if let profile = profiles.first {
                    profile.avatarId = id
                    profile.updatedAt = Date()
                    try context.save()
                }
            } catch {
                print("Failed to save avatar: \(error)")
            }
        }
    }
}
