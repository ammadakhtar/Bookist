import Foundation

struct BookListResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [BookDTO]
}

struct BookDTO: Codable, Identifiable {
    let id: Int
    let title: String
    let authors: [AuthorDTO]
    let summaries: [String]
    let editors: [AuthorDTO]
    let translators: [AuthorDTO]
    let subjects: [String]
    let bookshelves: [String]
    let languages: [String]
    let copyright: Bool?
    let mediaType: String
    let formats: FormatsDTO
    let downloadCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id, title, authors, summaries, editors, translators, subjects, bookshelves, languages, copyright
        case mediaType = "media_type"
        case formats
        case downloadCount = "download_count"
    }
}

struct AuthorDTO: Codable {
    let name: String
    let birthYear: Int?
    let deathYear: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case birthYear = "birth_year"
        case deathYear = "death_year"
    }
}

struct FormatsDTO: Codable {
    let textHtml: String?
    let applicationEpubZip: String?
    let applicationMobiPocketEbook: String?
    let textPlain: String?
    let applicationRdfXml: String?
    let imageJpeg: String?
    let applicationOctetStream: String?
    
    enum CodingKeys: String, CodingKey {
        case textHtml = "text/html"
        case applicationEpubZip = "application/epub+zip"
        case applicationMobiPocketEbook = "application/x-mobipocket-ebook"
        case textPlain = "text/plain; charset=us-ascii"
        case applicationRdfXml = "application/rdf+xml"
        case imageJpeg = "image/jpeg"
        case applicationOctetStream = "application/octet-stream"
    }
}
