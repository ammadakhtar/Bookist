import Foundation
import SwiftData

@Model
final class ReadingHistoryEntity {
    @Attribute(.unique) var id: UUID
    var bookId: Int  // Reference to API ID
    @Relationship var book: BookEntity?
    var lastOpenedAt: Date
    var openCount: Int
    var currentProgress: Double  // 0.0 to 1.0
    
    init(bookId: Int, book: BookEntity? = nil) {
        self.id = UUID()
        self.bookId = bookId
        self.book = book
        self.lastOpenedAt = Date()
        self.openCount = 1
        self.currentProgress = 0.0
    }
    
    func incrementOpenCount() {
        openCount += 1
        lastOpenedAt = Date()
    }
}
