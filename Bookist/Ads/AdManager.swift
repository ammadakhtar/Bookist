//
//  AdManager.swift
//  Bookist
//
//  Created by Ammad Akhtar on 24/12/2025.
//

import Foundation
import GoogleMobileAds
import SwiftUI
import AppTrackingTransparency

// MARK: - Session Tracking Enums and Structures

/// Define all possible ad types in the app
enum AdType: String, CaseIterable {
    case interstitial = "interstitial"
    case banner = "banner"
    case native = "native"
    case openApp = "openApp"
}

/// Define all app sections/features where ads are shown
enum AppSection: String, CaseIterable {
    case profileSegmentControl = "profileSegementControl"
    case bookReadAction = "bookReadAction"
    case openBookDetails = "openBook"
    case openProfile = "openProfile"
    case appLaunch = "appLaunch"
    case appBackgroundReturn = "appBackgroundReturn"
}

/// Track ad state per section per ad type
struct AdSessionState {
    var hasShown: Bool = false
    var lastShownDate: Date?
    var showCount: Int = 0
}

/// Configuration for ad behavior per section per ad type
struct AdConfiguration {
    let maxShowsPerSession: Int?
    let minimumTimeBetweenShows: TimeInterval?
    let requiresPremiumCheck: Bool
    let showOnlyOnce: Bool

    static let `default` = AdConfiguration(
        maxShowsPerSession: 1,
        minimumTimeBetweenShows: nil,
        requiresPremiumCheck: true,
        showOnlyOnce: true
    )
}

// MARK: - Ad Session Manager

class AdSessionManager {
    // [AppSection: [AdType: AdSessionState]]
    private var sessionStates: [AppSection: [AdType: AdSessionState]] = [:]

    func getState(type: AdType, for section: AppSection) -> AdSessionState {
        return sessionStates[section]?[type] ?? AdSessionState()
    }

    func setState(_ state: AdSessionState, type: AdType, for section: AppSection) {
        if sessionStates[section] == nil {
            sessionStates[section] = [:]
        }
        sessionStates[section]?[type] = state
    }

    func markAdShown(type: AdType, for section: AppSection) {
        var state = getState(type: type, for: section)
        state.hasShown = true
        state.lastShownDate = Date()
        state.showCount += 1
        setState(state, type: type, for: section)
    }

    func resetState(for section: AppSection? = nil, adType: AdType? = nil) {
        if let section = section {
            if let adType = adType {
                sessionStates[section]?[adType] = AdSessionState()
            } else {
                sessionStates[section] = [:]
            }
        } else {
            sessionStates = [:]
        }
    }
}

final class AdManager: NSObject, ObservableObject {
    static let shared = AdManager()

    // Banner
    @Published var bannerView: BannerView?

    // Native
    @Published var nativeAd: NativeAd?
    private var adLoader: AdLoader?

    // Interstitial
    @Published var interstitial: InterstitialAd?
    private var interstitialAdUnitID: String?
    private var interstitialLoadCompletion: ((Bool) -> Void)?

    // MARK: - Session Management
    private let sessionManager = AdSessionManager()

    // Track pre-loaded ads for instant display
    private var preloadedInterstitials: [AppSection: InterstitialAd] = [:]

    // Default configurations for different ad types and sections
    private lazy var adConfigurations: [AppSection: [AdType: AdConfiguration]] = [
        .bookReadAction: [
            .interstitial: AdConfiguration(maxShowsPerSession: 1, minimumTimeBetweenShows: nil, requiresPremiumCheck: true, showOnlyOnce: true)
        ],
        .profileSegmentControl: [
            // User said "first show...". Configuring as once per session to avoid nag, but can be adjusted.
            .interstitial: AdConfiguration(maxShowsPerSession: 1, minimumTimeBetweenShows: nil, requiresPremiumCheck: true, showOnlyOnce: true)
        ],
        .openBookDetails: [
            // Shared frequency logic handled manually, but config here for safety
            .interstitial: AdConfiguration(maxShowsPerSession: 1, minimumTimeBetweenShows: nil, requiresPremiumCheck: true, showOnlyOnce: true)
        ],
        .openProfile: [
            .interstitial: AdConfiguration(maxShowsPerSession: 1, minimumTimeBetweenShows: nil, requiresPremiumCheck: true, showOnlyOnce: true)
        ],
        .appLaunch: [
            .openApp: AdConfiguration(maxShowsPerSession: 1, minimumTimeBetweenShows: nil, requiresPremiumCheck: true, showOnlyOnce: true)
        ],
        .appBackgroundReturn: [
            // No session limits - show every time user returns from background
            .openApp: AdConfiguration(maxShowsPerSession: nil, minimumTimeBetweenShows: nil, requiresPremiumCheck: true, showOnlyOnce: false)
        ]
    ]

    private override init() {
        super.init()
        MobileAds.shared.start(completionHandler: nil)
    }

    // MARK: - ATT Compliant Ad Request Helper

    /// Creates an ad request configured for ATT compliance
    /// - Returns: GADRequest configured for personalized or non-personalized ads based on ATT status
    private func createAdRequest() -> Request {
        let request = Request()

        // Configure request based on ATT authorization status
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .authorized:
            // User allowed tracking - can show personalized ads
            print("📊 Creating personalized ad request (ATT authorized)")
        case .denied, .restricted:
            // User denied tracking - show non-personalized ads
            print("🔒 Creating non-personalized ad request (ATT denied/restricted)")
            let extras = Extras()
            extras.additionalParameters = ["npa": "1"] // Non-personalized ads
            request.register(extras)
        case .notDetermined:
            // User hasn't decided yet - show non-personalized ads as fallback
            print("❓ Creating non-personalized ad request (ATT not determined)")
            let extras = Extras()
            extras.additionalParameters = ["npa": "1"] // Non-personalized ads
            request.register(extras)
        @unknown default:
            // Unknown status - default to non-personalized
            print("❓ Creating non-personalized ad request (ATT unknown status)")
            let extras = Extras()
            extras.additionalParameters = ["npa": "1"] // Non-personalized ads
            request.register(extras)
        }

        return request
    }

    // MARK: - Session-Based Ad Decision Engine

    /// Determines if an ad should be shown based on session state and configuration
    func shouldShowAd(type: AdType, for section: AppSection, userIsPremium: Bool = false) -> Bool {
        let config = getConfiguration(type: type, for: section)

        // Skip premium check if not required for this ad type/section
        if config.requiresPremiumCheck && userIsPremium {
            return false
        }

        let state = sessionManager.getState(type: type, for: section)

        // Check if already shown and should only show once
        if config.showOnlyOnce && state.hasShown {
            return false
        }

        // Check max shows per session
        if let maxShows = config.maxShowsPerSession, state.showCount >= maxShows {
            return false
        }

        // Check minimum time between shows
        if let minimumTime = config.minimumTimeBetweenShows,
           let lastShown = state.lastShownDate,
           Date().timeIntervalSince(lastShown) < minimumTime {
            return false
        }

        return true
    }

    /// Marks an ad as shown for session tracking
    func markAdShown(type: AdType, for section: AppSection) {
        sessionManager.markAdShown(type: type, for: section)
        print("AdManager: Marked \(type.rawValue) ad as shown for \(section.rawValue) section")
    }

    /// Determines if paywall should be shown after an ad has been shown
    func shouldShowPaywallAfterAd(type: AdType, for section: AppSection, userIsPremium: Bool) -> Bool {
        if userIsPremium {
            return false
        }

        let state = sessionManager.getState(type: type, for: section)
        return state.hasShown
    }

    /// Checks if an ad has been shown in the current session
    func hasShownAdInSession(type: AdType, for section: AppSection) -> Bool {
        return sessionManager.getState(type: type, for: section).hasShown
    }

    /// Gets the number of times an ad has been shown in current session
    func getAdShowCount(type: AdType, for section: AppSection) -> Int {
        return sessionManager.getState(type: type, for: section).showCount
    }

    /// Resets session state for debugging/testing
    func resetSessionState(for section: AppSection? = nil, adType: AdType? = nil) {
        sessionManager.resetState(for: section, adType: adType)
        print("AdManager: Reset session state for section: \(section?.rawValue ?? "all"), adType: \(adType?.rawValue ?? "all")")
    }

    // MARK: - Private Helpers

    private func getConfiguration(type: AdType, for section: AppSection) -> AdConfiguration {
        return adConfigurations[section]?[type] ?? AdConfiguration.default
    }

    // MARK: - Pre-loading for Instant Display

    /// Pre-loads an interstitial ad for a specific section to eliminate delay
    func preloadInterstitialForSection(_ section: AppSection) {
        // 0. Premium Check: Don't load ads for premium users
        guard !SubscriptionManager.shared.isPremium else {
            print("AdManager: Skipping preload for \(section.rawValue) - User is Premium")
            return
        }
        
        // 1. Strict Cap Check: If we shouldn't show (limit reached), don't load.
        guard shouldShowAd(type: .interstitial, for: section) else {
            print("AdManager: Skipping preload for \(section.rawValue) - Session Limit Reached")
            return
        }

        // 2. Duplicate Check: If we already have one, don't load.
        if preloadedInterstitials[section] != nil {
            print("AdManager: Skipping preload for \(section.rawValue) - Ad Already Loaded")
            return
        }

        print("AdManager: Pre-loading interstitial for \(section.rawValue)")

        Task { @MainActor in
            do {
                let adUnitID = AdMobConfiguration.shared.interstitialAdUnitID
                let ad = try await InterstitialAdViewModel.loadInterstitial(adUnitID: adUnitID)
                ad.fullScreenContentDelegate = self
                self.preloadedInterstitials[section] = ad
                print("AdManager: Successfully pre-loaded interstitial for \(section.rawValue)")
            } catch {
                print("AdManager: Failed to pre-load interstitial for \(section.rawValue): \(error)")
            }
        }
    }

    /// Shows a pre-loaded interstitial instantly (no delay)
    func showPreloadedInterstitial(for section: AppSection, from rootViewController: UIViewController, onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) -> Bool {
        // 1. Check if we are allowed to show this ad (Frequency Capping)
        guard shouldShowAd(type: .interstitial, for: section) else {
            print("AdManager: Frequency cap reached for \(section.rawValue). Skipping.")
            return false
        }

        guard let preloadedAd = preloadedInterstitials[section] else {
            print("AdManager: No pre-loaded interstitial available for \(section.rawValue)")
            return false
        }

        // Set up completion callbacks
        self.interstitialSuccessCallback = onSuccess
        self.interstitialFailureCallback = onFailure

        // Ensure delegate is set (safety check)
        preloadedAd.fullScreenContentDelegate = self

        // Present the ad
        preloadedAd.present(from: rootViewController)

        // 2. Mark as shown immediately to prevent double-triggering
        markAdShown(type: .interstitial, for: section)

        // Remove from preloaded cache (ads can only be shown once)
        preloadedInterstitials[section] = nil

        print("AdManager: Showing pre-loaded interstitial for \(section.rawValue)")
        return true
    }

    // Callbacks for when interstitial succeeds or fails
    private var interstitialSuccessCallback: (() -> Void)?
    private var interstitialFailureCallback: (() -> Void)?

    /// Clears pre-loaded ads (useful when user becomes premium)
    func clearPreloadedAds() {
        preloadedInterstitials.removeAll()
        preloadedAppOpenAd = nil
        print("AdManager: Cleared all pre-loaded ads")
    }

    // MARK: - App Open Ad Management

    // Track pre-loaded app open ad
    private var preloadedAppOpenAd: AppOpenAd?
    private var appOpenLoadTime: Date?
    private var appOpenSuccessCallback: (() -> Void)?
    private var appOpenFailureCallback: (() -> Void)?

    /// Pre-loads an app open ad for instant display
    func preloadAppOpenAd(adUnitID: String? = nil) {
        // 0. Premium Check: Don't load ads for premium users
        guard !SubscriptionManager.shared.isPremium else {
            print("AdManager: Skipping App Open ad preload - User is Premium")
            return
        }
        
        let finalAdUnitID = adUnitID ?? AdMobConfiguration.shared.appOpenAdUnitID
        // Only preload if we don't already have one
        guard preloadedAppOpenAd == nil else {
            print("AdManager: App Open ad already preloaded - skipping duplicate load")
            return
        }

        print("AdManager: Pre-loading App Open ad (Caller: \(#function))")
        AppOpenAd.load(with: finalAdUnitID, request: createAdRequest()) { [weak self] ad, error in
            if let ad = ad {
                self?.preloadedAppOpenAd = ad
                self?.appOpenLoadTime = Date()
                ad.fullScreenContentDelegate = self
                print("AdManager: Successfully pre-loaded App Open ad")
            } else {
                print("AdManager: Failed to pre-load App Open ad: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    /// Loads and shows an App Open Ad immediately (used for First Launch ONLY)
    func loadAndShowAppOpenAd(from rootViewController: UIViewController, completion: (() -> Void)? = nil) {
        // 0. Premium Check: Don't load/show ads for premium users
        guard !SubscriptionManager.shared.isPremium else {
            print("AdManager: Skipping App Open Ad - User is Premium")
            completion?()
            return
        }
        
        // Check if already shown in this session
        guard shouldShowAd(type: .openApp, for: .appLaunch) else {
            print("AdManager: App Open Ad already shown in this session, skipping")
            completion?()
            return
        }
        
        let finalAdUnitID = AdMobConfiguration.shared.appOpenAdUnitID
        print("AdManager: Loading and Showing App Open Ad (Immediate - First Launch)")

        AppOpenAd.load(with: finalAdUnitID, request: createAdRequest()) { [weak self] ad, error in
            guard let self = self else { return }

            if let ad = ad {
                print("AdManager: Immediate App Open Ad loaded. Showing...")
                ad.fullScreenContentDelegate = self
                self.appOpenSuccessCallback = completion
                ad.present(from: rootViewController)
                self.markAdShown(type: .openApp, for: .appLaunch)
            } else {
                print("AdManager: Failed to load immediate App Open Ad: \(error?.localizedDescription ?? "Unknown error")")
                completion?()
            }
        }
    }

    /// Shows the pre-loaded app open ad if available and not expired
    func showPreloadedAppOpenAd(from rootViewController: UIViewController, userIsPremium: Bool, onSuccess: @escaping () -> Void, onFailure: @escaping () -> Void) -> Bool {
        print("AdManager: showPreloadedAppOpenAd called - checking conditions...")
        
        // Check if user should see app open ad (use appBackgroundReturn section)
        guard shouldShowAd(type: .openApp, for: .appBackgroundReturn, userIsPremium: userIsPremium) else {
            print("AdManager: App Open ad should not be shown (premium user or session rules)")
            print("AdManager: - isPremium: \(userIsPremium)")
            print("AdManager: - shouldShowAd returned false")
            onFailure()
            return false
        }
        print("AdManager: shouldShowAd check passed ✅")

        guard let preloadedAd = preloadedAppOpenAd else {
            print("AdManager: No pre-loaded App Open ad available ❌")
            onFailure()
            return false
        }
        print("AdManager: Pre-loaded ad found ✅")

        // Check if ad is not expired (Google recommends showing within 4 hours)
        if let loadTime = appOpenLoadTime {
            let timeInterval = Date().timeIntervalSince(loadTime)
            print("AdManager: Ad loaded \(Int(timeInterval)) seconds ago")
            if timeInterval > 4 * 60 * 60 { // 4 hours in seconds
                print("AdManager: App Open ad expired, not showing ❌")
                preloadedAppOpenAd = nil
                appOpenLoadTime = nil
                onFailure()
                return false
            }
        }
        print("AdManager: Ad expiry check passed ✅")

        // Set up completion callbacks
        self.appOpenSuccessCallback = onSuccess
        self.appOpenFailureCallback = onFailure
        
        // Ensure delegate is set (should already be set, but just in case)
        preloadedAd.fullScreenContentDelegate = self

        print("AdManager: Presenting App Open ad now... 🚀")
        // Present the ad
        preloadedAd.present(from: rootViewController)

        // Mark as shown in session (use appBackgroundReturn section)
        markAdShown(type: .openApp, for: .appBackgroundReturn)

        // Remove from preloaded cache (ads can only be shown once)
        preloadedAppOpenAd = nil
        appOpenLoadTime = nil

        print("AdManager: App Open ad presentation initiated (Background Return)")
        return true
    }

    /// Check if app open ad is ready to show
    func isAppOpenAdReady(userIsPremium: Bool) -> Bool {
        guard preloadedAppOpenAd != nil else {
            return false
        }

        // Check expiry
        if let loadTime = appOpenLoadTime {
            let timeInterval = Date().timeIntervalSince(loadTime)
            if timeInterval > 4 * 60 * 60 { // 4 hours
                preloadedAppOpenAd = nil
                appOpenLoadTime = nil
                return false
            }
        }

        return shouldShowAd(type: .openApp, for: .appBackgroundReturn, userIsPremium: userIsPremium)
    }

    // Banner
    func loadBanner(adUnitID: String, rootViewController: UIViewController, width: CGFloat) {
        let banner = BannerView(adSize: currentOrientationAnchoredAdaptiveBanner(width: width))
        banner.adUnitID = adUnitID
        banner.rootViewController = rootViewController
        banner.delegate = self
        banner.load(createAdRequest())
        self.bannerView = banner
    }

    // Native
    func loadNativeAd(adUnitID: String, rootViewController: UIViewController) {
        let options = MultipleAdsAdLoaderOptions()
        options.numberOfAds = 1
        adLoader = AdLoader(adUnitID: adUnitID,
                            rootViewController: rootViewController,
                            adTypes: [.native],
                            options: [options])
        adLoader?.delegate = self
        adLoader?.load(createAdRequest())
    }

    // Interstitial
    func loadInterstitial(adUnitID: String, completion: ((Bool) -> Void)? = nil) {
        self.interstitialAdUnitID = adUnitID
        self.interstitialLoadCompletion = completion
        InterstitialAd.load(with: adUnitID, request: createAdRequest()) { [weak self] ad, error in
            if let ad = ad {
                self?.interstitial = ad
                self?.interstitial?.fullScreenContentDelegate = self
                completion?(true)
                print("Interstitial loaded")
            } else {
                self?.interstitial = nil
                completion?(false)
                print("Interstitial failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    func showInterstitial(from rootViewController: UIViewController) {
        guard let interstitial = interstitial else {
            print("Interstitial not ready")
            return
        }
        interstitial.present(from: rootViewController)
        self.interstitial = nil // Must be reloaded after showing
    }
}

// MARK: - Interstitial Delegate
extension AdManager: FullScreenContentDelegate {
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad failed to present: \(error.localizedDescription)")

        // Check if it's an App Open ad or Interstitial
        if ad is AppOpenAd {
            print("App Open ad failed to present: \(error.localizedDescription)")
            appOpenFailureCallback?()
            appOpenFailureCallback = nil
            appOpenSuccessCallback = nil
        } else {
            print("Interstitial failed to present: \(error.localizedDescription)")
            interstitialFailureCallback?()
            interstitialFailureCallback = nil
            interstitialSuccessCallback = nil
        }
    }

    func adWillPresentFullScreenContent(_ ad: any FullScreenPresentingAd) {
        if ad is AppOpenAd {
            print("App Open ad will present")
        } else {
            print("Interstitial will present")
        }
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        if ad is AppOpenAd {
            print("App Open ad did dismiss")
            // Call success callback (ad was shown successfully)
            appOpenSuccessCallback?()
            appOpenSuccessCallback = nil
            appOpenFailureCallback = nil
        } else {
            print("Interstitial did dismiss")
            // Call success callback (ad was shown successfully)
            interstitialSuccessCallback?()
            interstitialSuccessCallback = nil
            interstitialFailureCallback = nil

            // No automatic reloading - ads should only be preloaded when actually needed
        }
    }
}

// MARK: - Banner Delegate
extension AdManager: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        print("Banner loaded")
    }
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        print("Banner failed: \(error.localizedDescription)")
    }
    func bannerViewDidRecordClick(_ bannerView: BannerView) {
        print("Banner clicked")
    }
    func bannerViewDidRecordImpression(_ bannerView: BannerView) {
        print("Banner impression")
    }
}

// MARK: - Native Delegate
extension AdManager: NativeAdLoaderDelegate {
    func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        self.nativeAd = nativeAd
        print("Native ad loaded")
    }
    func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        print("Native ad failed: \(error.localizedDescription)")
    }
}

