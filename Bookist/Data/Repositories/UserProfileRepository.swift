import Foundation
import SwiftData

@MainActor
protocol UserProfileRepositoryProtocol {
    func fetchProfile() async throws -> UserProfileEntity
    func updateName(name: String) async throws
}

@MainActor
class UserProfileRepository: UserProfileRepositoryProtocol {
    private let modelContext: ModelContext
    
    @MainActor
    init(modelContext: ModelContext? = nil) {
        self.modelContext = modelContext ?? SwiftDataManager.shared.container.mainContext
    }
    
    @MainActor
    func fetchProfile() async throws -> UserProfileEntity {
        let descriptor = FetchDescriptor<UserProfileEntity>()
        if let profile = try modelContext.fetch(descriptor).first {
            return profile
        } else {
            // Create default
            let newProfile = UserProfileEntity()
            modelContext.insert(newProfile)
            try modelContext.save()
            return newProfile
        }
    }
    
    @MainActor
    func updateName(name: String) async throws {
        let profile = try await fetchProfile()
        profile.name = name
        try modelContext.save()
    }
}
