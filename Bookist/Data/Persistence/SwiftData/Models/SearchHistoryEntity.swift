import Foundation
import SwiftData

@Model
class SearchHistoryEntity {
    var query: String
    var timestamp: Date
    
    init(query: String, timestamp: Date = Date()) {
        self.query = query
        self.timestamp = timestamp
    }
}
