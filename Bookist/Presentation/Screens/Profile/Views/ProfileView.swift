import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab = 0
    @State private var showingAvatarSheet = false
    @State private var localAvatarId = 0
    @State private var localUserName = ""
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack(alignment: .top) {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                ProfileHeaderView(
                    userName: $localUserName,
                    avatarId: $viewModel.avatarId,
                    booksRead: viewModel.booksReadCount,
                    reviewed: viewModel.reviewsCount,
                    onSettingsTap: {
                        // TODO: Open Settings
                    },
                    onBackTap: {
                        dismiss()
                    },
                    onAvatarTap: {
                        localAvatarId = viewModel.avatarId
                        showingAvatarSheet = true
                    },
                    onNameEditingChanged: { isEditing in
                        if !isEditing {
                            viewModel.userName = localUserName
                        }
                    }
                )
                
                // Tabs with divider overlap logic
                ZStack(alignment: .bottom) {
                    Divider()
                        .background(Color.black.opacity(0.1))
                    
                    CustomSegmentControl(selectedIndex: $selectedTab, titles: ["Stats", "Lists", "Reviews"])
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
        .onAppear {
            viewModel.loadProfile()
            localUserName = viewModel.userName
            // Pre-load all avatar images to avoid dyld lookup during sheet animation
            Task.detached(priority: .background) {
                for id in 1...42 {
                    _ = UIImage(named: "\(id)")
                }
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
}
