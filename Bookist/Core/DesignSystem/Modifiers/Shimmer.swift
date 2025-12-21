import SwiftUI

struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = 0
    var duration: Double = 1.5
    var bounce: Bool = false

    func body(content: Content) -> some View {
        content
            .modifier(
                AnimatedMask(phase: phase).animation(
                    Animation.linear(duration: duration)
                        .repeatForever(autoreverses: bounce)
                )
            )
            .onAppear { phase = 0.8 }
    }

    struct AnimatedMask: AnimatableModifier {
        var phase: CGFloat = 0

        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }

        func body(content: Content) -> some View {
            content
                .mask(GradientMask(phase: phase).scaleEffect(3))
        }
    }

    struct GradientMask: View {
        let phase: CGFloat
        
        var body: some View {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.gray.opacity(1), location: phase),
                    .init(color: Color.gray.opacity(1), location: phase + 0.1),
                    .init(color: Color.gray.opacity(1), location: phase + 0.2)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(Shimmer())
    }
}
