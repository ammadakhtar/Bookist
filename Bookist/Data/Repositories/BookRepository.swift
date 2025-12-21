import Foundation

class BookRepository: BookRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol = NetworkService.shared) {
        self.networkService = networkService
    }
    
    func fetchPopularBooks(page: Int) async throws -> [Book] {
        let response = try await networkService.fetchBooks(page: page)
        return response.results.map { Book(dto: $0) }
    }
    
    func searchBooks(query: String, page: Int) async throws -> [Book] {
        let response = try await networkService.searchBooks(query: query, page: page)
        return response.results.map { Book(dto: $0) }
    }
    
    func fetchBookDetail(id: Int) async throws -> Book {
        let dto = try await networkService.fetchBookDetail(id: id)
        return Book(dto: dto)
    }
    
    func fetchBooksByIds(ids: [Int]) async throws -> [Book] {
        let response = try await networkService.fetchBooksByIds(ids: ids)
        return response.results.map { Book(dto: $0) }
    }
}
