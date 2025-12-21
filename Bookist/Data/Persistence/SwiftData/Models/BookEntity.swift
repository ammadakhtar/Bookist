import Foundation
import SwiftData

@Model
final class BookEntity {
    @Attribute(.unique) var id: Int
    var title: String
    var summary: String?
    var coverImageURL: String?
    var languagesString: String = "" // Stored as comma-separated string
    
    var languagesList: [String] {
        get {
            languagesString.split(separator: ",").map { String($0) }
        }
        set {
            languagesString = newValue.joined(separator: ",")
        }
    }
    
    var downloadCount: Int
    var mediaType: String
    var copyright: Bool
    
    // Format URLs for reading
    var epubUrl: String?
    var mobiUrl: String?
    var htmlUrl: String?
    var textUrl: String?
    
    // Relationships
    @Relationship(deleteRule: .cascade) var authors: [AuthorEntity] = []
    @Relationship(deleteRule: .nullify) var subjects: [SubjectEntity] = []
    @Relationship(deleteRule: .nullify) var bookshelves: [BookshelfEntity] = []
    
    @Relationship(deleteRule: .cascade, inverse: \ReadingHistoryEntity.book)
    var readingHistory: ReadingHistoryEntity?
    
    @Relationship(deleteRule: .cascade, inverse: \SavedBookEntity.book)
    var savedBook: SavedBookEntity?
    
    @Relationship(deleteRule: .cascade, inverse: \ReviewEntity.book)
    var review: ReviewEntity?
    
    // Metadata
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: Int,
        title: String,
        summary: String?,
        coverImageURL: String?,
        downloadCount: Int,
        languages: [String],
        mediaType: String,
        copyright: Bool,
        epubUrl: String? = nil,
        mobiUrl: String? = nil,
        htmlUrl: String? = nil,
        textUrl: String? = nil
    ) {
        self.id = id
        self.title = title
        self.summary = summary
        self.coverImageURL = coverImageURL
        self.downloadCount = downloadCount
        self.languagesString = languages.joined(separator: ",")
        self.mediaType = mediaType
        self.copyright = copyright
        self.epubUrl = epubUrl
        self.mobiUrl = mobiUrl
        self.htmlUrl = htmlUrl
        self.textUrl = textUrl
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    convenience init(book: Book) {
        self.init(
            id: book.id,
            title: book.title,
            summary: book.summary,
            coverImageURL: book.coverImageURL?.absoluteString,
            downloadCount: book.downloadCount,
            languages: book.languages,
            mediaType: "Text",
            copyright: book.copyright ?? false,
            epubUrl: book.formats.epubUrl?.absoluteString,
            mobiUrl: book.formats.mobiUrl?.absoluteString,
            htmlUrl: book.formats.htmlUrl?.absoluteString,
            textUrl: book.formats.textUrl?.absoluteString
        )
        
        // Map authors
        for author in book.authors {
            let authorEntity = AuthorEntity(name: author.name, birthYear: author.birthYear, deathYear: author.deathYear)
            self.authors.append(authorEntity)
        }
        
        // Map subjects
        for subjectName in book.subjects {
            self.subjects.append(SubjectEntity(name: subjectName))
        }
        
        // Map bookshelves
        for shelfName in book.bookshelves {
            self.bookshelves.append(BookshelfEntity(name: shelfName))
        }
    }
}

extension BookEntity {
    func toDomain() -> Book {
        Book(
            id: id,
            title: title,
            authors: authors.map { Author(name: $0.name, birthYear: $0.birthYear, deathYear: $0.deathYear) },
            summary: summary,
            subjects: subjects.map { $0.name },
            bookshelves: bookshelves.map { $0.name },
            languages: languagesList,
            copyright: copyright,
            coverImageURL: coverImageURL != nil ? URL(string: coverImageURL!) : nil,
            downloadCount: downloadCount,
            formats: BookFormats(
                epubUrl: epubUrl.flatMap { URL(string: $0) },
                mobiUrl: mobiUrl.flatMap { URL(string: $0) },
                htmlUrl: htmlUrl.flatMap { URL(string: $0) },
                textUrl: textUrl.flatMap { URL(string: $0) }
            )
        )
    }
}

@Model
final class AuthorEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var birthYear: Int?
    var deathYear: Int?
    
    @Relationship(inverse: \BookEntity.authors) var books: [BookEntity] = []
    
    init(name: String, birthYear: Int? = nil, deathYear: Int? = nil) {
        self.id = UUID()
        self.name = name
        self.birthYear = birthYear
        self.deathYear = deathYear
    }
}

@Model
final class SubjectEntity {
    @Attribute(.unique) var name: String
    @Relationship(inverse: \BookEntity.subjects) var books: [BookEntity] = []
    
    init(name: String) {
        self.name = name
    }
}

@Model
final class BookshelfEntity {
    @Attribute(.unique) var name: String
    @Relationship(inverse: \BookEntity.bookshelves) var books: [BookEntity] = []
    
    init(name: String) {
        self.name = name
    }
}
