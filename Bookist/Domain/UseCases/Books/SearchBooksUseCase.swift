import Foundation

protocol SearchBooksUseCaseProtocol {
    func execute(query: String, page: Int) async throws -> [Book]
}

class SearchBooksUseCase: SearchBooksUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(query: String, page: Int) async throws -> [Book] {
        return try await repository.searchBooks(query: query, page: page)
    }
}
