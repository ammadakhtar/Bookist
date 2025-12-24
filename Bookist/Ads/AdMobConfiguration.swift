//
//  AdMobConfiguration.swift
//  Bookist
//
//  Created by Ammad Akhtar on 24/12/2025.
//

import Foundation

/// Centralized configuration for all Google AdMob ad unit IDs
/// This provides a single source of truth for ad monetization configuration
final class AdMobConfiguration {
    static let shared = AdMobConfiguration()

    private init() {}

    // MARK: - Environment Configuration

    /// Current ad environment - change this to switch between test and production
    private var environment: AdEnvironment {
#if DEBUG
        return .test
#else
        return .production
#endif
    }

    private enum AdEnvironment {
        case test
        case production
    }

    // MARK: - Production Ad Unit IDs

    private struct ProductionAdUnits {
        static let banner = "ca-app-pub-4505236895806079/9799060787"
        static let interstitial = "ca-app-pub-4505236895806079/3542991237"
        static let native = "ca-app-pub-4505236895806079/9916827893"
        static let appOpen = "ca-app-pub-4505236895806079/2477499188"
    }

    // MARK: - Test Ad Unit IDs (Google's test IDs)

    private struct TestAdUnits {
        static let banner = "ca-app-pub-3940256099942544/6300978111"
        static let interstitial = "ca-app-pub-3940256099942544/1033173712"
        static let native = "ca-app-pub-3940256099942544/2247696110"
        static let appOpen = "ca-app-pub-3940256099942544/9257395921"
    }

    // MARK: - Public Ad Unit ID Accessors

    /// Banner ad unit ID for the current environment
    var bannerAdUnitID: String {
        switch environment {
        case .production:
            return ProductionAdUnits.banner
        case .test:
            return TestAdUnits.banner
        }
    }

    /// Interstitial ad unit ID for the current environment
    var interstitialAdUnitID: String {
        switch environment {
        case .production:
            return ProductionAdUnits.interstitial
        case .test:
            return TestAdUnits.interstitial
        }
    }

    /// Native ad unit ID for the current environment
    var nativeAdUnitID: String {
        switch environment {
        case .production:
            return ProductionAdUnits.native
        case .test:
            return TestAdUnits.native
        }
    }

    /// App open ad unit ID for the current environment
    var appOpenAdUnitID: String {
        switch environment {
        case .production:
            return ProductionAdUnits.appOpen
        case .test:
            return TestAdUnits.appOpen
        }
    }

    // MARK: - Debug Information

    /// Returns the current environment as a string for debugging
    var currentEnvironment: String {
        switch environment {
        case .production:
            return "Production"
        case .test:
            return "Test"
        }
    }

    /// Prints current ad configuration for debugging
    func printConfiguration() {
        print("🎯 AdConfiguration - Environment: \(currentEnvironment)")
        print("📺 Banner: \(bannerAdUnitID)")
        print("🎬 Interstitial: \(interstitialAdUnitID)")
        print("📰 Native: \(nativeAdUnitID)")
        print("🚀 App Open: \(appOpenAdUnitID)")
    }
}

