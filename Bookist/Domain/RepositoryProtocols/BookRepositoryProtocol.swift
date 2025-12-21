import Foundation

protocol BookRepositoryProtocol {
    func fetchPopularBooks(page: Int) async throws -> [Book]
    func searchBooks(query: String, page: Int) async throws -> [Book]
    func fetchBookDetail(id: Int) async throws -> Book
    func fetchBooksByIds(ids: [Int]) async throws -> [Book]
}
