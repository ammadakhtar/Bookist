import Foundation

protocol FetchBooksUseCaseProtocol {
    func execute(page: Int) async throws -> [Book]
    func search(query: String) async throws -> [Book]
}

struct FetchBooksUseCase: FetchBooksUseCaseProtocol {
    let repository: BookRepositoryProtocol
    
    func execute(page: Int) async throws -> [Book] {
        try await repository.fetchPopularBooks(page: page)
    }
    
    func search(query: String) async throws -> [Book] {
        try await repository.searchBooks(query: query, page: 1)
    }
}
