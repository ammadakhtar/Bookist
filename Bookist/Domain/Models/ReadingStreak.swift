import Foundation

struct ReadingStreak: Identifiable, Sendable, Hashable {
    let id: UUID
    let date: Date
    let isRead: Bool
    let bookIdsRead: [Int]
    
    init(id: UUID = UUID(), date: Date, isRead: Bool, bookIdsRead: [Int]) {
        self.id = id
        self.date = date
        self.isRead = isRead
        self.bookIdsRead = bookIdsRead
    }
}
