import Foundation

enum APIEndpoint {
    case popularBooks(page: Int)
    case searchBooks(query: String, page: Int)
    case bookDetail(id: Int)
    case booksByIds(ids: [Int])
    
    var baseURL: URL {
        guard let url = URL(string: "https://gutendex.com") else {
            fatalError("Invalid Base URL")
        }
        return url
    }
    
    var path: String {
        switch self {
        case .popularBooks, .searchBooks, .booksByIds:
            return "/books"
        case .bookDetail(let id):
            return "/books/\(id)"
        }
    }
    
    var url: URL? {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        
        switch self {
        case .popularBooks(let page):
            components?.queryItems = [
                URLQueryItem(name: "page", value: String(page))
            ]
        case .searchBooks(let query, let page):
            components?.queryItems = [
                URLQueryItem(name: "search", value: query),
                URLQueryItem(name: "page", value: String(page))
            ]
        case .booksByIds(let ids):
            let idsString = ids.map { String($0) }.joined(separator: ",")
            components?.queryItems = [
                URLQueryItem(name: "ids", value: idsString)
            ]
        case .bookDetail:
            break
        }
        
        return components?.url
    }
}
