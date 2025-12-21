//
//  ConfettiView.swift
//  Bookist
//
//  Created by Ammad Akhtar on 21/12/2025.
//

import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    let isActive: Bool

    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation) { timeline in
                Canvas { context, size in
                    let now = timeline.date.timeIntervalSinceReferenceDate

                    for particle in particles {
                        let progress = now - particle.creationDate

                        if progress < particle.lifetime {
                            // Physics: x = x0 + vx*t, y = y0 + vy*t + 0.5*g*t^2
                            // g = 1000 (gravity)
                            let t = max(0, CGFloat(progress))
                            let x = particle.startX + (particle.vx * t)
                            let y = particle.startY + (particle.vy * t) + (500 * t * t)

                            let opacity = 1.0 - (progress / particle.lifetime)

                            var pContext = context
                            pContext.opacity = opacity
                            pContext.translateBy(x: x, y: y)
                            pContext.rotate(by: .degrees(progress * particle.rotationSpeed * 360))

                            let rect = CGRect(x: -particle.size/2, y: -particle.size/2, width: particle.size, height: particle.size)
                            pContext.fill(
                                Path(roundedRect: rect, cornerRadius: 2),
                                with: .color(particle.color)
                            )
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
        .onChange(of: isActive) { oldValue, newValue in
            if newValue {
                createExplosion()
            }
        }
    }

    private func createExplosion() {
        let colors: [Color] = [
            .yellow, .purple, .cyan, .red, .green, .orange, .pink, .blue
        ]

        let screen = UIScreen.main.bounds
        var newParticles: [ConfettiParticle] = []

        // Create a burst of particles
        for _ in 0..<150 {
            newParticles.append(ConfettiParticle(
                startX: screen.width / 2,
                startY: screen.height / 2 + 100, // Start lower
                vx: CGFloat.random(in: -300...300), // Wide spread
                vy: CGFloat.random(in: -900...(-500)), // Strong upward throw
                color: colors.randomElement() ?? .blue,
                rotationSpeed: Double.random(in: -3...3),
                size: CGFloat.random(in: 6...10),
                lifetime: Double.random(in: 3.0...5.0),
                creationDate: Date().timeIntervalSinceReferenceDate
            ))
        }

        self.particles = newParticles
    }
}

struct ConfettiParticle {
    let startX: CGFloat
    let startY: CGFloat
    let vx: CGFloat
    let vy: CGFloat
    let color: Color
    let rotationSpeed: Double
    let size: CGFloat
    let lifetime: Double
    let creationDate: TimeInterval
}
