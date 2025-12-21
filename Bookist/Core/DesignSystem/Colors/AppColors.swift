import SwiftUI

struct LightModeColors {
    static let background = Color(hex: "#FFFFFF")
    static let cardBackground = Color(hex: "#F5F5F5")
    static let headerDark = Color(hex: "#1A1A1A")
    static let primaryText = Color(hex: "#000000")
    static let secondaryText = Color(hex: "#666666")
    static let accent = Color(hex: "#6366F1") // Purple
    static let accentOrange = Color(hex: "#FF6B35")
    static let divider = Color(hex: "#E5E5E5")
}

struct DarkModeColors {
    static let background = Color(hex: "#000000")
    static let cardBackground = Color(hex: "#1A1A1A")
    static let headerLight = Color(hex: "#FFFFFF")
    static let primaryText = Color(hex: "#FFFFFF")
    static let secondaryText = Color(hex: "#A0A0A0")
    static let accent = Color(hex: "#818CF8") // Lighter Purple
    static let accentOrange = Color(hex: "#FF8C6B")
    static let divider = Color(hex: "#333333")
}

struct AppColors {
    // Dynamic Colors that adapt to color scheme
    static let background = Color(light: LightModeColors.background, dark: DarkModeColors.background)
    static let cardBackground = Color(light: LightModeColors.cardBackground, dark: DarkModeColors.cardBackground)
    static let primaryText = Color(light: LightModeColors.primaryText, dark: DarkModeColors.primaryText)
    static let secondaryText = Color(light: LightModeColors.secondaryText, dark: DarkModeColors.secondaryText)
    static let accent = Color(light: LightModeColors.accent, dark: DarkModeColors.accent)
    static let accentOrange = Color(light: LightModeColors.accentOrange, dark: DarkModeColors.accentOrange)
    static let divider = Color(light: LightModeColors.divider, dark: DarkModeColors.divider)
    
    // Header background adapts inversely or specifically
    static let headerBackground = Color(light: LightModeColors.headerDark, dark: DarkModeColors.headerLight)
    static let headerText = Color(light: .white, dark: .black) // Text on header background
    
    // Gradients
    static var headerGradient: LinearGradient {
        LinearGradient(
            stops: [
                Gradient.Stop(color: Color(hex: "#323232"), location: 0.33),
                Gradient.Stop(color: Color(hex: "#000000"), location: 1.00)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    // Reversed Gradient for Dark Mode (User Request: "in dark mode colors of lenar gradient should reverse")
    static var headerGradientDark: LinearGradient {
        LinearGradient(
            stops: [
                Gradient.Stop(color: Color(hex: "#000000"), location: 0.0),
                Gradient.Stop(color: Color(hex: "#323232"), location: 1.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    // Shadows
    static let streakCardShadow = Color(hex: "#1B1C20").opacity(0.46)
    static let streakCardBorder = Color(hex: "#1B1C20").opacity(0.06)
    
    // Specific UI Element Colors
    static let streakCardBackground = Color(light: .white, dark: Color(hex: "#1C1C1E"))
    static let buttonBackground = Color(light: .black, dark: .white)
    static let buttonText = Color(light: .white, dark: .black)
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(dynamicProvider: { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        }))
    }
}
