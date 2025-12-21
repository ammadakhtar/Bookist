import SwiftUI

struct CustomNavBarButton: View {
    let icon: String
    let action: () -> Void
    var backgroundColor: Color = .white
    var iconColor: Color = .black
    
    var body: some View {
        Button(action: {
            HapticHelper.medium()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(iconColor)
                .frame(width: 40, height: 40)
                .background(backgroundColor)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
}
