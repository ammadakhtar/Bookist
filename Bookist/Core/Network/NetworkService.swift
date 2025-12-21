import Foundation

protocol NetworkServiceProtocol {
    func fetchBooks(page: Int) async throws -> BookListResponse
    func searchBooks(query: String, page: Int) async throws -> BookListResponse
    func fetchBookDetail(id: Int) async throws -> BookDTO
    func fetchBooksByIds(ids: [Int]) async throws -> BookListResponse
}

class NetworkService: NetworkServiceProtocol {
    static let shared = NetworkService()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    
    init(session: URLSession = .shared) {
        self.session = session
        self.decoder = JSONDecoder()
    }
    
    func fetchBooks(page: Int) async throws -> BookListResponse {
        guard let url = APIEndpoint.popularBooks(page: page).url else {
            throw NetworkError.invalidURL
        }
        return try await performRequest(url: url)
    }
    
    func searchBooks(query: String, page: Int) async throws -> BookListResponse {
        guard let url = APIEndpoint.searchBooks(query: query, page: page).url else {
            throw NetworkError.invalidURL
        }
        return try await performRequest(url: url)
    }
    
    func fetchBookDetail(id: Int) async throws -> BookDTO {
        guard let url = APIEndpoint.bookDetail(id: id).url else {
            throw NetworkError.invalidURL
        }
        return try await performRequest(url: url)
    }
    
    func fetchBooksByIds(ids: [Int]) async throws -> BookListResponse {
        guard let url = APIEndpoint.booksByIds(ids: ids).url else {
            throw NetworkError.invalidURL
        }
        return try await performRequest(url: url)
    }
    
    private func performRequest<T: Decodable>(url: URL) async throws -> T {
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                if httpResponse.statusCode == 429 {
                    throw NetworkError.rateLimitExceeded
                }
                throw NetworkError.invalidResponse
            }
            
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Decoding error: \(error)")
                throw NetworkError.decodingFailed(error)
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.requestFailed(error)
        }
    }
}
