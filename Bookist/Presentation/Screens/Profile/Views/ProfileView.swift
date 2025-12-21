import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedTab = 0
    @State private var showingAvatarSheet = false
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
                        // TODO: Open Settings
                    },
                    onBackTap: {
                        dismiss()
                    },
                    onAvatarTap: {
                        showingAvatarSheet = true
                    }
                )
                
                // Tabs with divider overlap logic
                ZStack(alignment: .bottom) {
                    Divider()
                        .background(Color.black.opacity(0.1))
                    
                    CustomSegmentControl(selectedIndex: $selectedTab, titles: ["Stats", "Lists", "Reviews"])
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        if selectedTab == 0 {
                            // Stats
                            GoalsCard(current: viewModel.booksReadCount, target: viewModel.readingGoal)
                            
                            FinishedCard(count: viewModel.booksReadCount)
                            
                            ReadingStreakCalendar()
                            
                        } else if selectedTab == 1 {
                            // Lists (Saved)
                            SavedBooksListView()
                        } else if selectedTab == 2 {
                             // Reviews
                            ReviewsListView()
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            viewModel.loadProfile()
        }
        .sheet(isPresented: $showingAvatarSheet) {
            AvatarSelectionSheet(selectedAvatarId: $viewModel.avatarId)
        }
    }
}
