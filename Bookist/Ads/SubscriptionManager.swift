//
//  SubscriptionManager.swift
//  PulseMate
//
//  Created by Ammad Akhtar on 18/12/2025.
//

import Foundation
import SwiftUI
import StoreKit

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()

    @Published var isPremium: Bool = false
    @Published var activeProductId: String? = nil
    @Published var showingPaywall: Bool = false
    @Published var isLoading: Bool = false
    @Published var productsLoaded: Bool = false
    @Published var availableProducts: [Product] = []

    private let productIds = [
        "com.bookist.monthly",
        "com.bookist.yearly"
    ]

    // Track app readiness for presentations
    private var isAppReady: Bool = false
    private var pendingPaywallRequest: Bool = false
    private var transactionListener: Task<Void, Error>?

    // Persistence
    private let premiumKey = "isPremium"

    private init() {
        // Load cached premium status first to avoid UI flash
        self.isPremium = UserDefaults.standard.bool(forKey: premiumKey)

        Task {
            await loadProducts()
            await checkSubscriptionStatus()
        }

        // Start listening for transaction updates
        transactionListener = listenForTransactions()
    }

    deinit {
        transactionListener?.cancel()
    }

    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in StoreKit.Transaction.updates {
                if case .verified(let transaction) = result {
                    if self.productIds.contains(transaction.productID) {
                        await MainActor.run {
                            self.activeProductId = transaction.productID
                            self.setPremium(true)
                            AdManager.shared.clearPreloadedAds()
                            print("🎉 Transaction update: User became premium with \(transaction.productID)")
                        }
                    }
                    await transaction.finish()
                }
            }
        }
    }

    private func setPremium(_ value: Bool) {
        isPremium = value
        UserDefaults.standard.setValue(value, forKey: premiumKey)
    }

    // Load products from App Store
    @MainActor
    private func loadProducts() async {
        do {
            let products = try await Product.products(for: productIds)
            self.availableProducts = products
            self.productsLoaded = true
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    // Check current subscription status
    @MainActor
    private func checkSubscriptionStatus() async {
        let wasPremium = isPremium
        var hasActiveSubscription = false

        for await result in StoreKit.Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if productIds.contains(transaction.productID) {
                    hasActiveSubscription = true
                    activeProductId = transaction.productID
                    setPremium(true)

                    // Clear ads if user just became premium
                    if !wasPremium {
                        AdManager.shared.clearPreloadedAds()
                        print("🎉 User became premium - cleared all preloaded ads")
                    }

                    print("✅ Active subscription found: \(transaction.productID)")
                    return
                }
            }
        }

        // No active subscription found
        if !hasActiveSubscription {
            activeProductId = nil
            setPremium(false)
            print("❌ No active subscription found")
        }
    }

    // Purchase a subscription
    func purchaseSubscription(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()

                // Set premium status immediately after successful verified purchase
                // No need to check subscription status - verified transaction IS the proof
                await MainActor.run {
                    let wasPremium = self.isPremium
                    self.activeProductId = transaction.productID
                    self.setPremium(true)

                    // Clear ads since user is now premium
                    if !wasPremium {
                        AdManager.shared.clearPreloadedAds()
                        print("🎉 User became premium - cleared all preloaded ads")
                    }

                    print("✅ Purchase successful for product: \(transaction.productID)")
                }
            case .unverified:
                throw PurchaseError.unverifiedPurchase
            }
        case .userCancelled:
            throw PurchaseError.userCancelled
        case .pending:
            throw PurchaseError.purchasePending
        @unknown default:
            throw PurchaseError.unknown
        }
    }

    // Get product by ID
    func getProduct(for productId: String) -> Product? {
        return availableProducts.first { $0.id == productId }
    }

    // Get monthly product
    var monthlyProduct: Product? {
        return availableProducts.first { $0.id.contains("monthly") }
    }

    // Get yearly product
    var yearlyProduct: Product? {
        return availableProducts.first { $0.id.contains("yearly") }
    }

    // Restore purchases
    func restorePurchases() async {
        isLoading = true
        try? await AppStore.sync()
        await checkSubscriptionStatus()
        await MainActor.run {
            isLoading = false
        }
    }

    // Purchase wrapper for SwiftUI
    func purchase(_ product: Product) {
        isLoading = true

        Task {
            do {
                try await purchaseSubscription(product)
                await MainActor.run {
                    self.isLoading = false
                    self.showingPaywall = false

                    // Success feedback
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    print("Purchase failed: \(error.localizedDescription)")
                }
            }
        }
    }

    // Check if feature is available
    func hasAccess(to feature: String) -> Bool {
        return isPremium
    }

    // Show paywall with proper presentation control
    func showPaywall() {
        // If app isn't ready yet, queue the request
        if !isAppReady {
            pendingPaywallRequest = true
            return
        }

        // Prevent multiple simultaneous presentations
        guard !showingPaywall else { return }

        showingPaywall = true
    }

    // Mark app as ready for presentations
    func markAppReady() {
        isAppReady = true

        // Show pending paywall if requested
        if pendingPaywallRequest {
            pendingPaywallRequest = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showPaywall()
            }
        }
    }

    // Debug function to toggle premium status for testing
    func togglePremiumForTesting() {
        setPremium(!isPremium)

        // Clear all ads when user becomes premium
        if isPremium {
            AdManager.shared.clearPreloadedAds()
            print("🎉 User became premium - cleared all preloaded ads")
        }
    }
}

enum PurchaseError: Error, LocalizedError {
    case unverifiedPurchase
    case userCancelled
    case purchasePending
    case unknown

    var errorDescription: String? {
        switch self {
        case .unverifiedPurchase:
            return "Purchase could not be verified"
        case .userCancelled:
            return "Purchase was cancelled"
        case .purchasePending:
            return "Purchase is pending approval"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
