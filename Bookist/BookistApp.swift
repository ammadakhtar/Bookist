//
//  BookistApp.swift
//  Bookist
//
//  Created by Ammad Akhtar on 21/12/2025.
//

import SwiftUI

@main
struct BookistApp: App {
    @StateObject private var adsConsentManager = AdsConsentManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var isAppReady = false // Track when splash is done
    
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
                
                SplashScreen(onComplete: {
                    // Mark app as ready when splash completes
                    isAppReady = true
                })
            }
            .modelContainer(SwiftDataManager.shared.container)
            .preferredColorScheme(.light) // Enforce light mode app-wide
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            handleScenePhaseChange(newPhase: newPhase)
        }
    }
    
    private func handleScenePhaseChange(newPhase: ScenePhase) {
        print("📱 Scene phase changed to: \(newPhase), isAppReady: \(isAppReady)")
        
        // 1. Fetch Ad on Background (only if not premium)
        if newPhase == .background {
            if !SubscriptionManager.shared.isPremium {
                print("📱 App went to background - Preloading next App Open Ad")
                AdManager.shared.preloadAppOpenAd()
            }
            NotificationManager.shared.handleAppWillResignActive()
            return
        }
        
        // 2. Show Ad on Foreground (if splash is done and not already presenting something)
        if newPhase == .active {
            // Always clear badge immediately when app becomes active, regardless of splash state
            NotificationManager.shared.handleAppDidBecomeActive()
            
            // Only show ads after splash is complete
            guard isAppReady else { return }
            
            print("📱 App became active and app is ready")
            
            // Check premium before showing app open ad
            guard !SubscriptionManager.shared.isPremium else {
                print("🎉 User is premium - skipping app return ad")
                return
            }
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootViewController = windowScene.windows.first?.rootViewController else {
                print("❌ No root view controller found")
                return
            }
            
            // Check if we are already presenting a modal (like an existing Ad)
            if rootViewController.presentedViewController == nil {
                print("📱 No modal presented, attempting to show app open ad...")
                _ = AdManager.shared.showPreloadedAppOpenAd(
                    from: rootViewController,
                    userIsPremium: false,
                    onSuccess: {
                        print("✅ App Return Ad Dismissed")
                    },
                    onFailure: {
                        print("❌ App Return Ad Not Ready for Background Return")
                    }
                )
            } else {
                print("⏭️ Skipping App Open Ad - View Controller is already presenting: \(type(of: rootViewController.presentedViewController!))")
            }
        }
    }
}
