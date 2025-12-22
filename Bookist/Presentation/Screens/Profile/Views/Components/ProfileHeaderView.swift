import SwiftUI

struct ProfileHeaderView: View {
    @Binding var userName: String
    @Binding var avatarId: Int
    let booksRead: Int
    let reviewed: Int
    var onSettingsTap: () -> Void
    var onBackTap: () -> Void
    var onAvatarTap: () -> Void
    var onNameEditingChanged: (Bool) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Navbar
            ZStack(alignment: .center) {
                HStack {
                    CustomNavBarButton(icon: "chevron.left", action: onBackTap)
                    Spacer()
                    CustomNavBarButton(icon: "gearshape.fill", action: onSettingsTap)
                }
                
                Text("Profile")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .padding(.top, 60)
            .padding(.horizontal, 20)
            .ignoresSafeArea(edges: .top)
            
            // User Content
            HStack(spacing: 16) {
                // Avatar with Pencil
                ZStack(alignment: .topTrailing) {
                    Group {
                        if avatarId > 0 {
                            Image("\(avatarId)")
                                .resizable()
                                .scaledToFill()
                        } else {
                            ZStack {
                                Circle()
                                    .fill(Color.white)
                                
                                Image(systemName: "person")
                                    .font(.system(size: 24, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .onTapGesture {
                        onAvatarTap()
                    }
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image(systemName: "pencil")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.black)
                        )
                        .offset(x: 4, y: -4)
                        .shadow(radius: 2)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        TextField("Enter your name", text: $userName, onEditingChanged: onNameEditingChanged)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    HStack(spacing: 12) {
                        Text("\(booksRead) book reads")
                        Circle()
                            .fill(Color.white.opacity(0.4))
                            .frame(width: 4, height: 4)
                        Text("\(reviewed) reviewed")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(Color.white.opacity(0.7))
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
        .padding(.horizontal, 0)
        .background(
            AppColors.headerGradient
                .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: 24, bottomTrailingRadius: 24))
                .edgesIgnoringSafeArea(.top)
        )
    }
}
