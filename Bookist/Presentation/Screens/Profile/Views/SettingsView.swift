import SwiftUI
import SafariServices

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfUse = false
    
    var body: some View {
        ZStack(alignment: .top) {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Custom Header
                headerSection
                
                // Settings Content
                ScrollView {
                    VStack(spacing: 0) {
                        // Privacy Policy Row
                        SettingsRowButton(
                            icon: "lock.shield.fill",
                            title: "Privacy Policy",
                            action: {
                                HapticHelper.light()
                                showingPrivacyPolicy = true
                            }
                        )
                        
                        Divider()
                            .padding(.leading, 60)
                        
                        // Terms of Use Row
                        SettingsRowButton(
                            icon: "doc.text.fill",
                            title: "Terms of Use",
                            action: {
                                HapticHelper.light()
                                showingTermsOfUse = true
                            }
                        )
                    }
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingPrivacyPolicy) {
            SafariView(url: URL(string: "https://doc-hosting.flycricket.io/bookist/d16c5b6e-c9c9-4362-b57e-df81e1fda38f/privacy")!)
        }
        .sheet(isPresented: $showingTermsOfUse) {
            SafariView(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
        }
    }
    
    private var headerSection: some View {
        ZStack {
            HStack {
                CustomNavBarButton(icon: "chevron.left", action: {
                    dismiss()
                })
                Spacer()
            }
            
            Text("Settings")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(AppColors.primaryText)
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
        .padding(.bottom, 10)
    }
}

struct SettingsRowButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(AppColors.primaryText)
                    .frame(width: 28)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.primaryText)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(AppColors.secondaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(AppColors.cardBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}
