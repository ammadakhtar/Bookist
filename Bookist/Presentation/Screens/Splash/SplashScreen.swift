import SwiftUI

struct SplashScreen: View {
    @State private var bookScale: CGFloat = 1.0
    @State private var bookOpacity: Double = 0
    @State private var textScale: CGFloat = 0.95
    @State private var textOpacity: Double = 0
    @State private var textBlur: CGFloat = 10
    @State private var isAnimating = false
    @State private var showHome = false
    @State private var splashOpacity: Double = 1
    @State private var displayText: String = ""
    @State private var attRequested = false
    @State private var shouldShowAppOpenAd = false
    
    // Callback to notify when splash completes
    let onComplete: (() -> Void)?
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }
    
    // Daily motivational reading quotes
    private let motivationalTexts = [
        "A reader lives a thousand lives",
        "Reading is dreaming with open eyes",
        "Books are uniquely portable magic",
        "Today a reader, tomorrow a leader",
        "One book can change your entire life",
        "Reading is to the mind what exercise is to the body",
        "The more you read, the more things you will know",
        "A book is a dream you hold in your hands",
        "Reading is the gateway to adventure",
        "Books are mirrors: you only see in them what you already have inside",
        "There is no friend as loyal as a book",
        "Words are, in my not-so-humble opinion, our most inexhaustible source of magic"
    ]
    
    private var bookIconSize: CGFloat {
        #if targetEnvironment(macCatalyst)
        return 240
        #else
        return UIDevice.current.userInterfaceIdiom == .pad ? 200 : 140
        #endif
    }
    
    private var iconCornerRadius: CGFloat {
        #if targetEnvironment(macCatalyst)
        return 60
        #else
        return UIDevice.current.userInterfaceIdiom == .pad ? 50 : 35
        #endif
    }
    
    var body: some View {
        ZStack {
            if showHome {
                ContentView()
                    .transition(.opacity)
            } else {
                splashContent
                    .opacity(splashOpacity)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: showHome)
        .onAppear {
            // Pick one random text and keep it throughout the splash
            displayText = motivationalTexts.randomElement() ?? motivationalTexts[0]
            startAnimations()
        }
    }
    
    private var splashContent: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Book Icon with Breathing Animation
            Image("book")
                .resizable()
                .scaledToFit()
                .frame(width: bookIconSize, height: bookIconSize)
                .clipShape(RoundedRectangle(cornerRadius: iconCornerRadius, style: .continuous))
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                .scaleEffect(bookScale)
                .opacity(bookOpacity)
            
            // Motivational Text
            Text(displayText)
                .font(.system(size: UIDevice.current.userInterfaceIdiom == .pad ? 24 : 18, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .scaleEffect(textScale)
                .blur(radius: textBlur)
                .opacity(textOpacity)
            
            Spacer()
        }
    }
    
    private func startAnimations() {
        // Phase 1: Book icon fade-in with breathing effect (0-1.0s)
        withAnimation(.easeOut(duration: 0.8)) {
            bookOpacity = 1.0
        }
        
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            bookScale = 1.05
        }
        
        // Phase 2: Text smooth blur-fade-scale in (1.2-2.0s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation(.easeOut(duration: 1.0)) {
                textScale = 1.0
                textBlur = 0
                textOpacity = 1.0
            }
        }
        
        // Phase 3: Request ATT permission after splash animations (2.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            requestATTAndPrepareAds()
        }
    }
    
    private func requestATTAndPrepareAds() {
        // Request ATT first (this is the FIRST permission we ask for)
        AdsConsentManager.shared.checkAdsState {
            // After ATT decision, request notification permission
            DispatchQueue.main.async {
                attRequested = true
                requestNotificationPermission()
            }
        }
    }
    
    private func requestNotificationPermission() {
        // Request notification permission after ATT
        Task {
            let granted = await NotificationManager.shared.requestAuthorization()
            print(granted ? "✅ Notification permission granted" : "❌ Notification permission denied")
            
            // After notification permission, fetch and show app open ad
            DispatchQueue.main.async {
                fetchAndShowAppOpenAd()
            }
        }
    }
    
    private func fetchAndShowAppOpenAd() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            // No root VC, skip to home
            transitionToHome()
            return
        }
        
        // Load and show app open ad immediately on app launch
        AdManager.shared.loadAndShowAppOpenAd(from: rootVC) {
            // Ad dismissed, show home
            DispatchQueue.main.async {
                transitionToHome()
            }
        }
    }
    
    private func transitionToHome() {
        withAnimation(.easeOut(duration: 0.6)) {
            splashOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showHome = true
            // Notify that splash is complete
            onComplete?()
        }
    }
}

// MARK: - Enhanced Breathing Animation Variant
struct BreathingBookAnimation: View {
    @State private var isBreathing = false
    let size: CGFloat
    
    var body: some View {
        Image("book")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .scaleEffect(isBreathing ? 1.1 : 1.0)
            .opacity(isBreathing ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isBreathing)
            .onAppear {
                isBreathing = true
            }
    }
}

#Preview {
    SplashScreen()
}
