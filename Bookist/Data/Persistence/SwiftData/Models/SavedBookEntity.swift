import Foundation
import SwiftData

@Model
final class SavedBookEntity {
    @Attribute(.unique) var id: UUID
    var bookId: Int
    @Relationship var book: BookEntity?
    var savedAt: Date
    
    init(bookId: Int, book: BookEntity? = nil) {
        self.id = UUID()
        self.bookId = bookId
        self.book = book
        self.savedAt = Date()
    }
}
