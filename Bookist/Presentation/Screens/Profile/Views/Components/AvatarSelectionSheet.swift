import SwiftUI

struct AvatarSelectionSheet: View {
    @Binding var selectedAvatarId: Int
    @Environment(\.dismiss) private var dismiss
    
    private let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Choose an Avatar")
                .font(.system(size: 24, weight: .bold))
                .padding(.horizontal, 20)
                .padding(.top, 24)
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(1...42, id: \.self) { id in
                        Button(action: {
                            HapticHelper.light()
                            selectedAvatarId = id
                            dismiss()
                        }) {
                            Image("\(id)")
                                .renderingMode(.original)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 56, height: 56)
                                .clipShape(Circle())
                                .overlay(alignment: .bottomTrailing) {
                                    if selectedAvatarId == id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(.white, Color(hex: "5142E1"))
                                            .font(.system(size: 20))
                                            .offset(x: 4, y: -4)
                                    }
                                }
                        }
                    }
                }
                .drawingGroup() // Flattens the rendering path for 42 items
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .presentationCornerRadius(24)
        .presentationDetents([.medium, .large])
    }
}
