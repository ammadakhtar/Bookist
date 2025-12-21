import SwiftData
import Foundation

class SwiftDataManager {
    static let shared = SwiftDataManager()
    
    let container: ModelContainer
    
    private init() {
        let schema = Schema([
            BookEntity.self,
            AuthorEntity.self,
            SubjectEntity.self,
            BookshelfEntity.self,
            ReadingHistoryEntity.self,
            SavedBookEntity.self,
            ReviewEntity.self,
            ReadingStreakEntity.self,
            UserProfileEntity.self,
            BookReadStatusEntity.self
        ])
        
        // Use a persistent configuration
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}
