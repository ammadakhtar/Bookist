import Foundation
import SwiftData

@Model
final class ReviewEntity {
    @Attribute(.unique) var id: UUID
    var bookId: Int
    @Relationship var book: BookEntity?
    var rating: Int  // 1-5
    var reviewText: String?
    var createdAt: Date
    var updatedAt: Date
    
    init(bookId: Int, book: BookEntity? = nil, rating: Int, reviewText: String? = nil) {
        self.id = UUID()
        self.bookId = bookId
        self.book = book
        self.rating = rating
        self.reviewText = reviewText
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func update(rating: Int, reviewText: String?) {
        self.rating = rating
        self.reviewText = reviewText
        self.updatedAt = Date()
    }
}
