import SwiftUI

enum AppFontWeight {
    case regular, medium, semibold, bold
    
    var swiftUIWeight: Font.Weight {
        switch self {
        case .regular: return .regular
        case .medium: return .medium
        case .semibold: return .semibold
        case .bold: return .bold
        }
    }
}

enum AppFontSize {
    case caption     // 12pt
    case body        // 15pt
    case bodyLarge   // 17pt
    case title       // 20pt
    case titleLarge  // 24pt
    case headline    // 28pt
    case display     // 34pt
    
    var size: CGFloat {
        switch self {
        case .caption: return 12
        case .body: return 15
        case .bodyLarge: return 17
        case .title: return 20
        case .titleLarge: return 24
        case .headline: return 28
        case .display: return 34
        }
    }
}

struct TextStyle {
    let size: AppFontSize
    let weight: AppFontWeight
    let lineHeight: CGFloat
    let letterSpacing: CGFloat
    
    // Predefined Styles
    static let largeTitle = TextStyle(size: .display, weight: .bold, lineHeight: 41, letterSpacing: 0)
    static let title1 = TextStyle(size: .headline, weight: .bold, lineHeight: 34, letterSpacing: 0.36)
    static let title2 = TextStyle(size: .titleLarge, weight: .semibold, lineHeight: 29, letterSpacing: 0.35)
    static let headline = TextStyle(size: .title, weight: .semibold, lineHeight: 24, letterSpacing: 0.38)
    static let body = TextStyle(size: .bodyLarge, weight: .regular, lineHeight: 22, letterSpacing: -0.41)
    static let bodyBold = TextStyle(size: .bodyLarge, weight: .semibold, lineHeight: 22, letterSpacing: -0.41)
    static let caption = TextStyle(size: .caption, weight: .regular, lineHeight: 16, letterSpacing: 0)
}

struct TextStyleModifier: ViewModifier {
    let style: TextStyle
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: style.size.size, weight: style.weight.swiftUIWeight))
            .kerning(style.letterSpacing)
            .lineSpacing(style.lineHeight - style.size.size)
    }
}

extension View {
    func textStyle(_ style: TextStyle) -> some View {
        self.modifier(TextStyleModifier(style: style))
    }
}
