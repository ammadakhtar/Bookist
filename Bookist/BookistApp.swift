//
//  BookistApp.swift
//  Bookist
//
//  Created by Ammad Akhtar on 21/12/2025.
//

import SwiftUI

@main
struct BookistApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(SwiftDataManager.shared.container)
                .preferredColorScheme(.light) // Enforce light mode app-wide
        }
    }
}
