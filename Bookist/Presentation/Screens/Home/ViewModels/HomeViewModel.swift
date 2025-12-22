import Foundation
import SwiftData
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var state: HomeViewState = .idle
    @Published var popularBooks: [Book] = []
    @Published var recentlyReadBooks: [Book] = []
    @Published var weeklyStreak: [ReadingStreak] = []
    @Published var isLoadingMore = false
    @Published var showConfetti = false
    
    private let fetchBooksUseCase: FetchBooksUseCaseProtocol
    private let fetchRecentlyReadUseCase: FetchRecentlyReadUseCaseProtocol
    
    private var currentPage = 1
    private(set) var canLoadMore = true
    // private var isLoadingMore: removed in favor of published
    
    init(fetchBooksUseCase: FetchBooksUseCaseProtocol,
         fetchRecentlyReadUseCase: FetchRecentlyReadUseCaseProtocol) {
        self.fetchBooksUseCase = fetchBooksUseCase
        self.fetchRecentlyReadUseCase = fetchRecentlyReadUseCase
    }
    
    // Convenience init for DI
    convenience init() {
        let networkService = NetworkService.shared
        let bookRepo = BookRepository(networkService: networkService)
        let historyRepo = ReadingHistoryRepository()
        
        self.init(
            fetchBooksUseCase: FetchBooksUseCase(repository: bookRepo),
            fetchRecentlyReadUseCase: FetchRecentlyReadUseCase(repository: historyRepo)
        )
    }
    
    func loadInitialData(forceRefresh: Bool = false) {
        // 1. Immediately refresh local cache content - This is fast (SwiftData)
        // Refresh streak and recently read independently
        refreshRecentlyRead()
        
        // 2. Load Network Content (Popular Books)
        // Prevent unnecessary reload unless forced or empty
        if !forceRefresh && !popularBooks.isEmpty {
            return
        }
        
        Task {
            state = .loading
            do {
                // Reset pagination if refreshing
                if forceRefresh {
                    currentPage = 1
                    canLoadMore = true
                    popularBooks = [] // Clear strictly on force refresh
                }
                
                // Fetch first page of popular books
                let books = try await fetchBooksUseCase.execute(page: 1)
                
                // Update results and transition state
                popularBooks = books.shuffled()
                state = .loaded
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
    
    func loadMorePopularBooks() {
        guard canLoadMore && !isLoadingMore else { return }
        
        Task {
            isLoadingMore = true
            do {
                let nextPage = currentPage + 1
                let newBooks = try await fetchBooksUseCase.execute(page: nextPage)
                
                if newBooks.isEmpty {
                    canLoadMore = false
                } else {
                    // Deduplicate: Filter out books that are already in the list
                    let existingIDs = Set(popularBooks.map { $0.id })
                    let uniqueBooks = newBooks.shuffled().filter { !existingIDs.contains($0.id) }
                    
                    if uniqueBooks.isEmpty {
                        // If all fetched books are duplicates, maybe we reached end strictly?
                        // Or maybe just a glitch. We should accept them if we want to advance page
                        // But duplicate IDs crash SwiftUI. So we MUST skip them.
                    } else {
                        popularBooks.append(contentsOf: uniqueBooks)
                    }
                    
                    // Always advance page even if dupes, to try next set
                    currentPage = nextPage
                }
            } catch {
                print("Failed to load more books: \(error)")
            }
            isLoadingMore = false
        }
    }
    
    func refreshRecentlyRead() {
        Task {
            do {
                recentlyReadBooks = try await fetchRecentlyReadUseCase.execute()
                weeklyStreak = try await fetchRecentlyReadUseCase.getWeeklyStreak()
            } catch {
                print("Failed to refresh history: \(error)")
            }
        }
    }
    
    func markTodayRead() {
        Task {
            do {
                // Check if already read before triggering confetti
                let alreadyRead = weeklyStreak.first(where: { Calendar.current.isDateInToday($0.date) })?.isRead ?? false
                
                try await fetchRecentlyReadUseCase.markTodayAsRead()
                refreshRecentlyRead()
                
                if !alreadyRead {
                    // Trigger confetti one-shot
                    showConfetti = true
                    // Reset after 5 seconds to allow for future triggers if it was a mistake or reset (though not possible in UI currently)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                        self?.showConfetti = false
                    }
                }
            } catch {
                print("Failed to mark read: \(error)")
            }
        }
    }
}
