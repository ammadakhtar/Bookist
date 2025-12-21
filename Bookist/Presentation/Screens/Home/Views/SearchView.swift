import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @Binding var isActive: Bool
    var onBookTap: (Book) -> Void
    var namespace: Namespace.ID
    
    @FocusState private var isFocused: Bool
    @State private var animateContent: Bool = true
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background Fade (Phase 2)
            Color.white
                .ignoresSafeArea()
                .opacity(animateContent ? 1 : 0)
            
            VStack(spacing: 0) {
                // Search Header
                HStack(spacing: 0) { // Spacing 0 to control internally
                    HStack(spacing: 8) {
                        // Magnifying Glass (Morph Phase 1)
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(animateContent ? AppColors.secondaryText : .white)
                            .matchedGeometryEffect(id: "SearchIcon", in: namespace)
                            .frame(width: 24, height: 24)
                        
                        // Text Field (Slide In Phase 1)
                        // Grouped with the text field to match layout
                        if animateContent {
                            TextField("Search books or authors...", text: $viewModel.query)
                                .focused($isFocused)
                                .foregroundColor(AppColors.primaryText)
                                .submitLabel(.search)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.none)
                                .onSubmit {
                                    viewModel.addToHistory(query: viewModel.query)
                                    viewModel.performSearch(query: viewModel.query)
                                }
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                            
                            if !viewModel.query.isEmpty {
                                Button(action: {
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    viewModel.query = ""
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(AppColors.secondaryText)
                                }
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 40) // Match Header Icon Height
                    .frame(maxWidth: .infinity, alignment: .leading) // Expand to fill
                    .background(
                        Capsule()
                            .fill(Color(white: 0.95))
                            .overlay(
                                Capsule()
                                    .stroke(Color.black.opacity(0.08), lineWidth: 1)
                            )
                            .matchedGeometryEffect(id: "SearchBackground", in: namespace)
                    )
                    
                    // Cancel Button (Slide In Phase 1)
                    if animateContent {
                        Button(action: closeSearch) {
                            Text("Cancel")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(AppColors.primaryText)
                                .padding(.leading, 12)
                        }
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 60) // Match Header Padding
                .padding(.bottom, 16)
                
                // Content (Fade Phase 2)
                ZStack {
                    if viewModel.query.isEmpty {
                        // History View
                        if !viewModel.history.isEmpty {
                            HistoryListView(
                                history: viewModel.history,
                                onSelect: { query in
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    viewModel.query = query
                                },
                                onClear: {
                                    viewModel.clearHistory()
                                }
                            )
                        } else {
                            // Empty State / Prompt
                            VStack(spacing: 16) {
                                Spacer()
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 50))
                                    .foregroundColor(.gray.opacity(0.3))
                                    .padding(.bottom, 8)
                                Text("Search for any book with title or\nauthor name and start reading")
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                    } else {
                        // Results View
                        if viewModel.isLoading {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(0..<6, id: \.self) { _ in
                                        SkeletonBookResultRow()
                                    }
                                }
                                .padding(16)
                            }
                        } else if let error = viewModel.error, viewModel.lastSearchedQuery == viewModel.query {
                            Text(error).foregroundColor(.red).padding()
                        } else if viewModel.results.isEmpty, viewModel.lastSearchedQuery == viewModel.query {
                            VStack {
                                Spacer()
                                Text("No results found for \"\(viewModel.query)\"")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        } else if !viewModel.results.isEmpty {
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(viewModel.results) { book in
                                        BookResultRow(book: book, onTap: onBookTap)
                                    }
                                }
                                .padding(16)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .opacity(animateContent ? 1 : 0) // Content Fade
            }
        }
        .ignoresSafeArea(edges: .top)
        .onAppear {
            // Phase 3: Focus after animation - Quicker for better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                isFocused = true
            }
        }
        .onChange(of: isFocused) { oldValue, newValue in
            // When focus is lost (didEndTextEditing), trigger search if not empty
            if !newValue && !viewModel.query.isEmpty {
                viewModel.performSearch(query: viewModel.query)
            }
        }
    }
    
    private func closeSearch() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        isFocused = false
        viewModel.clearSearch() // Clear state on cancel
        
        // Dismiss with animation - matched geometry will handle the transition
        withAnimation(.interactiveSpring(response: 0.9, dampingFraction: 0.8, blendDuration: 0.2)) {
            isActive = false
        }
    }
}

// Subviews
struct HistoryListView: View {
    let history: [SearchHistoryEntity]
    let onSelect: (String) -> Void
    let onClear: () -> Void
    
    var body: some View {
        List {
            Section {
                ForEach(history) { item in
                    Button(action: { onSelect(item.query) }) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.gray)
                            Text(item.query)
                                .foregroundColor(.primary)
                            Spacer()
                        }
                    }
                }
            } header: {
                HStack {
                    Text("Recent Searches")
                    Spacer()
                    Button("Clear", action: onClear)
                        .font(.caption)
                }
            }
        }
        .listStyle(.plain)
    }
}

struct BookResultRow: View {
    let book: Book
    let onTap: (Book) -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            CachedAsyncImage(url: book.coverImageURL) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.gray.opacity(0.15)
            }
            .frame(width: 50, height: 75)
            .cornerRadius(6)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                    .lineLimit(2)
                    .foregroundColor(AppColors.primaryText)
                
                if let author = book.authors.first {
                    Text(author.name)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .background(Color.white) // Tappable area
        .onTapGesture {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            onTap(book)
        }
    }
}

struct SkeletonBookResultRow: View {
    var body: some View {
        HStack(spacing: 12) {
            ShimmerImage(width: 50, height: 75)
                .cornerRadius(6)
            
            VStack(alignment: .leading, spacing: 8) {
                ShimmerText(width: 150, height: 16)
                ShimmerText(width: 100, height: 12)
            }
            Spacer()
        }
    }
}
