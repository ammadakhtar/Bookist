import Foundation

struct Book: Identifiable, Equatable, Hashable {
    let id: Int
    let title: String
    let authors: [Author]
    let summary: String? // First summary from summaries array
    let subjects: [String]
    let bookshelves: [String]
    let languages: [String]
    let copyright: Bool?
    let coverImageURL: URL?
    let downloadCount: Int
    let formats: BookFormats // Store all formats for ePub reader
}

struct BookFormats: Equatable, Hashable {
    let epubUrl: URL?
    let mobiUrl: URL?
    let htmlUrl: URL?
    let textUrl: URL?
}

extension Book {
    // Helper to map from DTO
    init(dto: BookDTO) {
        self.id = dto.id
        self.title = dto.title
        self.authors = dto.authors.map { Author(name: $0.name, birthYear: $0.birthYear, deathYear: $0.deathYear) }
        self.summary = dto.summaries.first // Take first summary
        self.subjects = dto.subjects
        self.bookshelves = dto.bookshelves
        self.languages = dto.languages
        self.copyright = dto.copyright
        self.downloadCount = dto.downloadCount
        
        // Map formats
        self.formats = BookFormats(
            epubUrl: dto.formats.applicationEpubZip.flatMap { URL(string: $0) },
            mobiUrl: dto.formats.applicationMobiPocketEbook.flatMap { URL(string: $0) },
            htmlUrl: dto.formats.textHtml.flatMap { URL(string: $0) },
            textUrl: dto.formats.textPlain.flatMap { URL(string: $0) }
        )
        
        if let urlString = dto.formats.imageJpeg {
            self.coverImageURL = URL(string: urlString)
        } else {
            self.coverImageURL = nil
        }
    }
}

struct Author: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let birthYear: Int?
    let deathYear: Int?
}
