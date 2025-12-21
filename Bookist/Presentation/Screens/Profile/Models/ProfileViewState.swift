import Foundation

enum ProfileViewState: Equatable {
    case idle
    case loading
    case loaded(UserProfileEntity)
    case error(String)
}
