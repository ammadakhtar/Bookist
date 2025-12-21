import Foundation
import SwiftData

@Model
final class ReadingStreakEntity {
    @Attribute(.unique) var id: UUID
    var date: Date
    var isRead: Bool
    var bookIdsReadString: String = "" // Stored as comma-separated string
    
    var bookIdsRead: [Int] {
        get {
            bookIdsReadString.split(separator: ",").compactMap { Int($0) }
        }
        set {
            bookIdsReadString = newValue.map { String($0) }.joined(separator: ",")
        }
    }
    
    init(date: Date, isRead: Bool = false, bookIdsRead: [Int] = []) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.isRead = isRead
        self.bookIdsReadString = bookIdsRead.map { String($0) }.joined(separator: ",")
    }
}

extension ReadingStreakEntity {
    func toDomain() -> ReadingStreak {
        ReadingStreak(
            id: id,
            date: date,
            isRead: isRead,
            bookIdsRead: bookIdsRead
        )
    }
}
