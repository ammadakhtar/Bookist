//
//  PaywallView.swift
//  Bookist
//
//  Created by Ammad Akhtar on 24/12/2025.
//

import SwiftUI
import StoreKit
import SafariServices

struct PaywallView: View {
    @ObservedObject var subscriptionManager: SubscriptionManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfUse = false
    @State private var isBreathing = false

    // Premium features list
    private let premiumFeatures = [
        "Remove all advertisements",
        "Access to unlimited free books",
        "Ad-free reading experience",
        "Early access to new books",
        "Offline reading capability"
    ]

    // MARK: - Subscription Logic Helpers

    fileprivate enum SubscriptionState {
        case current
        case upgrade
        case downgrade
        case buy

        var buttonText: String {
            switch self {
            case .current: return "Current Plan"
            case .upgrade: return "Upgrade to Yearly"
            case .downgrade: return "Switch to Monthly"
            case .buy: return "Start Premium"
            }
        }
    }

    private func getSubscriptionState(for product: Product) -> SubscriptionState {
        guard let activeId = subscriptionManager.activeProductId else {
            return .buy
        }

        if product.id == activeId {
            return .current
        }

        // Logic for upgrade/downgrade
        if activeId.contains("monthly") && product.id.contains("yearly") {
            return .upgrade
        }

        if activeId.contains("yearly") && product.id.contains("monthly") {
            return .downgrade
        }

        return .buy
    }

    var body: some View {
        ZStack {
            // Dark background matching splash screen
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color(hex: "#323232"), location: 0.33),
                    Gradient.Stop(color: Color(hex: "#000000"), location: 1.00)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                headerSection

                // Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Heart icon and title
                        titleSection

                        // Features list
                        featuresSection

                        // Subscription options
                        subscriptionOptionsSection

                        // Subscribe button
                        subscribeButton

                        // Footer options
                        footerSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showingPrivacyPolicy) {
            SafariView(url: URL(string: "https://doc-hosting.flycricket.io/bookist/d16c5b6e-c9c9-4362-b57e-df81e1fda38f/privacy")!)
        }
        .sheet(isPresented: $showingTermsOfUse) {
            SafariView(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
        }
        .onAppear {
            isBreathing = true
        }
        .onDisappear {
            isBreathing = false
        }
    }

    private var headerSection: some View {
        HStack {
            Button {
                HapticHelper.light()
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 18)
    }

    private var titleSection: some View {
        VStack(spacing: 16) {
            // Book icon with gradient and splash screen animation
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            AppColors.accent,
                            AppColors.accentOrange
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: AppColors.accent.opacity(0.5), radius: 10, x: 0, y: 5)
                .scaleEffect(isBreathing ? 1.05 : 1.0)
                .opacity(isBreathing ? 0.9 : 1.0)
                .animation(isBreathing ? Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true) : .default, value: isBreathing)

            Text("BookPad Premium")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)

            Text("Unlock unlimited books and ad-free reading")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.top, 12)
    }

    private var featuresSection: some View {
        VStack(spacing: 12) {
            ForEach(premiumFeatures, id: \.self) { feature in
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(AppColors.accent)
                        .shadow(color: AppColors.accent.opacity(0.3), radius: 3, x: 0, y: 2)

                    Text(feature)
                        .font(.system(size: 16))
                        .foregroundColor(.white)

                    Spacer()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    private var subscriptionOptionsSection: some View {
        VStack(spacing: 12) {
            if subscriptionManager.productsLoaded {
                ForEach(subscriptionManager.availableProducts, id: \.id) { product in
                    SubscriptionOptionCard(
                        product: product,
                        isSelected: selectedProduct?.id == product.id,
                        state: getSubscriptionState(for: product),
                        onTap: {
                            selectedProduct = product
                            HapticHelper.light()
                        }
                    )
                }
            } else {
                ProgressView("Loading products...")
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .onAppear {
            // Priority 1: Select the currently active product
            if let activeId = subscriptionManager.activeProductId {
                if let activeProduct = subscriptionManager.availableProducts.first(where: { $0.id == activeId }) {
                    selectedProduct = activeProduct
                    return
                }
            }

            // Priority 2: Auto-select yearly product if available
            if selectedProduct == nil, let yearlyProduct = subscriptionManager.yearlyProduct {
                selectedProduct = yearlyProduct
            }
        }
    }

    private var subscribeButton: some View {
        Group {
            if let product = selectedProduct {
                let state = getSubscriptionState(for: product)

                Button {
                    HapticHelper.medium()
                    subscriptionManager.purchase(product)
                } label: {
                    HStack {
                        if subscriptionManager.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text(state.buttonText)
                                .font(.system(size: 18, weight: .bold))
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(
                                state == .downgrade ?
                                AnyShapeStyle(AppColors.secondaryText.opacity(0.3)) :
                                    AnyShapeStyle(LinearGradient(
                                        colors: [
                                            AppColors.accent,
                                            AppColors.accentOrange
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                            )
                            .shadow(color: state == .downgrade ? Color.clear : AppColors.accent.opacity(0.4), radius: 10, x: 0, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(state == .downgrade ? AppColors.secondaryText.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
                }
                .disabled(subscriptionManager.isLoading || state == .current)
                .opacity(subscriptionManager.isLoading || state == .current ? 0.6 : 1.0)
            }
        }
    }

    private var footerSection: some View {
        VStack(spacing: 12) {
            Button("Restore Purchases") {
                HapticHelper.light()
                Task {
                    await subscriptionManager.restorePurchases()
                }
            }
            .font(.system(size: 16))
            .foregroundColor(.white.opacity(0.7))

            HStack(spacing: 20) {
                Button("Terms of Use") {
                    HapticHelper.light()
                    showingTermsOfUse = true
                }
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))

                Button("Privacy Policy") {
                    HapticHelper.light()
                    showingPrivacyPolicy = true
                }
                .font(.system(size: 14))
                .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.top, 8)
    }
}

struct SubscriptionOptionCard: View {
    let product: Product
    let isSelected: Bool
    fileprivate let state: PaywallView.SubscriptionState
    let onTap: () -> Void

    private var displayName: String {
        if product.id.contains("monthly") {
            return "Monthly Premium"
        } else if product.id.contains("yearly") {
            return "Yearly Premium"
        } else {
            return product.displayName
        }
    }

    private var description: String {
        if state == .current {
            return "Current Plan"
        }

        if product.id.contains("yearly") {
            return "Best value • All premium features"
        } else {
            return "All premium features"
        }
    }

    private var period: String {
        if product.id.contains("monthly") {
            return "month"
        } else if product.id.contains("yearly") {
            return "year"
        } else {
            return "month"
        }
    }

    private var savings: String? {
        if product.id.contains("yearly") {
            return "Save 73%"
        }
        return nil
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(state == .current ? AppColors.accent.opacity(0.4) : Color.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected || state == .current {
                        Circle()
                            .fill(
                                state == .current ?
                                AnyShapeStyle(AppColors.accent) :
                                    AnyShapeStyle(LinearGradient(
                                        colors: [
                                            AppColors.accent,
                                            AppColors.accentOrange
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ))
                            )
                            .frame(width: 12, height: 12)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(displayName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(state == .current ? AppColors.accent : .white)

                        if let savings = savings, state != .current {
                            Text(savings)
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    AppColors.accent,
                                                    AppColors.accentOrange
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                )
                        }

                        Spacer()
                    }

                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(state == .current ? AppColors.accent.opacity(0.8) : .white.opacity(0.7))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(state == .current ? AppColors.accent : .white)

                    Text("per \(period)")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.white.opacity(0.12) : Color.white.opacity(0.06))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                state == .current ?
                                AnyShapeStyle(AppColors.accent.opacity(0.5)) :
                                    isSelected ?
                                AnyShapeStyle(LinearGradient(
                                    colors: [
                                        AppColors.accent,
                                        AppColors.accentOrange
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )) :
                                    AnyShapeStyle(Color.white.opacity(0.15)),
                                lineWidth: (isSelected || state == .current) ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(state == .current)
    }
}

// MARK: - SafariView Wrapper
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = UIColor.systemBlue
        return safariViewController
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No updates needed
    }
}

#Preview {
    PaywallView(subscriptionManager: SubscriptionManager.shared)
}
