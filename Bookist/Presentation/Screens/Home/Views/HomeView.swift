import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var searchViewModel = SearchViewModel()
    @State private var selectedTab = "For You"
    @State private var path = NavigationPath()
    @State private var isSearchActive = false
    @Namespace private var namespace
    @State private var headerBottomY: CGFloat = 380 // Default to avoid jump
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    private var contentHorizontalPadding: CGFloat {
        16
    }
    
    private var columns: [GridItem] {
        let count = horizontalSizeClass == .regular ? 5 : 3
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: count)
    }
    
    private func gridContentPadding(screenWidth: CGFloat) -> CGFloat {
        let count: CGFloat = horizontalSizeClass == .regular ? 5 : 3
        let totalSpacing = (count - 1) * 16
        let availableWidth = screenWidth - 32 // 16 leading + 16 trailing
        let columnWidth = (availableWidth - totalSpacing) / count
        let itemWidth: CGFloat = 120
        
        let centeringOffset = max(0, (columnWidth - itemWidth) / 2)
        return 16 + centeringOffset
    }
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack(alignment: .top) {
                Color.white.ignoresSafeArea() // Strict White Background
                
                GeometryReader { geometry in
                    let dynamicPadding = gridContentPadding(screenWidth: geometry.size.width)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            // Spacer from top of screen to bottom of header + 24px padding
                            Color.clear.frame(height: headerBottomY + 24)
                            
                            let recentlyReadVisible = !viewModel.recentlyReadBooks.isEmpty && selectedTab != "Trending"
                            
                            VStack(spacing: 0) {
                                // Recently Read Section
                                if recentlyReadVisible {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("Recently Read")
                                            .textStyle(.title2)
                                            .foregroundColor(AppColors.primaryText)
                                            .padding(.leading, contentHorizontalPadding)
                                            .padding(.trailing, contentHorizontalPadding)
                                        
                                        ScrollView(.horizontal, showsIndicators: false) {
                                            LazyHGrid(rows: [GridItem(.flexible())], spacing: 16) {
                                                ForEach(viewModel.recentlyReadBooks) { book in
                                                    BookCard(book: book)
                                                        .onTapGesture {
                                                            path.append(book)
                                                        }
                                                }
                                            }
                                            .scrollTargetLayout()
                                        }
                                        .contentMargins(.horizontal, dynamicPadding, for: .scrollContent)
                                    }
                                    .padding(.top, 0) // Gap is from header spacer
                                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                }
                            
                            // Popular Books Section
                            // Always use Grid Layout for Popular Books
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Popular Books")
                                    .textStyle(.title2)
                                    .foregroundColor(Color.black) // Strict Black
                                    .padding(.leading, contentHorizontalPadding)
                                    .padding(.trailing, contentHorizontalPadding)
                                    .padding(.top, recentlyReadVisible ? 24 : 0) // Precise gap
                                
                                // Real Data Grid
                                if !viewModel.popularBooks.isEmpty {
                                    LazyVGrid(columns: columns, spacing: 16) {
                                        let books = viewModel.popularBooks
                                        ForEach(Array(books.enumerated()), id: \.element.id) { index, book in
                                            BookCard(book: book, showDetails: true)
                                                .onTapGesture {
                                                    path.append(book)
                                                }
                                                .onAppear {
                                                    // Prefetching: Load more earlier if on iPad
                                                    let threshold = horizontalSizeClass == .regular ? 10 : 6
                                                    if index >= books.count - threshold {
                                                        viewModel.loadMorePopularBooks()
                                                    }
                                                }
                                        }
                                        
                                        // Pagination Shimmers while loading more pages
                                        if viewModel.isLoadingMore {
                                            let shimCount = horizontalSizeClass == .regular ? 10 : 6
                                            ForEach(0..<shimCount, id: \.self) { _ in
                                                SkeletonBookCard()
                                            }
                                        }
                                    }
                                    .padding(.horizontal, contentHorizontalPadding)
                                    .padding(.bottom, 24)
                                }
                                
                                // Initial Loading Skeletons (Detailed Grid)
                                if viewModel.state == .loading && viewModel.popularBooks.isEmpty {
                                    LazyVGrid(columns: columns, spacing: 16) {
                                        let shimCount = horizontalSizeClass == .regular ? 15 : 9
                                        ForEach(0..<shimCount, id: \.self) { _ in
                                            SkeletonBookCard()
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.bottom, 24)
                                }
                            }
                            .transition(.opacity)
                        }
                        .padding(.top, 0)
                        
                        // Bottom spacer for scrolling
                        Color.clear.frame(height: 100)
                    }
                }
                .refreshable {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    viewModel.loadInitialData(forceRefresh: true)
                }
                .ignoresSafeArea(.all, edges: .top) // Allow scrollview to go under header visually
                .opacity(isSearchActive ? 0 : 1) // Only fade content
                }
                
                // Fixed Header with MaxY Measurement (Always visible, handles its own transitions)
                HeaderView(
                    selectedTab: $selectedTab,
                    streakData: viewModel.weeklyStreak,
                    onSearchTap: {
                        withAnimation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.2)) {
                            isSearchActive = true
                        }
                    },
                    onProfileTap: {
                        path.append(HomeNavigation.profile)
                    },
                    onMarkRead: {
                        viewModel.markTodayRead()
                    },
                    namespace: namespace,
                    isSearchActive: isSearchActive
                )
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: HeaderMaxYKey.self, value: geo.frame(in: .global).maxY)
                    }
                )
                
                // Confetti Overlay - Persistent to avoid layout glitches
                ConfettiView(isActive: viewModel.showConfetti)
                    .zIndex(5)
                
                // --- Layer 2: Search Overlay ---
                if isSearchActive {
                    SearchView(
                        viewModel: searchViewModel,
                        isActive: $isSearchActive,
                        onBookTap: { book in
                            path.append(book)
                        },
                        namespace: namespace
                    )
                    .zIndex(2)
                }
            }
            .onPreferenceChange(HeaderMaxYKey.self) { maxY in
                        // Only update if legit
                        if maxY > 0 && abs(headerBottomY - maxY) > 1 {
                            headerBottomY = maxY
                        }
                    }
                    .onAppear {
                        viewModel.loadInitialData()
                    }
                    .navigationDestination(for: Book.self) { book in
                        BookDetailView(bookId: book.id, previewBook: book)
                    }
                    .navigationDestination(for: HomeNavigation.self) { route in
                        switch route {
                        case .profile:
                            ProfileView()
                        }
                    }
        }
    }
}

struct HeaderMaxYKey: PreferenceKey {
    static var defaultValue: CGFloat = 380
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

enum HomeNavigation: Hashable {
    case profile
}
