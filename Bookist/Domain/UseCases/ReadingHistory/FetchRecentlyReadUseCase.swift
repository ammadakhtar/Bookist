import Foundation

protocol FetchRecentlyReadUseCaseProtocol {
    func execute() async throws -> [Book]
    func getWeeklyStreak() async throws -> [ReadingStreak]
    func markTodayAsRead() async throws
}

class FetchRecentlyReadUseCase: FetchRecentlyReadUseCaseProtocol {
    private let repository: ReadingHistoryRepositoryProtocol
    
    init(repository: ReadingHistoryRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [Book] {
        return try await repository.fetchRecentlyRead()
    }
    
    func getWeeklyStreak() async throws -> [ReadingStreak] {
        try await repository.getWeeklyStreak()
    }
    
    func markTodayAsRead() async throws {
        try await repository.markTodayAsRead()
    }
}
