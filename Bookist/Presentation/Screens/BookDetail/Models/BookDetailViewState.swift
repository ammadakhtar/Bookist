import Foundation

enum BookDetailViewState: Equatable {
    case idle
    case loading
    case loaded(Book)
    case error(String)
}
