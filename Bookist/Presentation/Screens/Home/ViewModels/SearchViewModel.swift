import Foundation
import Combine
import SwiftData

@MainActor
class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [Book] = []
    @Published var history: [SearchHistoryEntity] = []
    @Published var isLoading = false
    @Published var error: String? = nil
    @Published var lastSearchedQuery: String? = nil
    
    private let fetchBooksUseCase: FetchBooksUseCaseProtocol
    private let searchHistoryRepository: SearchHistoryRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var historyLoadTask: Task<Void, Never>?
    
    init(fetchBooksUseCase: FetchBooksUseCaseProtocol? = nil,
         searchHistoryRepository: SearchHistoryRepositoryProtocol? = nil) {
        
        let networkService = NetworkService.shared
        let bookRepo = BookRepository(networkService: networkService)
        
        self.fetchBooksUseCase = fetchBooksUseCase ?? FetchBooksUseCase(repository: bookRepo)
        self.searchHistoryRepository = searchHistoryRepository ?? SearchHistoryRepository()
    }
    
    private var searchTask: Task<Void, Never>?
    
    func performSearch(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { 
            results = []
            return 
        }
        
        isLoading = true
        error = nil
        
        // Cancel any existing search task to prevent redundant API calls
        searchTask?.cancel()
        
        searchTask = Task {
            do {
                let books = try await fetchBooksUseCase.search(query: trimmedQuery)
                
                // If the task was cancelled, don't update results
                guard !Task.isCancelled else { return }
                
                // Deduplicate by ID to ensure clean results
                var uniqueBooks: [Book] = []
                var seenIds = Set<Int>()
                for book in books {
                    if !seenIds.contains(book.id) {
                        uniqueBooks.append(book)
                        seenIds.insert(book.id)
                    }
                }
                
                self.results = uniqueBooks
                self.lastSearchedQuery = trimmedQuery
            } catch {
                if !Task.isCancelled {
                    self.error = error.localizedDescription
                    self.lastSearchedQuery = trimmedQuery
                }
            }
            
            if !Task.isCancelled {
                self.isLoading = false
            }
        }
    }
    
    func clearSearch() {
        query = ""
        results = []
        error = nil
        isLoading = false
        lastSearchedQuery = nil
    }
    
    func addToHistory(query: String) {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        Task {
            try? await searchHistoryRepository.add(query: trimmedQuery)
            await refreshHistory()
        }
    }
    
    func refreshHistory() async {
        historyLoadTask?.cancel()
        historyLoadTask = Task {
            do {
                let fetchedHistory = try await searchHistoryRepository.getHistory()
                if !Task.isCancelled {
                    self.history = fetchedHistory
                }
            } catch {
                if !Task.isCancelled {
                    print("Failed to fetch history: \(error)")
                }
            }
        }
        await historyLoadTask?.value
    }
    
    func clearHistory() {
        Task {
            try? await searchHistoryRepository.clearHistory()
            await refreshHistory()
        }
    }
}
