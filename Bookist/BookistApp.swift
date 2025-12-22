//
//  BookistApp.swift
//  Bookist
//
//  Created by Ammad Akhtar on 21/12/2025.
//

import SwiftUI

@main
struct BookistApp: App {
    init() {
        // Set window background color to match splash gradient
        #if canImport(UIKit)
        UIWindow.appearance().backgroundColor = UIColor(red: 0.19, green: 0.19, blue: 0.19, alpha: 1.0)
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Background gradient that stays consistent
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color(hex: "#323232"), location: 0.33),
                        Gradient.Stop(color: Color(hex: "#000000"), location: 1.00)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                SplashScreen()
            }
            .modelContainer(SwiftDataManager.shared.container)
            .preferredColorScheme(.light) // Enforce light mode app-wide
        }
    }
}
