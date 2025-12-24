import SwiftUI
import SwiftData

struct HeaderView: View {
    @Binding var selectedTab: String
    var streakData: [ReadingStreak]
    var onSearchTap: () -> Void
    var onProfileTap: () -> Void
    var onPaywallTap: () -> Void
    var onMarkRead: () -> Void
    var namespace: Namespace.ID // For matched geometry
    var isSearchActive: Bool
    
    @Query private var userProfiles: [UserProfileEntity]
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    
    private var avatarId: Int {
        userProfiles.first?.avatarId ?? 0
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Top Bar
            HStack {
                // Menu Button
                if !isSearchActive {
                    MenuButton(selectedOption: $selectedTab)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    // Search Button -> Source for morphing
                    if !isSearchActive {
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            onSearchTap()
                        }) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .matchedGeometryEffect(id: "SearchIcon", in: namespace)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.08))
                                        .matchedGeometryEffect(id: "SearchBackground", in: namespace)
                                )
                        }
                    }
                    
                    // Premium/Paywall Button (between search and profile)
                    if !isSearchActive {
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            onPaywallTap()
                        }) {
                            Image(systemName: subscriptionManager.isPremium ? "crown.fill" : "lock.fill")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(Color.white.opacity(0.08))
                                )
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                    
                    // Profile Button
                    if !isSearchActive {
                        Button(action: onProfileTap) {
                            if avatarId > 0 {
                                Image("\(avatarId)")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                            } else {
                                ZStack {
                                    Circle()
                                        .fill(Color.white.opacity(0.08))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "person")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
            }
            
            // Streak Card
            if !isSearchActive {
                ReadingStreakCard(streakData: streakData, onMarkRead: onMarkRead)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 60) // Safe area approx
        .padding(.bottom, 30)
        .background(
            AppColors.headerGradient
        )
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 24, bottomTrailingRadius: 24))
        .edgesIgnoringSafeArea(.top)
    }
}

// Helper for corner radius
struct UnevenRoundedRectangle: Shape {
    var topLeadingRadius: CGFloat = 0
    var bottomLeadingRadius: CGFloat = 0
    var bottomTrailingRadius: CGFloat = 0
    var topTrailingRadius: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let tl = topLeadingRadius
        let tr = topTrailingRadius
        let bl = bottomLeadingRadius
        let br = bottomTrailingRadius

        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr), radius: tr,
                    startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br), radius: br,
                    startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl), radius: bl,
                    startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl), radius: tl,
                    startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)

        return path
    }
}
