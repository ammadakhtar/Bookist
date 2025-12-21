import Foundation

protocol FetchBookDetailUseCaseProtocol {
    func execute(id: Int) async throws -> Book
}

class FetchBookDetailUseCase: FetchBookDetailUseCaseProtocol {
    private let repository: BookRepositoryProtocol
    
    init(repository: BookRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: Int) async throws -> Book {
        return try await repository.fetchBookDetail(id: id)
    }
}
