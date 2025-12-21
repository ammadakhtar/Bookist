import Foundation

enum HomeViewState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}
