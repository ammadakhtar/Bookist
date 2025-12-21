import Foundation
import SwiftData

@Model
final class BookReadStatusEntity {
    @Attribute(.unique) var id: UUID
    var bookId: Int
    var finishedAt: Date
    
    init(bookId: Int, finishedAt: Date = Date()) {
        self.id = UUID()
        self.bookId = bookId
        self.finishedAt = finishedAt
    }
}
