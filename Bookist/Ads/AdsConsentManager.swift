//
//  AdsConsentManager.swift
//  Bookist
//
//  Created by Ammad Akhtar on 24/12/2025.
//

import Foundation
import AppTrackingTransparency
import AdSupport
import UIKit

class AdsConsentManager: ObservableObject {
    static let shared = AdsConsentManager()

    @Published var hasRequestedATT = false
    private let attRequestedKey = "ATTRequestedKey"

    private init() {
        hasRequestedATT = UserDefaults.standard.bool(forKey: attRequestedKey)
    }

    // MARK: - Request ATT Permission
    func requestTrackingPermission(completion: @escaping (Bool) -> Void = { _ in }) {
        print("🔍 requestTrackingPermission called")

        // Only request ATT on iOS 14.5+
        guard #available(iOS 14.5, *) else {
            print("⚠️ iOS version < 14.5, skipping ATT")
            completion(true) // Assume tracking allowed on older iOS
            return
        }

        print("📊 Current ATT Status: \(ATTrackingManager.trackingAuthorizationStatus.rawValue)")
        print("📊 hasRequestedATT: \(hasRequestedATT)")

        guard !hasRequestedATT else {
            // Already requested, just return current status
            let isAuthorized = ATTrackingManager.trackingAuthorizationStatus == .authorized
            print("⏭️ ATT already requested, current status: \(isAuthorized)")
            completion(isAuthorized)
            return
        }

        print("🚀 Requesting ATT authorization...")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    // Mark as requested
                    self?.hasRequestedATT = true
                    UserDefaults.standard.set(true, forKey: self?.attRequestedKey ?? "")

                    let isAuthorized = status == .authorized

                    switch status {
                    case .authorized:
                        print("✅ User authorized tracking - personalized ads enabled")
                    case .denied:
                        print("❌ User denied tracking - non-personalized ads only")
                    case .restricted:
                        print("🚫 Tracking restricted - non-personalized ads only")
                    case .notDetermined:
                        print("❓ Tracking not determined - non-personalized ads only")
                    @unknown default:
                        print("❓ Unknown ATT status - non-personalized ads only")
                    }

                    completion(isAuthorized)
                }
            }
        }
    }

    // MARK: - Check Current Status
    var isTrackingAuthorized: Bool {
        return ATTrackingManager.trackingAuthorizationStatus == .authorized
    }

    var shouldShowATTRequest: Bool {
        guard #available(iOS 14.5, *) else { return false }
        return !hasRequestedATT && ATTrackingManager.trackingAuthorizationStatus == .notDetermined
    }

    // MARK: - Check Ads State (Similar to UIKit implementation)
    func checkAdsState(completion: @escaping () -> Void) {
        if shouldShowATTRequest {
            // First time - request ATT permission
            requestTrackingPermission { _ in
                // After user makes decision, enable ads (no need to preload app open ad here)
                print("✅ ATT decision made - ads can now work normally")
                completion()
            }
        } else {
            // User already made decision - ads can work normally
            completion()
        }
    }

    // MARK: - App Open Ad Specific Check
    var shouldShowAppOpenAd: Bool {
        guard #available(iOS 14.5, *) else { return true } // Allow on older iOS
        // Only show app open ad if user has already made ATT decision
        return ATTrackingManager.trackingAuthorizationStatus != .notDetermined
    }

    // MARK: - Reset for Testing
    func resetATTRequest() {
        hasRequestedATT = false
        UserDefaults.standard.removeObject(forKey: attRequestedKey)
    }
}
