import Foundation
import SwiftData

@MainActor
protocol SearchHistoryRepositoryProtocol {
    func getHistory() async throws -> [SearchHistoryEntity]
    func add(query: String) async throws
    func clearHistory() async throws
}

@MainActor
class SearchHistoryRepository: SearchHistoryRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext ?? SwiftDataManager.shared.container.mainContext
    }
    
    func getHistory() async throws -> [SearchHistoryEntity] {
        let descriptor = FetchDescriptor<SearchHistoryEntity>(sortBy: [SortDescriptor(\.timestamp, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }
    
    func add(query: String) async throws {
        // Dedup: Remove existing if present
        let descriptor = FetchDescriptor<SearchHistoryEntity>(predicate: #Predicate { $0.query == query })
        let existing = try modelContext.fetch(descriptor)
        for item in existing {
            modelContext.delete(item)
        }
        
        let newItem = SearchHistoryEntity(query: query)
        modelContext.insert(newItem)
        try modelContext.save()
    }
    
    func clearHistory() async throws {
        try modelContext.delete(model: SearchHistoryEntity.self)
    }
}
