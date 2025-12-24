import Foundation
import GoogleMobileAds
import SwiftUI
import AppTrackingTransparency

// MARK: - BannerAdView
struct BannerAdView: UIViewRepresentable {
    @ObservedObject var viewModel: BannerAdViewModel

    init(viewModel: BannerAdViewModel) {
        self.viewModel = viewModel
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> BannerView {
        viewModel.bannerView ?? BannerView(adSize: currentOrientationAnchoredAdaptiveBanner(width: viewModel.width))
    }

    func updateUIView(_ uiView: BannerView, context: Context) {
        // No-op: BannerAdViewModel handles updates
    }

    class Coordinator: NSObject {}
}

// MARK: - NativeAdView
struct NativeAdView: UIViewRepresentable {
    typealias UIViewType = GoogleMobileAds.NativeAdView

    @ObservedObject var viewModel: NativeAdViewModel

    init(viewModel: NativeAdViewModel) {
        self.viewModel = viewModel
    }

    func makeUIView(context: Context) -> GoogleMobileAds.NativeAdView {
        let nativeAdView = GoogleMobileAds.NativeAdView()
        // Only set background and styling when ad is loaded
        nativeAdView.backgroundColor = UIColor.clear // Start with clear background
        nativeAdView.layer.cornerRadius = 12
        nativeAdView.layer.masksToBounds = true

        // Create media view
        let mediaView = MediaView()
        mediaView.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.mediaView = mediaView
        nativeAdView.addSubview(mediaView)

        // Create icon view
        let iconView = UIImageView()
        iconView.contentMode = .scaleAspectFit
        iconView.layer.cornerRadius = 8
        iconView.clipsToBounds = true
        iconView.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.iconView = iconView
        nativeAdView.addSubview(iconView)

        // Create headline label
        let headlineLabel = UILabel()
        headlineLabel.font = UIFont.boldSystemFont(ofSize: 18)
        headlineLabel.textColor = .label
        headlineLabel.numberOfLines = 2
        headlineLabel.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.headlineView = headlineLabel
        nativeAdView.addSubview(headlineLabel)

        // Create body label
        let bodyLabel = UILabel()
        bodyLabel.font = UIFont.systemFont(ofSize: 14)
        bodyLabel.textColor = .secondaryLabel
        bodyLabel.numberOfLines = 3
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.bodyView = bodyLabel
        nativeAdView.addSubview(bodyLabel)

        // Create call to action button
        let ctaButton = UIButton(type: .system)
        ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.backgroundColor = UIColor.systemBlue
        ctaButton.layer.cornerRadius = 10
        ctaButton.clipsToBounds = true
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        nativeAdView.callToActionView = ctaButton
        nativeAdView.addSubview(ctaButton)

        // Set up constraints
        NSLayoutConstraint.activate([
            mediaView.topAnchor.constraint(equalTo: nativeAdView.topAnchor, constant: 16),
            mediaView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 16),
            mediaView.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -16),
            mediaView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            mediaView.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),

            iconView.topAnchor.constraint(equalTo: mediaView.bottomAnchor, constant: 16),
            iconView.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 16),
            iconView.widthAnchor.constraint(equalToConstant: 50),
            iconView.heightAnchor.constraint(equalToConstant: 50),

            headlineLabel.leadingAnchor.constraint(equalTo: iconView.trailingAnchor, constant: 12),
            headlineLabel.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -16),
            headlineLabel.topAnchor.constraint(equalTo: iconView.topAnchor),

            bodyLabel.leadingAnchor.constraint(equalTo: headlineLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: headlineLabel.trailingAnchor),
            bodyLabel.topAnchor.constraint(equalTo: headlineLabel.bottomAnchor, constant: 4),

            ctaButton.topAnchor.constraint(greaterThanOrEqualTo: iconView.bottomAnchor, constant: 12),
            ctaButton.topAnchor.constraint(greaterThanOrEqualTo: bodyLabel.bottomAnchor, constant: 12),
            ctaButton.leadingAnchor.constraint(equalTo: nativeAdView.leadingAnchor, constant: 16),
            ctaButton.trailingAnchor.constraint(equalTo: nativeAdView.trailingAnchor, constant: -16),
            ctaButton.heightAnchor.constraint(equalToConstant: 44),
            ctaButton.bottomAnchor.constraint(equalTo: nativeAdView.bottomAnchor, constant: -16)
        ])

        return nativeAdView
    }

    func updateUIView(_ nativeAdView: GoogleMobileAds.NativeAdView, context: Context) {
        if let nativeAd = viewModel.nativeAd {
            // Ad is loaded - show background and content
            nativeAdView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)

            // Set media content
            if let mediaView = nativeAdView.mediaView {
                mediaView.mediaContent = nativeAd.mediaContent
            }

            // Set headline
            (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline

            // Set body
            (nativeAdView.bodyView as? UILabel)?.text = nativeAd.body
            nativeAdView.bodyView?.isHidden = nativeAd.body == nil

            // Set icon
            (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
            nativeAdView.iconView?.isHidden = (nativeAd.icon == nil)

            // Set call to action
            (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
            nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
            nativeAdView.callToActionView?.isUserInteractionEnabled = false

            // Assign the native ad to the view (this makes it clickable)
            nativeAdView.nativeAd = nativeAd
        } else {
            // No ad loaded - hide background
            nativeAdView.backgroundColor = UIColor.clear
            nativeAdView.nativeAd = nil
        }
    }
}

// MARK: - View Models

@MainActor
final class InterstitialAdViewModel: NSObject, ObservableObject {
    @Published var interstitial: InterstitialAd?
    @Published var isLoaded: Bool = false
    @Published var error: Error?
    private var adUnitID: String

    init(adUnitID: String) {
        self.adUnitID = adUnitID
    }

    func load() async {
        do {
            let ad = try await Self.loadInterstitial(adUnitID: adUnitID)
            self.interstitial = ad
            self.isLoaded = true
            self.error = nil
        } catch {
            self.interstitial = nil
            self.isLoaded = false
            self.error = error
        }
    }

    static func loadInterstitial(adUnitID: String) async throws -> InterstitialAd {
        try await withCheckedThrowingContinuation { continuation in
            InterstitialAd.load(with: adUnitID, request: Request()) { ad, error in
                if let ad = ad {
                    continuation.resume(returning: ad)
                } else {
                    continuation.resume(throwing: error ?? NSError(domain: "InterstitialAd", code: -1, userInfo: nil))
                }
            }
        }
    }

    func present(from rootViewController: UIViewController) {
        guard let interstitial = interstitial else { return }
        interstitial.fullScreenContentDelegate = self
        interstitial.present(from: rootViewController)
    }
}

extension InterstitialAdViewModel: FullScreenContentDelegate {
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        self.error = error
        self.isLoaded = false
        self.interstitial = nil
    }
    func adWillPresentFullScreenContent(_ ad: any FullScreenPresentingAd) {}
    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        self.isLoaded = false
        self.interstitial = nil
    }
}

@MainActor
final class NativeAdViewModel: NSObject, ObservableObject {
    @Published var nativeAd: NativeAd?
    @Published var isLoaded: Bool = false
    @Published var error: Error?
    private var adLoader: AdLoader?
    private var adUnitID: String
    private weak var rootViewController: UIViewController?

    init(adUnitID: String, rootViewController: UIViewController?) {
        self.adUnitID = adUnitID
        self.rootViewController = rootViewController
        super.init()
        loadAd()
    }

    /// Creates an ad request configured for ATT compliance
    private func createAdRequest() -> Request {
        let request = Request()

        // Configure request based on ATT authorization status
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .authorized:
            // User allowed tracking - can show personalized ads
            break
        case .denied, .restricted, .notDetermined:
            // User denied tracking or hasn't decided - show non-personalized ads
            let extras = Extras()
            extras.additionalParameters = ["npa": "1"] // Non-personalized ads
            request.register(extras)
        @unknown default:
            // Unknown status - default to non-personalized
            let extras = Extras()
            extras.additionalParameters = ["npa": "1"] // Non-personalized ads
            request.register(extras)
        }

        return request
    }

    func loadAd() {
        // Skip loading ads for premium users
        guard !SubscriptionManager.shared.isPremium else {
            print("🎉 User is premium - skipping native ad load")
            return
        }

        let options = MultipleAdsAdLoaderOptions()
        options.numberOfAds = 1
        adLoader = AdLoader(adUnitID: adUnitID,
                            rootViewController: rootViewController,
                            adTypes: [.native],
                            options: [options])
        adLoader?.delegate = self
        adLoader?.load(createAdRequest())
    }
}

extension NativeAdViewModel: NativeAdLoaderDelegate {
    nonisolated func adLoader(_ adLoader: AdLoader, didReceive nativeAd: NativeAd) {
        Task { @MainActor in
            self.nativeAd = nativeAd
            self.isLoaded = true
            self.error = nil
        }
    }

    nonisolated func adLoader(_ adLoader: AdLoader, didFailToReceiveAdWithError error: Error) {
        Task { @MainActor in
            self.nativeAd = nil
            self.isLoaded = false
            self.error = error
        }
    }
}

@MainActor
final class BannerAdViewModel: NSObject, ObservableObject {
    @Published var bannerView: BannerView?
    @Published var isLoaded: Bool = false
    @Published var error: Error?

    private var adUnitID: String
    var width: CGFloat
    private weak var rootViewController: UIViewController?

    init(adUnitID: String, width: CGFloat, rootViewController: UIViewController?) {
        self.adUnitID = adUnitID
        self.width = width
        self.rootViewController = rootViewController
        super.init()
        loadBanner()
    }

    /// Creates an ad request configured for ATT compliance
    private func createAdRequest() -> Request {
        let request = Request()

        // Configure request based on ATT authorization status
        switch ATTrackingManager.trackingAuthorizationStatus {
        case .authorized:
            // User allowed tracking - can show personalized ads
            break
        case .denied, .restricted, .notDetermined:
            // User denied tracking or hasn't decided - show non-personalized ads
            let extras = Extras()
            extras.additionalParameters = ["npa": "1"] // Non-personalized ads
            request.register(extras)
        @unknown default:
            // Unknown status - default to non-personalized
            let extras = Extras()
            extras.additionalParameters = ["npa": "1"] // Non-personalized ads
            request.register(extras)
        }

        return request
    }

    func loadBanner() {
        // Skip loading ads for premium users
        guard !SubscriptionManager.shared.isPremium else {
            print("🎉 User is premium - skipping banner ad load")
            return
        }

        let banner = BannerView(adSize: currentOrientationAnchoredAdaptiveBanner(width: width))
        banner.adUnitID = adUnitID
        banner.rootViewController = rootViewController
        banner.delegate = self
        banner.load(createAdRequest())
        self.bannerView = banner
    }
}

extension BannerAdViewModel: BannerViewDelegate {
    func bannerViewDidReceiveAd(_ bannerView: BannerView) {
        isLoaded = true
        error = nil
    }
    func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
        isLoaded = false
        self.error = error
    }
    func bannerViewDidRecordClick(_ bannerView: BannerView) {}
    func bannerViewDidRecordImpression(_ bannerView: BannerView) {}
}
