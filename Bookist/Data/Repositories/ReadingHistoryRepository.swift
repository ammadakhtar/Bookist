import Foundation
import SwiftData

@MainActor
protocol ReadingHistoryRepositoryProtocol {
    func fetchRecentlyRead() async throws -> [Book]
    func saveBookToHistory(book: Book) async throws
    func getWeeklyStreak() async throws -> [ReadingStreak]
    func markTodayAsRead() async throws
}

@MainActor
class ReadingHistoryRepository: ReadingHistoryRepositoryProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext ?? SwiftDataManager.shared.container.mainContext
    }
    
    func fetchRecentlyRead() async throws -> [Book] {
        var descriptor = FetchDescriptor<ReadingHistoryEntity>(
            sortBy: [SortDescriptor(\.lastOpenedAt, order: .reverse)]
        )
        descriptor.fetchLimit = 10
        
        let history: [ReadingHistoryEntity] = try modelContext.fetch(descriptor)
        
        // Map back to Book domain model
        return history.compactMap { historyItem -> Book? in
            guard let bookEntity = historyItem.book else { return nil }
            return bookEntity.toDomain()
        }
    }
    
    func saveBookToHistory(book: Book) async throws {
        let bookId = book.id
        let historyDescriptor = FetchDescriptor<ReadingHistoryEntity>(
            predicate: #Predicate<ReadingHistoryEntity> { $0.bookId == bookId }
        )
        
        if let existing = try modelContext.fetch(historyDescriptor).first {
            existing.incrementOpenCount()
        } else {
            // Create new
            // Check if BookEntity exists
            let bookDescriptor = FetchDescriptor<BookEntity>(
                predicate: #Predicate<BookEntity> { $0.id == bookId }
            )
            
            let bookEntity: BookEntity
            if let existingBook = try modelContext.fetch(bookDescriptor).first {
                bookEntity = existingBook
            } else {
                // Create BookEntity
                bookEntity = BookEntity(book: book)
                modelContext.insert(bookEntity)
            }
            
            let history = ReadingHistoryEntity(bookId: book.id, book: bookEntity)
            modelContext.insert(history)
        }
        
        try modelContext.save()
        
        // Auto-mark streak
        try await markTodayAsRead(bookId: book.id)
    }
    
    func getWeeklyStreak() async throws -> [ReadingStreak] {
        // Get start of week (assuming Monday start or Sunday, let's use current locale)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // Find start of current week
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) else {
            return []
        }
        
        let startDate = weekInterval.start
        let endDate = weekInterval.end
        
        let descriptor = FetchDescriptor<ReadingStreakEntity>(
            predicate: #Predicate<ReadingStreakEntity> { $0.date >= startDate && $0.date < endDate },
            sortBy: [SortDescriptor(\.date)]
        )
        
        let entities = try modelContext.fetch(descriptor)
        return entities.map { $0.toDomain() }
    }
    
    func markTodayAsRead() async throws {
        try await markTodayAsRead(bookId: nil)
    }
    
    private func markTodayAsRead(bookId: Int?) async throws {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        // 1. Update Streak
        let streakDescriptor = FetchDescriptor<ReadingStreakEntity>(
             predicate: #Predicate<ReadingStreakEntity> { $0.date == today }
        )
        
        if let existing = try modelContext.fetch(streakDescriptor).first {
             if !existing.isRead {
                 existing.isRead = true
             }
             if let bid = bookId, !existing.bookIdsRead.contains(bid) {
                 existing.bookIdsRead.append(bid)
             }
        } else {
             let newStreak = ReadingStreakEntity(date: today, isRead: true, bookIdsRead: bookId != nil ? [bookId!] : [])
             modelContext.insert(newStreak)
        }
        
        // 2. Update Calendar Finish Count (BookReadStatusEntity)
        let targetBookId = bookId ?? 0 // 0 means general daily activity
        
        let statusDescriptor = FetchDescriptor<BookReadStatusEntity>(
             predicate: #Predicate<BookReadStatusEntity> { $0.finishedAt >= today }
        )
        
        let allTodayStatuses = try modelContext.fetch(statusDescriptor)
        
        // Logical check:
        // If we are marking a SPECIFIC book (targetBookId > 0): 
        //    Insert if this specific book hasn't been marked today.
        // If we are marking GENERAL activity (targetBookId == 0):
        //    Insert ONLY IF there are absolutely no records for today yet.
        
        let shouldInsert: Bool
        if targetBookId > 0 {
            shouldInsert = !allTodayStatuses.contains(where: { $0.bookId == targetBookId })
        } else {
            shouldInsert = allTodayStatuses.isEmpty
        }
        
        if shouldInsert {
            let newStatus = BookReadStatusEntity(bookId: targetBookId, finishedAt: Date())
            modelContext.insert(newStatus)
        }
        
        try modelContext.save()
    }
}
