import SwiftUI

struct AvatarSelectionSheet: View {
    @Binding var selectedAvatarId: Int
    @Environment(\.dismiss) private var dismiss
    
    private let avatarIds = Array(1...42)
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(avatarIds, id: \.self) { id in
                        Button {
                            HapticHelper.light()
                            selectedAvatarId = id
                            dismiss()
                        } label: {
                            ZStack {
                                Image("\(id)")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 72, height: 72)
                                    .clipShape(Circle())
                                
                                if selectedAvatarId == id {
                                    Image(systemName: "checkmark.circle.fill")
                                        .symbolRenderingMode(.palette)
                                        .foregroundStyle(.white, Color(hex: "5142E1"))
                                        .font(.system(size: 24))
                                        .offset(x: 26, y: 26)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 40)
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
        }
        .presentationCornerRadius(24)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(false)
    }
}
