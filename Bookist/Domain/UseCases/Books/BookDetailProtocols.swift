import Foundation

protocol SaveBookForLaterUseCaseProtocol {
    func execute(book: Book) async throws
}

protocol RemoveSavedBookUseCaseProtocol {
    func execute(bookId: Int) async throws
}

protocol SaveReadingHistoryUseCaseProtocol {
    func execute(book: Book) async throws
}
