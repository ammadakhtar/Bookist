import SwiftUI

struct TabSelectorView: View {
    @Binding var selectedTab: Int
    var tabs: [String] = ["About", "Review"]
    @Namespace private var namespace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                TabItem(
                    title: tabs[index],
                    index: index,
                    selectedTab: $selectedTab,
                    namespace: namespace
                )
            }
        }
        .background(AppColors.divider.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal, 20)
    }
}

private struct TabItem: View {
    let title: String
    let index: Int
    @Binding var selectedTab: Int
    let namespace: Namespace.ID
    
    var body: some View {
        Button(action: {
            withAnimation(AnimationTiming.smoothSpring) {
                selectedTab = index
            }
        }) {
            Text(title)
                .textStyle(.bodyBold)
                .foregroundColor(selectedTab == index ? AppColors.primaryText : AppColors.secondaryText)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(backgroundView)
        }
    }
    
    @ViewBuilder
    private var backgroundView: some View {
        if selectedTab == index {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 2)
                .padding(2)
                .matchedGeometryEffect(id: "Tab", in: namespace)
        }
    }
}
