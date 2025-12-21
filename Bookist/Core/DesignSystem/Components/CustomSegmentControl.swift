import SwiftUI

struct CustomSegmentControl: View {
    @Binding var selectedIndex: Int
    let titles: [String]
    
    @Namespace private var animation
    
    var body: some View {
        VStack(spacing: 0) {
            // Top divider
            Divider()
                .background(Color.black.opacity(0.1))
            
            // Tabs
            HStack(spacing: 0) {
                ForEach(titles.indices, id: \.self) { index in
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedIndex = index
                        }
                    }) {
                        VStack(spacing: 0) {
                            Text(titles[index])
                                .font(.headline)
                                .foregroundColor(selectedIndex == index ? .black : Color.black.opacity(0.6))
                                .padding(.vertical, 16)
                            
                            // Underline - overlaps bottom divider
                            if selectedIndex == index {
                                Rectangle()
                                    .fill(Color.black)
                                    .frame(height: 2)
                                    .matchedGeometryEffect(id: "underline", in: animation)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            
            // Bottom divider
            Divider()
                .background(Color.black.opacity(0.1))
        }
    }
}
