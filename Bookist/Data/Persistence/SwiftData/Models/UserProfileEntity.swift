import Foundation
import SwiftData

@Model
final class UserProfileEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var avatarId: Int? // 0-41
    var bio: String?
    var createdAt: Date
    var updatedAt: Date
    var yearlyReadingGoal: Int // Default 30
    
    // Cached stats
    var booksReadCount: Int
    var reviewsCount: Int
    var pagesReadCount: Int? // New stat
    var booksInProgressCount: Int? // New stat
    
    init(name: String = "Enter your name", avatarId: Int = 0, yearlyReadingGoal: Int = 30) {
        self.id = UUID()
        self.name = name
        self.avatarId = avatarId
        self.createdAt = Date()
        self.updatedAt = Date()
        self.yearlyReadingGoal = yearlyReadingGoal
        self.booksReadCount = 0
        self.reviewsCount = 0
        self.pagesReadCount = 0
        self.booksInProgressCount = 0
    }
}
