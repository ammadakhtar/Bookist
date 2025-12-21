import SwiftUI

struct AnimationTiming {
    // Duration
    static let instant: Double = 0.15
    static let quick: Double = 0.25
    static let standard: Double = 0.35
    static let moderate: Double = 0.5
    static let slow: Double = 0.7
    
    // Spring Animations
    static let springResponse: Double = 0.5
    static let springDampingRatio: Double = 0.68
    
    // Curves
    static let easeIn = Animation.easeIn(duration: standard)
    static let easeOut = Animation.easeOut(duration: standard)
    static let easeInOut = Animation.easeInOut(duration: standard)
    static let spring = Animation.spring(
        response: springResponse,
        dampingFraction: springDampingRatio
    )
    static let smoothSpring = Animation.spring(
        response: 0.4,
        dampingFraction: 0.75
    )
}
