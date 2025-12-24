import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab = 0
    @State private var pendingTabSelection: Int?
    @State private var showingAvatarSheet = false
    @State private var showingSettings = false
    @State private var localAvatarId = 0
    @ObservedObject private var adManager = AdManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ProfileHeaderView(
                    userName: $viewModel.userName,
                    avatarId: $viewModel.avatarId,
                    booksRead: viewModel.booksReadCount,
                    reviewed: viewModel.reviewsCount,
                    onSettingsTap: {
                        showingSettings = true
                    },
                    onBackTap: {
                        dismiss()
                    },
                    onAvatarTap: {
                        localAvatarId = viewModel.avatarId
                        showingAvatarSheet = true
                    }
                )
                    
                    // Tabs with divider overlap logic
                    ZStack(alignment: .bottom) {
                    Divider()
                        .background(Color.black.opacity(0.1))
                    
                    CustomSegmentControl(selectedIndex: Binding(
                        get: { selectedTab },
                        set: { newValue in handleTabSelection(newValue) }
                    ), titles: ["Stats", "Lists", "Reviews"])
                }
                
                ScrollView {
                    LazyVStack(spacing: 24, pinnedViews: []) {
                        if selectedTab == 0 {
                            // Stats
                            GoalsCard(current: viewModel.booksReadCount, target: viewModel.readingGoal)
                            
                            FinishedCard(count: viewModel.booksReadCount)
                            
                            ReadingStreakCalendar()
                                .id("calendar-\(selectedTab)")
                            
                        } else if selectedTab == 1 {
                            // Lists (Saved)
                            SavedBooksListView()
                                .id("saved-\(selectedTab)")
                        } else if selectedTab == 2 {
                             // Reviews
                            ReviewsListView()
                                .id("reviews-\(selectedTab)")
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationBarHidden(true)
            .navigationDestination(isPresented: $showingSettings) {
                SettingsView()
            }
            .task {
                await viewModel.loadProfile()
                // Pre-load interstitial for segment control
                adManager.preloadInterstitialForSection(.profileSegmentControl)
                
                // Pre-load all avatar images to avoid dyld lookup during sheet animation
                Task.detached(priority: .background) {
                    for id in 1...42 {
                        _ = UIImage(named: "\(id)")
                    }
                }
            }
            .onChange(of: pendingTabSelection) { _, newValue in
                if let newTab = newValue {
                    selectedTab = newTab
                    pendingTabSelection = nil
                }
            }
            .sheet(isPresented: $showingAvatarSheet) {
                AvatarSelectionSheet(selectedAvatarId: $localAvatarId)
                    .onDisappear {
                        if localAvatarId != viewModel.avatarId {
                            viewModel.avatarId = localAvatarId
                        }
                    }
            }
    }
    
    // MARK: - Ad Handling
    private func handleTabSelection(_ newTab: Int) {
        // Don't show ad if selecting the same tab
        guard newTab != selectedTab else { return }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            selectedTab = newTab
            return
        }
        
        // Try to show interstitial before tab switch
        let shown = adManager.showPreloadedInterstitial(
            for: .profileSegmentControl,
            from: rootVC,
            onSuccess: {
                // Ad dismissed, switch tab
                DispatchQueue.main.async {
                    pendingTabSelection = newTab
                }
            },
            onFailure: {
                // No ad, switch directly
                DispatchQueue.main.async {
                    selectedTab = newTab
                }
            }
        )
        
        if !shown {
            // No ad available, switch directly
            selectedTab = newTab
        }
    }
}
